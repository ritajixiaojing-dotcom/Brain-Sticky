//
//  SettingsView.swift
//  Brain Sticky
//
//  Created for Brain Sticky - Personal Second Brain Super App.
//

import SwiftUI

public struct SettingsView: View {
    @Environment(\.dismiss) private var dismiss
    @ObservedObject var store = DataStore.shared
    @ObservedObject var authManager = BiometricAuthManager.shared
    @ObservedObject var langManager = AppLanguageManager.shared
    
    @AppStorage("enableHaptics") private var enableHaptics: Bool = true
    @AppStorage("autoLockVaultOnBackground") private var autoLockOnBackground: Bool = true
    @State private var isShowingResetAlert: Bool = false
    
    public var body: some View {
        NavigationStack {
            List {
                // MARK: - 语言切换 (Language Switcher)
                Section(header: Text(langManager.localized(.languageHeader)).font(.system(size: 11, weight: .bold, design: .rounded))) {
                    Picker("Language", selection: $langManager.currentLanguage) {
                        ForEach(AppLanguage.allCases) { lang in
                            Text(lang.displayName).tag(lang)
                        }
                    }
                    .pickerStyle(.segmented)
                    .listRowInsets(EdgeInsets(top: 8, leading: 14, bottom: 8, trailing: 14))
                }
                
                // MARK: - 触感反馈 (Haptics)
                
                Section(header: Text(langManager.localized(.hapticsHeader)).font(.system(size: 11, weight: .bold, design: .rounded))) {
                    Toggle(isOn: $enableHaptics) {
                        HStack {
                            Image(systemName: "hand.tap.fill")
                                .foregroundColor(BentoColors.noteAmber)
                            Text(langManager.localized(.hapticsFeedback))
                                .font(.system(size: 14, weight: .medium, design: .rounded))
                        }
                    }
                }
                
                Section(header: Text(langManager.localized(.dataHeader)).font(.system(size: 11, weight: .bold, design: .rounded))) {
                    Button(action: {
                        store.seedSampleData()
                        HapticManager.shared.notification(.success)
                    }) {
                        HStack {
                            Image(systemName: "arrow.clockwise.circle")
                                .foregroundColor(BentoColors.omniElectric)
                            Text(langManager.localized(.resetData))
                                .font(.system(size: 14, weight: .medium, design: .rounded))
                        }
                    }
                    
                    Button(role: .destructive, action: { isShowingResetAlert = true }) {
                        HStack {
                            Image(systemName: "trash")
                            Text(langManager.localized(.clearAllData))
                                .font(.system(size: 14, weight: .medium, design: .rounded))
                        }
                    }
                }
                
                Section(header: Text(langManager.localized(.aboutHeader)).font(.system(size: 11, weight: .bold, design: .rounded))) {
                    HStack {
                        Text(langManager.localized(.version))
                            .font(.system(size: 14, weight: .medium, design: .rounded))
                        Spacer()
                        Text("1.1.0 (Build 2)")
                            .font(.system(size: 13, design: .rounded))
                            .foregroundColor(.secondary)
                    }
                    
                    VStack(alignment: .leading, spacing: 6) {
                        Text(langManager.localized(.offlinePrivacyTitle))
                            .font(.system(size: 12, weight: .bold, design: .rounded))
                        Text(langManager.localized(.offlinePrivacyBody))
                            .font(.system(size: 11, design: .rounded))
                            .foregroundColor(.secondary)
                    }
                    .padding(.vertical, 3)
                }
            }
            .listStyle(.insetGrouped)
            .navigationTitle(langManager.localized(.settingsTitle))
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button(langManager.localized(.done)) { dismiss() }
                        .font(.system(size: 15, weight: .medium))
                }
            }
            .alert(isPresented: $isShowingResetAlert) {
                Alert(
                    title: Text(langManager.currentLanguage == .chinese ? "确定清空全部数据？" : "Clear all MindOS data?"),
                    message: Text(langManager.currentLanguage == .chinese ? "此操作将清空所有待办、日常、密码、买菜、剁手与打卡记录，并恢复纯净状态。" : "This will permanently clear all your todos, notes, passwords, grocery, wishlist, and check-in items."),
                    primaryButton: .destructive(Text(langManager.currentLanguage == .chinese ? "确认清空" : "Clear All")) {
                        store.clearAllData()
                    },
                    secondaryButton: .cancel(Text(langManager.localized(.cancel)))
                )
            }
        }
    }
}