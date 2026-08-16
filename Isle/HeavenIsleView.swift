import SwiftUI

// MARK: - Memory model

enum HeavenMemoryKind {
    case photo
    case video
    case object
}

struct HeavenMemoryItem: Identifiable {
    let id: Int
    let title: String
    let assetName: String?
    let width: CGFloat
    let height: CGFloat
    let cornerRadius: CGFloat
    let titleSize: CGFloat
    let kind: HeavenMemoryKind
    let description: String

    init(
        id: Int,
        title: String,
        assetName: String?,
        width: CGFloat,
        height: CGFloat,
        cornerRadius: CGFloat,
        titleSize: CGFloat,
        kind: HeavenMemoryKind = .photo,
        description: String = ""
    ) {
        self.id = id
        self.title = title
        self.assetName = assetName
        self.width = width
        self.height = height
        self.cornerRadius = cornerRadius
        self.titleSize = titleSize
        self.kind = kind
        self.description = description
    }
}

// MARK: - Memory contents

enum HeavenIsleContent {

    static let boracay = HeavenMemoryItem(
        id: 1,
        title: "Our Boracay Holiday",
        assetName: "Memory_Boracay",
        width: 276,
        height: 207,
        cornerRadius: 18,
        titleSize: 14.4,
        kind: .photo,
        description:
            """
            We sailed on a yacht, discovered delicious food and spent time on Boracay’s beautiful white-sand beaches. Every day felt special, and I would love for us to return together one day.
            """
    )

    static let recentFamily = HeavenMemoryItem(
        id: 2,
        title: "Recent Family Photo",
        assetName: "Memory_FamilyMeeting",
        width: 308,
        height: 230,
        cornerRadius: 20,
        titleSize: 16,
        kind: .photo,
        description:
            """
            We took this photo at a café shortly before I moved to the UK. Dad later had fun decorating it with AI, which somehow made the memory even more endearing.
            """
    )

    static let childhoodIsland = HeavenMemoryItem(
        id: 3,
        title: "Childhood Island Trip",
        assetName: "Memory_FamilyTrip1",
        width: 260,
        height: 196,
        cornerRadius: 17,
        titleSize: 13.6,
        kind: .photo,
        description:
            """
            I made this photo diary in primary school after taking time away for a family experience trip, then submitted it when I returned. My parents look so young, and our little family looks wonderfully sweet together.
            """
    )

    static let paris = HeavenMemoryItem(
        id: 4,
        title: "Paris with Mum",
        assetName: "Memory_Paris",
        width: 244,
        height: 184,
        cornerRadius: 16,
        titleSize: 12.8,
        kind: .video,
        description:
            """
            Mum and I spent part of the summer together in Paris. It was incredibly hot, but seeing how much she enjoyed the trip made me so happy. Next time, I hope to send Mum and Dad together as my treat. We only recently said goodbye, but I already miss her.
            """
    )

    static let jungfrauKeyring = HeavenMemoryItem(
        id: 6,
        title: "Jungfrau Keyring",
        assetName: "Memory_Swiss",
        width: 270,
        height: 230,
        cornerRadius: 16,
        titleSize: 14,
        kind: .object,
        description:
            """
            Mum and I travelled to Grindelwald, where we saw beautiful waterfalls and made our way up to Jungfraujoch. The landscape was breathtaking, and seeing snow in the middle of summer made the trip feel especially magical. I would love to return one day.
            """
    )

    static let parentsPortrait = HeavenMemoryItem(
        id: 5,
        title: "A Portrait of Mum and Dad",
        assetName: "Memory_Photostudio",
        width: 212,
        height: 161,
        cornerRadius: 14,
        titleSize: 11.2,
        kind: .video,
        description:
            """
            After I started working, I treated Mum and Dad to a professional studio portrait session. It still amazes me how affectionate they are after all these years — they look so lovely together.
            """
    )

    static let all: [HeavenMemoryItem] = [
        boracay,
        recentFamily,
        childhoodIsland,
        paris,
        jungfrauKeyring,
        parentsPortrait
    ]
}

// MARK: - Entrance message

struct MemoryCatchTitleView: View {
    var body: some View {
        VStack(spacing: 19) {
            Text("Memory Catch")
                .font(
                    .system(
                        size: 50,
                        weight: .bold,
                        design: .serif
                    )
                )

            Text("Pinch a memory to revisit a familiar moment.")
                .font(.system(size: 24, weight: .medium))
        }
        .multilineTextAlignment(.center)
        .foregroundStyle(.white)
    }
}

