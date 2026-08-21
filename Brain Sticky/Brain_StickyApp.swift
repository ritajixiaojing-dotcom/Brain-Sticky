//
//  Brain_StickyApp.swift
//  Brain Sticky
//
//  Created by Xiaojing Ji on 8/17/26.
//

import SwiftUI

@main
struct Brain_StickyApp: App {
    @Environment(\.scenePhase) private var scenePhase
    @StateObject private var store = DataStore.shared
    @StateObject private var authManager = BiometricAuthManager.shared
    
    init() {
        NotificationManager.shared.requestAuthorization()
    }

    var body: some Scene {
        WindowGroup {
            ContentView()
                .environmentObject(store)
                .environmentObject(authManager)
        }
        .onChange(of: scenePhase) { oldPhase, newPhase in
            if newPhase == .background {
                // Auto lock password vault on backgrounding
                authManager.lockVault()
            }
        }
    }
}