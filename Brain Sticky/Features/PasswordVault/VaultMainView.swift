//
//  VaultMainView.swift
//  Brain Sticky
//
//  Created for Brain Sticky - Personal Second Brain Super App.
//

import SwiftUI

public struct VaultMainView: View {
    @ObservedObject var store = DataStore.shared
    @ObservedObject var langManager = AppLanguageManager.shared
    
    @State private var isShowingAddSheet: Bool = false
    @State private var editingItem: VaultItem? = nil
    @State private var largeDisplayItem: VaultItem? = nil
    @State private var toastMessage: String? = nil
    
    public var body: some View {
        VStack(spacing: 0) {
            List {
                if store.vaultItems.isEmpty {
                    VStack(spacing: 8) {
                        Text("🔐")
                            .font(.system(size: 32))
                            .padding(.top, 40)
                        Text(langManager.currentLanguage == .chinese ? "暂无密码记录" : "No Passwords Stored")
                            .font(.system(size: 13, weight: .medium, design: .rounded))
                            .foregroundColor(.secondary)
                    }
                    .frame(maxWidth: .infinity)
                    .listRowBackground(Color.clear)
                } else {
                    ForEach(store.vaultItems) { item in
                        VaultItemCardRow(
                            item: item,
                            onCopy: { text in
                                UIPasteboard.general.string = text
                                showToast(langManager.currentLanguage == .chinese ? "已复制" : "Copied")
                                HapticManager.shared.notification(.success)
                            },
                            onEdit: {
                                editingItem = item
                            },
                            onLargeDisplay: {
                                largeDisplayItem = item
                            }
                        )
                        .listRowBackground(Color.clear)
                        .listRowInsets(EdgeInsets(top: 4, leading: 16, bottom: 4, trailing: 16))
                        .swipeActions(edge: .leading) {
                            Button {
                                editingItem = item
                            } label: {
                                Label(langManager.currentLanguage == .chinese ? "修改" : "Edit", systemImage: "pencil")
                            }
                            .tint(BentoColors.vaultViolet)
                        }
                        .swipeActions(edge: .trailing, allowsFullSwipe: true) {
                            Button(role: .destructive) {
                                store.deleteVaultItem(id: item.id)
                            } label: {
                                Label(langManager.currentLanguage == .chinese ? "删除" : "Delete", systemImage: "trash")
                            }
                        }
                    }
                }
            }
            .listStyle(.plain)
            .scrollDismissesKeyboard(.interactively)
            .dismissKeyboardOnTap()
        }
        .dismissKeyboardOnTap()
        .background(BentoColors.bgPrimary.ignoresSafeArea())
        .navigationTitle(langManager.localized(.vaultTitle))
        .navigationBarTitleDisplayMode(.inline)
        .toolbar {
            ToolbarItem(placement: .primaryAction) {
                Button(action: { isShowingAddSheet = true }) {
                    Image(systemName: "plus")
                        .font(.system(size: 15, weight: .bold))
                }
            }
        }
        .overlay(
            VStack {
                if let msg = toastMessage {
                    Text(msg)
                        .font(.system(size: 12, weight: .bold, design: .rounded))
                        .foregroundColor(.white)
                        .padding(.horizontal, 14)
                        .padding(.vertical, 8)
                        .background(Color.black.opacity(0.85))
                        .clipShape(Capsule())
                        .padding(.top, 12)
                }
                Spacer()
            }
            .animation(.spring(), value: toastMessage)
        )
        .sheet(isPresented: $isShowingAddSheet) {
            AddVaultSheet()
        }
        .sheet(item: $editingItem) { item in
            EditVaultSheet(item: item)
        }
        .sheet(item: $largeDisplayItem) { item in
            VaultLargeDisplaySheet(item: item)
        }
    }
    
    private func showToast(_ message: String) {
        toastMessage = message
        DispatchQueue.main.asyncAfter(deadline: .now() + 1.5) {
            if toastMessage == message { toastMessage = nil }
        }
    }
}

// MARK: - 极简密码卡片 (无杂乱标签，纯粹直白展示主题与明文密码)
struct VaultItemCardRow: View {
    @ObservedObject var store = DataStore.shared
    @State var item: VaultItem
    var onCopy: (String) -> Void
    var onEdit: () -> Void
    var onLargeDisplay: () -> Void
    
    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            HStack(spacing: 6) {
                Text(item.title)
                    .font(.system(size: 15, weight: .bold, design: .rounded))
                
                Spacer()
                
                Button(action: onEdit) {
                    Image(systemName: "pencil")
                        .font(.system(size: 12, weight: .semibold))
                        .foregroundColor(.secondary)
                        .padding(4)
                }
                .buttonStyle(.plain)
            }
            
