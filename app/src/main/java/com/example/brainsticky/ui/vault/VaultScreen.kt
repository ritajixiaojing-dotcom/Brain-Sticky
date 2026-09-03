package com.example.brainsticky.ui.vault

import android.widget.Toast
import androidx.compose.foundation.background
import androidx.compose.foundation.clickable
import androidx.compose.foundation.layout.*
import androidx.compose.foundation.lazy.LazyColumn
import androidx.compose.foundation.lazy.items
import androidx.compose.foundation.shape.RoundedCornerShape
import androidx.compose.material.icons.Icons
import androidx.compose.material.icons.automirrored.filled.ArrowBack
import androidx.compose.material.icons.filled.Add
import androidx.compose.material.icons.filled.Delete
import androidx.compose.material.icons.filled.Visibility
import androidx.compose.material.icons.filled.VisibilityOff
import androidx.compose.material3.*
import androidx.compose.runtime.*
import androidx.compose.ui.Alignment
import androidx.compose.ui.Modifier
import androidx.compose.ui.draw.clip
import androidx.compose.ui.graphics.Color
import androidx.compose.ui.platform.LocalClipboardManager
import androidx.compose.ui.platform.LocalContext
import androidx.compose.ui.text.AnnotatedString
import androidx.compose.ui.text.font.FontFamily
import androidx.compose.ui.text.font.FontWeight
import androidx.compose.ui.unit.dp
import androidx.compose.ui.unit.sp
import androidx.compose.ui.window.Dialog
import com.example.brainsticky.data.DataStore
import com.example.brainsticky.model.AppLanguage
import com.example.brainsticky.model.VaultItem
import com.example.brainsticky.theme.BentoColors

