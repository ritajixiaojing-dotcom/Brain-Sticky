//
//  CustomModuleDetailView.swift
//  Brain Sticky
//
//  Created for Brain Sticky - Modular Custom Feature Engine.
//

import SwiftUI

// MARK: - Built-in Habit Presets
struct BuiltinHabitPreset: Identifiable {
    let id = UUID()
    let icon: String
    let name: String
    let labelZh: String
    let labelEn: String
    let defaultDetailZh: String
    let defaultDetailEn: String
    
    var label: String {
        AppLanguageManager.shared.currentLanguage == .english ? labelEn : labelZh
    }
    
    var defaultDetail: String {
        AppLanguageManager.shared.currentLanguage == .english ? defaultDetailEn : defaultDetailZh
    }
}

let defaultBuiltinHabitPresets: [BuiltinHabitPreset] = [
    BuiltinHabitPreset(icon: "🏃", name: "跑步", labelZh: "跑步", labelEn: "Run", defaultDetailZh: "每日 30 分钟", defaultDetailEn: "30 mins daily"),
    BuiltinHabitPreset(icon: "💧", name: "喝水", labelZh: "喝水", labelEn: "Water", defaultDetailZh: "每日 2000ml", defaultDetailEn: "2000ml daily"),
    BuiltinHabitPreset(icon: "📖", name: "看书", labelZh: "看书", labelEn: "Read", defaultDetailZh: "开卷有益", defaultDetailEn: "20 pages a day"),
    BuiltinHabitPreset(icon: "🌙", name: "早睡", labelZh: "早睡", labelEn: "Sleep", defaultDetailZh: "23:00 前睡觉", defaultDetailEn: "Sleep by 23:00"),
    BuiltinHabitPreset(icon: "🦉", name: "多邻国", labelZh: "多邻国", labelEn: "Duolingo", defaultDetailZh: "每日打卡一课", defaultDetailEn: "1 lesson daily"),
    BuiltinHabitPreset(icon: "💊", name: "吃药", labelZh: "吃药", labelEn: "Meds", defaultDetailZh: "按时服用", defaultDetailEn: "Take on time"),
    BuiltinHabitPreset(icon: "🧘", name: "冥想", labelZh: "冥想", labelEn: "Meditate", defaultDetailZh: "每日 10 分钟", defaultDetailEn: "10 mins daily"),
    BuiltinHabitPreset(icon: "🍳", name: "在家做饭", labelZh: "在家做饭", labelEn: "Cook", defaultDetailZh: "少吃外卖", defaultDetailEn: "Less takeout"),
    BuiltinHabitPreset(icon: "💰", name: "记账", labelZh: "记账", labelEn: "Budget", defaultDetailZh: "记录开销", defaultDetailEn: "Track expenses"),
    BuiltinHabitPreset(icon: "👶", name: "耐心带娃", labelZh: "耐心带娃", labelEn: "Kids", defaultDetailZh: "温柔陪伴", defaultDetailEn: "Gentle parenting"),
    BuiltinHabitPreset(icon: "🐾", name: "照顾宠物", labelZh: "照顾宠物", labelEn: "Pet Care", defaultDetailZh: "遛狗/喂猫/陪伴", defaultDetailEn: "Walk dog / feed cat"),
    BuiltinHabitPreset(icon: "🧹", name: "整理房间", labelZh: "整理房间", labelEn: "Tidy Up", defaultDetailZh: "保持房间整洁", defaultDetailEn: "Keep room clean"),
    BuiltinHabitPreset(icon: "⛰️", name: "锻炼身体", labelZh: "锻炼身体", labelEn: "Workout", defaultDetailZh: "爬山看海", defaultDetailEn: "Climb & explore"),
    BuiltinHabitPreset(icon: "☕️", name: "咖啡茶饮", labelZh: "咖啡茶饮", labelEn: "Coffee/Tea", defaultDetailZh: "每日一杯", defaultDetailEn: "1 cup daily")
]

// MARK: - Custom Module Detail Screen
public struct CustomModuleDetailView: View {
    let moduleId: String
    @ObservedObject var store = DataStore.shared
    @ObservedObject var langManager = AppLanguageManager.shared
    @Environment(\.dismiss) private var dismiss
    
    @State private var isShowingEditModuleSheet = false
    @State private var isShowingCreateCustomHabitSheet = false
    @State private var isShowingClearAllItemsAlert = false
    @State private var entryToDelete: CustomEntryItem? = nil
    @State private var alreadyCheckedInAlertInfo: AlreadyCheckedInInfo? = nil
    @State private var newEntryTitle = ""
    @State private var newEntryIcon = "🎯"
    @State private var newEntryDetail = ""
    @State private var editingEntry: CustomEntryItem?
    @FocusState private var isInputFocused: Bool
    
    private var module: CustomModuleCard {
        store.customModules.first(where: { $0.id == moduleId }) ?? CustomModuleCard(id: moduleId, title: "打卡", icon: "🎯", mode: "checkin")
    }
    
    private var displayedModuleTitle: String {
        if moduleId == "custom_1" {
            let defaultNames = ["打卡", "what a day", "whataday", "Check-in", "Habit", "自定义"]
            if defaultNames.contains(module.title) {
                return langManager.localized(.habitTitle)
            }
        }
        return module.title
    }
    
    private var themeColor: Color {
        BentoColors.colorForHex(module.colorHex)
    }
    
    public init(moduleId: String) {
        self.moduleId = moduleId
    }
    