            if !item.accountOrKey.isEmpty {
                Text(item.accountOrKey)
                    .font(.system(size: 12, weight: .medium, design: .rounded))
                    .foregroundColor(.secondary)
            }
            
            // 明文密码框
            HStack {
                Text(item.secretValue)
                    .font(.system(size: 16, weight: .bold, design: .monospaced))
                    .foregroundColor(.primary)
                
                Spacer()
                
                Button(action: { onCopy(item.secretValue) }) {
                    Image(systemName: "doc.on.doc.fill")
                        .font(.system(size: 13))
                        .foregroundColor(BentoColors.vaultViolet)
                }
                .buttonStyle(.plain)
            }
            .padding(.horizontal, 12)
            .padding(.vertical, 8)
            .background(BentoColors.bgCard)
            .clipShape(RoundedRectangle(cornerRadius: 10))
            .onTapGesture {
                onLargeDisplay()
            }
        }
        .padding(14)
        .background(BentoColors.bgSecondary)
        .clipShape(RoundedRectangle(cornerRadius: 16, style: .continuous))
    }
}

// MARK: - 专属密码录入弹窗 (AddVaultSheet)
struct AddVaultSheet: View {
    @Environment(\.dismiss) private var dismiss
    @ObservedObject var store = DataStore.shared
    @ObservedObject var langManager = AppLanguageManager.shared
    
    @State private var titleText: String = ""
    @State private var vaultSecret: String = ""
    
    var isSubmitDisabled: Bool {
        titleText.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty ||
        vaultSecret.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty
    }
    
    var body: some View {
        NavigationStack {
            ScrollView(showsIndicators: false) {
                VStack(spacing: 14) {
                    // 主题
                    VStack(alignment: .leading, spacing: 6) {
                        Text(langManager.currentLanguage == .chinese ? "主题" : "Subject")
                            .font(.system(size: 12, weight: .bold, design: .rounded))
                            .foregroundColor(.secondary)
                        
                        TextField(
                            langManager.currentLanguage == .chinese ? "如: 门锁 / WiFi / 证件" : "e.g. Door Lock / WiFi / ID",
                            text: $titleText
                        )
                        .font(.system(size: 15, weight: .medium, design: .rounded))
                        .padding(11)
                        .background(BentoColors.bgCard)
                        .clipShape(RoundedRectangle(cornerRadius: 12))
                    }
                    
                    // 密码
                    VStack(alignment: .leading, spacing: 6) {
                        Text(langManager.currentLanguage == .chinese ? "密码 / 密钥" : "Secret / Password")
                            .font(.system(size: 12, weight: .bold, design: .rounded))
                            .foregroundColor(.secondary)
                        
                        TextField(
                            langManager.currentLanguage == .chinese ? "如: 081290# / 123456" : "e.g. 081290# / 123456",
                            text: $vaultSecret
                        )
                        .font(.system(size: 15, weight: .bold, design: .monospaced))
                        .padding(11)
                        .background(BentoColors.bgCard)
                        .clipShape(RoundedRectangle(cornerRadius: 12))
                    }
                    
                    // 存入按键
                    Button(action: {
                        let item = VaultItem(
                            title: titleText.trimmingCharacters(in: .whitespacesAndNewlines),
                            category: .custom,
                            secretValue: vaultSecret.trimmingCharacters(in: .whitespacesAndNewlines)
                        )
                        store.addVaultItem(item)
                        HapticManager.shared.notification(.success)
                        dismiss()
                    }) {
                        Text(langManager.localized(.save))
                            .font(.system(size: 16, weight: .heavy, design: .rounded))
                            .frame(maxWidth: .infinity)
                            .padding(.vertical, 13)
                            .background(
                                isSubmitDisabled ? Color.gray.opacity(0.25) : BentoColors.vaultViolet
                            )
                            .foregroundColor(.white)
                            .clipShape(Capsule())
                            .shadow(color: isSubmitDisabled ? .clear : BentoColors.vaultViolet.opacity(0.35), radius: 8, y: 4)
                    }
                    .disabled(isSubmitDisabled)
                    .bouncyTap()
                    .padding(.top, 6)
                }
                .padding(16)
                .background(BentoColors.bgSecondary)
                .clipShape(RoundedRectangle(cornerRadius: 20, style: .continuous))
                .padding(.horizontal, 16)
                .padding(.top, 14)
            }
            .scrollDismissesKeyboard(.interactively)
            .dismissKeyboardOnTap()
            .background(BentoColors.bgPrimary.ignoresSafeArea())
            .navigationTitle(langManager.currentLanguage == .chinese ? "新建密码" : "New Secret")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button(langManager.localized(.cancel)) { dismiss() }
                }
                ToolbarItemGroup(placement: .keyboard) {
                    Spacer()
                    Button(langManager.localized(.done)) {
                        UIApplication.shared.endEditing()
                    }
                    .font(.system(size: 15, weight: .bold))
                    .foregroundColor(BentoColors.vaultViolet)
                }
            }
        }
    }
}

