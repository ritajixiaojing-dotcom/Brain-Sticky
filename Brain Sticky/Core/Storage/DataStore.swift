//
//  DataStore.swift
//  MindOS
//
//  Created for MindOS - Personal Second Brain Super App.
//

import Foundation
import SwiftUI
import Combine

@MainActor
public final class DataStore: ObservableObject {
    public static let shared = DataStore()
    
    // MARK: - State Collections
    @Published public var todos: [TodoItem] = [] { didSet { saveTodos() } }
    @Published public var stickyNotes: [StickyNoteItem] = [] { didSet { saveNotes() } }
    @Published public var vaultItems: [VaultItem] = [] { didSet { saveVault() } }
    @Published public var groceryItems: [GroceryItem] = [] { didSet { saveGrocery() } }
    @Published public var wishlistItems: [WishlistItem] = [] { didSet { saveWishlist() } }
    
    // Frequent grocery catalog for fast adding
    @Published public var frequentGroceryList: [GroceryItem] = [] { didSet { saveFrequentGrocery() } }
    
    // 2 个自定义模块 (2 Customizable Feature Modules)
    @Published public var customModules: [CustomModuleCard] = [] { didSet { saveCustomModules() } }
    
    // 用户自定义并保存的常用习惯预设 (User Custom Habit Presets for fast selection)
    @Published public var userCustomHabitPresets: [CustomPresetItem] = [] { didSet { saveCustomPresets() } }
    
    // Global filter/search
    @Published public var searchText: String = ""
    
    private let fileManager = FileManager.default
    private var documentsDirectory: URL {
        fileManager.urls(for: .documentDirectory, in: .userDomainMask)[0]
    }
    
    public init() {
        loadAll()
    }
    
    // MARK: - Dashboard Computed Metrics
    public var pendingUrgentTodosCount: Int {
        todos.filter { !$0.isCompleted && $0.priority == .urgent }.count
    }
    
    public var activeStickyNotesCount: Int {
        stickyNotes.count
    }
    
    public var vaultCount: Int {
        vaultItems.count
    }
    
    public var groceryPendingCount: Int {
        groceryItems.filter { !$0.isBought }.count
    }
    
    public var groceryCompletedRatio: Double {
        guard !groceryItems.isEmpty else { return 0.0 }
        let bought = Double(groceryItems.filter { $0.isBought }.count)
        return bought / Double(groceryItems.count)
    }
    
    public var totalActiveBrainLoadCount: Int {
        todos.filter { !$0.isCompleted }.count +
        stickyNotes.count +
        vaultItems.count +
        groceryItems.filter { !$0.isBought }.count +
        wishlistItems.filter { !$0.isPurchased }.count
    }
    
    // MARK: - CRUD: Todos
    public func addTodo(_ item: TodoItem) {
        todos.insert(item, at: 0)
        NotificationManager.shared.scheduleTodoReminder(item: item)
        HapticManager.shared.impact(.medium)
    }
    
    public func toggleTodo(_ item: TodoItem) {
        if let idx = todos.firstIndex(where: { $0.id == item.id }) {
            todos[idx].isCompleted.toggle()
            if todos[idx].isCompleted {
                NotificationManager.shared.cancelTodoReminder(id: item.id)
                HapticManager.shared.notification(.success)
            } else {
                HapticManager.shared.selection()
            }
        }
    }
    
    
    public func updateTodo(_ item: TodoItem) {
        if let idx = todos.firstIndex(where: { $0.id == item.id }) {
            todos[idx] = item
            NotificationManager.shared.cancelTodoReminder(id: item.id)
            if !item.isCompleted && item.reminderMinutes != nil {
                NotificationManager.shared.scheduleTodoReminder(item: item)
            }
        }
    }

    public func deleteTodo(id: UUID) {
        todos.removeAll { $0.id == id }
        NotificationManager.shared.cancelTodoReminder(id: id)
        HapticManager.shared.impact(.light)
    }
    
    // MARK: - CRUD: Sticky Notes
    public func addStickyNote(_ item: StickyNoteItem) {
        stickyNotes.insert(item, at: 0)
        HapticManager.shared.impact(.medium)
    }
    