@OptIn(ExperimentalMaterial3Api::class)
@Composable
fun VaultScreen(
    dataStore: DataStore,
    onBack: () -> Unit
) {
    val lang = dataStore.language
    var isShowingAddDialog by remember { mutableStateOf(false) }
    var zoomItem by remember { mutableStateOf<VaultItem?>(null) }
    var vaultToDelete by remember { mutableStateOf<VaultItem?>(null) }

    Scaffold(
        topBar = {
            TopAppBar(
                title = {
                    Text(
                        if (lang == AppLanguage.CHINESE) "密码钥匙盒" else "Password Box",
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
            // 统一快速新建密码栏 (常驻置顶，与日常/待办/买菜保持统一优雅风格)
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
                    horizontalArrangement = Arrangement.SpaceBetween,
                    verticalAlignment = Alignment.CenterVertically
                ) {
                    Row(
                        verticalAlignment = Alignment.CenterVertically,
                        horizontalArrangement = Arrangement.spacedBy(10.dp)
                    ) {
                        Text(text = "🔐", fontSize = 18.sp)
                        Text(
                            text = if (lang == AppLanguage.CHINESE) "✨ 新建钥匙与密码账号..." else "✨ Add new secret or password...",
                            fontWeight = FontWeight.SemiBold,
                            fontSize = 14.sp,
                            color = MaterialTheme.colorScheme.onSurface
                        )
                    }
                    Icon(
                        Icons.Default.Add,
                        contentDescription = "Add",
                        tint = BentoColors.VaultViolet,
                        modifier = Modifier.size(20.dp)
                    )
                }
            }

            if (dataStore.vaultItems.isEmpty()) {
                Box(
                    modifier = Modifier
                        .fillMaxSize()
                        .clickable { isShowingAddDialog = true },
                    contentAlignment = Alignment.Center
                ) {
                    Column(
                        horizontalAlignment = Alignment.CenterHorizontally,
                        verticalArrangement = Arrangement.spacedBy(14.dp),
                        modifier = Modifier.padding(bottom = 60.dp)
                    ) {
                        Text(
                            text = "🔒",
                            fontSize = 42.sp
                        )
                        Column(
                            horizontalAlignment = Alignment.CenterHorizontally,
                            verticalArrangement = Arrangement.spacedBy(4.dp)
                        ) {
                            Text(
                                text = if (lang == AppLanguage.CHINESE) "钥匙密码已妥善安放 🔒" else "All Passwords Secured 🔒",
                                fontWeight = FontWeight.Bold,
                                fontSize = 15.sp,
                                color = MaterialTheme.colorScheme.onSurface.copy(alpha = 0.85f)
                            )
                            Text(
                                text = if (lang == AppLanguage.CHINESE) "轻点上方栏目，安全记录您的账号与密码 ✨" else "Tap the bar above to add a password ✨",
                                fontSize = 13.sp,
                                color = MaterialTheme.colorScheme.onSurface.copy(alpha = 0.6f),
                                textAlign = androidx.compose.ui.text.style.TextAlign.Center
                            )
                        }
                    }
                }
            } else {
                LazyColumn(
                    modifier = Modifier.fillMaxSize(),
                    verticalArrangement = Arrangement.spacedBy(10.dp)
                ) {
                    items(dataStore.vaultItems, key = { it.id }) { item ->
                        com.example.brainsticky.ui.components.SwipeToDeleteContainer(
                            onDelete = { vaultToDelete = item },
                            deleteLabel = if (lang == AppLanguage.CHINESE) "删除" else "Delete"
                        ) {
                            VaultCardRow(
                                item = item,
                                lang = lang,
                                onToggleMask = { dataStore.toggleVaultMask(item.id) },
                                onZoom = { zoomItem = item },
                                onDelete = { vaultToDelete = item }
                            )
                        }
                    }
                }
            }
        }
    }

    // Delete Confirmation Dialog
    vaultToDelete?.let { item ->
        AlertDialog(
            onDismissRequest = { vaultToDelete = null },
            title = {
                Text(
                    text = if (lang == AppLanguage.CHINESE) "确认删除此密码记录？" else "Delete Password Item?",
                    fontWeight = FontWeight.Bold
                )
            },
            text = {
                Text(
                    text = if (lang == AppLanguage.CHINESE) "确定要删除「${item.title}」的密码记录吗？" else "Are you sure you want to delete \"${item.title}\"?"
                )
            },
            confirmButton = {
                Button(
                    onClick = {
                        dataStore.deleteVaultItem(item.id)
                        vaultToDelete = null
                    },
                    colors = ButtonDefaults.buttonColors(containerColor = MaterialTheme.colorScheme.error)
                ) {
                    Text(if (lang == AppLanguage.CHINESE) "删除" else "Delete")
                }
            },
            dismissButton = {
                TextButton(onClick = { vaultToDelete = null }) {
                    Text(if (lang == AppLanguage.CHINESE) "取消" else "Cancel")
                }
            }
        )
    }

    if (isShowingAddDialog) {
        AddVaultDialog(
            lang = lang,
            onDismiss = { isShowingAddDialog = false },
            onSave = { dataStore.addVaultItem(it) }
        )
    }

    zoomItem?.let { item ->
        ZoomVaultDialog(
            item = item,
            lang = lang,
            onDismiss = { zoomItem = null }
        )
    }
}

@Composable
fun VaultCardRow(
    item: VaultItem,
    lang: AppLanguage,
    onToggleMask: () -> Unit,
    onZoom: () -> Unit,
    onDelete: () -> Unit
) {
    val clipboardManager = LocalClipboardManager.current
    val context = LocalContext.current

    Card(
        shape = RoundedCornerShape(18.dp),
        colors = CardDefaults.cardColors(containerColor = MaterialTheme.colorScheme.surface),
        modifier = Modifier.fillMaxWidth()
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
                Text(
                    text = item.title,
                    fontWeight = FontWeight.Bold,
                    fontSize = 15.sp,
                    color = MaterialTheme.colorScheme.onSurface
                )

                IconButton(
                    onClick = onDelete,
                    modifier = Modifier.size(24.dp)
                ) {
                    Icon(
                        Icons.Default.Delete,
                        contentDescription = "Delete",
                        tint = MaterialTheme.colorScheme.error.copy(alpha = 0.6f),
                        modifier = Modifier.size(16.dp)
                    )
                }
            }

            if (item.accountOrKey.isNotBlank()) {
                Text(
                    text = item.accountOrKey,
                    fontSize = 12.sp,
                    color = MaterialTheme.colorScheme.onSurface.copy(alpha = 0.6f)
                )
            }

            // Secret Display Row
            Row(
                modifier = Modifier
                    .fillMaxWidth()
                    .clip(RoundedCornerShape(12.dp))
                    .background(MaterialTheme.colorScheme.surfaceVariant.copy(alpha = 0.4f))
                    .clickable { onZoom() }
                    .padding(horizontal = 12.dp, vertical = 10.dp),
                verticalAlignment = Alignment.CenterVertically,
                horizontalArrangement = Arrangement.SpaceBetween
            ) {
                Text(
                    text = if (item.isMasked) "••••••••" else item.secretValue,
                    fontFamily = FontFamily.Monospace,
                    fontWeight = FontWeight.Bold,
                    fontSize = 15.sp,
                    color = BentoColors.VaultViolet
                )

                Row(
                    horizontalArrangement = Arrangement.spacedBy(8.dp),
                    verticalAlignment = Alignment.CenterVertically
                ) {
                    IconButton(
                        onClick = onToggleMask,
                        modifier = Modifier.size(24.dp)
                    ) {
                        Icon(
                            if (item.isMasked) Icons.Default.Visibility else Icons.Default.VisibilityOff,
                            contentDescription = "Toggle Visibility",
                            tint = MaterialTheme.colorScheme.onSurface.copy(alpha = 0.6f),
                            modifier = Modifier.size(18.dp)
                        )
                    }

                    TextButton(
                        onClick = {
                            clipboardManager.setText(AnnotatedString(item.secretValue))
                            Toast.makeText(
                                context,
                                if (lang == AppLanguage.CHINESE) "已复制密码到剪贴板 ✨" else "Password copied ✨",
                                Toast.LENGTH_SHORT
                            ).show()
                        },
                        contentPadding = PaddingValues(horizontal = 8.dp, vertical = 2.dp)
                    ) {
                        Text(
                            text = if (lang == AppLanguage.CHINESE) "复制" else "Copy",
                            fontSize = 12.sp,
                            fontWeight = FontWeight.Bold,
                            color = BentoColors.VaultViolet
                        )
                    }
                }
            }
        }
    }
}

