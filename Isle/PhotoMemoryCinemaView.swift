import SwiftUI

struct PhotoMemoryCinemaView: View {
    let memory: HeavenMemoryItem

    private let cinemaWidth: CGFloat = 3000
    private let cinemaHeight: CGFloat = 1688

    var body: some View {
        ZStack {
            Color.black

            if let assetName = memory.assetName {
                Image(assetName)
                    .resizable()
                    .scaledToFill()
                    .frame(
                        width: cinemaWidth,
                        height: cinemaHeight
                    )
                    .clipped()
            } else {
                cinemaPlaceholder
            }
        }
        .frame(width: cinemaWidth, height: cinemaHeight)
        .clipped()
        // No rounded card and no local Back button. ImmersiveView owns
        // the fixed Back control so its size and position never change.
    }

    private var cinemaPlaceholder: some View {
        ZStack {
            Color.black

            VStack(spacing: 26) {
                Image(systemName: "photo.fill")
                    .font(.system(size: 120))
                    .foregroundStyle(.white.opacity(0.48))

                Text(memory.title)
                    .font(
                        .system(
                            size: 46,
                            weight: .semibold,
                            design: .serif
                        )
                    )
                    .foregroundStyle(.white.opacity(0.76))
            }
        }
        .frame(width: cinemaWidth, height: cinemaHeight)
    }
}
