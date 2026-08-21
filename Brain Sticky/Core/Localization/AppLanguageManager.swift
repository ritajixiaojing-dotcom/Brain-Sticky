//
//  AppLanguageManager.swift
//  Brain Sticky
//
//  Created for Brain Sticky - Personal Second Brain Super App.
//

import SwiftUI
import Combine

public enum AppLanguage: String, CaseIterable, Identifiable {
    case chinese = "zh"
    case english = "en"
    
    public var id: String { rawValue }
    
    public var displayName: String {
        switch self {
        case .chinese: return "🇨🇳 简体中文"
        case .english: return "🇺🇸 English"
        }
    }
}

public class AppLanguageManager: ObservableObject {
    public typealias AppLanguage = Brain_Sticky.AppLanguage
    public static let shared = AppLanguageManager()
    
    private let languageKey = "app_selected_language"
    
    @Published public var currentLanguage: AppLanguage {
        didSet {
            UserDefaults.standard.set(currentLanguage.rawValue, forKey: languageKey)
            HapticManager.shared.notification(.success)
        }
    }
    
    private init() {
        let saved = UserDefaults.standard.string(forKey: languageKey) ?? "zh"
        self.currentLanguage = AppLanguage(rawValue: saved) ?? .chinese
    }
    
    public func localized(_ key: LocalizedKey) -> String {
        switch currentLanguage {
        case .chinese:
            return key.chineseValue
        case .english:
            return key.englishValue
        }
    }
}

public enum LocalizedKey {
    // Header & Dashboard
    case appName
    case appSubtitle
    case searchPlaceholder
    case captureDropButton
    case cloudsCount(Int)
    
    // Bento Modules
    case todoTitle
    case dropsTitle
    case vaultTitle
    case groceryTitle
    case wishlistTitle
    case habitTitle
    
    // Empty states
    case emptyTodo
    case emptyDrops
    case emptyVault
    case emptyGrocery
    case emptyWishlist
    case emptyHabit
    case statusCompleted
    case statusPending
    
    // Wishlist Inner
    case tabCooling
    case tabPurchased
    case tabAbandoned
    case totalBudget
    case savedBudget
    case itemsCount(Int)
    case buyAction
    case giveUpAction
    case restoreAction
    case ownedBadge
    case abandonedBadge
    
    // Settings
    case settingsTitle
    case languageHeader
    case securityHeader
    case hapticsHeader
    case dataHeader
    case aboutHeader
    case biometricGuard(String)
    case biometricActive
    case autoLockBackground
    case hapticsFeedback
    case resetData
    case clearAllData
    case version
    case offlinePrivacyTitle
    case offlinePrivacyBody
    case done
    case cancel
    case save
    
    var chineseValue: String {
        switch self {
        case .appName: return "脑雾收集站"
        case .appSubtitle: return "今天也把所有琐事交给我吧"
        case .searchPlaceholder: return "搜索脑雾与灵感..."
        case .captureDropButton: return "收集点滴 🫧"
        case .cloudsCount(let n): return "\(n) 朵"
            
        case .todoTitle: return "待办"
        case .dropsTitle: return "日常"
        case .vaultTitle: return "密码"
        case .groceryTitle: return "买菜"
        case .wishlistTitle: return "剁手"
        case .habitTitle: return "打卡"
            
        case .emptyTodo: return "脑袋放空，今天超棒 ✨"
        case .emptyDrops: return "写下此刻的想法..."
        case .emptyVault: return "钥匙密码已妥善安放 🔒"
        case .emptyGrocery: return "冰箱满满当当 🥕"
        case .emptyWishlist: return "心如止水，钱包保住啦 🧸"
        case .emptyHabit: return "点击添加习惯\n如 🏃 跑步 · 💧 喝水 ✨"
        case .statusCompleted: return "已完成"
        case .statusPending: return "待打卡"
            
        case .tabCooling: return "冷静 ⏳"
        case .tabPurchased: return "已买 🛍️"
        case .tabAbandoned: return "已放弃 🗑️"
        case .totalBudget: return "总额"
        case .savedBudget: return "已省下"
        case .itemsCount(let n): return "\(n)件"
        case .buyAction: return "买下 ✨"
        case .giveUpAction: return "放弃 🗑️"
        case .restoreAction: return "放回冷静 ♻️"
        case .ownedBadge: return "已拥有 ✨"
        case .abandonedBadge: return "已省钱 🍃"
            
        case .settingsTitle: return "设置与偏好"
        case .languageHeader: return "语言设置 (Language)"
        case .securityHeader: return "安全与生物识别"
        case .hapticsHeader: return "触感与反馈"
        case .dataHeader: return "外脑数据"
        case .aboutHeader: return "关于 Brain Sticky & 隐私安全"
        case .biometricGuard(let name): return "\(name) 硬件守护"
        case .biometricActive: return "已激活"
        case .autoLockBackground: return "切出后台自动锁闭钥匙匣"
        case .hapticsFeedback: return "触觉震动反馈 (Haptics)"
        case .resetData: return "重置演示模板与示例卡片"
        case .clearAllData: return "清空全部外脑记录"
        case .version: return "版本"
        case .offlinePrivacyTitle: return "🔒 100% 离线隐私架构"
        case .offlinePrivacyBody: return "Brain Sticky 秉持纯端侧极简原则，不设立任何中心化数据收集服务器。您的钥匙密码盒经由苹果安全芯片（Secure Enclave）加密存储，完全离线可用。"
        case .done: return "完成"
        case .cancel: return "取消"
        case .save: return "保存"
        }
    }
    