    public var body: some View {
        mainContentView
            .navigationTitle(displayedModuleTitle)
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                trailingToolbarItems
            }
            .scrollDismissesKeyboard(.interactively)
            .dismissKeyboardOnTap()
            .sheet(isPresented: $isShowingEditModuleSheet) {
                EditCustomModuleSheet(module: module)
            }
            .sheet(isPresented: $isShowingCreateCustomHabitSheet) {
                CreateCustomHabitSheet(moduleId: module.id)
            }
            .sheet(item: $editingEntry) { entry in
                EditCustomEntrySheet(moduleId: module.id, entry: entry)
            }
            .modifier(CustomModuleAlertsModifier(
                alreadyCheckedInAlertInfo: $alreadyCheckedInAlertInfo,
                entryToDelete: $entryToDelete,
                isShowingClearAllItemsAlert: $isShowingClearAllItemsAlert,
                moduleId: module.id,
                isChinese: langManager.currentLanguage == .chinese,
                store: store
            ))
    }
    
    @ViewBuilder
    private var mainContentView: some View {
        ZStack {
            CuteAmbientBackground()
            backgroundGlowView
            
            VStack(spacing: 0) {
                headerCard
                presetsBar
                inputBar
                habitListView
            }
        }
    }
    
    @ViewBuilder
    private var backgroundGlowView: some View {
        VStack {
            Circle()
                .fill(themeColor.opacity(0.35))
                .frame(width: 360, height: 360)
                .blur(radius: 70)
                .offset(y: -120)
            Spacer()
        }
        .ignoresSafeArea()
    }
    
    @ToolbarContentBuilder
    private var trailingToolbarItems: some ToolbarContent {
        if !module.entries.isEmpty {
            ToolbarItem(placement: .primaryAction) {
                Menu {
                    Button(role: .destructive) {
                        isShowingClearAllItemsAlert = true
                    } label: {
                        let labelText: String = (langManager.currentLanguage == .chinese) ? "清空所有打卡项目" : "Clear All Habits"
                        Label(labelText, systemImage: "trash")
                    }
                } label: {
                    Image(systemName: "ellipsis.circle")
                        .font(.system(size: 16, weight: .bold))
                        .foregroundColor(BentoColors.omniElectric)
                }
            }
        }
    }
    
    @ViewBuilder
    private var habitListView: some View {
        if module.entries.isEmpty {
            emptyStateView
        } else {
            List {
                ForEach(module.entries) { item in
                    habitRow(for: item)
                }
            }
            .listStyle(.plain)
            .scrollContentBackground(.hidden)
        }
    }
    
    @ViewBuilder
    private func habitRow(for item: CustomEntryItem) -> some View {
        HabitItemRow(
            moduleId: module.id,
            item: item,
            themeColor: themeColor,
            onEdit: {
                editingEntry = item
            },
            onDeleteRequest: {
                entryToDelete = item
            },
            onAlreadyCheckedIn: { title, icon in
                alreadyCheckedInAlertInfo = AlreadyCheckedInInfo(title: title, icon: icon)
            }
        )
        .listRowBackground(Color.clear)
        .listRowSeparator(.hidden)
        .listRowInsets(EdgeInsets(top: 4, leading: 16, bottom: 4, trailing: 16))
    }
    
    @ViewBuilder
    private var emptyStateView: some View {
        VStack(spacing: 10) {
            Spacer()
            Text("🎯 🏃 💧 📖")
                .font(.system(size: 34))
            Text(langManager.currentLanguage == .chinese ? "打卡清单已清空 ✨" : "Habit list is empty ✨")
                .font(.system(size: 16, weight: .bold, design: .rounded))
                .foregroundColor(.primary)
            Text(langManager.currentLanguage == .chinese ? "在上方快捷标签中轻点想要打卡的项目，或者点击「➕ 自定义目标」即可放进列表！" : "Tap tags above or add custom habits to start!")
                .font(.system(size: 13, design: .rounded))
                .foregroundColor(.secondary)
                .multilineTextAlignment(.center)
                .padding(.horizontal, 32)
            Spacer()
        }
        .frame(maxWidth: .infinity)
    }
    
    private func progressWidth(totalWidth: CGFloat, completed: Int, total: Int) -> CGFloat {
        guard total > 0 else { return 0 }
        let ratio = CGFloat(completed) / CGFloat(total)
        return totalWidth * max(0, min(1, ratio))
    }
    
    @ViewBuilder
    private var headerCard: some View {
        VStack(spacing: 10) {
            HStack(spacing: 8) {
                Text(module.icon)
                    .font(.system(size: 26))
                
                CuteHollowTitleView(
                    text: displayedModuleTitle,
                    fontSize: 22,
                    strokeColor: Color(red: 120/255, green: 112/255, blue: 135/255),
                    strokeWidth: 1.3,
                    fillColor: Color.white
                )
                
                Spacer()
                
                Button(action: { isShowingEditModuleSheet = true }) {
                    HStack(spacing: 4) {
                        Image(systemName: "paintpalette.fill")
                            .font(.system(size: 11, weight: .bold))
                        Text(langManager.currentLanguage == .chinese ? "卡片主题" : "Theme")
                            .font(.system(size: 12, weight: .bold, design: .rounded))
                    }
                    .foregroundColor(BentoColors.omniElectric)
                    .padding(.horizontal, 11)
                    .padding(.vertical, 6)
                    .background(Color.white.opacity(0.92))
                    .clipShape(Capsule())
                    .shadow(color: Color.black.opacity(0.04), radius: 3, x: 0, y: 1)
                }
                .bouncyTap()
            }
            
            let completedCount = module.entries.filter { $0.isCompleted }.count
            let total = module.entries.count
            
            HStack(spacing: 8) {
                if total > 0 {
                    HStack(spacing: 6) {
                        Text(langManager.currentLanguage == .chinese ? "今日打卡：" : "Today:")
                            .font(.system(size: 13, weight: .medium, design: .rounded))
                            .foregroundColor(.secondary)
                        Text(langManager.currentLanguage == .chinese ? "\(completedCount) / \(total) 已完成" : "\(completedCount) / \(total) Done")
                            .font(.system(size: 14, weight: .heavy, design: .rounded))
                            .foregroundColor(completedCount == total ? BentoColors.groceryMint : BentoColors.omniElectric)
                    }
                    
                    Spacer()
                } else {
                    Text(langManager.currentLanguage == .chinese ? "点击下方快捷标签或自定义按钮，将想打卡的项目放进列表 ✨" : "Tap tags below or add custom habits to start ✨")
                        .font(.system(size: 12, weight: .medium, design: .rounded))
                        .foregroundColor(.secondary)
                    Spacer()
                }
            }
            
            if total > 0 {
                GeometryReader { geo in
                    ZStack(alignment: .leading) {
                        Capsule()
                            .fill(Color.black.opacity(0.06))
                            .frame(height: 6)
                        Capsule()
                            .fill(
                                LinearGradient(
                                    colors: [themeColor, BentoColors.groceryMint],
                                    startPoint: .leading,
                                    endPoint: .trailing
                                )
                            )
                            .frame(width: progressWidth(totalWidth: geo.size.width, completed: completedCount, total: total), height: 6)
                    }
                }
                .frame(height: 6)
                .padding(.top, 2)
            }
        }
        .padding(.horizontal, 18)
        .padding(.vertical, 14)
        .background(
            LinearGradient(
                colors: [
                    themeColor.opacity(0.45),
                    Color.white.opacity(0.94)
                ],
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )
        )
        .clipShape(RoundedRectangle(cornerRadius: 20, style: .continuous))
        .overlay(
            RoundedRectangle(cornerRadius: 20, style: .continuous)
                .stroke(themeColor.opacity(0.55), lineWidth: 1.5)
        )
        .shadow(color: themeColor.opacity(0.25), radius: 12, x: 0, y: 5)
        .padding(.horizontal, 16)
        .padding(.top, 8)
        .padding(.bottom, 6)
    }
    
    @ViewBuilder
    private var presetsBar: some View {
        VStack(alignment: .leading, spacing: 6) {
            HStack {
                Text(langManager.currentLanguage == .chinese ? "点击下方快捷标签，直接放入打卡列表：" : "Tap tags below to add to habit list:")
                    .font(.system(size: 11, weight: .bold, design: .rounded))
                    .foregroundColor(.secondary)
                Spacer()
            }
            .padding(.horizontal, 18)
            
            ScrollView(.horizontal, showsIndicators: false) {
                HStack(spacing: 8) {
                    Button(action: {
                        isShowingCreateCustomHabitSheet = true
                        HapticManager.shared.selection()
                    }) {
                        HStack(spacing: 4) {
                            Image(systemName: "plus.circle.fill")
                                .font(.system(size: 13, weight: .bold))
                            Text(langManager.currentLanguage == .chinese ? "自定义目标" : "Custom")
                                .font(.system(size: 12, weight: .heavy, design: .rounded))
                        }
                        .padding(.horizontal, 12)
                        .padding(.vertical, 7)
                        .background(BentoColors.omniElectric)
                        .foregroundColor(.white)
                        .clipShape(Capsule())
                        .shadow(color: BentoColors.omniElectric.opacity(0.3), radius: 4, x: 0, y: 2)
                    }
                    .bouncyTap(scale: 0.95)
                    
                    ForEach(store.userCustomHabitPresets) { customPreset in
                        let isAlreadyAdded = module.entries.contains(where: { $0.title == customPreset.name })
                        Button(action: {
                            selectPresetHabit(icon: customPreset.icon, name: customPreset.name, detail: customPreset.defaultDetail)
                        }) {
                            HStack(spacing: 4) {
                                Text(customPreset.icon)
                                    .font(.system(size: 14))
                                Text(customPreset.name)
                                    .font(.system(size: 12, weight: .bold, design: .rounded))
                                Text("✨")
                                    .font(.system(size: 9))
                                if isAlreadyAdded {
                                    Image(systemName: "checkmark")
                                        .font(.system(size: 9, weight: .heavy))
                                        .foregroundColor(BentoColors.groceryMint)
                                }
                            }
                            .padding(.horizontal, 10)
                            .padding(.vertical, 6)
                            .background(isAlreadyAdded ? themeColor.opacity(0.35) : Color.white.opacity(0.92))
                            .foregroundColor(.primary)
                            .clipShape(Capsule())
                            .overlay(
                                Capsule()
                                    .stroke(isAlreadyAdded ? themeColor : Color.white.opacity(0.8), lineWidth: 1.2)
                            )
                            .shadow(color: Color.black.opacity(0.04), radius: 3, x: 0, y: 2)
                        }
                        .bouncyTap(scale: 0.95)
                        .contextMenu {
                            Button(role: .destructive) {
                                store.removeCustomHabitPreset(id: customPreset.id)
                            } label: {
                                Label(langManager.currentLanguage == .chinese ? "从常用栏移除" : "Remove from Presets", systemImage: "trash")
                            }
                        }
                    }
                    
                    ForEach(defaultBuiltinHabitPresets) { preset in
                        let isAlreadyAdded = module.entries.contains(where: { $0.title == preset.name })
                        Button(action: {
                            selectPresetHabit(icon: preset.icon, name: preset.name, detail: preset.defaultDetail)
                        }) {
                            HStack(spacing: 4) {
                                Text(preset.icon)
                                    .font(.system(size: 14))
                                Text(preset.label)
                                    .font(.system(size: 12, weight: .bold, design: .rounded))
                                if isAlreadyAdded {
                                    Image(systemName: "checkmark")
                                        .font(.system(size: 9, weight: .heavy))
                                        .foregroundColor(BentoColors.groceryMint)
                                }
                            }
                            .padding(.horizontal, 10)
                            .padding(.vertical, 6)
                            .background(isAlreadyAdded ? themeColor.opacity(0.35) : Color.white.opacity(0.92))
                            .foregroundColor(.primary)
                            .clipShape(Capsule())
                            .overlay(
                                Capsule()
                                    .stroke(isAlreadyAdded ? themeColor : Color.white.opacity(0.8), lineWidth: 1.2)
                            )
                            .shadow(color: Color.black.opacity(0.04), radius: 3, x: 0, y: 2)
                        }
                        .bouncyTap(scale: 0.95)
                    }
                }
                .padding(.horizontal, 16)
                .padding(.vertical, 4)
            }
        }
        .padding(.vertical, 4)
    }
    
    @ViewBuilder
    private var inputBar: some View {
        HStack(spacing: 8) {
            Menu {
                if !store.userCustomHabitPresets.isEmpty {
                    Section(header: Text(langManager.currentLanguage == .chinese ? "我的自定义打卡 ✨" : "Custom Habits ✨")) {
                        ForEach(store.userCustomHabitPresets) { customPreset in
                            Button("\(customPreset.icon) \(customPreset.name)") {
                                newEntryIcon = customPreset.icon
                                newEntryTitle = customPreset.name
                                newEntryDetail = customPreset.defaultDetail
                                HapticManager.shared.selection()
                            }
                        }
                    }
                }
                
                Section(header: Text(langManager.currentLanguage == .chinese ? "常用图标" : "Common Icons")) {
                    ForEach(defaultBuiltinHabitPresets) { preset in
                        Button("\(preset.icon) \(preset.label)") {
                            newEntryIcon = preset.icon
                            if newEntryTitle.isEmpty || defaultBuiltinHabitPresets.contains(where: { $0.name == newEntryTitle }) {
                                newEntryTitle = preset.name
                                newEntryDetail = preset.defaultDetail
                            }
                            HapticManager.shared.selection()
                        }
                    }
                }
            } label: {
                HStack(spacing: 3) {
                    Text(newEntryIcon)
                        .font(.system(size: 18))
                    Image(systemName: "chevron.down")
                        .font(.system(size: 8, weight: .bold))
                        .foregroundColor(.secondary)
                }
                .padding(.horizontal, 8)
                .padding(.vertical, 7)
                .background(themeColor.opacity(0.25))
                .clipShape(Capsule())
            }
            .bouncyTap(scale: 0.95)
            
            VStack(alignment: .leading, spacing: 2) {
                TextField(
                    langManager.currentLanguage == .chinese ? "输入任何习惯目标 (如 练琴、早睡)..." : "Enter habit (e.g. Piano, Early sleep)...",
                    text: $newEntryTitle
                )
                .font(.system(size: 15, weight: .bold, design: .rounded))
                .focused($isInputFocused)
                .submitLabel(.done)
                .onChange(of: newEntryTitle) { oldValue, newValue in
                    if newEntryIcon == "🎯" {
                        let suggested = CustomEntryItem.suggestIcon(for: newValue)
                        if suggested != "🎯" {
                            newEntryIcon = suggested
                        }
                    }
                }
                .onSubmit(quickAddEntry)
                
                TextField(
                    langManager.currentLanguage == .chinese ? "备注/目标 (如 每日15分钟, 睡前完成)..." : "Notes (e.g. 15 mins daily, before sleep)...",
                    text: $newEntryDetail
                )
                .font(.system(size: 11, design: .rounded))
                .foregroundColor(.secondary)
            }
            
            HStack(spacing: 6) {
                Button(action: quickAddEntry) {
                    Image(systemName: "plus.circle.fill")
                        .font(.system(size: 30))
                        .foregroundColor(newEntryTitle.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty ? BentoColors.omniElectric.opacity(0.35) : BentoColors.omniElectric)
                }
                .bouncyTap()
                .disabled(newEntryTitle.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty)
                
                Button(action: quickMinusAction) {
                    Image(systemName: "minus.circle.fill")
                        .font(.system(size: 30))
                        .foregroundColor((newEntryTitle.isEmpty && module.entries.isEmpty) ? BentoColors.urgentCoral.opacity(0.3) : BentoColors.urgentCoral)
                }
                .bouncyTap(scale: 0.88)
                .disabled(newEntryTitle.isEmpty && module.entries.isEmpty)
            }
        }
        .padding(.horizontal, 14)
        .padding(.vertical, 8)
        .background(Color.white.opacity(0.95))
        .clipShape(RoundedRectangle(cornerRadius: 18, style: .continuous))
        .overlay(
            RoundedRectangle(cornerRadius: 18, style: .continuous)
                .stroke(Color.white.opacity(0.85), lineWidth: 1.2)
        )
        .shadow(color: Color(red: 145/255, green: 135/255, blue: 165/255).opacity(0.1), radius: 8, x: 0, y: 3)
        .padding(.horizontal, 16)
        .padding(.vertical, 4)
    }
    
    // 快捷从预设栏点选加入单列打卡列表 (防重复添加并提示今日已打卡)
    private func selectPresetHabit(icon: String, name: String, detail: String) {
        if let existing = module.entries.first(where: { $0.title == name }) {
            let isCheckedInToday = (existing.isCompleted || existing.count >= 1) && existing.isWithin24Hours
            if isCheckedInToday {
                alreadyCheckedInAlertInfo = AlreadyCheckedInInfo(title: existing.title, icon: existing.icon)
                HapticManager.shared.notification(.warning)
            } else {
                withAnimation(.spring(response: 0.32, dampingFraction: 0.65)) {
                    _ = store.incrementEntryCountInModule(moduleId: module.id, entryId: existing.id)
                }
            }
        } else {
            let entry = CustomEntryItem(title: name, icon: icon, detail: detail, isCompleted: false)
            withAnimation(.spring(response: 0.35, dampingFraction: 0.72)) {
                store.addEntryToModule(moduleId: module.id, entry: entry)
            }
            HapticManager.shared.notification(.success)
        }
    }
    
    private func quickAddEntry() {
        let title = newEntryTitle.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !title.isEmpty else { return }
        
        if let existing = module.entries.first(where: { $0.title == title }) {
            let isCheckedInToday = (existing.isCompleted || existing.count >= 1) && existing.isWithin24Hours
            if isCheckedInToday {
                alreadyCheckedInAlertInfo = AlreadyCheckedInInfo(title: existing.title, icon: existing.icon)
                HapticManager.shared.notification(.warning)
                newEntryTitle = ""
                newEntryDetail = ""
                isInputFocused = false
                return
            } else {
                withAnimation(.spring(response: 0.32, dampingFraction: 0.65)) {
                    _ = store.incrementEntryCountInModule(moduleId: module.id, entryId: existing.id)
                }
                newEntryTitle = ""
                newEntryDetail = ""
                isInputFocused = false
                return
            }
        }
        
        let entry = CustomEntryItem(
            title: title,
            icon: newEntryIcon,
            detail: newEntryDetail,
            isCompleted: false
        )
        
        // 自动将自定义目标加入到快捷常用习惯栏中
        store.addCustomHabitPreset(name: title, icon: newEntryIcon, detail: newEntryDetail)
        
        withAnimation(.spring(response: 0.35, dampingFraction: 0.72)) {
            store.addEntryToModule(moduleId: module.id, entry: entry)
        }
        newEntryTitle = ""
        newEntryDetail = ""
        isInputFocused = false
    }
    
    private func quickMinusAction() {
        if !newEntryTitle.isEmpty {
            withAnimation(.spring(response: 0.25, dampingFraction: 0.7)) {
                newEntryTitle = ""
                newEntryDetail = ""
            }
            HapticManager.shared.impact(.light)
        } else if let last = module.entries.last {
            withAnimation(.spring(response: 0.35, dampingFraction: 0.72)) {
                store.deleteEntryFromModule(moduleId: module.id, entryId: last.id)
            }
            HapticManager.shared.notification(.warning)
        }
    }
}

