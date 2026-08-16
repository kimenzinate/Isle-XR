import SwiftUI
import AVFoundation
import Combine

// MARK: - Voice memory model

struct VoiceMemoryItem: Identifiable, Equatable {
    let id: Int
    let title: String
    let description: String
    let audioBaseName: String
    let orbSize: CGFloat
    let titleSize: CGFloat
}

enum VoiceIsleContent {

    static let dad = VoiceMemoryItem(
        id: 1,
        title: "A Call with Dad",
        description:
            "When I was working far from home, Dad reminded me to eat properly and look after my health. Hearing his voice gave me strength and made the distance feel a little easier.",
        audioBaseName: "Voice_Dad",
        orbSize: 248,
        titleSize: 34
    )

    static let song = VoiceMemoryItem(
        id: 2,
        title: "Mum Singing\nin the Car",
        description:
            "Mum used to sing this song in the car. She’s not exactly in tune, but she loves singing — and hearing it always makes me smile.",
        audioBaseName: "Voice_song",
        orbSize: 196,
        titleSize: 31
    )

    static let story = VoiceMemoryItem(
        id: 3,
        title: "Mum’s Scary\nStory",
        description:
            "Mum told me a scary story she had heard years ago, but she told it so dramatically and hilariously that we ended up laughing the whole time.",
        audioBaseName: "Voice_story",
        orbSize: 257,
        titleSize: 38
    )

    static let promise = VoiceMemoryItem(
        id: 4,
        title: "Dad’s Promise\nto Mum",
        description:
            "Dad made this promise to Mum, and he actually kept it. Hearing it again makes me so happy, knowing that he meant what he said.",
        audioBaseName: "Voice_Promise",
        orbSize: 130,
        titleSize: 22
    )

    static let birthday = VoiceMemoryItem(
        id: 5,
        title: "Mum Singing\nHappy Birthday",
        description:
            "Mum sang Happy Birthday to Dad while I was living far away, so I missed the celebration. I was sad not to be there — next year, I want to celebrate his birthday with them in person.",
        audioBaseName: "Voice_Birthday",
        orbSize: 141,
        titleSize: 26
    )

    static let all: [VoiceMemoryItem] = [
        song,
        dad,
        promise,
        birthday,
        story
    ]
}

// MARK: - Voice Isle title

struct VoiceIsleTitleView: View {
    var body: some View {
        VStack(spacing: 19) {
            Text("Voice Isle")
                .font(
                    .system(
                        size: 50,
                        weight: .bold,
                        design: .serif
                    )
                )

            Text("Pinch a voice to listen")
                .font(
                    .system(
                        size: 24,
                        weight: .medium
                    )
                )
        }
        .multilineTextAlignment(.center)
        .foregroundStyle(.white)
        .shadow(
            color: .black.opacity(0.28),
            radius: 12
        )
    }
}

// MARK: - Voice orb visual

private struct VoiceGlowOrb: View {
    let size: CGFloat

    var body: some View {
        Circle()
            .fill(
                RadialGradient(
                    stops: [
                        .init(
                            color: Color(
                                red: 0.9843137264,
                                green: 0.9529411793,
                                blue: 0.9176470637
                            ),
                            location: 0.0
                        ),
                        .init(
                            color: Color(
                                red: 0.6784313917,
                                green: 0.8535947800,
                                blue: 0.9411764741
                            ),
                            location: 0.5
                        ),
                        .init(
                            color: Color(
                                red: 0.6784313917,
                                green: 0.7607843280,
                                blue: 0.9411764741
                            )
                            .opacity(0.05),
                            location: 1.0
                        )
                    ],
                    center: .center,
                    startRadius: 0,
                    endRadius: size * 0.5
                )
            )
            .frame(
                width: size,
                height: size
            )
    }
}

// MARK: - Voice detail orb visual

