import SwiftUI
import RealityKit
import AVFoundation
import simd
import UIKit

@MainActor
private final class CinemaVideoPlaybackStore {
    var player: AVPlayer?

    func makePlayer(assetName: String) throws -> AVPlayer {
        stop()

        let url = try MemoryVideoResource.url(for: assetName)
        let newPlayer = AVPlayer(url: url)
        newPlayer.actionAtItemEnd = .pause
        newPlayer.automaticallyWaitsToMinimizeStalling = true
        newPlayer.isMuted = false
        newPlayer.volume = 1

        player = newPlayer
        print("✅ Cinema AVPlayer created:", url.lastPathComponent)
        return newPlayer
    }

    func stop() {
        player?.pause()
        player = nil
    }
}

private enum ImmersiveExperienceStage: Equatable {
    case tutorial
    case heavenIsle
    case voiceIsle
    case voiceDetail
    case photoDetail
    case photoCinema
    case videoDetail
    case videoCinema
    case objectDetail
    case objectExpanded
    case noteDetail

    // Exit / reflection flow — 802:12809 → 802:12910
    case exitPrompt
    case reflectionComfort
    case reflectionFeeling
    case reflectionVoice
    case reflectionSaved
    case sessionEnd
}

// MARK: - Surprise / Random bubble

private struct SurpriseSparkleShape: Shape {
    func path(in rect: CGRect) -> Path {
        let cx = rect.midX
        let cy = rect.midY
        let outerX = rect.width / 2
        let outerY = rect.height / 2
        let innerX = rect.width * 0.10
        let innerY = rect.height * 0.10

        var path = Path()
        path.move(to: CGPoint(x: cx, y: cy - outerY))
        path.addLine(to: CGPoint(x: cx + innerX, y: cy - innerY))
        path.addLine(to: CGPoint(x: cx + outerX, y: cy))
        path.addLine(to: CGPoint(x: cx + innerX, y: cy + innerY))
        path.addLine(to: CGPoint(x: cx, y: cy + outerY))
        path.addLine(to: CGPoint(x: cx - innerX, y: cy + innerY))
        path.addLine(to: CGPoint(x: cx - outerX, y: cy))
        path.addLine(to: CGPoint(x: cx - innerX, y: cy - innerY))
        path.closeSubpath()
        return path
    }
}

private struct HeavenSurpriseBubbleButton: View {
    let size: CGFloat
    let action: () -> Void

    @State private var isPressed = false
    @State private var popProgress: CGFloat = 0

    private let sparkleLayout: [(CGFloat, CGFloat, CGFloat, Double)] = [
        (-0.24, -0.20, 0.018, 0.88),
        ( 0.18, -0.10, 0.015, 0.72),
        ( 0.12,  0.22, 0.013, 0.60),
        (-0.05,  0.28, 0.012, 0.52)
    ]

    private var isPopping: Bool {
        popProgress > 0.001
    }

    private var burstOpacity: Double {
        let p = Double(popProgress)
        return max(0, 4 * p * (1 - p))
    }

    private var dynamicCanvasSize: CGFloat {
        size * (1.04 + 0.24 * popProgress)
    }

    var body: some View {
        Button {
            popAndOpen()
        } label: {
            ZStack {
                dreamyGlassBubble

                Circle()
                    .stroke(
                        LinearGradient(
                            colors: [
                                .white.opacity(0.86),
                                .white.opacity(0.18),
                                .clear
                            ],
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        ),
                        lineWidth: max(1.2, size * 0.006)
                    )
                    .frame(
                        width: size * 0.78,
                        height: size * 0.78
                    )
                    .scaleEffect(0.92 + 0.44 * popProgress)
                    .opacity(burstOpacity * 0.90)

                Circle()
                    .fill(
                        RadialGradient(
                            colors: [
                                .white.opacity(0.72),
                                .white.opacity(0.18),
                                .clear
                            ],
                            center: .center,
                            startRadius: 0,
                            endRadius: size * 0.28
                        )
                    )
                    .frame(
                        width: size * 0.56,
                        height: size * 0.56
                    )
                    .scaleEffect(0.88 + 0.48 * popProgress)
                    .opacity(burstOpacity * 0.64)

                ForEach(
                    Array(sparkleLayout.enumerated()),
                    id: \.offset
                ) { _, item in
                    SurpriseSparkleShape()
                        .fill(.white.opacity(item.3))
                        .frame(
                            width: size * item.2,
                            height: size * item.2
                        )
                        .offset(
                            x: size * item.0 * (1.0 + 1.15 * popProgress),
                            y: size * item.1 * (1.0 + 1.15 * popProgress)
                        )
                        .scaleEffect(1.0 + 0.78 * popProgress)
                        .opacity(
                            popProgress > 0
                                ? max(0, 1.0 - Double(popProgress) * 0.90)
                                : 1.0
                        )
                }
            }
            .frame(
                width: dynamicCanvasSize,
                height: dynamicCanvasSize
            )
            .contentShape(Circle())
            .scaleEffect(
                isPopping
                    ? 1.0
                    : (isPressed ? 0.975 : 1.0)
            )
        }
        .buttonStyle(.plain)
        .hoverEffectDisabled()
        .contentShape(Circle())
        .simultaneousGesture(
            DragGesture(minimumDistance: 0)
                .onChanged { _ in
                    guard !isPopping else { return }
                    withAnimation(.easeOut(duration: 0.08)) {
                        isPressed = true
                    }
                }
                .onEnded { _ in
                    guard !isPopping else { return }
                    withAnimation(.easeOut(duration: 0.10)) {
                        isPressed = false
                    }
                }
        )
        .accessibilityLabel("Open a random memory")
        .accessibilityHint("Pinch to pop the bubble and open its memory detail.")
    }

    private var dreamyGlassBubble: some View {
        ZStack {
            Circle()
                .fill(
                    RadialGradient(
                        stops: [
                            .init(color: .white.opacity(0.42), location: 0.00),
                            .init(color: Color(red: 1.00, green: 0.85, blue: 0.77).opacity(0.46), location: 0.22),
                            .init(color: Color(red: 0.96, green: 0.67, blue: 0.52).opacity(0.36), location: 0.58),
                            .init(color: Color(red: 0.90, green: 0.57, blue: 0.44).opacity(0.24), location: 0.86),
                            .init(color: .clear, location: 1.00)
                        ],
                        center: UnitPoint(x: 0.42, y: 0.38),
                        startRadius: 0,
                        endRadius: size * 0.50
                    )
                )

            Circle()
                .fill(
                    LinearGradient(
                        colors: [
                            Color(red: 1.00, green: 0.92, blue: 0.88).opacity(0.22),
                            Color(red: 0.98, green: 0.78, blue: 0.67).opacity(0.18),
                            Color(red: 0.88, green: 0.53, blue: 0.42).opacity(0.12)
                        ],
                        startPoint: .topLeading,
                        endPoint: .bottomTrailing
                    )
                )
                .padding(size * 0.04)

            Circle()
                .stroke(
                    LinearGradient(
                        colors: [
                            .white.opacity(0.58),
                            .white.opacity(0.24),
                            Color(red: 0.95, green: 0.74, blue: 0.65).opacity(0.18)
                        ],
                        startPoint: .topLeading,
                        endPoint: .bottomTrailing
                    ),
                    lineWidth: max(1.0, size * 0.006)
                )
                .padding(size * 0.035)

            Circle()
                .stroke(
                    .white.opacity(0.14),
                    lineWidth: max(0.8, size * 0.0035)
                )
                .padding(size * 0.12)

            Ellipse()
                .fill(
                    LinearGradient(
                        colors: [
                            .white.opacity(0.56),
                            .white.opacity(0.12),
                            .clear
                        ],
                        startPoint: .topLeading,
                        endPoint: .bottomTrailing
                    )
                )
                .frame(
                    width: size * 0.28,
                    height: size * 0.16
                )
                .rotationEffect(.degrees(-28))
                .offset(x: -size * 0.16, y: -size * 0.16)

            Circle()
                .fill(
                    RadialGradient(
                        colors: [
                            .white.opacity(0.46),
                            .clear
                        ],
                        center: .center,
                        startRadius: 0,
                        endRadius: size * 0.12
                    )
                )
                .frame(
                    width: size * 0.18,
                    height: size * 0.18
                )
                .offset(x: -size * 0.14, y: -size * 0.10)
        }
        .frame(width: size, height: size)
        .scaleEffect(1.0 + 0.18 * popProgress)
        .opacity(max(0.0, 1.0 - Double(popProgress)))
    }

    private func popAndOpen() {
        guard !isPopping else { return }

        isPressed = false

        withAnimation(.easeOut(duration: 0.22)) {
            popProgress = 1.0
        }

        Task { @MainActor in
            try? await Task.sleep(nanoseconds: 210_000_000)
            action()

            try? await Task.sleep(nanoseconds: 170_000_000)
            popProgress = 0
        }
    }
}


// MARK: - Exit / Reflection flow — 802:12809 → 802:12910

private enum ReflectionComfortChoice: String, CaseIterable, Identifiable {
    case boracay
    case paris
    case keyring

    var id: String { rawValue }

    var title: String {
        switch self {
        case .boracay:
            return "Our Boracay Holiday"
        case .paris:
            return "Paris with Mum"
        case .keyring:
            return "Jungfrau Keyring"
        }
    }

    var imageCandidates: [String] {
        switch self {
        case .boracay:
            return [
                "Reflection_Boracay",
                "Memory_Boracay",
                "Memory_BoracayHoliday",
                "Boracay"
            ]
        case .paris:
            return [
                "Reflection_Paris",
                "Memory_Paris_Thumbnail",
                "Memory_ParisThumbnail",
                "Paris_Thumbnail",
                "Memory_Paris"
            ]
        case .keyring:
            return [
                "Reflection_Jungfrau",
                "Memory_Swiss_Thumbnail",
                "Memory_SwissThumbnail",
                "Jungfrau_Keyring",
                "Memory_Swiss"
            ]
        }
    }

    var fallbackSymbol: String {
        switch self {
        case .boracay:
            return "photo.fill"
        case .paris:
            return "play.rectangle.fill"
        case .keyring:
            return "key.fill"
        }
    }
}

private enum ReflectionFeelingChoice: String, CaseIterable, Identifiable {
    case struggling
    case better
    case good

    var id: String { rawValue }

    var title: String {
        switch self {
        case .struggling:
            return "Still struggling."
        case .better:
            return "Feeling better."
        case .good:
            return "Feeling good!"
        }
    }

    var assetName: String {
        switch self {
        case .struggling:
            return "Feeling 1"
        case .better:
            return "Feeling 2"
        case .good:
            return "Feeling 3"
        }
    }
}

private struct ReflectionGlassPanel<Content: View>: View {
    let width: CGFloat
    let content: Content

    init(
        width: CGFloat,
        @ViewBuilder content: () -> Content
    ) {
        self.width = width
        self.content = content()
    }

    var body: some View {
        content
            .padding(.vertical, 68)
            .padding(.horizontal, 60)
            .frame(width: width)
            .background {
                RoundedRectangle(cornerRadius: 50, style: .continuous)
                    .fill(
                        Color(
                            red: 243.0 / 255.0,
                            green: 240.0 / 255.0,
                            blue: 237.0 / 255.0
                        )
                        .opacity(0.60)
                    )
                    .overlay {
                        RoundedRectangle(cornerRadius: 50, style: .continuous)
                            .stroke(
                                .white.opacity(0.24),
                                lineWidth: 1
                            )
                    }
            }
    }
}

private struct ReflectionPillButton: View {
    let title: String
    var width: CGFloat? = nil
    var textColor: Color =
        Color(
            red: 122.0 / 255.0,
            green: 115.0 / 255.0,
            blue: 108.0 / 255.0
        )
    var fillColor: Color =
        Color(
            red: 243.0 / 255.0,
            green: 240.0 / 255.0,
            blue: 237.0 / 255.0
        )
    let action: () -> Void

    @State private var isPressed = false

    var body: some View {
        Button(action: action) {
            Text(title)
                .font(.system(size: 24, weight: .bold))
                .foregroundStyle(textColor)
                .padding(.horizontal, 30)
                .frame(width: width)
                .frame(minHeight: 64)
                .background {
                    Capsule()
                        .fill(fillColor)
                }
                .scaleEffect(isPressed ? 0.97 : 1.0)
        }
        .buttonStyle(.plain)
        .hoverEffectDisabled()
        .simultaneousGesture(
            DragGesture(minimumDistance: 0)
                .onChanged { _ in
                    withAnimation(.easeOut(duration: 0.08)) {
                        isPressed = true
                    }
                }
                .onEnded { _ in
                    withAnimation(.easeOut(duration: 0.12)) {
                        isPressed = false
                    }
                }
        )
    }
}

private struct ExitPromptView: View {
    let onReflect: () -> Void
    let onExitNow: () -> Void

