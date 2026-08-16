import SwiftUI

@main
struct TestApp: App {
    @State private var appModel = AppModel()
    @State private var immersionStyle: ImmersionStyle = .full
    
    var body: some Scene {
        WindowGroup {
            ContentView()
                .environment(appModel)
        }
        
        ImmersiveSpace(id: appModel.immersiveSpaceID) {
                ImmersiveView()
                    .environment(appModel)
                    .onAppear {
                        appModel.immersiveSpaceState = .open
                    }
                    .onDisappear {
                        appModel.immersiveSpaceState = .closed
                    }
            }
            .immersionStyle(selection: $immersionStyle, in: .full)
        }
    }