private struct VoiceDetailOrb: View {
    var body: some View {
        ZStack {
            Circle()
                .fill(
                    RadialGradient(
                        stops: [
                            .init(
                                color: Color(
                                    red: 0.9843137264,
                                    green: 0.9529411793,
                                    blue: 0.9176470637
                                ),
                                location: 0.0
                            ),
                            .init(
                                color: Color(
                                    red: 0.5540865660,
                                    green: 0.8810897470,
                                    blue: 1.0
                                ),
                                location: 0.25
                            ),
                            .init(
                                color: Color(
                                    red: 0.6784313917,
                                    green: 0.8535947800,
                                    blue: 0.9411764741
                                ),
                                location: 0.5
                            ),
                            .init(
                                color: Color(
                                    red: 0.6784313917,
                                    green: 0.7607843280,
                                    blue: 0.9411764741
                                )
                                .opacity(0.05),
                                location: 1.0
                            )
                        ],
                        center: .center,
                        startRadius: 0,
                        endRadius: 228.5
                    )
                )
                .frame(
                    width: 457,
                    height: 457
                )

            Circle()
                .stroke(
                    .white.opacity(0.50),
                    lineWidth: 2.4635
                )
                .frame(
                    width: 262.774,
                    height: 262.774
                )

            Circle()
                .stroke(
                    .white.opacity(0.50),
                    lineWidth: 1.6423
                )
                .frame(
                    width: 344.891,
                    height: 344.891
                )
        }
        .frame(
            width: 600,
            height: 600
        )
    }
}

// MARK: - Voice orb

struct VoiceIsleOrbButton: View {
    let memory: VoiceMemoryItem
    let action: () -> Void

    @State private var isPressed = false

    var body: some View {
        Button(action: action) {
            VStack(spacing: 29) {
                VoiceGlowOrb(
                    size: memory.orbSize
                )
                .frame(
                    width: memory.orbSize,
                    height: memory.orbSize
                )
                .scaleEffect(
                    isPressed
                        ? 1.055
                        : 1.00
                )

                Text(memory.title)
                    .font(
                        .system(
                            size: memory.titleSize,
                            weight: .bold
                        )
                    )
                    .foregroundStyle(.white)
                    .multilineTextAlignment(.center)
                    .lineSpacing(2)
                    .frame(
                        width: max(
                            memory.orbSize + 50,
                            230
                        )
                    )
                    .shadow(
                        color: .black.opacity(0.28),
                        radius: 8
                    )
            }
        }
        .buttonStyle(.plain)
        .hoverEffectDisabled()
        .contentShape(Rectangle())
        .simultaneousGesture(
            DragGesture(minimumDistance: 0)
                .onChanged { _ in
                    withAnimation(
                        .easeOut(
                            duration: 0.12
                        )
                    ) {
                        isPressed = true
                    }
                }
                .onEnded { _ in
                    withAnimation(
                        .easeOut(
                            duration: 0.18
                        )
                    ) {
                        isPressed = false
                    }
                }
        )
    }
}

// MARK: - Heaven Isle portal

struct VoiceIsleHeavenPortalButton: View {
    let action: () -> Void

    @State private var isFloatingUp = false
    @State private var isBreathing = false
    @State private var isPressed = false