// MARK: - Create Custom Habit Sheet (真正自由自定义新目标，并自动同步到快捷选择栏)
struct CreateCustomHabitSheet: View {
    let moduleId: String
    @Environment(\.dismiss) private var dismiss
    @ObservedObject var store = DataStore.shared
    @ObservedObject var langManager = AppLanguageManager.shared
    
    @State private var habitTitle = ""
    @State private var habitIcon = "🎯"
    @State private var habitDetail = ""
    @FocusState private var isTitleFocused: Bool
    
    private let emojiGrid = [
        "🎯", "✨", "🧘", "🎸", "🎹", "🎨", "📚", "🏃", 
        "🏊", "🚴", "🥗", "🍵", "🥤", "🌙", "☀️", "💡", 
        "🧴", "🍳", "🌱", "🧹", "🎧", "✍️", "🧗", "🪥", 
        "💊", "❤️", "🐾", "💰", "👶", "💧", "🦉", "🔥"
    ]
    
    var body: some View {
        NavigationStack {
            Form {
                Section(header: Text(langManager.currentLanguage == .chinese ? "自定义习惯名称（将自动出现在常用习惯栏）" : "Habit Name (Auto-added to Presets)").font(.system(size: 11, weight: .bold, design: .rounded))) {
                    HStack(spacing: 12) {
                        Text(habitIcon)
                            .font(.system(size: 28))
                            .frame(width: 44, height: 44)
                            .background(BentoColors.omniElectric.opacity(0.12))
                            .clipShape(RoundedRectangle(cornerRadius: 12, style: .continuous))
                        
                        TextField(
                            langManager.currentLanguage == .chinese ? "例如: 练琴、背诗、跳绳、早起瑜伽..." : "e.g. Piano, Reading, Yoga...",
                            text: $habitTitle
                        )
                        .font(.system(size: 16, weight: .bold, design: .rounded))
                        .focused($isTitleFocused)
                        .onChange(of: habitTitle) { oldValue, newValue in
                            if habitIcon == "🎯" {
                                let suggested = CustomEntryItem.suggestIcon(for: newValue)
                                if suggested != "🎯" {
                                    habitIcon = suggested
                                }
                            }
                        }
                    }
                }
                
                Section(header: Text(langManager.currentLanguage == .chinese ? "选择专属可爱 Icon" : "Choose Cute Icon").font(.system(size: 11, weight: .bold, design: .rounded))) {
                    LazyVGrid(columns: Array(repeating: GridItem(.flexible(), spacing: 8), count: 6), spacing: 10) {
                        ForEach(emojiGrid, id: \.self) { emoji in
                            Button(action: {
                                habitIcon = emoji
                                HapticManager.shared.selection()
                            }) {
                                Text(emoji)
                                    .font(.system(size: 22))
                                    .frame(width: 44, height: 44)
                                    .background(habitIcon == emoji ? BentoColors.omniElectric.opacity(0.2) : Color.black.opacity(0.04))
                                    .clipShape(RoundedRectangle(cornerRadius: 10, style: .continuous))
                                    .overlay(
                                        RoundedRectangle(cornerRadius: 10, style: .continuous)
                                            .stroke(habitIcon == emoji ? BentoColors.omniElectric : Color.clear, lineWidth: 2)
                                    )
                            }
                            .buttonStyle(.plain)
                        }
                    }
                    .padding(.vertical, 6)
                }
                
                Section(header: Text(langManager.currentLanguage == .chinese ? "备注或目标频次（选填）" : "Notes or Frequency (Optional)").font(.system(size: 11, weight: .bold, design: .rounded))) {
                    TextField(
                        langManager.currentLanguage == .chinese ? "例如: 每日 15 分钟、每周 3 次、睡前完成" : "e.g. 15 mins daily, 3 times a week",
                        text: $habitDetail
                    )
                    .font(.system(size: 14, design: .rounded))
                }
            }
            .navigationTitle(langManager.currentLanguage == .chinese ? "自定义打卡目标" : "Custom Habit Goal")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button(langManager.localized(.cancel)) { dismiss() }
                }
                ToolbarItem(placement: .confirmationAction) {
                    Button(langManager.currentLanguage == .chinese ? "保存并添加" : "Save & Add") {
                        let title = habitTitle.trimmingCharacters(in: .whitespacesAndNewlines)
                        guard !title.isEmpty else { return }
                        if let mod = store.customModules.first(where: { $0.id == moduleId }),
                           let existing = mod.entries.first(where: { $0.title == title }) {
                            // 已存在此项，同步更新预设即可
                            store.addCustomHabitPreset(name: title, icon: habitIcon, detail: habitDetail)
                            dismiss()
                            return
                        }
                        let entry = CustomEntryItem(
                            title: title,
                            icon: habitIcon,
                            detail: habitDetail,
                            isCompleted: false
                        )
                        // 1. 添加到打卡条目
                        store.addEntryToModule(moduleId: moduleId, entry: entry)
                        // 2. 自动同步到常用习惯选择栏
                        store.addCustomHabitPreset(name: title, icon: habitIcon, detail: habitDetail)
                        HapticManager.shared.notification(.success)
                        dismiss()
                    }
                    .font(.system(size: 15, weight: .bold))
                    .disabled(habitTitle.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty)
                }
            }
            .onAppear {
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {
                    isTitleFocused = true
                }
            }
        }
    }
}

