import SwiftUI

struct ContentView: View {
    @Environment(AppModel.self) private var appModel
    @Environment(\.openImmersiveSpace) private var openImmersiveSpace
    @Environment(\.dismissWindow) private var dismissWindow

    var body: some View {
        Text("Opening Dream Island...")
            .task {
                await openDreamIslandIfNeeded()
            }
    }

    @MainActor
    private func openDreamIslandIfNeeded() async {
        if appModel.immersiveSpaceState == .open {
            print("ℹ️ Immersive space is already open")
            dismissWindow()
            return
        }

        guard appModel.immersiveSpaceState == .closed else {
            print("ℹ️ Immersive space request already in progress")
            return
        }

        appModel.immersiveSpaceState = .inTransition

        let result = await openImmersiveSpace(
            id: appModel.immersiveSpaceID
        )

        switch result {
        case .opened:
            appModel.immersiveSpaceState = .open
            print("✅ Immersive space opened")

            dismissWindow()

        case .userCancelled:
            appModel.immersiveSpaceState = .closed
            print("⚠️ User cancelled immersive space")

        case .error:
            appModel.immersiveSpaceState = .closed
            print("❌ Failed to open immersive space")

        @unknown default:
            appModel.immersiveSpaceState = .closed
            print("❌ Unknown immersive space result")
        }
    }
}
