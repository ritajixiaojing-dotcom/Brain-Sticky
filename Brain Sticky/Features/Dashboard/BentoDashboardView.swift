//
//  BentoDashboardView.swift
//  Brain Sticky
//
//  Created for Brain Sticky - Personal Second Brain Super App.
//

import SwiftUI

public struct BentoDashboardView: View {
    @ObservedObject var store = DataStore.shared
    @ObservedObject var langManager = AppLanguageManager.shared
    @State private var isShowingOmni: Bool = false
    @State private var isShowingSettings: Bool = false
    
    let columns = [
        GridItem(.flexible(), spacing: 12),
        GridItem(.flexible(), spacing: 12)
    ]
    
    public init() {}
    
    public var body: some View {
        NavigationStack {
            ZStack(alignment: .bottom) {
                CuteAmbientBackground()
                
                ScrollView(showsIndicators: false) {
                    VStack(spacing: 12) {
                        // MARK: - 顶部欢迎状态栏 (Cute App Header)
                        HStack(alignment: .center) {
                            VStack(alignment: .leading, spacing: 2) {
                                HStack(spacing: 5) {
                                    CuteHollowTitleView(text: langManager.localized(.appName), fontSize: 23)
                                    Text("🫧")
                                        .font(.system(size: 17))
                                }
                                HStack(spacing: 4) {
                                    Text(langManager.localized(.appSubtitle))
                                        .font(.system(size: 12, weight: .bold, design: .rounded))
                                        .foregroundColor(Color(red: 140/255, green: 132/255, blue: 152/255))
                                    Text("✨")
                                        .font(.system(size: 11))
                                }
                                .padding(.top, 1)
                            }
                            
                            Spacer()
                            
                            // 可爱脑雾气泡
                            HStack(spacing: 4) {
                                Text("☁️")
                                    .font(.system(size: 12))
                                Text(langManager.localized(.cloudsCount(store.totalActiveBrainLoadCount)))
                                    .font(.system(size: 12, weight: .heavy, design: .rounded))
                                    .foregroundColor(BentoColors.noteAmber)
                            }
                            .padding(.horizontal, 11)
                            .padding(.vertical, 6)
                            .background(BentoColors.noteAmber.opacity(0.15))
                            .clipShape(Capsule())
                            .shadow(color: BentoColors.noteAmber.opacity(0.2), radius: 6, x: 0, y: 2)
                            
                            Button(action: {
                                isShowingSettings = true
                                HapticManager.shared.impact(.light)
                            }) {
                                Image(systemName: "slider.horizontal.3")
                                    .font(.system(size: 15, weight: .bold))
                                    .foregroundColor(.primary.opacity(0.8))
                                    .frame(width: 38, height: 38)
                                    .background(Color.white.opacity(0.92))
                                    .clipShape(Circle())
                                    .shadow(color: Color(red: 145/255, green: 135/255, blue: 165/255).opacity(0.15), radius: 8, x: 0, y: 3)
                            }
                            .bouncyTap()
                        }
                        .padding(.horizontal, 18)
                        .padding(.top, 18)
                        
                        // MARK: - 极简搜索条 (Minimalist Search)
                        HStack(spacing: 8) {
                            Image(systemName: "magnifyingglass")
                                .font(.system(size: 14, weight: .bold))
                                .foregroundColor(.secondary)
                            
                            TextField(langManager.localized(.searchPlaceholder), text: $store.searchText)
                                .font(.system(size: 14, weight: .medium, design: .rounded))
                            
                            if !store.searchText.isEmpty {
                                Button(action: { store.searchText = "" }) {
                                    Image(systemName: "xmark.circle.fill")
                                        .foregroundColor(.secondary)
                                }
                            }
                        }
                        .padding(.horizontal, 14)
                        .padding(.vertical, 10)
                        .background(Color.white.opacity(0.94))
                        .clipShape(RoundedRectangle(cornerRadius: 16, style: .continuous))
                        .overlay(
                            RoundedRectangle(cornerRadius: 16, style: .continuous)
                                .stroke(Color.white.opacity(0.9), lineWidth: 1)
                        )
                        .shadow(color: Color(red: 145/255, green: 135/255, blue: 165/255).opacity(0.12), radius: 10, x: 0, y: 4)
                        .shadow(color: Color.black.opacity(0.03), radius: 2, x: 0, y: 1)
                        .padding(.horizontal, 18)
                        
                        if !store.searchText.isEmpty {
                            SearchResultsSection()
                                .padding(.horizontal, 18)
                        } else {
                            // MARK: - 极简 Bento 六大模块网格 (3 行 × 2 列，统一大尺寸，饱满撑满整个屏幕)
                            LazyVGrid(columns: columns, spacing: 12) {
                                // 1. 待办 (Todos)
                                NavigationLink(destination: TodoListView()) {
                                    BentoTodoCard()
                                }
                                .bouncyTap()
                                
                                // 2. 日常 (Daily Notes / Drops)
                                NavigationLink(destination: StickyNotesWallView()) {
                                    BentoStickyNotesCard()
                                }
                                .bouncyTap()
                                
                                // 3. 密码 (Vault)
                                NavigationLink(destination: VaultMainView()) {
                                    BentoVaultCard()
                                }
                                .bouncyTap()
                                
                                // 4. 买菜 (Grocery)
                                NavigationLink(destination: GroceryListView()) {
                                    BentoGroceryCard()
                                }
                                .bouncyTap()
                                
                                // 5. 剁手 (Wishlist)
                                NavigationLink(destination: WishlistMainView()) {
                                    BentoWishlistCard()
                                }
                                .bouncyTap()
                                
                                // 6. 打卡 (Habit Check-in Custom Slot)
                                NavigationLink(destination: CustomModuleDetailView(moduleId: "custom_1")) {
                                    BentoCustomCardView(slotId: "custom_1")
                                }
                                .bouncyTap()
                            }
                            .padding(.horizontal, 18)
                        }
                        
                        // 底部留白紧凑恰当，让六大卡片刚好饱满落在收集日常按键正上方
                        Spacer(minLength: 70)
                    }
                    .padding(.top, 4)
                }
                .scrollDismissesKeyboard(.interactively)
                .dismissKeyboardOnTap()
                
                // MARK: - 可爱浮动录入按键 (Cute Fast Action Pill)
                Button(action: {
                    isShowingOmni = true
                    HapticManager.shared.impact(.medium)
                }) {
                    HStack(spacing: 7) {
                        Image(systemName: "sparkles")
                            .font(.system(size: 15, weight: .heavy))
                            .foregroundColor(.white)
                        
                        Text(langManager.localized(.captureDropButton))
                            .font(.system(size: 16, weight: .heavy, design: .rounded))
                            .foregroundColor(.white)
                    }
                    .padding(.horizontal, 24)
                    .padding(.vertical, 13)
                    .background(
                        LinearGradient(
                            colors: [Color(red: 255/255, green: 142/255, blue: 130/255), Color(red: 255/255, green: 110/255, blue: 168/255)],
                            startPoint: .leading,
                            endPoint: .trailing
                        )
                    )
                    .clipShape(Capsule())
                    .shadow(color: Color(red: 255/255, green: 110/255, blue: 168/255).opacity(0.45), radius: 14, x: 0, y: 6)
                    .shadow(color: Color.black.opacity(0.06), radius: 4, x: 0, y: 2)
                    .padding(.bottom, 14)
                }
                .bouncyTap(scale: 0.94)
            }
            .dismissKeyboardOnTap()
            .background(BentoColors.bgPrimary.ignoresSafeArea())
            .sheet(isPresented: $isShowingOmni) {
                OmniCaptureView()
            }
            .sheet(isPresented: $isShowingSettings) {
                SettingsView()
            }
        }
    }
}

