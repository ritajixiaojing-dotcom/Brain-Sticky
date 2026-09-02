//
//  StickyNotesWallView.swift
//  Brain Sticky
//
//  Created for Brain Sticky - Personal Second Brain Super App.
//

import SwiftUI

public struct StickyNotesWallView: View {
    @ObservedObject var store = DataStore.shared
    @ObservedObject var langManager = AppLanguageManager.shared
    @State private var isShowingNewSheet: Bool = false
    @State private var selectedNoteForEnlarge: StickyNoteItem? = nil
    @State private var selectedNoteForEdit: StickyNoteItem? = nil
    @State private var noteToDelete: StickyNoteItem? = nil
    @State private var isShowingDeleteAlert: Bool = false
    
    let columns = [
        GridItem(.flexible(), spacing: 12),
        GridItem(.flexible(), spacing: 12)
    ]
    
    public var body: some View {
        VStack(spacing: 0) {
            // MARK: - 居中显眼快速记录日常便签按钮
            Button(action: {
                isShowingNewSheet = true
                HapticManager.shared.impact(.medium)
            }) {
                HStack(spacing: 10) {
                    Image(systemName: "square.and.pencil")
                        .font(.system(size: 16, weight: .bold))
                        .foregroundColor(BentoColors.noteAmber)
                    Text(langManager.currentLanguage == .chinese ? "✨ 记下此刻日常想法与灵感..." : "✨ Capture thoughts & daily moments...")
                        .font(.system(size: 14, weight: .semibold, design: .rounded))
                        .foregroundColor(.primary.opacity(0.85))
                    Spacer()
                    Image(systemName: "plus.circle.fill")
                        .font(.system(size: 20, weight: .bold))
                        .foregroundColor(BentoColors.noteAmber)
                }
                .padding(.horizontal, 16)
                .padding(.vertical, 14)
                .background(Color.white)
                .contentShape(Rectangle())
                .clipShape(RoundedRectangle(cornerRadius: 16, style: .continuous))
                .shadow(color: BentoColors.noteAmber.opacity(0.14), radius: 8, x: 0, y: 3)
            }
            .buttonStyle(BouncyButtonStyle())
            .padding(.horizontal, 16)
            .padding(.top, 12)
            .padding(.bottom, 6)
            
            List {
                Section {
                    if store.stickyNotes.isEmpty {
                        VStack(spacing: 12) {
                            Image(systemName: "sparkles")
                                .font(.system(size: 36))
                                .foregroundColor(BentoColors.noteAmber)
                                .padding(.top, 50)
                            Text(langManager.currentLanguage == .chinese ? "暂无日常记录 ✨\n点击上方输入框开始记录" : "No Drops Yet ✨\nTap above to capture thoughts")
                                .font(.system(size: 14, weight: .medium, design: .rounded))
                                .foregroundColor(.secondary)
                                .multilineTextAlignment(.center)
                        }
                        .frame(maxWidth: .infinity)
                        .listRowBackground(Color.clear)
                        .listRowSeparator(.hidden)
                    } else {
                        ForEach(store.stickyNotes) { note in
                            StickyNoteCardView(note: note)
                                .contentShape(Rectangle())
                                .onTapGesture {
                                    selectedNoteForEnlarge = note
                                }
                                .listRowInsets(EdgeInsets(top: 5, leading: 16, bottom: 5, trailing: 16))
                                .listRowBackground(Color.clear)
                                .listRowSeparator(.hidden)
                                .swipeActions(edge: .trailing, allowsFullSwipe: false) {
                                    Button(role: .destructive) {
                                        noteToDelete = note
                                        isShowingDeleteAlert = true
                                    } label: {
                                        Label(langManager.currentLanguage == .chinese ? "删除" : "Delete", systemImage: "trash")
                                    }
                                }
                                .swipeActions(edge: .leading) {
                                    Button {
                                        var updated = note
                                        updated.isPinned.toggle()
                                        store.updateStickyNote(updated)
                                    } label: {
                                        Label(
                                            note.isPinned ? (langManager.currentLanguage == .chinese ? "取消置顶" : "Unpin") : (langManager.currentLanguage == .chinese ? "置顶" : "Pin"),
                                            systemImage: note.isPinned ? "pin.slash" : "pin.fill"
                                        )
                                    }
                                    .tint(.orange)
                                }
                                .contextMenu {
                                    Button(action: {
                                        ShareManager.shareText("【脑雾收集站 · 日常便签】\n\(note.moodEmoji) \(note.content)\n— 记录于 脑雾收集站 (Brain Sticky)")
                                    }) {
                                        Label(langManager.currentLanguage == .chinese ? "分享便签 (微信/WhatsApp)" : "Share Note", systemImage: "square.and.arrow.up")
                                    }
                                    
                                    Button(action: {
                                        ShareManager.copyToClipboard("【脑雾收集站 · 日常便签】\n\(note.moodEmoji) \(note.content)\n— 记录于 脑雾收集站 (Brain Sticky)")
                                    }) {
                                        Label(langManager.currentLanguage == .chinese ? "复制内容" : "Copy Content", systemImage: "doc.on.doc")
                                    }
                                    
                                    Button(action: {
                                        var updated = note
                                        updated.isPinned.toggle()
                                        store.updateStickyNote(updated)
                                    }) {
                                        Label(
                                            note.isPinned ? (langManager.currentLanguage == .chinese ? "取消置顶" : "Unpin") : (langManager.currentLanguage == .chinese ? "置顶" : "Pin"),
                                            systemImage: note.isPinned ? "pin.slash" : "pin.fill"
                                        )
                                    }
                                    
                                    Button(role: .destructive, action: {
                                        noteToDelete = note
                                        isShowingDeleteAlert = true
                                    }) {
                                        Label(langManager.currentLanguage == .chinese ? "删除" : "Delete", systemImage: "trash")
                                    }
                                }
                        }
                    }
                }
            }
            .listStyle(.plain)
            .scrollContentBackground(.hidden)
            .scrollDismissesKeyboard(.interactively)
        }
        .background(BentoColors.bgPrimary.ignoresSafeArea())
        .navigationTitle(langManager.localized(.dropsTitle))
        .navigationBarTitleDisplayMode(.inline)
        .alert(
            langManager.currentLanguage == .chinese ? "确认删除便签？" : "Delete Note?",
            isPresented: $isShowingDeleteAlert,
            presenting: noteToDelete
        ) { note in
            Button(langManager.currentLanguage == .chinese ? "删除" : "Delete", role: .destructive) {
                store.deleteStickyNote(id: note.id)
                noteToDelete = nil
            }
            Button(langManager.localized(.cancel), role: .cancel) {
                noteToDelete = nil
            }
        } message: { note in
            Text(langManager.currentLanguage == .chinese ? "删除后将无法恢复，确定要删除这条便签吗？" : "This action cannot be undone. Are you sure you want to delete this note?")
        }
        .sheet(isPresented: $isShowingNewSheet) {
            OmniCaptureView()
        }
        .sheet(item: $selectedNoteForEnlarge) { note in
            EnlargedStickyNoteViewerSheet(
                note: note,
                onEdit: {
                    selectedNoteForEnlarge = nil
                    selectedNoteForEdit = note
                },
                onDelete: {
                    noteToDelete = note
                    selectedNoteForEnlarge = nil
                    isShowingDeleteAlert = true
                }
            )
        }
        .sheet(item: $selectedNoteForEdit) { note in
            EditStickyNoteSheet(note: note)
        }
    }
}