// MARK: - Habit Item Row (支持【今日已打卡】锁定与点击弹窗提示)
struct HabitItemRow: View {
    let moduleId: String
    let item: CustomEntryItem
    let themeColor: Color
    var onEdit: () -> Void
    var onDeleteRequest: () -> Void
    var onAlreadyCheckedIn: (String, String) -> Void
    @ObservedObject var store = DataStore.shared
    @ObservedObject var langManager = AppLanguageManager.shared
    
    private var isCheckedInToday: Bool {
        (item.isCompleted || item.count >= 1) && item.isWithin24Hours
    }
    
    var body: some View {
        HStack(spacing: 12) {
            // 左侧：专属可爱 Icon
            Text(item.icon)
                .font(.system(size: 22))
                .frame(width: 42, height: 42)
                .background(isCheckedInToday ? BentoColors.groceryMint.opacity(0.18) : themeColor.opacity(0.35))
                .clipShape(RoundedRectangle(cornerRadius: 12, style: .continuous))
                .onTapGesture { onEdit() }
            
            // 中间：习惯标题与描述备注
            VStack(alignment: .leading, spacing: 3) {
                Text(item.title)
                    .font(.system(size: 16, weight: .bold, design: .rounded))
                    .strikethrough(isCheckedInToday, color: .secondary)
                    .foregroundColor(isCheckedInToday ? .secondary : .primary)
                
                if !item.detail.isEmpty {
                    Text(item.detail)
                        .font(.system(size: 12, design: .rounded))
                        .foregroundColor(.secondary)
                }
            }
            .onTapGesture { onEdit() }
            
            Spacer()
            
            // 右侧：打卡按钮 (点击打卡显示今日已打卡，就不能再点了，点了就显示弹出窗口)
            Button(action: {
                if isCheckedInToday {
                    onAlreadyCheckedIn(item.title, item.icon)
                } else {
                    withAnimation(.spring(response: 0.32, dampingFraction: 0.65)) {
                        let result = store.incrementEntryCountInModule(moduleId: moduleId, entryId: item.id)
                        if !result.success {
                            onAlreadyCheckedIn(item.title, item.icon)
                        }
                    }
                }
            }) {
                if isCheckedInToday {
                    HStack(spacing: 5) {
                        Image(systemName: "checkmark.seal.fill")
                            .font(.system(size: 13, weight: .bold))
                            .foregroundColor(BentoColors.groceryMint)
                        Text(langManager.currentLanguage == .chinese ? "今日已打卡" : "Done Today")
                            .font(.system(size: 12, weight: .heavy, design: .rounded))
                            .foregroundColor(BentoColors.groceryMint)
                    }
                    .padding(.horizontal, 11)
                    .padding(.vertical, 7)
                    .background(BentoColors.groceryMint.opacity(0.15))
                    .clipShape(Capsule())
                    .overlay(
                        Capsule().stroke(BentoColors.groceryMint.opacity(0.35), lineWidth: 1.2)
                    )
                } else {
                    HStack(spacing: 4) {
                        Image(systemName: "plus.circle.fill")
                            .font(.system(size: 14, weight: .bold))
                            .foregroundColor(themeColor)
                        Text(langManager.currentLanguage == .chinese ? "打卡 +1" : "Check-in +1")
                            .font(.system(size: 12, weight: .bold, design: .rounded))
                            .foregroundColor(.primary)
                    }
                    .padding(.horizontal, 11)
                    .padding(.vertical, 7)
                    .background(themeColor.opacity(0.28))
                    .clipShape(Capsule())
                    .overlay(
                        Capsule().stroke(themeColor.opacity(0.55), lineWidth: 1)
                    )
                }
            }
            .buttonStyle(.plain)
            .bouncyTap(scale: 0.9)
        }
        .padding(.horizontal, 14)
        .padding(.vertical, 10)
        .background(Color.white.opacity(0.94))
        .clipShape(RoundedRectangle(cornerRadius: 18, style: .continuous))
        .overlay(
            RoundedRectangle(cornerRadius: 18, style: .continuous)
                .stroke(isCheckedInToday ? Color.white.opacity(0.85) : themeColor.opacity(0.3), lineWidth: 1.0)
        )
        .shadow(color: Color(red: 145/255, green: 135/255, blue: 165/255).opacity(0.08), radius: 6, x: 0, y: 2)
        .swipeActions(edge: .trailing, allowsFullSwipe: false) {
            Button(role: .destructive) {
                onDeleteRequest()
            } label: {
                Label(langManager.currentLanguage == .chinese ? "删除" : "Delete", systemImage: "trash")
            }
        }
    }
}

