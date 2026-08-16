import SwiftUI
import AVFoundation
import UIKit

enum MemoryVideoResourceError: LocalizedError {
    case missing(String)
    case empty(String)
    case notPlayable(String)
    case thumbnailFailed(String)
    case copyFailed(String, Error)

    var errorDescription: String? {
        switch self {
        case .missing(let name):
            return "Video ‘\(name)’ was not found in the Isle target."
        case .empty(let name):
            return "Video ‘\(name)’ is empty."
        case .notPlayable(let name):
            return "Video ‘\(name)’ is not playable."
        case .thumbnailFailed(let name):
            return "Could not create a thumbnail for ‘\(name)’ ."
        case .copyFailed(let name, let error):
            return "Could not prepare ‘\(name)’: \(error.localizedDescription)"
        }
    }
}

enum MemoryVideoResource {
    private static let supportedExtensions = ["mp4", "mov", "m4v"]

    @MainActor
    static func url(for assetName: String) throws -> URL {
        let source = assetName as NSString
        let suppliedExtension = source.pathExtension.lowercased()
        let resourceName = source.deletingPathExtension

        if suppliedExtension.isEmpty {
            for fileExtension in supportedExtensions {
                if let bundledURL = Bundle.main.url(
                    forResource: assetName,
                    withExtension: fileExtension
                ) {
                    print("✅ Video file found: \(bundledURL.lastPathComponent)")
                    return bundledURL
                }
            }
        } else if let bundledURL = Bundle.main.url(
            forResource: resourceName,
            withExtension: suppliedExtension
        ) {
            print("✅ Video file found: \(bundledURL.lastPathComponent)")
            return bundledURL
        }

        // Videos placed in a blue folder/group may be copied into a bundle
        // subfolder, so search the app resources recursively as well.
        if let resourceRoot = Bundle.main.resourceURL,
           let enumerator = FileManager.default.enumerator(
                at: resourceRoot,
                includingPropertiesForKeys: [.isRegularFileKey],
                options: [.skipsHiddenFiles]
           ) {
            for case let candidate as URL in enumerator {
                guard supportedExtensions.contains(
                    candidate.pathExtension.lowercased()
                ) else {
                    continue
                }

                if candidate.deletingPathExtension().lastPathComponent
                    .caseInsensitiveCompare(resourceName) == .orderedSame {
                    print(
                        "✅ Video file found recursively:",
                        candidate.lastPathComponent
                    )
                    return candidate
                }
            }
        }

        let dataAssetName = suppliedExtension.isEmpty ? assetName : resourceName
        guard let dataAsset = NSDataAsset(name: dataAssetName) else {
            throw MemoryVideoResourceError.missing(dataAssetName)
        }

        let data = dataAsset.data
        guard !data.isEmpty else {
            throw MemoryVideoResourceError.empty(dataAssetName)
        }

        let temporaryExtension = inferredExtension(
            typeIdentifier: dataAsset.typeIdentifier,
            data: data
        )
        let safeName = dataAssetName
            .components(
                separatedBy: CharacterSet.alphanumerics.inverted
            )
            .filter { !$0.isEmpty }
            .joined(separator: "-")
        let fingerprint = String(
            UInt(bitPattern: data.hashValue),
            radix: 16
        )

        let temporaryURL = FileManager.default.temporaryDirectory
            .appendingPathComponent(
                "isle-\(safeName)-\(fingerprint).\(temporaryExtension)"
            )

        do {
            // Do not replace a file that AVPlayer or AVAssetImageGenerator
            // may already be reading. The content fingerprint creates a new
            // URL only when the Data Asset actually changes.
            if !FileManager.default.fileExists(
                atPath: temporaryURL.path
            ) {
                try data.write(
                    to: temporaryURL,
                    options: .atomic
                )
            }

            print(
                "✅ Video Data Asset prepared:",
                dataAssetName,
                "|",
                dataAsset.typeIdentifier,
                "|",
                temporaryURL.lastPathComponent
            )
            return temporaryURL
        } catch {
            throw MemoryVideoResourceError.copyFailed(
                dataAssetName,
                error
            )
        }
    }

