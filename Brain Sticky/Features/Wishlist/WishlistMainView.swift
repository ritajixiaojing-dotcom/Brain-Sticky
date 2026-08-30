//
//  WishlistMainView.swift
//  Brain Sticky
//
//  Created for Brain Sticky - Personal Second Brain Super App.
//

import SwiftUI

public struct WishlistMainView: View {
    @ObservedObject var store = DataStore.shared
    @ObservedObject var langManager = AppLanguageManager.shared
    @State private var isShowingAddSheet: Bool = false
    @State private var editingItem: WishlistItem? = nil
    @State private var itemToDelete: WishlistItem? = nil
    @State private var viewTab: WishlistTab = .cooling
    @State private var isTotalZoomed: Bool = false
    @State private var isCountZoomed: Bool = false
    @State private var isIconWiggling: Bool = false
    
    enum WishlistTab: String, CaseIterable {
        case cooling
        case achieved
        case abandoned
        
        func title(lang: AppLanguage) -> String {
            switch self {
            case .cooling: return lang == .chinese ? "冷静 ⏳" : "Cooling ⏳"
            case .achieved: return lang == .chinese ? "已买 🛍️" : "Bought 🛍️"
            case .abandoned: return lang == .chinese ? "已放弃 🗑️" : "Passed 🗑️"
            }
        }
    }
    
    var activeItems: [WishlistItem] {
        store.wishlistItems.filter { !$0.isPurchased && !$0.isAbandoned }
    }
    
    var purchasedItems: [WishlistItem] {
        store.wishlistItems.filter { $0.isPurchased && !$0.isAbandoned }
    }
    
    var abandonedItems: [WishlistItem] {
        store.wishlistItems.filter { $0.isAbandoned }
    }
    
    struct CurrencySummary: Identifiable {
        let currency: WishlistCurrency
        let total: Double
        var id: String { currency.rawValue }
    }
    
    var currentTabItems: [WishlistItem] {
        switch viewTab {
        case .cooling: return activeItems
        case .achieved: return purchasedItems
        case .abandoned: return abandonedItems
        }
    }
    
    var currencySummaries: [CurrencySummary] {
        var map: [WishlistCurrency: Double] = [:]
        for item in currentTabItems {
            let curr = WishlistCurrency.fromSymbol(item.currency)
            map[curr, default: 0] += item.targetPrice
        }
        
        let nonZero = WishlistCurrency.allCases.compactMap { curr -> CurrencySummary? in
            if let sum = map[curr], sum != 0 {
                return CurrencySummary(currency: curr, total: sum)
            }
            return nil
        }
        
        if nonZero.isEmpty {
            return [CurrencySummary(currency: .cny, total: 0)]
        }
        return nonZero
    }
    
    var displayedBudgetLabel: String {
        if viewTab == .abandoned {
            return langManager.currentLanguage == .chinese ? "已省下" : "Saved"
        } else {
            return langManager.currentLanguage == .chinese ? "总额" : "Total"
        }
    }
    
    var displayedCount: Int {
        switch viewTab {
        case .cooling: return activeItems.count
        case .achieved: return purchasedItems.count
        case .abandoned: return abandonedItems.count
        }
    }
    
    var displayedCountLabel: String {
        switch viewTab {
        case .cooling: return langManager.currentLanguage == .chinese ? "剁手" : "Wishlist"
        case .achieved: return langManager.currentLanguage == .chinese ? "已买" : "Bought"
        case .abandoned: return langManager.currentLanguage == .chinese ? "放弃" : "Passed"
        }
    }
    
    var displayedIconName: String {
        switch viewTab {
        case .cooling: return "gift.fill"
        case .achieved: return "bag.fill"
        case .abandoned: return "trash.fill"
        }
    }
    