    var body: some View {
        ReflectionGlassPanel(width: 720) {
            VStack(
                alignment: .leading,
                spacing: 60
            ) {
                VStack(
                    alignment: .leading,
                    spacing: 20
                ) {
                    Text("Ready to leave?")
                        .font(
                            .system(
                                size: 50,
                                weight: .bold,
                                design: .serif
                            )
                        )
                        .foregroundStyle(.black)

                    Text(
                        "Save a short reflection before you finish,\n"
                        + "or leave without saving."
                    )
                    .font(
                        .system(
                            size: 24,
                            weight: .medium
                        )
                        .italic()
                    )
                    .foregroundStyle(
                        Color(
                            red: 122.0 / 255.0,
                            green: 115.0 / 255.0,
                            blue: 108.0 / 255.0
                        )
                    )
                    .lineSpacing(6)
                }

                HStack(spacing: 12) {
                    ReflectionPillButton(
                        title: "Reflect",
                        textColor:
                            Color(
                                red: 122.0 / 255.0,
                                green: 115.0 / 255.0,
                                blue: 108.0 / 255.0
                            ),
                        fillColor:
                            Color(
                                red: 243.0 / 255.0,
                                green: 240.0 / 255.0,
                                blue: 237.0 / 255.0
                            ),
                        action: onReflect
                    )

                    ReflectionPillButton(
                        title: "Exit now",
                        textColor: .black,
                        fillColor: .white.opacity(0.20),
                        action: onExitNow
                    )
                }
                .frame(maxWidth: .infinity)
            }
        }
    }
}

private struct ReflectionComfortThumbnail: View {
    let choice: ReflectionComfortChoice

    var body: some View {
        ZStack {
            content

            LinearGradient(
                colors: [
                    .clear,
                    .black.opacity(0.52)
                ],
                startPoint: .center,
                endPoint: .bottom
            )
            .allowsHitTesting(false)

            VStack {
                Spacer()

                Text(choice.title)
                    .font(.system(size: 14, weight: .bold))
                    .foregroundStyle(.white)
                    .lineLimit(1)
                    .minimumScaleFactor(0.72)
                    .multilineTextAlignment(.center)
                    .frame(maxWidth: 238)
                    .padding(.horizontal, 10)
                    .padding(.bottom, 12)
            }
            .allowsHitTesting(false)
        }
        .frame(width: 270, height: 200)
        .clipShape(
            RoundedRectangle(
                cornerRadius: 17,
                style: .continuous
            )
        )
    }

    @ViewBuilder
    private var content: some View {
        switch choice {
        case .boracay:
            if let assetName =
                HeavenIsleContent.boracay.assetName {
                Image(assetName)
                    .resizable()
                    .scaledToFill()
                    .frame(width: 270, height: 200)
                    .clipped()
            } else {
                Color.white.opacity(0.90)
            }

        case .paris:
            MemoryVideoThumbnail(
                memory: HeavenIsleContent.paris,
                maximumSize:
                    CGSize(
                        width: 900,
                        height: 675
                    )
            )
            .frame(width: 270, height: 200)
            .clipped()

        case .keyring:
            ZStack {
                Color.white.opacity(0.96)


                Image("Reflection_Jungfrau")
                    .resizable()
                    .scaledToFit()
                    .frame(
                        width: 214,
                        height: 142
                    )
                    .allowsHitTesting(false)
            }
            .frame(width: 270, height: 200)
            .clipShape(
                RoundedRectangle(
                    cornerRadius: 17,
                    style: .continuous
                )
            )
        }
    }
}

private struct ReflectionComfortCard: View {
    let choice: ReflectionComfortChoice
    let isSelected: Bool
    let action: () -> Void

    @State private var isPressed = false

    private let cardWidth: CGFloat = 270
    private let cardHeight: CGFloat = 200

    var body: some View {
        Button(action: action) {
            ReflectionComfortThumbnail(choice: choice)
                .frame(
                    width: cardWidth,
                    height: cardHeight
                )
                .background {
                    RoundedRectangle(
                        cornerRadius: 20,
                        style: .continuous
                    )
                    .fill(
                        isSelected
                            ? Color(
                                red: 243.0 / 255.0,
                                green: 240.0 / 255.0,
                                blue: 237.0 / 255.0
                            )
                            .opacity(0.24)
                            : .clear
                    )
                }
                .overlay {
                    RoundedRectangle(
                        cornerRadius: 20,
                        style: .continuous
                    )
                    .strokeBorder(
                        isSelected
                            ? Color(
                                red: 232.0 / 255.0,
                                green: 149.0 / 255.0,
                                blue: 106.0 / 255.0
                            )
                            : .clear,
                        lineWidth: 5
                    )
                }
                .contentShape(
                    RoundedRectangle(
                        cornerRadius: 20,
                        style: .continuous
                    )
                )
                .clipShape(
                    RoundedRectangle(
                        cornerRadius: 20,
                        style: .continuous
                    )
                )
                .scaleEffect(isPressed ? 0.97 : 1.0)
        }
        .buttonStyle(.plain)
        .hoverEffectDisabled()

        .frame(
            width: cardWidth,
            height: cardHeight
        )
        .simultaneousGesture(
            DragGesture(minimumDistance: 0)
                .onChanged { _ in
                    withAnimation(.easeOut(duration: 0.08)) {
                        isPressed = true
                    }
                }
                .onEnded { _ in
                    withAnimation(.easeOut(duration: 0.12)) {
                        isPressed = false
                    }
                }
        )
    }
}

private struct ReflectionComfortView: View {
    let selected: ReflectionComfortChoice?
    let onSelect: (ReflectionComfortChoice) -> Void
    let onNext: () -> Void

    var body: some View {
        ReflectionGlassPanel(width: 1115) {
            VStack(spacing: 60) {
                Text("What brought you comfort today?")
                    .font(
                        .system(
                            size: 50,
                            weight: .bold,
                            design: .serif
                        )
                    )
                    .foregroundStyle(.black)
                    .frame(
                        maxWidth: .infinity,
                        alignment: .leading
                    )

                HStack(spacing: 24) {
                    ForEach(ReflectionComfortChoice.allCases) { choice in
                        ReflectionComfortCard(
                            choice: choice,
                            isSelected: selected == choice
                        ) {
                            onSelect(choice)
                        }
                    }
                }
                .frame(
                    maxWidth: .infinity,
                    alignment: .center
                )

                if selected != nil {
                    ReflectionPillButton(
                        title: "Next",
                        width: 300,
                        action: onNext
                    )
                    .transition(
                        .opacity
                            .combined(
                                with: .move(edge: .bottom)
                            )
                    )
                }
            }
            .animation(
                .easeInOut(duration: 0.22),
                value: selected
            )
        }
    }
}

private struct ReflectionFeelingMoodCard: View {
    let choice: ReflectionFeelingChoice
    let showSelectedState: Bool
    let action: () -> Void

    @State private var isPressed = false

    private let cardWidth: CGFloat = 234
    private let cardHeight: CGFloat = 267
    private let iconSize: CGFloat = 125

    var body: some View {
        Button(action: action) {
            VStack(spacing: 25) {
                feelingIcon
                    .frame(
                        width: iconSize,
                        height: iconSize
                    )

                Text(choice.title)
                    .font(
                        .system(
                            size: 20,
                            weight: .bold,
                            design: .serif
                        )
                    )
                    .foregroundStyle(.black)
                    .multilineTextAlignment(.center)
                    .lineLimit(1)
                    .minimumScaleFactor(0.82)
            }
            .frame(
                width: cardWidth,
                height: cardHeight
            )
            .background {
                RoundedRectangle(
                    cornerRadius: 50,
                    style: .continuous
                )
                .fill(
                    showSelectedState
                        ? .white.opacity(0.40)
                        : .clear
                )
            }
            .overlay {
                RoundedRectangle(
                    cornerRadius: 50,
                    style: .continuous
                )
                .strokeBorder(
                    showSelectedState
                        ? Color(
                            red: 232.0 / 255.0,
                            green: 149.0 / 255.0,
                            blue: 106.0 / 255.0
                        )
                        : .clear,
                    lineWidth: 5
                )
            }
            .contentShape(
                RoundedRectangle(
                    cornerRadius: 50,
                    style: .continuous
                )
            )
            .scaleEffect(isPressed ? 0.97 : 1.0)
        }
        .buttonStyle(.plain)
        .hoverEffectDisabled()
        .simultaneousGesture(
            DragGesture(minimumDistance: 0)
                .onChanged { _ in
                    withAnimation(.easeOut(duration: 0.08)) {
                        isPressed = true
                    }
                }
                .onEnded { _ in
                    withAnimation(.easeOut(duration: 0.12)) {
                        isPressed = false
                    }
                }
        )
    }

    @ViewBuilder
    private var feelingIcon: some View {

        switch choice {
        case .struggling:
            Image("Feeling 1")
                .renderingMode(.original)
                .resizable()
                .scaledToFit()

        case .better:
            Image("Feeling 2")
                .renderingMode(.original)
                .resizable()
                .scaledToFit()

        case .good:
            Image("Feeling 3")
                .renderingMode(.original)
                .resizable()
                .scaledToFit()
        }
    }
}

private struct ReflectionFeelingView: View {
    let selected: ReflectionFeelingChoice?
    let onChoose: (ReflectionFeelingChoice) -> Void
    let onNext: () -> Void

    private var hasSelection: Bool {
        selected != nil
    }

    var body: some View {
        ReflectionGlassPanel(width: 950) {
            VStack(
                alignment: .leading,
                spacing: 60
            ) {
                VStack(
                    alignment: .leading,
                    spacing: 20
                ) {
                    Text("How do you feel now?")
                        .font(
                            .system(
                                size: 50,
                                weight: .bold,
                                design: .serif
                            )
                        )
                        .foregroundStyle(.black)

                    Text(
                        "Take a moment before you leave.\n"
                        + "Choose what feels closest."
                    )
                    .font(
                        .system(
                            size: 24,
                            weight: .medium
                        )
                        .italic()
                    )
                    .foregroundStyle(
                        Color(
                            red: 122.0 / 255.0,
                            green: 115.0 / 255.0,
                            blue: 108.0 / 255.0
                        )
                    )
                    .lineSpacing(6)
                }
                .frame(
                    maxWidth: .infinity,
                    alignment: .leading
                )

                HStack(spacing: 60) {
                    ForEach(
                        ReflectionFeelingChoice.allCases
                    ) { choice in
                        ReflectionFeelingMoodCard(
                            choice: choice,

                            showSelectedState:
                                selected == choice
                        ) {
                            onChoose(choice)
                        }
                    }
                }
                .frame(
                    maxWidth: .infinity,
                    alignment: .center
                )

                if hasSelection {
                    ReflectionPillButton(
                        title: "Next",
                        width: 200,
                        textColor:
                            Color(
                                red: 122.0 / 255.0,
                                green: 115.0 / 255.0,
                                blue: 108.0 / 255.0
                            ),
                        fillColor:
                            Color(
                                red: 243.0 / 255.0,
                                green: 240.0 / 255.0,
                                blue: 237.0 / 255.0
                            ),
                        action: onNext
                    )
                    .frame(
                        maxWidth: .infinity,
                        alignment: .center
                    )
                    .transition(
                        .opacity
                            .combined(
                                with: .move(edge: .bottom)
                            )
                    )
                }
            }
            .animation(
                .easeInOut(duration: 0.22),
                value: hasSelection
            )
        }
        .onAppear {
            print("✅ REFLECTION FEELING V24 — SVG CARDS LOADED")
        }
    }
}

private struct VoiceReflectionRecordingVisual: View {
    let isRecording: Bool

    private let barBaseHeights: [CGFloat] = [
        22, 36, 52, 31, 62, 43, 27, 48, 34
    ]

    var body: some View {
        TimelineView(
            .animation(
                minimumInterval: 1.0 / 18.0
            )
        ) { timeline in
            let time =
                timeline.date
                    .timeIntervalSinceReferenceDate

            let pulse =
                isRecording
                ? (
                    0.5
                    + 0.5
                    * sin(time * 2.4)
                )
                : 0.0

            VStack(spacing: 24) {
                ZStack {

                    Circle()
                        .stroke(
                            Color(
                                red: 232.0 / 255.0,
                                green: 149.0 / 255.0,
                                blue: 106.0 / 255.0
                            )
                            .opacity(
                                isRecording
                                ? 0.18 + 0.12 * pulse
                                : 0.10
                            ),
                            lineWidth: 3
                        )
                        .frame(width: 214, height: 214)
                        .scaleEffect(
                            isRecording
                            ? 0.96 + 0.08 * pulse
                            : 0.96
                        )

                    Circle()
                        .fill(
                            RadialGradient(
                                colors: [
                                    .white.opacity(0.94),
                                    Color(
                                        red: 232.0 / 255.0,
                                        green: 149.0 / 255.0,
                                        blue: 106.0 / 255.0
                                    )
                                    .opacity(
                                        isRecording
                                        ? 0.24 + 0.10 * pulse
                                        : 0.18
                                    ),
                                    .clear
                                ],
                                center: .center,
                                startRadius: 8,
                                endRadius: 100
                            )
                        )
                        .frame(width: 200, height: 200)
                        .scaleEffect(
                            isRecording
                            ? 0.99 + 0.025 * pulse
                            : 1.0
                        )

                    Image(
                        systemName:
                            isRecording
                            ? "mic.fill"
                            : "pause.fill"
                    )
                    .font(
                        .system(
                            size: 64,
                            weight: .medium
                        )
                    )
                    .foregroundStyle(.white)
                }

                // Small live waveform. It freezes automatically while paused.
                HStack(
                    alignment: .center,
                    spacing: 7
                ) {
                    ForEach(
                        Array(
                            barBaseHeights.enumerated()
                        ),
                        id: \.offset
                    ) { index, baseHeight in
                        let wave =
                            isRecording
                            ? (
                                0.42
                                + 0.58
                                * abs(
                                    sin(
                                        time * 3.0
                                        + Double(index) * 0.78
                                    )
                                )
                            )
                            : 0.48

                        Capsule()
                            .fill(.white.opacity(0.88))
                            .frame(
                                width: 5,
                                height:
                                    max(
                                        10,
                                        baseHeight * wave
                                    )
                            )
                    }
                }
                .frame(height: 68)
            }
        }
    }
}

