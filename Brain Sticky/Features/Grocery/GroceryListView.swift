//
//  GroceryListView.swift
//  Brain Sticky
//
//  Created for Brain Sticky - Personal Second Brain Super App.
//

import SwiftUI

public struct GroceryListView: View {
    @ObservedObject var store = DataStore.shared
    @ObservedObject var langManager = AppLanguageManager.shared
    @State private var newItemName: String = ""
    @State private var selectedAisle: GroceryAisle = .produce
    @State private var isShowingFrequentDrawer: Bool = false
    @State private var editingItem: GroceryItem? = nil
    
    @State private var itemToDelete: GroceryItem? = nil
    @State private var isShowingDeleteAlert: Bool = false
    
    var groupedItems: [GroceryAisle: [GroceryItem]] {
        Dictionary(grouping: store.groceryItems, by: { $0.aisle })
    }
    
    var boughtCount: Int {
        store.groceryItems.filter { $0.isBought }.count
    }
    
    var totalCount: Int {
        store.groceryItems.count
    }
    
    public var body: some View {
        VStack(spacing: 0) {
            // 顶栏进度与常购
            HStack(spacing: 12) {
                HStack(spacing: 4) {
                    Text(langManager.currentLanguage == .chinese ? "已买:" : "Bought:")
                        .font(.system(size: 11, weight: .medium, design: .rounded))
                        .foregroundColor(.secondary)
                    Text("\(boughtCount)/\(totalCount)")
                        .font(.system(size: 12, weight: .heavy, design: .rounded))
                        .foregroundColor(BentoColors.groceryMint)
                }
                
                ProgressView(value: store.groceryCompletedRatio)
                    .tint(BentoColors.groceryMint)
                
                Button(action: { isShowingFrequentDrawer = true }) {
                    Text(langManager.currentLanguage == .chinese ? "常购" : "Frequent")
                        .font(.system(size: 11, weight: .bold, design: .rounded))
                        .padding(.horizontal, 10)
                        .padding(.vertical, 5)
                        .background(BentoColors.groceryMint.opacity(0.14))
                        .foregroundColor(BentoColors.groceryMint)
                        .clipShape(Capsule())
                }
                .bouncyTap(scale: 0.95)
            }
            .padding(.horizontal, 16)
            .padding(.vertical, 8)
            .background(BentoColors.bgSecondary)
            
            // 舒适大尺寸快速添加栏 (Enlarged & Cute Quick Add Bar with Left Category Menu)
            HStack(spacing: 8) {
                // 左侧分类下拉菜单 (Left Aisle Dropdown Menu)
                Menu {
                    ForEach(GroceryAisle.allCases) { aisle in
                        Button(action: {
                            selectedAisle = aisle
                            HapticManager.shared.selection()
                        }) {
                            Label("\(aisle.icon) \(aisle.localized(lang: langManager.currentLanguage))", systemImage: selectedAisle == aisle ? "checkmark" : "")
                        }
                    }
                } label: {
                    HStack(spacing: 3) {
                        Text(selectedAisle.icon)
                            .font(.system(size: 16))
                        Text(selectedAisle.localized(lang: langManager.currentLanguage))
                            .font(.system(size: 12, weight: .bold, design: .rounded))
                            .foregroundColor(BentoColors.groceryMint)
                        Image(systemName: "chevron.down")
                            .font(.system(size: 9, weight: .bold))
                            .foregroundColor(BentoColors.groceryMint.opacity(0.8))
                    }
                    .padding(.horizontal, 8)
                    .padding(.vertical, 6)
                    .background(BentoColors.groceryMint.opacity(0.14))
                    .clipShape(RoundedRectangle(cornerRadius: 10, style: .continuous))
                }
                .buttonStyle(.plain)
                .bouncyTap(scale: 0.95)

                // 大字号输入框
                TextField(
                    langManager.currentLanguage == .chinese ? "想买点什么呢 🍓..." : "What to buy 🍓...",
                    text: $newItemName
                )
                .font(.system(size: 15, weight: .medium, design: .rounded))
                .submitLabel(.done)
                .onSubmit(addNewGrocery)
                
                if !newItemName.isEmpty {
                    Button(action: { newItemName = "" }) {
                        Image(systemName: "xmark.circle.fill")
                            .font(.system(size: 16))
                            .foregroundColor(.secondary.opacity(0.6))
                    }
                    .buttonStyle(.plain)
                }
                
                // 醒目的大添加按键
                Button(action: addNewGrocery) {
                    Image(systemName: "plus.circle.fill")
                        .font(.system(size: 28))
                        .foregroundColor(newItemName.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty ? BentoColors.groceryMint.opacity(0.35) : BentoColors.groceryMint)
                }
                .bouncyTap()
                .disabled(newItemName.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty)
            }
            .padding(.horizontal, 14)
            .padding(.vertical, 10)
            .background(Color.white.opacity(0.95))
            .clipShape(RoundedRectangle(cornerRadius: 18, style: .continuous))
            .overlay(
                RoundedRectangle(cornerRadius: 18, style: .continuous)
                    .stroke(Color.white.opacity(0.85), lineWidth: 1.2)
            )
            .shadow(color: Color(red: 145/255, green: 135/255, blue: 165/255).opacity(0.12), radius: 10, x: 0, y: 4)
            .padding(.horizontal, 16)
            .padding(.vertical, 8)
            
            // 列表
            List {
                if store.groceryItems.isEmpty {
                    VStack(spacing: 8) {
                        Text("🥦")
                            .font(.system(size: 32))
                            .padding(.top, 30)
                        Text(langManager.currentLanguage == .chinese ? "无买菜项" : "No Grocery Items")
                            .font(.system(size: 13, weight: .medium, design: .rounded))
                            .foregroundColor(.secondary)
                    }
                    .frame(maxWidth: .infinity)
                    .listRowBackground(Color.clear)
                } else {
                    ForEach(store.groceryItems) { item in
                        GroceryItemRow(
                            item: item,
                            onEdit: { editingItem = item },
                            onDeleteRequest: {
                                itemToDelete = item
                                isShowingDeleteAlert = true
                            }
                        )
                    }
                }
            }
            .listStyle(.insetGrouped)
            .scrollDismissesKeyboard(.interactively)
        }
        .background(BentoColors.bgPrimary.ignoresSafeArea())
        .navigationTitle(langManager.localized(.groceryTitle))
        .navigationBarTitleDisplayMode(.inline)
        .toolbar {
            ToolbarItem(placement: .primaryAction) {
                Menu {
                    Button(action: {
                        withAnimation {
                            store.clearCompletedGrocery()
                        }
                    }) {
                        Label(langManager.currentLanguage == .chinese ? "清空已买" : "Clear Bought", systemImage: "checkmark.bubble")
                    }
                } label: {
                    Image(systemName: "ellipsis.circle")
                        .font(.system(size: 15))
                }
            }
        }
        .alert(
            langManager.currentLanguage == .chinese ? "确认删除买菜项？" : "Delete Grocery Item?",
            isPresented: $isShowingDeleteAlert,
            presenting: itemToDelete
        ) { item in
            Button(langManager.currentLanguage == .chinese ? "删除" : "Delete", role: .destructive) {
                store.deleteGroceryItem(id: item.id)
                itemToDelete = nil
            }
            Button(langManager.localized(.cancel), role: .cancel) {
                itemToDelete = nil
            }
        } message: { item in
            Text(langManager.currentLanguage == .chinese ? "确定要删除「\(item.name)」吗？" : "Are you sure you want to delete \"\(item.name)\"?")
        }
        .sheet(item: $editingItem) { item in
            EditGrocerySheet(item: item)
        }
    }
    