    var body: some View {
        ZStack {
            Ellipse()
                .fill(
                    RadialGradient(
                        colors: [
                            Color(
                                red: 0.76,
                                green: 0.86,
                                blue: 1.00
                            )
                            .opacity(0.46),
                            Color(
                                red: 0.50,
                                green: 0.66,
                                blue: 0.94
                            )
                            .opacity(0.22),
                            .clear
                        ],
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
                        colors: [
                            Color(
                                red: 0.22,
                                green: 0.30,
                                blue: 0.48
                            )
                            .opacity(0.30),
                            Color(
                                red: 0.38,
                                green: 0.50,
                                blue: 0.76
                            )
                            .opacity(0.40),
                            Color(
                                red: 0.70,
                                green: 0.82,
                                blue: 1.00
                            )
                            .opacity(0.72)
                        ],
                        startPoint: .top,
                        endPoint: .bottom
                    )
                )
                .frame(width: 201, height: 275)
                .overlay {
                    Ellipse()
                        .stroke(
                            .white.opacity(0.18),
                            lineWidth: 1
                        )
                }
                .shadow(
                    color: Color(
                        red: 0.58,
                        green: 0.74,
                        blue: 1.00
                    )
                    .opacity(0.34),
                    radius: 28
                )
                .scaleEffect(
                    (isBreathing ? 1.015 : 0.99)
                    * (isPressed ? 0.97 : 1.0)
                )

            Ellipse()
                .fill(
                    RadialGradient(
                        colors: [
                            .white.opacity(0.96),
                            Color(
                                red: 0.67,
                                green: 0.80,
                                blue: 1.00
                            )
                            .opacity(0.82),
                            Color(
                                red: 0.40,
                                green: 0.58,
                                blue: 0.94
                            )
                            .opacity(0.42),
                            .clear
                        ],
                        center: .center,
                        startRadius: 4,
                        endRadius: 100
                    )
                )
                .frame(width: 146, height: 191)
                .offset(y: 28)

            Text("Heaven Isle")
                .font(.system(size: 21, weight: .bold))
                .foregroundStyle(.white)
                .shadow(
                    color: .black.opacity(0.50),
                    radius: 18
                )

            Image(systemName: "sparkle")
                .font(
                    .system(
                        size: 11,
                        weight: .semibold
                    )
                )
                .foregroundStyle(.white)
                .offset(x: -74, y: -78)

            Image(systemName: "sparkle")
                .font(
                    .system(
                        size: 10,
                        weight: .semibold
                    )
                )
                .foregroundStyle(
                    .white.opacity(0.92)
                )
                .offset(x: 76, y: 104)
        }
        // Keeps the portal interaction area consistent across islands.
        .frame(width: 260, height: 330)
        .padding(.horizontal, 28)
        .padding(.vertical, 30)
        .offset(y: isFloatingUp ? -5 : 5)
        .contentShape(Ellipse())
        // Gesture avoids the default visionOS rectangular button highlight.
        .onTapGesture {
            action()
        }
        .simultaneousGesture(
            DragGesture(minimumDistance: 0)
                .onChanged { _ in
                    withAnimation(
                        .easeOut(duration: 0.12)
                    ) {
                        isPressed = true
                    }
                }
                .onEnded { _ in
                    withAnimation(
                        .easeOut(duration: 0.18)
                    ) {
                        isPressed = false
                    }
                }
        )
        .accessibilityAddTraits(.isButton)
        .onAppear {
            withAnimation(
                .easeInOut(duration: 3.2)
                    .repeatForever(
                        autoreverses: true
                    )
            ) {
                isFloatingUp = true
            }

            withAnimation(
                .easeInOut(duration: 2.8)
                    .repeatForever(
                        autoreverses: true
                    )
            ) {
                isBreathing = true
            }
        }
    }
}

// MARK: - Audio resource lookup