private struct ReflectionVoiceView: View {
    let isActive: Bool
    let onSave: () -> Void

    @State private var elapsedSeconds = 0
    @State private var isRecording = true

    private var timerText: String {
        String(
            format: "%02d:%02d",
            elapsedSeconds / 60,
            elapsedSeconds % 60
        )
    }

    var body: some View {
        ReflectionGlassPanel(width: 720) {
            VStack(
                alignment: .leading,
                spacing: 60
            ) {
                VStack(
                    alignment: .leading,
                    spacing: 20
                ) {
                    Text("Add a voice reflection")
                        .font(
                            .system(
                                size: 50,
                                weight: .bold,
                                design: .serif
                            )
                        )
                        .foregroundStyle(.black)

                    Text(
                        "Take a moment to share whatever is on your mind. "
                        + "You can revisit your reflection and explore suggested "
                        + "activities later in the Isle app."
                    )
                    .font(
                        .system(
                            size: 24,
                            weight: .medium
                        )
                        .italic()
                    )
                    .foregroundStyle(
                        Color(
                            red: 122.0 / 255.0,
                            green: 115.0 / 255.0,
                            blue: 108.0 / 255.0
                        )
                    )
                    .lineSpacing(6)
                }

                VStack(spacing: 26) {
                    Button {
                        isRecording.toggle()
                    } label: {
                        VoiceReflectionRecordingVisual(
                            isRecording: isRecording
                        )
                    }
                    .buttonStyle(.plain)
                    .hoverEffectDisabled()

                    Text(
                        isRecording
                            ? "Recording · \(timerText)"
                            : "Paused · \(timerText)"
                    )
                    .font(
                        .system(
                            size: 24,
                            weight: .bold
                        )
                    )
                    .foregroundStyle(.white)

                    ReflectionPillButton(
                        title: "Save",
                        width: 200,
                        action: onSave
                    )
                }
                .frame(maxWidth: .infinity)
            }
        }
        .task(id: isActive) {
            guard isActive else {
                return
            }

            elapsedSeconds = 0
            isRecording = true

            while !Task.isCancelled
                    && isActive {
                try? await Task.sleep(
                    for: .seconds(1)
                )

                guard !Task.isCancelled,
                      isActive
                else {
                    return
                }

                if isRecording {
                    elapsedSeconds += 1
                }
            }
        }
    }
}

private struct ReflectionSavedView: View {
    let onFinish: () -> Void

    var body: some View {
        ReflectionGlassPanel(width: 720) {
            VStack(
                alignment: .leading,
                spacing: 60
            ) {
                VStack(
                    alignment: .leading,
                    spacing: 30
                ) {
                    ZStack {
                        Circle()
                            .fill(
                                Color(
                                    red: 243.0 / 255.0,
                                    green: 240.0 / 255.0,
                                    blue: 237.0 / 255.0
                                )
                            )
                            .frame(width: 90, height: 90)

                        Image(systemName: "checkmark")
                            .font(
                                .system(
                                    size: 42,
                                    weight: .medium
                                )
                            )
                            .foregroundStyle(
                                Color(
                                    red: 122.0 / 255.0,
                                    green: 115.0 / 255.0,
                                    blue: 108.0 / 255.0
                                )
                            )
                    }

                    VStack(
                        alignment: .leading,
                        spacing: 20
                    ) {
                        Text("Reflection saved")
                            .font(
                                .system(
                                    size: 50,
                                    weight: .bold,
                                    design: .serif
                                )
                            )
                            .foregroundStyle(.black)

                        Text(
                            "You can revisit it later in your mobile Journal."
                        )
                        .font(
                            .system(
                                size: 24,
                                weight: .medium
                            )
                            .italic()
                        )
                        .foregroundStyle(
                            Color(
                                red: 122.0 / 255.0,
                                green: 115.0 / 255.0,
                                blue: 108.0 / 255.0
                            )
                        )
                    }
                }

                ReflectionPillButton(
                    title: "Finish Session",
                    action: onFinish
                )
                .frame(maxWidth: .infinity)
            }
        }
    }
}

private struct SessionEndView: View {
    let isActive: Bool
    let onComplete: () -> Void

    var body: some View {
        Text("See you later")
            .font(
                .system(
                    size: 120,
                    weight: .heavy,
                    design: .serif
                )
            )
            .foregroundStyle(.white)
            .multilineTextAlignment(.center)
            .shadow(
                color: .black.opacity(0.18),
                radius: 18
            )
            .frame(
                width: 1200,
                height: 240
            )
            .task(id: isActive) {
                
                guard isActive else {
                    return
                }

                try? await Task.sleep(
                    for: .milliseconds(1600)
                )

                guard !Task.isCancelled,
                      isActive
                else {
                    return
                }

                onComplete()
            }
    }
}

@MainActor
struct ImmersiveView: View {
    @Environment(\.dismissImmersiveSpace)
    private var dismissImmersiveSpace

    @State private var experienceStage:
        ImmersiveExperienceStage = .tutorial
    @State private var showsEntranceMessage = false
    @State private var selectedMemory: HeavenMemoryItem?
    @State private var selectedVoice: VoiceMemoryItem?
    @State private var highlightedMemoryID: Int?
    @State private var isRandomMode = false
    @State private var randomMemoryIDs: [Int] = []
    @State private var selectedNoteAssetName: String?
    @State private var objectYaw: Float = 0
    @State private var objectPitch: Float = 0
    @State private var objectDragPreviousTranslation = CGSize.zero
    @State private var cinemaVideoPlayback =
        CinemaVideoPlaybackStore()


    @State private var tutorialShowsBackButton = false
    @State private var tutorialBackRequest = 0

    // Exit / reflection flow
    @State private var exitReturnStage:
        ImmersiveExperienceStage = .heavenIsle
    @State private var selectedReflectionComfort:
        ReflectionComfortChoice?
    @State private var selectedReflectionFeeling:
        ReflectionFeelingChoice?

    // MARK: Attachment IDs

    private let tutorialAttachmentID = "tutorial"
    private let entranceTitleAttachmentID = "entrance-title"
    private let settingsAttachmentID = "settings"
    private let exitAttachmentID = "exit"
    private let surpriseAttachmentID = "surprise"
    private let boracayAttachmentID = "memory-boracay"
    private let recentFamilyAttachmentID = "memory-recent-family"
    private let childhoodAttachmentID = "memory-childhood-island"
    private let parisAttachmentID = "memory-paris"
    private let swissAttachmentID = "memory-swiss"
    private let parentsAttachmentID = "memory-parents"
    private let portalAttachmentID = "voice-isle-portal"

    private let randomSlot0AttachmentID = "random-memory-slot-0"
    private let randomSlot1AttachmentID = "random-memory-slot-1"
    private let randomSlot2AttachmentID = "random-memory-slot-2"
    private let randomSlot3AttachmentID = "random-memory-slot-3"
    private let randomSlot4AttachmentID = "random-memory-slot-4"
    private let randomSlot5AttachmentID = "random-memory-slot-5"

    private let voiceTitleAttachmentID = "voice-isle-title"
    private let voiceSongAttachmentID = "voice-isle-song"
    private let voiceDadAttachmentID = "voice-isle-dad"
    private let voicePromiseAttachmentID = "voice-isle-promise"
    private let voiceBirthdayAttachmentID = "voice-isle-birthday"
    private let voiceStoryAttachmentID = "voice-isle-story"
    private let voiceModeAttachmentID = "voice-isle-normal-mode"
    private let heavenPortalAttachmentID = "voice-isle-heaven-portal"
    private let voiceDetailAttachmentID = "voice-detail"

    private let exitPromptAttachmentID = "exit-prompt"
    private let reflectionComfortAttachmentID = "reflection-comfort"
    private let reflectionFeelingAttachmentID = "reflection-feeling"
    private let reflectionVoiceAttachmentID = "reflection-voice"
    private let reflectionSavedAttachmentID = "reflection-saved"
    private let sessionEndAttachmentID = "session-end"

    private let photoDetailAttachmentID = "photo-detail"
    private let photoCinemaAttachmentID = "photo-cinema"
    private let parisVideoDetailAttachmentID = "video-detail-paris"
    private let parentsVideoDetailAttachmentID = "video-detail-parents"
    private let parisVideoCinemaAttachmentID = "video-cinema-paris"
    private let parentsVideoCinemaAttachmentID = "video-cinema-parents"
    private let objectDetailAttachmentID = "object-detail"
    private let objectExpandedAttachmentID = "object-expanded"
    private let noteDetailAttachmentID = "note-detail"
    private let backAttachmentID = "detail-back"

    private let interfaceAnchorName = "isle-interface-anchor"

    private let boracayIslandName = "island-boracay"
    private let familyIslandName = "island-family"
    private let childhoodIslandName = "island-childhood"
    private let parisIslandName = "island-paris"
    private let swissIslandName = "island-swiss"
    private let parentsIslandName = "island-parents"
    private let swissObjectEntityName = "swiss-object-entity"
    private let swissObjectFrontLightName = "swiss-object-front-light"
    private let swissObjectLeftLightName = "swiss-object-left-light"
    private let swissObjectRightLightName = "swiss-object-right-light"
    private let scenicSkyEntityName = "isle-scenic-sky"
    private let voiceSkyEntityName = "isle-voice-sky"
    private let cinemaSkyEntityName = "isle-cinema-black-sky"
    private let videoCinemaEntityName = "isle-video-cinema-player"


    private let paperEntityPrefix = "paper-memory-"

    // MARK: - Real 3D button depth bodies

    private let settingsDepthEntityName = "control-depth-settings"
    private let exitDepthEntityName = "control-depth-exit"
    private let surpriseDepthEntityName = "control-depth-surprise"
    private let backDepthEntityName = "control-depth-back"
    
    private let mainControlDepth: Float = 0.0062
    private let mainControlCornerRadius: Float = 0.026

    private let settingsDepthSize =
        SIMD3<Float>(0.150, 0.064, 0.0062)

    private let exitDepthSize =
        SIMD3<Float>(0.187, 0.064, 0.0062)

    private let surpriseDepthSize =
        SIMD3<Float>(0.200, 0.064, 0.0062)


    private let backControlCornerRadius: Float = 0.026
    private let backDepthSize =
        SIMD3<Float>(0.145, 0.070, 0.009)


    private let paperNoteAssets: [Int: String] = [
        1: "Note (1)",
        2: "Note (2)",
        3: "Note (3)",
        4: "Note (4)",
        5: "Note (5)",
        6: "Note (6)"
    ]

    // MARK: Island sizing

    private let swissIslandWidth: Float = 0.51
    private let boracayIslandWidth: Float = 0.95
    private let childhoodIslandWidth: Float = 0.61
    private let parisIslandWidth: Float = 1.10
    private let familyIslandWidth: Float = 1.26
    private let parentsIslandWidth: Float = 0.56

    private let boracayReferenceCardScale: Float = 0.88
    private let boracayReferenceSurfaceY: Float = 0.132

    // MARK: Stable positions

    private let tutorialPosition = SIMD3<Float>(0, 0.02, -1.10)
    private let entranceTitlePosition = SIMD3<Float>(0.00, 0.00, -0.91)

    private let settingsPosition = SIMD3<Float>(-0.803, 0.420, -0.92)
    private let exitPosition = SIMD3<Float>(0.785, 0.420, -0.92)
    private let surprisePosition = SIMD3<Float>(-0.780, -0.420, -0.92)
    private let backPosition = SIMD3<Float>(0.785, 0.420, -0.92)

    private let memoryLocalX: Float = 0.000
    private let memoryLocalZ: Float = -0.028
    private let swissPosition = SIMD3<Float>(0.000, 0.064, 0.000)

    // Heaven Isle → Voice Isle portal.
    private let portalPosition = SIMD3<Float>(0.00, -0.39, -1.05)

    // Voice Isle — 802:12686
    // Five voice memories follow the 1920×1080 composition.
    private let voiceTitlePosition =
        SIMD3<Float>(0.00, 0.03, -0.96)

    // Left-mid: x 289 / y 238
    private let voiceSongPosition =
        SIMD3<Float>(-0.58, 0.20, -1.10)

    // Upper-centre: x 786 / y 40
    private let voiceDadPosition =
        SIMD3<Float>(-0.05, 0.36, -1.18)

    // Upper-right: x 1431 / y 256
    private let voicePromisePosition =
        SIMD3<Float>(0.54, 0.21, -1.08)

    // Lower-right
    private let voiceBirthdayPosition =
        SIMD3<Float>(0.37, -0.32, -1.05)

    // Lower-left
    private let voiceStoryPosition =
        SIMD3<Float>(-0.36, -0.25, -1.05)

    private let voiceModePosition =
        SIMD3<Float>(-0.780, -0.420, -0.92)

    private let voiceDetailPosition =
        SIMD3<Float>(0.00, -0.01, -1.18)
    private let heavenPortalPosition = SIMD3<Float>(0.00, -0.39, -1.05)

