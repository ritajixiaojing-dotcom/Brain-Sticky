//
//  MindOSModels.swift
//  Brain Sticky
//
//  Created for Brain Sticky - Personal Second Brain Super App.
//

import Foundation
import SwiftUI

// MARK: - 极简双字分区
public enum OmniCategory: String, Codable, CaseIterable, Identifiable {
    case urgentTodo = "待办"
    case stickyNote = "日常"
    case passwordVault = "密码"
    case grocery = "买菜"
    case wishlist = "剁手"
    
    public var id: String { rawValue }
    
    public var icon: String {
        switch self {
        case .urgentTodo: return "checklist"
        case .stickyNote: return "sparkles"
        case .passwordVault: return "lock.fill"
        case .grocery: return "cart.fill"
        case .wishlist: return "gift.fill"
        }
    }
    
    public var themeColor: Color {
        switch self {
        case .urgentTodo: return BentoColors.urgentCoral
        case .stickyNote: return BentoColors.noteAmber
        case .passwordVault: return BentoColors.vaultViolet
        case .grocery: return BentoColors.groceryMint
        case .wishlist: return BentoColors.wishlistRuby
        }
    }
}

// MARK: - 1. 待办 (Todos)
public enum TodoPriority: String, Codable, CaseIterable {
    case urgent = "紧急"
    case normal = "日常"
    case someday = "随缘"
    
    public var color: Color {
        switch self {
        case .urgent: return BentoColors.urgentCoral
        case .normal: return BentoColors.noteAmber
        case .someday: return BentoColors.omniElectric
        }
    }
    
    public func localized(lang: AppLanguage = AppLanguageManager.shared.currentLanguage) -> String {
        switch self {
        case .urgent: return lang == .chinese ? "紧急" : "Urgent"
        case .normal: return lang == .chinese ? "日常" : "Normal"
        case .someday: return lang == .chinese ? "随缘" : "Someday"
        }
    }
}

public struct TodoItem: Identifiable, Codable, Hashable {
    public var id: UUID
    public var title: String
    public var isCompleted: Bool
    public var dueDate: Date?
    public var priority: TodoPriority
    public var reminderMinutes: Int?
    public var createdAt: Date
    
    public init(
        id: UUID = UUID(),
        title: String,
        isCompleted: Bool = false,
        dueDate: Date? = nil,
        priority: TodoPriority = .normal,
        reminderMinutes: Int? = nil,
        createdAt: Date = Date()
    ) {
        self.id = id
        self.title = title
        self.isCompleted = isCompleted
        self.dueDate = dueDate
        self.priority = priority
        self.reminderMinutes = reminderMinutes
        self.createdAt = createdAt
    }
}

// MARK: - 2. 点滴 (Moments & Drops)
public struct StickyNoteItem: Identifiable, Codable, Hashable {
    public var id: UUID
    public var content: String
    public var moodEmoji: String
    public var colorHex: String
    public var isPinned: Bool
    public var isEphemeral: Bool
    public var createdAt: Date
    
    public init(
        id: UUID = UUID(),
        content: String,
        moodEmoji: String = "💡",
        colorHex: String = "#FFF7D1",
        isPinned: Bool = false,
        isEphemeral: Bool = false,
        createdAt: Date = Date()
    ) {
        self.id = id
        self.content = content
        self.moodEmoji = moodEmoji
        self.colorHex = colorHex
        self.isPinned = isPinned
        self.isEphemeral = isEphemeral
        self.createdAt = createdAt
    }
}

// MARK: - 3. 密码 (Vault)
public enum VaultCategory: String, Codable, CaseIterable, Identifiable {
    case drop = "日常"
    case custom = "密码"
    
    public var id: String { rawValue }
    
    public var icon: String {
        switch self {
        case .drop: return "sparkles"
        case .custom: return "key.fill"
        }
    }
    
    public var defaultAccountLabel: String { "备注说明" }
    public var defaultSecretLabel: String { "密码" }
}

public struct VaultItem: Identifiable, Codable, Hashable {
    public var id: UUID
    public var title: String
    public var category: VaultCategory
    public var accountOrKey: String
    public var secretValue: String
    public var notes: String
    public var updatedAt: Date
    public var isMasked: Bool
    