// MARK: - Organic home-memory masks

struct OrganicMemoryShape: Shape {
    let variant: Int

    func path(in rect: CGRect) -> Path {
        let w = rect.width
        let h = rect.height

        func p(_ x: CGFloat, _ y: CGFloat) -> CGPoint {
            CGPoint(x: x * w, y: y * h)
        }

        var path = Path()

        switch abs(variant) % 5 {
        case 0:
            path.move(to: p(0.12, 0.05))
            path.addCurve(
                to: p(0.82, 0.04),
                control1: p(0.34, -0.03),
                control2: p(0.68, -0.01)
            )
            path.addCurve(
                to: p(0.97, 0.42),
                control1: p(0.96, 0.10),
                control2: p(1.01, 0.26)
            )
            path.addCurve(
                to: p(0.84, 0.88),
                control1: p(0.99, 0.65),
                control2: p(0.94, 0.80)
            )
            path.addCurve(
                to: p(0.32, 0.98),
                control1: p(0.66, 1.02),
                control2: p(0.45, 1.02)
            )
            path.addCurve(
                to: p(0.03, 0.68),
                control1: p(0.12, 0.94),
                control2: p(-0.02, 0.83)
            )
            path.addCurve(
                to: p(0.12, 0.05),
                control1: p(-0.01, 0.40),
                control2: p(0.02, 0.18)
            )

        case 1:
            path.move(to: p(0.20, 0.03))
            path.addCurve(
                to: p(0.88, 0.16),
                control1: p(0.46, -0.06),
                control2: p(0.75, 0.02)
            )
            path.addCurve(
                to: p(0.94, 0.72),
                control1: p(1.02, 0.34),
                control2: p(1.00, 0.58)
            )
            path.addCurve(
                to: p(0.55, 0.98),
                control1: p(0.84, 0.92),
                control2: p(0.69, 1.00)
            )
            path.addCurve(
                to: p(0.10, 0.78),
                control1: p(0.33, 1.01),
                control2: p(0.17, 0.92)
            )
            path.addCurve(
                to: p(0.20, 0.03),
                control1: p(-0.02, 0.58),
                control2: p(0.03, 0.20)
            )

        case 2:
            path.move(to: p(0.26, 0.02))
            path.addCurve(
                to: p(0.82, 0.08),
                control1: p(0.47, -0.04),
                control2: p(0.70, 0.00)
            )
            path.addCurve(
                to: p(0.99, 0.50),
                control1: p(0.96, 0.20),
                control2: p(1.02, 0.34)
            )
            path.addCurve(
                to: p(0.76, 0.94),
                control1: p(0.97, 0.72),
                control2: p(0.90, 0.88)
            )
            path.addCurve(
                to: p(0.19, 0.91),
                control1: p(0.56, 1.02),
                control2: p(0.33, 0.99)
            )
            path.addCurve(
                to: p(0.03, 0.42),
                control1: p(0.04, 0.78),
                control2: p(-0.01, 0.58)
            )
            path.addCurve(
                to: p(0.26, 0.02),
                control1: p(0.06, 0.20),
                control2: p(0.13, 0.07)
            )

        case 3:
            path.move(to: p(0.31, 0.02))
            path.addCurve(
                to: p(0.78, 0.05),
                control1: p(0.48, -0.03),
                control2: p(0.66, -0.01)
            )
            path.addCurve(
                to: p(0.96, 0.35),
                control1: p(0.91, 0.11),
                control2: p(0.98, 0.22)
            )
            path.addCurve(
                to: p(0.88, 0.82),
                control1: p(0.99, 0.55),
                control2: p(0.96, 0.72)
            )
            path.addCurve(
                to: p(0.43, 0.99),
                control1: p(0.73, 0.97),
                control2: p(0.57, 1.03)
            )
            path.addCurve(
                to: p(0.08, 0.73),
                control1: p(0.22, 0.98),
                control2: p(0.11, 0.88)
            )
            path.addCurve(
                to: p(0.31, 0.02),
                control1: p(-0.01, 0.48),
                control2: p(0.07, 0.15)
            )

        default:
            path.move(to: p(0.16, 0.08))
            path.addCurve(
                to: p(0.79, 0.02),
                control1: p(0.35, -0.03),
                control2: p(0.65, -0.02)
            )
            path.addCurve(
                to: p(0.98, 0.44),
                control1: p(0.95, 0.12),
                control2: p(1.02, 0.30)
            )
            path.addCurve(
                to: p(0.78, 0.93),
                control1: p(0.98, 0.67),
                control2: p(0.90, 0.84)
            )
            path.addCurve(
                to: p(0.25, 0.95),
                control1: p(0.58, 1.02),
                control2: p(0.39, 1.00)
            )
            path.addCurve(
                to: p(0.02, 0.55),
                control1: p(0.08, 0.88),
                control2: p(-0.02, 0.71)
            )
            path.addCurve(
                to: p(0.16, 0.08),
                control1: p(0.02, 0.31),
                control2: p(0.06, 0.16)
            )
        }

        path.closeSubpath()
        return path
    }
}