    public var body: some View {
        List {
            // 顶部总额/已省下统计卡片 (支持多币种每种一列、总额与件数分别点击动态放大、图标动效)
            Section {
                HStack(spacing: 12) {
                    // 左侧：总额 / 已省金额 (竖排每个币种，点击放大)
                    VStack(alignment: .leading, spacing: 5) {
                        HStack(spacing: 4) {
                            Text(displayedBudgetLabel)
                                .font(.system(size: 11, weight: .bold, design: .rounded))
                                .foregroundColor(.secondary)
                            if isTotalZoomed {
                                Text(viewTab == .abandoned ? "🎉" : "✨")
                                    .font(.system(size: 10))
                                    .transition(.scale.combined(with: .opacity))
                            }
                        }
                        
                        // 竖排显示各个币种金额 (Vertical stack for each currency)
                        VStack(alignment: .leading, spacing: 3) {
                            ForEach(currencySummaries) { summary in
                                HStack(alignment: .firstTextBaseline, spacing: 3) {
                                    if currencySummaries.count > 1 {
                                        Text(summary.currency.name)
                                            .font(.system(size: isTotalZoomed ? 12 : 10, weight: .bold, design: .rounded))
                                            .foregroundColor(.secondary)
                                            .frame(minWidth: 28, alignment: .leading)
                                    }
                                    
                                    if summary.currency != .jpy {
                                        Text(summary.currency.symbol)
                                            .font(.system(size: isTotalZoomed ? (currencySummaries.count > 1 ? 17 : 20) : (currencySummaries.count > 1 ? 13 : 15), weight: .heavy, design: .rounded))
                                            .foregroundColor(viewTab == .abandoned ? BentoColors.groceryMint : BentoColors.wishlistRuby)
                                    }
                                    
                                    Text(String(format: "%.0f", summary.total))
                                        .font(.system(size: isTotalZoomed ? (currencySummaries.count > 1 ? 26 : 34) : (currencySummaries.count > 1 ? 19 : 23), weight: .heavy, design: .rounded))
                                        .foregroundColor(viewTab == .abandoned ? BentoColors.groceryMint : BentoColors.wishlistRuby)
                                        .contentTransition(.numericText())
                                    
                                    if summary.currency == .jpy {
                                        Text("円")
                                            .font(.system(size: isTotalZoomed ? 13 : 11, weight: .bold, design: .rounded))
                                            .foregroundColor(viewTab == .abandoned ? BentoColors.groceryMint : BentoColors.wishlistRuby)
                                    }
                                }
                            }
                        }
                        .scaleEffect(isTotalZoomed ? 1.08 : 1.0, anchor: .leading)
                        .shadow(color: isTotalZoomed ? (viewTab == .abandoned ? BentoColors.groceryMint.opacity(0.35) : BentoColors.wishlistRuby.opacity(0.35)) : .clear, radius: 8, y: 3)
                        .animation(.spring(response: 0.3, dampingFraction: 0.48), value: isTotalZoomed)
                    }
                    .padding(8)
                    .background(
                        RoundedRectangle(cornerRadius: 14, style: .continuous)
                            .fill(isTotalZoomed ? (viewTab == .abandoned ? BentoColors.groceryMint.opacity(0.1) : BentoColors.wishlistRuby.opacity(0.1)) : Color.clear)
                    )
                    .contentShape(Rectangle())
                    .onTapGesture {
                        HapticManager.shared.impact(.heavy)
                        withAnimation(.spring(response: 0.28, dampingFraction: 0.45)) {
                            isTotalZoomed.toggle()
                        }
                    }
                    
                    Spacer()
                    
                    // 右侧：件数 (点击放大 + 灵动图标跳动)
                    VStack(alignment: .trailing, spacing: 3) {
                        HStack(spacing: 4) {
                            Image(systemName: displayedIconName)
                                .font(.system(size: isCountZoomed ? 14 : 11, weight: .bold))
                                .foregroundColor(viewTab == .abandoned ? BentoColors.groceryMint : BentoColors.wishlistRuby)
                                .rotationEffect(.degrees(isIconWiggling ? -22 : (isCountZoomed ? 15 : 0)))
                                .scaleEffect(isIconWiggling ? 1.35 : (isCountZoomed ? 1.25 : 1.0))
                                .animation(.spring(response: 0.25, dampingFraction: 0.4), value: isIconWiggling)
                                .animation(.spring(response: 0.3, dampingFraction: 0.5), value: isCountZoomed)
                            
                            Text(displayedCountLabel)
                                .font(.system(size: 11, weight: .bold, design: .rounded))
                                .foregroundColor(.secondary)
                            
                            if isCountZoomed {
                                Text("✨")
                                    .font(.system(size: 10))
                                    .transition(.scale.combined(with: .opacity))
                            }
                        }
                        
                        HStack(alignment: .firstTextBaseline, spacing: 2) {
                            Text("\(displayedCount)")
                                .font(.system(size: isCountZoomed ? 34 : 19, weight: .heavy, design: .rounded))
                                .foregroundColor(isCountZoomed ? (viewTab == .abandoned ? BentoColors.groceryMint : BentoColors.wishlistRuby) : .primary)
                                .contentTransition(.numericText())
                            Text(langManager.currentLanguage == .chinese ? "件" : " items")
                                .font(.system(size: isCountZoomed ? 14 : 12, weight: .bold, design: .rounded))
                                .foregroundColor(.secondary)
                        }
                        .scaleEffect(isCountZoomed ? 1.18 : 1.0, anchor: .trailing)
                        .shadow(color: isCountZoomed ? (viewTab == .abandoned ? BentoColors.groceryMint.opacity(0.35) : BentoColors.wishlistRuby.opacity(0.35)) : .clear, radius: 8, y: 3)
                        .animation(.spring(response: 0.3, dampingFraction: 0.48), value: isCountZoomed)
                        .animation(.spring(), value: displayedCount)
                    }
                    .padding(10)
                    .background(
                        RoundedRectangle(cornerRadius: 14, style: .continuous)
                            .fill(isCountZoomed ? (viewTab == .abandoned ? BentoColors.groceryMint.opacity(0.1) : BentoColors.wishlistRuby.opacity(0.1)) : Color.clear)
                    )
                    .contentShape(Rectangle())
                    .onTapGesture {
                        HapticManager.shared.impact(.heavy)
                        withAnimation(.spring(response: 0.28, dampingFraction: 0.45)) {
                            isCountZoomed.toggle()
                            isIconWiggling = true
                        }
                        DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {
                            isIconWiggling = false
                        }
                    }
                }
                .padding(8)
                .background(BentoColors.bgSecondary)
                .clipShape(RoundedRectangle(cornerRadius: 18, style: .continuous))
                .listRowInsets(EdgeInsets(top: 4, leading: 16, bottom: 6, trailing: 16))
                .listRowBackground(Color.clear)
                .listRowSeparator(.hidden)
                
                // 三字状态切换 (冷静 ⏳ / 已买 🛍️ / 已放弃 🗑️)
                Picker("Tab", selection: $viewTab) {
                    ForEach(WishlistTab.allCases, id: \.self) { tab in
                        Text(tab.title(lang: langManager.currentLanguage)).tag(tab)
                    }
                }
                .pickerStyle(.segmented)
                .listRowInsets(EdgeInsets(top: 6, leading: 16, bottom: 8, trailing: 16))
                .listRowBackground(Color.clear)
                .listRowSeparator(.hidden)
            }
            
            // 列表区 (支持左滑操作)
            Section {
                let itemsToShow: [WishlistItem] = {
                    switch viewTab {
                    case .cooling: return activeItems
                    case .achieved: return purchasedItems
                    case .abandoned: return abandonedItems
                    }
                }()
                
                if itemsToShow.isEmpty {
                    VStack {
                        Spacer()
                        Text(emptyStateText)
                            .font(.system(size: 13, weight: .medium, design: .rounded))
                            .foregroundColor(.secondary)
                            .frame(maxWidth: .infinity)
                            .padding(.top, 24)
                        Spacer()
                    }
                    .listRowBackground(Color.clear)
                    .listRowSeparator(.hidden)
                } else {
                    ForEach(itemsToShow) { item in
                        WishlistCard(item: item, onEdit: {
                            editingItem = item
                        })
                        .listRowInsets(EdgeInsets(top: 5, leading: 16, bottom: 5, trailing: 16))
                        .listRowBackground(Color.clear)
                        .listRowSeparator(.hidden)
                        .swipeActions(edge: .trailing, allowsFullSwipe: false) {
                            if item.isAbandoned {
                                Button(role: .destructive) {
                                    itemToDelete = item
                                } label: {
                                    Label(langManager.currentLanguage == .chinese ? "彻底删除" : "Delete", systemImage: "trash.slash.fill")
                                }
                            } else {
                                Button(role: .destructive) {
                                    itemToDelete = item
                                } label: {
                                    Label(langManager.currentLanguage == .chinese ? "放弃" : "Pass", systemImage: "trash.fill")
                                }
                            }
                        }
                        .swipeActions(edge: .leading) {
                            if item.isAbandoned {
                                Button {
                                    withAnimation(.spring()) {
                                        store.restoreWishlistItem(id: item.id)
                                    }
                                } label: {
                                    Label(langManager.currentLanguage == .chinese ? "恢复" : "Restore", systemImage: "arrow.uturn.backward")
                                }
                                .tint(BentoColors.wishlistRuby)
                            }
                        }
                    }
                }
            }
        }
        .listStyle(.plain)
        .scrollContentBackground(.hidden)
        .scrollDismissesKeyboard(.interactively)
        .dismissKeyboardOnTap()
        .background(BentoColors.bgPrimary.ignoresSafeArea())
        .navigationTitle(langManager.localized(.wishlistTitle))
        .navigationBarTitleDisplayMode(.inline)
        .toolbar {
            ToolbarItem(placement: .primaryAction) {
                Button(action: { isShowingAddSheet = true }) {
                    Image(systemName: "plus")
                        .font(.system(size: 15, weight: .bold))
                }
            }
        }
        .alert(
            langManager.currentLanguage == .chinese ? "确认删除此心愿？" : "Delete Wishlist Item?",
            isPresented: Binding(
                get: { itemToDelete != nil },
                set: { if !$0 { itemToDelete = nil } }
            ),
            presenting: itemToDelete
        ) { item in
            Button(langManager.currentLanguage == .chinese ? "确认删除" : "Delete", role: .destructive) {
                withAnimation(.spring()) {
                    if item.isAbandoned {
                        store.deleteWishlistItem(id: item.id)
                    } else {
                        store.abandonWishlistItem(id: item.id)
                    }
                }
                itemToDelete = nil
            }
            Button(langManager.localized(.cancel), role: .cancel) {
                itemToDelete = nil
            }
        } message: { item in
            Text(langManager.currentLanguage == .chinese ? "确定要删除「\(item.title)」吗？此操作无法撤销。" : "Are you sure you want to delete \"\(item.title)\"?")
        }
        .sheet(isPresented: $isShowingAddSheet) {
            AddWishlistSheet()
        }
        .sheet(item: $editingItem) { item in
            EditWishlistSheet(item: item)
        }
    }
    