    // Reflection panels sit over the preserved sky/background only.
    // All Heaven/Voice Isle objects are hidden during the exit flow.
    private let reflectionPosition =
        SIMD3<Float>(0.00, 0.00, -1.08)
    private let sessionEndPosition =
        SIMD3<Float>(0.00, 0.00, -1.10)

    private let reflectionPanelScale: Float = 1.00

    private let detailPosition = SIMD3<Float>(0, 0.00, -1.30)
    private let noteDetailPosition = SIMD3<Float>(0, -0.02, -1.42)
    private let objectDetailPosition = SIMD3<Float>(0, -0.02, -1.42)
    private let cinemaPosition = SIMD3<Float>(0, 0.00, -1.40)
    private let objectExpandedPosition = SIMD3<Float>(0, 0.00, -0.92)

    // MARK: Floating paper layout


    // 790:18683 — individual paper sizes, preserving the different
    // visual hierarchy from the 1920 × 1080 composition.
    private let paperTargetSizes: [Float] = [
        0.38, // paper 1 — slightly larger to feel fuller
        0.66, // paper 2 — reduced
        0.56, // paper 3
        0.54, // paper 4
        0.46, // paper 5
        0.44  // paper 6
    ]

    // 790:18683 positions mapped from the 1920 × 1080 frame into
    // the same head-relative space already used by settings / Exit / Surprise.
    private let paperPositions: [SIMD3<Float>] = [
        SIMD3<Float>(-0.234, -0.080, -0.97), // paper 1 — slightly higher
        SIMD3<Float>(-0.377,  0.315, -1.00), // paper 2
        SIMD3<Float>(-0.680, -0.212, -0.99), // paper 3
        SIMD3<Float>( 0.463,  0.315, -1.02), // paper 4
        SIMD3<Float>( 0.320,  0.052, -1.00), // paper 5
        SIMD3<Float>( 0.725, -0.096, -1.01)  // paper 6
    ]

    // Calm bobbing only: roughly 2–2.8 cm TOTAL vertical travel.
    private let paperFloatAmplitudes: [Float] = [
        0.010, 0.014, 0.011, 0.012, 0.010, 0.011
    ]

    // Duration for ONE direction. Full cycles are deliberately slow (~6–7 s).
    private let paperFloatDurations: [TimeInterval] = [
        3.2, 3.5, 3.3, 3.6, 3.4, 3.5
    ]

    var body: some View {
        RealityView { content, attachments in
            let interfaceAnchor = AnchorEntity(
                .head,
                trackingMode: .once
            )
            interfaceAnchor.name = interfaceAnchorName
            content.add(interfaceAnchor)

            await addSky(to: content)
            await addVoiceSky(to: content)
            addSceneLights(to: content)
            addObjectLight(to: interfaceAnchor)
            addFixedControlDepthBodies(to: interfaceAnchor)

            await addMemoryIslands(to: interfaceAnchor)
            await addSwissObject(to: interfaceAnchor)
            await addFloatingPapers(to: interfaceAnchor)
            applyAttachmentLayout(
                content: content,
                attachments: attachments
            )
        } update: { content, attachments in
            applyAttachmentLayout(
                content: content,
                attachments: attachments
            )
        } attachments: {
            tutorialAttachment
            entranceTitleAttachment
            fixedControlAttachments
            floatingMemoryAttachments
            randomModeAttachments
            portalAttachment
            voiceIsleAttachments
            reflectionAttachments
            detailAttachments
        }
        .gesture(
            TapGesture()
                .targetedToAnyEntity()
                .onEnded { value in
                    handleRealityEntityTap(value.entity)
                }
        )
    }

    // MARK: Scene

    private func addSky(
        to content: RealityViewContent
    ) async {
        var material = UnlitMaterial()

        do {
            let texture = try await TextureResource(named: "sky")
            material.color = .init(
                tint: .white,
                texture: .init(texture)
            )
            print("✅ sky texture loaded")
        } catch {
            material.color = .init(tint: .red)
            print("❌ sky texture failed:", error)
        }

        let skySphere = ModelEntity(
            mesh: .generateSphere(radius: 20),
            materials: [material]
        )
        skySphere.name = scenicSkyEntityName
        skySphere.scale = SIMD3<Float>(-1, 1, 1)
        skySphere.position = .zero
        skySphere.orientation = simd_quatf(
            angle: .pi,
            axis: SIMD3<Float>(0, 1, 0)
        )
        content.add(skySphere)

        var cinemaMaterial = UnlitMaterial()
        cinemaMaterial.color = .init(tint: .black)

        let cinemaSphere = ModelEntity(
            mesh: .generateSphere(radius: 19.5),
            materials: [cinemaMaterial]
        )
        cinemaSphere.name = cinemaSkyEntityName
        cinemaSphere.scale = SIMD3<Float>(-1, 1, 1)
        cinemaSphere.position = .zero
        cinemaSphere.isEnabled = false
        content.add(cinemaSphere)
    }

    private func addVoiceSky(
        to content: RealityViewContent
    ) async {
        var material = UnlitMaterial()

        do {
            let texture: TextureResource

            do {
                // Asset Catalog image set name.
                texture = try await TextureResource(named: "island")
            } catch {
                // Raw bundled resource fallback.
                texture = try await TextureResource(named: "island.jpg")
            }

            // subtle ~20% black overlay.
            material.color = .init(
                tint: UIColor(white: 0.80, alpha: 1.0),
                texture: .init(texture)
            )
            print("✅ Voice Isle 360 texture loaded: island.jpg")
        } catch {
            material.color = .init(
                tint: UIColor(red: 0.12, green: 0.36, blue: 0.52, alpha: 1)
            )
            print("❌ Voice Isle island.jpg failed:", error)
        }

        let sphere = ModelEntity(
            mesh: .generateSphere(radius: 19.8),
            materials: [material]
        )
        sphere.name = voiceSkyEntityName
        sphere.scale = SIMD3<Float>(-1, 1, 1)
        sphere.position = .zero
        sphere.orientation = simd_quatf(
            angle: -.pi / 2,
            axis: SIMD3<Float>(0, 1, 0)
        )
        sphere.isEnabled = false
        content.add(sphere)
    }

    private func addSceneLights(
        to content: RealityViewContent
    ) {
        let keyLight = DirectionalLight()
        keyLight.name = "isle-key-light"
        keyLight.light.color = .white
        keyLight.light.intensity = 9_000
        keyLight.look(
            at: SIMD3<Float>(0, 1.45, -1.20),
            from: SIMD3<Float>(-1.2, 2.4, -0.15),
            relativeTo: nil
        )
        content.add(keyLight)

        let fillLight = PointLight()
        fillLight.name = "isle-fill-light"
        fillLight.light.color = .white
        fillLight.light.intensity = 4_500
        fillLight.light.attenuationRadius = 4
        fillLight.position = SIMD3<Float>(0.35, 1.65, -0.35)
        content.add(fillLight)
    }

    private func addObjectLight(
        to parent: Entity
    ) {
        // Three soft fills around the viewer-facing side of the keyring.
        // This keeps the USDZ readable while the user rotates it.

        let front = PointLight()
        front.name = swissObjectFrontLightName
        front.light.color = .white
        front.light.intensity = 38_000
        front.light.attenuationRadius = 3.0
        front.position = SIMD3<Float>(0.00, 0.20, -0.42)
        front.isEnabled = false
        parent.addChild(front)

        let left = PointLight()
        left.name = swissObjectLeftLightName
        left.light.color = .white
        left.light.intensity = 25_000
        left.light.attenuationRadius = 3.0
        left.position = SIMD3<Float>(-0.65, 0.15, -0.58)
        left.isEnabled = false
        parent.addChild(left)

        let right = PointLight()
        right.name = swissObjectRightLightName
        right.light.color = .white
        right.light.intensity = 25_000
        right.light.attenuationRadius = 3.0
        right.position = SIMD3<Float>(0.65, 0.15, -0.58)
        right.isEnabled = false
        parent.addChild(right)
    }

    // MARK: - Fixed control 3D depth

    private func addFixedControlDepthBodies(
        to parent: Entity
    ) {
        addFixedControlDepthBody(
            name: settingsDepthEntityName,
            frontPosition: settingsPosition,
            size: settingsDepthSize,
            cornerRadius: mainControlCornerRadius,
            isMainControl: true,
            to: parent
        )

        addFixedControlDepthBody(
            name: exitDepthEntityName,
            frontPosition: exitPosition,
            size: exitDepthSize,
            cornerRadius: mainControlCornerRadius,
            isMainControl: true,
            to: parent
        )

        addFixedControlDepthBody(
            name: surpriseDepthEntityName,
            frontPosition: surprisePosition,
            size: surpriseDepthSize,
            cornerRadius: mainControlCornerRadius,
            isMainControl: true,
            to: parent
        )

        addFixedControlDepthBody(
            name: backDepthEntityName,
            frontPosition: backPosition,
            size: backDepthSize,
            cornerRadius: backControlCornerRadius,
            isMainControl: false,
            to: parent
        )
    }

    private func addFixedControlDepthBody(
        name: String,
        frontPosition: SIMD3<Float>,
        size: SIMD3<Float>,
        cornerRadius: Float,
        isMainControl: Bool,
        to parent: Entity
    ) {
        // IMPORTANT — REAL VISIBLE ROUNDING
        //
        // generateBox(... cornerRadius:, splitFaces:) clamps cornerRadius
        // to half of the SMALLEST dimension. Because this button is only
        // ~5.5 mm deep, a 21–25 mm front-face radius was being clamped to
        // ~2.75 mm and therefore looked square.
        //
        // This overload separates:
        // - majorCornerRadius = visible XY/front-face rounding
        // - minorCornerRadius = small rounding through the thin Z depth
        let mesh = MeshResource.generateBox(
            size: size,
            majorCornerRadius: cornerRadius,
            minorCornerRadius: min(size.z * 0.48, 0.0026)
        )

        // GLASS MATERIAL
        // The dual-radius mesh uses one material so the large front-face
        // rounding can remain independent from the very thin depth.
        //
        // MAIN controls:
        //   opacity 0.075 = clearer / lighter
        //   opacity 0.10  = more visible
        //
        // Back keeps a slightly denser material for now.

        func glassMaterial(
            tint: UIColor,
            opacity: Float,
            roughness: Float
        ) -> PhysicallyBasedMaterial {
            var material = PhysicallyBasedMaterial()

            material.baseColor = .init(
                tint: tint
            )
            material.roughness = .init(
                floatLiteral: roughness
            )
            material.metallic = .init(
                floatLiteral: 0.0
            )
            material.blending = .transparent(
                opacity: .init(
                    floatLiteral: opacity
                )
            )

            return material
        }

        let glass = glassMaterial(
            tint: UIColor(
                red: 0.86,
                green: 0.83,
                blue: 0.79,
                alpha: 1.0
            ),
            opacity: isMainControl ? 0.075 : 0.11,
            roughness: 0.07
        )

        let body = ModelEntity(
            mesh: mesh,
            materials: [glass]
        )

        body.name = name

        // The attachment itself sits at frontPosition.
        // Move the cuboid backward so its +Z/front face is just behind
        // the SwiftUI button face, leaving visible physical thickness.
        body.position = SIMD3<Float>(
            frontPosition.x,
            frontPosition.y,
            frontPosition.z - (size.z / 2) - 0.0005
        )

        body.isEnabled = false
        parent.addChild(body)
    }

    private func addMemoryIslands(
        to parent: Entity
    ) async {
        do {
            let islandTemplate = try await Entity(named: "Island")

            // F718:17038 screen-space composition.
            //
            // X/Y positions are mapped from the 1920×1080 frame.


            // Recent Family — hero island, upper centre.
            addIslandClone(
                from: islandTemplate,
                name: familyIslandName,
                position: SIMD3<Float>(0.022, 0.267, -1.10),
                targetWidth: familyIslandWidth,
                yaw: -0.04,
                to: parent
            )

            // Boracay — medium, left-middle.
            addIslandClone(
                from: islandTemplate,
                name: boracayIslandName,
                position: SIMD3<Float>(-0.656, 0.025, -1.11),
                targetWidth: boracayIslandWidth,
                yaw: 0.08,
                to: parent
            )

            // Childhood — small, lower-left.
            addIslandClone(
                from: islandTemplate,
                name: childhoodIslandName,
                position: SIMD3<Float>(-0.426, -0.341, -1.16),
                targetWidth: childhoodIslandWidth,
                yaw: -0.08,
                to: parent
            )

            // Paris — second-largest, lower-right.
            addIslandClone(
                from: islandTemplate,
                name: parisIslandName,
                position: SIMD3<Float>(0.524, -0.312, -1.11),
                targetWidth: parisIslandWidth,
                yaw: 0.07,
                to: parent
            )

            // Parents — smallest, upper-right.
            addIslandClone(
                from: islandTemplate,
                name: parentsIslandName,
                position: SIMD3<Float>(0.666, 0.127, -1.18),
                targetWidth: parentsIslandWidth,
                yaw: 0.10,
                to: parent
            )

            // Keep it as a quiet secondary memory in the open centre-lower area.
            addIslandClone(
                from: islandTemplate,
                name: swissIslandName,
                position: SIMD3<Float>(0.030, -0.080, -1.20),
                targetWidth: swissIslandWidth,
                yaw: 0.00,
                to: parent
            )

            print("✅ Heaven Isle islands: 718:17038 layout")
        } catch {
            print(
                "❌ Island template failed:",
                error.localizedDescription
            )
        }
    }

