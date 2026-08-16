import SwiftUI
import AVFoundation
import UIKit

private final class IsleCinemaPlayerUIView: UIView {
    override static var layerClass: AnyClass { AVPlayerLayer.self }

    var playerLayer: AVPlayerLayer { layer as! AVPlayerLayer }

    override init(frame: CGRect) {
        super.init(frame: frame)
        backgroundColor = .black
        playerLayer.backgroundColor = UIColor.black.cgColor
        playerLayer.videoGravity = AVLayerVideoGravity.resizeAspect
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}

private struct IsleCinemaPlayerLayerView: UIViewRepresentable {
    let player: AVPlayer?

    func makeUIView(context: Context) -> IsleCinemaPlayerUIView {
        let view = IsleCinemaPlayerUIView()
        view.playerLayer.player = player
        return view
    }

    func updateUIView(
        _ uiView: IsleCinemaPlayerUIView,
        context: Context
    ) {
        if uiView.playerLayer.player !== player {
            uiView.playerLayer.player = player
        }
    }

    static func dismantleUIView(
        _ uiView: IsleCinemaPlayerUIView,
        coordinator: Void
    ) {
        uiView.playerLayer.player = nil
    }
}

struct VideoMemoryCinemaView: View {
    let memory: HeavenMemoryItem
    let isActive: Bool

    @State private var player: AVPlayer?
    @State private var errorMessage: String?

    private let screenWidth: CGFloat = 3000
    private let screenHeight: CGFloat = 1688

    var body: some View {
        ZStack {
            Color.black

            if let player {
                IsleCinemaPlayerLayerView(player: player)
            } else if let errorMessage {
                VStack(spacing: 22) {
                    Image(systemName: "exclamationmark.triangle.fill")
                        .font(.system(size: 84))
                        .foregroundStyle(.orange)

                    Text("Video could not be played")
                        .font(.system(size: 44, weight: .bold))
                        .foregroundStyle(.white)

                    Text(errorMessage)
                        .font(.system(size: 24))
                        .foregroundStyle(.white.opacity(0.72))
                        .multilineTextAlignment(.center)
                }
                .padding(40)
            } else {
                ProgressView()
                    .controlSize(.extraLarge)
                    .tint(.white)
            }
        }
        .frame(width: screenWidth, height: screenHeight)
        .background(Color.black)
        .clipped()
        .onAppear {
            // Attachments may appear while their RealityKit entity is hidden.
            // Never start audio unless this exact cinema is active.
            if isActive {
                activatePlayback()
            }
        }
        .onChange(of: isActive) { _, active in
            if active {
                activatePlayback()
            } else {
                deactivatePlayback()
            }
        }
        .onDisappear {
            deactivatePlayback()
        }
    }

    @MainActor
    private func activatePlayback() {
        guard isActive else { return }

        if let player {
            player.play()
            return
        }

        guard let assetName = memory.assetName else {
            errorMessage = "No video asset name."
            return
        }

        do {
            let url = try MemoryVideoResource.url(for: assetName)

            let newPlayer = AVPlayer(url: url)
            newPlayer.automaticallyWaitsToMinimizeStalling = true
            newPlayer.isMuted = false
            newPlayer.volume = 1

            player = newPlayer
            errorMessage = nil
            newPlayer.play()

            print(
                "▶️ ACTIVE CINEMA ONLY:",
                memory.title,
                "|",
                assetName
            )
        } catch {
            errorMessage = error.localizedDescription
            print(
                "❌ Cinema failed:",
                assetName,
                "|",
                error.localizedDescription
            )
        }
    }

    @MainActor
    private func deactivatePlayback() {
        player?.pause()
        player = nil
    }
}
