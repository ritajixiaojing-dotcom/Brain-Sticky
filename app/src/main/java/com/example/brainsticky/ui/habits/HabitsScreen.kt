package com.example.brainsticky.ui.habits

import androidx.compose.foundation.background
import androidx.compose.foundation.clickable
import androidx.compose.foundation.layout.*
import androidx.compose.foundation.lazy.LazyColumn
import androidx.compose.foundation.lazy.LazyRow
import androidx.compose.foundation.lazy.items
import androidx.compose.foundation.shape.CircleShape
import androidx.compose.foundation.shape.RoundedCornerShape
import androidx.compose.material.icons.Icons
import androidx.compose.material.icons.automirrored.filled.ArrowBack
import androidx.compose.material.icons.filled.Add
import androidx.compose.material.icons.filled.Check
import androidx.compose.material.icons.filled.Delete
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
import com.example.brainsticky.data.DataStore
import com.example.brainsticky.model.AppLanguage
import com.example.brainsticky.model.BuiltinHabitPreset
import com.example.brainsticky.model.CustomEntryItem
import com.example.brainsticky.theme.BentoColors

@OptIn(ExperimentalMaterial3Api::class)
@Composable
fun HabitsScreen(
    dataStore: DataStore,
    onBack: () -> Unit
) {
    val lang = dataStore.language
    val habitModule = dataStore.customModules.firstOrNull()
    var isShowingAddDialog by remember { mutableStateOf(false) }

    Scaffold(
        topBar = {
            TopAppBar(
                title = {
                    Text(
                        if (lang == AppLanguage.CHINESE) "习惯打卡" else "Habit Tracker",
                        fontWeight = FontWeight.Bold
                    )
                },
                navigationIcon = {
                    IconButton(onClick = onBack) {
                        Icon(Icons.AutoMirrored.Filled.ArrowBack, contentDescription = "Back")
                    }
                },
                actions = {
                    IconButton(onClick = { isShowingAddDialog = true }) {
                        Icon(Icons.Default.Add, contentDescription = "Add")
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
            if (habitModule == null || habitModule.entries.isEmpty()) {
                Box(
                    modifier = Modifier.fillMaxSize(),
                    contentAlignment = Alignment.Center
                ) {
                    Column(
                        horizontalAlignment = Alignment.CenterHorizontally,
                        verticalArrangement = Arrangement.spacedBy(8.dp)
                    ) {
                        Text(text = "🎯", fontSize = 40.sp)
                        Text(
                            text = if (lang == AppLanguage.CHINESE) "点击右上角添加习惯\n如 🏃 跑步 · 💧 喝水 ✨" else "Tap + to add habits\ne.g. 🏃 Run · 💧 Water ✨",
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
                    items(habitModule.entries, key = { it.id }) { entry ->
                        HabitItemCard(
                            entry = entry,
                            lang = lang,
                            onToggle = { dataStore.toggleHabitEntry(habitModule.id, entry.id) },
                            onDelete = { dataStore.deleteHabitEntry(habitModule.id, entry.id) }
                        )
                    }
                }
            }
        }
    }

    if (isShowingAddDialog && habitModule != null) {
        AddHabitDialog(
            lang = lang,
            onDismiss = { isShowingAddDialog = false },
            onSave = { dataStore.addHabitEntry(habitModule.id, it) }
        )
    }
}

@Composable
fun HabitItemCard(
    entry: CustomEntryItem,
    lang: AppLanguage,
    onToggle: () -> Unit,
    onDelete: () -> Unit
) {
    Card(
        shape = RoundedCornerShape(18.dp),
        colors = CardDefaults.cardColors(containerColor = MaterialTheme.colorScheme.surface),
        modifier = Modifier.fillMaxWidth()
    ) {
        Row(
            modifier = Modifier
                .fillMaxWidth()
                .padding(14.dp),
            verticalAlignment = Alignment.CenterVertically,
            horizontalArrangement = Arrangement.spacedBy(12.dp)
        ) {
            Text(text = entry.icon, fontSize = 28.sp)

            Column(
                modifier = Modifier.weight(1f),
                verticalArrangement = Arrangement.spacedBy(2.dp)
            ) {
                Text(
                    text = entry.title,
                    fontWeight = FontWeight.Bold,
                    fontSize = 15.sp,
                    color = MaterialTheme.colorScheme.onSurface
                )

                if (entry.detail.isNotBlank()) {
                    Text(
                        text = entry.detail,
                        fontSize = 12.sp,
                        color = MaterialTheme.colorScheme.onSurface.copy(alpha = 0.6f)
                    )
                }

                Row(
                    verticalAlignment = Alignment.CenterVertically,
                    horizontalArrangement = Arrangement.spacedBy(4.dp)
                ) {
                    Text(
                        text = if (lang == AppLanguage.CHINESE) "🔥 连续 ${entry.streakDays} 天" else "🔥 ${entry.streakDays} days streak",
                        fontSize = 11.sp,
                        fontWeight = FontWeight.Bold,
                        color = BentoColors.OmniElectric
                    )
                }
            }

            // Big Check-in Button
            Button(
                onClick = onToggle,
                shape = RoundedCornerShape(12.dp),
                colors = ButtonDefaults.buttonColors(
                    containerColor = if (entry.isCompleted) BentoColors.GroceryMint else MaterialTheme.colorScheme.surfaceVariant.copy(alpha = 0.6f)
                ),
                contentPadding = PaddingValues(horizontal = 12.dp, vertical = 6.dp)
            ) {
                Row(
                    verticalAlignment = Alignment.CenterVertically,
                    horizontalArrangement = Arrangement.spacedBy(4.dp)
                ) {
                    if (entry.isCompleted) {
                        Icon(Icons.Default.Check, contentDescription = "Done", tint = Color.White, modifier = Modifier.size(16.dp))
                    }
                    Text(
                        text = if (entry.isCompleted) (if (lang == AppLanguage.CHINESE) "已打卡" else "Done") else (if (lang == AppLanguage.CHINESE) "打卡" else "Check-in"),
                        fontWeight = FontWeight.Bold,
                        color = if (entry.isCompleted) Color.White else MaterialTheme.colorScheme.onSurface
                    )
                }
            }

            IconButton(
                onClick = onDelete,
                modifier = Modifier.size(24.dp)
            ) {
                Icon(
                    Icons.Default.Delete,
                    contentDescription = "Delete",
                    tint = MaterialTheme.colorScheme.onSurface.copy(alpha = 0.3f),
                    modifier = Modifier.size(16.dp)
                )
            }
        }
    }
}

@Composable
fun AddHabitDialog(
    lang: AppLanguage,
    onDismiss: () -> Unit,
    onSave: (CustomEntryItem) -> Unit
) {
    var icon by remember { mutableStateOf("⭐️") }
    var title by remember { mutableStateOf("") }
    var detail by remember { mutableStateOf("") }

    Dialog(onDismissRequest = onDismiss) {
        Card(
            shape = RoundedCornerShape(24.dp),
            colors = CardDefaults.cardColors(containerColor = MaterialTheme.colorScheme.surface),
            modifier = Modifier.fillMaxWidth()
        ) {
            Column(
                modifier = Modifier
                    .padding(20.dp)
                    .fillMaxWidth(),
                verticalArrangement = Arrangement.spacedBy(14.dp)
            ) {
                Text(
                    text = if (lang == AppLanguage.CHINESE) "添加习惯打卡" else "New Habit",
                    fontWeight = FontWeight.Bold,
                    fontSize = 17.sp
                )

                // Presets
                Text(
                    text = if (lang == AppLanguage.CHINESE) "快速选择预设" else "Quick Presets",
                    fontSize = 12.sp,
                    color = MaterialTheme.colorScheme.onSurface.copy(alpha = 0.6f)
                )

                LazyRow(
                    horizontalArrangement = Arrangement.spacedBy(8.dp),
                    modifier = Modifier.fillMaxWidth()
                ) {
                    items(BuiltinHabitPreset.ALL) { preset ->
                        Box(
                            modifier = Modifier
                                .clip(RoundedCornerShape(10.dp))
                                .background(MaterialTheme.colorScheme.surfaceVariant.copy(alpha = 0.5f))
                                .clickable {
                                    icon = preset.icon
                                    title = preset.getTitle(lang)
                                    detail = preset.getDetail(lang)
                                }
                                .padding(horizontal = 10.dp, vertical = 6.dp)
                        ) {
                            Text(
                                text = "${preset.icon} ${preset.getTitle(lang)}",
                                fontSize = 12.sp,
                                fontWeight = FontWeight.Bold
                            )
                        }
                    }
                }

                // Emoji Picker Row
                val quickEmojis = listOf("⭐️", "🎯", "🏃", "💧", "🌙", "📖", "🧘", "🎸", "🎹", "🏋️", "💊", "🎨", "🌿", "☕️", "🐱", "💡", "🍳", "🚴")
                LazyRow(
                    horizontalArrangement = Arrangement.spacedBy(6.dp),
                    modifier = Modifier.fillMaxWidth()
                ) {
                    items(quickEmojis) { em ->
                        Box(
                            modifier = Modifier
                                .size(36.dp)
                                .clip(CircleShape)
                                .background(if (icon == em) BentoColors.OmniElectric.copy(alpha = 0.2f) else MaterialTheme.colorScheme.surfaceVariant.copy(alpha = 0.4f))
                                .clickable { icon = em },
                            contentAlignment = Alignment.Center
                        ) {
                            Text(text = em, fontSize = 18.sp)
                        }
                    }
                }

                Row(
                    modifier = Modifier.fillMaxWidth(),
                    horizontalArrangement = Arrangement.spacedBy(8.dp),
                    verticalAlignment = Alignment.CenterVertically
                ) {
                    OutlinedTextField(
                        value = icon,
                        onValueChange = { icon = it },
                        label = { Text("Emoji") },
                        singleLine = true,
                        modifier = Modifier.width(72.dp)
                    )

                    OutlinedTextField(
                        value = title,
                        onValueChange = { title = it },
                        label = { Text(if (lang == AppLanguage.CHINESE) "习惯名称" else "Habit Title") },
                        placeholder = { Text(if (lang == AppLanguage.CHINESE) "如：背单词 / 练琴 / 随心写" else "e.g. Practice Piano / Vocab") },
                        singleLine = true,
                        modifier = Modifier.weight(1f)
                    )
                }

                OutlinedTextField(
                    value = detail,
                    onValueChange = { detail = it },
                    label = { Text(if (lang == AppLanguage.CHINESE) "目标说明 (选填)" else "Target Description (Optional)") },
                    placeholder = { Text(if (lang == AppLanguage.CHINESE) "如：每天20分钟、读10页..." else "e.g. 20 mins a day, 10 pages...") },
                    singleLine = true,
                    modifier = Modifier.fillMaxWidth()
                )

                Row(
                    modifier = Modifier.fillMaxWidth(),
                    horizontalArrangement = Arrangement.End
                ) {
                    TextButton(onClick = onDismiss) {
                        Text(if (lang == AppLanguage.CHINESE) "取消" else "Cancel")
                    }

                    Spacer(modifier = Modifier.width(8.dp))

                    Button(
                        onClick = {
                            if (title.isNotBlank()) {
                                onSave(
                                    CustomEntryItem(
                                        icon = icon.ifBlank { "⭐️" },
                                        title = title.trim(),
                                        detail = detail.trim()
                                    )
                                )
                                onDismiss()
                            }
                        },
                        enabled = title.isNotBlank(),
                        colors = ButtonDefaults.buttonColors(containerColor = BentoColors.OmniElectric)
                    ) {
                        Text(if (lang == AppLanguage.CHINESE) "保存" else "Save")
                    }
                }
            }
        }
    }
}
