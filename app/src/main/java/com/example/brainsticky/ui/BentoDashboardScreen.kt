package com.example.brainsticky.ui

import androidx.activity.compose.BackHandler
import androidx.compose.foundation.background
import androidx.compose.foundation.clickable
import androidx.compose.foundation.layout.*
import androidx.compose.foundation.lazy.LazyColumn
import androidx.compose.foundation.shape.CircleShape
import androidx.compose.foundation.shape.RoundedCornerShape
import androidx.compose.material.icons.Icons
import androidx.compose.material.icons.automirrored.filled.ArrowBack
import androidx.compose.material.icons.filled.*
import androidx.compose.material3.*
import androidx.compose.runtime.*
import androidx.compose.ui.Alignment
import androidx.compose.ui.Modifier
import androidx.compose.ui.draw.clip
import androidx.compose.ui.draw.shadow
import androidx.compose.ui.graphics.Color
import androidx.compose.ui.graphics.vector.ImageVector
import androidx.compose.ui.text.font.FontWeight
import androidx.compose.ui.text.style.TextOverflow
import androidx.compose.ui.unit.dp
import androidx.compose.ui.unit.sp
import com.example.brainsticky.data.DataStore
import com.example.brainsticky.model.AppLanguage
import com.example.brainsticky.model.WishlistCurrency
import com.example.brainsticky.theme.BentoColors

enum class ScreenRoute {
    DASHBOARD,
    TODO,
    DROPS,
    VAULT,
    GROCERY,
    WISHLIST,
    HABITS,
    SETTINGS
}