    private func addIslandClone(
        from template: Entity,
        name: String,
        position: SIMD3<Float>,
        targetWidth: Float,
        yaw: Float,
        to parent: Entity
    ) {
        let model = template.clone(recursive: true)

        let bounds = model.visualBounds(relativeTo: model)
        let horizontalExtent = max(
            bounds.extents.x,
            bounds.extents.z
        )

        let modelPivot = Entity()
        modelPivot.name = islandVisualName(name)
        model.position = -bounds.center

        if horizontalExtent > 0.0001 {
            modelPivot.scale = SIMD3<Float>(
                repeating: targetWidth / horizontalExtent
            )
        }

        modelPivot.orientation =
            simd_quatf(
                angle: 0.46,
                axis: SIMD3<Float>(1, 0, 0)
            )
            * simd_quatf(
                angle: yaw,
                axis: SIMD3<Float>(0, 1, 0)
            )

        modelPivot.addChild(model)

        let cluster = Entity()
        cluster.name = name
        cluster.position = position
        cluster.isEnabled = false
        cluster.addChild(modelPivot)

        parent.addChild(cluster)
    }

    private func addSwissObject(
        to parent: Entity
    ) async {
        do {
            let model = try await Entity(named: "Memory_Swiss")
            let bounds = model.visualBounds(relativeTo: model)
            let largestExtent = max(
                bounds.extents.x,
                bounds.extents.y,
                bounds.extents.z
            )

            let pivot = Entity()
            model.position = -bounds.center

            if largestExtent > 0.0001 {
                pivot.scale = SIMD3<Float>(
                    repeating: 0.58 / largestExtent
                )
            }

            pivot.addChild(model)

            let container = Entity()
            container.name = swissObjectEntityName
            container.isEnabled = false
            container.addChild(pivot)
            parent.addChild(container)
        } catch {
            print("❌ Memory_Swiss.usdz failed:", error)
        }
    }

    // MARK: Floating paper memories

    private func addFloatingPapers(
        to parent: Entity
    ) async {
        for index in 1...6 {
            await addFloatingPaper(
                index: index,
                to: parent
            )
        }
    }

    private func addFloatingPaper(
        index: Int,
        to parent: Entity
    ) async {
        // Use the SAME RealityKit loading pattern as Island.usdz.
        // Try the exact lowercase name first, then common case variants.
        let candidates = [
            "paper \(index)",
            "Paper \(index)",
            "paper\(index)",
            "Paper\(index)"
        ]

        var loadedModel: Entity?
        var loadedName: String?

        for candidate in candidates {
            do {
                loadedModel = try await Entity(named: candidate)
                loadedName = candidate
                break
            } catch {
                continue
            }
        }

        guard let model = loadedModel else {
            print(
                "❌ PAPER LOAD FAILED — tried:",
                candidates.joined(separator: ", ")
            )
            return
        }

        let bounds = model.visualBounds(relativeTo: model)
        let largestExtent = max(
            bounds.extents.x,
            bounds.extents.y,
            bounds.extents.z
        )

        // Same pivot/normalisation pattern used by the working Island loader.
        let modelPivot = Entity()
        model.position = -bounds.center

        if largestExtent > 0.0001 {
            modelPivot.scale = SIMD3<Float>(
                repeating:
                    paperTargetSizes[index - 1]
                    / largestExtent
            )
        }

        modelPivot.addChild(model)

        // paper 2 asset arrives flipped/backward, so pitch it forward 90°.
        if index == 2 {
            modelPivot.orientation = simd_quatf(
                angle: .pi / 2,
                axis: SIMD3<Float>(1, 0, 0)
            )
        }

        let container = Entity()
        container.name = paperEntityName(index)
        container.position = paperPositions[index - 1]
        container.isEnabled = false
        container.addChild(modelPivot)

        // Make the whole paper selectable.
        let interactiveBounds = container.visualBounds(
            recursive: true,
            relativeTo: container,
            excludeInactive: false
        )

        let collisionSize = SIMD3<Float>(
            max(interactiveBounds.extents.x + 0.03, 0.08),
            max(interactiveBounds.extents.y + 0.03, 0.08),
            max(interactiveBounds.extents.z + 0.03, 0.05)
        )

        container.components.set(InputTargetComponent())
        container.components.set(
            CollisionComponent(
                shapes: [
                    ShapeResource.generateBox(size: collisionSize)
                ]
            )
        )

        parent.addChild(container)

        startPaperFloatAnimation(
            on: container,
            index: index
        )

        print(
            "✅ PAPER LOADED:",
            loadedName ?? "unknown",
            "| bounds:",
            bounds.extents,
            "| position:",
            paperPositions[index - 1]
        )
    }

    private func startPaperFloatAnimation(
        on entity: Entity,
        index: Int
    ) {
        let amplitude = paperFloatAmplitudes[index - 1]
        let duration = paperFloatDurations[index - 1]

        var topTransform = entity.transform
        topTransform.translation.y += amplitude

        var bottomTransform = entity.transform
        bottomTransform.translation.y -= amplitude

        // Start at one end of the tiny range. The entity is hidden during the
        // tutorial, so the loop is already underway when Heaven Isle appears.
        entity.transform = topTransform

        var downAnimation = FromToByAnimation<Transform>()
        downAnimation.name = "paper-float-down-\(index)"
        downAnimation.fromValue = topTransform
        downAnimation.toValue = bottomTransform
        downAnimation.duration = duration
        downAnimation.timing = .easeInOut
        downAnimation.bindTarget = .transform

        var upAnimation = FromToByAnimation<Transform>()
        upAnimation.name = "paper-float-up-\(index)"
        upAnimation.fromValue = bottomTransform
        upAnimation.toValue = topTransform
        upAnimation.duration = duration
        upAnimation.timing = .easeInOut
        upAnimation.bindTarget = .transform

        do {
            let downResource = try AnimationResource.generate(
                with: downAnimation
            )
            let upResource = try AnimationResource.generate(
                with: upAnimation
            )

            // One complete cycle ends at the exact transform it started from.
            // Repeating the sequence therefore has no reset or sudden drop.
            let cycle = try AnimationResource.sequence(
                with: [
                    downResource,
                    upResource
                ]
            )

            entity.playAnimation(
                cycle.repeat()
            )
        } catch {
            print(
                "❌ Paper float animation failed for paper \(index):",
                error.localizedDescription
            )
        }
    }

    private func paperEntityName(
        _ index: Int
    ) -> String {
        paperEntityPrefix + String(index)
    }

    private func paperIndex(
        from entity: Entity
    ) -> Int? {
        var current: Entity? = entity

        while let candidate = current {
            if candidate.name.hasPrefix(paperEntityPrefix) {
                let suffix = candidate.name.dropFirst(
                    paperEntityPrefix.count
                )
                return Int(suffix)
            }

            current = candidate.parent
        }

        return nil
    }

    // MARK: Attachments

    @AttachmentContentBuilder
    private var tutorialAttachment: some AttachmentContent {
        Attachment(id: tutorialAttachmentID) {
            TutorialFlowView(
                onTutorialFinished: {
                    print("✅ Enter Heaven Isle tapped")
                    enterHeavenIsle(showCatchMessage: true)
                },
                onStartExploring: {
                    print("✅ Start Exploring tapped")
                    enterHeavenIsle(showCatchMessage: true)
                },
                externalBackRequest: tutorialBackRequest,
                onBackVisibilityChanged: { isVisible in
                    tutorialShowsBackButton = isVisible
                }
            )
        }
    }

    @AttachmentContentBuilder
    private var entranceTitleAttachment: some AttachmentContent {
        Attachment(id: entranceTitleAttachmentID) {
            MemoryCatchTitleView()
        }
    }

    @AttachmentContentBuilder
    private var fixedControlAttachments: some AttachmentContent {
        Attachment(id: settingsAttachmentID) {
            HeavenMainControlButton(
                assetName: "Icon_Setting",
                title: "settings"
            ) {
                print("settings selected")
            }
        }

        Attachment(id: exitAttachmentID) {
            HeavenMainControlButton(
                assetName: "Icon_Exit",
                title: "Exit Island"
            ) {
                openExitPrompt()
            }
        }

        Attachment(id: surpriseAttachmentID) {
            HeavenMainControlButton(
                assetName: isRandomMode ? "Icon_Normal" : "Icon_Surprise",
                title: isRandomMode ? "Normal Mode" : "Surprise Me!"
            ) {
                toggleRandomMode()
            }
        }

        Attachment(id: backAttachmentID) {
            HeavenFixedControlButton(
                assetName: "Icon_Back",
                title: "Back"
            ) {
                if experienceStage == .tutorial {
                    tutorialBackRequest += 1
                } else {
                    goBack()
                }
            }
        }
    }

    @AttachmentContentBuilder
    private var floatingMemoryAttachments: some AttachmentContent {
        Attachment(id: boracayAttachmentID) {
            HeavenFloatingMemoryCard(
                memory: HeavenIsleContent.boracay,
                isHighlighted:
                    highlightedMemoryID == HeavenIsleContent.boracay.id,
                animationDelay: 0.00
            ) {
                selectMemory(HeavenIsleContent.boracay)
            }
            .allowsHitTesting(
                experienceStage == .heavenIsle
            )
        }

        Attachment(id: recentFamilyAttachmentID) {
            HeavenFloatingMemoryCard(
                memory: HeavenIsleContent.recentFamily,
                isHighlighted:
                    highlightedMemoryID == HeavenIsleContent.recentFamily.id,
                animationDelay: 0.30
            ) {
                selectMemory(HeavenIsleContent.recentFamily)
            }
            .allowsHitTesting(
                experienceStage == .heavenIsle
            )
        }

        Attachment(id: childhoodAttachmentID) {
            HeavenFloatingMemoryCard(
                memory: HeavenIsleContent.childhoodIsland,
                isHighlighted:
                    highlightedMemoryID == HeavenIsleContent.childhoodIsland.id,
                animationDelay: 0.60
            ) {
                selectMemory(HeavenIsleContent.childhoodIsland)
            }
            .allowsHitTesting(
                experienceStage == .heavenIsle
            )
        }

        Attachment(id: parisAttachmentID) {
            HeavenFloatingVideoMemory(
                memory: HeavenIsleContent.paris,
                animationDelay: 0.15
            ) {
                selectMemory(HeavenIsleContent.paris)
            }
            .allowsHitTesting(
                experienceStage == .heavenIsle
            )
        }

        Attachment(id: swissAttachmentID) {
            HeavenFloatingObjectMemory(
                memory: HeavenIsleContent.jungfrauKeyring,
                animationDelay: 0.45
            ) {
                selectMemory(HeavenIsleContent.jungfrauKeyring)
            }
            .allowsHitTesting(
                experienceStage == .heavenIsle
            )
        }

        Attachment(id: parentsAttachmentID) {
            HeavenFloatingVideoMemory(
                memory: HeavenIsleContent.parentsPortrait,
                animationDelay: 0.75
            ) {
                selectMemory(HeavenIsleContent.parentsPortrait)
            }
            .allowsHitTesting(
                experienceStage == .heavenIsle
            )
        }
    }

    @AttachmentContentBuilder
    private var randomModeAttachments: some AttachmentContent {
        Attachment(id: randomSlot0AttachmentID) {
            randomSlotView(0)
        }

        Attachment(id: randomSlot1AttachmentID) {
            randomSlotView(1)
        }

        Attachment(id: randomSlot2AttachmentID) {
            randomSlotView(2)
        }

        Attachment(id: randomSlot3AttachmentID) {
            randomSlotView(3)
        }

        Attachment(id: randomSlot4AttachmentID) {
            randomSlotView(4)
        }

        Attachment(id: randomSlot5AttachmentID) {
            randomSlotView(5)
        }
    }

    @ViewBuilder
    private func randomSlotView(
        _ slot: Int
    ) -> some View {
        if isRandomMode,
           randomMemory(for: slot) != nil {

            HeavenSurpriseBubbleButton(
                size: randomBubbleSize(for: slot)
            ) {
                openRandomSlot(slot)
            }
            .transition(
                .opacity
                    .combined(
                        with: .scale(scale: 0.90)
                    )
            )
        } else {
            Color.clear
                .frame(width: 1, height: 1)
        }
    }

    @AttachmentContentBuilder
    private var portalAttachment: some AttachmentContent {
        Attachment(id: portalAttachmentID) {
            VoiceIslePortalView {
                enterVoiceIsle()
            }
            .allowsHitTesting(
                experienceStage == .heavenIsle
            )
        }
    }