    private func addNewGrocery() {
        let name = newItemName.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !name.isEmpty else { return }
        
        let item = GroceryItem(
            name: name,
            aisle: selectedAisle,
            quantity: "1"
        )
        withAnimation(.spring(response: 0.35, dampingFraction: 0.72)) {
            store.addGroceryItem(item)
            HapticManager.shared.notification(.success)
        }
        newItemName = ""
    }
}

// MARK: - Grocery Item Row (隐藏默认的数字 1, 支持常购标识与左滑收藏)
struct GroceryItemRow: View {
    @ObservedObject var store = DataStore.shared
    let item: GroceryItem
    var onEdit: () -> Void
    var onDeleteRequest: () -> Void
    
    var isFrequent: Bool {
        store.frequentGroceryList.contains(where: { $0.name == item.name })
    }
    
    var body: some View {
        HStack(spacing: 10) {
            Button(action: {
                withAnimation(.spring()) {
                    store.toggleGroceryItem(item)
                }
            }) {
                Image(systemName: item.isBought ? "checkmark.circle.fill" : "circle")
                    .font(.system(size: 18))
                    .foregroundColor(item.isBought ? BentoColors.groceryMint : .secondary)
            }
            .buttonStyle(.plain)
            
            Text(item.aisle.icon)
                .font(.system(size: 16))
            
            HStack(spacing: 4) {
                Text(item.name)
                    .font(.system(size: 14, weight: .medium, design: .rounded))
                    .strikethrough(item.isBought, color: .secondary)
                    .foregroundColor(item.isBought ? .secondary : .primary)
                
                if isFrequent {
                    Image(systemName: "star.fill")
                        .font(.system(size: 10))
                        .foregroundColor(.orange)
                }
            }
            
            Spacer()
            
            if item.quantity != "1" && !item.quantity.isEmpty {
                Text(item.quantity)
                    .font(.system(size: 10, weight: .bold, design: .rounded))
                    .foregroundColor(.secondary)
                    .padding(.horizontal, 6)
                    .padding(.vertical, 2)
                    .background(BentoColors.bgCard)
                    .clipShape(Capsule())
            }
            
            Button(action: onEdit) {
                Image(systemName: "pencil")
                    .font(.system(size: 12))
                    .foregroundColor(.secondary)
                    .padding(4)
            }
            .buttonStyle(.plain)
        }
        .padding(.vertical, 2)
        .contentShape(Rectangle())
        .onTapGesture {
            onEdit()
        }
        .swipeActions(edge: .leading) {
            Button {
                withAnimation {
                    store.toggleFrequentStatus(for: item)
                }
            } label: {
                Label(
                    isFrequent ? (AppLanguageManager.shared.currentLanguage == .chinese ? "取消常购" : "Unstar") : (AppLanguageManager.shared.currentLanguage == .chinese ? "设为常购" : "Star"),
                    systemImage: isFrequent ? "star.slash" : "star.fill"
                )
            }
            .tint(.orange)
        }
        .swipeActions(edge: .trailing, allowsFullSwipe: false) {
            Button(role: .destructive) {
                onDeleteRequest()
            } label: {
                Label(AppLanguageManager.shared.currentLanguage == .chinese ? "删除" : "Delete", systemImage: "trash")
            }
        }
    }
}