// MARK: - 修改密码弹窗
struct EditVaultSheet: View {
    @Environment(\.dismiss) private var dismiss
    @ObservedObject var store = DataStore.shared
    @ObservedObject var langManager = AppLanguageManager.shared
    @State var item: VaultItem
    
    var body: some View {
        NavigationStack {
            Form {
                Section(header: Text(langManager.currentLanguage == .chinese ? "主题与密码" : "Subject & Secret").font(.system(size: 11, weight: .bold, design: .rounded))) {
                    TextField(langManager.currentLanguage == .chinese ? "主题" : "Subject", text: $item.title)
                    TextField(langManager.currentLanguage == .chinese ? "密码" : "Secret", text: $item.secretValue)
                }
                
                Section {
                    Button(role: .destructive) {
                        store.deleteVaultItem(id: item.id)
                        dismiss()
                    } label: {
                        HStack {
                            Spacer()
                            Text(langManager.currentLanguage == .chinese ? "删除此项" : "Delete Secret")
                            Spacer()
                        }
                    }
                }
            }
            .scrollDismissesKeyboard(.interactively)
            .dismissKeyboardOnTap()
            .navigationTitle(langManager.currentLanguage == .chinese ? "修改密码" : "Edit Secret")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button(langManager.localized(.cancel)) { dismiss() }
                }
                ToolbarItem(placement: .confirmationAction) {
                    Button(langManager.localized(.save)) {
                        store.updateVaultItem(item)
                        HapticManager.shared.notification(.success)
                        dismiss()
                    }
                    .disabled(item.title.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty)
                }
                ToolbarItemGroup(placement: .keyboard) {
                    Spacer()
                    Button(langManager.localized(.done)) {
                        UIApplication.shared.endEditing()
                    }
                    .font(.system(size: 15, weight: .bold))
                    .foregroundColor(BentoColors.vaultViolet)
                }
            }
        }
    }
}

// MARK: - 大字查看
struct VaultLargeDisplaySheet: View {
    @Environment(\.dismiss) private var dismiss
    @ObservedObject var langManager = AppLanguageManager.shared
    let item: VaultItem
    
    var body: some View {
        NavigationStack {
            VStack(spacing: 16) {
                Spacer()
                
                Text(item.title)
                    .font(.system(size: 18, weight: .bold, design: .rounded))
                
                Text(item.secretValue)
                    .font(.system(size: 32, weight: .heavy, design: .monospaced))
                    .multilineTextAlignment(.center)
                    .padding(20)
                    .frame(maxWidth: .infinity)
                    .background(BentoColors.vaultViolet.opacity(0.12))
                    .clipShape(RoundedRectangle(cornerRadius: 20))
                    .padding(.horizontal, 20)
                
                Button(action: {
                    UIPasteboard.general.string = item.secretValue
                    HapticManager.shared.notification(.success)
                    dismiss()
                }) {
                    Text(langManager.currentLanguage == .chinese ? "复制" : "Copy")
                        .font(.system(size: 15, weight: .bold, design: .rounded))
                        .padding(.horizontal, 28)
                        .padding(.vertical, 10)
                        .background(BentoColors.vaultViolet)
                        .foregroundColor(.white)
                        .clipShape(Capsule())
                }
                .bouncyTap()
                
                Spacer()
            }
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button(langManager.currentLanguage == .chinese ? "关闭" : "Close") { dismiss() }
                }
            }
        }
    }
}