    private static func inferredExtension(
        typeIdentifier: String,
        data: Data
    ) -> String {
        let lowercasedType = typeIdentifier.lowercased()

        if lowercasedType.contains("quicktime") {
            return "mov"
        }

        if lowercasedType.contains("m4v") {
            return "m4v"
        }

        if lowercasedType.contains("mpeg-4")
            || lowercasedType.contains("mp4") {
            return "mp4"
        }

        // ISO Base Media files keep their major brand at bytes 8...11.
        // QuickTime uses "qt  "; most H.264/H.265 MP4 exports use another
        // brand such as isom/mp42 and should keep the mp4 extension.
        if data.count >= 12 {
            let brandData = data.subdata(in: 8..<12)
            let brand = String(
                data: brandData,
                encoding: .ascii
            )

            if brand == "qt  " {
                return "mov"
            }
        }

        return "mp4"
    }
}

struct VideoMemoryDetailView: View {
    let memory: HeavenMemoryItem
    let onViewFullScreen: () -> Void

    init(
        memory: HeavenMemoryItem,
        onViewFullScreen: @escaping () -> Void = {}
    ) {
        self.memory = memory
        self.onViewFullScreen = onViewFullScreen
    }

    var body: some View {
        HStack(alignment: .top, spacing: 50) {
            VStack(spacing: 40) {
                ZStack {
                    MemoryVideoThumbnail(
                        memory: memory,
                        maximumSize: CGSize(width: 1600, height: 1200)
                    )
                    .frame(width: 800, height: 600)
                    .clipped()

                    Button {
                        onViewFullScreen()
                    } label: {
                        Image(systemName: "play.circle.fill")
                            .font(.system(size: 110))
                            .foregroundStyle(.white.opacity(0.92))
                            .shadow(color: .black.opacity(0.45), radius: 18)
                    }
                    .buttonStyle(.plain)
                    .hoverEffect(.highlight)
                }
                .frame(width: 800, height: 600)
                .background(Color.black)
                .clipShape(
                    RoundedRectangle(cornerRadius: 50, style: .continuous)
                )
                .padding(10)
                .background(
                    .white.opacity(0.10),
                    in: RoundedRectangle(cornerRadius: 50, style: .continuous)
                )
                .overlay {
                    RoundedRectangle(cornerRadius: 50, style: .continuous)
                        .stroke(.white, lineWidth: 1)
                }
                .shadow(color: .white.opacity(0.62), radius: 36)

                Button {
                    onViewFullScreen()
                } label: {
                    HStack(spacing: 12) {
                        Image(systemName: "arrow.up.left.and.arrow.down.right")
                        Text("View in Cinema Mode")
                    }
                    .font(.system(size: 24, weight: .medium))
                    .foregroundStyle(.white)
                    .frame(width: 800, height: 54)
                    .contentShape(Rectangle())
                }
                .buttonStyle(.plain)
                .hoverEffect(.highlight)
            }

            informationPanel
        }
        .frame(width: 1371, height: 700)
    }

    private var informationPanel: some View {
        VStack(alignment: .leading, spacing: 24) {
            VStack(alignment: .leading, spacing: 8) {
                Text(memory.title)
                    .font(.system(size: 48, weight: .bold, design: .serif))
                    .foregroundStyle(.white)

                Text("Video memory")
                    .font(.system(size: 20, weight: .medium))
                    .foregroundStyle(.white)
            }

            Rectangle()
                .fill(.white.opacity(0.32))
                .frame(height: 1)

            Text(memory.description)
                .font(.system(size: 24, weight: .medium))
                .lineSpacing(8)
                .foregroundStyle(.white)

            Spacer(minLength: 0)
        }
        .padding(40)
        .frame(width: 500, height: 620, alignment: .topLeading)
        .background {
            RoundedRectangle(cornerRadius: 50, style: .continuous)
                .fill(.black.opacity(0.10))
                .overlay {
                    RoundedRectangle(cornerRadius: 50, style: .continuous)
                        .stroke(.white.opacity(0.50), lineWidth: 0.5)
                }
        }
        .shadow(color: .black.opacity(0.10), radius: 20)
    }
}