// MARK: - Grocery Aisle Section Header (放大幼圆艺术字)
struct GroceryAisleSectionHeader: View {
    let aisle: GroceryAisle
    let count: Int
    
    var body: some View {
        HStack(spacing: 6) {
            CuteHollowTitleView(
                text: aisle.cuteTitle,
                fontSize: 16,
                strokeColor: Color(red: 120/255, green: 112/255, blue: 135/255),
                strokeWidth: 1.15,
                fillColor: Color.white
            )
            
            Spacer()
            
            Text("\(count)")
                .font(.system(size: 11, weight: .heavy, design: .rounded))
                .foregroundColor(BentoColors.groceryMint)
                .padding(.horizontal, 7)
                .padding(.vertical, 2)
                .background(BentoColors.groceryMint.opacity(0.14))
                .clipShape(Capsule())
        }
        .padding(.vertical, 3)
        .textCase(nil)
    }
}

// MARK: - Edit Grocery Sheet
struct EditGrocerySheet: View {
    @Environment(\.dismiss) private var dismiss
    @ObservedObject var store = DataStore.shared
    @ObservedObject var langManager = AppLanguageManager.shared
    @State var item: GroceryItem
    @State private var isShowingDeleteConfirm: Bool = false
    
    var body: some View {
        NavigationStack {
            Form {
                Section(header: Text(langManager.currentLanguage == .chinese ? "物品名称" : "Item Name").font(.system(size: 11, weight: .bold, design: .rounded))) {
                    TextField(langManager.currentLanguage == .chinese ? "物品名" : "Item Name", text: $item.name)
                        .submitLabel(.done)
                }
                
                Section(header: Text(langManager.currentLanguage == .chinese ? "分区归类" : "Category").font(.system(size: 11, weight: .bold, design: .rounded))) {
                    HStack {
                        Text(langManager.currentLanguage == .chinese ? "当前分区" : "Current Category")
                            .font(.system(size: 14, weight: .medium, design: .rounded))
                        Spacer()
                        HStack(spacing: 4) {
                            Text(item.aisle.icon)
                                .font(.system(size: 14))
                            CuteHollowTitleView(
                                text: item.aisle.localized(lang: langManager.currentLanguage),
                                fontSize: 14,
                                strokeColor: Color(red: 120/255, green: 112/255, blue: 135/255),
                                strokeWidth: 1.0,
                                fillColor: Color.white
                            )
                        }
                    }
                    
                    Picker(langManager.currentLanguage == .chinese ? "修改分区" : "Change Category", selection: $item.aisle) {
                        ForEach(GroceryAisle.allCases) { aisle in
                            Text(aisle.cuteTitle).tag(aisle)
                        }
                    }
                }
                
                Section(header: Text(langManager.currentLanguage == .chinese ? "数量/备注" : "Quantity / Notes").font(.system(size: 11, weight: .bold, design: .rounded))) {
                    TextField(langManager.currentLanguage == .chinese ? "如: 2袋 / 500g" : "e.g. 2 bags / 500g", text: $item.quantity)
                        .submitLabel(.done)
                }
                
                Section {
                    Toggle(isOn: $item.isFrequent) {
                        HStack(spacing: 6) {
                            Image(systemName: item.isFrequent ? "star.fill" : "star")
                                .foregroundColor(.orange)
                            Text(langManager.currentLanguage == .chinese ? "设为常购物品（存入常购库）" : "Save to Frequent Items")
                                .font(.system(size: 14, weight: .medium, design: .rounded))
                        }
                    }
                }
                
                Section {
                    Button(role: .destructive) {
                        isShowingDeleteConfirm = true
                    } label: {
                        HStack {
                            Spacer()
                            Text(langManager.currentLanguage == .chinese ? "删除此项目" : "Delete Item")
                            Spacer()
                        }
                    }
                }
            }
            .scrollDismissesKeyboard(.interactively)
            .dismissKeyboardOnTap()
            .navigationTitle(langManager.currentLanguage == .chinese ? "修改物品" : "Edit Item")
            .navigationBarTitleDisplayMode(.inline)
            .alert(
                langManager.currentLanguage == .chinese ? "确认删除此物品？" : "Delete Grocery Item?",
                isPresented: $isShowingDeleteConfirm
            ) {
                Button(langManager.currentLanguage == .chinese ? "删除" : "Delete", role: .destructive) {
                    store.deleteGroceryItem(id: item.id)
                    dismiss()
                }
                Button(langManager.localized(.cancel), role: .cancel) {}
            } message: {
                Text(langManager.currentLanguage == .chinese ? "确定要删除「\(item.name)」吗？" : "Are you sure you want to delete \"\(item.name)\"?")
            }
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button(langManager.localized(.cancel)) { dismiss() }
                }
                ToolbarItem(placement: .confirmationAction) {
                    Button(langManager.localized(.save)) {
                        store.updateGroceryItem(item)
                        HapticManager.shared.notification(.success)
                        dismiss()
                    }
                }
            }
        }
    }
}

