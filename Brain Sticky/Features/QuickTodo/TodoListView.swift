//
//  TodoListView.swift
//  Brain Sticky
//
//  Created for Brain Sticky - Personal Second Brain Super App.
//

import SwiftUI

public struct TodoListView: View {
    @ObservedObject var store = DataStore.shared
    @ObservedObject var langManager = AppLanguageManager.shared
    @State private var filterMode: TodoFilter = .all
    @State private var newTodoText: String = ""
    @State private var selectedPriority: TodoPriority = .urgent
    @State private var quickMinutes: Int? = 15
    @State private var editingItem: TodoItem? = nil
    
    enum TodoFilter: String, CaseIterable {
        case all = "全部"
        case urgent = "紧急"
        case normal = "日常"
        case someday = "随缘"
        
        func title(lang: AppLanguage) -> String {
            switch self {
            case .all: return lang == .chinese ? "全部" : "All"
            case .urgent: return lang == .chinese ? "紧急" : "Urgent"
            case .normal: return lang == .chinese ? "日常" : "Normal"
            case .someday: return lang == .chinese ? "随缘" : "Someday"
            }
        }
    }
    
    var filteredTodos: [TodoItem] {
        store.todos.filter { item in
            switch filterMode {
            case .all: return true
            case .urgent: return item.priority == .urgent
            case .normal: return item.priority == .normal
            case .someday: return item.priority == .someday
            }
        }
    }
    
    @State private var itemToDelete: TodoItem? = nil
    @State private var isShowingDeleteAlert: Bool = false
    
