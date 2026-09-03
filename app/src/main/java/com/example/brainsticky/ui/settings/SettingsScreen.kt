package com.example.brainsticky.ui.settings

import android.widget.Toast
import androidx.compose.foundation.background
import androidx.compose.foundation.clickable
import androidx.compose.foundation.layout.*
import androidx.compose.foundation.lazy.LazyColumn
import androidx.compose.foundation.shape.RoundedCornerShape
import androidx.compose.material.icons.Icons
import androidx.compose.material.icons.automirrored.filled.ArrowBack
import androidx.compose.material.icons.filled.Delete
import androidx.compose.material.icons.filled.Language
import androidx.compose.material.icons.filled.Lock
import androidx.compose.material.icons.filled.TouchApp
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
import com.example.brainsticky.data.DataStore
import com.example.brainsticky.model.AppLanguage
import com.example.brainsticky.theme.BentoColors

@OptIn(ExperimentalMaterial3Api::class)
@Composable
fun SettingsScreen(
    dataStore: DataStore,
    onBack: () -> Unit
) {
    val lang = dataStore.language
    val context = LocalContext.current
    var isShowingClearDialog by remember { mutableStateOf(false) }

    Scaffold(
        topBar = {
            TopAppBar(
                title = {
                    Text(
                        if (lang == AppLanguage.CHINESE) "设置与偏好" else "Settings & Preferences",
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
        LazyColumn(
            modifier = Modifier
                .fillMaxSize()
                .padding(innerPadding)
                .background(MaterialTheme.colorScheme.background)
                .padding(horizontal = 16.dp),
            verticalArrangement = Arrangement.spacedBy(14.dp)
        ) {
            // Language Selection Section
            item {
                SettingsSectionCard(
                    title = if (lang == AppLanguage.CHINESE) "语言设置 (Language)" else "Language"
                ) {
                    Row(
                        modifier = Modifier
                            .fillMaxWidth()
                            .clip(RoundedCornerShape(12.dp))
                            .background(MaterialTheme.colorScheme.surfaceVariant.copy(alpha = 0.5f))
                            .padding(4.dp),
                        horizontalArrangement = Arrangement.spacedBy(4.dp)
                    ) {
                        AppLanguage.entries.forEach { l ->
                            val isSelected = lang == l
                            Box(
                                modifier = Modifier
                                    .weight(1f)
                                    .clip(RoundedCornerShape(10.dp))
                                    .background(if (isSelected) MaterialTheme.colorScheme.surface else Color.Transparent)
                                    .clickable { dataStore.setAppLanguage(l) }
                                    .padding(vertical = 10.dp),
                                contentAlignment = Alignment.Center
                            ) {
                                Text(
                                    text = l.displayName,
                                    fontWeight = if (isSelected) FontWeight.Bold else FontWeight.Medium,
                                    fontSize = 13.sp,
                                    color = if (isSelected) MaterialTheme.colorScheme.onSurface else MaterialTheme.colorScheme.onSurface.copy(alpha = 0.6f)
                                )
                            }
                        }
                    }
                }
            }

            // Haptics (触觉震动) Section
            item {
                SettingsSectionCard(
                    title = if (lang == AppLanguage.CHINESE) "触觉震动" else "Haptics"
                ) {
                    Row(
                        modifier = Modifier
                            .fillMaxWidth()
                            .padding(vertical = 4.dp, horizontal = 6.dp),
                        verticalAlignment = Alignment.CenterVertically,
                        horizontalArrangement = Arrangement.SpaceBetween
                    ) {
                        Row(
                            verticalAlignment = Alignment.CenterVertically,
                            horizontalArrangement = Arrangement.spacedBy(10.dp)
                        ) {
                            Icon(
                                Icons.Default.TouchApp,
                                contentDescription = null,
                                tint = BentoColors.NoteAmber
                            )
                            Text(
                                if (lang == AppLanguage.CHINESE) "触觉震动 (Haptics)" else "Haptic Vibration (Haptics)",
                                fontSize = 14.sp,
                                fontWeight = FontWeight.Medium
                            )
                        }
                        Switch(
                            checked = dataStore.enableHaptics,
                            onCheckedChange = { dataStore.setHapticsEnabled(it) },
                            colors = SwitchDefaults.colors(
                                checkedThumbColor = Color.White,
                                checkedTrackColor = BentoColors.NoteAmber
                            )
                        )
                    }
                }
            }

            // Data Management Section
            item {
                SettingsSectionCard(
                    title = if (lang == AppLanguage.CHINESE) "外脑数据管理" else "Data Management"
                ) {
                    Column(verticalArrangement = Arrangement.spacedBy(10.dp)) {
                        Row(
                            modifier = Modifier
                                .fillMaxWidth()
                                .clip(RoundedCornerShape(12.dp))
                                .clickable { isShowingClearDialog = true }
                                .padding(vertical = 8.dp, horizontal = 6.dp),
                            verticalAlignment = Alignment.CenterVertically,
                            horizontalArrangement = Arrangement.spacedBy(10.dp)
                        ) {
                            Icon(Icons.Default.Delete, contentDescription = null, tint = MaterialTheme.colorScheme.error)
                            Text(
                                text = if (lang == AppLanguage.CHINESE) "清空全部外脑记录" else "Clear all MindOS data",
                                fontSize = 14.sp,
                                fontWeight = FontWeight.Medium,
                                color = MaterialTheme.colorScheme.error
                            )
                        }
                    }
                }
            }

            // Privacy & About Section
            item {
                SettingsSectionCard(
                    title = if (lang == AppLanguage.CHINESE) "关于与离线隐私架构" else "About & Privacy"
                ) {
                    Column(verticalArrangement = Arrangement.spacedBy(8.dp)) {
                        Row(
                            modifier = Modifier.fillMaxWidth(),
                            horizontalArrangement = Arrangement.SpaceBetween
                        ) {
                            Text(
                                text = if (lang == AppLanguage.CHINESE) "版本" else "Version",
                                fontSize = 13.sp,
                                color = MaterialTheme.colorScheme.onSurface.copy(alpha = 0.7f)
                            )
                            Text(
                                text = "1.1.0 (Android Build)",
                                fontSize = 13.sp,
                                fontWeight = FontWeight.Bold,
                                color = MaterialTheme.colorScheme.onSurface
                            )
                        }

                        Text(
                            text = if (lang == AppLanguage.CHINESE) "🔒 100% 纯本地离线隐私架构" else "🔒 100% Offline Privacy Architecture",
                            fontWeight = FontWeight.Bold,
                            fontSize = 12.sp,
                            color = BentoColors.GroceryMint,
                            modifier = Modifier.padding(top = 4.dp)
                        )

                        Text(
                            text = if (lang == AppLanguage.CHINESE)
                                "Brain Sticky 秉持纯端侧极简原则，不设立任何中心化数据收集服务器。所有密码与外脑记录完全存储在您的本地设备上。"
                            else
                                "Brain Sticky is designed with zero cloud data collection. All passwords and notes are encrypted and stored purely on your local device.",
                            fontSize = 11.sp,
                            lineHeight = 16.sp,
                            color = MaterialTheme.colorScheme.onSurface.copy(alpha = 0.6f)
                        )
                    }
                }
            }
        }
    }

    if (isShowingClearDialog) {
        AlertDialog(
            onDismissRequest = { isShowingClearDialog = false },
            title = { Text(if (lang == AppLanguage.CHINESE) "确定清空全部数据？" else "Clear all data?") },
            text = { Text(if (lang == AppLanguage.CHINESE) "此操作将永久清空所有待办、日常、密码、买菜与心愿记录。" else "This will permanently clear all your todos, notes, passwords, and wishlist items.") },
            confirmButton = {
                TextButton(
                    onClick = {
                        dataStore.clearAllData()
                        isShowingClearDialog = false
                        Toast.makeText(context, if (lang == AppLanguage.CHINESE) "已清空全部数据" else "All data cleared", Toast.LENGTH_SHORT).show()
                    }
                ) {
                    Text(if (lang == AppLanguage.CHINESE) "确认清空" else "Clear", color = MaterialTheme.colorScheme.error)
                }
            },
            dismissButton = {
                TextButton(onClick = { isShowingClearDialog = false }) {
                    Text(if (lang == AppLanguage.CHINESE) "取消" else "Cancel")
                }
            }
        )
    }
}

@Composable
fun SettingsSectionCard(
    title: String,
    content: @Composable () -> Unit
) {
    Card(
        shape = RoundedCornerShape(18.dp),
        colors = CardDefaults.cardColors(containerColor = MaterialTheme.colorScheme.surface),
        modifier = Modifier.fillMaxWidth()
    ) {
        Column(
            modifier = Modifier.padding(16.dp),
            verticalArrangement = Arrangement.spacedBy(10.dp)
        ) {
            Text(
                text = title,
                fontSize = 12.sp,
                fontWeight = FontWeight.Bold,
                color = MaterialTheme.colorScheme.onSurface.copy(alpha = 0.5f)
            )
            content()
        }
    }
}