// MARK: - 1. 待办卡片 (大尺寸饱满排版)
struct BentoTodoCard: View {
    @ObservedObject var store = DataStore.shared
    @ObservedObject var langManager = AppLanguageManager.shared
    
    var pendingItems: [TodoItem] {
        store.todos.filter { !$0.isCompleted }
    }
    
    var body: some View {
        BentoCardView(
            title: langManager.localized(.todoTitle),
            subtitle: nil,
            icon: "checklist",
            iconColor: BentoColors.urgentCoral,
            badgeCount: pendingItems.count
        ) {
            VStack(alignment: .leading, spacing: 7) {
                if pendingItems.isEmpty {
                    Text(langManager.localized(.emptyTodo))
                        .font(.system(size: 13, weight: .medium, design: .rounded))
                        .foregroundColor(.secondary)
                        .frame(minHeight: 70, alignment: .topLeading)
                } else {
                    ForEach(pendingItems.prefix(3)) { item in
                        HStack(spacing: 6) {
                            Image(systemName: "circle")
                                .font(.system(size: 12))
                                .foregroundColor(item.priority == .urgent ? BentoColors.urgentCoral : .secondary)
                            Text(item.title)
                                .font(.system(size: 13, weight: .bold, design: .rounded))
                                .foregroundColor(.primary)
                                .lineLimit(1)
                            Spacer()
                            if let mins = item.reminderMinutes {
                                Text("\(mins)m")
                                    .font(.system(size: 10, weight: .heavy, design: .rounded))
                                    .foregroundColor(BentoColors.urgentCoral)
                                    .padding(.horizontal, 5)
                                    .padding(.vertical, 2)
                                    .background(BentoColors.urgentCoral.opacity(0.12))
                                    .clipShape(Capsule())
                            }
                        }
                    }
                }
            }
            .frame(minHeight: 70, alignment: .topLeading)
        }
    }
}