@OptIn(ExperimentalMaterial3Api::class)
@Composable
fun BentoDashboardScreen(
    dataStore: DataStore,
    onNavigate: (ScreenRoute) -> Unit
) {
    val lang = dataStore.language
    var isShowingCaptureDialog by remember { mutableStateOf(false) }
    var isShowingCloudsOverview by remember { mutableStateOf(false) }

    val totalPendingTodos = dataStore.todos.count { !it.isCompleted }
    val totalNotes = dataStore.stickyNotes.size
    val totalVault = dataStore.vaultItems.size
    val totalPendingGrocery = dataStore.groceryItems.count { !it.isBought }
    val totalActiveWishlist = dataStore.wishlistItems.count { !it.isPurchased && !it.isAbandoned }
    val totalHabits = dataStore.customModules.firstOrNull()?.entries?.count { !it.isCompleted } ?: 0

    val totalClouds = totalPendingTodos + totalPendingGrocery + totalActiveWishlist + totalHabits

    val searchQuery = dataStore.searchText.trim()
    val isSearching = searchQuery.isNotEmpty()

    // Handle back button when searching to return to home desktop
    BackHandler(enabled = isSearching) {
        dataStore.searchText = ""
    }

    Scaffold(
        floatingActionButton = {
            Button(
                onClick = { isShowingCaptureDialog = true },
                shape = RoundedCornerShape(24.dp),
                colors = ButtonDefaults.buttonColors(containerColor = BentoColors.NoteAmber),
                modifier = Modifier
                    .height(48.dp)
                    .shadow(8.dp, RoundedCornerShape(24.dp), spotColor = BentoColors.NoteAmber.copy(alpha = 0.5f))
            ) {
                Row(
                    verticalAlignment = Alignment.CenterVertically,
                    horizontalArrangement = Arrangement.spacedBy(6.dp)
                ) {
                    Text(
                        text = if (lang == AppLanguage.CHINESE) "✨ 收集点滴 🫧" else "✨ Quick Capture 🫧",
                        fontWeight = FontWeight.Bold,
                        fontSize = 14.sp,
                        color = Color.White
                    )
                }
            }
        },
        floatingActionButtonPosition = FabPosition.Center
    ) { innerPadding ->
        LazyColumn(
            modifier = Modifier
                .fillMaxSize()
                .padding(innerPadding)
                .background(MaterialTheme.colorScheme.background)
                .padding(horizontal = 16.dp),
            verticalArrangement = Arrangement.spacedBy(14.dp)
        ) {
            item { Spacer(modifier = Modifier.height(10.dp)) }

            // MARK: - Header (Cute & Bouncy Typography)
            item {
                Row(
                    modifier = Modifier.fillMaxWidth(),
                    horizontalArrangement = Arrangement.SpaceBetween,
                    verticalAlignment = Alignment.Top
                ) {
                    Column(verticalArrangement = Arrangement.spacedBy(4.dp)) {
                        Row(
                            verticalAlignment = Alignment.CenterVertically,
                            horizontalArrangement = Arrangement.spacedBy(8.dp)
                        ) {
                            Text(
                                text = if (lang == AppLanguage.CHINESE) "脑雾收集站 🫧" else "Brain Sticky 🫧",
                                fontSize = 25.sp,
                                fontWeight = FontWeight.Black,
                                letterSpacing = 0.5.sp,
                                color = MaterialTheme.colorScheme.onBackground
                            )

                            Box(
                                modifier = Modifier
                                    .clip(RoundedCornerShape(12.dp))
                                    .background(BentoColors.OmniElectric.copy(alpha = 0.15f))
                                    .clickable { isShowingCloudsOverview = true }
                                    .padding(horizontal = 9.dp, vertical = 4.dp)
                            ) {
                                Row(
                                    verticalAlignment = Alignment.CenterVertically,
                                    horizontalArrangement = Arrangement.spacedBy(4.dp)
                                ) {
                                    Text(
                                        text = if (totalClouds == 0) {
                                            if (lang == AppLanguage.CHINESE) "✨ 脑袋放空" else "✨ Mind Clear"
                                        } else {
                                            if (lang == AppLanguage.CHINESE) "☁️ $totalClouds 朵" else "☁️ $totalClouds Clouds"
                                        },
                                        fontSize = 11.sp,
                                        fontWeight = FontWeight.ExtraBold,
                                        color = BentoColors.OmniElectric
                                    )
                                    Icon(
                                        Icons.Default.Info,
                                        contentDescription = "Overview",
                                        tint = BentoColors.OmniElectric.copy(alpha = 0.7f),
                                        modifier = Modifier.size(12.dp)
                                    )
                                }
                            }
                        }

                        Text(
                            text = if (lang == AppLanguage.CHINESE) "今天也把所有琐事交给我吧 ～ ✨" else "Leave all the little chores to me today ✨",
                            fontSize = 12.sp,
                            fontWeight = FontWeight.Medium,
                            color = MaterialTheme.colorScheme.onBackground.copy(alpha = 0.6f)
                        )
                    }

                    IconButton(
                        onClick = { onNavigate(ScreenRoute.SETTINGS) },
                        modifier = Modifier
                            .size(38.dp)
                            .clip(CircleShape)
                            .background(MaterialTheme.colorScheme.surface)
                    ) {
                        Icon(
                            Icons.Default.Settings,
                            contentDescription = "Settings",
                            tint = MaterialTheme.colorScheme.onSurface.copy(alpha = 0.7f),
                            modifier = Modifier.size(20.dp)
                        )
                    }
                }
            }

            // MARK: - Search Bar
            item {
                TextField(
                    value = dataStore.searchText,
                    onValueChange = { dataStore.searchText = it },
                    placeholder = {
                        Text(
                            if (lang == AppLanguage.CHINESE) "搜索脑雾与灵感..." else "Search brain fog & notes...",
                            fontSize = 13.sp
                        )
                    },
                    leadingIcon = {
                        Icon(
                            Icons.Default.Search,
                            contentDescription = "Search",
                            tint = MaterialTheme.colorScheme.onSurface.copy(alpha = 0.4f),
                            modifier = Modifier.size(18.dp)
                        )
                    },
                    trailingIcon = {
                        if (isSearching) {
                            IconButton(onClick = { dataStore.searchText = "" }) {
                                Icon(Icons.Default.Close, contentDescription = "Clear", modifier = Modifier.size(16.dp))
                            }
                        }
                    },
                    singleLine = true,
                    shape = RoundedCornerShape(16.dp),
                    colors = TextFieldDefaults.colors(
                        focusedContainerColor = MaterialTheme.colorScheme.surface,
                        unfocusedContainerColor = MaterialTheme.colorScheme.surface,
                        focusedIndicatorColor = Color.Transparent,
                        unfocusedIndicatorColor = Color.Transparent
                    ),
                    modifier = Modifier
                        .fillMaxWidth()
                        .shadow(2.dp, RoundedCornerShape(16.dp))
                )
            }

            // MARK: - Bento Grid (When not searching)
            if (!isSearching) {
                // Row 1: Todo & Drops
                item {
                    Row(
                        modifier = Modifier.fillMaxWidth(),
                        horizontalArrangement = Arrangement.spacedBy(12.dp)
                    ) {
                        BentoCard(
                            title = if (lang == AppLanguage.CHINESE) "待办" else "Todo",
                            badgeCount = totalPendingTodos,
                            icon = Icons.Default.Checklist,
                            themeColor = BentoColors.UrgentCoral,
                            modifier = Modifier.weight(1f),
                            onClick = { onNavigate(ScreenRoute.TODO) }
                        ) {
                            if (dataStore.todos.isEmpty()) {
                                Text(
                                    text = if (lang == AppLanguage.CHINESE) "脑袋放空 ✨" else "Mind is clear ✨",
                                    fontSize = 11.sp,
                                    color = MaterialTheme.colorScheme.onSurface.copy(alpha = 0.5f)
                                )
                            } else {
                                Column(verticalArrangement = Arrangement.spacedBy(4.dp)) {
                                    dataStore.todos.filter { !it.isCompleted }.take(2).forEach { item ->
                                        Text(
                                            text = "• ${item.title}",
                                            fontSize = 11.sp,
                                            fontWeight = FontWeight.Medium,
                                            maxLines = 1,
                                            overflow = TextOverflow.Ellipsis
                                        )
                                    }
                                }
                            }
                        }

                        BentoCard(
                            title = if (lang == AppLanguage.CHINESE) "日常" else "Daily",
                            badgeCount = totalNotes,
                            icon = Icons.Default.AutoAwesome,
                            themeColor = BentoColors.NoteAmber,
                            modifier = Modifier.weight(1f),
                            onClick = { onNavigate(ScreenRoute.DROPS) }
                        ) {
                            val latestNote = dataStore.stickyNotes.firstOrNull()
                            if (latestNote == null) {
                                Text(
                                    text = if (lang == AppLanguage.CHINESE) "写下此刻想法..." else "Jot down thoughts...",
                                    fontSize = 11.sp,
                                    color = MaterialTheme.colorScheme.onSurface.copy(alpha = 0.5f)
                                )
                            } else {
                                Text(
                                    text = "${latestNote.moodEmoji} ${latestNote.content}",
                                    fontSize = 11.sp,
                                    fontWeight = FontWeight.Medium,
                                    maxLines = 2,
                                    overflow = TextOverflow.Ellipsis
                                )
                            }
                        }
                    }
                }

                // Row 2: Vault & Market
                item {
                    Row(
                        modifier = Modifier.fillMaxWidth(),
                        horizontalArrangement = Arrangement.spacedBy(12.dp)
                    ) {
                        BentoCard(
                            title = if (lang == AppLanguage.CHINESE) "密码" else "Vault",
                            badgeCount = totalVault,
                            icon = Icons.Default.Lock,
                            themeColor = BentoColors.VaultViolet,
                            modifier = Modifier.weight(1f),
                            onClick = { onNavigate(ScreenRoute.VAULT) }
                        ) {
                            Text(
                                text = if (lang == AppLanguage.CHINESE) "钥匙已妥善安放 🔒" else "Passwords secured 🔒",
                                fontSize = 11.sp,
                                color = MaterialTheme.colorScheme.onSurface.copy(alpha = 0.55f)
                            )
                        }

                        BentoCard(
                            title = if (lang == AppLanguage.CHINESE) "买菜" else "Market",
                            badgeCount = totalPendingGrocery,
                            icon = Icons.Default.ShoppingCart,
                            themeColor = BentoColors.GroceryMint,
                            modifier = Modifier.weight(1f),
                            onClick = { onNavigate(ScreenRoute.GROCERY) }
                        ) {
                            if (dataStore.groceryItems.isEmpty()) {
                                Text(
                                    text = if (lang == AppLanguage.CHINESE) "冰箱满满当当 🥕" else "Fridge is full 🥕",
                                    fontSize = 11.sp,
                                    color = MaterialTheme.colorScheme.onSurface.copy(alpha = 0.5f)
                                )
                            } else {
                                Column(verticalArrangement = Arrangement.spacedBy(2.dp)) {
                                    dataStore.groceryItems.filter { !it.isBought }.take(2).forEach { item ->
                                        Text(
                                            text = "${item.aisle.icon} ${item.name}",
                                            fontSize = 11.sp,
                                            fontWeight = FontWeight.Medium,
                                            maxLines = 1,
                                            overflow = TextOverflow.Ellipsis
                                        )
                                    }
                                }
                            }
                        }
                    }
                }

                // Row 3: Wishlist & Habits
                item {
                    Row(
                        modifier = Modifier.fillMaxWidth(),
                        horizontalArrangement = Arrangement.spacedBy(12.dp)
                    ) {
                        BentoCard(
                            title = if (lang == AppLanguage.CHINESE) "剁手" else "Wishlist",
                            badgeCount = totalActiveWishlist,
                            icon = Icons.Default.CardGiftcard,
                            themeColor = BentoColors.WishlistRuby,
                            modifier = Modifier.weight(1f),
                            onClick = { onNavigate(ScreenRoute.WISHLIST) }
                        ) {
                            val firstWish = dataStore.wishlistItems.firstOrNull { !it.isPurchased && !it.isAbandoned }
                            if (firstWish == null) {
                                Text(
                                    text = if (lang == AppLanguage.CHINESE) "心如止水 🧸" else "Peaceful mind 🧸",
                                    fontSize = 11.sp,
                                    color = MaterialTheme.colorScheme.onSurface.copy(alpha = 0.5f)
                                )
                            } else {
                                Text(
                                    text = "${firstWish.title}\n${if (lang == AppLanguage.CHINESE) "还剩 ${firstWish.daysRemaining} 天" else "${firstWish.daysRemaining} days left"}",
                                    fontSize = 11.sp,
                                    fontWeight = FontWeight.Bold,
                                    color = BentoColors.WishlistRuby,
                                    maxLines = 2
                                )
                            }
                        }

                        BentoCard(
                            title = if (lang == AppLanguage.CHINESE) "打卡" else "Check-in",
                            badgeCount = totalHabits,
                            icon = Icons.Default.Adjust,
                            themeColor = BentoColors.OmniElectric,
                            modifier = Modifier.weight(1f),
                            onClick = { onNavigate(ScreenRoute.HABITS) }
                        ) {
                            val habits = dataStore.customModules.firstOrNull()?.entries ?: emptyList()
                            if (habits.isEmpty()) {
                                Text(
                                    text = if (lang == AppLanguage.CHINESE) "添加微习惯 ✨" else "Add habits ✨",
                                    fontSize = 11.sp,
                                    color = MaterialTheme.colorScheme.onSurface.copy(alpha = 0.5f)
                                )
                            } else {
                                Column(verticalArrangement = Arrangement.spacedBy(2.dp)) {
                                    habits.take(2).forEach { h ->
                                        Text(
                                            text = "${h.icon} ${h.title}",
                                            fontSize = 11.sp,
                                            fontWeight = FontWeight.Medium,
                                            maxLines = 1,
                                            overflow = TextOverflow.Ellipsis
                                        )
                                    }
                                }
                            }
                        }
                    }
                }
            } else {
                // Search Results
                // Search Results (Universal Search across all 6 modules)
                item {
                    val matchedTodos = dataStore.todos.filter { it.title.contains(searchQuery, ignoreCase = true) }
                    val matchedNotes = dataStore.stickyNotes.filter { it.content.contains(searchQuery, ignoreCase = true) }
                    val matchedVault = dataStore.vaultItems.filter {
                        it.title.contains(searchQuery, ignoreCase = true) ||
                        it.accountOrKey.contains(searchQuery, ignoreCase = true) ||
                        it.notes.contains(searchQuery, ignoreCase = true)
                    }
                    val matchedGrocery = dataStore.groceryItems.filter { it.name.contains(searchQuery, ignoreCase = true) }
                    val matchedWishlist = dataStore.wishlistItems.filter {
                        it.title.contains(searchQuery, ignoreCase = true) ||
                        it.notes.contains(searchQuery, ignoreCase = true)
                    }
                    val matchedHabits = dataStore.customModules.flatMap { it.entries }.filter {
                        it.title.contains(searchQuery, ignoreCase = true) ||
                        it.detail.contains(searchQuery, ignoreCase = true) ||
                        it.icon.contains(searchQuery)
                    }

                    val totalMatches = matchedTodos.size + matchedNotes.size + matchedVault.size + matchedGrocery.size + matchedWishlist.size + matchedHabits.size

                    Column(verticalArrangement = Arrangement.spacedBy(8.dp)) {
                        Row(
                            modifier = Modifier.fillMaxWidth(),
                            horizontalArrangement = Arrangement.SpaceBetween,
                            verticalAlignment = Alignment.CenterVertically
                        ) {
                            Row(
                                verticalAlignment = Alignment.CenterVertically,
                                horizontalArrangement = Arrangement.spacedBy(6.dp)
                            ) {
                                Text(
                                    text = if (lang == AppLanguage.CHINESE) "搜索结果" else "Results",
                                    fontSize = 14.sp,
                                    fontWeight = FontWeight.Bold
                                )
                                Box(
                                    modifier = Modifier
                                        .clip(RoundedCornerShape(8.dp))
                                        .background(BentoColors.OmniElectric.copy(alpha = 0.15f))
                                        .padding(horizontal = 7.dp, vertical = 2.dp)
                                ) {
                                    Text(
                                        text = "$totalMatches",
                                        fontSize = 11.sp,
                                        fontWeight = FontWeight.Black,
                                        color = BentoColors.OmniElectric
                                    )
                                }
                            }

                            IconButton(
                                onClick = { dataStore.searchText = "" },
                                modifier = Modifier.size(28.dp)
                            ) {
                                Icon(
                                    Icons.Default.Close,
                                    contentDescription = "Close",
                                    tint = MaterialTheme.colorScheme.onSurface.copy(alpha = 0.5f),
                                    modifier = Modifier.size(16.dp)
                                )
                            }
                        }

                        if (totalMatches == 0) {
                            Box(
                                modifier = Modifier
                                    .fillMaxWidth()
                                    .padding(vertical = 24.dp),
                                contentAlignment = Alignment.Center
                            ) {
                                Text(
                                    text = if (lang == AppLanguage.CHINESE) "🔍 未找到与「$searchQuery」相关的脑雾记录" else "🔍 No items found for \"$searchQuery\"",
                                    fontSize = 13.sp,
                                    color = MaterialTheme.colorScheme.onSurface.copy(alpha = 0.5f)
                                )
                            }
                        }

                        // Match Todos
                        matchedTodos.forEach { item ->
                            SearchResultItem(title = item.title, category = if (lang == AppLanguage.CHINESE) "待办" else "Todo", color = BentoColors.UrgentCoral) {
                                onNavigate(ScreenRoute.TODO)
                            }
                        }

                        // Match Notes
                        matchedNotes.forEach { note ->
                            SearchResultItem(title = note.content, category = if (lang == AppLanguage.CHINESE) "日常" else "Daily", color = BentoColors.NoteAmber) {
                                onNavigate(ScreenRoute.DROPS)
                            }
                        }

                        // Match Habits & Check-ins (打卡、运动、锻炼、阅读等)
                        matchedHabits.forEach { habit ->
                            val habitLabel = "${habit.icon} ${habit.title}${if (habit.detail.isNotBlank()) " · ${habit.detail}" else ""}"
                            SearchResultItem(title = habitLabel, category = if (lang == AppLanguage.CHINESE) "打卡" else "Check-in", color = BentoColors.OmniElectric) {
                                onNavigate(ScreenRoute.HABITS)
                            }
                        }

                        // Match Vault
                        matchedVault.forEach { v ->
                            SearchResultItem(title = v.title, category = if (lang == AppLanguage.CHINESE) "密码" else "Vault", color = BentoColors.VaultViolet) {
                                onNavigate(ScreenRoute.VAULT)
                            }
                        }

                        // Match Grocery
                        matchedGrocery.forEach { g ->
                            SearchResultItem(title = g.name, category = if (lang == AppLanguage.CHINESE) "买菜" else "Market", color = BentoColors.GroceryMint) {
                                onNavigate(ScreenRoute.GROCERY)
                            }
                        }

                        // Match Wishlist
                        matchedWishlist.forEach { w ->
                            SearchResultItem(title = w.title, category = if (lang == AppLanguage.CHINESE) "剁手" else "Wishlist", color = BentoColors.WishlistRuby) {
                                onNavigate(ScreenRoute.WISHLIST)
                            }
                        }
                    }
                }
            }

            item { Spacer(modifier = Modifier.height(70.dp)) }
        }
    }

    if (isShowingCaptureDialog) {
        OmniCaptureDialog(
            lang = lang,
            onDismiss = { isShowingCaptureDialog = false },
            onSave = { dataStore.addStickyNote(it) }
        )
    }

    if (isShowingCloudsOverview) {
        ModalBottomSheet(
            onDismissRequest = { isShowingCloudsOverview = false },
            sheetState = rememberModalBottomSheetState(skipPartiallyExpanded = true),
            containerColor = MaterialTheme.colorScheme.surface,
            shape = RoundedCornerShape(topStart = 24.dp, topEnd = 24.dp)
        ) {
            Column(
                modifier = Modifier
                    .fillMaxWidth()
                    .padding(horizontal = 20.dp)
                    .padding(bottom = 36.dp),
                verticalArrangement = Arrangement.spacedBy(14.dp)
            ) {
                // Header
                Row(
                    modifier = Modifier.fillMaxWidth(),
                    horizontalArrangement = Arrangement.SpaceBetween,
                    verticalAlignment = Alignment.CenterVertically
                ) {
                    Column(verticalArrangement = Arrangement.spacedBy(2.dp)) {
                        Text(
                            text = if (lang == AppLanguage.CHINESE) "☁️ 脑雾琐事全貌清单" else "☁️ Records Overview",
                            fontSize = 18.sp,
                            fontWeight = FontWeight.Black
                        )
                        Text(
                            text = if (totalClouds == 0) {
                                if (lang == AppLanguage.CHINESE) "当前无任何未完成事项，脑袋一身轻 ～ ✨" else "No pending items, your mind is clear! ✨"
                            } else {
                                if (lang == AppLanguage.CHINESE) "当前累计 $totalClouds 项待办/记录，点击可直达：" else "$totalClouds pending items, tap to jump:"
                            },
                            fontSize = 12.sp,
                            color = MaterialTheme.colorScheme.onSurface.copy(alpha = 0.6f)
                        )
                    }

                    IconButton(onClick = { isShowingCloudsOverview = false }) {
                        Icon(Icons.Default.Close, contentDescription = "Close", modifier = Modifier.size(20.dp))
                    }
                }

                HorizontalDivider(color = MaterialTheme.colorScheme.onSurface.copy(alpha = 0.08f))

                val activeTodos = dataStore.todos.filter { !it.isCompleted }
                val activeGrocery = dataStore.groceryItems.filter { !it.isBought }
                val activeWishlist = dataStore.wishlistItems.filter { !it.isPurchased && !it.isAbandoned }
                val activeHabits = dataStore.customModules.firstOrNull()?.entries?.filter { !it.isCompleted } ?: emptyList()

                LazyColumn(
                    modifier = Modifier.fillMaxWidth(),
                    verticalArrangement = Arrangement.spacedBy(10.dp)
                ) {
                    // 1. Todos
                    if (activeTodos.isNotEmpty()) {
                        item {
                            OverviewSectionCard(
                                title = if (lang == AppLanguage.CHINESE) "📋 待办事项 (${activeTodos.size})" else "📋 Todos (${activeTodos.size})",
                                color = BentoColors.UrgentCoral,
                                items = activeTodos.map { it.title },
                                onClick = {
                                    isShowingCloudsOverview = false
                                    onNavigate(ScreenRoute.TODO)
                                }
                            )
                        }
                    }

                    // 2. Grocery
                    if (activeGrocery.isNotEmpty()) {
                        item {
                            OverviewSectionCard(
                                title = if (lang == AppLanguage.CHINESE) "🥦 待买补货 (${activeGrocery.size})" else "🥦 Market (${activeGrocery.size})",
                                color = BentoColors.GroceryMint,
                                items = activeGrocery.map { "${it.aisle.icon} ${it.name}" },
                                onClick = {
                                    isShowingCloudsOverview = false
                                    onNavigate(ScreenRoute.GROCERY)
                                }
                            )
                        }
                    }

                    // 3. Wishlist
                    if (activeWishlist.isNotEmpty()) {
                        item {
                            OverviewSectionCard(
                                title = if (lang == AppLanguage.CHINESE) "🛍️ 剁手冷静 (${activeWishlist.size})" else "🛍️ Wishlist (${activeWishlist.size})",
                                color = BentoColors.WishlistRuby,
                                items = activeWishlist.map { it.title },
                                onClick = {
                                    isShowingCloudsOverview = false
                                    onNavigate(ScreenRoute.WISHLIST)
                                }
                            )
                        }
                    }

                    // 4. Habits
                    if (activeHabits.isNotEmpty()) {
                        item {
                            OverviewSectionCard(
                                title = if (lang == AppLanguage.CHINESE) "🎯 今日待打卡 (${activeHabits.size})" else "🎯 Check-ins (${activeHabits.size})",
                                color = BentoColors.OmniElectric,
                                items = activeHabits.map { "${it.icon} ${it.title}" },
                                onClick = {
                                    isShowingCloudsOverview = false
                                    onNavigate(ScreenRoute.HABITS)
                                }
                            )
                        }
                    }

                    // 5. Notes / Vault Summary
                    item {
                        Row(
                            modifier = Modifier.fillMaxWidth(),
                            horizontalArrangement = Arrangement.spacedBy(10.dp)
                        ) {
                            Box(
                                modifier = Modifier
                                    .weight(1f)
                                    .clip(RoundedCornerShape(14.dp))
                                    .background(BentoColors.NoteAmber.copy(alpha = 0.12f))
                                    .clickable {
                                        isShowingCloudsOverview = false
                                        onNavigate(ScreenRoute.DROPS)
                                    }
                                    .padding(12.dp)
                            ) {
                                Column(verticalArrangement = Arrangement.spacedBy(4.dp)) {
                                    Text(
                                        text = if (lang == AppLanguage.CHINESE) "✨ 日常便签" else "✨ Daily Notes",
                                        fontWeight = FontWeight.Bold,
                                        fontSize = 13.sp,
                                        color = BentoColors.NoteAmber
                                    )
                                    Text(
                                        text = if (lang == AppLanguage.CHINESE) "已存 ${dataStore.stickyNotes.size} 条灵感" else "${dataStore.stickyNotes.size} notes",
                                        fontSize = 11.sp,
                                        color = MaterialTheme.colorScheme.onSurface.copy(alpha = 0.7f)
                                    )
                                }
                            }

                            Box(
                                modifier = Modifier
                                    .weight(1f)
                                    .clip(RoundedCornerShape(14.dp))
                                    .background(BentoColors.VaultViolet.copy(alpha = 0.12f))
                                    .clickable {
                                        isShowingCloudsOverview = false
                                        onNavigate(ScreenRoute.VAULT)
                                    }
                                    .padding(12.dp)
                            ) {
                                Column(verticalArrangement = Arrangement.spacedBy(4.dp)) {
                                    Text(
                                        text = if (lang == AppLanguage.CHINESE) "🔐 密码钥匙盒" else "🔐 Vault",
                                        fontWeight = FontWeight.Bold,
                                        fontSize = 13.sp,
                                        color = BentoColors.VaultViolet
                                    )
                                    Text(
                                        text = if (lang == AppLanguage.CHINESE) "已存 ${dataStore.vaultItems.size} 条凭证" else "${dataStore.vaultItems.size} items",
                                        fontSize = 11.sp,
                                        color = MaterialTheme.colorScheme.onSurface.copy(alpha = 0.7f)
                                    )
                                }
                            }
                        }
                    }
                }
            }
        }
    }
}

