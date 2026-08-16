import SwiftUI

private enum TutorialStep: Equatable {
    case intro
    case islandName
    case welcome
    case gestures
    case catchMemory
    case comfortThings
    case customiseIsland
    case portal
}

enum FigmaPopupLayout {
    static let verticalPadding: CGFloat = 68
    static let cornerRadius: CGFloat = 50

    static let titleToBody: CGFloat = 20
    static let headingToDescription: CGFloat = 8
    static let sectionGap: CGFloat = 60

    // 포탈의 큰 그림자 영역을 시각적으로 보정
    static let portalGap: CGFloat = 120
}

struct TutorialFlowView: View {
    let onTutorialFinished: () -> Void
    let onStartExploring: () -> Void

    // Tutorial Back is rendered by ImmersiveView using the exact same
    // fixed Back attachment + RealityKit depth body used everywhere else.
    let externalBackRequest: Int
    let onBackVisibilityChanged: (Bool) -> Void

    init(
        onTutorialFinished: @escaping () -> Void = {},
        onStartExploring: @escaping () -> Void = {},
        externalBackRequest: Int = 0,
        onBackVisibilityChanged: @escaping (Bool) -> Void = { _ in }
    ) {
        self.onTutorialFinished = onTutorialFinished
        self.onStartExploring = onStartExploring
        self.externalBackRequest = externalBackRequest
        self.onBackVisibilityChanged = onBackVisibilityChanged
    }

    @State private var step: TutorialStep = .intro
    @State private var hasPlayedOpening = false

    var body: some View {
        ZStack {
            currentStepView
                .id(step)
                .scaleEffect(1.08)
                .transition(
                    .opacity.combined(
                        with: .scale(scale: 0.97)
                    )
                )
        }
        .frame(width: 1920, height: 1080)
        .animation(
            .easeInOut(duration: 0.55),
            value: step
        )
        .onAppear {
            onBackVisibilityChanged(showsBackButton)
        }
        .onChange(of: step) { _, _ in
            onBackVisibilityChanged(showsBackButton)
        }
        .onChange(of: externalBackRequest) { _, _ in
            guard showsBackButton else {
                return
            }

            goToPreviousStep()
        }
        .task {
            guard !hasPlayedOpening else {
                return
            }

            hasPlayedOpening = true
            await playOpeningSequence()
        }
    }

    // MARK: - Current screen

    @ViewBuilder
    private var currentStepView: some View {
        switch step {
        case .intro:
            introView

        case .islandName:
            islandNameView

        case .welcome:
            welcomeView

        case .gestures:
            gestureTutorialView

        case .catchMemory:
            catchMemoryView

        case .comfortThings:
            comfortThingsView

        case .customiseIsland:
            customiseIslandView

        case .portal:
            portalTutorialView
        }
    }

    // MARK: - Opening

    private var introView: some View {
        Image("Isle Logo")
            .resizable()
            .scaledToFit()
            .frame(width: 300, height: 150)
            .accessibilityLabel("Isle")
    }

    private var islandNameView: some View {
        Text("Heaven Isle")
            .font(
                .system(
                    size: 82,
                    weight: .semibold,
                    design: .serif
                )
            )
            .foregroundStyle(.white)
    }

    // MARK: - Welcome

    private var welcomeView: some View {
        FigmaPopupContainer(
            width: 720,
            horizontalPadding: 60
        ) {
            VStack(
                alignment: .leading,
                spacing: 0
            ) {
                Text("Welcome to Heaven Isle")
                    .font(
                        .system(
                            size: 50,
                            weight: .bold,
                            design: .serif
                        )
                    )
                    .foregroundStyle(.black)

                Spacer()
                    .frame(height: 20)

                Text(
                    """
                    Look at a memory, then pinch to open it.
                    Follow the portals to explore different parts
                    of your island.
                    """
                )
                .font(
                    .system(
                        size: 22,
                        weight: .medium
                    )
                )
                .lineSpacing(4)
                .multilineTextAlignment(.leading)
                .foregroundStyle(
                    Color(
                        red: 122 / 255,
                        green: 115 / 255,
                        blue: 108 / 255
                    )
                )

                Spacer()
                    .frame(
                        height:
                            FigmaPopupLayout.sectionGap
                    )

                HStack(spacing: 16) {
                    GradientActionButton(
                        title: "Start Tutorial",
                        width: 220
                    ) {
                        goToStep(.gestures)
                    }

                    SecondaryActionButton(
                        title: "Start Exploring",
                        width: 220
                    ) {
                        onStartExploring()
                    }
                }
                .frame(
                    maxWidth: .infinity,
                    alignment: .center
                )
            }
        }
    }

