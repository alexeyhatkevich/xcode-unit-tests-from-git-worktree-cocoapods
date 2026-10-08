import SwiftUI

@main
struct DemoApp: App {
    var body: some Scene {
        WindowGroup {
            VStack(spacing: 12) {
                Text("Project-level SWIFT_PACKAGE=1 demo").font(.headline)
                Text("The app builds. Now run the schemes:").font(.subheadline)
                Text("NaiveTests - fails to compile (inherits SWIFT_PACKAGE=1)")
                Text("FixedTests - passes (overrides the define)")
            }
            .padding()
        }
    }
}
