package com.example.brainsticky.ui.drops

import android.content.ClipData
import android.content.ClipboardManager
import android.content.Context
import android.content.Intent
import android.widget.Toast
import androidx.compose.foundation.background
import androidx.compose.foundation.border
import androidx.compose.foundation.clickable
import androidx.compose.foundation.layout.*
import androidx.compose.foundation.lazy.LazyColumn
import androidx.compose.foundation.lazy.items
import androidx.compose.foundation.rememberScrollState
import androidx.compose.foundation.shape.CircleShape
import androidx.compose.foundation.shape.RoundedCornerShape
import androidx.compose.foundation.verticalScroll
import androidx.compose.material.icons.Icons
import androidx.compose.material.icons.automirrored.filled.ArrowBack
import androidx.compose.material.icons.filled.*
import androidx.compose.material3.*
import androidx.compose.runtime.*
import androidx.compose.ui.Alignment
import androidx.compose.ui.Modifier
import androidx.compose.ui.draw.clip
import androidx.compose.ui.graphics.Color
import androidx.compose.ui.platform.LocalContext
import androidx.compose.ui.text.font.FontWeight
import androidx.compose.ui.unit.dp
import androidx.compose.ui.unit.sp
import androidx.compose.ui.window.Dialog
import androidx.compose.ui.window.DialogProperties
import com.example.brainsticky.data.DataStore
import com.example.brainsticky.model.AppLanguage
import com.example.brainsticky.model.StickyNoteItem
import com.example.brainsticky.theme.BentoColors
import com.example.brainsticky.ui.OmniCaptureDialog
import java.text.SimpleDateFormat
import java.util.*