    private var emptyStateText: String {
        switch viewTab {
        case .cooling: return langManager.currentLanguage == .chinese ? "无剁手清单 🌿" : "No Wishlist Items 🌿"
        case .achieved: return langManager.currentLanguage == .chinese ? "无已买项 ✨" : "No Purchased Items ✨"
        case .abandoned: return langManager.currentLanguage == .chinese ? "暂无已放弃物品，每一笔都超理智 🍃" : "No passed items, stay mindful 🍃"
        }
    }
}

// MARK: - 专属心愿录入弹窗 (AddWishlistSheet)
struct AddWishlistSheet: View {
    @Environment(\.dismiss) private var dismiss
    @ObservedObject var store = DataStore.shared
    @ObservedObject var langManager = AppLanguageManager.shared
    
    @State private var title: String = ""
    @State private var priceString: String = ""
    @State private var selectedCurrency: WishlistCurrency = .cny
    @State private var coolOffDays: Int = 14
    @State private var notes: String = ""
    
    var isSubmitDisabled: Bool {
        title.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty
    }
    
    var body: some View {
        NavigationStack {
            ScrollView(showsIndicators: false) {
                VStack(spacing: 14) {
                    VStack(alignment: .leading, spacing: 14) {
                        // 剁手物品
                        VStack(alignment: .leading, spacing: 6) {
                            Text(langManager.currentLanguage == .chinese ? "剁手物品" : "Wishlist Item")
                                .font(.system(size: 12, weight: .bold, design: .rounded))
                                .foregroundColor(.secondary)
                            
                            TextField(
                                langManager.currentLanguage == .chinese ? "如: 索尼相机 / 降噪耳机 / 跑鞋" : "e.g. Sony Camera / Headphones / Shoes",
                                text: $title
                            )
                            .font(.system(size: 15, weight: .medium, design: .rounded))
                            .padding(11)
                            .background(BentoColors.bgCard)
                            .clipShape(RoundedRectangle(cornerRadius: 12))
                        }
                        
                        // 预算金额与货币单位 (¥ 元 / $ 美元 / 円 日币 / € 欧元)
                        VStack(alignment: .leading, spacing: 6) {
                            Text(langManager.currentLanguage == .chinese ? "预算与货币" : "Budget & Currency")
                                .font(.system(size: 12, weight: .bold, design: .rounded))
                                .foregroundColor(.secondary)
                            
                            HStack(spacing: 6) {
                                ForEach(WishlistCurrency.allCases) { curr in
                                    Button(action: {
                                        selectedCurrency = curr
                                        HapticManager.shared.selection()
                                    }) {
                                        HStack(spacing: 2) {
                                            Text(curr.symbol)
                                                .font(.system(size: 12, weight: .heavy, design: .rounded))
                                            Text(curr.name)
                                                .font(.system(size: 11, weight: .bold, design: .rounded))
                                        }
                                        .frame(maxWidth: .infinity)
                                        .padding(.vertical, 7)
                                        .background(selectedCurrency == curr ? BentoColors.wishlistRuby : BentoColors.bgCard)
                                        .foregroundColor(selectedCurrency == curr ? .white : .primary)
                                        .clipShape(RoundedRectangle(cornerRadius: 10))
                                    }
                                    .bouncyTap(scale: 0.96)
                                }
                            }
                            
                            HStack(spacing: 6) {
                                Text(selectedCurrency.symbol)
                                    .font(.system(size: 16, weight: .heavy, design: .rounded))
                                    .foregroundColor(BentoColors.wishlistRuby)
                                    .padding(.leading, 8)
                                
                                Button(action: {
                                    if priceString.starts(with: "-") {
                                        priceString = String(priceString.dropFirst())
                                    } else if !priceString.isEmpty {
                                        priceString = "-" + priceString
                                    } else {
                                        priceString = "-"
                                    }
                                    HapticManager.shared.selection()
                                }) {
                                    Text("±")
                                        .font(.system(size: 15, weight: .bold, design: .rounded))
                                        .foregroundColor(priceString.starts(with: "-") ? .white : BentoColors.wishlistRuby)
                                        .padding(.horizontal, 7)
                                        .padding(.vertical, 3)
                                        .background(priceString.starts(with: "-") ? BentoColors.wishlistRuby : BentoColors.wishlistRuby.opacity(0.12))
                                        .clipShape(RoundedRectangle(cornerRadius: 6))
                                }
                                .buttonStyle(.plain)
                                
                                TextField(
                                    langManager.currentLanguage == .chinese ? "输入金额 (支持负数如: -200)" : "Amount (e.g. -200)",
                                    text: $priceString
                                )
                                .keyboardType(.numbersAndPunctuation)
                                .font(.system(size: 15, weight: .bold, design: .rounded))
                                .padding(.vertical, 11)
                                .padding(.trailing, 11)
                            }
                            .background(BentoColors.bgCard)
                            .clipShape(RoundedRectangle(cornerRadius: 12))
                        }
                        
                        // 冷静期设置
                        VStack(alignment: .leading, spacing: 6) {
                            Text(langManager.currentLanguage == .chinese ? "冷静期" : "Cool-off Period")
                                .font(.system(size: 12, weight: .bold, design: .rounded))
                                .foregroundColor(.secondary)
                            
                            let options: [(Int, String)] = langManager.currentLanguage == .chinese ?
                                [(7, "7天"), (14, "14天"), (30, "30天"), (9999, "∞")] :
                                [(7, "7 Days"), (14, "14 Days"), (30, "30 Days"), (9999, "∞")]
                            
                            HStack(spacing: 8) {
                                ForEach(options, id: \.0) { option in
                                    Button(action: {
                                        coolOffDays = option.0
                                        HapticManager.shared.selection()
                                    }) {
                                        Text(option.1)
                                            .font(.system(size: option.0 == 9999 ? 16 : 13, weight: .bold, design: .rounded))
                                            .frame(maxWidth: .infinity)
                                            .padding(.vertical, 8)
                                            .background(coolOffDays == option.0 ? BentoColors.wishlistRuby : BentoColors.bgCard)
                                            .foregroundColor(coolOffDays == option.0 ? .white : .primary)
                                            .clipShape(RoundedRectangle(cornerRadius: 10))
                                    }
                                    .bouncyTap(scale: 0.96)
                                }
                            }
                        }
                        
                        // 备注 / 种草理由
                        VStack(alignment: .leading, spacing: 6) {
                            Text(langManager.currentLanguage == .chinese ? "理由 / 备注 (选填)" : "Reason / Notes (Optional)")
                                .font(.system(size: 12, weight: .bold, design: .rounded))
                                .foregroundColor(.secondary)
                            
                            TextField(
                                langManager.currentLanguage == .chinese ? "记录为什么想买，或者降价预期..." : "Why do you want this, or discount expectation...",
                                text: $notes,
                                axis: .vertical
                            )
                            .lineLimit(2...4)
                            .font(.system(size: 14, weight: .medium, design: .rounded))
                            .padding(11)
                            .background(BentoColors.bgCard)
                            .clipShape(RoundedRectangle(cornerRadius: 12))
                        }
                    }
                    .padding(16)
                    .background(BentoColors.bgSecondary)
                    .clipShape(RoundedRectangle(cornerRadius: 20, style: .continuous))
                    .padding(.horizontal, 16)
                    .padding(.top, 10)
                    
                    // 保存按键
                    Button(action: {
                        let parsedPrice = Double(priceString) ?? 0.0
                        let item = WishlistItem(
                            title: title.trimmingCharacters(in: .whitespacesAndNewlines),
                            targetPrice: parsedPrice,
                            currency: selectedCurrency.symbol,
                            coolOffDaysTotal: coolOffDays,
                            coolOffStartDate: Date(),
                            notes: notes
                        )
                        store.addWishlistItem(item)
                        HapticManager.shared.notification(.success)
                        dismiss()
                    }) {
                        Text(langManager.localized(.save))
                            .font(.system(size: 16, weight: .heavy, design: .rounded))
                            .frame(maxWidth: .infinity)
                            .padding(.vertical, 13)
                            .background(
                                isSubmitDisabled ? Color.gray.opacity(0.25) : BentoColors.wishlistRuby
                            )
                            .foregroundColor(.white)
                            .clipShape(Capsule())
                            .shadow(color: isSubmitDisabled ? .clear : BentoColors.wishlistRuby.opacity(0.35), radius: 8, y: 4)
                    }
                    .disabled(isSubmitDisabled)
                    .bouncyTap()
                    .padding(.horizontal, 16)
                    .padding(.top, 4)
                    .padding(.bottom, 20)
                }
            }
            .scrollDismissesKeyboard(.interactively)
            .dismissKeyboardOnTap()
            .background(BentoColors.bgPrimary.ignoresSafeArea())
            .navigationTitle(langManager.currentLanguage == .chinese ? "新建剁手" : "New Wishlist Item")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button(langManager.localized(.cancel)) { dismiss() }
                        .font(.system(size: 15, weight: .medium))
                }
            }
        }
    }
}

