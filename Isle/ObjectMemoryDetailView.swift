import SwiftUI

struct ObjectMemoryDetailView: View {
    let memory: HeavenMemoryItem
    let onViewLarger: () -> Void

    init(
        memory: HeavenMemoryItem,
        onViewLarger: @escaping () -> Void = {}
    ) {
        self.memory = memory
        self.onViewLarger = onViewLarger
    }

    var body: some View {
        VStack(spacing: 34) {
            Button(action: onViewLarger) {
                // The USDZ is rendered by ImmersiveView as a real
                // RealityKit entity so its scene lights affect it.
                Color.clear
                    .frame(width: 500, height: 500)
                    .contentShape(Rectangle())
            }
            .buttonStyle(.plain)
            .hoverEffect(.highlight)
            .accessibilityLabel("View \(memory.title) larger")

            informationPanel
        }
        .frame(width: 1371, height: 850)
    }

    private var informationPanel: some View {
        VStack(spacing: 24) {
            Text(memory.title)
                .font(
                    .system(
                        size: 38,
                        weight: .bold,
                        design: .serif
                    )
                )
                .foregroundStyle(.white)

            Text(memory.description)
                .font(.system(size: 24, weight: .medium))
                .lineSpacing(7)
                .multilineTextAlignment(.center)
                .foregroundStyle(.white)
                .frame(maxWidth: 1080)
        }
        .padding(.horizontal, 70)
        .padding(.vertical, 34)
        .frame(width: 1300, height: 237)
        .background {
            RoundedRectangle(
                cornerRadius: 20,
                style: .continuous
            )
            .fill(.black.opacity(0.20))
            .overlay {
                RoundedRectangle(
                    cornerRadius: 20,
                    style: .continuous
                )
                .stroke(.white.opacity(0.50), lineWidth: 0.5)
            }
        }
        .shadow(color: .black.opacity(0.10), radius: 20)
    }
}

struct ObjectMemoryExpandedView: View {
    let memory: HeavenMemoryItem
    let onRotate: (CGSize) -> Void

    @State private var previousTranslation = CGSize.zero

    init(
        memory: HeavenMemoryItem,
        onRotate: @escaping (CGSize) -> Void = { _ in }
    ) {
        self.memory = memory
        self.onRotate = onRotate
    }

    var body: some View {
        Color.clear
            .frame(width: 2100, height: 1250)
            .contentShape(Rectangle())
            .gesture(
                DragGesture(minimumDistance: 0)
                    .onChanged { value in
                        let delta = CGSize(
                            width:
                                value.translation.width
                                - previousTranslation.width,
                            height:
                                value.translation.height
                                - previousTranslation.height
                        )

                        previousTranslation = value.translation
                        onRotate(delta)
                    }
                    .onEnded { _ in
                        previousTranslation = .zero
                    }
            )
            .accessibilityLabel("Rotate \(memory.title)")
            .accessibilityHint(
                "Pinch and drag to rotate the object."
            )
    }
}

private struct ObjectMemoryPlaceholder: View {
    let title: String

    var body: some View {
        VStack(spacing: 20) {
            Image(systemName: "cube.transparent")
                .font(.system(size: 100))
                .foregroundStyle(.white.opacity(0.58))

            Text(title)
                .font(.system(size: 24, weight: .semibold))
                .foregroundStyle(.white.opacity(0.82))
                .multilineTextAlignment(.center)
        }
    }
}