    public func updateStickyNote(_ item: StickyNoteItem) {
        if let idx = stickyNotes.firstIndex(where: { $0.id == item.id }) {
            stickyNotes[idx] = item
        }
    }
    
    public func deleteStickyNote(id: UUID) {
        stickyNotes.removeAll { $0.id == id }
        HapticManager.shared.impact(.light)
    }
    
    // MARK: - CRUD: Vault
    public func addVaultItem(_ item: VaultItem) {
        vaultItems.insert(item, at: 0)
        HapticManager.shared.impact(.medium)
    }
    
    public func updateVaultItem(_ item: VaultItem) {
        if let idx = vaultItems.firstIndex(where: { $0.id == item.id }) {
            vaultItems[idx] = item
            vaultItems[idx].updatedAt = Date()
        }
    }
    
    public func deleteVaultItem(id: UUID) {
        vaultItems.removeAll { $0.id == id }
        HapticManager.shared.impact(.light)
    }
    
    // MARK: - CRUD: Grocery
    public func addGroceryItem(_ item: GroceryItem) {
        groceryItems.insert(item, at: 0)
        if item.isFrequent && !frequentGroceryList.contains(where: { $0.name == item.name }) {
            frequentGroceryList.append(item)
        }
        HapticManager.shared.impact(.light)
    }
    
    public func toggleGroceryItem(_ item: GroceryItem) {
        if let idx = groceryItems.firstIndex(where: { $0.id == item.id }) {
            groceryItems[idx].isBought.toggle()
            HapticManager.shared.selection()
        }
    }
    
    public func clearCompletedGrocery() {
        groceryItems.removeAll { $0.isBought }
        HapticManager.shared.notification(.success)
    }
    
    
    public func updateGroceryItem(_ item: GroceryItem) {
        if let idx = groceryItems.firstIndex(where: { $0.id == item.id }) {
            groceryItems[idx] = item
        }
        if item.isFrequent {
            addFrequentGrocery(item)
        } else {
            frequentGroceryList.removeAll { $0.name == item.name }
        }
    }

    public func deleteGroceryItem(id: UUID) {
        groceryItems.removeAll { $0.id == id }
        HapticManager.shared.impact(.light)
    }
    
    public func addFrequentGrocery(_ item: GroceryItem) {
        let trimmed = item.name.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !trimmed.isEmpty else { return }
        if !frequentGroceryList.contains(where: { $0.name.lowercased() == trimmed.lowercased() }) {
            var newItem = item
            newItem.name = trimmed
            newItem.isFrequent = true
            frequentGroceryList.insert(newItem, at: 0)
            HapticManager.shared.notification(.success)
        }
    }
    
    public func removeFrequentGrocery(id: UUID) {
        frequentGroceryList.removeAll { $0.id == id }
        HapticManager.shared.impact(.light)
    }
    
    public func toggleFrequentStatus(for item: GroceryItem) {
        if let idx = frequentGroceryList.firstIndex(where: { $0.name == item.name }) {
            frequentGroceryList.remove(at: idx)
        } else {
            var copy = item
            copy.isFrequent = true
            frequentGroceryList.append(copy)
        }
        HapticManager.shared.selection()
    }
    
    // MARK: - CRUD: Wishlist
    public func addWishlistItem(_ item: WishlistItem) {
        wishlistItems.insert(item, at: 0)
        NotificationManager.shared.scheduleWishlistCoolOffAlert(item: item)
        HapticManager.shared.impact(.medium)
    }
    
    public func toggleWishlistPurchased(_ item: WishlistItem) {
        if let idx = wishlistItems.firstIndex(where: { $0.id == item.id }) {
            wishlistItems[idx].isPurchased.toggle()
            HapticManager.shared.notification(.success)
        }
    }
    
    
    public func updateWishlistItem(_ item: WishlistItem) {
        if let idx = wishlistItems.firstIndex(where: { $0.id == item.id }) {
            wishlistItems[idx] = item
        }
    }