// MARK: - Wishlist Card
struct WishlistCard: View {
    @ObservedObject var store = DataStore.shared
    @ObservedObject var langManager = AppLanguageManager.shared
    let item: WishlistItem
    var onEdit: () -> Void
    
    var currencyObj: WishlistCurrency {
        WishlistCurrency.fromSymbol(item.currency)
    }
    
    var body: some View {
        VStack(alignment: .leading, spacing: 10) {
            HStack {
                Text(item.title)
                    .font(.system(size: 14, weight: .bold, design: .rounded))
                
                Spacer()
                
                if item.targetPrice != 0 {
                    Text(currencyObj.formatted(item.targetPrice))
                        .font(.system(size: 15, weight: .heavy, design: .rounded))
                        .foregroundColor(BentoColors.wishlistRuby)
                }
                
                Button(action: onEdit) {
                    Image(systemName: "pencil")
                        .font(.system(size: 11))
                        .foregroundColor(.secondary)
                }
                .buttonStyle(.plain)
                .padding(.leading, 4)
            }
            
            if item.isAbandoned {
                HStack {
                    HStack(spacing: 4) {
                        Image(systemName: "trash.fill")
                            .font(.system(size: 10))
                        Text(langManager.currentLanguage == .chinese ? "已放弃拔草 · 省钱成功 🍃" : "Passed · Money Saved 🍃")
                            .font(.system(size: 11, weight: .bold, design: .rounded))
                    }
                    .foregroundColor(BentoColors.groceryMint)
                    
                    Spacer()
                }
            } else if !item.isPurchased {
                if item.coolOffDaysTotal >= 9999 {
                    HStack {
                        Text(langManager.currentLanguage == .chinese ? "冷静 ∞" : "Cool-off ∞")
                            .font(.system(size: 11, weight: .bold, design: .rounded))
                            .foregroundColor(BentoColors.wishlistRuby)
                        Spacer()
                    }
                } else {
                    HStack {
                        Text(langManager.currentLanguage == .chinese ? "冷静还剩 \(item.daysRemaining) 天" : "\(item.daysRemaining) days left")
                            .font(.system(size: 10, weight: .bold, design: .rounded))
                            .foregroundColor(BentoColors.wishlistRuby)
                        Spacer()
                        ProgressView(value: item.coolOffProgress)
                            .frame(width: 80)
                            .tint(BentoColors.wishlistRuby)
                    }
                }
            }
            
            HStack {
                if item.isAbandoned {
                    // 已放弃项：放回冷静
                    Button(action: {
                        withAnimation(.spring(response: 0.35, dampingFraction: 0.7)) {
                            store.restoreWishlistItem(id: item.id)
                        }
                    }) {
                        HStack(spacing: 4) {
                            Image(systemName: "arrow.uturn.backward.circle.fill")
                                .font(.system(size: 11))
                            Text(langManager.currentLanguage == .chinese ? "放回冷静 ♻️" : "Back to Cooling ♻️")
                                .font(.system(size: 11, weight: .bold, design: .rounded))
                        }
                        .padding(.horizontal, 11)
                        .padding(.vertical, 6)
                        .background(BentoColors.wishlistRuby.opacity(0.12))
                        .foregroundColor(BentoColors.wishlistRuby)
                        .clipShape(Capsule())
                    }
                    .bouncyTap(scale: 0.95)
                    
                    Spacer()
                    
                    HStack(spacing: 3) {
                        Image(systemName: "trash.circle.fill")
                            .font(.system(size: 12))
                            .foregroundColor(Color.secondary)
                        Text(langManager.currentLanguage == .chinese ? "已放弃" : "Passed")
                            .font(.system(size: 11, weight: .bold, design: .rounded))
                            .foregroundColor(.secondary)
                    }
                    .padding(.horizontal, 8)
                } else if item.isPurchased {
                    // 已买项：放回冷静 & 已拥有徽章
                    Button(action: {
                        withAnimation(.spring(response: 0.35, dampingFraction: 0.7)) {
                            store.toggleWishlistPurchased(item)
                            HapticManager.shared.notification(.success)
                        }
                    }) {
                        HStack(spacing: 4) {
                            Image(systemName: "arrow.uturn.backward")
                                .font(.system(size: 10))
                            Text(langManager.currentLanguage == .chinese ? "放回冷静" : "Back to Cooling")
                                .font(.system(size: 11, weight: .bold, design: .rounded))
                        }
                        .padding(.horizontal, 11)
                        .padding(.vertical, 6)
                        .background(BentoColors.bgCard)
                        .foregroundColor(.secondary)
                        .clipShape(Capsule())
                    }
                    .bouncyTap(scale: 0.95)
                    
                    Spacer()
                    
                    HStack(spacing: 3) {
                        Image(systemName: "checkmark.seal.fill")
                            .font(.system(size: 11))
                            .foregroundColor(BentoColors.wishlistRuby)
                        Text(langManager.currentLanguage == .chinese ? "已拥有 ✨" : "Owned ✨")
                            .font(.system(size: 11, weight: .bold, design: .rounded))
                            .foregroundColor(.secondary)
                    }
                    .padding(.horizontal, 8)
                } else {
                    // 冷静中项：买下 & 放弃扔进垃圾箱
                    Button(action: {
                        withAnimation(.spring(response: 0.35, dampingFraction: 0.7)) {
                            store.toggleWishlistPurchased(item)
                            HapticManager.shared.notification(.success)
                        }
                    }) {
                        HStack(spacing: 4) {
                            Image(systemName: "bag.fill")
                                .font(.system(size: 10))
                            Text(langManager.currentLanguage == .chinese ? "买下 ✨" : "Buy ✨")
                                .font(.system(size: 11, weight: .bold, design: .rounded))
                        }
                        .padding(.horizontal, 11)
                        .padding(.vertical, 6)
                        .background(BentoColors.wishlistRuby.opacity(0.12))
                        .foregroundColor(BentoColors.wishlistRuby)
                        .clipShape(Capsule())
                    }
                    .bouncyTap(scale: 0.95)
                    
                    Spacer()
                    
                    Button(action: {
                        withAnimation(.spring(response: 0.35, dampingFraction: 0.7)) {
                            store.abandonWishlistItem(id: item.id)
                        }
                    }) {
                        HStack(spacing: 4) {
                            Image(systemName: "trash.fill")
                                .font(.system(size: 11))
                            Text(langManager.currentLanguage == .chinese ? "放弃 🗑️" : "Pass 🗑️")
                                .font(.system(size: 11, weight: .bold, design: .rounded))
                        }
                        .padding(.horizontal, 11)
                        .padding(.vertical, 6)
                        .background(Color.red.opacity(0.1))
                        .foregroundColor(Color.red.opacity(0.85))
                        .clipShape(Capsule())
                    }
                    .bouncyTap(scale: 0.95)
                }
            }
        }
        .padding(14)
        .background(BentoColors.bgSecondary)
        .clipShape(RoundedRectangle(cornerRadius: 16, style: .continuous))
        .contentShape(Rectangle())
        .onTapGesture {
            onEdit()
        }
    }
}