// MARK: - Edit Custom Entry Sheet
struct EditCustomEntrySheet: View {
    @Environment(\.dismiss) private var dismiss
    @ObservedObject var store = DataStore.shared
    @ObservedObject var langManager = AppLanguageManager.shared
    
    let moduleId: String
    @State var entry: CustomEntryItem
    
    private let emojiGrid = [
        "🎯", "✨", "🧘", "🎸", "🎹", "🎨", "📚", "🏃", 
        "🏊", "🚴", "🥗", "🍵", "🥤", "🌙", "☀️", "💡", 
        "🧴", "🍳", "🌱", "🧹", "🎧", "✍️", "🧗", "🪥", 
        "💊", "❤️", "🐾", "💰", "👶", "💧", "🦉", "🔥"
    ]
    
    var body: some View {
        NavigationStack {
            Form {
                Section(header: Text(langManager.currentLanguage == .chinese ? "专属 Icon 与名称" : "Icon & Name").font(.system(size: 11, weight: .bold, design: .rounded))) {
                    HStack(spacing: 12) {
                        Text(entry.icon)
                            .font(.system(size: 28))
                            .frame(width: 44, height: 44)
                            .background(BentoColors.omniElectric.opacity(0.12))
                            .clipShape(RoundedRectangle(cornerRadius: 10))
                        
                        TextField(langManager.currentLanguage == .chinese ? "打卡习惯名称" : "Habit Name", text: $entry.title)
                            .font(.system(size: 16, weight: .bold, design: .rounded))
                    }
                    
                    ScrollView(.horizontal, showsIndicators: false) {
                        HStack(spacing: 8) {
                            ForEach(emojiGrid, id: \.self) { emoji in
                                Button(action: {
                                    entry.icon = emoji
                                    HapticManager.shared.selection()
                                }) {
                                    Text(emoji)
                                        .font(.system(size: 20))
                                        .padding(6)
                                        .background(entry.icon == emoji ? BentoColors.omniElectric.opacity(0.2) : Color.clear)
                                        .clipShape(RoundedRectangle(cornerRadius: 8))
                                }
                                .buttonStyle(.plain)
                            }
                        }
                        .padding(.vertical, 4)
                    }
                }
                
                Section(header: Text(langManager.currentLanguage == .chinese ? "备注或目标" : "Notes or Goal").font(.system(size: 11, weight: .bold, design: .rounded))) {
                    TextField(langManager.currentLanguage == .chinese ? "例如: 每日 15 分钟、每周 3 次" : "e.g. 15 mins daily, 3 times a week", text: $entry.detail)
                        .font(.system(size: 14, design: .rounded))
                }
                
                Section {
                    Button(role: .destructive) {
                        store.deleteEntryFromModule(moduleId: moduleId, entryId: entry.id)
                        dismiss()
                    } label: {
                        HStack {
                            Spacer()
                            Text(langManager.currentLanguage == .chinese ? "删除此打卡项" : "Delete Habit")
                            Spacer()
                        }
                    }
                }
            }
            .navigationTitle(langManager.currentLanguage == .chinese ? "修改习惯项" : "Edit Habit")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button(langManager.localized(.cancel)) { dismiss() }
                }
                ToolbarItem(placement: .confirmationAction) {
                    Button(langManager.localized(.save)) {
                        if let mIdx = store.customModules.firstIndex(where: { $0.id == moduleId }),
                           let eIdx = store.customModules[mIdx].entries.firstIndex(where: { $0.id == entry.id }) {
                            store.customModules[mIdx].entries[eIdx] = entry
                            store.addCustomHabitPreset(name: entry.title, icon: entry.icon, detail: entry.detail)
                            HapticManager.shared.notification(.success)
                        }
                        dismiss()
                    }
                    .font(.system(size: 15, weight: .bold))
                }
            }
        }
    }
}

