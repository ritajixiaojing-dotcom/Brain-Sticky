package com.example.brainsticky.ui

import androidx.compose.foundation.background
import androidx.compose.foundation.border
import androidx.compose.foundation.clickable
import androidx.compose.foundation.layout.*
import androidx.compose.foundation.shape.CircleShape
import androidx.compose.foundation.shape.RoundedCornerShape
import androidx.compose.material3.*
import androidx.compose.runtime.*
import androidx.compose.ui.Alignment
import androidx.compose.ui.Modifier
import androidx.compose.ui.draw.clip
import androidx.compose.ui.graphics.Color
import androidx.compose.ui.text.font.FontWeight
import androidx.compose.ui.unit.dp
import androidx.compose.ui.unit.sp
import androidx.compose.ui.window.Dialog
import com.example.brainsticky.model.AppLanguage
import com.example.brainsticky.model.StickyNoteItem
import com.example.brainsticky.theme.BentoColors

@Composable
fun OmniCaptureDialog(
    lang: AppLanguage,
    onDismiss: () -> Unit,
    onSave: (StickyNoteItem) -> Unit
) {
    var contentText by remember { mutableStateOf("") }
    var selectedMood by remember { mutableStateOf("✨") }
    var selectedColorHex by remember { mutableStateOf("#FFF7D1") }
    var selectedTextColorHex by remember { mutableStateOf("#1E293B") }

    val moods = listOf("✨", "💡", "🌈", "☕️", "💭", "🎯", "🌿", "🌸")
    val textColors = listOf("#1E293B", "#78350F", "#BE123C", "#065F46", "#1E40AF", "#6B21A8")

    Dialog(onDismissRequest = onDismiss) {
        Card(
            shape = RoundedCornerShape(24.dp),
            colors = CardDefaults.cardColors(containerColor = MaterialTheme.colorScheme.surface),
            modifier = Modifier
                .fillMaxWidth()
                .padding(horizontal = 8.dp)
        ) {
            Column(
                modifier = Modifier
                    .padding(20.dp)
                    .fillMaxWidth(),
                verticalArrangement = Arrangement.spacedBy(12.dp)
            ) {
                // Header Badge
                Row(
                    modifier = Modifier.fillMaxWidth(),
                    horizontalArrangement = Arrangement.SpaceBetween,
                    verticalAlignment = Alignment.CenterVertically
                ) {
                    Box(
                        modifier = Modifier
                            .clip(RoundedCornerShape(12.dp))
                            .background(BentoColors.NoteAmber)
                            .padding(horizontal = 12.dp, vertical = 6.dp)
                    ) {
                        Text(
                            text = if (lang == AppLanguage.CHINESE) "日常便签" else "Daily Note",
                            color = Color.White,
                            fontWeight = FontWeight.Bold,
                            fontSize = 13.sp
                        )
                    }

                    TextButton(onClick = onDismiss) {
                        Text(if (lang == AppLanguage.CHINESE) "取消" else "Cancel")
                    }
                }

                // Note Content Editor Card
                Box(
                    modifier = Modifier
                        .fillMaxWidth()
                        .height(130.dp)
                        .clip(RoundedCornerShape(16.dp))
                        .background(BentoColors.colorForHex(selectedColorHex))
                        .padding(12.dp)
                ) {
                    TextField(
                        value = contentText,
                        onValueChange = { contentText = it },
                        placeholder = {
                            Text(
                                if (lang == AppLanguage.CHINESE) "写下此刻的想法与日常碎碎念..." else "Write down thoughts & moments...",
                                color = BentoColors.colorForHex(selectedTextColorHex).copy(alpha = 0.55f),
                                fontSize = 14.sp
                            )
                        },
                        colors = TextFieldDefaults.colors(
                            focusedContainerColor = Color.Transparent,
                            unfocusedContainerColor = Color.Transparent,
                            focusedIndicatorColor = Color.Transparent,
                            unfocusedIndicatorColor = Color.Transparent,
                            focusedTextColor = BentoColors.colorForHex(selectedTextColorHex),
                            unfocusedTextColor = BentoColors.colorForHex(selectedTextColorHex)
                        ),
                        modifier = Modifier.fillMaxSize()
                    )
                }

                // Pastel Colors Picker
                Text(
                    text = if (lang == AppLanguage.CHINESE) "便签底色" else "Background",
                    style = MaterialTheme.typography.labelSmall,
                    color = MaterialTheme.colorScheme.onSurface.copy(alpha = 0.6f)
                )

                Row(
                    modifier = Modifier.fillMaxWidth(),
                    horizontalArrangement = Arrangement.spacedBy(8.dp),
                    verticalAlignment = Alignment.CenterVertically
                ) {
                    BentoColors.AllStickyHexes.forEach { hex ->
                        val isSelected = selectedColorHex == hex
                        Box(
                            modifier = Modifier
                                .size(26.dp)
                                .clip(CircleShape)
                                .background(BentoColors.colorForHex(hex))
                                .border(
                                    width = if (isSelected) 2.5.dp else 1.dp,
                                    color = if (isSelected) MaterialTheme.colorScheme.primary else Color.Black.copy(alpha = 0.1f),
                                    shape = CircleShape
                                )
                                .clickable { selectedColorHex = hex }
                        )
                    }
                }

                // Font Colors Picker (with real-time preview badge)
                Row(
                    modifier = Modifier.fillMaxWidth(),
                    horizontalArrangement = Arrangement.spacedBy(8.dp),
                    verticalAlignment = Alignment.CenterVertically
                ) {
                    Text(
                        text = if (lang == AppLanguage.CHINESE) "字体颜色" else "Font Color",
                        style = MaterialTheme.typography.labelSmall,
                        color = MaterialTheme.colorScheme.onSurface.copy(alpha = 0.6f)
                    )

                    Box(
                        modifier = Modifier
                            .clip(RoundedCornerShape(8.dp))
                            .background(BentoColors.colorForHex(selectedColorHex))
                            .border(
                                width = 1.dp,
                                color = BentoColors.colorForHex(selectedTextColorHex).copy(alpha = 0.25f),
                                shape = RoundedCornerShape(8.dp)
                            )
                            .padding(horizontal = 8.dp, vertical = 2.dp)
                    ) {
                        Text(
                            text = if (lang == AppLanguage.CHINESE) "Aa 字体预览" else "Aa Preview",
                            fontSize = 11.sp,
                            fontWeight = FontWeight.Bold,
                            color = BentoColors.colorForHex(selectedTextColorHex)
                        )
                    }
                }

                Row(
                    modifier = Modifier.fillMaxWidth(),
                    horizontalArrangement = Arrangement.spacedBy(8.dp),
                    verticalAlignment = Alignment.CenterVertically
                ) {
                    textColors.forEach { hex ->
                        val isSelected = selectedTextColorHex == hex
                        Box(
                            modifier = Modifier
                                .size(26.dp)
                                .clip(CircleShape)
                                .background(BentoColors.colorForHex(hex))
                                .border(
                                    width = if (isSelected) 2.5.dp else 1.dp,
                                    color = if (isSelected) MaterialTheme.colorScheme.primary else Color.Black.copy(alpha = 0.1f),
                                    shape = CircleShape
                                )
                                .clickable { selectedTextColorHex = hex }
                        )
                    }
                }

                // Mood Emojis
                Text(
                    text = if (lang == AppLanguage.CHINESE) "选择心情" else "Choose Mood",
                    style = MaterialTheme.typography.labelSmall,
                    color = MaterialTheme.colorScheme.onSurface.copy(alpha = 0.6f)
                )

                Row(
                    modifier = Modifier.fillMaxWidth(),
                    horizontalArrangement = Arrangement.SpaceBetween
                ) {
                    moods.forEach { emoji ->
                        val isSelected = selectedMood == emoji
                        Box(
                            modifier = Modifier
                                .size(32.dp)
                                .clip(CircleShape)
                                .background(if (isSelected) BentoColors.NoteAmber.copy(alpha = 0.2f) else MaterialTheme.colorScheme.surfaceVariant.copy(alpha = 0.5f))
                                .border(
                                    width = if (isSelected) 2.dp else 0.dp,
                                    color = if (isSelected) BentoColors.NoteAmber else Color.Transparent,
                                    shape = CircleShape
                                )
                                .clickable { selectedMood = emoji },
                            contentAlignment = Alignment.Center
                        ) {
                            Text(text = emoji, fontSize = 16.sp)
                        }
                    }
                }

                // Save Button
                Button(
                    onClick = {
                        if (contentText.isNotBlank()) {
                            onSave(
                                StickyNoteItem(
                                    content = contentText.trim(),
                                    moodEmoji = selectedMood,
                                    colorHex = selectedColorHex,
                                    textColorHex = selectedTextColorHex
                                )
                            )
                            onDismiss()
                        }
                    },
                    enabled = contentText.isNotBlank(),
                    modifier = Modifier
                        .fillMaxWidth()
                        .height(48.dp),
                    shape = RoundedCornerShape(24.dp),
                    colors = ButtonDefaults.buttonColors(containerColor = BentoColors.NoteAmber)
                ) {
                    Text(
                        text = if (lang == AppLanguage.CHINESE) "保存" else "Save",
                        fontWeight = FontWeight.Bold,
                        fontSize = 15.sp,
                        color = Color.White
                    )
                }
            }
        }
    }
}
