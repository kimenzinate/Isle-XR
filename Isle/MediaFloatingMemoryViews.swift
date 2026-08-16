import SwiftUI
import RealityKit
import AVFoundation
import UIKit

struct HeavenFloatingVideoMemory: View {
    let memory: HeavenMemoryItem
    let animationDelay: Double
    let action: () -> Void

    var body: some View {
        ZStack {
            videoPreview

            Image(systemName: "play.circle.fill")
                .font(
                    .system(
                        size:
                            min(
                                memory.width,
                                memory.height
                            )
                            * 0.15
                    )
                )
                .foregroundStyle(
                    .white.opacity(0.94)
                )
                .shadow(
                    color: .black.opacity(0.28),
                    radius: 4
                )
        }
        .frame(
            width: memory.width,
            height: memory.height
        )
        .clipShape(
            RoundedRectangle(
                cornerRadius: memory.cornerRadius,
                style: .continuous
            )
        )
        .overlay {
            RoundedRectangle(
                cornerRadius: memory.cornerRadius,
                style: .continuous
            )
            .stroke(
                .white.opacity(0.68),
                lineWidth: 0.8
            )
        }
        .overlay {
            IsleMiniTwinkles(
                width: memory.width,
                height: memory.height,
                isHighlighted: false,
                compact: false
            )
        }
        .hoverEffect { effect, isActive, _ in
            effect.animation(
                .easeOut(duration: 0.16)
            ) {
                $0
                    .scaleEffect(
                        isActive ? 1.045 : 1.0
                    )
                    .opacity(
                        isActive ? 1.0 : 0.92
                    )
            }
        }
        .contentShape(
            RoundedRectangle(
                cornerRadius: memory.cornerRadius,
                style: .continuous
            )
        )
        .onTapGesture {
            action()
        }
    }

    private var videoPreview: some View {
        MemoryVideoThumbnail(
            memory: memory,
            maximumSize: CGSize(
                width: 900,
                height: 675
            )
        )
        .frame(
            width: memory.width,
            height: memory.height
        )
    }
}

struct MemoryVideoThumbnail: View {
    let memory: HeavenMemoryItem
    let maximumSize: CGSize

    private enum LoadState {
        case loading
        case ready(UIImage)
        case failed
    }

    @State private var loadState: LoadState = .loading

    var body: some View {
        Group {
            switch loadState {
            case .ready(let image):
                Image(uiImage: image)
                    .resizable()
                    .scaledToFill()

            case .loading:
                LinearGradient(
                    colors: [
                        Color(red: 0.52, green: 0.61, blue: 0.78)
                            .opacity(0.48),
                        Color.black.opacity(0.72)
                    ],
                    startPoint: .topLeading,
                    endPoint: .bottomTrailing
                )
                .overlay {
                    ProgressView()
                        .controlSize(.large)
                        .tint(.white.opacity(0.78))
                }

            case .failed:
                LinearGradient(
                    colors: [
                        Color(red: 0.32, green: 0.38, blue: 0.52),
                        Color.black.opacity(0.88)
                    ],
                    startPoint: .topLeading,
                    endPoint: .bottomTrailing
                )
                .overlay {
                    Image(systemName: "exclamationmark.triangle.fill")
                        .font(.system(size: 54))
                        .foregroundStyle(.orange.opacity(0.88))
                }
            }
        }
        .clipped()
        .task(id: memory.id) {
            await loadImage()
        }
    }

    @MainActor
    private func loadImage() async {
        loadState = .loading

        guard let assetName = memory.assetName else {
            loadState = .failed
            return
        }

        // Optional manual poster fallback. If either image exists in Assets,
        // it is used immediately; otherwise a frame is generated from video.
        for posterName in [
            "\(assetName)_Poster",
            "\(assetName)_Thumbnail"
        ] {
            if let posterImage = UIImage(named: posterName) {
                loadState = .ready(posterImage)
                print("✅ Video poster found: \(posterName)")
                return
            }
        }

        do {
            let url = try MemoryVideoResource.url(for: assetName)
            let asset = AVURLAsset(url: url)
            let isPlayable = try await asset.load(.isPlayable)
            let videoTracks = try await asset.loadTracks(
                withMediaType: .video
            )

            guard isPlayable, !videoTracks.isEmpty else {
                throw MemoryVideoResourceError.notPlayable(assetName)
            }

            let generator = AVAssetImageGenerator(asset: asset)
            generator.appliesPreferredTrackTransform = true
            generator.maximumSize = maximumSize

            let requestedTimes = [
                CMTime(seconds: 0.35, preferredTimescale: 600),
                CMTime(seconds: 1.00, preferredTimescale: 600),
                CMTime.zero
            ]

            var generatedImage: CGImage?

            for time in requestedTimes {
                do {
                    let result = try await generator.image(at: time)
                    generatedImage = result.image
                    break
                } catch {
                    continue
                }
            }

            guard let generatedImage else {
                throw MemoryVideoResourceError.thumbnailFailed(assetName)
            }

            guard !Task.isCancelled else {
                return
            }

            loadState = .ready(UIImage(cgImage: generatedImage))
            print("✅ Video thumbnail generated: \(assetName)")
        } catch {
            loadState = .failed
            print("❌ Video thumbnail failed for \(assetName):", error)
        }
    }
}

struct HeavenFloatingObjectMemory: View {
    let memory: HeavenMemoryItem
    let animationDelay: Double
    let action: () -> Void

    var body: some View {
        ZStack {
            objectPreview
                .frame(
                    width: memory.width,
                    height: memory.height
                )

            // Compact placement keeps both stars close to the USDZ object
            // instead of placing them near the full attachment edges.
            IsleMiniTwinkles(
                width: memory.width,
                height: memory.height,
                isHighlighted: false,
                compact: true
            )
        }
        .frame(
            width: memory.width,
            height: memory.height
        )
        .hoverEffect { effect, isActive, _ in
            effect.animation(
                .easeOut(duration: 0.16)
            ) {
                $0
                    .scaleEffect(
                        isActive ? 1.055 : 1.0
                    )
                    .opacity(
                        isActive ? 1.0 : 0.92
                    )
            }
        }
        .contentShape(Rectangle())
        .onTapGesture {
            action()
        }
    }

    @ViewBuilder
    private var objectPreview: some View {
        if let assetName = memory.assetName {
            Model3D(named: assetName) { model in
                model
                    .resizable()
                    .scaledToFit()
            } placeholder: {
                ProgressView()
                    .controlSize(.large)
            }
        } else {
            Image(systemName: "cube.transparent")
                .font(.system(size: 116))
                .foregroundStyle(
                    .white.opacity(0.85)
                )
        }
    }
}