    @AttachmentContentBuilder
    private var voiceIsleAttachments:
        some AttachmentContent {

        Attachment(
            id: voiceTitleAttachmentID
        ) {
            VoiceIsleTitleView()
        }

        Attachment(
            id: voiceSongAttachmentID
        ) {
            VoiceIsleOrbButton(
                memory:
                    VoiceIsleContent.song
            ) {
                selectVoice(
                    VoiceIsleContent.song
                )
            }
            .allowsHitTesting(
                experienceStage == .voiceIsle
            )
        }

        Attachment(
            id: voiceDadAttachmentID
        ) {
            VoiceIsleOrbButton(
                memory:
                    VoiceIsleContent.dad
            ) {
                selectVoice(
                    VoiceIsleContent.dad
                )
            }
            .allowsHitTesting(
                experienceStage == .voiceIsle
            )
        }

        Attachment(
            id: voicePromiseAttachmentID
        ) {
            VoiceIsleOrbButton(
                memory:
                    VoiceIsleContent.promise
            ) {
                selectVoice(
                    VoiceIsleContent.promise
                )
            }
            .allowsHitTesting(
                experienceStage == .voiceIsle
            )
        }

        Attachment(
            id: voiceBirthdayAttachmentID
        ) {
            VoiceIsleOrbButton(
                memory:
                    VoiceIsleContent.birthday
            ) {
                selectVoice(
                    VoiceIsleContent.birthday
                )
            }
            .allowsHitTesting(
                experienceStage == .voiceIsle
            )
        }

        Attachment(
            id: voiceStoryAttachmentID
        ) {
            VoiceIsleOrbButton(
                memory:
                    VoiceIsleContent.story
            ) {
                selectVoice(
                    VoiceIsleContent.story
                )
            }
            .allowsHitTesting(
                experienceStage == .voiceIsle
            )
        }

        Attachment(
            id: voiceModeAttachmentID
        ) {
            HeavenFixedControlButton(
                assetName: "Icon_Normal",
                title: "Normal Mode"
            ) {
                voiceNormalMode()
            }
        }

        Attachment(
            id: heavenPortalAttachmentID
        ) {
            VoiceIsleHeavenPortalButton {
                returnToHeavenIsle()
            }
            .allowsHitTesting(
                experienceStage == .voiceIsle
            )
        }
    }

    @AttachmentContentBuilder
    private var reflectionAttachments: some AttachmentContent {
        Attachment(
            id: exitPromptAttachmentID
        ) {
            ExitPromptView(
                onReflect: {
                    beginReflection()
                },
                onExitNow: {
                    finishWithoutReflection()
                }
            )
        }

        Attachment(
            id: reflectionComfortAttachmentID
        ) {
            ReflectionComfortView(
                selected: selectedReflectionComfort,
                onSelect: { choice in
                    selectReflectionComfort(choice)
                },
                onNext: {
                    advanceFromComfort()
                }
            )
        }

        Attachment(
            id: reflectionFeelingAttachmentID
        ) {
            ReflectionFeelingView(
                selected: selectedReflectionFeeling,
                onChoose: { choice in
                    selectReflectionFeeling(choice)
                },
                onNext: {
                    advanceFromFeeling()
                }
            )
        }

        Attachment(
            id: reflectionVoiceAttachmentID
        ) {
            ReflectionVoiceView(
                isActive:
                    experienceStage == .reflectionVoice,
                onSave: {
                    saveReflection()
                }
            )
        }

        Attachment(
            id: reflectionSavedAttachmentID
        ) {
            ReflectionSavedView {
                finishReflectionSession()
            }
        }

        Attachment(
            id: sessionEndAttachmentID
        ) {
            SessionEndView(
                isActive:
                    experienceStage == .sessionEnd
            ) {
                Task { @MainActor in
                    await dismissImmersiveSpace()
                }
            }
        }
    }

    @AttachmentContentBuilder
    private var detailAttachments: some AttachmentContent {

        Attachment(
            id: voiceDetailAttachmentID
        ) {
            VoiceMemoryDetailView(
                memory:
                    selectedVoice
                    ?? VoiceIsleContent.dad,
                isActive:
                    experienceStage
                    == .voiceDetail
            )
        }
        Attachment(id: photoDetailAttachmentID) {
            PhotoMemoryDetailView(
                memory: selectedMemory ?? HeavenIsleContent.boracay
            ) {
                withAnimation(.easeInOut(duration: 0.35)) {
                    experienceStage = .photoCinema
                }
            }
        }

        Attachment(id: photoCinemaAttachmentID) {
            PhotoMemoryCinemaView(
                memory: selectedMemory ?? HeavenIsleContent.boracay
            )
        }

        Attachment(id: parisVideoDetailAttachmentID) {
            VideoMemoryDetailView(
                memory: HeavenIsleContent.paris
            ) {
                // Re-assert the exact memory immediately before cinema.
                selectedMemory = HeavenIsleContent.paris
                print("🎯 CINEMA REQUEST: Memory_Paris")

                withAnimation(.easeInOut(duration: 0.35)) {
                    experienceStage = .videoCinema
                }
            }
        }

        Attachment(id: parentsVideoDetailAttachmentID) {
            VideoMemoryDetailView(
                memory: HeavenIsleContent.parentsPortrait
            ) {
                // Re-assert the exact memory immediately before cinema.
                selectedMemory = HeavenIsleContent.parentsPortrait
                print("🎯 CINEMA REQUEST: Memory_Photostudio")

                withAnimation(.easeInOut(duration: 0.35)) {
                    experienceStage = .videoCinema
                }
            }
        }

        Attachment(id: parisVideoCinemaAttachmentID) {
            VideoMemoryCinemaView(
                memory: HeavenIsleContent.paris,
                isActive:
                    experienceStage == .videoCinema
                    && selectedMemory?.id == HeavenIsleContent.paris.id
            )
        }

        Attachment(id: parentsVideoCinemaAttachmentID) {
            VideoMemoryCinemaView(
                memory: HeavenIsleContent.parentsPortrait,
                isActive:
                    experienceStage == .videoCinema
                    && selectedMemory?.id
                        == HeavenIsleContent.parentsPortrait.id
            )
        }

        Attachment(id: objectDetailAttachmentID) {
            ObjectMemoryDetailView(
                memory: selectedMemory ?? HeavenIsleContent.jungfrauKeyring
            ) {
                withAnimation(.easeInOut(duration: 0.35)) {
                    experienceStage = .objectExpanded
                }
            }
        }

        Attachment(id: objectExpandedAttachmentID) {
            Rectangle()
                // Keep the rotation hit area around the object only,
                // so the fixed Back button remains clickable.
                .fill(.white.opacity(0.001))
                .frame(width: 1180, height: 820)
                .contentShape(Rectangle())
                .gesture(
                    DragGesture(minimumDistance: 0)
                        .onChanged { value in
                            let delta = CGSize(
                                width:
                                    value.translation.width
                                    - objectDragPreviousTranslation.width,
                                height:
                                    value.translation.height
                                    - objectDragPreviousTranslation.height
                            )

                            objectDragPreviousTranslation =
                                value.translation

                            rotateExpandedObject(by: delta)
                        }
                        .onEnded { _ in
                            objectDragPreviousTranslation = .zero
                        }
                )
                .accessibilityLabel("Rotate Jungfrau Keyring")
                .accessibilityHint(
                    "Pinch and drag to rotate the object."
                )
        }


        Attachment(id: noteDetailAttachmentID) {
            PaperNoteDetailView(
                assetName: selectedNoteAssetName ?? "Note (1)"
            )
            .onAppear {
                print(
                    "📝 NOTE DETAIL APPEAR:",
                    selectedNoteAssetName ?? "Note (1)"
                )
            }
        }
    }

    // MARK: Random mode helpers

    private func randomMemory(
        for slot: Int
    ) -> HeavenMemoryItem? {
        guard randomMemoryIDs.indices.contains(slot) else {
            return nil
        }

        let memoryID = randomMemoryIDs[slot]
        return HeavenIsleContent.all.first {
            $0.id == memoryID
        }
    }

    private func randomBubbleSize(
        for slot: Int
    ) -> CGFloat {
        // 718:17098 uses deliberately varied bubble sizes.
        let sizes: [CGFloat] = [
            390, 420, 360, 395, 375, 360
        ]

        guard sizes.indices.contains(slot) else {
            return 380
        }

        return sizes[slot]
    }


    private func randomBubbleScale(
        for slot: Int
    ) -> SIMD3<Float> {
        // Bubble size is already defined in points by randomBubbleSize(for:).
        // Do not enlarge the RealityView attachment again: double-scaling makes
        // the attachment hit planes overlap and one front bubble steals input.
        SIMD3<Float>(repeating: 1.0)
    }


    private func randomSlotScale(
        _ slot: Int
    ) -> SIMD3<Float> {
        randomBubbleScale(for: slot)
    }

    private func islandVisualName(
        _ islandName: String
    ) -> String {
        islandName + "-visual"
    }

    // MARK: Proportional home-memory layout

    private func memorySurfacePosition(
        islandWidth: Float
    ) -> SIMD3<Float> {
        let relativeIslandScale = islandWidth / boracayIslandWidth

        // Scale both Y and Z with island size.
        // This keeps every photo/video planted at the same proportional depth.
        return SIMD3<Float>(
            memoryLocalX,
            boracayReferenceSurfaceY * relativeIslandScale,
            memoryLocalZ * relativeIslandScale
        )
    }

    private func memoryCardScale(
        memory: HeavenMemoryItem,
        islandWidth: Float
    ) -> SIMD3<Float> {
        let relativeIslandScale = islandWidth / boracayIslandWidth
        let sourceWidthCorrection =
            Float(HeavenIsleContent.boracay.width) / Float(memory.width)

        // 718:17038 card/island width ratios:
        // Boracay .517, Family .542, Childhood .526,
        // Paris .486, Parents .469.
        let figmaRatioCorrection: Float
        switch memory.id {
        case HeavenIsleContent.recentFamily.id:
            figmaRatioCorrection = 1.048
        case HeavenIsleContent.childhoodIsland.id:
            figmaRatioCorrection = 1.017
        case HeavenIsleContent.paris.id:
            figmaRatioCorrection = 0.940
        case HeavenIsleContent.parentsPortrait.id:
            figmaRatioCorrection = 0.907
        default:
            figmaRatioCorrection = 1.0
        }

        let scale =
            boracayReferenceCardScale
            * relativeIslandScale
            * sourceWidthCorrection
            * figmaRatioCorrection

        return SIMD3<Float>(repeating: scale)
    }

    // MARK: Layout