// MARK: - 2. 日常便签卡片 (大尺寸饱满排版)
struct BentoStickyNotesCard: View {
    @ObservedObject var store = DataStore.shared
    @ObservedObject var langManager = AppLanguageManager.shared
    
    var latestNote: StickyNoteItem? {
        store.stickyNotes.first
    }
    
    var body: some View {
        BentoCardView(
            title: langManager.localized(.dropsTitle),
            subtitle: nil,
            icon: "sparkles",
            iconColor: BentoColors.noteAmber,
            badgeCount: store.stickyNotes.count,
            customBg: latestNote != nil ? BentoColors.colorForHex(latestNote!.colorHex) : nil
        ) {
            if let note = latestNote {
                VStack(alignment: .leading, spacing: 5) {
                    HStack {
                        Text(note.moodEmoji)
                            .font(.system(size: 18))
                        Spacer()
                        if note.isPinned {
                            Image(systemName: "pin.fill")
                                .font(.system(size: 10))
                                .foregroundColor(.orange)
                        }
                    }
                    Text(note.content)
                        .font(.system(size: 13, weight: .medium, design: .rounded))
                        .foregroundColor(Color.black.opacity(0.85))
                        .lineLimit(3)
                        .multilineTextAlignment(.leading)
                }
                .frame(minHeight: 70, alignment: .topLeading)
            } else {
                Text(langManager.localized(.emptyDrops))
                    .font(.system(size: 13, weight: .medium, design: .rounded))
                    .foregroundColor(.secondary)
                    .frame(minHeight: 70, alignment: .topLeading)
            }
        }
    }
}

// MARK: - 3. 密码卡片 (大尺寸饱满排版)
struct BentoVaultCard: View {
    @ObservedObject var store = DataStore.shared
    @ObservedObject var langManager = AppLanguageManager.shared
    
    var body: some View {
        BentoCardView(
            title: langManager.localized(.vaultTitle),
            subtitle: nil,
            icon: "lock.fill",
            iconColor: BentoColors.vaultViolet,
            badgeCount: store.vaultCount
        ) {
            VStack(alignment: .leading, spacing: 6) {
                if let first = store.vaultItems.first {
                    Text(first.title)
                        .font(.system(size: 13, weight: .bold, design: .rounded))
                        .foregroundColor(.primary)
                        .lineLimit(1)
                    
                    Text(first.secretValue)
                        .font(.system(size: 13, weight: .semibold, design: .monospaced))
                        .foregroundColor(BentoColors.vaultViolet)
                        .lineLimit(1)
                    
                    if store.vaultItems.count > 1, let second = store.vaultItems.dropFirst().first {
                        Text(second.title)
                            .font(.system(size: 11, design: .rounded))
                            .foregroundColor(.secondary)
                            .lineLimit(1)
                    }
                } else {
                    Text(langManager.localized(.emptyVault))
                        .font(.system(size: 13, weight: .medium, design: .rounded))
                        .foregroundColor(.secondary)
                        .frame(minHeight: 70, alignment: .topLeading)
                }
            }
            .frame(minHeight: 70, alignment: .topLeading)
        }
    }
}