    var englishValue: String {
        switch self {
        case .appName: return "Brain Sticky"
        case .appSubtitle: return "Leave all the little chores to me today"
        case .searchPlaceholder: return "Search brain fog & notes..."
        case .captureDropButton: return "Capture Drop 🫧"
        case .cloudsCount(let n): return "\(n) Clouds"
            
        case .todoTitle: return "Todo"
        case .dropsTitle: return "Drops"
        case .vaultTitle: return "Vault"
        case .groceryTitle: return "Market"
        case .wishlistTitle: return "Wishlist"
        case .habitTitle: return "Check-in"
            
        case .emptyTodo: return "Mind is clear, having a great day ✨"
        case .emptyDrops: return "Jot down your instant thoughts..."
        case .emptyVault: return "All passwords secured 🔒"
        case .emptyGrocery: return "Fridge is fully stocked 🥕"
        case .emptyWishlist: return "Peaceful mind, wallet saved 🧸"
        case .emptyHabit: return "Tap to add habits\ne.g. 🏃 Run · 💧 Water ✨"
        case .statusCompleted: return "Done"
        case .statusPending: return "Pending"
            
        case .tabCooling: return "Cooling ⏳"
        case .tabPurchased: return "Bought 🛍️"
        case .tabAbandoned: return "Passed 🗑️"
        case .totalBudget: return "Total"
        case .savedBudget: return "Saved"
        case .itemsCount(let n): return "\(n) items"
        case .buyAction: return "Buy ✨"
        case .giveUpAction: return "Pass 🗑️"
        case .restoreAction: return "Restore ♻️"
        case .ownedBadge: return "Owned ✨"
        case .abandonedBadge: return "Saved 🍃"
            
        case .settingsTitle: return "Settings & Preferences"
        case .languageHeader: return "Language"
        case .securityHeader: return "Security & Biometrics"
        case .hapticsHeader: return "Haptics & Feedback"
        case .dataHeader: return "MindOS Data"
        case .aboutHeader: return "About Brain Sticky & Privacy"
        case .biometricGuard(let name): return "\(name) Security Guard"
        case .biometricActive: return "Active"
        case .autoLockBackground: return "Auto-lock vault when backgrounded"
        case .hapticsFeedback: return "Haptic Feedback"
        case .resetData: return "Reset demo cards & templates"
        case .clearAllData: return "Clear all MindOS data"
        case .version: return "Version"
        case .offlinePrivacyTitle: return "🔒 100% Offline Privacy Architecture"
        case .offlinePrivacyBody: return "Brain Sticky is designed with zero cloud data collection. Your secrets and passwords are encrypted via Apple Secure Enclave and work 100% offline."
        case .done: return "Done"
        case .cancel: return "Cancel"
        case .save: return "Save"
        }
    }
}
