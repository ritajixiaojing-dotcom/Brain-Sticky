package com.example.brainsticky.ui.wishlist

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
import com.example.brainsticky.model.WishlistCurrency
import com.example.brainsticky.model.WishlistItem
import com.example.brainsticky.theme.BentoColors

enum class WishlistTab(val labelZh: String, val labelEn: String) {
    COOLING("冷静 ⏳", "Cooling ⏳"),
    BOUGHT("已买 🛍️", "Bought 🛍️"),
    PASSED("已放弃 🗑️", "Passed 🗑️")
}

@OptIn(ExperimentalMaterial3Api::class)
@Composable
fun WishlistScreen(
    dataStore: DataStore,
    onBack: () -> Unit
) {
    val lang = dataStore.language
    var selectedTab by remember { mutableStateOf(WishlistTab.COOLING) }
    var isShowingAddDialog by remember { mutableStateOf(false) }

    val activeItems = dataStore.wishlistItems.filter { !it.isPurchased && !it.isAbandoned }
    val boughtItems = dataStore.wishlistItems.filter { it.isPurchased }
    val passedItems = dataStore.wishlistItems.filter { it.isAbandoned }

    val displayedItems = when (selectedTab) {
        WishlistTab.COOLING -> activeItems
        WishlistTab.BOUGHT -> boughtItems
        WishlistTab.PASSED -> passedItems
    }

    val totalActiveBudget = activeItems.sumOf { it.targetPrice }
    val totalSavedBudget = passedItems.sumOf { it.targetPrice }

    Scaffold(
        topBar = {
            TopAppBar(
                title = {
                    Text(
                        if (lang == AppLanguage.CHINESE) "心愿与冷静期" else "Wishlist & Cool-off",
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
            // Budget Summary Card
            Card(
                shape = RoundedCornerShape(18.dp),
                colors = CardDefaults.cardColors(containerColor = MaterialTheme.colorScheme.surface),
                modifier = Modifier.fillMaxWidth()
            ) {
                Row(
                    modifier = Modifier
                        .fillMaxWidth()
                        .padding(16.dp),
                    horizontalArrangement = Arrangement.SpaceBetween,
                    verticalAlignment = Alignment.CenterVertically
                ) {
                    Column(verticalArrangement = Arrangement.spacedBy(4.dp)) {
                        Text(
                            text = if (lang == AppLanguage.CHINESE) "冷静中心愿总额" else "Active Wishlist Total",
                            fontSize = 12.sp,
                            color = MaterialTheme.colorScheme.onSurface.copy(alpha = 0.6f)
                        )
                        Text(
                            text = "¥${totalActiveBudget.toLong()}",
                            fontSize = 22.sp,
                            fontWeight = FontWeight.Black,
                            color = BentoColors.WishlistRuby
                        )
                    }

                    Column(
                        horizontalAlignment = Alignment.End,
                        verticalArrangement = Arrangement.spacedBy(4.dp)
                    ) {
                        Text(
                            text = if (lang == AppLanguage.CHINESE) "已成功省下 🍃" else "Money Saved 🍃",
                            fontSize = 12.sp,
                            color = MaterialTheme.colorScheme.onSurface.copy(alpha = 0.6f)
                        )
                        Text(
                            text = "¥${totalSavedBudget.toLong()}",
                            fontSize = 20.sp,
                            fontWeight = FontWeight.Bold,
                            color = BentoColors.GroceryMint
                        )
                    }
                }
            }

            // Tab Switcher
            Row(
                modifier = Modifier
                    .fillMaxWidth()
                    .clip(RoundedCornerShape(12.dp))
                    .background(MaterialTheme.colorScheme.surfaceVariant.copy(alpha = 0.5f))
                    .padding(4.dp),
                horizontalArrangement = Arrangement.spacedBy(4.dp)
            ) {
                WishlistTab.entries.forEach { tab ->
                    val isSelected = selectedTab == tab
                    Box(
                        modifier = Modifier
                            .weight(1f)
                            .clip(RoundedCornerShape(10.dp))
                            .background(if (isSelected) MaterialTheme.colorScheme.surface else Color.Transparent)
                            .clickable { selectedTab = tab }
                            .padding(vertical = 8.dp),
                        contentAlignment = Alignment.Center
                    ) {
                        Text(
                            text = if (lang == AppLanguage.CHINESE) tab.labelZh else tab.labelEn,
                            fontWeight = if (isSelected) FontWeight.Bold else FontWeight.Medium,
                            fontSize = 12.sp,
                            color = if (isSelected) MaterialTheme.colorScheme.onSurface else MaterialTheme.colorScheme.onSurface.copy(alpha = 0.6f)
                        )
                    }
                }
            }

            // Wishlist Items
            if (displayedItems.isEmpty()) {
                Box(
                    modifier = Modifier
                        .fillMaxWidth()
                        .weight(1f),
                    contentAlignment = Alignment.Center
                ) {
                    Text(
                        text = if (lang == AppLanguage.CHINESE) "心如止水，钱包保住啦 🧸" else "Peaceful mind, wallet saved 🧸",
                        style = MaterialTheme.typography.bodyMedium,
                        color = MaterialTheme.colorScheme.onSurface.copy(alpha = 0.6f)
                    )
                }
            } else {
                LazyColumn(
                    modifier = Modifier.weight(1f),
                    verticalArrangement = Arrangement.spacedBy(10.dp)
                ) {
                    items(displayedItems, key = { it.id }) { item ->
                        WishlistCardRow(
                            item = item,
                            lang = lang,
                            onBuy = { dataStore.toggleWishlistPurchased(item.id) },
                            onPass = { dataStore.abandonWishlistItem(item.id) },
                            onRestore = { dataStore.restoreWishlistItem(item.id) },
                            onDelete = { dataStore.deleteWishlistItem(item.id) }
                        )
                    }
                }
            }
        }
    }

    if (isShowingAddDialog) {
        AddWishlistDialog(
            lang = lang,
            onDismiss = { isShowingAddDialog = false },
            onSave = { dataStore.addWishlistItem(it) }
        )
    }
}

@Composable
fun WishlistCardRow(
    item: WishlistItem,
    lang: AppLanguage,
    onBuy: () -> Unit,
    onPass: () -> Unit,
    onRestore: () -> Unit,
    onDelete: () -> Unit
) {
    val currency = WishlistCurrency.fromSymbol(item.currency)

    Card(
        shape = RoundedCornerShape(18.dp),
        colors = CardDefaults.cardColors(containerColor = MaterialTheme.colorScheme.surface),
        modifier = Modifier.fillMaxWidth()
    ) {
        Column(
            modifier = Modifier
                .fillMaxWidth()
                .padding(14.dp),
            verticalArrangement = Arrangement.spacedBy(10.dp)
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

                if (item.targetPrice > 0) {
                    Text(
                        text = currency.format(item.targetPrice),
                        fontWeight = FontWeight.Black,
                        fontSize = 16.sp,
                        color = BentoColors.WishlistRuby
                    )
                }
            }

            if (item.notes.isNotBlank()) {
                Text(
                    text = item.notes,
                    fontSize = 12.sp,
                    color = MaterialTheme.colorScheme.onSurface.copy(alpha = 0.6f)
                )
            }

            // Cool-off Progress
            if (!item.isPurchased && !item.isAbandoned) {
                Row(
                    modifier = Modifier.fillMaxWidth(),
                    horizontalArrangement = Arrangement.SpaceBetween,
                    verticalAlignment = Alignment.CenterVertically
                ) {
                    Text(
                        text = if (item.coolOffDaysTotal >= 9999) "∞" else if (lang == AppLanguage.CHINESE) "冷静还剩 ${item.daysRemaining} 天" else "${item.daysRemaining} days left",
                        fontSize = 11.sp,
                        fontWeight = FontWeight.Bold,
                        color = BentoColors.WishlistRuby
                    )

                    LinearProgressIndicator(
                        progress = { item.coolOffProgress },
                        modifier = Modifier
                            .width(100.dp)
                            .height(6.dp)
                            .clip(RoundedCornerShape(3.dp)),
                        color = BentoColors.WishlistRuby,
                        trackColor = BentoColors.WishlistRuby.copy(alpha = 0.15f)
                    )
                }
            }

            // Action Buttons
            Row(
                modifier = Modifier.fillMaxWidth(),
                horizontalArrangement = Arrangement.SpaceBetween,
                verticalAlignment = Alignment.CenterVertically
            ) {
                if (item.isAbandoned) {
                    Button(
                        onClick = onRestore,
                        shape = RoundedCornerShape(10.dp),
                        colors = ButtonDefaults.buttonColors(containerColor = BentoColors.WishlistRuby.copy(alpha = 0.15f)),
                        contentPadding = PaddingValues(horizontal = 12.dp, vertical = 6.dp)
                    ) {
                        Text(
                            text = if (lang == AppLanguage.CHINESE) "放回冷静 ♻️" else "Restore ♻️",
                            color = BentoColors.WishlistRuby,
                            fontWeight = FontWeight.Bold,
                            fontSize = 11.sp
                        )
                    }
                } else if (item.isPurchased) {
                    Row(
                        horizontalArrangement = Arrangement.spacedBy(8.dp),
                        verticalAlignment = Alignment.CenterVertically
                    ) {
                        Button(
                            onClick = onRestore,
                            shape = RoundedCornerShape(10.dp),
                            colors = ButtonDefaults.buttonColors(containerColor = MaterialTheme.colorScheme.surfaceVariant.copy(alpha = 0.6f)),
                            contentPadding = PaddingValues(horizontal = 10.dp, vertical = 6.dp)
                        ) {
                            Text(
                                text = if (lang == AppLanguage.CHINESE) "↩️ 放回冷静" else "↩️ Back to Cooling",
                                color = MaterialTheme.colorScheme.onSurface.copy(alpha = 0.85f),
                                fontWeight = FontWeight.Bold,
                                fontSize = 11.sp
                            )
                        }

                        Text(
                            text = if (lang == AppLanguage.CHINESE) "已拥有 ✨" else "Owned ✨",
                            fontSize = 12.sp,
                            fontWeight = FontWeight.Bold,
                            color = BentoColors.GroceryMint
                        )
                    }
                } else {
                    Row(horizontalArrangement = Arrangement.spacedBy(8.dp)) {
                        Button(
                            onClick = onBuy,
                            shape = RoundedCornerShape(10.dp),
                            colors = ButtonDefaults.buttonColors(containerColor = BentoColors.WishlistRuby.copy(alpha = 0.15f)),
                            contentPadding = PaddingValues(horizontal = 12.dp, vertical = 6.dp)
                        ) {
                            Text(
                                text = if (lang == AppLanguage.CHINESE) "买下 ✨" else "Buy ✨",
                                color = BentoColors.WishlistRuby,
                                fontWeight = FontWeight.Bold,
                                fontSize = 11.sp
                            )
                        }

                        Button(
                            onClick = onPass,
                            shape = RoundedCornerShape(10.dp),
                            colors = ButtonDefaults.buttonColors(containerColor = MaterialTheme.colorScheme.error.copy(alpha = 0.12f)),
                            contentPadding = PaddingValues(horizontal = 12.dp, vertical = 6.dp)
                        ) {
                            Text(
                                text = if (lang == AppLanguage.CHINESE) "放弃 🗑️" else "Pass 🗑️",
                                color = MaterialTheme.colorScheme.error,
                                fontWeight = FontWeight.Bold,
                                fontSize = 11.sp
                            )
                        }
                    }
                }

                IconButton(
                    onClick = onDelete,
                    modifier = Modifier.size(28.dp)
                ) {
                    Icon(
                        Icons.Default.Delete,
                        contentDescription = "Delete",
                        tint = MaterialTheme.colorScheme.onSurface.copy(alpha = 0.4f),
                        modifier = Modifier.size(16.dp)
                    )
                }
            }
        }
    }
}

@Composable
fun AddWishlistDialog(
    lang: AppLanguage,
    onDismiss: () -> Unit,
    onSave: (WishlistItem) -> Unit
) {
    var title by remember { mutableStateOf("") }
    var priceStr by remember { mutableStateOf("") }
    var selectedCurrency by remember { mutableStateOf(WishlistCurrency.CNY) }
    var coolOffDays by remember { mutableStateOf(14) }
    var notes by remember { mutableStateOf("") }

    val coolOffOptions = listOf(
        7 to (if (lang == AppLanguage.CHINESE) "7天" else "7 Days"),
        14 to (if (lang == AppLanguage.CHINESE) "14天" else "14 Days"),
        30 to (if (lang == AppLanguage.CHINESE) "30天" else "30 Days"),
        9999 to "∞"
    )

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
                verticalArrangement = Arrangement.spacedBy(12.dp)
            ) {
                Text(
                    text = if (lang == AppLanguage.CHINESE) "新建心愿与冷静期" else "New Wishlist Item",
                    fontWeight = FontWeight.Bold,
                    fontSize = 17.sp
                )

                OutlinedTextField(
                    value = title,
                    onValueChange = { title = it },
                    label = { Text(if (lang == AppLanguage.CHINESE) "心愿好物名称" else "Item Name") },
                    singleLine = true,
                    modifier = Modifier.fillMaxWidth()
                )

                // Currency & Price
                Row(
                    modifier = Modifier.fillMaxWidth(),
                    horizontalArrangement = Arrangement.spacedBy(8.dp)
                ) {
                    WishlistCurrency.entries.forEach { curr ->
                        val isSelected = selectedCurrency == curr
                        Box(
                            modifier = Modifier
                                .weight(1f)
                                .clip(RoundedCornerShape(10.dp))
                                .background(if (isSelected) BentoColors.WishlistRuby else MaterialTheme.colorScheme.surfaceVariant.copy(alpha = 0.4f))
                                .clickable { selectedCurrency = curr }
                                .padding(vertical = 6.dp),
                            contentAlignment = Alignment.Center
                        ) {
                            Text(
                                text = "${curr.symbol} ${curr.getName(lang)}",
                                fontSize = 11.sp,
                                fontWeight = FontWeight.Bold,
                                color = if (isSelected) Color.White else MaterialTheme.colorScheme.onSurface
                            )
                        }
                    }
                }

                OutlinedTextField(
                    value = priceStr,
                    onValueChange = { priceStr = it },
                    label = { Text(if (lang == AppLanguage.CHINESE) "预算金额 (如 2999)" else "Budget Price") },
                    singleLine = true,
                    modifier = Modifier.fillMaxWidth()
                )

                // Cool-off Days
                Text(
                    text = if (lang == AppLanguage.CHINESE) "冷静期" else "Cool-off Period",
                    fontSize = 12.sp,
                    color = MaterialTheme.colorScheme.onSurface.copy(alpha = 0.6f)
                )

                Row(
                    modifier = Modifier.fillMaxWidth(),
                    horizontalArrangement = Arrangement.spacedBy(6.dp)
                ) {
                    coolOffOptions.forEach { (days, label) ->
                        val isSelected = coolOffDays == days
                        Box(
                            modifier = Modifier
                                .weight(1f)
                                .clip(RoundedCornerShape(8.dp))
                                .background(if (isSelected) BentoColors.WishlistRuby else MaterialTheme.colorScheme.surfaceVariant.copy(alpha = 0.4f))
                                .clickable { coolOffDays = days }
                                .padding(vertical = 6.dp),
                            contentAlignment = Alignment.Center
                        ) {
                            Text(
                                text = label,
                                fontSize = 12.sp,
                                fontWeight = FontWeight.Bold,
                                color = if (isSelected) Color.White else MaterialTheme.colorScheme.onSurface
                            )
                        }
                    }
                }

                OutlinedTextField(
                    value = notes,
                    onValueChange = { notes = it },
                    label = { Text(if (lang == AppLanguage.CHINESE) "种草理由 / 备注" else "Reason / Notes") },
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
                                    WishlistItem(
                                        title = title.trim(),
                                        targetPrice = priceStr.toDoubleOrNull() ?: 0.0,
                                        currency = selectedCurrency.symbol,
                                        coolOffDaysTotal = coolOffDays,
                                        notes = notes.trim()
                                    )
                                )
                                onDismiss()
                            }
                        },
                        enabled = title.isNotBlank(),
                        colors = ButtonDefaults.buttonColors(containerColor = BentoColors.WishlistRuby)
                    ) {
                        Text(if (lang == AppLanguage.CHINESE) "保存" else "Save")
                    }
                }
            }
        }
    }
}