// MARK: - Frequent Grocery Drawer (支持自定义自由添加与删除常购)
struct FrequentGroceryDrawer: View {
    @Environment(\.dismiss) private var dismiss
    @ObservedObject var store = DataStore.shared
    @ObservedObject var langManager = AppLanguageManager.shared
    
    @State private var newFrequentName: String = ""
    @State private var newFrequentAisle: GroceryAisle = .produce
    
    var body: some View {
        NavigationStack {
            List {
                // MARK: - 1. 自定义录入新常购
                Section(header: Text(langManager.currentLanguage == .chinese ? "添加我的专属常购" : "Add Frequent Item").font(.system(size: 11, weight: .bold, design: .rounded))) {
                    HStack(spacing: 8) {
                        Menu {
                            ForEach(GroceryAisle.allCases) { aisle in
                                Button(aisle.cuteTitle) { 
                                    newFrequentAisle = aisle
                                    HapticManager.shared.selection()
                                }
                            }
                        } label: {
                            HStack(spacing: 4) {
                                Text(newFrequentAisle.icon)
                                    .font(.system(size: 13))
                                Text(newFrequentAisle.localized(lang: langManager.currentLanguage))
                                    .font(.system(size: 13, weight: .bold, design: .rounded))
                                    .foregroundColor(.primary)
                            }
                            .padding(.horizontal, 9)
                            .padding(.vertical, 6)
                            .background(BentoColors.groceryMint.opacity(0.14))
                            .clipShape(Capsule())
                        }
                        .bouncyTap(scale: 0.95)
                        
                        TextField(
                            langManager.currentLanguage == .chinese ? "输入常购物品 (如 鸡蛋, 燕麦奶)..." : "e.g. Eggs, Oat milk...",
                            text: $newFrequentName
                        )
                        .font(.system(size: 14, weight: .medium, design: .rounded))
                        .submitLabel(.done)
                        .onSubmit(addCustomFrequent)
                        
                        Button(action: addCustomFrequent) {
                            Image(systemName: "plus.circle.fill")
                                .font(.system(size: 26))
                                .foregroundColor(newFrequentName.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty ? BentoColors.groceryMint.opacity(0.35) : BentoColors.groceryMint)
                        }
                        .bouncyTap()
                        .disabled(newFrequentName.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty)
                    }
                    .padding(.vertical, 3)
                }
                
                // MARK: - 2. 我的常购清单
                Section(header: HStack {
                    Text(langManager.currentLanguage == .chinese ? "我的常购库 (\(store.frequentGroceryList.count))" : "Frequent Items (\(store.frequentGroceryList.count))")
                        .font(.system(size: 11, weight: .bold, design: .rounded))
                    Spacer()
                    if !store.frequentGroceryList.isEmpty {
                        Text(langManager.currentLanguage == .chinese ? "左滑可移出常购" : "Swipe left to remove")
                            .font(.system(size: 10, design: .rounded))
                            .foregroundColor(.secondary)
                    }
                }) {
                    if store.frequentGroceryList.isEmpty {
                        VStack(spacing: 8) {
                            Text("🛒")
                                .font(.system(size: 34))
                                .padding(.top, 16)
                            Text(langManager.currentLanguage == .chinese ? "常购库暂无内容" : "No Frequent Items")
                                .font(.system(size: 14, weight: .bold, design: .rounded))
                            Text(langManager.currentLanguage == .chinese ? "在上方输入物品名，轻松建立只属于您的常购清单 ✨" : "Enter item above to build your frequent grocery list ✨")
                                .font(.system(size: 12, design: .rounded))
                                .foregroundColor(.secondary)
                                .multilineTextAlignment(.center)
                                .padding(.horizontal, 16)
                                .padding(.bottom, 12)
                        }
                        .frame(maxWidth: .infinity)
                        .listRowBackground(Color.clear)
                    } else {
                        ForEach(store.frequentGroceryList) { item in
                            HStack {
                                HStack(spacing: 6) {
                                    Text(item.aisle.icon)
                                        .font(.system(size: 15))
                                    Text(item.name)
                                        .font(.system(size: 14, weight: .semibold, design: .rounded))
                                }
                                
                                Spacer()
                                
                                Text(item.aisle.localized(lang: langManager.currentLanguage))
                                    .font(.system(size: 10, weight: .bold, design: .rounded))
                                    .foregroundColor(.secondary)
                                    .padding(.horizontal, 6)
                                    .padding(.vertical, 2)
                                    .background(BentoColors.bgCard)
                                    .clipShape(Capsule())
                                
                                Button(action: {
                                    var copy = item
                                    copy.id = UUID()
                                    copy.isBought = false
                                    withAnimation(.spring(response: 0.35, dampingFraction: 0.7)) {
                                        store.addGroceryItem(copy)
                                        HapticManager.shared.notification(.success)
                                    }
                                }) {
                                    HStack(spacing: 3) {
                                        Image(systemName: "plus")
                                            .font(.system(size: 10, weight: .bold))
                                        Text(langManager.currentLanguage == .chinese ? "加入买菜" : "Add to List")
                                            .font(.system(size: 11, weight: .bold, design: .rounded))
                                    }
                                    .padding(.horizontal, 9)
                                    .padding(.vertical, 5)
                                    .background(BentoColors.groceryMint.opacity(0.14))
                                    .foregroundColor(BentoColors.groceryMint)
                                    .clipShape(Capsule())
                                }
                                .bouncyTap(scale: 0.95)
                            }
                            .swipeActions(edge: .trailing, allowsFullSwipe: true) {
                                Button(role: .destructive) {
                                    withAnimation {
                                        store.removeFrequentGrocery(id: item.id)
                                    }
                                } label: {
                                    Label(langManager.currentLanguage == .chinese ? "移除" : "Remove", systemImage: "trash")
                                }
                            }
                        }
                    }
                }
            }
            .listStyle(.insetGrouped)
            .scrollDismissesKeyboard(.interactively)
            .dismissKeyboardOnTap()
            .navigationTitle(langManager.currentLanguage == .chinese ? "我的常购库" : "Frequent Items")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button(langManager.localized(.done)) { dismiss() }
                        .font(.system(size: 15, weight: .medium))
                }
                if !store.frequentGroceryList.isEmpty {
                    ToolbarItem(placement: .primaryAction) {
                        Button(role: .destructive) {
                            withAnimation {
                                store.clearAllFrequentGrocery()
                            }
                        } label: {
                            Text(langManager.currentLanguage == .chinese ? "清空" : "Clear")
                                .font(.system(size: 14, weight: .medium, design: .rounded))
                                .foregroundColor(.red)
                        }
                    }
                }
            }
        }
    }
    
    private func addCustomFrequent() {
        let name = newFrequentName.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !name.isEmpty else { return }
        
        let item = GroceryItem(
            name: name,
            aisle: newFrequentAisle,
            isFrequent: true
        )
        withAnimation(.spring(response: 0.35, dampingFraction: 0.72)) {
            store.addFrequentGrocery(item)
        }
        newFrequentName = ""
    }
}