private nonisolated enum VoiceAudioResource {

    private static let supportedExtensions: Set<String> = [
        "m4a",
        "mp3",
        "wav",
        "aac",
        "caf",
        "aiff",
        "aif",
        "mp4"
    ]

    static func url(
        for requestedBaseName: String
    ) -> URL? {

        let candidateNames =
            candidateBaseNames(
                for: requestedBaseName
            )

        // 1) Fast exact lookup first.
        for candidate in candidateNames {
            for ext in supportedExtensions {
                if let url =
                        Bundle.main.url(
                            forResource: candidate,
                            withExtension: ext
                        ) {
                    print(
                        "✅ VOICE AUDIO FOUND:",
                        url.lastPathComponent
                    )
                    return url
                }
            }
        }

        // Search bundled audio recursively to support nested resources
        // and common filename variations.
        guard let resourceURL =
                Bundle.main.resourceURL
        else {
            return nil
        }

        let expectedKeys =
            Set(
                candidateNames.map(
                    normalize
                )
            )

        guard let enumerator =
                FileManager.default.enumerator(
                    at: resourceURL,
                    includingPropertiesForKeys: nil,
                    options: [
                        .skipsHiddenFiles
                    ]
                )
        else {
            return nil
        }

        var audioFiles: [String] = []

        for case let url as URL in enumerator {

            let ext =
                url.pathExtension
                    .lowercased()

            guard supportedExtensions
                .contains(ext)
            else {
                continue
            }

            audioFiles.append(
                url.lastPathComponent
            )

            let actualBaseName =
                url.deletingPathExtension()
                    .lastPathComponent

            let actualKey =
                normalize(
                    actualBaseName
                )

            let actualWithoutPrefixKey =
                normalize(
                    removingLeadingNumberPrefix(
                        from: actualBaseName
                    )
                )

            if expectedKeys
                .contains(actualKey)
                || expectedKeys
                    .contains(
                        actualWithoutPrefixKey
                    ) {

                print(
                    "✅ VOICE AUDIO FOUND BY SCAN:",
                    url.lastPathComponent
                )

                return url
            }
        }

        print(
            "❌ VOICE AUDIO NOT IN APP BUNDLE:",
            requestedBaseName
        )

        print(
            "🎧 AUDIO FILES CURRENTLY IN BUNDLE:",
            audioFiles.isEmpty
            ? "(none)"
            : audioFiles.joined(
                separator: ", "
            )
        )

        return nil
    }

    private static func candidateBaseNames(
        for requestedBaseName: String
    ) -> [String] {

        let withoutNumber =
            removingLeadingNumberPrefix(
                from: requestedBaseName
            )

        var names = [
            requestedBaseName,
            withoutNumber,
            requestedBaseName
                .replacingOccurrences(
                    of: "-",
                    with: "_"
                ),
            requestedBaseName
                .replacingOccurrences(
                    of: "_",
                    with: "-"
                ),
            withoutNumber
                .replacingOccurrences(
                    of: "-",
                    with: "_"
                ),
            withoutNumber
                .replacingOccurrences(
                    of: "_",
                    with: "-"
                )
        ]

        // Remove duplicates while preserving order.
        var seen = Set<String>()

        names = names.filter {
            seen.insert($0).inserted
        }

        return names
    }

    private static func removingLeadingNumberPrefix(
        from value: String
    ) -> String {

        var index =
            value.startIndex

        while index < value.endIndex {
            let character =
                value[index]

            if character.isNumber
                || character == "-"
                || character == "_"
                || character == " " {

                index =
                    value.index(
                        after: index
                    )

            } else {
                break
            }
        }

        return String(
            value[index...]
        )
    }

    private static func normalize(
        _ value: String
    ) -> String {

        String(
            value
                .lowercased()
                .filter {
                    $0.isLetter
                    || $0.isNumber
                }
        )
    }
}

// MARK: - Audio playback

