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
    @State private var selectedTextColorHex: String = "#1E293B" // 默认经典墨黑
    @FocusState private var isFocused: Bool
    
    let moods = ["✨", "💡", "🌈", "☕️", "💭", "🎯", "🌿", "🌸"]
    let textColorHexes = ["#1E293B", "#78350F", "#BE123C", "#065F46", "#1E40AF", "#6B21A8"]
    
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
                    
                    // MARK: - 文本卡片 (支持回车换行多行自由编辑，秒速聚焦)
                    VStack(alignment: .leading, spacing: 14) {
                        TextField(
                            langManager.currentLanguage == .chinese ? "写下此刻的想法与日常碎碎念..." : "Write down thoughts & moments...",
                            text: $contentText,
                            axis: .vertical
                        )
                        .focused($isFocused)
                        .font(.system(size: 16, weight: .medium, design: .rounded))
                        .foregroundColor(BentoColors.colorForHex(selectedTextColorHex))
                        .padding(14)
                        .frame(minHeight: 130, alignment: .topLeading)
                        .background(BentoColors.colorForHex(selectedColorHex))
                        .clipShape(RoundedRectangle(cornerRadius: 16, style: .continuous))
                        .onTapGesture {
                            isFocused = true
                        }
                        
                        // 柔和底色点选
                        VStack(alignment: .leading, spacing: 6) {
                            Text(langManager.currentLanguage == .chinese ? "便签底色" : "Background")
                                .font(.system(size: 12, weight: .bold, design: .rounded))
                                .foregroundColor(.secondary)
                            
                            HStack(spacing: 12) {
                                ForEach(BentoColors.allStickyHexes, id: \.self) { hex in
                                    Circle()
                                        .fill(BentoColors.colorForHex(hex))
                                        .frame(width: 26, height: 26)
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
                        
                        // 字体颜色点选
                        VStack(alignment: .leading, spacing: 6) {
                            Text(langManager.currentLanguage == .chinese ? "字体颜色" : "Font Color")
                                .font(.system(size: 12, weight: .bold, design: .rounded))
                                .foregroundColor(.secondary)
                            
                            HStack(spacing: 12) {
                                ForEach(textColorHexes, id: \.self) { hex in
                                    Circle()
                                        .fill(BentoColors.colorForHex(hex))
                                        .frame(width: 26, height: 26)
                                        .overlay(
                                            Circle().stroke(selectedTextColorHex == hex ? Color.black : Color.black.opacity(0.1), lineWidth: selectedTextColorHex == hex ? 2.5 : 1)
                                        )
                                        .onTapGesture {
                                            selectedTextColorHex = hex
                                            HapticManager.shared.selection()
                                        }
                                }
                                Spacer()
                            }
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
                    .padding(.bottom, 24)
                }
            }
            .scrollDismissesKeyboard(.interactively)
            .background(BentoColors.bgPrimary.ignoresSafeArea())
            .navigationTitle(langManager.localized(.dropsTitle))
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button(langManager.localized(.cancel)) { dismiss() }
                        .font(.system(size: 15, weight: .medium))
                }
                ToolbarItem(placement: .confirmationAction) {
                    Button(action: commitDrop) {
                        Text(langManager.localized(.save))
                            .font(.system(size: 14, weight: .heavy, design: .rounded))
                            .padding(.horizontal, 16)
                            .padding(.vertical, 6)
                            .background(
                                isSubmitDisabled ? Color.gray.opacity(0.3) : BentoColors.noteAmber
                            )
                            .foregroundColor(.white)
                            .clipShape(Capsule())
                    }
                    .disabled(isSubmitDisabled)
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
            colorHex: selectedColorHex,
            textColorHex: selectedTextColorHex
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
