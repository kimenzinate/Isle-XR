import SwiftUI

struct PhotoMemoryDetailView: View {
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
                memoryImage
                    .frame(width: 800, height: 600)
                    .clipped()
                    .clipShape(
                        RoundedRectangle(
                            cornerRadius: 50,
                            style: .continuous
                        )
                    )
                    .padding(10)
                    .background(
                        .white.opacity(0.10),
                        in: RoundedRectangle(
                            cornerRadius: 50,
                            style: .continuous
                        )
                    )
                    .overlay {
                        RoundedRectangle(
                            cornerRadius: 50,
                            style: .continuous
                        )
                        .stroke(.white, lineWidth: 1)
                    }
                    .shadow(
                        color: .white.opacity(0.62),
                        radius: 36
                    )

                Button(action: onViewFullScreen) {
                    HStack(spacing: 12) {
                        Image(
                            systemName:
                                "arrow.up.left.and.arrow.down.right"
                        )
                        Text("View Full Screen")
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

    @ViewBuilder
    private var memoryImage: some View {
        if let assetName = memory.assetName {
            Image(assetName)
                .resizable()
                .scaledToFill()
        } else {
            PhotoMemoryPlaceholder(title: memory.title)
        }
    }

    private var informationPanel: some View {
        VStack(alignment: .leading, spacing: 24) {
            VStack(alignment: .leading, spacing: 8) {
                Text(memory.title)
                    .font(
                        .system(
                            size: 48,
                            weight: .bold,
                            design: .serif
                        )
                    )
                    .foregroundStyle(.white)

                Text("Photo memory")
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
            RoundedRectangle(
                cornerRadius: 50,
                style: .continuous
            )
            .fill(.black.opacity(0.10))
            .overlay {
                RoundedRectangle(
                    cornerRadius: 50,
                    style: .continuous
                )
                .stroke(.white.opacity(0.50), lineWidth: 0.5)
            }
        }
        .shadow(color: .black.opacity(0.10), radius: 20)
    }
}

private struct PhotoMemoryPlaceholder: View {
    let title: String

    var body: some View {
        ZStack {
            LinearGradient(
                colors: [
                    .white.opacity(0.24),
                    .black.opacity(0.48)
                ],
                startPoint: .top,
                endPoint: .bottom
            )

            VStack(spacing: 16) {
                Image(systemName: "photo.fill")
                    .font(.system(size: 74))
                    .foregroundStyle(.white.opacity(0.55))

                Text(title)
                    .font(.system(size: 22, weight: .semibold))
                    .foregroundStyle(.white.opacity(0.82))
                    .multilineTextAlignment(.center)
                    .padding(.horizontal, 30)
            }
        }
    }
}