// MARK: - Floating photo memory

struct HeavenFloatingMemoryCard: View {
    let memory: HeavenMemoryItem
    let isHighlighted: Bool
    let animationDelay: Double
    let action: () -> Void

    var body: some View {
        Button(action: action) {
            memoryImage
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
                        .white.opacity(
                            isHighlighted ? 0.90 : 0.58
                        ),
                        lineWidth:
                            isHighlighted ? 1.4 : 0.8
                    )
                }
                .overlay {
                    IsleMiniTwinkles(
                        width: memory.width,
                        height: memory.height,
                        isHighlighted: isHighlighted,
                        compact: false
                    )
                }
                .scaleEffect(
                    isHighlighted ? 1.04 : 1.0
                )
        }
        .buttonStyle(.plain)
        .animation(
            .easeInOut(duration: 0.25),
            value: isHighlighted
        )
    }

    @ViewBuilder
    private var memoryImage: some View {
        if let assetName = memory.assetName {
            Image(assetName)
                .resizable()
                .scaledToFill()
                .frame(
                    width: memory.width,
                    height: memory.height
                )
                .clipped()
        } else {
            ZStack {
                Color.white.opacity(0.15)

                Image(systemName: "photo.fill")
                    .font(.system(size: 64))
                    .foregroundStyle(
                        .white.opacity(0.55)
                    )
            }
        }
    }
}


// MARK: - Stable two-star twinkle

struct IsleMiniTwinkles: View {
    let width: CGFloat
    let height: CGFloat
    let isHighlighted: Bool
    let compact: Bool

    @State private var pulseA = false
    @State private var pulseB = false
    @State private var pulseC = false
    @State private var pulseD = false

    private var minSide: CGFloat {
        min(width, height)
    }

    private var majorSize: CGFloat {
        let ratio: CGFloat = compact ? 0.221 : 0.26
        return max(23, minSide * ratio)
    }

    private var mediumSize: CGFloat {
        let ratio: CGFloat = compact ? 0.150 : 0.170
        return max(16, minSide * ratio)
    }

    private var smallSize: CGFloat {
        let ratio: CGFloat = compact ? 0.117 : 0.136
        return max(13, minSide * ratio)
    }

    private var tinySize: CGFloat {
        let ratio: CGFloat = compact ? 0.094 : 0.107
        return max(10, minSide * ratio)
    }

    private var glowBoost: CGFloat {
        isHighlighted ? 1.0 : 0.78
    }

    var body: some View {
        ZStack {
            sparkle(
                assetName: "sparkle-bigstar",
                size: majorSize,
                x: width * (compact ? -0.18 : -0.30),
                y: height * (compact ? -0.17 : -0.28),
                active: pulseA,
                activeOpacity: isHighlighted ? 0.98 : 0.88,
                inactiveOpacity: 0.20,
                activeScale: 1.18,
                inactiveScale: 0.68,
                shadowRadius: 4.8 * glowBoost
            )

            sparkle(
                assetName: "sparkle-bigstar",
                size: mediumSize,
                x: width * (compact ? 0.16 : 0.27),
                y: height * (compact ? -0.13 : -0.22),
                active: pulseB,
                activeOpacity: isHighlighted ? 0.92 : 0.80,
                inactiveOpacity: 0.14,
                activeScale: 1.16,
                inactiveScale: 0.60,
                shadowRadius: 3.8 * glowBoost
            )

            sparkle(
                assetName: "sparkle-star",
                size: smallSize,
                x: width * (compact ? -0.09 : -0.18),
                y: height * (compact ? 0.02 : -0.04),
                active: pulseC,
                activeOpacity: isHighlighted ? 0.84 : 0.72,
                inactiveOpacity: 0.12,
                activeScale: 1.22,
                inactiveScale: 0.58,
                shadowRadius: 3.0 * glowBoost
            )

            sparkle(
                assetName: "sparkle-star",
                size: tinySize,
                x: width * (compact ? 0.07 : 0.16),
                y: height * (compact ? 0.10 : 0.04),
                active: pulseD,
                activeOpacity: isHighlighted ? 0.76 : 0.64,
                inactiveOpacity: 0.10,
                activeScale: 1.18,
                inactiveScale: 0.56,
                shadowRadius: 2.6 * glowBoost
            )
        }
        .frame(
            width: width,
            height: height
        )
        .allowsHitTesting(false)
        .onAppear {
            pulseA = true

            DispatchQueue.main.asyncAfter(deadline: .now() + 0.18) {
                pulseB = true
            }

            DispatchQueue.main.asyncAfter(deadline: .now() + 0.36) {
                pulseC = true
            }

            DispatchQueue.main.asyncAfter(deadline: .now() + 0.54) {
                pulseD = true
            }
        }
    }