    private func applyAttachmentLayout(
        content: RealityViewContent,
        attachments: RealityViewAttachments
    ) {
        let tutorialIsVisible = experienceStage == .tutorial
        let homeIsVisible = experienceStage == .heavenIsle
        let voiceIsVisible = experienceStage == .voiceIsle
        let voiceDetailIsVisible = experienceStage == .voiceDetail
        let photoDetailIsVisible = experienceStage == .photoDetail
        let photoCinemaIsVisible = experienceStage == .photoCinema
        let videoDetailIsVisible = experienceStage == .videoDetail
        let videoCinemaIsVisible = experienceStage == .videoCinema

        let parisVideoDetailIsVisible =
            videoDetailIsVisible
            && selectedMemory?.id == HeavenIsleContent.paris.id

        let parentsVideoDetailIsVisible =
            videoDetailIsVisible
            && selectedMemory?.id == HeavenIsleContent.parentsPortrait.id

        let parisVideoCinemaIsVisible =
            videoCinemaIsVisible
            && selectedMemory?.id == HeavenIsleContent.paris.id

        let parentsVideoCinemaIsVisible =
            videoCinemaIsVisible
            && selectedMemory?.id == HeavenIsleContent.parentsPortrait.id
        let objectDetailIsVisible = experienceStage == .objectDetail
        let objectExpandedIsVisible = experienceStage == .objectExpanded
        let noteDetailIsVisible = experienceStage == .noteDetail

        let exitPromptIsVisible =
            experienceStage == .exitPrompt
        let reflectionComfortIsVisible =
            experienceStage == .reflectionComfort
        let reflectionFeelingIsVisible =
            experienceStage == .reflectionFeeling
        let reflectionVoiceIsVisible =
            experienceStage == .reflectionVoice
        let reflectionSavedIsVisible =
            experienceStage == .reflectionSaved
        let sessionEndIsVisible =
            experienceStage == .sessionEnd

        let reflectionBackgroundIsVisible =
            exitPromptIsVisible
            || reflectionComfortIsVisible
            || reflectionFeelingIsVisible
            || reflectionVoiceIsVisible
            || reflectionSavedIsVisible
            || sessionEndIsVisible

        // Exit / reflection keeps ONLY the sky/background of the isle
        // the user exited from. All memories, titles, portals and island
        // scene objects are hidden; only the reflection panel + Back remain.
        let reflectionUsesVoiceSky =
            reflectionBackgroundIsVisible
            && exitReturnStage == .voiceIsle

        let tutorialBackIsVisible =
            tutorialIsVisible
            && tutorialShowsBackButton

        let backIsVisible =
            tutorialBackIsVisible
            || voiceDetailIsVisible
            || photoDetailIsVisible
            || photoCinemaIsVisible
            || videoDetailIsVisible
            || videoCinemaIsVisible
            || objectDetailIsVisible
            || objectExpandedIsVisible
            || noteDetailIsVisible
            || exitPromptIsVisible
            || reflectionComfortIsVisible
            || reflectionFeelingIsVisible
            || reflectionVoiceIsVisible

        configureAttachment(
            id: tutorialAttachmentID,
            position: tutorialPosition,
            isEnabled: tutorialIsVisible,
            content: content,
            attachments: attachments
        )
        configureAttachment(
            id: entranceTitleAttachmentID,
            position: entranceTitlePosition,
            isEnabled:
                homeIsVisible
                && showsEntranceMessage
                && !isRandomMode,
            content: content,
            attachments: attachments
        )

        configureAttachment(
            id: settingsAttachmentID,
            position: settingsPosition,
            scale: SIMD3<Float>(repeating: 1.00),
            isEnabled: homeIsVisible || voiceIsVisible,
            content: content,
            attachments: attachments
        )
        configureAttachment(
            id: exitAttachmentID,
            position: exitPosition,
            scale: SIMD3<Float>(repeating: 1.00),
            isEnabled: homeIsVisible || voiceIsVisible,
            content: content,
            attachments: attachments
        )
        configureAttachment(
            id: surpriseAttachmentID,
            position: surprisePosition,
            scale: SIMD3<Float>(repeating: 1.00),
            isEnabled: homeIsVisible,
            content: content,
            attachments: attachments
        )
        configureAttachment(
            id: backAttachmentID,
            position: backPosition,
            scale: SIMD3<Float>(repeating: 1.00),
            isEnabled: backIsVisible,
            content: content,
            attachments: attachments
        )

        configureAttachment(
            id: boracayAttachmentID,
            position: memorySurfacePosition(islandWidth: boracayIslandWidth),
            scale: memoryCardScale(memory: HeavenIsleContent.boracay, islandWidth: boracayIslandWidth),
            isEnabled: homeIsVisible && !isRandomMode,
            content: content,
            attachments: attachments,
            parentName: boracayIslandName
        )
        configureAttachment(
            id: recentFamilyAttachmentID,
            position: memorySurfacePosition(islandWidth: familyIslandWidth),
            scale: memoryCardScale(memory: HeavenIsleContent.recentFamily, islandWidth: familyIslandWidth),
            isEnabled: homeIsVisible && !isRandomMode,
            content: content,
            attachments: attachments,
            parentName: familyIslandName
        )
        configureAttachment(
            id: childhoodAttachmentID,
            position: memorySurfacePosition(islandWidth: childhoodIslandWidth),
            scale: memoryCardScale(memory: HeavenIsleContent.childhoodIsland, islandWidth: childhoodIslandWidth),
            isEnabled: homeIsVisible && !isRandomMode,
            content: content,
            attachments: attachments,
            parentName: childhoodIslandName
        )
        configureAttachment(
            id: parisAttachmentID,
            position: memorySurfacePosition(islandWidth: parisIslandWidth),
            scale: memoryCardScale(memory: HeavenIsleContent.paris, islandWidth: parisIslandWidth),
            isEnabled: homeIsVisible && !isRandomMode,
            content: content,
            attachments: attachments,
            parentName: parisIslandName
        )

        configureAttachment(
            id: swissAttachmentID,
            position: swissPosition,
            scale: SIMD3<Float>(repeating: 0.62),
            isEnabled: homeIsVisible && !isRandomMode,
            content: content,
            attachments: attachments,
            parentName: swissIslandName
        )
        configureAttachment(
            id: parentsAttachmentID,
            position: memorySurfacePosition(islandWidth: parentsIslandWidth),
            scale: memoryCardScale(memory: HeavenIsleContent.parentsPortrait, islandWidth: parentsIslandWidth),
            isEnabled: homeIsVisible && !isRandomMode,
            content: content,
            attachments: attachments,
            parentName: parentsIslandName
        )
        // Random mode uses the exact same six memory centres as normal mode.
        configureAttachment(
            id: randomSlot0AttachmentID,
            position: memorySurfacePosition(islandWidth: boracayIslandWidth),
            scale: randomSlotScale(0),
            isEnabled: homeIsVisible && isRandomMode,
            content: content,
            attachments: attachments,
            parentName: boracayIslandName
        )
        configureAttachment(
            id: randomSlot1AttachmentID,
            position: memorySurfacePosition(islandWidth: familyIslandWidth),
            scale: randomSlotScale(1),
            isEnabled: homeIsVisible && isRandomMode,
            content: content,
            attachments: attachments,
            parentName: familyIslandName
        )
        configureAttachment(
            id: randomSlot2AttachmentID,
            position: memorySurfacePosition(islandWidth: childhoodIslandWidth),
            scale: randomSlotScale(2),
            isEnabled: homeIsVisible && isRandomMode,
            content: content,
            attachments: attachments,
            parentName: childhoodIslandName
        )
        configureAttachment(
            id: randomSlot3AttachmentID,
            position: memorySurfacePosition(islandWidth: parisIslandWidth),
            scale: randomSlotScale(3),
            isEnabled: homeIsVisible && isRandomMode,
            content: content,
            attachments: attachments,
            parentName: parisIslandName
        )
        configureAttachment(
            id: randomSlot4AttachmentID,
            position: swissPosition,
            scale: randomSlotScale(4),
            isEnabled: homeIsVisible && isRandomMode,
            content: content,
            attachments: attachments,
            parentName: swissIslandName
        )
        configureAttachment(
            id: randomSlot5AttachmentID,
            position: memorySurfacePosition(islandWidth: parentsIslandWidth),
            scale: randomSlotScale(5),
            isEnabled: homeIsVisible && isRandomMode,
            content: content,
            attachments: attachments,
            parentName: parentsIslandName
        )

        configureAttachment(
            id: portalAttachmentID,
            position: portalPosition,
            scale: SIMD3<Float>(repeating: 0.78),
            isEnabled: homeIsVisible && !isRandomMode,
            content: content,
            attachments: attachments
        )

        configureAttachment(
            id: voiceTitleAttachmentID,
            position: voiceTitlePosition,
            isEnabled: voiceIsVisible,
            content: content,
            attachments: attachments
        )

        configureAttachment(
            id: voiceSongAttachmentID,
            position: voiceSongPosition,
            scale:
                SIMD3<Float>(
                    repeating: 1.00
                ),
            isEnabled: voiceIsVisible,
            content: content,
            attachments: attachments
        )

        configureAttachment(
            id: voiceDadAttachmentID,
            position: voiceDadPosition,
            scale:
                SIMD3<Float>(
                    repeating: 1.00
                ),
            isEnabled: voiceIsVisible,
            content: content,
            attachments: attachments
        )

        configureAttachment(
            id: voicePromiseAttachmentID,
            position: voicePromisePosition,
            scale:
                SIMD3<Float>(
                    repeating: 1.00
                ),
            isEnabled: voiceIsVisible,
            content: content,
            attachments: attachments
        )

        configureAttachment(
            id: voiceBirthdayAttachmentID,
            position: voiceBirthdayPosition,
            scale:
                SIMD3<Float>(
                    repeating: 1.00
                ),
            isEnabled: voiceIsVisible,
            content: content,
            attachments: attachments
        )

        configureAttachment(
            id: voiceStoryAttachmentID,
            position: voiceStoryPosition,
            scale:
                SIMD3<Float>(
                    repeating: 1.00
                ),
            isEnabled: voiceIsVisible,
            content: content,
            attachments: attachments
        )

        configureAttachment(
            id: voiceModeAttachmentID,
            position: voiceModePosition,
            scale:
                SIMD3<Float>(
                    repeating: 1.00
                ),
            isEnabled: false,
            content: content,
            attachments: attachments
        )

        configureAttachment(
            id: heavenPortalAttachmentID,
            position: heavenPortalPosition,
            scale:
                SIMD3<Float>(
                    repeating: 0.78
                ),
            isEnabled: voiceIsVisible,
            content: content,
            attachments: attachments
        )

        configureAttachment(
            id: voiceDetailAttachmentID,
            position: voiceDetailPosition,
            scale:
                SIMD3<Float>(
                    repeating: 1.08
                ),
            isEnabled:
                voiceDetailIsVisible,
            content: content,
            attachments: attachments
        )

        configureAttachment(
            id: photoDetailAttachmentID,
            position: detailPosition,
            isEnabled: photoDetailIsVisible,
            content: content,
            attachments: attachments
        )
        configureAttachment(
            id: photoCinemaAttachmentID,
            position: cinemaPosition,
            isEnabled: photoCinemaIsVisible,
            content: content,
            attachments: attachments
        )
        configureAttachment(
            id: parisVideoDetailAttachmentID,
            position: detailPosition,
            isEnabled: parisVideoDetailIsVisible,
            content: content,
            attachments: attachments
        )
        configureAttachment(
            id: parentsVideoDetailAttachmentID,
            position: detailPosition,
            isEnabled: parentsVideoDetailIsVisible,
            content: content,
            attachments: attachments
        )
        configureAttachment(
            id: parisVideoCinemaAttachmentID,
            position: cinemaPosition,
            isEnabled: parisVideoCinemaIsVisible,
            content: content,
            attachments: attachments
        )
        configureAttachment(
            id: parentsVideoCinemaAttachmentID,
            position: cinemaPosition,
            isEnabled: parentsVideoCinemaIsVisible,
            content: content,
            attachments: attachments
        )
        configureAttachment(
            id: objectDetailAttachmentID,
            position: objectDetailPosition,
            isEnabled: objectDetailIsVisible,
            content: content,
            attachments: attachments
        )
        configureAttachment(
            id: objectExpandedAttachmentID,
            position: objectExpandedPosition,
            isEnabled: objectExpandedIsVisible,
            content: content,
            attachments: attachments
        )
        configureAttachment(
            id: noteDetailAttachmentID,
            position: noteDetailPosition,
            isEnabled: noteDetailIsVisible,
            content: content,
            attachments: attachments
        )

        configureAttachment(
            id: exitPromptAttachmentID,
            position: reflectionPosition,
            scale:
                SIMD3<Float>(
                    repeating: reflectionPanelScale
                ),
            isEnabled: exitPromptIsVisible,
            content: content,
            attachments: attachments
        )
        configureAttachment(
            id: reflectionComfortAttachmentID,
            position: reflectionPosition,
            scale:
                SIMD3<Float>(
                    repeating: reflectionPanelScale
                ),
            isEnabled: reflectionComfortIsVisible,
            content: content,
            attachments: attachments
        )
        configureAttachment(
            id: reflectionFeelingAttachmentID,
            position: reflectionPosition,
            scale:
                SIMD3<Float>(
                    repeating: reflectionPanelScale
                ),
            isEnabled: reflectionFeelingIsVisible,
            content: content,
            attachments: attachments
        )
        configureAttachment(
            id: reflectionVoiceAttachmentID,
            position: reflectionPosition,
            scale:
                SIMD3<Float>(
                    repeating: reflectionPanelScale
                ),
            isEnabled: reflectionVoiceIsVisible,
            content: content,
            attachments: attachments
        )
        configureAttachment(
            id: reflectionSavedAttachmentID,
            position: reflectionPosition,
            scale:
                SIMD3<Float>(
                    repeating: reflectionPanelScale
                ),
            isEnabled: reflectionSavedIsVisible,
            content: content,
            attachments: attachments
        )
        configureAttachment(
            id: sessionEndAttachmentID,
            position: sessionEndPosition,
            scale:
                SIMD3<Float>(
                    repeating: reflectionPanelScale
                ),
            isEnabled: sessionEndIsVisible,
            content: content,
            attachments: attachments
        )

        syncFixedControlDepthBodies(
            settingsVisible: homeIsVisible || voiceIsVisible,
            exitVisible: homeIsVisible || voiceIsVisible,
            surpriseVisible: homeIsVisible,
            backVisible: backIsVisible,
            content: content
        )

        syncMemoryIslands(
            isVisible: homeIsVisible,
            showIslandVisuals:
                homeIsVisible && !isRandomMode,
            content: content
        )

        syncFloatingPapers(
            isVisible:
                homeIsVisible && !isRandomMode,
            content: content
        )

        syncSwissObjectEntity(
            detailIsVisible: objectDetailIsVisible,
            expandedIsVisible: objectExpandedIsVisible,
            content: content
        )

        syncSkyEnvironment(
            voiceIsVisible:
                voiceIsVisible
                || voiceDetailIsVisible
                || reflectionUsesVoiceSky,
            cinemaIsVisible:
                photoCinemaIsVisible
                || videoCinemaIsVisible,
            content: content
        )
    }

    private func syncFixedControlDepthBodies(
        settingsVisible: Bool,
        exitVisible: Bool,
        surpriseVisible: Bool,
        backVisible: Bool,
        content: RealityViewContent
    ) {
        findEntity(
            named: settingsDepthEntityName,
            in: content
        )?.isEnabled = settingsVisible

        findEntity(
            named: exitDepthEntityName,
            in: content
        )?.isEnabled = exitVisible

        findEntity(
            named: surpriseDepthEntityName,
            in: content
        )?.isEnabled = surpriseVisible

        findEntity(
            named: backDepthEntityName,
            in: content
        )?.isEnabled = backVisible
    }

    private func syncMemoryIslands(
        isVisible: Bool,
        showIslandVisuals: Bool,
        content: RealityViewContent
    ) {
        let names = [
            boracayIslandName,
            familyIslandName,
            childhoodIslandName,
            parisIslandName,
            swissIslandName,
            parentsIslandName
        ]

        for name in names {
            guard let cluster = findEntity(
                named: name,
                in: content
            ) else {
                continue
            }

            // Keep the cluster alive in random mode because the random
            // attachments are parented to the same exact spatial anchors.
            cluster.isEnabled = isVisible

            cluster.findEntity(
                named: islandVisualName(name)
            )?.isEnabled = showIslandVisuals
        }
    }

    private func syncFloatingPapers(
        isVisible: Bool,
        content: RealityViewContent
    ) {
        for index in 1...6 {
            findEntity(
                named: paperEntityName(index),
                in: content
            )?.isEnabled = isVisible
        }
    }

    private func syncSkyEnvironment(
        voiceIsVisible: Bool,
        cinemaIsVisible: Bool,
        content: RealityViewContent
    ) {
        findEntity(
            named: scenicSkyEntityName,
            in: content
        )?.isEnabled = !voiceIsVisible && !cinemaIsVisible

        findEntity(
            named: voiceSkyEntityName,
            in: content
        )?.isEnabled = voiceIsVisible && !cinemaIsVisible

        findEntity(
            named: cinemaSkyEntityName,
            in: content
        )?.isEnabled = cinemaIsVisible
    }