@MainActor
private final class VoiceAudioPlaybackModel:
    ObservableObject {

    @Published var isPlaying = false
    @Published var progress: Double = 0
    @Published var duration: TimeInterval = 0
    @Published var loadError: String?

    private var player: AVAudioPlayer?
    private var progressTask: Task<Void, Never>?
    private var loadedBaseName: String?

    func prepare(
        baseName: String
    ) {
        guard loadedBaseName != baseName
        else {
            return
        }

        stop(resetProgress: true)
        loadedBaseName = baseName
        loadError = nil

        guard let url =
                VoiceAudioResource.url(
                    for: baseName
                )
        else {
            loadError =
                "Audio file is not in the app bundle: \(baseName)"
            print(
                "❌ VOICE AUDIO NOT FOUND:",
                baseName
            )
            return
        }

        do {
            let player =
                try AVAudioPlayer(
                    contentsOf: url
                )

            player.prepareToPlay()
            player.volume = 1

            self.player = player
            duration = player.duration
            progress = 0

            print(
                "✅ VOICE AUDIO READY:",
                url.lastPathComponent
            )
        } catch {
            loadError =
                error.localizedDescription

            print(
                "❌ VOICE AUDIO FAILED:",
                baseName,
                "|",
                error.localizedDescription
            )
        }
    }

    func toggle() {
        guard let player
        else {
            return
        }

        if player.isPlaying {
            player.pause()
            isPlaying = false
            stopTimer()
        } else {
            if player.currentTime
                >= player.duration - 0.05 {
                player.currentTime = 0
            }

            player.play()
            isPlaying = true
            startTimer()
        }
    }

    func stop(
        resetProgress: Bool = false
    ) {
        player?.pause()
        isPlaying = false
        stopTimer()

        if resetProgress {
            player?.currentTime = 0
            progress = 0
        }
    }

    private func startTimer() {
        stopTimer()

        progressTask = Task { @MainActor [weak self] in
            while !Task.isCancelled {
                guard let self,
                      let player = self.player
                else {
                    return
                }

                let safeDuration =
                    max(
                        player.duration,
                        0.001
                    )

                self.duration =
                    player.duration

                self.progress =
                    min(
                        max(
                            player.currentTime
                                / safeDuration,
                            0
                        ),
                        1
                    )

                if !player.isPlaying {
                    self.isPlaying = false

                    if player.currentTime
                        >= player.duration - 0.05 {
                        self.progress = 1
                    }

                    self.stopTimer()
                    return
                }

                try? await Task.sleep(
                    for: .milliseconds(50)
                )
            }
        }
    }

    private func stopTimer() {
        progressTask?.cancel()
        progressTask = nil
    }
}

// MARK: - Waveform

private struct VoiceWaveformView: View {
    let progress: Double

    private let bars: [CGFloat] = [
        18, 28, 41, 57, 39, 62, 49, 36,
        54, 44, 31, 59, 33, 28, 39, 36,
        49, 31, 23, 33, 44, 31, 23, 39,
        46, 33, 39, 28, 23, 44, 33, 28,
        39, 36, 49, 31, 23, 33, 44, 31,
        23, 39, 46, 33, 39, 28, 23, 44
    ]

    var body: some View {
        HStack(
            alignment: .center,
            spacing: 3.8
        ) {
            ForEach(
                Array(
                    bars.enumerated()
                ),
                id: \.offset
            ) { index, height in
                let threshold =
                    Double(index)
                    / Double(
                        max(
                            bars.count - 1,
                            1
                        )
                    )

                Capsule()
                    .fill(
                        threshold <= progress
                        ? .white
                        : .white.opacity(0.50)
                    )
                    .frame(
                        width: 3.8,
                        height: height
                    )
            }
        }
        .frame(height: 64)
    }
}

// MARK: - Voice detail — 718:17612

struct VoiceMemoryDetailView: View {
    let memory: VoiceMemoryItem
    let isActive: Bool

    @StateObject
    private var playback =
        VoiceAudioPlaybackModel()

    // 718:17612 uses a 1920×1080 screen.
    // This attachment keeps the same vertical coordinates,
    // while using the project's established 1371pt detail width.
    private let canvasWidth: CGFloat = 1371
    private let canvasHeight: CGFloat = 1080

    private var durationText: String {
        let remaining =
            max(
                playback.duration
                    * (1 - playback.progress),
                0
            )

        // ceil keeps 0:16 visible until the first full second has elapsed,
        // then counts down naturally to 0:00.
        let total =
            max(
                Int(ceil(remaining)),
                0
            )

        return String(
            format:
                "%d:%02d",
            total / 60,
            total % 60
        )
    }