    // MARK: - Gesture introduction

    private var gestureTutorialView: some View {
        FigmaPopupContainer(
            width: 1320,
            horizontalPadding: 80
        ) {
            VStack(
                alignment: .leading,
                spacing: 0
            ) {
                Text("Tutorial")
                    .tutorialTitleStyle()

                Spacer()
                    .frame(height: 20)

                Text(
                    "Here are a few gestures to get you started."
                )
                .font(
                    .system(
                        size: 24,
                        weight: .medium
                    )
                )
                .foregroundStyle(
                    Color(
                        red: 122 / 255,
                        green: 115 / 255,
                        blue: 108 / 255
                    )
                )

                Spacer()
                    .frame(height: 44)

                HStack(
                    alignment: .top,
                    spacing: 69
                ) {
                    GestureGuide(
                        symbol: "eye.fill",
                        title: "Gaze",
                        description:
                            """
                            Look at an item
                            to bring it into focus.
                            """
                    )

                    GestureGuide(
                        symbol: "hand.pinch.fill",
                        title: "Pinch",
                        description:
                            """
                            Bring your thumb and index finger together
                            to select or open it.
                            """
                    )

                    GestureGuide(
                        symbol:
                            "arrow.up.left.and.arrow.down.right",
                        title: "Zoom",
                        description:
                            """
                            Pinch with both hands,
                            then move them apart to zoom in.
                            """
                    )
                }
                .frame(
                    maxWidth: .infinity,
                    minHeight: 400
                )

                Spacer()
                    .frame(height: 44)

                GradientActionButton(
                    title: "Next",
                    width: 300
                ) {
                    goToStep(.catchMemory)
                }
                .frame(
                    maxWidth: .infinity,
                    alignment: .center
                )
            }
        }
    }

    // MARK: - Tutorial 1

    private var catchMemoryView: some View {
        FigmaPopupContainer(
            width: 760,
            horizontalPadding: 70
        ) {
            VStack(
                alignment: .leading,
                spacing: 0
            ) {
                Text("Tutorial")
                    .tutorialTitleStyle()

                Spacer().frame(height: 20)

                Text("1. Catch a memory")
                    .font(
                        .system(
                            size: 30,
                            weight: .medium
                        )
                    )
                    .foregroundStyle(.black)

                Spacer().frame(height: 8)

                Text(
                    "Look at a memory, then pinch to open it."
                )
                .font(.system(size: 20))
                .foregroundStyle(
                    Color(
                        red: 67 / 255,
                        green: 67 / 255,
                        blue: 67 / 255
                    )
                )

                Spacer().frame(height: 40)

                Image("Tutorial 1")
                    .resizable()
                    .scaledToFit()
                    .frame(
                        width: 356.636,
                        height: 320
                    )
                    .frame(
                        maxWidth: .infinity,
                        alignment: .center
                    )
                    .accessibilityHidden(true)

                Spacer().frame(height: 40)

                GradientActionButton(
                    title: "Next",
                    width: 300
                ) {
                    goToStep(.comfortThings)
                }
                .frame(
                    maxWidth: .infinity,
                    alignment: .center
                )
            }
        }
    }

    // MARK: - Tutorial 2

    private var comfortThingsView: some View {
        FigmaPopupContainer(
            width: 790,
            horizontalPadding: 65
        ) {
            VStack(
                alignment: .leading,
                spacing: 0
            ) {
                Text("Tutorial")
                    .tutorialTitleStyle()

                Spacer().frame(height: 20)

                Text("2. Explore your comfort things")
                    .font(
                        .system(
                            size: 30,
                            weight: .medium
                        )
                    )
                    .foregroundStyle(.black)

                Spacer().frame(height: 8)

                Text(
                    "Open photos, videos and familiar voices."
                )
                .font(.system(size: 20))
                .foregroundStyle(
                    Color(
                        red: 67 / 255,
                        green: 67 / 255,
                        blue: 67 / 255
                    )
                )

                Spacer().frame(height: 40)

                Image("Tutorial 2")
                    .resizable()
                    .scaledToFit()
                    .frame(
                        width: 622,
                        height: 311
                    )
                    .frame(
                        maxWidth: .infinity,
                        alignment: .center
                    )
                    .accessibilityHidden(true)

                Spacer().frame(height: 40)

                GradientActionButton(
                    title: "Next",
                    width: 300
                ) {
                    goToStep(.customiseIsland)
                }
                .frame(
                    maxWidth: .infinity,
                    alignment: .center
                )
            }
        }
    }

