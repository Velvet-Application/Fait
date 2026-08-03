import SwiftUI

@main
struct FAITApp: App {
    @AppStorage("fait.hasCompletedOnboarding") private var hasCompletedOnboarding = false
    @StateObject private var environment = AppEnvironment()

    var body: some Scene {
        WindowGroup {
            Group {
                if hasCompletedOnboarding {
                    RootTabView()
                } else {
                    OnboardingView {
                        hasCompletedOnboarding = true
                    }
                }
            }
            .environmentObject(environment)
            .tint(FAITColor.trustGreen)
        }
    }
}