    private func syncSwissObjectEntity(
        detailIsVisible: Bool,
        expandedIsVisible: Bool,
        content: RealityViewContent
    ) {
        guard let objectEntity = findEntity(
            named: swissObjectEntityName,
            in: content
        ) else {
            return
        }

        objectEntity.isEnabled = detailIsVisible || expandedIsVisible

        let objectLightsAreVisible =
            detailIsVisible || expandedIsVisible

        findEntity(
            named: swissObjectFrontLightName,
            in: content
        )?.isEnabled = objectLightsAreVisible

        findEntity(
            named: swissObjectLeftLightName,
            in: content
        )?.isEnabled = objectLightsAreVisible

        findEntity(
            named: swissObjectRightLightName,
            in: content
        )?.isEnabled = objectLightsAreVisible

        if expandedIsVisible {
            objectEntity.position = SIMD3<Float>(0, 0.02, -0.96)
            objectEntity.scale = SIMD3<Float>(repeating: 2.75)
            objectEntity.orientation =
                simd_quatf(
                    angle: objectYaw,
                    axis: SIMD3<Float>(0, 1, 0)
                )
                * simd_quatf(
                    angle: objectPitch,
                    axis: SIMD3<Float>(1, 0, 0)
                )
        } else {
            objectEntity.position = SIMD3<Float>(0, 0.10, -1.08)
            objectEntity.scale = SIMD3<Float>(repeating: 1.65)
            objectEntity.orientation = simd_quatf(
                angle: 0,
                axis: SIMD3<Float>(0, 1, 0)
            )
        }
    }

    private func configureAttachment(
        id: String,
        position: SIMD3<Float>,
        scale: SIMD3<Float> = SIMD3<Float>(repeating: 1),
        isEnabled: Bool,
        content: RealityViewContent,
        attachments: RealityViewAttachments,
        parentName: String? = nil
    ) {
        guard let entity = attachments.entity(for: id) else {
            return
        }

        entity.position = position
        entity.scale = scale
        entity.isEnabled = isEnabled

        if let parentName,
           let customParent = findEntity(
                named: parentName,
                in: content
           ) {
            if entity.parent !== customParent {
                customParent.addChild(entity)
            }
            return
        }

        if let interfaceAnchor = findEntity(
            named: interfaceAnchorName,
            in: content
        ) {
            if entity.parent !== interfaceAnchor {
                interfaceAnchor.addChild(entity)
            }
        } else if entity.parent == nil {
            content.add(entity)
        }
    }

    private func findEntity(
        named name: String,
        in content: RealityViewContent
    ) -> Entity? {
        for rootEntity in content.entities {
            if rootEntity.name == name {
                return rootEntity
            }

            if let match = rootEntity.findEntity(named: name) {
                return match
            }
        }

        return nil
    }

    // MARK: Actions

    private func openExitPrompt() {
        guard experienceStage == .heavenIsle
                || experienceStage == .voiceIsle
        else {
            return
        }

        exitReturnStage = experienceStage
        selectedReflectionComfort = nil
        selectedReflectionFeeling = nil

        withAnimation(.easeInOut(duration: 0.30)) {
            experienceStage = .exitPrompt
        }
    }

    private func beginReflection() {
        selectedReflectionComfort = nil
        selectedReflectionFeeling = nil

        // Reflection flow:
        // Comfort → Feeling → Voice Reflection → Saved
        withAnimation(.easeInOut(duration: 0.30)) {
            experienceStage = .reflectionComfort
        }
    }

    private func finishWithoutReflection() {
        Task { @MainActor in
            await dismissImmersiveSpace()
        }
    }

    private func selectReflectionComfort(
        _ choice: ReflectionComfortChoice
    ) {
        withAnimation(.easeInOut(duration: 0.20)) {
            selectedReflectionComfort = choice
        }
    }

    private func advanceFromComfort() {
        guard selectedReflectionComfort != nil else {
            return
        }

        // Next page after "What brought you comfort today?"
        // is "How do you feel now?"
        withAnimation(.easeInOut(duration: 0.30)) {
            experienceStage = .reflectionFeeling
        }
    }

    private func selectReflectionFeeling(
        _ choice: ReflectionFeelingChoice
    ) {
        // interaction:
        // 832:8944 (plain icon choices)
        // → tap any feeling
        // → 836:9322 (all three cards framed + Next appears)
        withAnimation(.easeInOut(duration: 0.22)) {
            selectedReflectionFeeling = choice
        }

        print(
            "✅ FEELING SELECTED → 836:9322:",
            choice.title
        )
    }

    private func advanceFromFeeling() {
        guard selectedReflectionFeeling != nil else {
            return
        }

        // Next page after "How do you feel now?"
        // is Voice Reflection.
        withAnimation(.easeInOut(duration: 0.30)) {
            experienceStage = .reflectionVoice
        }
    }

    private func saveReflection() {
        withAnimation(.easeInOut(duration: 0.30)) {
            experienceStage = .reflectionSaved
        }
    }

    private func finishReflectionSession() {
        // Finish Session closes the immersive experience immediately.
        // No intermediate "See you later" screen.
        Task { @MainActor in
            await dismissImmersiveSpace()
        }
    }

    private func enterHeavenIsle(
        showCatchMessage: Bool
    ) {
        isRandomMode = false
        randomMemoryIDs.removeAll()
        highlightedMemoryID = nil
        selectedMemory = nil
        selectedNoteAssetName = nil

        withAnimation(.easeInOut(duration: 0.40)) {
            experienceStage = .heavenIsle
            showsEntranceMessage = showCatchMessage
        }

        guard showCatchMessage else {
            return
        }

        Task { @MainActor in
            try? await Task.sleep(nanoseconds: 2_200_000_000)

            guard experienceStage == .heavenIsle else {
                return
            }

            withAnimation(.easeOut(duration: 0.40)) {
                showsEntranceMessage = false
            }
        }
    }

    private func enterVoiceIsle() {
        guard experienceStage == .heavenIsle else {
            return
        }

        isRandomMode = false
        randomMemoryIDs.removeAll()
        highlightedMemoryID = nil
        selectedMemory = nil
        selectedVoice = nil
        selectedNoteAssetName = nil

        withAnimation(.easeInOut(duration: 0.35)) {
            experienceStage = .voiceIsle
        }
    }

    private func returnToHeavenIsle() {
        guard experienceStage == .voiceIsle else {
            return
        }

        selectedVoice = nil

        withAnimation(
            .easeInOut(
                duration: 0.35
            )
        ) {
            experienceStage =
                .heavenIsle
        }
    }

    private func voiceNormalMode() {
        print("🎙 Voice Isle Normal Mode")
    }

    private func selectVoice(
        _ voice: VoiceMemoryItem
    ) {
        guard experienceStage == .voiceIsle else {
            return
        }

        selectedVoice = voice

        print(
            "🎙 Voice selected:",
            voice.title,
            "→",
            voice.audioBaseName
        )

        withAnimation(
            .easeInOut(
                duration: 0.35
            )
        ) {
            experienceStage =
                .voiceDetail
        }
    }

    private func handleRealityEntityTap(
        _ entity: Entity
    ) {
        guard experienceStage == .heavenIsle,
              let index = paperIndex(from: entity),
              (1...6).contains(index)
        else {
            return
        }

        selectPaper(index)
    }

    private func selectPaper(
        _ index: Int
    ) {
        guard let noteName = paperNoteAssets[index] else {
            print("❌ No note asset mapped for paper \(index)")
            return
        }

        selectedNoteAssetName = noteName
        highlightedMemoryID = nil
        selectedMemory = nil
        showsEntranceMessage = false

        print(
            "📝 PAPER SELECTED:",
            "paper \(index)",
            "→",
            noteName
        )

        withAnimation(.easeInOut(duration: 0.30)) {
            experienceStage = .noteDetail
        }
    }

    private func selectMemory(
        _ memory: HeavenMemoryItem
    ) {
        guard experienceStage == .heavenIsle else {
            return
        }

        selectedMemory = memory
        highlightedMemoryID = nil

        print(
            "🎯 MEMORY SELECTED:",
            memory.title,
            "| id:",
            memory.id,
            "| asset:",
            memory.assetName ?? "nil"
        )

        if case .object = memory.kind {
            objectYaw = 0
            objectPitch = 0
        }

        withAnimation(.easeInOut(duration: 0.35)) {
            switch memory.kind {
            case .photo:
                experienceStage = .photoDetail
            case .video:
                experienceStage = .videoDetail
            case .object:
                experienceStage = .objectDetail
            }
        }
    }

    private func toggleRandomMode() {
        if isRandomMode {
            leaveRandomMode()
        } else {
            enterRandomMode()
        }
    }

    private func enterRandomMode() {
        let shuffledIDs =
            HeavenIsleContent.all
                .map(\.id)
                .shuffled()

        guard !shuffledIDs.isEmpty else {
            return
        }

        randomMemoryIDs = shuffledIDs
        highlightedMemoryID = nil
        selectedMemory = nil
        showsEntranceMessage = false

        withAnimation(.easeInOut(duration: 0.35)) {
            isRandomMode = true
        }

        print(
            "🎲 RANDOM MODE ON:",
            shuffledIDs
        )
    }

    private func leaveRandomMode() {
        withAnimation(.easeInOut(duration: 0.35)) {
            isRandomMode = false
        }

        randomMemoryIDs.removeAll()
        highlightedMemoryID = nil
        selectedMemory = nil
        showsEntranceMessage = false

        print("🎲 RANDOM MODE OFF — original layout restored")
    }

    private func openRandomSlot(
        _ slot: Int
    ) {
        guard experienceStage == .heavenIsle,
              isRandomMode,
              let memory =
                randomMemory(for: slot)
        else {
            return
        }

        print(
            "🎲 RANDOM BUBBLE OPENED:",
            "slot",
            slot,
            "→",
            memory.title
        )

        // Open the shuffled memory detail immediately.
        // There is no intermediate reveal state.
        selectMemory(memory)
    }

    private func rotateExpandedObject(
        by delta: CGSize
    ) {
        objectYaw += Float(delta.width) * 0.006
        objectPitch -= Float(delta.height) * 0.0045
        // Horizontal yaw is intentionally unlimited for full 360° turns.
        // Vertical tilt is wide but capped to avoid disorienting flips.
        objectPitch = min(max(objectPitch, -1.30), 1.30)
    }

    private func goBack() {
        withAnimation(.easeInOut(duration: 0.35)) {
            switch experienceStage {
            case .voiceDetail:
                experienceStage = .voiceIsle
                selectedVoice = nil

            case .photoCinema:
                experienceStage = .photoDetail
            case .videoCinema:
                experienceStage = .videoDetail
            case .objectExpanded:
                experienceStage = .objectDetail
            case .photoDetail, .videoDetail, .objectDetail, .noteDetail:
                experienceStage = .heavenIsle
                selectedMemory = nil
                selectedNoteAssetName = nil
                highlightedMemoryID = nil
                showsEntranceMessage = false
                objectYaw = 0
                objectPitch = 0
                objectDragPreviousTranslation = .zero

            case .exitPrompt:
                experienceStage = exitReturnStage

            case .reflectionComfort:
                experienceStage = .exitPrompt

            case .reflectionFeeling:
                experienceStage = .reflectionComfort

            case .reflectionVoice:
                experienceStage = .reflectionFeeling

            case .reflectionSaved, .sessionEnd:
                break

            case .tutorial, .heavenIsle, .voiceIsle:
                break
            }
        }
    }
}


// MARK: - Paper note detail

private struct PaperNoteDetailView: View {
    let assetName: String

    private var resolvedImage: UIImage? {
        let number = assetName.filter(\.isNumber)

        let candidates = [
            assetName,
            assetName.replacingOccurrences(of: " ", with: ""),
            assetName.lowercased(),
            assetName.lowercased().replacingOccurrences(of: " ", with: ""),
            "Note (\(number))",
            "Note(\(number))",
            "Note \(number)",
            "Note\(number)",
            "Note_\(number)",
            "Note-\(number)",
            "note (\(number))",
            "note(\(number))",
            "note \(number)",
            "note\(number)",
            "note_\(number)",
            "note-\(number)"
        ]

        for candidate in candidates {
            if let image = UIImage(named: candidate) {
                print("✅ NOTE IMAGE FOUND:", candidate)
                return image
            }
        }

        print(
            "❌ NOTE IMAGE NOT FOUND:",
            assetName,
            "| tried:",
            candidates.joined(separator: ", ")
        )
        return nil
    }

    var body: some View {
        Group {
            if let uiImage = resolvedImage {
                Image(uiImage: uiImage)
                    .resizable()
                    .scaledToFit()
                    .frame(
                        maxWidth: 1180,
                        maxHeight: 800
                    )
            } else {
                VStack(spacing: 18) {
                    Image(systemName: "photo")
                        .font(.system(size: 72))
                        .foregroundStyle(.white.opacity(0.72))

                    Text("Could not load \(assetName)")
                        .font(.system(size: 26, weight: .semibold))
                        .foregroundStyle(.white.opacity(0.88))
                }
            }
        }
        // Intentionally transparent: note image + Back only.
        .frame(width: 1371, height: 850)
        .accessibilityLabel("Memory note")
    }
}