// MARK: - Single Sticky Note Card
struct StickyNoteCardView: View {
    let note: StickyNoteItem
    
    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            HStack {
                Text(note.moodEmoji)
                    .font(.system(size: 18))
                Spacer()
                if note.isPinned {
                    HStack(spacing: 3) {
                        Image(systemName: "pin.fill")
                            .font(.system(size: 9))
                        Text(AppLanguageManager.shared.currentLanguage == .chinese ? "置顶" : "Pinned")
                            .font(.system(size: 10, weight: .bold, design: .rounded))
                    }
                    .foregroundColor(.orange)
                    .padding(.horizontal, 6)
                    .padding(.vertical, 2)
                    .background(Color.orange.opacity(0.15))
                    .clipShape(Capsule())
                }
            }
            
            Text(note.content)
                .font(.system(size: 14, weight: .medium, design: .rounded))
                .foregroundColor(BentoColors.colorForHex(note.textColorHex ?? "#1E293B"))
                .lineLimit(6)
                .multilineTextAlignment(.leading)
            
            Spacer(minLength: 2)
        }
        .padding(14)
        .frame(maxWidth: .infinity, alignment: .topLeading)
        .background(
            RoundedRectangle(cornerRadius: 16, style: .continuous)
                .fill(BentoColors.colorForHex(note.colorHex))
                .shadow(color: Color.black.opacity(0.04), radius: 6, x: 0, y: 2)
        )
    }
}