// MARK: - 4. 买菜卡片 (大尺寸饱满排版)
struct BentoGroceryCard: View {
    @ObservedObject var store = DataStore.shared
    @ObservedObject var langManager = AppLanguageManager.shared
    
    var pendingItems: [GroceryItem] {
        store.groceryItems.filter { !$0.isBought }
    }
    
    var body: some View {
        BentoCardView(
            title: langManager.localized(.groceryTitle),
            subtitle: nil,
            icon: "cart.fill",
            iconColor: BentoColors.groceryMint,
            badgeCount: pendingItems.count
        ) {
            VStack(alignment: .leading, spacing: 6) {
                if pendingItems.isEmpty {
                    Text(langManager.localized(.emptyGrocery))
                        .font(.system(size: 13, weight: .medium, design: .rounded))
                        .foregroundColor(.secondary)
                        .frame(minHeight: 70, alignment: .topLeading)
                } else {
                    ForEach(pendingItems.prefix(2)) { item in
                        HStack(spacing: 4) {
                            Text(item.aisle.icon)
                                .font(.system(size: 12))
                            Text(item.name)
                                .font(.system(size: 13, weight: .bold, design: .rounded))
                                .foregroundColor(.primary)
                                .lineLimit(1)
                        }
                    }
                    
                    ProgressView(value: store.groceryCompletedRatio)
                        .tint(BentoColors.groceryMint)
                        .padding(.top, 4)
                }
            }
            .frame(minHeight: 70, alignment: .topLeading)
        }
    }
}

// MARK: - 5. 剁手卡片 (大尺寸饱满排版)
struct BentoWishlistCard: View {
    @ObservedObject var store = DataStore.shared
    @ObservedObject var langManager = AppLanguageManager.shared
    
    var activeItems: [WishlistItem] {
        store.wishlistItems.filter { !$0.isPurchased && !$0.isAbandoned }
    }
    
    var body: some View {
        BentoCardView(
            title: langManager.localized(.wishlistTitle),
            subtitle: nil,
            icon: "gift.fill",
            iconColor: BentoColors.wishlistRuby,
            badgeCount: activeItems.count
        ) {
            VStack(alignment: .leading, spacing: 6) {
                if let item = activeItems.first {
                    Text(item.title)
                        .font(.system(size: 13, weight: .bold, design: .rounded))
                        .lineLimit(1)
                    
                    HStack(spacing: 4) {
                        Text(langManager.currentLanguage == .english ? "\(item.daysRemaining) days left" : "还剩 \(item.daysRemaining) 天")
                            .font(.system(size: 12, weight: .heavy, design: .rounded))
                            .foregroundColor(BentoColors.wishlistRuby)
                        
                        if item.targetPrice > 0 {
                            Spacer()
                            Text(WishlistCurrency.fromSymbol(item.currency).formatted(item.targetPrice))
                                .font(.system(size: 11, weight: .bold, design: .rounded))
                                .foregroundColor(.secondary)
                        }
                    }
                } else {
                    Text(langManager.localized(.emptyWishlist))
                        .font(.system(size: 13, weight: .medium, design: .rounded))
                        .foregroundColor(.secondary)
                        .frame(minHeight: 70, alignment: .topLeading)
                }
            }
            .frame(minHeight: 70, alignment: .topLeading)
        }
    }
}

// MARK: - 全域深度检索区 (Omni Search Across All Content)
struct SearchResultsSection: View {
    @ObservedObject var store = DataStore.shared
    @ObservedObject var langManager = AppLanguageManager.shared
    
    var query: String {
        store.searchText.trimmingCharacters(in: .whitespacesAndNewlines)
    }
    
    // 1. 待办 (Todos)
    var matchTodos: [TodoItem] {
        guard !query.isEmpty else { return [] }
        return store.todos.filter {
            $0.title.localizedCaseInsensitiveContains(query) ||
            $0.priority.rawValue.localizedCaseInsensitiveContains(query)
        }
    }
    