    // MARK: - Tutorial 3

    private var customiseIslandView: some View {
        FigmaPopupContainer(
            width: 760,
            horizontalPadding: 70
        ) {
            VStack(
                alignment: .leading,
                spacing: 0
            ) {
                Text("Tutorial")
                    .tutorialTitleStyle()

                Spacer().frame(height: 20)

                Text("3. Make the island yours")
                    .font(
                        .system(
                            size: 30,
                            weight: .medium
                        )
                    )
                    .foregroundStyle(.black)

                Spacer().frame(height: 8)

                Text(
                    """
                    Use the menu to add or remove comfort items
                    and adjust the atmosphere.
                    """
                )
                .font(.system(size: 20))
                .multilineTextAlignment(.leading)
                .foregroundStyle(
                    Color(
                        red: 67 / 255,
                        green: 67 / 255,
                        blue: 67 / 255
                    )
                )

                Spacer().frame(height: 40)

                Image("Tutorial 3")
                    .resizable()
                    .scaledToFit()
                    .frame(
                        width: 469,
                        height: 380
                    )
                    .frame(
                        maxWidth: .infinity,
                        alignment: .center
                    )
                    .accessibilityHidden(true)

                Spacer().frame(height: 40)

                GradientActionButton(
                    title: "Next",
                    width: 300
                ) {
                    goToStep(.portal)
                }
                .frame(
                    maxWidth: .infinity,
                    alignment: .center
                )
            }
        }
    }

    // MARK: - Tutorial 4

    private var portalTutorialView: some View {
        FigmaPopupContainer(
            width: 760,
            horizontalPadding: 70
        ) {
            VStack(
                alignment: .leading,
                spacing: 0
            ) {
                Text("Tutorial")
                    .tutorialTitleStyle()

                Spacer().frame(height: 20)

                Text("4. Travel between islands")
                    .font(
                        .system(
                            size: 30,
                            weight: .medium
                        )
                    )
                    .foregroundStyle(.black)

                Spacer().frame(height: 8)

                Text(
                    "Pinch a portal to move between spaces."
                )
                .font(.system(size: 20))
                .foregroundStyle(
                    Color(
                        red: 67 / 255,
                        green: 67 / 255,
                        blue: 67 / 255
                    )
                )

                Spacer().frame(height: 54)

                Image("Tutorial 4")
                    .resizable()
                    .scaledToFit()
                    .frame(
                        width: 307,
                        height: 372
                    )
                    .frame(
                        maxWidth: .infinity,
                        alignment: .center
                    )
                    .accessibilityHidden(true)

                Spacer().frame(height: 44)

                GradientActionButton(
                    title: "Enter Heaven Isle",
                    width: 300
                ) {
                    onTutorialFinished()
                }
                .frame(
                    maxWidth: .infinity,
                    alignment: .center
                )
            }
        }
    }

    // MARK: - Back navigation

    private var showsBackButton: Bool {
        switch step {
        case .intro, .islandName, .welcome:
            return false

        case .gestures,
             .catchMemory,
             .comfortThings,
             .customiseIsland,
             .portal:
            return true
        }
    }

    private func goToPreviousStep() {
        switch step {
        case .gestures:
            goToStep(.welcome)

        case .catchMemory:
            goToStep(.gestures)

        case .comfortThings:
            goToStep(.catchMemory)

        case .customiseIsland:
            goToStep(.comfortThings)

        case .portal:
            goToStep(.customiseIsland)

        case .intro, .islandName, .welcome:
            break
        }
    }

    private func goToStep(
        _ newStep: TutorialStep
    ) {
        withAnimation(
            .easeInOut(duration: 0.55)
        ) {
            step = newStep
        }
    }

    // MARK: - Opening timing

    @MainActor
    private func playOpeningSequence() async {
        try? await Task.sleep(
            nanoseconds: 1_300_000_000
        )

        guard !Task.isCancelled else {
            return
        }

        goToStep(.islandName)

        try? await Task.sleep(
            nanoseconds: 1_500_000_000
        )

        guard !Task.isCancelled else {
            return
        }

        goToStep(.welcome)
    }
}

// MARK: - Shared popup

struct FigmaPopupContainer<Content: View>: View {
    let width: CGFloat
    let horizontalPadding: CGFloat

    private let content: Content

    init(
        width: CGFloat,
        horizontalPadding: CGFloat = 70,
        @ViewBuilder content: () -> Content
    ) {
        self.width = width
        self.horizontalPadding = horizontalPadding
        self.content = content()
    }