@Composable
fun AddVaultDialog(
    lang: AppLanguage,
    onDismiss: () -> Unit,
    onSave: (VaultItem) -> Unit
) {
    var title by remember { mutableStateOf("") }
    var account by remember { mutableStateOf("") }
    var secret by remember { mutableStateOf("") }

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
                    text = if (lang == AppLanguage.CHINESE) "新建密码钥匙" else "New Vault Entry",
                    fontWeight = FontWeight.Bold,
                    fontSize = 17.sp
                )

                OutlinedTextField(
                    value = title,
                    onValueChange = { title = it },
                    label = { Text(if (lang == AppLanguage.CHINESE) "标题 (如: 家门密码)" else "Title (e.g. Door Code)") },
                    singleLine = true,
                    modifier = Modifier.fillMaxWidth()
                )

                OutlinedTextField(
                    value = account,
                    onValueChange = { account = it },
                    label = { Text(if (lang == AppLanguage.CHINESE) "账号 / 备注 (选填)" else "Account / Note (Optional)") },
                    singleLine = true,
                    modifier = Modifier.fillMaxWidth()
                )

                OutlinedTextField(
                    value = secret,
                    onValueChange = { secret = it },
                    label = { Text(if (lang == AppLanguage.CHINESE) "密码 / 口令" else "Password / Secret") },
                    singleLine = true,
                    modifier = Modifier.fillMaxWidth()
                )

                Row(
                    modifier = Modifier.fillMaxWidth(),
                    horizontalArrangement = Arrangement.End,
                    verticalAlignment = Alignment.CenterVertically
                ) {
                    TextButton(onClick = onDismiss) {
                        Text(if (lang == AppLanguage.CHINESE) "取消" else "Cancel")
                    }

                    Spacer(modifier = Modifier.width(8.dp))

                    Button(
                        onClick = {
                            if (title.isNotBlank() && secret.isNotBlank()) {
                                onSave(
                                    VaultItem(
                                        title = title.trim(),
                                        accountOrKey = account.trim(),
                                        secretValue = secret.trim()
                                    )
                                )
                                onDismiss()
                            }
                        },
                        enabled = title.isNotBlank() && secret.isNotBlank(),
                        colors = ButtonDefaults.buttonColors(containerColor = BentoColors.VaultViolet)
                    ) {
                        Text(if (lang == AppLanguage.CHINESE) "保存" else "Save")
                    }
                }
            }
        }
    }
}

@Composable
fun ZoomVaultDialog(
    item: VaultItem,
    lang: AppLanguage,
    onDismiss: () -> Unit
) {
    Dialog(onDismissRequest = onDismiss) {
        Card(
            shape = RoundedCornerShape(24.dp),
            colors = CardDefaults.cardColors(containerColor = MaterialTheme.colorScheme.surface),
            modifier = Modifier.fillMaxWidth()
        ) {
            Column(
                modifier = Modifier
                    .padding(24.dp)
                    .fillMaxWidth(),
                horizontalAlignment = Alignment.CenterHorizontally,
                verticalArrangement = Arrangement.spacedBy(16.dp)
            ) {
                Text(
                    text = item.title,
                    fontWeight = FontWeight.Bold,
                    fontSize = 18.sp,
                    color = MaterialTheme.colorScheme.onSurface
                )

                if (item.accountOrKey.isNotBlank()) {
                    Text(
                        text = item.accountOrKey,
                        fontSize = 13.sp,
                        color = MaterialTheme.colorScheme.onSurface.copy(alpha = 0.6f)
                    )
                }

                Box(
                    modifier = Modifier
                        .fillMaxWidth()
                        .clip(RoundedCornerShape(16.dp))
                        .background(BentoColors.VaultViolet.copy(alpha = 0.15f))
                        .padding(20.dp),
                    contentAlignment = Alignment.Center
                ) {
                    Text(
                        text = item.secretValue,
                        fontSize = 28.sp,
                        fontWeight = FontWeight.Black,
                        fontFamily = FontFamily.Monospace,
                        color = BentoColors.VaultViolet
                    )
                }

                Button(
                    onClick = onDismiss,
                    modifier = Modifier.fillMaxWidth(),
                    shape = RoundedCornerShape(14.dp),
                    colors = ButtonDefaults.buttonColors(containerColor = BentoColors.VaultViolet)
                ) {
                    Text(if (lang == AppLanguage.CHINESE) "完成" else "Done")
                }
            }
        }
    }
}