    // 2. 日常 / 便签 (Sticky Notes)
    var matchNotes: [StickyNoteItem] {
        guard !query.isEmpty else { return [] }
        return store.stickyNotes.filter {
            $0.content.localizedCaseInsensitiveContains(query) ||
            $0.moodEmoji.contains(query)
        }
    }
    
    // 3. 密码 / 钥匙盒 (Vault)
    var matchVault: [VaultItem] {
        guard !query.isEmpty else { return [] }
        return store.vaultItems.filter {
            $0.title.localizedCaseInsensitiveContains(query) ||
            $0.accountOrKey.localizedCaseInsensitiveContains(query) ||
            $0.notes.localizedCaseInsensitiveContains(query) ||
            $0.category.rawValue.localizedCaseInsensitiveContains(query)
        }
    }
    
    // 4. 买菜清单 (Grocery)
    var matchGrocery: [GroceryItem] {
        guard !query.isEmpty else { return [] }
        return store.groceryItems.filter {
            $0.name.localizedCaseInsensitiveContains(query) ||
            $0.aisle.rawValue.localizedCaseInsensitiveContains(query)
        }
    }
    
    // 5. 剁手 (Wishlist)
    var matchWishlist: [WishlistItem] {
        guard !query.isEmpty else { return [] }
        return store.wishlistItems.filter {
            $0.title.localizedCaseInsensitiveContains(query) ||
            $0.category.localizedCaseInsensitiveContains(query) ||
            $0.notes.localizedCaseInsensitiveContains(query)
        }
    }
    
    // 6. 打卡 / 自定义习惯 (Check-in & Habit Items)
    struct MatchedHabitEntry: Identifiable {
        var id: UUID { entry.id }
        let moduleId: String
        let moduleTitle: String
        let moduleIcon: String
        let entry: CustomEntryItem
    }
    
    var matchHabits: [MatchedHabitEntry] {
        guard !query.isEmpty else { return [] }
        var list: [MatchedHabitEntry] = []
        for module in store.customModules {
            for entry in module.entries {
                if entry.title.localizedCaseInsensitiveContains(query) ||
                   entry.detail.localizedCaseInsensitiveContains(query) ||
                   module.title.localizedCaseInsensitiveContains(query) {
                    list.append(MatchedHabitEntry(
                        moduleId: module.id,
                        moduleTitle: module.title,
                        moduleIcon: module.icon,
                        entry: entry
                    ))
                }
            }
        }
        return list
    }
    
    var totalMatches: Int {
        matchTodos.count + matchNotes.count + matchVault.count + matchGrocery.count + matchWishlist.count + matchHabits.count
    }
    