    public func abandonWishlistItem(id: UUID) {
        if let idx = wishlistItems.firstIndex(where: { $0.id == id }) {
            wishlistItems[idx].isAbandoned = true
            wishlistItems[idx].isPurchased = false
            saveWishlist()
            HapticManager.shared.notification(.warning)
        }
    }
    
    public func restoreWishlistItem(id: UUID) {
        if let idx = wishlistItems.firstIndex(where: { $0.id == id }) {
            wishlistItems[idx].isAbandoned = false
            saveWishlist()
            HapticManager.shared.notification(.success)
        }
    }

    public func deleteWishlistItem(id: UUID) {
        wishlistItems.removeAll { $0.id == id }
        HapticManager.shared.impact(.light)
    }
    
    // MARK: - CRUD: Custom Modules (自定义模块 1 & 2)
    public func updateCustomModule(_ module: CustomModuleCard) {
        if let idx = customModules.firstIndex(where: { $0.id == module.id }) {
            customModules[idx] = module
        } else {
            customModules.append(module)
        }
        HapticManager.shared.impact(.light)
    }
    
    public func addEntryToModule(moduleId: String, entry: CustomEntryItem) {
        if let idx = customModules.firstIndex(where: { $0.id == moduleId }) {
            if !customModules[idx].entries.contains(where: { $0.title == entry.title }) {
                customModules[idx].entries.insert(entry, at: 0)
                saveCustomModules()
                HapticManager.shared.notification(.success)
            }
        }
    }
    
    @discardableResult
    public func incrementEntryCountInModule(moduleId: String, entryId: UUID) -> (success: Bool, message: String?) {
        if let mIdx = customModules.firstIndex(where: { $0.id == moduleId }),
           let eIdx = customModules[mIdx].entries.firstIndex(where: { $0.id == entryId }) {
            var entry = customModules[mIdx].entries[eIdx]
            
            // 如果距离上次打卡已超过 24 小时，自动重置打卡状态，开启新一轮打卡周期
            if let last = entry.lastCheckedInAt, Date().timeIntervalSince(last) >= 24 * 3600 {
                entry.count = 0
                entry.isCompleted = false
            }
            
            // 如果今日已打卡（已完成打卡且在 24 小时内），则不可再次打卡，返回失败
            if (entry.isCompleted || entry.count >= 1) && entry.isWithin24Hours {
                HapticManager.shared.notification(.warning)
                return (false, nil)
            }
            
            entry.count = 1
            entry.isCompleted = true
            entry.lastCheckedInAt = Date()
            customModules[mIdx].entries[eIdx] = entry
            saveCustomModules()
            HapticManager.shared.notification(.success)
            return (true, nil)
        }
        return (false, nil)
    }
    
    public func toggleEntryInModule(moduleId: String, entryId: UUID) {
        incrementEntryCountInModule(moduleId: moduleId, entryId: entryId)
    }
    
    public func deleteEntryFromModule(moduleId: String, entryId: UUID) {
        if let mIdx = customModules.firstIndex(where: { $0.id == moduleId }) {
            customModules[mIdx].entries.removeAll { $0.id == entryId }
            HapticManager.shared.impact(.light)
        }
    }
    
    public func resetAllEntriesInModule(moduleId: String) {
        if let mIdx = customModules.firstIndex(where: { $0.id == moduleId }) {
            for i in 0..<customModules[mIdx].entries.count {
                customModules[mIdx].entries[i].isCompleted = false
                customModules[mIdx].entries[i].count = 0
            }
            HapticManager.shared.notification(.warning)
        }
    }
    
    public func clearAllEntriesInModule(moduleId: String) {
        if let mIdx = customModules.firstIndex(where: { $0.id == moduleId }) {
            customModules[mIdx].entries.removeAll()
            HapticManager.shared.notification(.warning)
        }
    }
    
    // 系统内置的常用习惯名称，用于严格去重，避免在“我的自定义打卡”中混入系统内置项目
    public static let builtinHabitNames: Set<String> = [
        "跑步", "喝水", "看书", "早睡", "多邻国", "吃药", "冥想", 
        "在家做饭", "在家吃饭", "记账", "耐心带娃", "照顾宠物", "整理房间", "锻炼身体", "咖啡茶饮",
        "打卡", "倒数", "自定义"
    ]
    