// MARK: - 极简轻量版 Edit Custom Module Sheet (只保留模块名称与卡片主题色)
struct EditCustomModuleSheet: View {
    @Environment(\.dismiss) private var dismiss
    @ObservedObject var store = DataStore.shared
    @ObservedObject var langManager = AppLanguageManager.shared
    
    @State var module: CustomModuleCard
    
    private var colorPresets: [(String, String)] {
        langManager.currentLanguage == .chinese ? [
            ("#E0F2FE", "晴空蓝"),
            ("#DCFCE7", "薄荷绿"),
            ("#FFE4E6", "樱花粉"),
            ("#FEF3C7", "暖阳黄"),
            ("#F3E8FF", "薰衣草"),
            ("#FFEDD5", "蜜桃橙"),
            ("#ECFCCB", "抹茶绿"),
            ("#FCE7F3", "蔷薇粉")
        ] : [
            ("#E0F2FE", "Sky Blue"),
            ("#DCFCE7", "Mint"),
            ("#FFE4E6", "Sakura"),
            ("#FEF3C7", "Sun Yellow"),
            ("#F3E8FF", "Lavender"),
            ("#FFEDD5", "Peach"),
            ("#ECFCCB", "Matcha"),
            ("#FCE7F3", "Rose")
        ]
    }
    
