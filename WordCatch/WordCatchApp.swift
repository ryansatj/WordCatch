//
//  WordCatchApp.swift
//  WordCatch
//
//  Created by Ryan Tjendana on 26/05/26.
//

import SwiftUI
import UIKit

@main
struct WordCatchApp: App {
    @UIApplicationDelegateAdaptor(AppDelegate.self) private var appDelegate

    @AppStorage("hasSeenOnboarding")
    private var hasSeenOnboarding = false

    var body: some Scene {
        WindowGroup {

            if hasSeenOnboarding {

                ContentView()
                    .preferredColorScheme(.light)

            } else {

                OnboardingScreen {
                    hasSeenOnboarding = true
                }
                .preferredColorScheme(.light)
            }
        }
    }
}

final class AppDelegate: NSObject, UIApplicationDelegate {
    func application(_ application: UIApplication,
                     supportedInterfaceOrientationsFor window: UIWindow?) -> UIInterfaceOrientationMask {
        OrientationManager.shared.mask
    }
}