    // MARK: - Custom Habit Presets CRUD
    public func addCustomHabitPreset(name: String, icon: String, detail: String = "") {
        let cleanName = name.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !cleanName.isEmpty else { return }
        
        // 严格去重：如果该项目属于系统内置常用习惯，绝不重复添加至自定义打卡列表中！
        if DataStore.builtinHabitNames.contains(cleanName) {
            return
        }
        
        if let idx = userCustomHabitPresets.firstIndex(where: { $0.name == cleanName }) {
            userCustomHabitPresets[idx].icon = icon
            userCustomHabitPresets[idx].defaultDetail = detail
        } else {
            userCustomHabitPresets.insert(CustomPresetItem(icon: icon, name: cleanName, label: cleanName, defaultDetail: detail), at: 0)
        }
        saveCustomPresets()
        HapticManager.shared.notification(.success)
    }
    
    public func removeCustomHabitPreset(id: UUID) {
        userCustomHabitPresets.removeAll { $0.id == id }
        saveCustomPresets()
        HapticManager.shared.impact(.light)
    }
    
    // MARK: - Persistence Engine
    private func saveTodos() { save(todos, fileName: "todos.json") }
    private func saveNotes() { save(stickyNotes, fileName: "notes.json") }
    private func saveVault() { save(vaultItems, fileName: "vault.json") }
    private func saveGrocery() { save(groceryItems, fileName: "grocery.json") }
    private func saveFrequentGrocery() { save(frequentGroceryList, fileName: "frequent_grocery.json") }
    private func saveWishlist() { save(wishlistItems, fileName: "wishlist.json") }
    private func saveCustomModules() { save(customModules, fileName: "custom_modules.json") }
    private func saveCustomPresets() { save(userCustomHabitPresets, fileName: "custom_presets.json") }
    
    private func save<T: Encodable>(_ data: T, fileName: String) {
        let url = documentsDirectory.appendingPathComponent(fileName)
        do {
            let encoded = try JSONEncoder().encode(data)
            try encoded.write(to: url, options: .atomic)
        } catch {
            print("[DataStore] Failed to save \(fileName): \(error)")
        }
    }
    
    private func load<T: Decodable>(fileName: String) -> T? {
        let url = documentsDirectory.appendingPathComponent(fileName)
        guard fileManager.fileExists(atPath: url.path) else { return nil }
        do {
            let data = try Data(contentsOf: url)
            return try JSONDecoder().decode(T.self, from: data)
        } catch {
            print("[DataStore] Failed to load \(fileName): \(error)")
        }
        return nil
    }
    