    public init(
        id: UUID = UUID(),
        title: String,
        category: VaultCategory = .custom,
        accountOrKey: String = "",
        secretValue: String,
        notes: String = "",
        updatedAt: Date = Date(),
        isMasked: Bool = false
    ) {
        self.id = id
        self.title = title
        self.category = category
        self.accountOrKey = accountOrKey
        self.secretValue = secretValue
        self.notes = notes
        self.updatedAt = updatedAt
        self.isMasked = isMasked
    }
}

// MARK: - 4. 买菜 (Grocery)
public enum GroceryAisle: String, Codable, CaseIterable, Identifiable {
    case produce = "果蔬"
    case meat = "肉禽"
    case dairy = "乳品"
    case snacks = "零食"
    case essentials = "粮油"
    case daily = "百货"
    case others = "其他"
    
    public var id: String { rawValue }
    
    public var icon: String {
        switch self {
        case .produce: return "🥬"
        case .meat: return "🥩"
        case .dairy: return "🥛"
        case .snacks: return "🍿"
        case .essentials: return "🌾"
        case .daily: return "🧴"
        case .others: return "📦"
        }
    }
    
    public var cuteTitle: String {
        "\(icon) \(localized())"
    }
    
    public func localized(lang: AppLanguage = AppLanguageManager.shared.currentLanguage) -> String {
        switch self {
        case .produce: return lang == .chinese ? "果蔬" : "Produce"
        case .meat: return lang == .chinese ? "肉禽" : "Meat"
        case .dairy: return lang == .chinese ? "乳品" : "Dairy"
        case .snacks: return lang == .chinese ? "零食" : "Snacks"
        case .essentials: return lang == .chinese ? "粮油" : "Pantry"
        case .daily: return lang == .chinese ? "百货" : "Daily"
        case .others: return lang == .chinese ? "其他" : "Other"
        }
    }
}

public struct GroceryItem: Identifiable, Codable, Hashable {
    public var id: UUID
    public var name: String
    public var aisle: GroceryAisle
    public var quantity: String
    public var isBought: Bool
    public var isFrequent: Bool
    public var createdAt: Date
    
    public init(
        id: UUID = UUID(),
        name: String,
        aisle: GroceryAisle = .others,
        quantity: String = "1",
        isBought: Bool = false,
        isFrequent: Bool = false,
        createdAt: Date = Date()
    ) {
        self.id = id
        self.name = name
        self.aisle = aisle
        self.quantity = quantity
        self.isBought = isBought
        self.isFrequent = isFrequent
        self.createdAt = createdAt
    }
}

// MARK: - 5. 心愿 / 剁手 (Wishlist & Currencies)
public enum WishlistCurrency: String, Codable, CaseIterable, Identifiable {
    case cny = "¥" // 元
    case usd = "$" // 美元
    case jpy = "円" // 日币
    case eur = "€" // 欧元
    
    public var id: String { rawValue }
    
    public var name: String {
        switch self {
        case .cny: return AppLanguageManager.shared.currentLanguage == .chinese ? "元" : "CNY"
        case .usd: return AppLanguageManager.shared.currentLanguage == .chinese ? "美元" : "USD"
        case .jpy: return AppLanguageManager.shared.currentLanguage == .chinese ? "日币" : "JPY"
        case .eur: return AppLanguageManager.shared.currentLanguage == .chinese ? "欧元" : "EUR"
        }
    }
    
    public var symbol: String { rawValue }
    
    public func formatted(_ price: Double) -> String {
        if self == .jpy {
            return String(format: "%.0f 円", price)
        } else {
            return String(format: "%@%.0f", symbol, price)
        }
    }
    
    public static func fromSymbol(_ symbol: String) -> WishlistCurrency {
        switch symbol {
        case "$", "USD": return .usd
        case "円", "JPY", "JP¥": return .jpy
        case "€", "EUR": return .eur
        default: return .cny
        }
    }
}

public struct WishlistItem: Identifiable, Codable, Hashable {
    public var id: UUID
    public var title: String
    public var targetPrice: Double
    public var currency: String
    public var coolOffDaysTotal: Int
    public var coolOffStartDate: Date
    public var notes: String
    public var buyUrl: String
    public var isPurchased: Bool
    public var isAbandoned: Bool
    public var category: String
    
