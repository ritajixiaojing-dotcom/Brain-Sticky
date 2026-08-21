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
    @State private var isShowingOmni: Bool = false
    @State private var editingItem: TodoItem? = nil
    
    enum TodoFilter: String, CaseIterable {
        case all = "全部"
        case urgent = "紧急"
        case normal = "日常"
        case someday = "随缘"
        case done = "完成"
        
        func title(lang: AppLanguage) -> String {
            switch self {
            case .all: return lang == .chinese ? "全部" : "All"
            case .urgent: return lang == .chinese ? "紧急" : "Urgent"
            case .normal: return lang == .chinese ? "日常" : "Normal"
            case .someday: return lang == .chinese ? "随缘" : "Someday"
            case .done: return lang == .chinese ? "完成" : "Done"
            }
        }
    }
    
    var filteredTodos: [TodoItem] {
        store.todos.filter { item in
            switch filterMode {
            case .all: return true
            case .urgent: return item.priority == .urgent && !item.isCompleted
            case .normal: return item.priority == .normal && !item.isCompleted
            case .someday: return item.priority == .someday && !item.isCompleted
            case .done: return item.isCompleted
            }
        }
    }
    
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
                
                // 定时预设 (含 ∞ 无期限) 与 优先级联动筛选
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
                                withAnimation(.spring()) {
                                    switch p {
                                    case .urgent: filterMode = .urgent
                                    case .normal: filterMode = .normal
                                    case .someday: filterMode = .someday
                                    }
                                }
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
                        HStack(spacing: 10) {
                            Button(action: {
                                withAnimation(.spring()) {
                                    store.toggleTodo(item)
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
                            
                            Button(action: { editingItem = item }) {
                                Image(systemName: "pencil")
                                    .font(.system(size: 12))
                                    .foregroundColor(.secondary)
                            }
                            .buttonStyle(.plain)
                        }
                        .padding(.vertical, 3)
                        .contentShape(Rectangle())
                        .onTapGesture {
                            editingItem = item
                        }
                        .swipeActions(edge: .trailing, allowsFullSwipe: true) {
                            Button(role: .destructive) {
                                store.deleteTodo(id: item.id)
                            } label: {
                                Label(langManager.currentLanguage == .chinese ? "删除" : "Delete", systemImage: "trash")
                            }
                        }
                    }
                }
            }
            .listStyle(.insetGrouped)
            .scrollDismissesKeyboard(.interactively)
            .dismissKeyboardOnTap()
        }
        .dismissKeyboardOnTap()
        .background(BentoColors.bgPrimary.ignoresSafeArea())
        .navigationTitle(langManager.localized(.todoTitle))
        .navigationBarTitleDisplayMode(.inline)
        .toolbar {
            ToolbarItem(placement: .primaryAction) {
                Button(action: { isShowingOmni = true }) {
                    Image(systemName: "plus")
                        .font(.system(size: 15, weight: .bold))
                }
            }
            ToolbarItemGroup(placement: .keyboard) {
                Spacer()
                Button(langManager.localized(.done)) {
                    UIApplication.shared.endEditing()
                }
                .font(.system(size: 15, weight: .bold))
                .foregroundColor(BentoColors.urgentCoral)
            }
        }
        .sheet(isPresented: $isShowingOmni) {
            AddTodoSheet()
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
                ToolbarItemGroup(placement: .keyboard) {
                    Spacer()
                    Button(langManager.localized(.done)) {
                        UIApplication.shared.endEditing()
                    }
                    .font(.system(size: 15, weight: .bold))
                    .foregroundColor(BentoColors.urgentCoral)
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
    
    var body: some View {
        NavigationStack {
            Form {
                Section(header: Text(langManager.currentLanguage == .chinese ? "内容" : "Content").font(.system(size: 11, weight: .bold, design: .rounded))) {
                    TextField(langManager.currentLanguage == .chinese ? "待办内容" : "Todo text", text: $item.title)
                }
                
                Section(header: Text(langManager.currentLanguage == .chinese ? "属性" : "Attributes").font(.system(size: 11, weight: .bold, design: .rounded))) {
                    Picker(langManager.currentLanguage == .chinese ? "优先级" : "Priority", selection: $item.priority) {
                        ForEach(TodoPriority.allCases, id: \.self) { p in
                            Text(p.localized(lang: langManager.currentLanguage)).tag(p)
                        }
                    }
                    
                    Picker(langManager.currentLanguage == .chinese ? "提醒" : "Reminder", selection: $item.reminderMinutes) {
                        Text(langManager.currentLanguage == .chinese ? "无提醒" : "No reminder").tag(nil as Int?)
                        Text(langManager.currentLanguage == .chinese ? "5分钟后" : "In 5 min").tag(5 as Int?)
                        Text(langManager.currentLanguage == .chinese ? "15分钟后" : "In 15 min").tag(15 as Int?)
                        Text(langManager.currentLanguage == .chinese ? "30分钟后" : "In 30 min").tag(30 as Int?)
                        Text(langManager.currentLanguage == .chinese ? "60分钟后" : "In 60 min").tag(60 as Int?)
                    }
                }
                
                Section {
                    Button(role: .destructive) {
                        store.deleteTodo(id: item.id)
                        dismiss()
                    } label: {
                        HStack {
                            Spacer()
                            Text(langManager.currentLanguage == .chinese ? "删除待办" : "Delete Todo")
                            Spacer()
                        }
                    }
                }
            }
            .scrollDismissesKeyboard(.interactively)
            .dismissKeyboardOnTap()
            .navigationTitle(langManager.currentLanguage == .chinese ? "修改待办" : "Edit Todo")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button(langManager.localized(.cancel)) { dismiss() }
                }
                ToolbarItem(placement: .confirmationAction) {
                    Button(langManager.localized(.save)) {
                        store.updateTodo(item)
                        HapticManager.shared.notification(.success)
                        dismiss()
                    }
                }
                ToolbarItemGroup(placement: .keyboard) {
                    Spacer()
                    Button(langManager.localized(.done)) {
                        UIApplication.shared.endEditing()
                    }
                    .font(.system(size: 15, weight: .bold))
                    .foregroundColor(BentoColors.urgentCoral)
                }
            }
        }
    }
}