@OptIn(ExperimentalMaterial3Api::class)
@Composable
fun DropsScreen(
    dataStore: DataStore,
    onBack: () -> Unit
) {
    val lang = dataStore.language
    val context = LocalContext.current
    var isShowingAddDialog by remember { mutableStateOf(false) }
    var noteToDelete by remember { mutableStateOf<StickyNoteItem?>(null) }
    var selectedNoteForEnlarge by remember { mutableStateOf<StickyNoteItem?>(null) }

    Scaffold(
        topBar = {
            TopAppBar(
                title = {
                    Text(
                        if (lang == AppLanguage.CHINESE) "日常便签" else "Daily Notes",
                        fontWeight = FontWeight.Bold
                    )
                },
                navigationIcon = {
                    IconButton(onClick = onBack) {
                        Icon(Icons.AutoMirrored.Filled.ArrowBack, contentDescription = "Back")
                    }
                },
                colors = TopAppBarDefaults.topAppBarColors(
                    containerColor = MaterialTheme.colorScheme.background
                )
            )
        }
    ) { innerPadding ->
        Column(
            modifier = Modifier
                .fillMaxSize()
                .padding(innerPadding)
                .background(MaterialTheme.colorScheme.background)
                .padding(horizontal = 16.dp),
            verticalArrangement = Arrangement.spacedBy(12.dp)
        ) {
            // MARK: - 居中显眼快速记录日常便签按钮
            Card(
                shape = RoundedCornerShape(16.dp),
                colors = CardDefaults.cardColors(containerColor = MaterialTheme.colorScheme.surface),
                modifier = Modifier
                    .fillMaxWidth()
                    .clickable { isShowingAddDialog = true }
            ) {
                Row(
                    modifier = Modifier
                        .fillMaxWidth()
                        .padding(horizontal = 16.dp, vertical = 14.dp),
                    verticalAlignment = Alignment.CenterVertically,
                    horizontalArrangement = Arrangement.SpaceBetween
                ) {
                    Row(
                        verticalAlignment = Alignment.CenterVertically,
                        horizontalArrangement = Arrangement.spacedBy(10.dp)
                    ) {
                        Icon(
                            Icons.Default.Edit,
                            contentDescription = null,
                            tint = BentoColors.NoteAmber,
                            modifier = Modifier.size(18.dp)
                        )
                        Text(
                            text = if (lang == AppLanguage.CHINESE) "✨ 记下此刻日常想法与灵感..." else "✨ Capture thoughts & daily moments...",
                            fontWeight = FontWeight.SemiBold,
                            fontSize = 14.sp,
                            color = MaterialTheme.colorScheme.onSurface
                        )
                    }
                    Icon(
                        Icons.Default.AddCircle,
                        contentDescription = "Add",
                        tint = BentoColors.NoteAmber,
                        modifier = Modifier.size(22.dp)
                    )
                }
            }

            if (dataStore.stickyNotes.isEmpty()) {
                Box(
                    modifier = Modifier.fillMaxSize(),
                    contentAlignment = Alignment.Center
                ) {
                    Column(
                        horizontalAlignment = Alignment.CenterHorizontally,
                        verticalArrangement = Arrangement.spacedBy(8.dp)
                    ) {
                        Text(text = "🫧", fontSize = 40.sp)
                        Text(
                            text = if (lang == AppLanguage.CHINESE) "暂无日常记录 ✨\n点击上方输入框开始记录" else "No Daily Notes Yet ✨\nTap above to capture thoughts",
                            style = MaterialTheme.typography.bodyMedium,
                            color = MaterialTheme.colorScheme.onSurface.copy(alpha = 0.6f),
                            textAlign = androidx.compose.ui.text.style.TextAlign.Center
                        )
                    }
                }
            } else {
                LazyColumn(
                    modifier = Modifier.fillMaxSize(),
                    verticalArrangement = Arrangement.spacedBy(10.dp)
                ) {
                    items(dataStore.stickyNotes, key = { it.id }) { note ->
                        com.example.brainsticky.ui.components.SwipeToDeleteContainer(
                            onDelete = { noteToDelete = note },
                            deleteLabel = if (lang == AppLanguage.CHINESE) "删除" else "Delete"
                        ) {
                            StickyNoteCard(
                                note = note,
                                lang = lang,
                                onCardClick = { selectedNoteForEnlarge = note },
                                onShare = {
                                    val sendIntent = Intent(Intent.ACTION_SEND).apply {
                                        type = "text/plain"
                                        putExtra(
                                            Intent.EXTRA_TEXT,
                                            "【脑雾收集站 · 日常便签】\n${note.moodEmoji} ${note.content}\n— 记录于 脑雾收集站 (Brain Sticky)"
                                        )
                                    }
                                    val shareChooser = Intent.createChooser(
                                        sendIntent,
                                        if (lang == AppLanguage.CHINESE) "分享便签" else "Share Note"
                                    )
                                    context.startActivity(shareChooser)
                                },
                                onDelete = { noteToDelete = note }
                            )
                        }
                    }
                }
            }
        }
    }

    // Enlarged View Modal
    selectedNoteForEnlarge?.let { note ->
        EnlargedStickyNoteDialog(
            note = note,
            lang = lang,
            onDismiss = { selectedNoteForEnlarge = null },
            onUpdate = { updated ->
                dataStore.updateStickyNote(updated)
                selectedNoteForEnlarge = updated
            },
            onDelete = {
                noteToDelete = note
                selectedNoteForEnlarge = null
            },
            onShare = {
                val sendIntent = Intent(Intent.ACTION_SEND).apply {
                    type = "text/plain"
                    putExtra(
                        Intent.EXTRA_TEXT,
                        "【脑雾收集站 · 日常便签】\n${note.moodEmoji} ${note.content}\n— 记录于 脑雾收集站 (Brain Sticky)"
                    )
                }
                val shareChooser = Intent.createChooser(
                    sendIntent,
                    if (lang == AppLanguage.CHINESE) "分享便签" else "Share Note"
                )
                context.startActivity(shareChooser)
            }
        )
    }

    // Delete Confirmation Dialog
    noteToDelete?.let { note ->
        AlertDialog(
            onDismissRequest = { noteToDelete = null },
            title = {
                Text(
                    text = if (lang == AppLanguage.CHINESE) "确认删除便签？" else "Delete Note?",
                    fontWeight = FontWeight.Bold
                )
            },
            text = {
                Text(
                    text = if (lang == AppLanguage.CHINESE) "删除后将无法恢复，确定要删除这条便签吗？" else "This action cannot be undone. Are you sure you want to delete this note?"
                )
            },
            confirmButton = {
                Button(
                    onClick = {
                        dataStore.deleteStickyNote(note.id)
                        noteToDelete = null
                    },
                    colors = ButtonDefaults.buttonColors(containerColor = MaterialTheme.colorScheme.error)
                ) {
                    Text(if (lang == AppLanguage.CHINESE) "删除" else "Delete")
                }
            },
            dismissButton = {
                TextButton(onClick = { noteToDelete = null }) {
                    Text(if (lang == AppLanguage.CHINESE) "取消" else "Cancel")
                }
            }
        )
    }

    if (isShowingAddDialog) {
        OmniCaptureDialog(
            lang = lang,
            onDismiss = { isShowingAddDialog = false },
            onSave = { dataStore.addStickyNote(it) }
        )
    }
}