    public init(
        id: UUID = UUID(),
        title: String,
        targetPrice: Double = 0.0,
        currency: String = "¥",
        coolOffDaysTotal: Int = 14,
        coolOffStartDate: Date = Date(),
        notes: String = "",
        buyUrl: String = "",
        isPurchased: Bool = false,
        isAbandoned: Bool = false,
        category: String = "好物"
    ) {
        self.id = id
        self.title = title
        self.targetPrice = targetPrice
        self.currency = currency
        self.coolOffDaysTotal = coolOffDaysTotal
        self.coolOffStartDate = coolOffStartDate
        self.notes = notes
        self.buyUrl = buyUrl
        self.isPurchased = isPurchased
        self.isAbandoned = isAbandoned
        self.category = category
    }
    
    enum CodingKeys: String, CodingKey {
        case id, title, targetPrice, currency, coolOffDaysTotal, coolOffStartDate, notes, buyUrl, isPurchased, isAbandoned, category
    }
    
    public init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        self.id = try container.decodeIfPresent(UUID.self, forKey: .id) ?? UUID()
        self.title = try container.decodeIfPresent(String.self, forKey: .title) ?? ""
        self.targetPrice = try container.decodeIfPresent(Double.self, forKey: .targetPrice) ?? 0.0
        self.currency = try container.decodeIfPresent(String.self, forKey: .currency) ?? "¥"
        self.coolOffDaysTotal = try container.decodeIfPresent(Int.self, forKey: .coolOffDaysTotal) ?? 14
        self.coolOffStartDate = try container.decodeIfPresent(Date.self, forKey: .coolOffStartDate) ?? Date()
        self.notes = try container.decodeIfPresent(String.self, forKey: .notes) ?? ""
        self.buyUrl = try container.decodeIfPresent(String.self, forKey: .buyUrl) ?? ""
        self.isPurchased = try container.decodeIfPresent(Bool.self, forKey: .isPurchased) ?? false
        self.isAbandoned = try container.decodeIfPresent(Bool.self, forKey: .isAbandoned) ?? false
        self.category = try container.decodeIfPresent(String.self, forKey: .category) ?? "好物"
    }
    
    public var daysRemaining: Int {
        if coolOffDaysTotal >= 9999 { return 9999 }
        let calendar = Calendar.current
        let elapsed = calendar.dateComponents([.day], from: coolOffStartDate, to: Date()).day ?? 0
        let remaining = coolOffDaysTotal - elapsed
        return max(0, remaining)
    }
    
    public var coolOffProgress: Double {
        guard coolOffDaysTotal > 0 else { return 1.0 }
        let calendar = Calendar.current
        let elapsed = calendar.dateComponents([.day], from: coolOffStartDate, to: Date()).day ?? 0
        return min(1.0, max(0.0, Double(elapsed) / Double(coolOffDaysTotal)))
    }
}

// MARK: - 6. 自定义功能模块 (Custom Modular Cards)
public struct CustomEntryItem: Identifiable, Codable, Hashable {
    public var id: UUID
    public var title: String
    public var icon: String // 每个打卡项独立的专属 Icon
    public var detail: String
    public var isCompleted: Bool
    public var targetDate: Date?
    public var count: Int
    public var createdAt: Date
    
    public init(
        id: UUID = UUID(),
        title: String,
        icon: String = "🎯",
        detail: String = "",
        isCompleted: Bool = false,
        targetDate: Date? = nil,
        count: Int = 0,
        createdAt: Date = Date()
    ) {
        self.id = id
        self.title = title
        self.icon = (icon.isEmpty || icon == "🎯") ? CustomEntryItem.suggestIcon(for: title) : icon
        self.detail = detail
        self.isCompleted = isCompleted
        self.targetDate = targetDate
        self.count = count
        self.createdAt = createdAt
    }
    
    enum CodingKeys: String, CodingKey {
        case id, title, icon, detail, isCompleted, targetDate, count, createdAt
    }
    