    private let emojiGrid = [
        "🎯", "✨", "🧘", "🎸", "🎹", "🎨", "📚", "🏃", 
        "🏊", "🚴", "🥗", "🍵", "🥤", "🌙", "☀️", "💡", 
        "🧴", "🍳", "🌱", "🧹", "🎧", "✍️", "🧗", "🪥", 
        "💊", "❤️", "🐾", "💰", "👶", "💧", "🦉", "🔥"
    ]
    
    var body: some View {
        NavigationStack {
            Form {
                // 1. 模块名称
                Section(header: Text(langManager.currentLanguage == .chinese ? "模块名称与图标" : "Module Name & Icon").font(.system(size: 11, weight: .bold, design: .rounded))) {
                    HStack(spacing: 12) {
                        Text(module.icon)
                            .font(.system(size: 28))
                            .frame(width: 44, height: 44)
                            .background(BentoColors.colorForHex(module.colorHex).opacity(0.35))
                            .clipShape(RoundedRectangle(cornerRadius: 10))
                        
                        TextField(
                            langManager.currentLanguage == .chinese ? "输入模块名称 (如 打卡、好习惯)" : "Module Name (e.g. Habits)",
                            text: $module.title
                        )
                        .font(.system(size: 16, weight: .bold, design: .rounded))
                        
                        if !module.title.isEmpty {
                            Button(action: {
                                module.title = ""
                                HapticManager.shared.impact(.light)
                            }) {
                                Image(systemName: "xmark.circle.fill")
                                    .foregroundColor(.secondary)
                            }
                            .buttonStyle(.plain)
                        }
                    }
                    
                    ScrollView(.horizontal, showsIndicators: false) {
                        HStack(spacing: 8) {
                            ForEach(emojiGrid, id: \.self) { emoji in
                                Button(action: {
                                    module.icon = emoji
                                    if module.title == "打卡" || module.title == "自定义" || module.title == "Check-in" || module.title == "Habits" {
                                        module.title = "" // 选了某个图标后，名称留空白让用户自己输入
                                    }
                                    HapticManager.shared.selection()
                                }) {
                                    Text(emoji)
                                        .font(.system(size: 22))
                                        .padding(6)
                                        .background(module.icon == emoji ? BentoColors.omniElectric.opacity(0.18) : Color.clear)
                                        .clipShape(RoundedRectangle(cornerRadius: 8))
                                }
                                .buttonStyle(.plain)
                            }
                        }
                        .padding(.vertical, 4)
                    }
                }
                
                // 2. 卡片主题色
                Section(header: Text(langManager.currentLanguage == .chinese ? "卡片主题色" : "Card Theme Color").font(.system(size: 11, weight: .bold, design: .rounded))) {
                    LazyVGrid(columns: Array(repeating: GridItem(.flexible(), spacing: 10), count: 4), spacing: 12) {
                        ForEach(colorPresets, id: \.0) { hex, name in
                            VStack(spacing: 4) {
                                ZStack {
                                    Circle()
                                        .fill(BentoColors.colorForHex(hex))
                                        .frame(width: 42, height: 42)
                                        .shadow(color: BentoColors.colorForHex(hex).opacity(0.4), radius: 4, x: 0, y: 2)
                                    
                                    if module.colorHex.uppercased() == hex.uppercased() {
                                        Image(systemName: "checkmark")
                                            .font(.system(size: 14, weight: .heavy))
                                            .foregroundColor(Color.black.opacity(0.65))
                                    }
                                }
                                .overlay(
                                    Circle()
                                        .stroke(module.colorHex.uppercased() == hex.uppercased() ? Color.primary : Color.white, lineWidth: 2)
                                )
                                
                                Text(name)
                                    .font(.system(size: 11, weight: .semibold, design: .rounded))
                                    .foregroundColor(.secondary)
                            }
                            .onTapGesture {
                                module.colorHex = hex
                                HapticManager.shared.selection()
                            }
                        }
                    }
                    .padding(.vertical, 6)
                }
            }
            .navigationTitle(langManager.currentLanguage == .chinese ? "卡片主题" : "Card Theme")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button(langManager.localized(.cancel)) { dismiss() }
                }
                ToolbarItem(placement: .confirmationAction) {
                    Button(langManager.localized(.save)) {
                        let finalTitle = module.title.trimmingCharacters(in: .whitespacesAndNewlines)
                        module.title = finalTitle.isEmpty ? (langManager.currentLanguage == .chinese ? "打卡" : "Habits") : finalTitle
                        store.updateCustomModule(module)
                        HapticManager.shared.notification(.success)
                        dismiss()
                    }
                    .font(.system(size: 15, weight: .bold))
                }
            }
            .onAppear {
                if module.title == "打卡" || module.title == "自定义" || module.title == "Check-in" || module.title == "Habits" {
                    module.title = "" // 留空白，方便用户直接输入自定义文字
                }
            }
        }
    }
}

// MARK: - Bento Custom Card for Dashboard (首页 6 大模块之一，清晰显现所选主题色)
public struct BentoCustomCardView: View {
    let slotId: String
    @ObservedObject var store = DataStore.shared
    @ObservedObject var langManager = AppLanguageManager.shared
    
    private var module: CustomModuleCard {
        store.customModules.first(where: { $0.id == slotId }) ?? CustomModuleCard(id: slotId, title: "打卡")
    }
    
    private var displayedTitle: String {
        if slotId == "custom_1" {
            let defaultNames = ["打卡", "what a day", "whataday", "Check-in", "Habit", "自定义"]
            if defaultNames.contains(module.title) {
                return langManager.localized(.habitTitle)
            }
        }
        return module.title
    }
    