    private func sparkle(
        assetName: String,
        size: CGFloat,
        x: CGFloat,
        y: CGFloat,
        active: Bool,
        activeOpacity: Double,
        inactiveOpacity: Double,
        activeScale: CGFloat,
        inactiveScale: CGFloat,
        shadowRadius: CGFloat
    ) -> some View {
        Image(assetName)
            .resizable()
            .scaledToFit()
            .frame(width: size, height: size)
            .opacity(active ? activeOpacity : inactiveOpacity)
            .scaleEffect(active ? activeScale : inactiveScale)
            .shadow(
                color: .white.opacity(isHighlighted ? 0.40 : 0.26),
                radius: shadowRadius
            )
            .offset(x: x, y: y)
            .animation(
                .easeInOut(duration: 1.35 + Double(size.truncatingRemainder(dividingBy: 7)) * 0.08)
                    .repeatForever(autoreverses: true),
                value: active
            )
    }
}


// MARK: - Voice Isle portal

enum IslePortalStyle {
    case voice
    case heaven

    var outerGlowColors: [Color] {
        switch self {
        case .voice:
            return [
                Color(red: 1.00, green: 0.72, blue: 0.57).opacity(0.42),
                Color(red: 0.78, green: 0.66, blue: 0.60).opacity(0.20),
                .clear
            ]
        case .heaven:
            return [
                Color(red: 0.76, green: 0.86, blue: 1.00).opacity(0.46),
                Color(red: 0.50, green: 0.66, blue: 0.94).opacity(0.22),
                .clear
            ]
        }
    }

    var bodyColors: [Color] {
        switch self {
        case .voice:
            return [
                Color(red: 0.34, green: 0.34, blue: 0.35).opacity(0.30),
                Color(red: 0.52, green: 0.47, blue: 0.46).opacity(0.35),
                Color(red: 0.95, green: 0.65, blue: 0.51).opacity(0.68)
            ]
        case .heaven:
            return [
                Color(red: 0.22, green: 0.30, blue: 0.48).opacity(0.30),
                Color(red: 0.38, green: 0.50, blue: 0.76).opacity(0.40),
                Color(red: 0.70, green: 0.82, blue: 1.00).opacity(0.72)
            ]
        }
    }

    var coreColors: [Color] {
        switch self {
        case .voice:
            return [
                Color(red: 1.00, green: 0.91, blue: 0.74).opacity(0.95),
                Color(red: 1.00, green: 0.63, blue: 0.46).opacity(0.72),
                .clear
            ]
        case .heaven:
            return [
                .white.opacity(0.96),
                Color(red: 0.67, green: 0.80, blue: 1.00).opacity(0.82),
                Color(red: 0.40, green: 0.58, blue: 0.94).opacity(0.42),
                .clear
            ]
        }
    }

    var shadowColor: Color {
        switch self {
        case .voice:
            return Color(red: 1.00, green: 0.67, blue: 0.50).opacity(0.30)
        case .heaven:
            return Color(red: 0.58, green: 0.74, blue: 1.00).opacity(0.34)
        }
    }
}

struct IslePortalView: View {
    let title: String
    let style: IslePortalStyle
    let action: () -> Void

    @State private var isFloatingUp = false
    @State private var isBreathing = false