// MARK: - Enlarged Sticky Note Viewer Sheet (便签大图卡片放大查看)
struct EnlargedStickyNoteViewerSheet: View {
    @Environment(\.dismiss) private var dismiss
    @ObservedObject var store = DataStore.shared
    @ObservedObject var langManager = AppLanguageManager.shared
    @State var note: StickyNoteItem
    var onEdit: () -> Void
    var onDelete: () -> Void
    
    @State private var hasCopied: Bool = false
    
    private let textColorHexes = ["#1E293B", "#78350F", "#BE123C", "#065F46", "#1E40AF", "#6B21A8"]
    
    private var formattedDate: String {
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM-dd HH:mm"
        return formatter.string(from: note.createdAt)
    }
    
    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(spacing: 16) {
                    // 大尺寸卡片容器
                    VStack(alignment: .leading, spacing: 16) {
                        // 头部：表情与时间
                        HStack(alignment: .center, spacing: 10) {
                            Text(note.moodEmoji)
                                .font(.system(size: 32))
                            
                            VStack(alignment: .leading, spacing: 2) {
                                Text(langManager.currentLanguage == .chinese ? "便签详情" : "Note Detail")
                                    .font(.system(size: 16, weight: .bold, design: .rounded))
                                    .foregroundColor(.black.opacity(0.8))
                                
                                Text(formattedDate)
                                    .font(.system(size: 12, weight: .medium, design: .rounded))
                                    .foregroundColor(.black.opacity(0.45))
                            }
                            
                            Spacer()
                            
                            Button(action: {
                                var updated = note
                                updated.isPinned.toggle()
                                note = updated
                                store.updateStickyNote(updated)
                                HapticManager.shared.selection()
                            }) {
                                Image(systemName: note.isPinned ? "pin.fill" : "pin")
                                    .font(.system(size: 16))
                                    .foregroundColor(note.isPinned ? .orange : .black.opacity(0.4))
                                    .padding(8)
                                    .background(Color.white.opacity(0.7))
                                    .clipShape(Circle())
                            }
                        }
                        
                        Divider()
                            .background(Color.black.opacity(0.08))
                        
                        // 放大正文内容
                        Text(note.content)
                            .font(.system(size: 17, weight: .regular, design: .rounded))
                            .lineSpacing(6)
                            .foregroundColor(BentoColors.colorForHex(note.textColorHex ?? "#1E293B"))
                            .frame(maxWidth: .infinity, alignment: .leading)
                            .padding(.vertical, 4)
                        
                        // 便签底色挑选栏
                        HStack(spacing: 12) {
                            Text(langManager.currentLanguage == .chinese ? "便签底色:" : "Background:")
                                .font(.system(size: 12, weight: .bold, design: .rounded))
                                .foregroundColor(.black.opacity(0.5))
                            
                            ForEach(BentoColors.allStickyHexes, id: \.self) { hex in
                                Circle()
                                    .fill(BentoColors.colorForHex(hex))
                                    .frame(width: 26, height: 26)
                                    .overlay(
                                        Circle().stroke(note.colorHex == hex ? Color.black.opacity(0.8) : Color.black.opacity(0.12), lineWidth: note.colorHex == hex ? 2.5 : 1)
                                    )
                                    .onTapGesture {
                                        note.colorHex = hex
                                        store.updateStickyNote(note)
                                        HapticManager.shared.selection()
                                    }
                            }
                        }
                        .padding(.top, 4)
                        
                        // 字体颜色挑选栏
                        HStack(spacing: 12) {
                            Text(langManager.currentLanguage == .chinese ? "字体颜色:" : "Font Color:")
                                .font(.system(size: 12, weight: .bold, design: .rounded))
                                .foregroundColor(.black.opacity(0.5))
                            
                            ForEach(textColorHexes, id: \.self) { hex in
                                Circle()
                                    .fill(BentoColors.colorForHex(hex))
                                    .frame(width: 26, height: 26)
                                    .overlay(
                                        Circle().stroke((note.textColorHex ?? "#1E293B") == hex ? Color.black : Color.black.opacity(0.12), lineWidth: (note.textColorHex ?? "#1E293B") == hex ? 2.5 : 1)
                                    )
                                    .onTapGesture {
                                        note.textColorHex = hex
                                        store.updateStickyNote(note)
                                        HapticManager.shared.selection()
                                    }
                            }
                        }
                        .padding(.top, 2)
                    }
                    .padding(22)
                    .background(
                        RoundedRectangle(cornerRadius: 24, style: .continuous)
                            .fill(BentoColors.colorForHex(note.colorHex))
                            .shadow(color: Color.black.opacity(0.08), radius: 12, x: 0, y: 4)
                    )
                    .padding(.horizontal, 16)
                    .padding(.top, 12)
                    
                    // 底部操作区
                    HStack(spacing: 12) {
                        // 复制按钮
                        Button(action: {
                            UIPasteboard.general.string = note.content
                            HapticManager.shared.notification(.success)
                            hasCopied = true
                            DispatchQueue.main.asyncAfter(deadline: .now() + 2) {
                                hasCopied = false
                            }
                        }) {
                            HStack(spacing: 6) {
                                Image(systemName: hasCopied ? "checkmark.circle.fill" : "doc.on.doc")
                                Text(hasCopied ? (langManager.currentLanguage == .chinese ? "已复制" : "Copied") : (langManager.currentLanguage == .chinese ? "复制全文" : "Copy"))
                            }
                            .font(.system(size: 14, weight: .bold, design: .rounded))
                            .foregroundColor(.primary)
                            .frame(maxWidth: .infinity)
                            .padding(.vertical, 12)
                            .background(Color.white)
                            .clipShape(RoundedRectangle(cornerRadius: 14, style: .continuous))
                            .shadow(color: Color.black.opacity(0.05), radius: 6, x: 0, y: 2)
                        }
                        
                        // 分享按钮 (支持微信、WhatsApp 等)
                        Button(action: {
                            ShareManager.shareText("【脑雾收集站 · 日常便签】\n\(note.moodEmoji) \(note.content)\n— 记录于 脑雾收集站 (Brain Sticky)")
                        }) {
                            HStack(spacing: 6) {
                                Image(systemName: "square.and.arrow.up")
                                Text(langManager.currentLanguage == .chinese ? "分享" : "Share")
                            }
                            .font(.system(size: 14, weight: .bold, design: .rounded))
                            .foregroundColor(.primary)
                            .frame(maxWidth: .infinity)
                            .padding(.vertical, 12)
                            .background(Color.white)
                            .clipShape(RoundedRectangle(cornerRadius: 14, style: .continuous))
                            .shadow(color: Color.black.opacity(0.05), radius: 6, x: 0, y: 2)
                        }
                        
                        // 复制按钮
                        Button(action: {
                            ShareManager.copyToClipboard("【脑雾收集站 · 日常便签】\n\(note.moodEmoji) \(note.content)\n— 记录于 脑雾收集站 (Brain Sticky)")
                        }) {
                            HStack(spacing: 6) {
                                Image(systemName: "doc.on.doc")
                                Text(langManager.currentLanguage == .chinese ? "复制" : "Copy")
                            }
                            .font(.system(size: 14, weight: .bold, design: .rounded))
                            .foregroundColor(.primary)
                            .frame(maxWidth: .infinity)
                            .padding(.vertical, 12)
                            .background(Color.white)
                            .clipShape(RoundedRectangle(cornerRadius: 14, style: .continuous))
                            .shadow(color: Color.black.opacity(0.05), radius: 6, x: 0, y: 2)
                        }
                        
                        // 编辑按钮
                        Button(action: onEdit) {
                            HStack(spacing: 6) {
                                Image(systemName: "pencil")
                                Text(langManager.currentLanguage == .chinese ? "编辑" : "Edit")
                            }
                            .font(.system(size: 14, weight: .bold, design: .rounded))
                            .foregroundColor(BentoColors.noteAmber)
                            .frame(maxWidth: .infinity)
                            .padding(.vertical, 12)
                            .background(Color.white)
                            .clipShape(RoundedRectangle(cornerRadius: 14, style: .continuous))
                            .shadow(color: Color.black.opacity(0.05), radius: 6, x: 0, y: 2)
                        }
                        
                        // 删除按钮
                        Button(action: onDelete) {
                            Image(systemName: "trash")
                                .font(.system(size: 15, weight: .bold))
                                .foregroundColor(.red)
                                .padding(.horizontal, 14)
                                .padding(.vertical, 12)
                                .background(Color.white)
                                .clipShape(RoundedRectangle(cornerRadius: 14, style: .continuous))
                                .shadow(color: Color.black.opacity(0.05), radius: 6, x: 0, y: 2)
                        }
                    }
                    .padding(.horizontal, 16)
                }
            }
            .background(BentoColors.bgPrimary.ignoresSafeArea())
            .navigationTitle(langManager.currentLanguage == .chinese ? "便签详情" : "Note Detail")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button(langManager.localized(.done)) {
                        dismiss()
                    }
                    .font(.system(size: 15, weight: .bold))
                }
            }
        }
    }
}