    private func loadAll() {
        if let savedTodos: [TodoItem] = load(fileName: "todos.json") { todos = savedTodos }
        if let savedNotes: [StickyNoteItem] = load(fileName: "notes.json") { stickyNotes = savedNotes }
        if let savedVault: [VaultItem] = load(fileName: "vault.json") { vaultItems = savedVault }
        if let savedGrocery: [GroceryItem] = load(fileName: "grocery.json") { groceryItems = savedGrocery }
        if let savedFrequent: [GroceryItem] = load(fileName: "frequent_grocery.json") { frequentGroceryList = savedFrequent } else { frequentGroceryList = [] }
        if let savedWishlist: [WishlistItem] = load(fileName: "wishlist.json") { wishlistItems = savedWishlist }
        if let savedPresets: [CustomPresetItem] = load(fileName: "custom_presets.json") { userCustomHabitPresets = savedPresets }
        
        if let savedCustom: [CustomModuleCard] = load(fileName: "custom_modules.json") {
            customModules = savedCustom
        }
        // 初始化两个可自由定制的预设卡片 (打卡 & 倒数)
        if customModules.count < 2 {
            var modules = customModules
            if !modules.contains(where: { $0.id == "custom_1" }) {
                modules.append(CustomModuleCard(id: "custom_1", title: "打卡", icon: "🎯", colorHex: "#E0F2FE", entries: [], mode: "checkin"))
            }
            if !modules.contains(where: { $0.id == "custom_2" }) {
                modules.append(CustomModuleCard(id: "custom_2", title: "倒数", icon: "⏳", colorHex: "#FFE4E6", entries: [], mode: "countdown"))
            }
            customModules = modules
        }
        
        // 确保 custom_1 保持为「打卡」模块名称与🎯图标，如果误改成了钢琴等内容，自动转移至自定义习惯列表并恢复
        if let idx = customModules.firstIndex(where: { $0.id == "custom_1" }) {
            let currentTitle = customModules[idx].title
            let currentIcon = customModules[idx].icon
            if currentTitle != "打卡" && !currentTitle.isEmpty {
                // 将误设置的名称与图标加入到用户自定义打卡列表中
                addCustomHabitPreset(name: currentTitle, icon: currentIcon.isEmpty ? "🎯" : currentIcon)
                customModules[idx].title = "打卡"
                customModules[idx].icon = "🎯"
                saveCustomModules()
            }
        }
        
        // 严格清除自定义习惯列表中任何与内置常用图标重复的内容，避免重复出现
        userCustomHabitPresets.removeAll { DataStore.builtinHabitNames.contains($0.name) }
        
        // 彻底清空历史默认假数据，确保默认库存为 0
        if !UserDefaults.standard.bool(forKey: "has_cleared_frequent_defaults_v2") {
            frequentGroceryList = []
            saveFrequentGrocery()
            UserDefaults.standard.set(true, forKey: "has_cleared_frequent_defaults_v2")
        }
        
        // 彻底清空打卡模块历史项目，确保默认为 0 条，用户自主挑选后放进去列成一列
        if !UserDefaults.standard.bool(forKey: "has_cleared_all_custom_entries_v5") {
            for i in 0..<customModules.count {
                customModules[i].entries.removeAll()
            }
            saveCustomModules()
            UserDefaults.standard.set(true, forKey: "has_cleared_all_custom_entries_v5")
        }
        
        // 彻底纠正历史脏数据 what a day
        if let idx = customModules.firstIndex(where: { $0.id == "custom_1" }) {
            let current = customModules[idx].title.lowercased().trimmingCharacters(in: .whitespacesAndNewlines)
            if current == "what a day" || current == "whataday" {
                customModules[idx].title = "打卡"
                customModules[idx].icon = "🎯"
                saveCustomModules()
            }
        }
        
        // 自动去重打卡清单中的重复同名项目（保留最新状态）
        for i in 0..<customModules.count {
            var seenTitles = Set<String>()
            var uniqueEntries: [CustomEntryItem] = []
            for entry in customModules[i].entries {
                if !seenTitles.contains(entry.title) {
                    seenTitles.insert(entry.title)
                    uniqueEntries.append(entry)
                }
            }
            if uniqueEntries.count != customModules[i].entries.count {
                customModules[i].entries = uniqueEntries
                saveCustomModules()
            }
        }
    }
    
    public func clearAllFrequentGrocery() {
        frequentGroceryList.removeAll()
        HapticManager.shared.notification(.warning)
    }
    
    // MARK: - 全局清空所有数据（彻底重置为默认纯净状态）
    public func clearAllData() {
        todos.removeAll()
        stickyNotes.removeAll()
        vaultItems.removeAll()
        groceryItems.removeAll()
        frequentGroceryList.removeAll()
        wishlistItems.removeAll()
        userCustomHabitPresets.removeAll()
        customModules = [
            CustomModuleCard(id: "custom_1", title: "打卡", icon: "🎯", colorHex: "#E0F2FE", entries: [], mode: "checkin"),
            CustomModuleCard(id: "custom_2", title: "倒数", icon: "⏳", colorHex: "#FFE4E6", entries: [], mode: "countdown")
        ]
        saveTodos()
        saveNotes()
        saveVault()
        saveGrocery()
        saveFrequentGrocery()
        saveWishlist()
        saveCustomPresets()
        saveCustomModules()
        HapticManager.shared.notification(.warning)
    }
    
    // MARK: - Preset Sample Data for First Launch (Disabled - Completely Clean & Empty by Default)
    public func seedSampleData() {
        clearAllData()
    }
}