@Composable
fun StickyNoteCard(
    note: StickyNoteItem,
    lang: AppLanguage,
    onCardClick: () -> Unit,
    onShare: () -> Unit,
    onDelete: () -> Unit
) {
    val bgColor = BentoColors.colorForHex(note.colorHex)
    val sdf = remember { SimpleDateFormat("MM-dd HH:mm", Locale.getDefault()) }
    val timeStr = remember(note.createdAt) { sdf.format(Date(note.createdAt)) }

    Card(
        shape = RoundedCornerShape(18.dp),
        colors = CardDefaults.cardColors(containerColor = bgColor),
        modifier = Modifier
            .fillMaxWidth()
            .clickable { onCardClick() }
    ) {
        Column(
            modifier = Modifier
                .fillMaxWidth()
                .padding(14.dp),
            verticalArrangement = Arrangement.spacedBy(8.dp)
        ) {
            Row(
                modifier = Modifier.fillMaxWidth(),
                horizontalArrangement = Arrangement.SpaceBetween,
                verticalAlignment = Alignment.CenterVertically
            ) {
                Row(
                    verticalAlignment = Alignment.CenterVertically,
                    horizontalArrangement = Arrangement.spacedBy(6.dp)
                ) {
                    Text(text = note.moodEmoji, fontSize = 20.sp)
                    if (note.isPinned) {
                        Text("📌", fontSize = 12.sp)
                    }
                }

                Row(
                    verticalAlignment = Alignment.CenterVertically,
                    horizontalArrangement = Arrangement.spacedBy(6.dp)
                ) {
                    Text(
                        text = timeStr,
                        fontSize = 11.sp,
                        color = Color.Black.copy(alpha = 0.4f)
                    )

                    // Share button
                    IconButton(
                        onClick = onShare,
                        modifier = Modifier.size(26.dp)
                    ) {
                        Icon(
                            Icons.Default.Share,
                            contentDescription = "Share",
                            tint = Color.Black.copy(alpha = 0.6f),
                            modifier = Modifier.size(16.dp)
                        )
                    }

                    // Delete button
                    IconButton(
                        onClick = onDelete,
                        modifier = Modifier.size(26.dp)
                    ) {
                        Icon(
                            Icons.Default.Delete,
                            contentDescription = "Delete",
                            tint = Color.Black.copy(alpha = 0.5f),
                            modifier = Modifier.size(16.dp)
                        )
                    }
                }
            }

            Text(
                text = note.content,
                fontSize = 14.sp,
                lineHeight = 20.sp,
                fontWeight = FontWeight.Medium,
                color = BentoColors.colorForHex(note.textColorHex),
                maxLines = 4
            )
        }
    }
}

