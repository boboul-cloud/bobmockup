//
//  BobmockupApp.swift
//  Bobmockup
//

import SwiftUI

@main
struct BobmockupApp: App {
    @AppStorage("hasCompletedOnboarding") private var hasCompletedOnboarding = false
    @AppStorage("appLanguage") private var appLanguage = "fr"

    /// L'intro n'est pas une barrière : l'accueil est monté sous elle
    /// dès la première image, et elle disparaît d'elle-même en 1 080 ms.
    @State private var launchFinished = false

    var body: some Scene {
        WindowGroup {
            ZStack {
                Group {
                    if hasCompletedOnboarding {
                        ContentView()
                            .environment(PurchaseManager.shared)
                            .environment(ProjectStore.shared)
                    } else {
                        OnboardingView(hasCompletedOnboarding: $hasCompletedOnboarding)
                    }
                }

                if !launchFinished {
                    LaunchRevealView(isFinished: $launchFinished)
                        .transition(.opacity)
                        .zIndex(10)
                }
            }
            .environment(\.locale, Locale(identifier: appLanguage))
            .tint(DS.Palette.safelight)
        }
    }
}