// MARK: - Edit Note Sheet
struct EditStickyNoteSheet: View {
    @Environment(\.dismiss) private var dismiss
    @ObservedObject var store = DataStore.shared
    @ObservedObject var langManager = AppLanguageManager.shared
    @State var note: StickyNoteItem
    @State private var isShowingDeleteConfirm: Bool = false
    
    private let textColorHexes = ["#1E293B", "#78350F", "#BE123C", "#065F46", "#1E40AF", "#6B21A8"]
    
    var body: some View {
        NavigationStack {
            VStack(spacing: 14) {
                TextEditor(text: $note.content)
                    .font(.system(size: 16, weight: .medium, design: .rounded))
                    .foregroundColor(BentoColors.colorForHex(note.textColorHex ?? "#1E293B"))
                    .id(note.textColorHex ?? "#1E293B")
                    .padding()
                    .frame(minHeight: 140)
                    .background(BentoColors.colorForHex(note.colorHex))
                    .clipShape(RoundedRectangle(cornerRadius: 16))
                    .padding(.horizontal, 16)
                
                // 便签底色
                VStack(alignment: .leading, spacing: 6) {
                    Text(langManager.currentLanguage == .chinese ? "便签底色" : "Background")
                        .font(.system(size: 12, weight: .bold, design: .rounded))
                        .foregroundColor(.secondary)
                        .padding(.horizontal, 18)
                    
                    HStack(spacing: 12) {
                        ForEach(BentoColors.allStickyHexes, id: \.self) { hex in
                            Circle()
                                .fill(BentoColors.colorForHex(hex))
                                .frame(width: 28, height: 28)
                                .overlay(
                                    Circle().stroke(note.colorHex == hex ? Color.primary : Color.black.opacity(0.1), lineWidth: note.colorHex == hex ? 2.5 : 1)
                                )
                                .onTapGesture {
                                    note.colorHex = hex
                                }
                        }
                        Spacer()
                    }
                    .padding(.horizontal, 18)
                }
                
                // 字体颜色
                VStack(alignment: .leading, spacing: 6) {
                    HStack(spacing: 8) {
                        Text(langManager.currentLanguage == .chinese ? "字体颜色" : "Font Color")
                            .font(.system(size: 12, weight: .bold, design: .rounded))
                            .foregroundColor(.secondary)
                        
                        HStack(spacing: 4) {
                            Text("Aa")
                                .font(.system(size: 12, weight: .heavy, design: .rounded))
                            Text(langManager.currentLanguage == .chinese ? "字体预览" : "Preview")
                                .font(.system(size: 11, weight: .bold, design: .rounded))
                        }
                        .foregroundColor(BentoColors.colorForHex(note.textColorHex ?? "#1E293B"))
                        .padding(.horizontal, 8)
                        .padding(.vertical, 3)
                        .background(BentoColors.colorForHex(note.colorHex))
                        .clipShape(Capsule())
                        .overlay(
                            Capsule().stroke(BentoColors.colorForHex(note.textColorHex ?? "#1E293B").opacity(0.25), lineWidth: 1)
                        )
                    }
                    .padding(.horizontal, 18)
                    
                    HStack(spacing: 12) {
                        ForEach(textColorHexes, id: \.self) { hex in
                            Circle()
                                .fill(BentoColors.colorForHex(hex))
                                .frame(width: 28, height: 28)
                                .overlay(
                                    Circle().stroke((note.textColorHex ?? "#1E293B") == hex ? Color.black : Color.black.opacity(0.1), lineWidth: (note.textColorHex ?? "#1E293B") == hex ? 2.5 : 1)
                                )
                                .onTapGesture {
                                    note.textColorHex = hex
                                }
                        }
                        Spacer()
                    }
                    .padding(.horizontal, 18)
                }
                
                // 分享便签 (原生兼容微信、WhatsApp 等)
                Button(action: {
                    ShareManager.shareText("【脑雾收集站 · 日常便签】\n\(note.moodEmoji) \(note.content)\n— 记录于 脑雾收集站 (Brain Sticky)")
                }) {
                    HStack {
                        Image(systemName: "square.and.arrow.up")
                        Text(langManager.currentLanguage == .chinese ? "分享此便签 (微信/WhatsApp)" : "Share Note")
                    }
                    .font(.system(size: 14, weight: .bold, design: .rounded))
                    .foregroundColor(BentoColors.noteAmber)
                    .padding(.vertical, 4)
                }
                
                Button(action: {
                    ShareManager.copyToClipboard("【脑雾收集站 · 日常便签】\n\(note.moodEmoji) \(note.content)\n— 记录于 脑雾收集站 (Brain Sticky)")
                }) {
                    HStack {
                        Image(systemName: "doc.on.doc")
                        Text(langManager.currentLanguage == .chinese ? "复制便签文本" : "Copy Note Text")
                    }
                    .font(.system(size: 14, weight: .bold, design: .rounded))
                    .foregroundColor(.secondary)
                    .padding(.vertical, 2)
                }
                
                Button(role: .destructive, action: {
                    isShowingDeleteConfirm = true
                }) {
                    HStack {
                        Image(systemName: "trash")
                        Text(langManager.currentLanguage == .chinese ? "删除便签" : "Delete Note")
                    }
                    .font(.system(size: 14, weight: .bold, design: .rounded))
                    .foregroundColor(.red)
                    .padding(.vertical, 8)
                }
                .padding(.top, 4)
                
                Spacer()
            }
            .scrollDismissesKeyboard(.interactively)
            .dismissKeyboardOnTap()
            .navigationTitle(langManager.currentLanguage == .chinese ? "修改便签" : "Edit Note")
            .navigationBarTitleDisplayMode(.inline)
            .alert(
                langManager.currentLanguage == .chinese ? "确认删除便签？" : "Delete Note?",
                isPresented: $isShowingDeleteConfirm
            ) {
                Button(langManager.currentLanguage == .chinese ? "删除" : "Delete", role: .destructive) {
                    store.deleteStickyNote(id: note.id)
                    HapticManager.shared.notification(.warning)
                    dismiss()
                }
                Button(langManager.localized(.cancel), role: .cancel) {}
            } message: {
                Text(langManager.currentLanguage == .chinese ? "删除后将无法恢复，确定要删除这条便签吗？" : "This action cannot be undone. Are you sure you want to delete this note?")
            }
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button(langManager.localized(.cancel)) { dismiss() }
                }
                ToolbarItem(placement: .confirmationAction) {
                    Button(langManager.localized(.save)) {
                        store.updateStickyNote(note)
                        dismiss()
                    }
                }
            }
        }
    }
}