    private var cardThemeColor: Color {
        BentoColors.colorForHex(module.colorHex)
    }
    
    public init(slotId: String) {
        self.slotId = slotId
    }
    
    public var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            // Header
            HStack(spacing: 8) {
                Text(module.icon)
                    .font(.system(size: 16))
                    .frame(width: 28, height: 28)
                    .background(Color.white.opacity(0.65))
                    .clipShape(RoundedRectangle(cornerRadius: 10, style: .continuous))
                
                CuteHollowTitleView(
                    text: displayedTitle,
                    fontSize: 17,
                    strokeColor: Color(red: 120/255, green: 112/255, blue: 135/255),
                    strokeWidth: 1.2,
                    fillColor: Color.white
                )
                
                Spacer()
                
                if module.entries.count > 0 {
                    let completed = module.entries.filter { $0.isCompleted }.count
                    Text("\(completed)/\(module.entries.count)")
                        .font(.system(size: 12, weight: .heavy, design: .rounded))
                        .foregroundColor(completed == module.entries.count ? BentoColors.groceryMint : BentoColors.omniElectric)
                        .padding(.horizontal, 8)
                        .padding(.vertical, 3)
                        .background(Color.white.opacity(0.85))
                        .clipShape(Capsule())
                }
            }
            
            // Content
            VStack(alignment: .leading, spacing: 6) {
                if module.entries.isEmpty {
                    Text(langManager.localized(.emptyHabit))
                        .font(.system(size: 12, weight: .medium, design: .rounded))
                        .foregroundColor(.secondary)
                        .frame(minHeight: 70, alignment: .topLeading)
                } else {
                    // 首页展示真实的习惯项与完成状态词语
                    ForEach(module.entries.prefix(2)) { item in
                        HStack(spacing: 4) {
                            Text(item.icon)
                                .font(.system(size: 13))
                            Text(item.title)
                                .font(.system(size: 13, weight: .bold, design: .rounded))
                                .foregroundColor(.primary)
                                .lineLimit(1)
                            
                            Spacer()
                            
                            if item.isCompleted {
                                Text(langManager.localized(.statusCompleted))
                                    .font(.system(size: 11, weight: .heavy, design: .rounded))
                                    .foregroundColor(BentoColors.groceryMint)
                            } else {
                                Text(langManager.localized(.statusPending))
                                    .font(.system(size: 11, weight: .bold, design: .rounded))
                                    .foregroundColor(.secondary)
                            }
                        }
                    }
                    
                    // 进度条
                    let total = module.entries.count
                    let completed = module.entries.filter { $0.isCompleted }.count
                    GeometryReader { geo in
                        ZStack(alignment: .leading) {
                            Capsule()
                                .fill(Color.black.opacity(0.06))
                                .frame(height: 5)
                            Capsule()
                                .fill(BentoColors.groceryMint)
                                .frame(width: geo.size.width * CGFloat(total > 0 ? Double(completed) / Double(total) : 0), height: 5)
                        }
                    }
                    .frame(height: 5)
                    .padding(.top, 4)
                }
            }
            .frame(minHeight: 70, alignment: .topLeading)
        }
        .padding(16)
        .frame(maxWidth: .infinity, minHeight: 152, alignment: .topLeading)
        .background(
            LinearGradient(
                colors: [
                    cardThemeColor.opacity(0.42),
                    Color.white.opacity(0.94)
                ],
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )
        )
        .clipShape(RoundedRectangle(cornerRadius: 22, style: .continuous))
        .overlay(
            RoundedRectangle(cornerRadius: 22, style: .continuous)
                .stroke(cardThemeColor.opacity(0.5), lineWidth: 1.2)
        )
        .shadow(color: cardThemeColor.opacity(0.2), radius: 10, x: 0, y: 4)
        .shadow(color: Color.black.opacity(0.03), radius: 2, x: 0, y: 1)
    }
}

// MARK: - Custom Module Alerts Modifier
struct CustomModuleAlertsModifier: ViewModifier {
    @Binding var alreadyCheckedInAlertInfo: AlreadyCheckedInInfo?
    @Binding var entryToDelete: CustomEntryItem?
    @Binding var isShowingClearAllItemsAlert: Bool
    let moduleId: String
    let isChinese: Bool
    @ObservedObject var store: DataStore

    func body(content: Content) -> some View {
        content
            .alert(
                isChinese ? "今日已打卡" : "Already Checked In Today",
                isPresented: Binding(
                    get: { alreadyCheckedInAlertInfo != nil },
                    set: { if !$0 { alreadyCheckedInAlertInfo = nil } }
                ),
                presenting: alreadyCheckedInAlertInfo
            ) { _ in
                Button(isChinese ? "我知道了" : "OK", role: .cancel) {
                    alreadyCheckedInAlertInfo = nil
                }
            } message: { info in
                Text(isChinese
                     ? "「\(info.icon) \(info.title)」今日已打卡，不可重复打卡 ✨"
                     : "\"\(info.title)\" has already been checked in today!")
            }
            .alert(
                isChinese ? "确认删除此打卡项？" : "Delete Habit Item?",
                isPresented: Binding(
                    get: { entryToDelete != nil },
                    set: { if !$0 { entryToDelete = nil } }
                ),
                presenting: entryToDelete
            ) { item in
                Button(isChinese ? "删除" : "Delete", role: .destructive) {
                    withAnimation(.spring(response: 0.35, dampingFraction: 0.72)) {
                        store.deleteEntryFromModule(moduleId: moduleId, entryId: item.id)
                    }
                    entryToDelete = nil
                }
                Button(isChinese ? "取消" : "Cancel", role: .cancel) {
                    entryToDelete = nil
                }
            } message: { item in
                Text(isChinese ? "确定要删除「\(item.icon) \(item.title)」吗？此操作无法撤销。" : "Are you sure you want to delete \"\(item.title)\"?")
            }
            .alert(
                isChinese ? "确认清空打卡列表中的所有项目？" : "Clear all items in habit list?",
                isPresented: $isShowingClearAllItemsAlert
            ) {
                Button(isChinese ? "清空全部" : "Clear All", role: .destructive) {
                    withAnimation(.spring(response: 0.35, dampingFraction: 0.72)) {
                        store.clearAllEntriesInModule(moduleId: moduleId)
                    }
                }
                Button(isChinese ? "取消" : "Cancel", role: .cancel) {}
            } message: {
                Text(isChinese ? "此操作会删除当前列表中的全部项目，方便您重新从上方点选或自定义添加。" : "This will delete all items in the current habit list.")
            }
    }
}