@Composable
fun OverviewSectionCard(
    title: String,
    color: Color,
    items: List<String>,
    onClick: () -> Unit
) {
    Card(
        shape = RoundedCornerShape(16.dp),
        colors = CardDefaults.cardColors(containerColor = MaterialTheme.colorScheme.surfaceVariant.copy(alpha = 0.35f)),
        modifier = Modifier
            .fillMaxWidth()
            .clickable { onClick() }
    ) {
        Column(
            modifier = Modifier
                .fillMaxWidth()
                .padding(12.dp),
            verticalArrangement = Arrangement.spacedBy(6.dp)
        ) {
            Row(
                modifier = Modifier.fillMaxWidth(),
                horizontalArrangement = Arrangement.SpaceBetween,
                verticalAlignment = Alignment.CenterVertically
            ) {
                Text(
                    text = title,
                    fontWeight = FontWeight.Bold,
                    fontSize = 13.sp,
                    color = color
                )
                Text(
                    text = "👉",
                    fontSize = 12.sp
                )
            }

            items.take(4).forEach { itemText ->
                Text(
                    text = "• $itemText",
                    fontSize = 12.sp,
                    maxLines = 1,
                    overflow = TextOverflow.Ellipsis,
                    color = MaterialTheme.colorScheme.onSurface.copy(alpha = 0.75f)
                )
            }
        }
    }
}

