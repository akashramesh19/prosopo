//
//  ProsopoApp.swift
//  Prosopo
//
//  Created by Akash Ramesh on 22/9/2025.
//

import SwiftUI
import SwiftData
import FirebaseCore
import GoogleSignIn

/// Application delegate responsible for configuring Firebase and handling Google Sign-In callbacks.
class AppDelegate: NSObject, UIApplicationDelegate {
    func application(
        _ application: UIApplication,
        didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey : Any]? = nil
    ) -> Bool {
        FirebaseApp.configure()
        return true
    }

    func application(
        _ app: UIApplication,
        open url: URL,
        options: [UIApplication.OpenURLOptionsKey : Any] = [:]
    ) -> Bool {
        return GIDSignIn.sharedInstance.handle(url)
    }
}

/// Application entry point for Prosopo.
@main
struct ProsopoApp: App {
    @UIApplicationDelegateAdaptor(AppDelegate.self) var delegate
    @StateObject private var authVM = AuthViewModel()
    @StateObject private var copyManager = CopyManager()     

    var body: some Scene {
        WindowGroup {
            ZStack {
                Group {
                    if authVM.isAuthenticated {
                        HomeView()
                    } else {
                        AuthView()
                    }
                }
            }
            .environmentObject(authVM)
            .environmentObject(copyManager)
            .onOpenURL { url in copyManager.handle(url: url) }
            .overlay(alignment: .top) {
                if let name = copyManager.copiedName {
                    CopiedToast(text: "Copied: \(name)")
                        .transition(.move(edge: .top).combined(with: .opacity))
                        .zIndex(10)
                }
            }
        }
        .modelContainer(for: [DraftPersona.self])
    }
}