    public var body: some View {
        VStack(spacing: 0) {
            // MARK: - 快速添加
            VStack(spacing: 8) {
                HStack(spacing: 8) {
                    Image(systemName: "bolt.horizontal.fill")
                        .foregroundColor(BentoColors.urgentCoral)
                        .font(.system(size: 14, weight: .bold))
                    
                    TextField(
                        langManager.currentLanguage == .chinese ? "待办 (如: 关火、取快递)..." : "Todo (e.g. Turn off stove, parcel)...",
                        text: $newTodoText
                    )
                    .font(.system(size: 14, weight: .medium, design: .rounded))
                    .submitLabel(.done)
                    .onSubmit(addQuickTodo)
                    
                    if !newTodoText.isEmpty {
                        Button(action: addQuickTodo) {
                            Image(systemName: "arrow.up.circle.fill")
                                .font(.system(size: 22))
                                .foregroundColor(BentoColors.urgentCoral)
                        }
                        .bouncyTap()
                    }
                }
                .padding(.horizontal, 12)
                .padding(.vertical, 8)
                .background(BentoColors.bgSecondary)
                .clipShape(RoundedRectangle(cornerRadius: 14, style: .continuous))
                
                // 定时预设 (含 ∞ 无期限) 与 优先级选择
                let minuteLabels: [(Int?, String)] = [
                    (5, langManager.currentLanguage == .chinese ? "5分" : "5m"),
                    (15, langManager.currentLanguage == .chinese ? "15分" : "15m"),
                    (30, langManager.currentLanguage == .chinese ? "30分" : "30m"),
                    (60, langManager.currentLanguage == .chinese ? "60分" : "60m"),
                    (nil as Int?, "∞")
                ]
                
                HStack(spacing: 6) {
                    ForEach(minuteLabels, id: \.1) { option in
                        Button(action: {
                            quickMinutes = option.0
                            HapticManager.shared.selection()
                        }) {
                            Text(option.1)
                                .font(.system(size: option.0 == nil ? 14 : 11, weight: .bold, design: .rounded))
                                .padding(.horizontal, option.0 == nil ? 9 : 8)
                                .padding(.vertical, 3)
                                .background(quickMinutes == option.0 ? BentoColors.urgentCoral : BentoColors.bgCard)
                                .foregroundColor(quickMinutes == option.0 ? .white : .secondary)
                                .clipShape(Capsule())
                        }
                        .bouncyTap(scale: 0.95)
                    }
                    
                    Spacer()
                    
                    Menu {
                        ForEach(TodoPriority.allCases, id: \.self) { p in
                            Button(action: {
                                selectedPriority = p
                                HapticManager.shared.selection()
                            }) {
                                HStack {
                                    Text(p.localized(lang: langManager.currentLanguage))
                                    if selectedPriority == p {
                                        Image(systemName: "checkmark")
                                    }
                                }
                            }
                        }
                    } label: {
                        HStack(spacing: 3) {
                            Circle()
                                .fill(selectedPriority.color)
                                .frame(width: 6, height: 6)
                            Text(selectedPriority.localized(lang: langManager.currentLanguage))
                                .font(.system(size: 11, weight: .bold, design: .rounded))
                                .foregroundColor(selectedPriority.color)
                            Image(systemName: "chevron.up.chevron.down")
                                .font(.system(size: 9, weight: .bold))
                                .foregroundColor(selectedPriority.color)
                        }
                        .padding(.horizontal, 8)
                        .padding(.vertical, 4)
                        .background(selectedPriority.color.opacity(0.12))
                        .clipShape(Capsule())
                    }
                }
            }
            .padding(.horizontal, 16)
            .padding(.vertical, 6)
            .background(BentoColors.bgPrimary)
            
            // MARK: - 状态筛选 (全部 | 紧急 | 日常 | 随缘 | 完成)
            Picker("Filter", selection: $filterMode) {
                ForEach(TodoFilter.allCases, id: \.self) { f in
                    Text(f.title(lang: langManager.currentLanguage)).tag(f)
                }
            }
            .pickerStyle(.segmented)
            .padding(.horizontal, 16)
            .padding(.vertical, 6)
            
            // MARK: - 列表
            List {
                if filteredTodos.isEmpty {
                    VStack(spacing: 10) {
                        Image(systemName: "sparkles")
                            .font(.system(size: 32))
                            .foregroundColor(BentoColors.urgentCoral)
                            .padding(.top, 30)
                        Text(langManager.currentLanguage == .chinese ? "无待办 🎈" : "No Todos 🎈")
                            .font(.system(size: 13, weight: .medium, design: .rounded))
                            .foregroundColor(.secondary)
                    }
                    .frame(maxWidth: .infinity)
                    .listRowBackground(Color.clear)
                } else {
                    ForEach(filteredTodos) { item in
                        TodoItemRow(
                            langManager: langManager,
                            item: item,
                            onToggle: {
                                store.toggleTodo(item)
                            },
                            onEdit: {
                                editingItem = item
                            },
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
        .navigationTitle(langManager.localized(.todoTitle))
        .navigationBarTitleDisplayMode(.inline)
        .alert(
            langManager.currentLanguage == .chinese ? "确认删除待办？" : "Delete Todo?",
            isPresented: $isShowingDeleteAlert
        ) {
            Button(langManager.currentLanguage == .chinese ? "删除" : "Delete", role: .destructive) {
                if let item = itemToDelete {
                    withAnimation {
                        store.deleteTodo(id: item.id)
                    }
                }
                itemToDelete = nil
            }
            Button(langManager.localized(.cancel), role: .cancel) {
                itemToDelete = nil
            }
        } message: {
            if let item = itemToDelete {
                Text(langManager.currentLanguage == .chinese ? "确定要删除待办「\(item.title)」吗？" : "Are you sure you want to delete \"\(item.title)\"?")
            }
        }
        .sheet(item: $editingItem) { item in
            EditTodoSheet(item: item)
        }
    }
    
    private func addQuickTodo() {
        let text = newTodoText.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !text.isEmpty else { return }
        
        let item = TodoItem(
            title: text,
            priority: selectedPriority,
            reminderMinutes: quickMinutes
        )
        store.addTodo(item)
        newTodoText = ""
    }
}

// MARK: - Todo Item Row
struct TodoItemRow: View {
    @ObservedObject var store = DataStore.shared
    @ObservedObject var langManager: AppLanguageManager
    let item: TodoItem
    let onToggle: () -> Void
    let onEdit: () -> Void
    let onDeleteRequest: () -> Void
    
    var body: some View {
        HStack(spacing: 10) {
            Button(action: {
                withAnimation(.spring()) {
                    onToggle()
                }
            }) {
                Image(systemName: item.isCompleted ? "checkmark.circle.fill" : "circle")
                    .font(.system(size: 20))
                    .foregroundColor(item.isCompleted ? BentoColors.groceryMint : (item.priority == .urgent ? BentoColors.urgentCoral : .secondary))
            }
            .buttonStyle(.plain)
            
            VStack(alignment: .leading, spacing: 2) {
                Text(item.title)
                    .font(.system(size: 14, weight: .medium, design: .rounded))
                    .strikethrough(item.isCompleted, color: .secondary)
                    .foregroundColor(item.isCompleted ? .secondary : .primary)
                
                if let mins = item.reminderMinutes {
                    Text(langManager.currentLanguage == .chinese ? "\(mins)分后" : "in \(mins)m")
                        .font(.system(size: 10, weight: .bold, design: .rounded))
                        .foregroundColor(.orange)
                }
            }
            
            Spacer()
            
            // ⚡ 帮我办 / 分享给别人
            ShareLink(
                item: "⚡【请你帮我办件事】\n\(item.title)\n\n拜托啦！谢谢你～\n— 来自 脑雾收集站 (Brain Sticky)",
                preview: SharePreview("帮我办: \(item.title)", image: Image(systemName: "bolt.horizontal.fill"))
            ) {
                Image(systemName: "square.and.arrow.up")
                    .font(.system(size: 13, weight: .semibold))
                    .foregroundColor(BentoColors.urgentCoral)
                    .padding(4)
            }
            .buttonStyle(.plain)
            
            Button(action: onEdit) {
                Image(systemName: "pencil")
                    .font(.system(size: 12))
                    .foregroundColor(.secondary)
                    .padding(4)
            }
            .buttonStyle(.plain)
        }
        .padding(.vertical, 3)
        .contentShape(Rectangle())
        .onTapGesture {
            onEdit()
        }
        .swipeActions(edge: .trailing, allowsFullSwipe: false) {
            Button(role: .destructive) {
                onDeleteRequest()
            } label: {
                Label(langManager.currentLanguage == .chinese ? "删除" : "Delete", systemImage: "trash")
            }
        }
    }
}

// MARK: - 专属待办录入弹窗 (AddTodoSheet)
struct AddTodoSheet: View {
    @Environment(\.dismiss) private var dismiss
    @ObservedObject var store = DataStore.shared
    @ObservedObject var langManager = AppLanguageManager.shared
    
    @State private var title: String = ""
    @State private var selectedPriority: TodoPriority = .urgent
    @State private var reminderMinutes: Int? = 15
    
    var isSubmitDisabled: Bool {
        title.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty
    }
    
    var body: some View {
        NavigationStack {
            ScrollView(showsIndicators: false) {
                VStack(spacing: 14) {
                    VStack(alignment: .leading, spacing: 14) {
                        // 待办内容
                        VStack(alignment: .leading, spacing: 6) {
                            Text(langManager.currentLanguage == .chinese ? "待办内容" : "Todo Details")
                                .font(.system(size: 12, weight: .bold, design: .rounded))
                                .foregroundColor(.secondary)
                            
                            TextField(
                                langManager.currentLanguage == .chinese ? "如: 关火、取快递、提交方案..." : "e.g. Turn off stove, pick up parcel...",
                                text: $title
                            )
                            .font(.system(size: 15, weight: .medium, design: .rounded))
                            .submitLabel(.done)
                            .padding(11)
                            .background(BentoColors.bgCard)
                            .clipShape(RoundedRectangle(cornerRadius: 12))
                        }
                        
                        // 优先级
                        VStack(alignment: .leading, spacing: 6) {
                            Text(langManager.currentLanguage == .chinese ? "优先级" : "Priority")
                                .font(.system(size: 12, weight: .bold, design: .rounded))
                                .foregroundColor(.secondary)
                            
                            HStack(spacing: 8) {
                                ForEach(TodoPriority.allCases, id: \.self) { priority in
                                    Button(action: {
                                        selectedPriority = priority
                                        HapticManager.shared.selection()
                                    }) {
                                        Text(priority.localized(lang: langManager.currentLanguage))
                                            .font(.system(size: 13, weight: .bold, design: .rounded))
                                            .frame(maxWidth: .infinity)
                                            .padding(.vertical, 8)
                                            .background(selectedPriority == priority ? priority.color : BentoColors.bgCard)
                                            .foregroundColor(selectedPriority == priority ? .white : .primary)
                                            .clipShape(RoundedRectangle(cornerRadius: 10))
                                    }
                                    .bouncyTap(scale: 0.96)
                                }
                            }
                        }
                        
                        // 提醒定时
                        VStack(alignment: .leading, spacing: 6) {
                            Text(langManager.currentLanguage == .chinese ? "提醒定时" : "Reminder Timer")
                                .font(.system(size: 12, weight: .bold, design: .rounded))
                                .foregroundColor(.secondary)
                            
                            let minuteOptions: [(Int?, String)] = [
                                (5, langManager.currentLanguage == .chinese ? "5分" : "5m"),
                                (15, langManager.currentLanguage == .chinese ? "15分" : "15m"),
                                (30, langManager.currentLanguage == .chinese ? "30分" : "30m"),
                                (60, langManager.currentLanguage == .chinese ? "60分" : "60m"),
                                (nil as Int?, "∞")
                            ]
                            
                            HStack(spacing: 6) {
                                ForEach(minuteOptions, id: \.1) { option in
                                    Button(action: {
                                        reminderMinutes = option.0
                                        HapticManager.shared.selection()
                                    }) {
                                        Text(option.1)
                                            .font(.system(size: option.0 == nil ? 16 : 12, weight: .bold, design: .rounded))
                                            .frame(maxWidth: .infinity)
                                            .padding(.vertical, option.0 == nil ? 6 : 8)
                                            .background(reminderMinutes == option.0 ? BentoColors.urgentCoral : BentoColors.bgCard)
                                            .foregroundColor(reminderMinutes == option.0 ? .white : .primary)
                                            .clipShape(RoundedRectangle(cornerRadius: 8))
                                    }
                                    .bouncyTap(scale: 0.96)
                                }
                            }
                        }
                    }
                    .padding(16)
                    .background(BentoColors.bgSecondary)
                    .clipShape(RoundedRectangle(cornerRadius: 20, style: .continuous))
                    .padding(.horizontal, 16)
                    .padding(.top, 10)
                    
                    // 保存按键
                    Button(action: {
                        let item = TodoItem(
                            title: title.trimmingCharacters(in: .whitespacesAndNewlines),
                            priority: selectedPriority,
                            reminderMinutes: reminderMinutes
                        )
                        store.addTodo(item)
                        HapticManager.shared.notification(.success)
                        dismiss()
                    }) {
                        Text(langManager.localized(.save))
                            .font(.system(size: 16, weight: .heavy, design: .rounded))
                            .frame(maxWidth: .infinity)
                            .padding(.vertical, 13)
                            .background(
                                isSubmitDisabled ? Color.gray.opacity(0.25) : BentoColors.urgentCoral
                            )
                            .foregroundColor(.white)
                            .clipShape(Capsule())
                            .shadow(color: isSubmitDisabled ? .clear : BentoColors.urgentCoral.opacity(0.35), radius: 8, y: 4)
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
            .navigationTitle(langManager.currentLanguage == .chinese ? "新建待办" : "New Todo")
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

// MARK: - Edit Todo Sheet
struct EditTodoSheet: View {
    @Environment(\.dismiss) private var dismiss
    @ObservedObject var store = DataStore.shared
    @ObservedObject var langManager = AppLanguageManager.shared
    @State var item: TodoItem
    @State private var isShowingDeleteConfirm: Bool = false
    
    private func reminderText(for mins: Int?) -> String {
        guard let mins = mins else {
            return langManager.currentLanguage == .chinese ? "无提醒" : "No reminder"
        }
        switch mins {
        case 5: return langManager.currentLanguage == .chinese ? "5分钟后" : "In 5 min"
        case 15: return langManager.currentLanguage == .chinese ? "15分钟后" : "In 15 min"
        case 30: return langManager.currentLanguage == .chinese ? "30分钟后" : "In 30 min"
        case 60: return langManager.currentLanguage == .chinese ? "1小时后" : "In 1 hour"
        case 120: return langManager.currentLanguage == .chinese ? "2小时后" : "In 2 hours"
        case 480: return langManager.currentLanguage == .chinese ? "今晚" : "Tonight"
        case 1440: return langManager.currentLanguage == .chinese ? "明天" : "Tomorrow"
        default: return langManager.currentLanguage == .chinese ? "\(mins)分钟后" : "In \(mins) min"
        }
    }
    
    var body: some View {
        NavigationStack {
            ScrollView(showsIndicators: false) {
                VStack(spacing: 16) {
                    // 内容编辑卡片
                    VStack(alignment: .leading, spacing: 8) {
                        Text(langManager.currentLanguage == .chinese ? "待办内容" : "Todo text")
                            .font(.system(size: 12, weight: .bold, design: .rounded))
                            .foregroundColor(.secondary)
                        
                        TextField(
                            langManager.currentLanguage == .chinese ? "待办内容..." : "Todo text...",
                            text: $item.title
                        )
                        .font(.system(size: 15, weight: .medium, design: .rounded))
                        .padding(12)
                        .background(BentoColors.bgCard)
                        .clipShape(RoundedRectangle(cornerRadius: 12, style: .continuous))
                    }
                    .padding(14)
                    .background(BentoColors.bgSecondary)
                    .clipShape(RoundedRectangle(cornerRadius: 18, style: .continuous))
                    
                    // 属性选择卡片 (下拉菜单)
                    VStack(spacing: 12) {
                        // 优先级下拉菜单
                        HStack {
                            Label(
                                langManager.currentLanguage == .chinese ? "优先级" : "Priority",
                                systemImage: "flag.fill"
                            )
                            .font(.system(size: 14, weight: .semibold, design: .rounded))
                            .foregroundColor(.primary)
                            
                            Spacer()
                            
                            Menu {
                                ForEach(TodoPriority.allCases, id: \.self) { p in
                                    Button {
                                        item.priority = p
                                        HapticManager.shared.selection()
                                    } label: {
                                        HStack {
                                            Text(p.localized(lang: langManager.currentLanguage))
                                            if item.priority == p {
                                                Image(systemName: "checkmark")
                                            }
                                        }
                                    }
                                }
                            } label: {
                                HStack(spacing: 6) {
                                    Circle()
                                        .fill(item.priority.color)
                                        .frame(width: 8, height: 8)
                                    Text(item.priority.localized(lang: langManager.currentLanguage))
                                        .font(.system(size: 14, weight: .bold, design: .rounded))
                                        .foregroundColor(item.priority.color)
                                    Image(systemName: "chevron.up.chevron.down")
                                        .font(.system(size: 11, weight: .bold))
                                        .foregroundColor(.secondary)
                                }
                                .padding(.horizontal, 12)
                                .padding(.vertical, 8)
                                .background(item.priority.color.opacity(0.12))
                                .clipShape(RoundedRectangle(cornerRadius: 10, style: .continuous))
                            }
                        }
                        
                        Divider()
                            .padding(.vertical, 2)
                        
                        // 提醒时间下拉菜单
                        HStack {
                            Label(
                                langManager.currentLanguage == .chinese ? "提醒时间" : "Reminder",
                                systemImage: "bell.fill"
                            )
                            .font(.system(size: 14, weight: .semibold, design: .rounded))
                            .foregroundColor(.primary)
                            
                            Spacer()
                            
                            Menu {
                                let options: [(Int?, String)] = [
                                    (nil, langManager.currentLanguage == .chinese ? "无提醒" : "No reminder"),
                                    (5, langManager.currentLanguage == .chinese ? "5分钟后" : "In 5 min"),
                                    (15, langManager.currentLanguage == .chinese ? "15分钟后" : "In 15 min"),
                                    (30, langManager.currentLanguage == .chinese ? "30分钟后" : "In 30 min"),
                                    (60, langManager.currentLanguage == .chinese ? "1小时后" : "In 1 hour"),
                                    (120, langManager.currentLanguage == .chinese ? "2小时后" : "In 2 hours"),
                                    (480, langManager.currentLanguage == .chinese ? "今晚" : "Tonight"),
                                    (1440, langManager.currentLanguage == .chinese ? "明天" : "Tomorrow")
                                ]
                                ForEach(options, id: \.1) { opt in
                                    Button {
                                        item.reminderMinutes = opt.0
                                        HapticManager.shared.selection()
                                    } label: {
                                        HStack {
                                            Text(opt.1)
                                            if item.reminderMinutes == opt.0 {
                                                Image(systemName: "checkmark")
                                            }
                                        }
                                    }
                                }
                            } label: {
                                HStack(spacing: 6) {
                                    Image(systemName: item.reminderMinutes == nil ? "bell.slash" : "bell.fill")
                                        .font(.system(size: 11))
                                        .foregroundColor(item.reminderMinutes == nil ? .secondary : BentoColors.urgentCoral)
                                    Text(reminderText(for: item.reminderMinutes))
                                        .font(.system(size: 14, weight: .bold, design: .rounded))
                                        .foregroundColor(item.reminderMinutes == nil ? .secondary : BentoColors.urgentCoral)
                                    Image(systemName: "chevron.up.chevron.down")
                                        .font(.system(size: 11, weight: .bold))
                                        .foregroundColor(.secondary)
                                }
                                .padding(.horizontal, 12)
                                .padding(.vertical, 8)
                                .background((item.reminderMinutes == nil ? Color.gray : BentoColors.urgentCoral).opacity(0.12))
                                .clipShape(RoundedRectangle(cornerRadius: 10, style: .continuous))
                            }
                        }
                    }
                    .padding(14)
                    .background(BentoColors.bgSecondary)
                    .clipShape(RoundedRectangle(cornerRadius: 18, style: .continuous))
                    
                    // 分享托付按钮
                    ShareLink(
                        item: "⚡【请你帮我办件事】\n\(item.title)\n\n拜托啦！谢谢你～\n— 来自 脑雾收集站 (Brain Sticky)",
                        preview: SharePreview("帮我办: \(item.title)", image: Image(systemName: "bolt.horizontal.fill"))
                    ) {
                        HStack {
                            Spacer()
                            Label(langManager.currentLanguage == .chinese ? "⚡ 请别人帮办 (分享)" : "⚡ Delegate Todo (Share)", systemImage: "square.and.arrow.up")
                                .font(.system(size: 14, weight: .bold, design: .rounded))
                                .foregroundColor(BentoColors.urgentCoral)
                            Spacer()
                        }
                        .padding(.vertical, 12)
                        .background(BentoColors.bgSecondary)
                        .clipShape(RoundedRectangle(cornerRadius: 16, style: .continuous))
                    }
                    
                    // 删除按钮
                    Button(role: .destructive) {
                        isShowingDeleteConfirm = true
                    } label: {
                        HStack {
                            Spacer()
                            Image(systemName: "trash")
                            Text(langManager.currentLanguage == .chinese ? "删除待办" : "Delete Todo")
                            Spacer()
                        }
                        .font(.system(size: 14, weight: .semibold, design: .rounded))
                        .foregroundColor(.red)
                        .padding(.vertical, 12)
                        .background(Color.red.opacity(0.1))
                        .clipShape(RoundedRectangle(cornerRadius: 16, style: .continuous))
                    }
                }
                .padding(16)
            }
            .background(BentoColors.bgPrimary.ignoresSafeArea())
            .navigationTitle(langManager.currentLanguage == .chinese ? "修改待办" : "Edit Todo")
            .navigationBarTitleDisplayMode(.inline)
            .alert(
                langManager.currentLanguage == .chinese ? "确认删除待办？" : "Delete Todo?",
                isPresented: $isShowingDeleteConfirm
            ) {
                Button(langManager.currentLanguage == .chinese ? "删除" : "Delete", role: .destructive) {
                    store.deleteTodo(id: item.id)
                    dismiss()
                }
                Button(langManager.localized(.cancel), role: .cancel) {}
            } message: {
                Text(langManager.currentLanguage == .chinese ? "确定要删除此待办吗？" : "Are you sure you want to delete this todo?")
            }
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button(langManager.localized(.cancel)) { dismiss() }
                        .font(.system(size: 15, weight: .medium))
                }
                ToolbarItem(placement: .confirmationAction) {
                    Button(langManager.localized(.save)) {
                        store.updateTodo(item)
                        HapticManager.shared.notification(.success)
                        dismiss()
                    }
                    .font(.system(size: 15, weight: .bold))
                    .foregroundColor(BentoColors.urgentCoral)
                }
            }
        }
    }
}