// MARK: - Edit Wishlist Sheet
struct EditWishlistSheet: View {
    @Environment(\.dismiss) private var dismiss
    @ObservedObject var store = DataStore.shared
    @ObservedObject var langManager = AppLanguageManager.shared
    @State var item: WishlistItem
    @State private var priceString: String = ""
    @State private var selectedCurrency: WishlistCurrency = .cny
    
    var body: some View {
        NavigationStack {
            Form {
                Section(header: Text(langManager.currentLanguage == .chinese ? "剁手详情" : "Details").font(.system(size: 11, weight: .bold, design: .rounded))) {
                    TextField(langManager.currentLanguage == .chinese ? "物品名称" : "Item Name", text: $item.title)
                    
                    Picker(langManager.currentLanguage == .chinese ? "货币单位" : "Currency", selection: $selectedCurrency) {
                        ForEach(WishlistCurrency.allCases) { curr in
                            Text("\(curr.symbol) \(curr.name)").tag(curr)
                        }
                    }
                    
                    TextField(langManager.currentLanguage == .chinese ? "预算价格 (支持负数)" : "Budget Price", text: $priceString)
                        .keyboardType(.numbersAndPunctuation)
                }
                
                Section(header: Text(langManager.currentLanguage == .chinese ? "剁手冷静" : "Cool-off Period").font(.system(size: 11, weight: .bold, design: .rounded))) {
                    Picker(langManager.currentLanguage == .chinese ? "冷静周期" : "Period", selection: $item.coolOffDaysTotal) {
                        Text(langManager.currentLanguage == .chinese ? "7天" : "7 Days").tag(7)
                        Text(langManager.currentLanguage == .chinese ? "14天" : "14 Days").tag(14)
                        Text(langManager.currentLanguage == .chinese ? "30天" : "30 Days").tag(30)
                        Text(langManager.currentLanguage == .chinese ? "∞ 无限" : "∞ Infinite").tag(9999)
                    }
                }
                
                Section(header: Text(langManager.currentLanguage == .chinese ? "备注" : "Notes").font(.system(size: 11, weight: .bold, design: .rounded))) {
                    TextField(langManager.currentLanguage == .chinese ? "购买理由/备注" : "Reason / Notes", text: $item.notes, axis: .vertical)
                }
                
                Section {
                    Button(role: .destructive) {
                        store.deleteWishlistItem(id: item.id)
                        dismiss()
                    } label: {
                        HStack {
                            Spacer()
                            Text(langManager.currentLanguage == .chinese ? "删除此剁手记录" : "Delete Item")
                            Spacer()
                        }
                    }
                }
            }
            .scrollDismissesKeyboard(.interactively)
            .dismissKeyboardOnTap()
            .navigationTitle(langManager.currentLanguage == .chinese ? "修改剁手" : "Edit Wishlist Item")
            .navigationBarTitleDisplayMode(.inline)
            .onAppear {
                priceString = String(format: "%.0f", item.targetPrice)
                selectedCurrency = WishlistCurrency.fromSymbol(item.currency)
            }
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button(langManager.localized(.cancel)) { dismiss() }
                }
                ToolbarItem(placement: .confirmationAction) {
                    Button(langManager.localized(.save)) {
                        if let p = Double(priceString) { item.targetPrice = p }
                        item.currency = selectedCurrency.symbol
                        store.updateWishlistItem(item)
                        HapticManager.shared.notification(.success)
                        dismiss()
                    }
                }
            }
        }
    }
}