//
//  OmniCaptureView.swift
//  Brain Sticky
//
//  Created for Brain Sticky.
//

import SwiftUI

public struct OmniCaptureView: View {
    @Environment(\.dismiss) private var dismiss
    @ObservedObject var store = DataStore.shared
    @ObservedObject var langManager = AppLanguageManager.shared
    
    @State private var contentText: String = ""
    @State private var selectedMood: String = "✨"
    @State private var selectedColorHex: String = "#FFF7D1" // 默认柔黄便签
    @FocusState private var isFocused: Bool
    
    let moods = ["✨", "💡", "🌈", "☕️", "💭", "🎯", "🌿", "🌸"]
    
    public init() {}
    
    var isSubmitDisabled: Bool {
        contentText.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty
    }
    
    public var body: some View {
        NavigationStack {
            ScrollView(showsIndicators: false) {
                VStack(spacing: 14) {
                    // MARK: - 顶部单一纯粹标签
                    HStack {
                        Text(langManager.localized(.dropsTitle))
                            .font(.system(size: 13, weight: .heavy, design: .rounded))
                            .padding(.horizontal, 14)
                            .padding(.vertical, 6)
                            .background(BentoColors.noteAmber)
                            .foregroundColor(.white)
                            .clipShape(Capsule())
                            .shadow(color: BentoColors.noteAmber.opacity(0.28), radius: 5, y: 2)
                        
                        Spacer()
                    }
                    .padding(.horizontal, 16)
                    .padding(.top, 8)
                    
                    // MARK: - 原生 TextEditor 文本卡片 (全面优化中文输入法与换行兼容，秒速聚焦)
                    VStack(alignment: .leading, spacing: 14) {
                        ZStack(alignment: .topLeading) {
                            if contentText.isEmpty {
                                Text(langManager.currentLanguage == .chinese ? "写下此刻的想法与日常碎碎念..." : "Write down thoughts & moments...")
                                    .font(.system(size: 16, weight: .medium, design: .rounded))
                                    .foregroundColor(Color.black.opacity(0.35))
                                    .padding(.horizontal, 16)
                                    .padding(.vertical, 14)
                                    .allowsHitTesting(false)
                            }
                            
                            TextEditor(text: $contentText)
                                .focused($isFocused)
                                .scrollContentBackground(.hidden)
                                .font(.system(size: 16, weight: .medium, design: .rounded))
                                .foregroundColor(Color.black.opacity(0.85))
                                .padding(10)
                                .frame(minHeight: 140)
                        }
                        .background(BentoColors.colorForHex(selectedColorHex))
                        .clipShape(RoundedRectangle(cornerRadius: 16, style: .continuous))
                        .onTapGesture {
                            isFocused = true
                        }
                        
                        // 柔和底色点选
                        HStack(spacing: 12) {
                            ForEach(BentoColors.allStickyHexes, id: \.self) { hex in
                                Circle()
                                    .fill(BentoColors.colorForHex(hex))
                                    .frame(width: 28, height: 28)
                                    .overlay(
                                        Circle().stroke(selectedColorHex == hex ? Color.primary.opacity(0.8) : Color.black.opacity(0.06), lineWidth: selectedColorHex == hex ? 2 : 1)
                                    )
                                    .onTapGesture {
                                        selectedColorHex = hex
                                        HapticManager.shared.selection()
                                    }
                            }
                            Spacer()
                        }
                    }
                    .padding(16)
                    .background(BentoColors.bgSecondary)
                    .clipShape(RoundedRectangle(cornerRadius: 20, style: .continuous))
                    .padding(.horizontal, 16)
                    
                    // MARK: - 极简情绪与图标点选
                    VStack(alignment: .leading, spacing: 10) {
                        Text(langManager.currentLanguage == .chinese ? "选择心情" : "Choose Mood")
                            .font(.system(size: 12, weight: .bold, design: .rounded))
                            .foregroundColor(.secondary)
                            .padding(.horizontal, 18)
                        
                        ScrollView(.horizontal, showsIndicators: false) {
                            HStack(spacing: 10) {
                                ForEach(moods, id: \.self) { emoji in
                                    Button(action: {
                                        selectedMood = emoji
                                        HapticManager.shared.selection()
                                    }) {
                                        Text(emoji)
                                            .font(.system(size: 22))
                                            .frame(width: 44, height: 44)
                                            .background(selectedMood == emoji ? BentoColors.noteAmber.opacity(0.25) : Color.white)
                                            .clipShape(Circle())
                                            .overlay(
                                                Circle()
                                                    .stroke(selectedMood == emoji ? BentoColors.noteAmber : Color.black.opacity(0.06), lineWidth: selectedMood == emoji ? 2 : 1)
                                            )
                                            .shadow(color: Color.black.opacity(0.03), radius: 3, y: 1)
                                    }
                                    .buttonStyle(.plain)
                                }
                            }
                            .padding(.horizontal, 16)
                            .padding(.vertical, 4)
                        }
                    }
                    .padding(.top, 4)
                    
                    // MARK: - 保存按键
                    Button(action: commitDrop) {
                        Text(langManager.localized(.save))
                            .font(.system(size: 16, weight: .heavy, design: .rounded))
                            .frame(maxWidth: .infinity)
                            .padding(.vertical, 13)
                            .background(
                                isSubmitDisabled ? Color.gray.opacity(0.25) : BentoColors.noteAmber
                            )
                            .foregroundColor(.white)
                            .clipShape(Capsule())
                            .shadow(color: isSubmitDisabled ? .clear : BentoColors.noteAmber.opacity(0.35), radius: 8, y: 4)
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
            .navigationTitle(langManager.localized(.dropsTitle))
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button(langManager.localized(.cancel)) { dismiss() }
                        .font(.system(size: 15, weight: .medium))
                }
                ToolbarItemGroup(placement: .keyboard) {
                    Spacer()
                    Button(langManager.localized(.done)) {
                        isFocused = false
                        UIApplication.shared.endEditing()
                    }
                    .font(.system(size: 15, weight: .bold))
                    .foregroundColor(BentoColors.noteAmber)
                }
            }
            .onAppear {
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.15) {
                    isFocused = true
                }
            }
        }
    }
    
    private func commitDrop() {
        let text = contentText.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !text.isEmpty else { return }
        
        let note = StickyNoteItem(
            content: text,
            moodEmoji: selectedMood,
            colorHex: selectedColorHex
        )
        store.addStickyNote(note)
        
        let lower = text.lowercased()
        if lower.contains("密码") || lower.contains("wifi") || lower.contains("门禁") || lower.contains("锁") {
            let v = VaultItem(title: text, category: .custom, secretValue: text)
            store.addVaultItem(v)
        }
        
        HapticManager.shared.notification(.success)
        dismiss()
    }
}
