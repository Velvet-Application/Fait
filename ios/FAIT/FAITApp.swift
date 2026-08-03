import GoogleSignIn
import SwiftUI
import UIKit

final class FAITAppDelegate: NSObject, UIApplicationDelegate {
    func application(
        _ app: UIApplication,
        open url: URL,
        options: [UIApplication.OpenURLOptionsKey: Any] = [:]
    ) -> Bool {
        GIDSignIn.sharedInstance.handle(url)
    }
}

@main
struct FAITApp: App {
    @UIApplicationDelegateAdaptor(FAITAppDelegate.self) private var appDelegate
    @Environment(\.scenePhase) private var scenePhase
    @AppStorage("fait.hasCompletedOnboarding") private var hasCompletedOnboarding = false
    @StateObject private var environment = AppEnvironment()
    @StateObject private var integrations = NativeIntegrationController()
    @StateObject private var security = AppSecurityController()

    var body: some Scene {
        WindowGroup {
            ZStack {
                Group {
                    if hasCompletedOnboarding {
                        RootTabView()
                    } else {
                        OnboardingView {
                            hasCompletedOnboarding = true
                            integrations.publishWidgetSnapshot(from: environment)
                        }
                    }
                }
                .environmentObject(environment)
                .environmentObject(integrations)
                .environmentObject(security)
                .tint(FAITColor.trustGreen)

                if security.isLocked {
                    FAITLockScreen()
                        .environmentObject(security)
                        .transition(.opacity)
                        .zIndex(20)
                }
            }
            .animation(.easeInOut(duration: 0.2), value: security.isLocked)
            .task {
                integrations.publishWidgetSnapshot(from: environment)
                if security.faceIDEnabled {
                    security.lock()
                    await security.unlock()
                }
            }
            .onOpenURL { url in
                if GIDSignIn.sharedInstance.handle(url) { return }
                guard url.scheme == "fait" else { return }
                switch url.host {
                case "detected": environment.selectedTab = .detected
                case "cases": environment.selectedTab = .cases
                default: environment.selectedTab = .home
                }
            }
            .onChange(of: scenePhase) { _, newPhase in
                switch newPhase {
                case .background, .inactive:
                    security.lock()
                case .active:
                    if security.faceIDEnabled && security.isLocked {
                        Task { await security.unlock() }
                    }
                @unknown default:
                    break
                }
            }
        }
    }
}

private struct FAITLockScreen: View {
    @EnvironmentObject private var security: AppSecurityController

    var body: some View {
        ZStack {
            FAITBackground()
            VStack(spacing: 24) {
                BrandLockup(compact: false)
                Image(systemName: "faceid")
                    .font(.system(size: 54, weight: .medium))
                    .foregroundStyle(FAITColor.trustGreen)
                    .frame(width: 118, height: 118)
                    .background(FAITColor.softSage.opacity(0.22), in: Circle())
                VStack(spacing: 8) {
                    Text("FAIT. est verrouillé")
                        .font(.system(size: 30, weight: .bold, design: .rounded))
                        .foregroundStyle(FAITColor.oliveCharcoal)
                    Text("Vos dossiers, e-mails et rendez-vous restent protégés.")
                        .multilineTextAlignment(.center)
                        .foregroundStyle(.secondary)
                }
                Button {
                    Task { await security.unlock() }
                } label: {
                    Label("Déverrouiller avec \(security.biometricLabel)", systemImage: "faceid")
                }
                .buttonStyle(PrimaryActionButtonStyle())
                .padding(.horizontal, 28)
                if let error = security.lastError {
                    Text(error)
                        .font(.caption)
                        .foregroundStyle(Color.orange)
                        .multilineTextAlignment(.center)
                        .padding(.horizontal, 28)
                }
            }
        }
    }
}