    var body: some View {
        VStack(alignment: .leading, spacing: 14) {
            HStack {
                Text(langManager.currentLanguage == .english ? "Search Results" : "全库匹配结果")
                    .font(.system(size: 15, weight: .bold, design: .rounded))
                    .foregroundColor(.primary)
                Spacer()
                Text(langManager.currentLanguage == .english ? "\(totalMatches) items found" : "共匹配 \(totalMatches) 条")
                    .font(.system(size: 12, weight: .bold, design: .rounded))
                    .foregroundColor(totalMatches > 0 ? BentoColors.omniElectric : .secondary)
            }
            .padding(.horizontal, 4)
            
            if totalMatches == 0 {
                VStack(spacing: 8) {
                    Text("🔍")
                        .font(.system(size: 32))
                        .padding(.top, 20)
                    Text(langManager.currentLanguage == .english ? "No brain fog records found" : "未找到匹配的脑雾记录")
                        .font(.system(size: 14, weight: .bold, design: .rounded))
                        .foregroundColor(.primary)
                    Text(langManager.currentLanguage == .english ? "Searched across Todos, Daily, Vault, Grocery, Wishlist & Habits ✨" : "已全库搜索待办、日常、密码、买菜、剁手与打卡习惯 ✨")
                        .font(.system(size: 12, design: .rounded))
                        .foregroundColor(.secondary)
                        .padding(.bottom, 20)
                }
                .frame(maxWidth: .infinity)
                .background(Color.white.opacity(0.92))
                .clipShape(RoundedRectangle(cornerRadius: 20, style: .continuous))
                .shadow(color: Color(red: 145/255, green: 135/255, blue: 165/255).opacity(0.12), radius: 10, x: 0, y: 4)
            } else {
                VStack(spacing: 12) {
                    // 1. 待办匹配
                    if !matchTodos.isEmpty {
                        SearchCategoryCard(
                            title: langManager.localized(.todoTitle),
                            icon: "checklist",
                            color: BentoColors.urgentCoral,
                            count: matchTodos.count
                        ) {
                            ForEach(matchTodos) { item in
                                NavigationLink(destination: TodoListView()) {
                                    HStack {
                                        Image(systemName: item.isCompleted ? "checkmark.circle.fill" : "circle")
                                            .foregroundColor(item.isCompleted ? BentoColors.groceryMint : (item.priority == .urgent ? BentoColors.urgentCoral : .secondary))
                                        Text(item.title)
                                            .font(.system(size: 13, weight: .medium, design: .rounded))
                                            .foregroundColor(.primary)
                                            .strikethrough(item.isCompleted)
                                        Spacer()
                                        if let mins = item.reminderMinutes {
                                            Text("\(mins)m")
                                                .font(.system(size: 10, weight: .bold, design: .rounded))
                                                .foregroundColor(BentoColors.urgentCoral)
                                        }
                                    }
                                    .padding(.vertical, 3)
                                }
                                .buttonStyle(.plain)
                            }
                        }
                    }
                    
                    // 2. 日常便签匹配
                    if !matchNotes.isEmpty {
                        SearchCategoryCard(
                            title: langManager.localized(.dropsTitle),
                            icon: "sparkles",
                            color: BentoColors.noteAmber,
                            count: matchNotes.count
                        ) {
                            ForEach(matchNotes) { note in
                                NavigationLink(destination: StickyNotesWallView()) {
                                    HStack(spacing: 8) {
                                        Text(note.moodEmoji)
                                            .font(.system(size: 14))
                                        Text(note.content)
                                            .font(.system(size: 13, weight: .medium, design: .rounded))
                                            .foregroundColor(.primary)
                                            .lineLimit(1)
                                        Spacer()
                                    }
                                    .padding(.vertical, 3)
                                }
                                .buttonStyle(.plain)
                            }
                        }
                    }
                    
                    // 3. 密码匹配
                    if !matchVault.isEmpty {
                        SearchCategoryCard(
                            title: langManager.localized(.vaultTitle),
                            icon: "lock.fill",
                            color: BentoColors.vaultViolet,
                            count: matchVault.count
                        ) {
                            ForEach(matchVault) { item in
                                NavigationLink(destination: VaultMainView()) {
                                    HStack {
                                        Text(item.title)
                                            .font(.system(size: 13, weight: .bold, design: .rounded))
                                            .foregroundColor(.primary)
                                        Spacer()
                                        Text(item.secretValue)
                                            .font(.system(size: 12, weight: .medium, design: .monospaced))
                                            .foregroundColor(BentoColors.vaultViolet)
                                    }
                                    .padding(.vertical, 3)
                                }
                                .buttonStyle(.plain)
                            }
                        }
                    }
                    
                    // 4. 买菜匹配
                    if !matchGrocery.isEmpty {
                        SearchCategoryCard(
                            title: langManager.localized(.groceryTitle),
                            icon: "cart.fill",
                            color: BentoColors.groceryMint,
                            count: matchGrocery.count
                        ) {
                            ForEach(matchGrocery) { item in
                                NavigationLink(destination: GroceryListView()) {
                                    HStack {
                                        Text(item.name)
                                            .font(.system(size: 13, weight: .medium, design: .rounded))
                                            .foregroundColor(.primary)
                                        Spacer()
                                        Text(item.aisle.localized(lang: langManager.currentLanguage))
                                            .font(.system(size: 11, design: .rounded))
                                            .foregroundColor(.secondary)
                                            .padding(.horizontal, 6)
                                            .padding(.vertical, 2)
                                            .background(BentoColors.groceryMint.opacity(0.12))
                                            .clipShape(Capsule())
                                    }
                                    .padding(.vertical, 3)
                                }
                                .buttonStyle(.plain)
                            }
                        }
                    }
                    
                    // 5. 剁手匹配
                    if !matchWishlist.isEmpty {
                        SearchCategoryCard(
                            title: langManager.localized(.wishlistTitle),
                            icon: "gift.fill",
                            color: BentoColors.wishlistRuby,
                            count: matchWishlist.count
                        ) {
                            ForEach(matchWishlist) { item in
                                NavigationLink(destination: WishlistMainView()) {
                                    HStack {
                                        Text(item.title)
                                            .font(.system(size: 13, weight: .medium, design: .rounded))
                                            .foregroundColor(.primary)
                                        Spacer()
                                        Text(langManager.currentLanguage == .english ? "\(item.daysRemaining) days left" : "还剩 \(item.daysRemaining) 天")
                                            .font(.system(size: 11, weight: .bold, design: .rounded))
                                            .foregroundColor(BentoColors.wishlistRuby)
                                    }
                                    .padding(.vertical, 3)
                                }
                                .buttonStyle(.plain)
                            }
                        }
                    }
                    
                    // 6. 打卡习惯匹配
                    if !matchHabits.isEmpty {
                        SearchCategoryCard(
                            title: langManager.localized(.habitTitle),
                            icon: "target",
                            color: BentoColors.omniElectric,
                            count: matchHabits.count
                        ) {
                            ForEach(matchHabits) { habit in
                                NavigationLink(destination: CustomModuleDetailView(moduleId: habit.moduleId)) {
                                    HStack(spacing: 8) {
                                        Text(habit.entry.icon)
                                            .font(.system(size: 14))
                                        
                                        VStack(alignment: .leading, spacing: 2) {
                                            Text(habit.entry.title)
                                                .font(.system(size: 13, weight: .bold, design: .rounded))
                                                .foregroundColor(.primary)
                                            if !habit.entry.detail.isEmpty {
                                                Text(habit.entry.detail)
                                                    .font(.system(size: 11, design: .rounded))
                                                    .foregroundColor(.secondary)
                                            }
                                        }
                                        
                                        Spacer()
                                        
                                        if habit.entry.isCompleted {
                                            Text(langManager.localized(.statusCompleted))
                                                .font(.system(size: 10, weight: .heavy, design: .rounded))
                                                .foregroundColor(BentoColors.groceryMint)
                                                .padding(.horizontal, 6)
                                                .padding(.vertical, 2)
                                                .background(BentoColors.groceryMint.opacity(0.12))
                                                .clipShape(Capsule())
                                        } else {
                                            Text(langManager.localized(.statusPending))
                                                .font(.system(size: 10, weight: .bold, design: .rounded))
                                                .foregroundColor(.secondary)
                                                .padding(.horizontal, 6)
                                                .padding(.vertical, 2)
                                                .background(Color.black.opacity(0.05))
                                                .clipShape(Capsule())
                                        }
                                    }
                                    .padding(.vertical, 3)
                                }
                                .buttonStyle(.plain)
                            }
                        }
                    }
                }
            }
        }
    }
}

