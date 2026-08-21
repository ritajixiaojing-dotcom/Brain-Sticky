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
    @State private var selectedNoteForEdit: StickyNoteItem? = nil
    
    let columns = [
        GridItem(.flexible(), spacing: 12),
        GridItem(.flexible(), spacing: 12)
    ]
    
    public var body: some View {
        ScrollView(showsIndicators: false) {
            if store.stickyNotes.isEmpty {
                VStack(spacing: 12) {
                    Image(systemName: "sparkles")
                        .font(.system(size: 36))
                        .foregroundColor(BentoColors.noteAmber)
                        .padding(.top, 50)
                    Text(langManager.currentLanguage == .chinese ? "暂无日常记录 ✨" : "No Drops Yet ✨")
                        .font(.system(size: 14, weight: .medium, design: .rounded))
                        .foregroundColor(.secondary)
                }
                .frame(maxWidth: .infinity)
            } else {
                LazyVGrid(columns: columns, spacing: 12) {
                    ForEach(store.stickyNotes) { note in
                        StickyNoteCardView(note: note)
                            .onTapGesture {
                                selectedNoteForEdit = note
                            }
                            .contextMenu {
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
                                    store.deleteStickyNote(id: note.id)
                                }) {
                                    Label(langManager.currentLanguage == .chinese ? "删除" : "Delete", systemImage: "trash")
                                }
                            }
                    }
                }
                .padding(.horizontal, 16)
                .padding(.vertical, 10)
            }
        }
        .scrollDismissesKeyboard(.interactively)
        .dismissKeyboardOnTap()
        .background(BentoColors.bgPrimary.ignoresSafeArea())
        .navigationTitle(langManager.localized(.dropsTitle))
        .navigationBarTitleDisplayMode(.inline)
        .toolbar {
            ToolbarItem(placement: .primaryAction) {
                Button(action: { isShowingNewSheet = true }) {
                    Image(systemName: "plus")
                        .font(.system(size: 15, weight: .bold))
                }
            }
        }
        .sheet(isPresented: $isShowingNewSheet) {
            OmniCaptureView()
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
                    .font(.system(size: 16))
                Spacer()
                if note.isPinned {
                    Image(systemName: "pin.fill")
                        .font(.system(size: 9))
                        .foregroundColor(.orange)
                }
            }
            
            Text(note.content)
                .font(.system(size: 13, weight: .medium, design: .rounded))
                .foregroundColor(Color.black.opacity(0.85))
                .lineLimit(5)
                .multilineTextAlignment(.leading)
            
            Spacer(minLength: 2)
        }
        .padding(12)
        .frame(minHeight: 110, alignment: .topLeading)
        .background(
            RoundedRectangle(cornerRadius: 16, style: .continuous)
                .fill(BentoColors.colorForHex(note.colorHex))
                .shadow(color: Color.black.opacity(0.04), radius: 6, x: 0, y: 2)
        )
    }
}

// MARK: - Edit Note Sheet
struct EditStickyNoteSheet: View {
    @Environment(\.dismiss) private var dismiss
    @ObservedObject var store = DataStore.shared
    @ObservedObject var langManager = AppLanguageManager.shared
    @State var note: StickyNoteItem
    
    var body: some View {
        NavigationStack {
            VStack(spacing: 14) {
                TextEditor(text: $note.content)
                    .font(.system(size: 15))
                    .padding()
                    .background(BentoColors.colorForHex(note.colorHex))
                    .clipShape(RoundedRectangle(cornerRadius: 16))
                    .padding(.horizontal, 16)
                
                HStack(spacing: 12) {
                    ForEach(BentoColors.allStickyHexes, id: \.self) { hex in
                        Circle()
                            .fill(BentoColors.colorForHex(hex))
                            .frame(width: 30, height: 30)
                            .overlay(
                                Circle().stroke(note.colorHex == hex ? Color.primary : Color.clear, lineWidth: 2)
                            )
                            .onTapGesture {
                                note.colorHex = hex
                            }
                    }
                }
                
                Button(role: .destructive, action: {
                    store.deleteStickyNote(id: note.id)
                    HapticManager.shared.notification(.warning)
                    dismiss()
                }) {
                    HStack {
                        Image(systemName: "trash")
                        Text(langManager.currentLanguage == .chinese ? "删除便签" : "Delete Note")
                    }
                    .font(.system(size: 14, weight: .bold, design: .rounded))
                    .foregroundColor(.red)
                    .padding(.vertical, 8)
                }
                .padding(.top, 8)
                
                Spacer()
            }
            .scrollDismissesKeyboard(.interactively)
            .dismissKeyboardOnTap()
            .navigationTitle(langManager.currentLanguage == .chinese ? "修改便签" : "Edit Note")
            .navigationBarTitleDisplayMode(.inline)
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
                ToolbarItemGroup(placement: .keyboard) {
                    Spacer()
                    Button(langManager.localized(.done)) {
                        UIApplication.shared.endEditing()
                    }
                    .font(.system(size: 15, weight: .bold))
                    .foregroundColor(BentoColors.noteAmber)
                }
            }
        }
    }
}