// MARK: - Enlarged Sticky Note Viewer Dialog (便签大图与详细放大查看)
@Composable
fun EnlargedStickyNoteDialog(
    note: StickyNoteItem,
    lang: AppLanguage,
    onDismiss: () -> Unit,
    onUpdate: (StickyNoteItem) -> Unit,
    onDelete: () -> Unit,
    onShare: () -> Unit
) {
    val context = LocalContext.current
    var isEditing by remember { mutableStateOf(false) }
    var editedContent by remember { mutableStateOf(note.content) }
    var editedHex by remember { mutableStateOf(note.colorHex) }
    var editedTextColorHex by remember { mutableStateOf(note.textColorHex) }
    var editedEmoji by remember { mutableStateOf(note.moodEmoji) }

    val colorOptions = listOf("#FFF7D1", "#FFE4E6", "#E0F2FE", "#E8F5E9", "#EDE9FE")
    val textColorOptions = listOf("#1E293B", "#78350F", "#BE123C", "#065F46", "#1E40AF", "#6B21A8")
    val emojiOptions = listOf("✨", "💡", "🌿", "💭", "☕️", "🌇", "🧸", "🎯", "🫧")

    val sdf = remember { SimpleDateFormat("yyyy-MM-dd HH:mm", Locale.getDefault()) }
    val fullTimeStr = remember(note.createdAt) { sdf.format(Date(note.createdAt)) }

    Dialog(
        onDismissRequest = onDismiss,
        properties = DialogProperties(usePlatformDefaultWidth = false)
    ) {
        Box(
            modifier = Modifier
                .fillMaxSize()
                .background(Color.Black.copy(alpha = 0.6f))
                .clickable { onDismiss() }
                .padding(20.dp),
            contentAlignment = Alignment.Center
        ) {
            Card(
                shape = RoundedCornerShape(26.dp),
                colors = CardDefaults.cardColors(containerColor = BentoColors.colorForHex(editedHex)),
                elevation = CardDefaults.cardElevation(defaultElevation = 12.dp),
                modifier = Modifier
                    .fillMaxWidth(0.92f)
                    .clickable(enabled = false) {} // Prevent click-through
            ) {
                Column(
                    modifier = Modifier
                        .fillMaxWidth()
                        .padding(22.dp),
                    verticalArrangement = Arrangement.spacedBy(14.dp)
                ) {
                    // Top Header
                    Row(
                        modifier = Modifier.fillMaxWidth(),
                        horizontalArrangement = Arrangement.SpaceBetween,
                        verticalAlignment = Alignment.CenterVertically
                    ) {
                        Row(
                            verticalAlignment = Alignment.CenterVertically,
                            horizontalArrangement = Arrangement.spacedBy(8.dp)
                        ) {
                            Text(text = editedEmoji, fontSize = 28.sp)
                            Column {
                                Text(
                                    text = if (lang == AppLanguage.CHINESE) "便签详情" else "Note Detail",
                                    fontSize = 14.sp,
                                    fontWeight = FontWeight.Bold,
                                    color = Color.Black.copy(alpha = 0.8f)
                                )
                                Text(
                                    text = fullTimeStr,
                                    fontSize = 11.sp,
                                    color = Color.Black.copy(alpha = 0.45f)
                                )
                            }
                        }

                        IconButton(
                            onClick = onDismiss,
                            modifier = Modifier
                                .size(32.dp)
                                .clip(CircleShape)
                                .background(Color.Black.copy(alpha = 0.08f))
                        ) {
                            Icon(Icons.Default.Close, contentDescription = "Close", tint = Color.Black.copy(alpha = 0.7f), modifier = Modifier.size(18.dp))
                        }
                    }

                    HorizontalDivider(color = Color.Black.copy(alpha = 0.08f))

                    // Content View / Edit View
                    if (isEditing) {
                        TextField(
                            value = editedContent,
                            onValueChange = { editedContent = it },
                            textStyle = LocalTextStyle.current.copy(
                                color = BentoColors.colorForHex(editedTextColorHex),
                                fontSize = 16.sp,
                                lineHeight = 24.sp
                            ),
                            colors = TextFieldDefaults.colors(
                                focusedContainerColor = Color.White.copy(alpha = 0.6f),
                                unfocusedContainerColor = Color.White.copy(alpha = 0.4f),
                                focusedIndicatorColor = Color.Transparent,
                                unfocusedIndicatorColor = Color.Transparent
                            ),
                            shape = RoundedCornerShape(16.dp),
                            modifier = Modifier
                                .fillMaxWidth()
                                .heightIn(min = 160.dp, max = 280.dp)
                        )

                        // Mood selector in edit mode
                        Row(
                            horizontalArrangement = Arrangement.spacedBy(6.dp),
                            modifier = Modifier.fillMaxWidth()
                        ) {
                            emojiOptions.forEach { emoji ->
                                Box(
                                    modifier = Modifier
                                        .clip(CircleShape)
                                        .background(if (editedEmoji == emoji) Color.White else Color.Transparent)
                                        .clickable { editedEmoji = emoji }
                                        .padding(6.dp)
                                ) {
                                    Text(emoji, fontSize = 18.sp)
                                }
                            }
                        }
                    } else {
                        // Scrollable Enlarged Text
                        Box(
                            modifier = Modifier
                                .fillMaxWidth()
                                .heightIn(min = 140.dp, max = 340.dp)
                                .verticalScroll(rememberScrollState())
                        ) {
                            Text(
                                text = note.content,
                                fontSize = 17.sp,
                                lineHeight = 26.sp,
                                fontWeight = FontWeight.Normal,
                                color = BentoColors.colorForHex(editedTextColorHex)
                            )
                        }
                    }

                    // Background color palette row
                    Row(
                        modifier = Modifier.fillMaxWidth(),
                        horizontalArrangement = Arrangement.spacedBy(10.dp),
                        verticalAlignment = Alignment.CenterVertically
                    ) {
                        Text(
                            text = if (lang == AppLanguage.CHINESE) "便签底色:" else "Background:",
                            fontSize = 12.sp,
                            fontWeight = FontWeight.Medium,
                            color = Color.Black.copy(alpha = 0.6f)
                        )

                        colorOptions.forEach { hex ->
                            Box(
                                modifier = Modifier
                                    .size(24.dp)
                                    .clip(CircleShape)
                                    .background(BentoColors.colorForHex(hex))
                                    .border(
                                        width = if (editedHex == hex) 2.5.dp else 1.dp,
                                        color = if (editedHex == hex) Color.Black.copy(alpha = 0.8f) else Color.Black.copy(alpha = 0.15f),
                                        shape = CircleShape
                                    )
                                    .clickable {
                                        editedHex = hex
                                        onUpdate(note.copy(colorHex = hex, textColorHex = editedTextColorHex))
                                    }
                            )
                        }
                    }

                    // Font color palette row
                    Row(
                        modifier = Modifier.fillMaxWidth(),
                        horizontalArrangement = Arrangement.spacedBy(8.dp),
                        verticalAlignment = Alignment.CenterVertically
                    ) {
                        Text(
                            text = if (lang == AppLanguage.CHINESE) "字体颜色:" else "Font Color:",
                            fontSize = 12.sp,
                            fontWeight = FontWeight.Medium,
                            color = Color.Black.copy(alpha = 0.6f)
                        )

                        Box(
                            modifier = Modifier
                                .clip(RoundedCornerShape(6.dp))
                                .background(BentoColors.colorForHex(editedHex))
                                .border(
                                    width = 1.dp,
                                    color = BentoColors.colorForHex(editedTextColorHex).copy(alpha = 0.3f),
                                    shape = RoundedCornerShape(6.dp)
                                )
                                .padding(horizontal = 6.dp, vertical = 2.dp)
                        ) {
                            Text(
                                text = "Aa",
                                fontSize = 11.sp,
                                fontWeight = FontWeight.Bold,
                                color = BentoColors.colorForHex(editedTextColorHex)
                            )
                        }

                        textColorOptions.forEach { hex ->
                            Box(
                                modifier = Modifier
                                    .size(24.dp)
                                    .clip(CircleShape)
                                    .background(BentoColors.colorForHex(hex))
                                    .border(
                                        width = if (editedTextColorHex == hex) 2.5.dp else 1.dp,
                                        color = if (editedTextColorHex == hex) Color.Black else Color.Black.copy(alpha = 0.15f),
                                        shape = CircleShape
                                    )
                                    .clickable {
                                        editedTextColorHex = hex
                                        onUpdate(note.copy(colorHex = editedHex, textColorHex = hex))
                                    }
                            )
                        }
                    }

                    HorizontalDivider(color = Color.Black.copy(alpha = 0.08f))

                    // Bottom Action Toolbar
                    Row(
                        modifier = Modifier.fillMaxWidth(),
                        horizontalArrangement = Arrangement.SpaceBetween,
                        verticalAlignment = Alignment.CenterVertically
                    ) {
                        // Copy Text Button
                        Button(
                            onClick = {
                                val clipboard = context.getSystemService(Context.CLIPBOARD_SERVICE) as ClipboardManager
                                val clip = ClipData.newPlainText("Sticky Note", note.content)
                                clipboard.setPrimaryClip(clip)
                                Toast.makeText(
                                    context,
                                    if (lang == AppLanguage.CHINESE) "已复制便签文本 📋" else "Copied to clipboard 📋",
                                    Toast.LENGTH_SHORT
                                ).show()
                            },
                            colors = ButtonDefaults.buttonColors(containerColor = Color.Black.copy(alpha = 0.08f)),
                            shape = RoundedCornerShape(12.dp),
                            contentPadding = PaddingValues(horizontal = 10.dp, vertical = 6.dp)
                        ) {
                            Icon(Icons.Default.ContentCopy, contentDescription = "Copy", tint = Color.Black.copy(alpha = 0.75f), modifier = Modifier.size(15.dp))
                            Spacer(Modifier.width(4.dp))
                            Text(if (lang == AppLanguage.CHINESE) "复制" else "Copy", fontSize = 12.sp, color = Color.Black.copy(alpha = 0.75f))
                        }

                        // Share Button
                        Button(
                            onClick = onShare,
                            colors = ButtonDefaults.buttonColors(containerColor = Color.Black.copy(alpha = 0.08f)),
                            shape = RoundedCornerShape(12.dp),
                            contentPadding = PaddingValues(horizontal = 10.dp, vertical = 6.dp)
                        ) {
                            Icon(Icons.Default.Share, contentDescription = "Share", tint = Color.Black.copy(alpha = 0.75f), modifier = Modifier.size(15.dp))
                            Spacer(Modifier.width(4.dp))
                            Text(if (lang == AppLanguage.CHINESE) "分享" else "Share", fontSize = 12.sp, color = Color.Black.copy(alpha = 0.75f))
                        }

                        if (isEditing) {
                            Button(
                                onClick = {
                                    onUpdate(note.copy(content = editedContent.trim(), colorHex = editedHex, textColorHex = editedTextColorHex, moodEmoji = editedEmoji))
                                    isEditing = false
                                },
                                colors = ButtonDefaults.buttonColors(containerColor = BentoColors.NoteAmber),
                                shape = RoundedCornerShape(12.dp),
                                contentPadding = PaddingValues(horizontal = 12.dp, vertical = 6.dp)
                            ) {
                                Text(if (lang == AppLanguage.CHINESE) "保存" else "Save", fontSize = 12.sp, fontWeight = FontWeight.Bold, color = Color.White)
                            }
                        } else {
                            // Edit Button
                            Button(
                                onClick = { isEditing = true },
                                colors = ButtonDefaults.buttonColors(containerColor = Color.Black.copy(alpha = 0.08f)),
                                shape = RoundedCornerShape(12.dp),
                                contentPadding = PaddingValues(horizontal = 10.dp, vertical = 6.dp)
                            ) {
                                Icon(Icons.Default.Edit, contentDescription = "Edit", tint = Color.Black.copy(alpha = 0.75f), modifier = Modifier.size(15.dp))
                                Spacer(Modifier.width(4.dp))
                                Text(if (lang == AppLanguage.CHINESE) "编辑" else "Edit", fontSize = 12.sp, color = Color.Black.copy(alpha = 0.75f))
                            }
                        }

                        // Delete Button
                        IconButton(
                            onClick = onDelete,
                            modifier = Modifier.size(34.dp)
                        ) {
                            Icon(Icons.Default.Delete, contentDescription = "Delete", tint = Color.Red.copy(alpha = 0.7f), modifier = Modifier.size(18.dp))
                        }
                    }
                }
            }
        }
    }
}
