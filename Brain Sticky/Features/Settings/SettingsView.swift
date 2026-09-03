//
//  SettingsView.swift
//  Brain Sticky
//
//  Created for Brain Sticky - Personal Second Brain Super App.
//

import SwiftUI
import UserNotifications

public struct SettingsView: View {
    @Environment(\.dismiss) private var dismiss
    @ObservedObject var store = DataStore.shared
    @ObservedObject var authManager = BiometricAuthManager.shared
    @ObservedObject var langManager = AppLanguageManager.shared
    
    @AppStorage("enableHaptics") private var enableHaptics: Bool = true
    @AppStorage("enableTimerVibration") private var enableTimerVibration: Bool = true
    @AppStorage("autoLockVaultOnBackground") private var autoLockOnBackground: Bool = true
    @State private var isShowingResetAlert: Bool = false
    @State private var notificationStatus: UNAuthorizationStatus = .authorized
    
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
                
                // MARK: - 触感与到期震动提醒 (单开关极简设计)
                Section(header: Text(langManager.currentLanguage == .chinese ? "触感与到期提醒" : "Haptics & Alerts").font(.system(size: 11, weight: .bold, design: .rounded))) {
                    Toggle(isOn: Binding(
                        get: { enableHaptics },
                        set: { newVal in
                            enableHaptics = newVal
                            enableTimerVibration = newVal
                        }
                    )) {
                        HStack(spacing: 10) {
                            Image(systemName: "iphone.radiowaves.left.and.right")
                                .foregroundColor(BentoColors.urgentCoral)
                            VStack(alignment: .leading, spacing: 2) {
                                Text(langManager.currentLanguage == .chinese ? "触感与到期震动提醒" : "Haptics & Timer Vibration")
                                    .font(.system(size: 14, weight: .medium, design: .rounded))
                                Text(langManager.currentLanguage == .chinese ? "包含按键触觉反馈与待办定时到期震动报警" : "Includes button tap feedback and timer alert vibration")
                                    .font(.system(size: 11, design: .rounded))
                                    .foregroundColor(.secondary)
                            }
                        }
                    }
                    
                    if notificationStatus == .denied {
                        Button(action: {
                            if let url = URL(string: UIApplication.openSettingsURLString) {
                                UIApplication.shared.open(url)
                            }
                        }) {
                            HStack(spacing: 8) {
                                Image(systemName: "exclamationmark.triangle.fill")
                                    .foregroundColor(.orange)
                                VStack(alignment: .leading, spacing: 2) {
                                    Text(langManager.currentLanguage == .chinese ? "系统通知权限未开启" : "Notifications Disabled")
                                        .font(.system(size: 13, weight: .semibold, design: .rounded))
                                        .foregroundColor(.orange)
                                    Text(langManager.currentLanguage == .chinese ? "轻点前往系统设置开启，否则时间到了无法收到通知" : "Tap to enable in Settings to receive alerts")
                                        .font(.system(size: 11, design: .rounded))
                                        .foregroundColor(.secondary)
                                }
                                Spacer()
                                Image(systemName: "chevron.right")
                                    .font(.system(size: 11))
                                    .foregroundColor(.secondary)
                            }
                        }
                    }
                }
                
                Section(header: Text(langManager.localized(.dataHeader)).font(.system(size: 11, weight: .bold, design: .rounded))) {
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
                        Text("1.2.3 (Build 1)")
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
            .onAppear {
                UNUserNotificationCenter.current().getNotificationSettings { settings in
                    DispatchQueue.main.async {
                        self.notificationStatus = settings.authorizationStatus
                    }
                }
            }
        }
    }
}