    public init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        self.id = try container.decodeIfPresent(UUID.self, forKey: .id) ?? UUID()
        self.title = try container.decodeIfPresent(String.self, forKey: .title) ?? ""
        let decodedIcon = try container.decodeIfPresent(String.self, forKey: .icon)
        self.icon = (decodedIcon == nil || decodedIcon!.isEmpty) ? CustomEntryItem.suggestIcon(for: self.title) : decodedIcon!
        self.detail = try container.decodeIfPresent(String.self, forKey: .detail) ?? ""
        self.isCompleted = try container.decodeIfPresent(Bool.self, forKey: .isCompleted) ?? false
        self.targetDate = try container.decodeIfPresent(Date.self, forKey: .targetDate)
        self.count = try container.decodeIfPresent(Int.self, forKey: .count) ?? 0
        self.createdAt = try container.decodeIfPresent(Date.self, forKey: .createdAt) ?? Date()
    }
    
    public static func suggestIcon(for text: String) -> String {
        let lower = text.lowercased()
        if lower.contains("水") || lower.contains("water") || lower.contains("drink") { return "💧" }
        if lower.contains("书") || lower.contains("读") || lower.contains("read") || lower.contains("book") { return "📖" }
        if lower.contains("跑") || lower.contains("run") || lower.contains("运动") || lower.contains("练") || lower.contains("gym") || lower.contains("健身") { return "🏃" }
        if lower.contains("睡") || lower.contains("sleep") || lower.contains("晚安") || lower.contains("早起") || lower.contains("起") { return "🌙" }
        if lower.contains("多邻国") || lower.contains("duolingo") || lower.contains("鸟") { return "🦉" }
        if lower.contains("词") || lower.contains("背") || lower.contains("学") || lower.contains("study") || lower.contains("英") || lower.contains("语") { return "🦉" }
        if lower.contains("药") || lower.contains("维生素") || lower.contains("pill") { return "💊" }
        if lower.contains("咖啡") || lower.contains("茶") || lower.contains("tea") || lower.contains("coffee") { return "☕️" }
        if lower.contains("钱") || lower.contains("存") || lower.contains("薪") || lower.contains("pay") || lower.contains("理财") { return "💰" }
        if lower.contains("娃") || lower.contains("宝") || lower.contains("儿") || lower.contains("孩") || lower.contains("baby") || lower.contains("kid") { return "👶" }
        if lower.contains("猫") || lower.contains("狗") || lower.contains("宠") || lower.contains("pet") { return "🐾" }
        if lower.contains("生") || lower.contains("日") || lower.contains("birthday") || lower.contains("party") { return "🎂" }
        if lower.contains("冥想") || lower.contains("放") || lower.contains("瑜伽") { return "🧘" }
        if lower.contains("家") || lower.contains("饭") || lower.contains("做饭") || lower.contains("厨") || lower.contains("餐") { return "🍳" }
        if lower.contains("果") || lower.contains("蔬") || lower.contains("沙拉") || lower.contains("eat") { return "🍎" }
        if lower.contains("琴") || lower.contains("乐") || lower.contains("歌") { return "🎸" }
        if lower.contains("行") || lower.contains("飞") || lower.contains("游") || lower.contains("travel") { return "✈️" }
        if lower.contains("恋") || lower.contains("爱") || lower.contains("纪念") || lower.contains("love") { return "❤️" }
        if lower.contains("洁") || lower.contains("扫") || lower.contains("家务") || lower.contains("整") { return "🧹" }
        if lower.contains("山") || lower.contains("海") || lower.contains("爬") || lower.contains("锻炼") { return "⛰️" }
        if lower.contains("骑") || lower.contains("车") || lower.contains("bike") { return "🚴" }
        return "🎯"
    }
    
    public var daysUntilTarget: Int? {
        guard let targetDate = targetDate else { return nil }
        let calendar = Calendar.current
        let start = calendar.startOfDay(for: Date())
        let end = calendar.startOfDay(for: targetDate)
        return calendar.dateComponents([.day], from: start, to: end).day
    }
}

public struct CustomModuleCard: Identifiable, Codable, Hashable {
    public var id: String // "custom_1", "custom_2"
    public var title: String // e.g. "打卡", "倒数"
    public var icon: String // "🎯", "⏳", "💧", "📚", etc.
    public var colorHex: String
    public var entries: [CustomEntryItem]
    public var mode: String // "checkin" | "countdown" | "general"
    
    public init(
        id: String,
        title: String,
        icon: String = "🎯",
        colorHex: String = "#E0F2FE",
        entries: [CustomEntryItem] = [],
        mode: String = "checkin"
    ) {
        self.id = id
        self.title = title
        self.icon = icon
        self.colorHex = colorHex
        self.entries = entries
        self.mode = mode
    }
}

public struct CustomPresetItem: Identifiable, Codable, Hashable {
    public var id: UUID
    public var icon: String
    public var name: String
    public var label: String
    public var defaultDetail: String
    
    public init(id: UUID = UUID(), icon: String, name: String, label: String, defaultDetail: String = "") {
        self.id = id
        self.icon = icon
        self.name = name
        self.label = label
        self.defaultDetail = defaultDetail
    }
}