    var body: some View {
        content
            .padding(
                .horizontal,
                horizontalPadding
            )
            .padding(
                .vertical,
                FigmaPopupLayout.verticalPadding
            )
            .frame(width: width)
            .figmaGlassPanel(
                cornerRadius:
                    FigmaPopupLayout.cornerRadius
            )
    }
}

// MARK: - Gesture guide

private struct GestureGuide: View {
    let symbol: String
    let title: String
    let description: String

    var body: some View {
        VStack(spacing: 0) {
            Text(title)
                .font(
                    .system(
                        size: 30,
                        weight: .medium
                    )
                )
                .foregroundStyle(.black)

            Spacer().frame(height: 8)

            Text(description)
                .font(
                    .system(
                        size: 16,
                        weight: .regular
                    )
                )
                .italic()
                .multilineTextAlignment(.center)
                .foregroundStyle(
                    Color(
                        red: 67 / 255,
                        green: 67 / 255,
                        blue: 67 / 255
                    )
                )

            Spacer()

            Image(systemName: symbol)
                .font(.system(size: 150))
                .foregroundStyle(
                    Color(
                        red: 245 / 255,
                        green: 154 / 255,
                        blue: 106 / 255
                    )
                )
                .frame(
                    maxWidth: .infinity,
                    minHeight: 270,
                    alignment: .bottom
                )
        }
        .frame(
            maxWidth: .infinity,
            minHeight: 400,
            maxHeight: 400
        )
    }
}

// MARK: - Memory preview

private struct MemoryPreviewCard: View {
    var body: some View {
        ZStack(alignment: .bottom) {
            RoundedRectangle(cornerRadius: 22)
                .fill(
                    LinearGradient(
                        colors: [
                            .white.opacity(0.28),
                            .white.opacity(0.10)
                        ],
                        startPoint: .top,
                        endPoint: .bottom
                    )
                )

            LinearGradient(
                colors: [
                    .clear,
                    .black.opacity(0.55)
                ],
                startPoint: .top,
                endPoint: .bottom
            )
            .clipShape(
                RoundedRectangle(cornerRadius: 22)
            )

            Text("Family Trip in childhood")
                .font(
                    .system(
                        size: 18,
                        weight: .bold
                    )
                )
                .foregroundStyle(.white)
                .padding(.bottom, 16)
        }
        .frame(width: 320, height: 230)
        .overlay {
            RoundedRectangle(cornerRadius: 22)
                .stroke(
                    .white.opacity(0.35),
                    lineWidth: 1
                )
        }
        .shadow(
            color: .white.opacity(0.18),
            radius: 18
        )
    }
}

// MARK: - Comfort preview

private struct ComfortMemoryPreview: View {
    var body: some View {
        HStack(spacing: 22) {
            ZStack {
                RoundedRectangle(cornerRadius: 22)
                    .fill(
                        LinearGradient(
                            colors: [
                                Color(
                                    red: 0.75,
                                    green: 0.77,
                                    blue: 0.70
                                ),
                                Color(
                                    red: 0.31,
                                    green: 0.38,
                                    blue: 0.29
                                )
                            ],
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        )
                    )

                Image(systemName: "photo.fill")
                    .font(.system(size: 74))
                    .foregroundStyle(
                        .white.opacity(0.7)
                    )
            }
            .frame(width: 330, height: 245)
            .overlay {
                RoundedRectangle(cornerRadius: 22)
                    .stroke(
                        .white.opacity(0.45),
                        lineWidth: 1
                    )
            }
            .shadow(
                color: .white.opacity(0.18),
                radius: 14
            )

            VStack(
                alignment: .leading,
                spacing: 12
            ) {
                Text("Our summer trip")
                    .font(
                        .system(
                            size: 22,
                            weight: .bold,
                            design: .serif
                        )
                    )

                Text("Photo memory")
                    .font(.caption)
                    .foregroundStyle(
                        Color(
                            red: 122 / 255,
                            green: 115 / 255,
                            blue: 108 / 255
                        )
                    )

                Divider()
                    .overlay(.white.opacity(0.18))

                Text(
                    """
                    A summer afternoon with my family.
                    We walked through the fields together —
                    it still feels warm and familiar.
                    """
                )
                .font(.system(size: 14))
                .foregroundStyle(
                    Color(
                        red: 67 / 255,
                        green: 67 / 255,
                        blue: 67 / 255
                    )
                )

                Spacer()
            }
            .padding(22)
            .frame(width: 230, height: 245)
            .background(
                .black.opacity(0.10),
                in: RoundedRectangle(
                    cornerRadius: 22
                )
            )
            .overlay {
                RoundedRectangle(cornerRadius: 22)
                    .stroke(
                        .white.opacity(0.25),
                        lineWidth: 0.7
                    )
            }
        }
    }
}

