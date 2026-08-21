//
//  ContentView.swift
//  Brain Sticky
//
//  Created by Xiaojing Ji on 8/17/26.
//

import SwiftUI

struct ContentView: View {
    
    var body: some View {
        BentoDashboardView()
    }
}

#Preview {
    ContentView()
        .environmentObject(DataStore.shared)
        .environmentObject(BiometricAuthManager.shared)
}