    var body: some View {
        ZStack(alignment: .topLeading) {

            // --------------------------------------------------
            // Orb 600×600, top ≈ 119.68
            // --------------------------------------------------
            VoiceDetailOrb()
                .frame(
                width: 600,
                height: 600
                )
                .position(
                    x: canvasWidth / 2,
                    y: 420
                )

            // --------------------------------------------------
            // player top ≈ 682, height ≈ 72
            // --------------------------------------------------
            HStack(spacing: 36) {

                Button {
                    playback.toggle()
                } label: {
                    Circle()
                        .fill(.white)
                        .frame(
                            width: 72,
                            height: 72
                        )
                        .overlay {
                            Image(
                                systemName:
                                    playback.isPlaying
                                    ? "pause.fill"
                                    : "play.fill"
                            )
                            .font(
                                .system(
                                    size: 29,
                                    weight: .black
                                )
                            )
                            .foregroundStyle(
                                .black
                            )
                            .offset(
                                x:
                                    playback.isPlaying
                                    ? 0
                                    : 2
                            )
                        }
                }
                .buttonStyle(.plain)
                .hoverEffect(.highlight)

                VoiceWaveformView(
                    progress:
                        playback.progress
                )

                Text(durationText)
                    .font(
                        .system(
                            size: 26,
                            weight: .bold
                        )
                    )
                    .foregroundStyle(
                        .white
                    )
                    .monospacedDigit()
                    .frame(
                        minWidth: 68
                    )
            }
            .frame(
                height: 72
            )
            .position(
                x: canvasWidth / 2,
                y: 718
            )

            // --------------------------------------------------
            // description panel top ≈ 807, width 1300
            // --------------------------------------------------
            VStack(spacing: 19) {

                Text(
                    memory.title
                        .replacingOccurrences(
                            of: "\n",
                            with: " "
                        )
                )
                .font(
                    .system(
                        size: 38,
                        weight: .bold
                    )
                )

                Text(
                    memory.description
                )
                .font(
                    .system(
                        size: 24,
                        weight: .medium
                    )
                )
                .lineSpacing(4)
                .frame(
                    maxWidth: 1220
                )
            }
            .multilineTextAlignment(
                .center
            )
            .foregroundStyle(.white)
            .frame(
                width: 1300
            )
            .padding(
                .vertical,
                34
            )
            .background {
                RoundedRectangle(
                    cornerRadius: 20,
                    style: .continuous
                )
                .fill(
                    .black.opacity(0.10)
                )
                .overlay {
                    RoundedRectangle(
                        cornerRadius: 20,
                        style: .continuous
                    )
                    .stroke(
                        .white.opacity(0.50),
                        lineWidth: 0.5
                    )
                }
            }
            .shadow(
                color:
                    .white.opacity(0.20),
                radius: 50
            )
            .position(
                x: canvasWidth / 2,
                y: 955
            )

            // Diagnostic only.
            // If this appears, the file is not bundled in the app.
            if let loadError =
                    playback.loadError {

                Text(loadError)
                    .font(
                        .system(
                            size: 16,
                            weight: .medium
                        )
                    )
                    .foregroundStyle(
                        .white.opacity(0.62)
                    )
                    .position(
                        x:
                            canvasWidth / 2,
                        y: 1040
                    )
            }
        }
        .frame(
            width: canvasWidth,
            height: canvasHeight
        )
        .onAppear {
            playback.prepare(
                baseName:
                    memory.audioBaseName
            )
        }
        .onChange(
            of: memory.id
        ) { _, _ in
            playback.prepare(
                baseName:
                    memory.audioBaseName
            )
        }
        .onChange(
            of: isActive
        ) { _, newValue in

            if newValue {
                playback.prepare(
                    baseName:
                        memory.audioBaseName
                )
            } else {
                playback.stop(
                    resetProgress: true
                )
            }
        }
    }
}