// MARK: - Portal preview

private struct PortalPreview: View {
    private let portalGradient = Gradient(
        stops: [
            .init(
                color: Color(
                    red: 0.6588,
                    green: 0.9098,
                    blue: 1
                )
                .opacity(0.72),
                location: 0
            ),

            .init(
                color: Color(
                    red: 0.5412,
                    green: 0.5686,
                    blue: 1
                )
                .opacity(0.42),
                location: 0.5
            ),

            .init(
                color: Color.white.opacity(0.08),
                location: 1
            )
        ]
    )

    var body: some View {
        ZStack {
            Circle()
                .fill(
                    RadialGradient(
                        gradient: portalGradient,
                        center: .center,
                        startRadius: 0,
                        endRadius: 205
                    )
                )
                .frame(width: 410, height: 410)
                .scaleEffect(
                    x: 300.0 / 410.0,
                    y: 1
                )
                .frame(width: 300, height: 410)
                .compositingGroup()
                .shadow(
                    color: Color(
                        red: 0.7867,
                        green: 0.7642,
                        blue: 1
                    ),
                    radius: 100,
                    x: 0,
                    y: 4
                )

            Text("Portal")
                .font(
                    .system(
                        size: 28,
                        weight: .bold
                    )
                )
                .foregroundStyle(.white)
        }
        .frame(width: 300, height: 410)
    }
}

// MARK: - Gradient button

private struct GradientActionButton: View {
    let title: String
    let width: CGFloat
    let action: () -> Void

    var body: some View {
        Button(action: action) {
            Text(title)
                .font(
                    .system(
                        size: 24,
                        weight: .bold
                    )
                )
                .foregroundStyle(
                    Color(
                        red: 140 / 255,
                        green: 130 / 255,
                        blue: 121 / 255
                    )
                )
                .frame(
                    width: width,
                    height: 68
                )
                .background {
                    Capsule()
                        .fill(
                            Color(
                                red: 237 / 255,
                                green: 231 / 255,
                                blue: 223 / 255
                            )
                        )
                }
        }
        .buttonStyle(.plain)
        .hoverEffect(.highlight)
    }
}

// MARK: - Secondary button

private struct SecondaryActionButton: View {
    let title: String
    let width: CGFloat
    let action: () -> Void

    var body: some View {
        Button(action: action) {
            Text(title)
                .font(
                    .system(
                        size: 24,
                        weight: .bold
                    )
                )
                .foregroundStyle(
                    Color(
                        red: 67 / 255,
                        green: 67 / 255,
                        blue: 67 / 255
                    )
                )
                .frame(
                    width: width,
                    height: 68
                )
                .background {
                    Capsule()
                        .fill(.white.opacity(0.20))
                }
        }
        .buttonStyle(.plain)
        .hoverEffect(.highlight)
    }
}

// MARK: - Glass panel

private struct FigmaGlassPanelModifier:
    ViewModifier {
    let cornerRadius: CGFloat

    func body(content: Content) -> some View {
        let shape = RoundedRectangle(
            cornerRadius: cornerRadius,
            style: .continuous
        )

        content
            .background {
                shape
                    .fill(.ultraThinMaterial)
                    .overlay {
                        shape
                            .fill(
                                Color(
                                    red: 243 / 255,
                                    green: 240 / 255,
                                    blue: 237 / 255
                                )
                                .opacity(0.60)
                            )
                    }
            }
            .overlay {
                shape
                    .stroke(
                        .white.opacity(0.12),
                        lineWidth: 0.5
                    )
            }
            .overlay {
                shape
                    .stroke(
                        .white.opacity(0.25),
                        lineWidth: 10
                    )
                    .blur(radius: 10)
                    .clipShape(shape)
            }
            .shadow(
                color: .white.opacity(0.20),
                radius: 50
            )
    }
}

// MARK: - Styles

private extension View {
    func figmaGlassPanel(
        cornerRadius: CGFloat = 50
    ) -> some View {
        modifier(
            FigmaGlassPanelModifier(
                cornerRadius: cornerRadius
            )
        )
    }

    func tutorialTitleStyle() -> some View {
        font(
            .system(
                size: 50,
                weight: .bold,
                design: .serif
            )
        )
        .foregroundStyle(.black)
    }
}