// MARK: - 搜索结果单项卡片容器
struct SearchCategoryCard<Content: View>: View {
    let title: String
    let icon: String
    let color: Color
    let count: Int
    @ViewBuilder let content: () -> Content
    
    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            HStack(spacing: 6) {
                Image(systemName: icon)
                    .font(.system(size: 11, weight: .bold))
                    .foregroundColor(color)
                Text(title)
                    .font(.system(size: 13, weight: .heavy, design: .rounded))
                    .foregroundColor(color)
                Spacer()
                Text("\(count)")
                    .font(.system(size: 11, weight: .bold, design: .rounded))
                    .foregroundColor(color)
                    .padding(.horizontal, 6)
                    .padding(.vertical, 2)
                    .background(color.opacity(0.12))
                    .clipShape(Capsule())
            }
            
            VStack(alignment: .leading, spacing: 4) {
                content()
            }
        }
        .padding(12)
        .background(Color.white.opacity(0.92))
        .clipShape(RoundedRectangle(cornerRadius: 16, style: .continuous))
        .overlay(
            RoundedRectangle(cornerRadius: 16, style: .continuous)
                .stroke(Color.white.opacity(0.9), lineWidth: 1)
        )
        .shadow(color: Color(red: 145/255, green: 135/255, blue: 165/255).opacity(0.1), radius: 8, x: 0, y: 3)
    }
}