@Composable
fun BentoCard(
    title: String,
    badgeCount: Int,
    icon: ImageVector,
    themeColor: Color,
    modifier: Modifier = Modifier,
    onClick: () -> Unit,
    content: @Composable () -> Unit
) {
    Card(
        shape = RoundedCornerShape(22.dp),
        colors = CardDefaults.cardColors(containerColor = MaterialTheme.colorScheme.surface),
        modifier = modifier
            .height(134.dp)
            .shadow(3.dp, RoundedCornerShape(22.dp), spotColor = themeColor.copy(alpha = 0.2f))
            .clickable { onClick() }
    ) {
        Column(
            modifier = Modifier
                .fillMaxSize()
                .padding(14.dp),
            verticalArrangement = Arrangement.SpaceBetween
        ) {
            Row(
                modifier = Modifier.fillMaxWidth(),
                horizontalArrangement = Arrangement.SpaceBetween,
                verticalAlignment = Alignment.CenterVertically
            ) {
                Row(
                    verticalAlignment = Alignment.CenterVertically,
                    horizontalArrangement = Arrangement.spacedBy(7.dp)
                ) {
                    Box(
                        modifier = Modifier
                            .size(28.dp)
                            .clip(RoundedCornerShape(9.dp))
                            .background(themeColor.copy(alpha = 0.16f)),
                        contentAlignment = Alignment.Center
                    ) {
                        Icon(icon, contentDescription = null, tint = themeColor, modifier = Modifier.size(15.dp))
                    }

                    Text(
                        text = title,
                        fontWeight = FontWeight.ExtraBold,
                        fontSize = 15.sp,
                        letterSpacing = 0.3.sp,
                        color = MaterialTheme.colorScheme.onSurface
                    )
                }

                if (badgeCount > 0) {
                    Box(
                        modifier = Modifier
                            .clip(RoundedCornerShape(8.dp))
                            .background(themeColor)
                            .padding(horizontal = 7.dp, vertical = 2.dp)
                    ) {
                        Text(
                            text = "$badgeCount",
                            fontSize = 10.sp,
                            fontWeight = FontWeight.Black,
                            color = Color.White
                        )
                    }
                }
            }

            Box(modifier = Modifier.fillMaxWidth()) {
                content()
            }
        }
    }
}

@Composable
fun SearchResultItem(
    title: String,
    category: String,
    color: Color,
    onClick: () -> Unit
) {
    Card(
        shape = RoundedCornerShape(14.dp),
        colors = CardDefaults.cardColors(containerColor = MaterialTheme.colorScheme.surface),
        modifier = Modifier
            .fillMaxWidth()
            .clickable { onClick() }
    ) {
        Row(
            modifier = Modifier
                .fillMaxWidth()
                .padding(12.dp),
            horizontalArrangement = Arrangement.SpaceBetween,
            verticalAlignment = Alignment.CenterVertically
        ) {
            Text(
                text = title,
                fontSize = 13.sp,
                fontWeight = FontWeight.Medium,
                maxLines = 1,
                overflow = TextOverflow.Ellipsis,
                modifier = Modifier.weight(1f)
            )

            Box(
                modifier = Modifier
                    .clip(RoundedCornerShape(6.dp))
                    .background(color.copy(alpha = 0.15f))
                    .padding(horizontal = 8.dp, vertical = 3.dp)
            ) {
                Text(
                    text = category,
                    fontSize = 10.sp,
                    fontWeight = FontWeight.Bold,
                    color = color
                )
            }
        }
    }
}