    var body: some View {
        ZStack {
            Ellipse()
                .fill(
                    RadialGradient(
                        colors: style.outerGlowColors,
                        center: .center,
                        startRadius: 10,
                        endRadius: 145
                    )
                )
                .frame(width: 238, height: 288)
                .blur(radius: 20)

            Ellipse()
                .fill(
                    LinearGradient(
                        colors: style.bodyColors,
                        startPoint: .top,
                        endPoint: .bottom
                    )
                )
                .frame(width: 201, height: 275)
                .overlay {
                    Ellipse()
                        .stroke(.white.opacity(0.17), lineWidth: 1)
                }
                .shadow(
                    color: style.shadowColor,
                    radius: 28
                )
                .scaleEffect(isBreathing ? 1.015 : 0.99)

            Ellipse()
                .fill(
                    RadialGradient(
                        colors: style.coreColors,
                        center: .center,
                        startRadius: 4,
                        endRadius: 100
                    )
                )
                .frame(width: 146, height: 191)
                .offset(y: 28)

            Text(title)
                .font(.system(size: 21, weight: .bold))
                .foregroundStyle(.white)
                .shadow(color: .black.opacity(0.50), radius: 18)

            Image(systemName: "sparkle")
                .font(.system(size: 11, weight: .semibold))
                .foregroundStyle(.white)
                .offset(x: -74, y: -78)

            Image(systemName: "sparkle")
                .font(.system(size: 10, weight: .semibold))
                .foregroundStyle(.white.opacity(0.92))
                .offset(x: 76, y: 104)
        }
        .frame(width: 260, height: 330)
        .padding(.horizontal, 28)
        .padding(.vertical, 30)
        .offset(y: isFloatingUp ? -5 : 5)
        .contentShape(Ellipse())
        .hoverEffectDisabled()
        .onTapGesture {
            action()
        }
        .onAppear {
            withAnimation(
                .easeInOut(duration: 3.2)
                    .repeatForever(autoreverses: true)
            ) {
                isFloatingUp = true
            }

            withAnimation(
                .easeInOut(duration: 2.8)
                    .repeatForever(autoreverses: true)
            ) {
                isBreathing = true
            }
        }
    }
}

struct VoiceIslePortalView: View {
    let action: () -> Void

    var body: some View {
        IslePortalView(
            title: "Voice Isle",
            style: .voice,
            action: action
        )
    }
}


// MARK: - Heaven Isle MAIN fixed control

struct HeavenMainControlButton: View {
    let assetName: String
    let title: String
    let action: () -> Void

    private let horizontalPadding: CGFloat = 14
    private let verticalPadding: CGFloat = 16
    private let hitCornerRadius: CGFloat = 24

    var body: some View {
        Button(action: action) {
            HStack(spacing: 10) {
                Image(assetName)
                    .renderingMode(.original)
                    .resizable()
                    .scaledToFit()
                    .frame(width: 30, height: 30)
                    .accessibilityHidden(true)

                Text(title)
                    .font(
                        .system(
                            size: 24,
                            weight: .black
                        )
                    )
            }
            .foregroundStyle(
                Color(
                    red: 237 / 255,
                    green: 231 / 255,
                    blue: 223 / 255
                )
            )
            .padding(.horizontal, horizontalPadding)
            .padding(.vertical, verticalPadding)
            .contentShape(
                RoundedRectangle(
                    cornerRadius: hitCornerRadius,
                    style: .continuous
                )
            )
        }
        .buttonStyle(.plain)
        .hoverEffectDisabled()
    }
}


// MARK: - Other fixed controls

struct HeavenFixedControlButton: View {
    let assetName: String
    let title: String
    let action: () -> Void

    var body: some View {
        Button(action: action) {
            HStack(spacing: 10) {
                Image(assetName)
                    .renderingMode(.original)
                    .resizable()
                    .scaledToFit()
                    .frame(width: 30, height: 30)
                    .accessibilityHidden(true)

                Text(title)
                    .font(
                        .system(
                            size: 24,
                            weight: .black
                        )
                    )
            }
            .foregroundStyle(
                Color(
                    red: 237 / 255,
                    green: 231 / 255,
                    blue: 223 / 255
                )
            )
            .padding(20)
            .contentShape(
                RoundedRectangle(
                    cornerRadius: 20,
                    style: .continuous
                )
            )
        }
        .buttonStyle(.plain)
        .hoverEffectDisabled()
    }
}
