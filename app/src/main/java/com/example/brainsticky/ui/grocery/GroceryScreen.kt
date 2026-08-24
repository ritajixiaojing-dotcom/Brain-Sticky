package com.example.brainsticky.ui.grocery

import androidx.compose.foundation.background
import androidx.compose.foundation.border
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
import androidx.compose.ui.text.style.TextDecoration
import androidx.compose.ui.unit.dp
import androidx.compose.ui.unit.sp
import androidx.compose.ui.window.Dialog
import com.example.brainsticky.data.DataStore
import com.example.brainsticky.model.AppLanguage
import com.example.brainsticky.model.GroceryAisle
import com.example.brainsticky.model.GroceryItem
import com.example.brainsticky.theme.BentoColors

@OptIn(ExperimentalMaterial3Api::class)
@Composable
fun GroceryScreen(
    dataStore: DataStore,
    onBack: () -> Unit
) {
    val lang = dataStore.language
    var newItemName by remember { mutableStateOf("") }
    var selectedAisle by remember { mutableStateOf(GroceryAisle.PRODUCE) }
    var isShowingFrequentDialog by remember { mutableStateOf(false) }
    var isAisleMenuExpanded by remember { mutableStateOf(false) }

    val totalCount = dataStore.groceryItems.size
    val boughtCount = dataStore.groceryItems.count { it.isBought }
    val progress = if (totalCount > 0) boughtCount.toFloat() / totalCount.toFloat() else 0f

    val groupedItems = remember(dataStore.groceryItems) {
        dataStore.groceryItems.groupBy { it.aisle }
    }

    Scaffold(
        topBar = {
            TopAppBar(
                title = {
                    Text(
                        if (lang == AppLanguage.CHINESE) "买菜与补货" else "Market & Grocery",
                        fontWeight = FontWeight.Bold
                    )
                },
                navigationIcon = {
                    IconButton(onClick = onBack) {
                        Icon(Icons.AutoMirrored.Filled.ArrowBack, contentDescription = "Back")
                    }
                },
                actions = {
                    TextButton(onClick = { isShowingFrequentDialog = true }) {
                        Text(
                            text = if (lang == AppLanguage.CHINESE) "常购库" else "Frequent",
                            fontWeight = FontWeight.Bold,
                            color = BentoColors.GroceryMint
                        )
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
            // Top Progress Card
            Card(
                shape = RoundedCornerShape(18.dp),
                colors = CardDefaults.cardColors(containerColor = MaterialTheme.colorScheme.surface),
                modifier = Modifier.fillMaxWidth()
            ) {
                Column(
                    modifier = Modifier.padding(14.dp),
                    verticalArrangement = Arrangement.spacedBy(8.dp)
                ) {
                    Row(
                        modifier = Modifier.fillMaxWidth(),
                        horizontalArrangement = Arrangement.SpaceBetween,
                        verticalAlignment = Alignment.CenterVertically
                    ) {
                        Text(
                            text = if (lang == AppLanguage.CHINESE) "采购进度" else "Shopping Progress",
                            fontWeight = FontWeight.Bold,
                            fontSize = 13.sp,
                            color = MaterialTheme.colorScheme.onSurface.copy(alpha = 0.7f)
                        )

                        Text(
                            text = "$boughtCount / $totalCount",
                            fontWeight = FontWeight.ExtraBold,
                            fontSize = 14.sp,
                            color = BentoColors.GroceryMint
                        )
                    }

                    LinearProgressIndicator(
                        progress = { progress },
                        modifier = Modifier
                            .fillMaxWidth()
                            .height(8.dp)
                            .clip(RoundedCornerShape(4.dp)),
                        color = BentoColors.GroceryMint,
                        trackColor = BentoColors.GroceryMint.copy(alpha = 0.15f)
                    )
                }
            }

            // Floating Category Selector Pills
            LazyRow(
                horizontalArrangement = Arrangement.spacedBy(8.dp),
                modifier = Modifier.fillMaxWidth()
            ) {
                items(GroceryAisle.entries) { aisle ->
                    val isSelected = selectedAisle == aisle
                    Box(
                        modifier = Modifier
                            .clip(RoundedCornerShape(12.dp))
                            .background(
                                if (isSelected) BentoColors.GroceryMint else MaterialTheme.colorScheme.surfaceVariant.copy(alpha = 0.5f)
                            )
                            .clickable { selectedAisle = aisle }
                            .padding(horizontal = 12.dp, vertical = 7.dp)
                    ) {
                        Text(
                            text = aisle.getCuteTitle(lang),
                            fontSize = 12.sp,
                            fontWeight = if (isSelected) FontWeight.Bold else FontWeight.Medium,
                            color = if (isSelected) Color.White else MaterialTheme.colorScheme.onSurface
                        )
                    }
                }
            }

            // Quick Add Row
            Row(
                modifier = Modifier.fillMaxWidth(),
                horizontalArrangement = Arrangement.spacedBy(8.dp),
                verticalAlignment = Alignment.CenterVertically
            ) {
                // Aisle Selector Chip with Floating Dropdown Menu
                Box {
                    Box(
                        modifier = Modifier
                            .clip(RoundedCornerShape(12.dp))
                            .background(BentoColors.GroceryMint.copy(alpha = 0.15f))
                            .clickable { isAisleMenuExpanded = true }
                            .padding(horizontal = 10.dp, vertical = 12.dp)
                    ) {
                        Row(
                            verticalAlignment = Alignment.CenterVertically,
                            horizontalArrangement = Arrangement.spacedBy(4.dp)
                        ) {
                            Text(
                                text = selectedAisle.getCuteTitle(lang),
                                fontWeight = FontWeight.Bold,
                                fontSize = 12.sp,
                                color = BentoColors.GroceryMint
                            )
                            Text("▾", fontSize = 10.sp, color = BentoColors.GroceryMint)
                        }
                    }

                    DropdownMenu(
                        expanded = isAisleMenuExpanded,
                        onDismissRequest = { isAisleMenuExpanded = false }
                    ) {
                        GroceryAisle.entries.forEach { aisle ->
                            DropdownMenuItem(
                                text = {
                                    Text(
                                        text = aisle.getCuteTitle(lang),
                                        fontWeight = if (selectedAisle == aisle) FontWeight.Bold else FontWeight.Normal,
                                        color = if (selectedAisle == aisle) BentoColors.GroceryMint else MaterialTheme.colorScheme.onSurface
                                    )
                                },
                                onClick = {
                                    selectedAisle = aisle
                                    isAisleMenuExpanded = false
                                }
                            )
                        }
                    }
                }

                TextField(
                    value = newItemName,
                    onValueChange = { newItemName = it },
                    placeholder = {
                        Text(
                            if (lang == AppLanguage.CHINESE) "输入想买的物品..." else "Add item...",
                            fontSize = 13.sp
                        )
                    },
                    singleLine = true,
                    shape = RoundedCornerShape(12.dp),
                    colors = TextFieldDefaults.colors(
                        focusedContainerColor = MaterialTheme.colorScheme.surfaceVariant.copy(alpha = 0.4f),
                        unfocusedContainerColor = MaterialTheme.colorScheme.surfaceVariant.copy(alpha = 0.3f),
                        focusedIndicatorColor = Color.Transparent,
                        unfocusedIndicatorColor = Color.Transparent
                    ),
                    modifier = Modifier.weight(1f)
                )

                IconButton(
                    onClick = {
                        if (newItemName.isNotBlank()) {
                            dataStore.addGroceryItem(
                                GroceryItem(
                                    name = newItemName.trim(),
                                    aisle = selectedAisle
                                )
                            )
                            newItemName = ""
                        }
                    },
                    enabled = newItemName.isNotBlank(),
                    modifier = Modifier
                        .size(44.dp)
                        .clip(RoundedCornerShape(12.dp))
                        .background(if (newItemName.isNotBlank()) BentoColors.GroceryMint else MaterialTheme.colorScheme.surfaceVariant.copy(alpha = 0.3f))
                ) {
                    Icon(
                        Icons.Default.Add,
                        contentDescription = "Add",
                        tint = Color.White
                    )
                }
            }

            // Grocery Aisle Groups List
            if (dataStore.groceryItems.isEmpty()) {
                Box(
                    modifier = Modifier
                        .fillMaxWidth()
                        .weight(1f),
                    contentAlignment = Alignment.Center
                ) {
                    Column(
                        horizontalAlignment = Alignment.CenterHorizontally,
                        verticalArrangement = Arrangement.spacedBy(8.dp)
                    ) {
                        Text(text = "🥦", fontSize = 40.sp)
                        Text(
                            text = if (lang == AppLanguage.CHINESE) "无买菜项" else "No Grocery Items",
                            style = MaterialTheme.typography.bodyMedium,
                            color = MaterialTheme.colorScheme.onSurface.copy(alpha = 0.6f)
                        )
                    }
                }
            } else {
                LazyColumn(
                    modifier = Modifier.weight(1f),
                    verticalArrangement = Arrangement.spacedBy(14.dp)
                ) {
                    GroceryAisle.entries.forEach { aisle ->
                        val itemsInAisle = groupedItems[aisle]
                        if (!itemsInAisle.isNullOrEmpty()) {
                            item(key = "header_${aisle.name}") {
                                Text(
                                    text = aisle.getCuteTitle(lang),
                                    fontWeight = FontWeight.Bold,
                                    fontSize = 13.sp,
                                    color = MaterialTheme.colorScheme.onSurface.copy(alpha = 0.7f),
                                    modifier = Modifier.padding(start = 4.dp)
                                )
                            }

                            items(itemsInAisle, key = { it.id }) { item ->
                                GroceryItemRow(
                                    item = item,
                                    onToggle = { dataStore.toggleGrocery(item.id) },
                                    onDelete = { dataStore.deleteGroceryItem(item.id) }
                                )
                            }
                        }
                    }
                }
            }
        }
    }

    if (isShowingFrequentDialog) {
        FrequentGroceryDialog(
            dataStore = dataStore,
            lang = lang,
            onDismiss = { isShowingFrequentDialog = false }
        )
    }
}

@Composable
fun GroceryItemRow(
    item: GroceryItem,
    onToggle: () -> Unit,
    onDelete: () -> Unit
) {
    Card(
        shape = RoundedCornerShape(14.dp),
        colors = CardDefaults.cardColors(containerColor = MaterialTheme.colorScheme.surface),
        modifier = Modifier.fillMaxWidth()
    ) {
        Row(
            modifier = Modifier
                .fillMaxWidth()
                .padding(horizontal = 14.dp, vertical = 10.dp),
            verticalAlignment = Alignment.CenterVertically,
            horizontalArrangement = Arrangement.spacedBy(10.dp)
        ) {
            Box(
                modifier = Modifier
                    .size(24.dp)
                    .clip(CircleShape)
                    .background(if (item.isBought) BentoColors.GroceryMint else Color.Transparent)
                    .border(
                        width = 2.dp,
                        color = if (item.isBought) BentoColors.GroceryMint else MaterialTheme.colorScheme.outline.copy(alpha = 0.5f),
                        shape = CircleShape
                    )
                    .clickable { onToggle() },
                contentAlignment = Alignment.Center
            ) {
                if (item.isBought) {
                    Icon(
                        Icons.Default.Check,
                        contentDescription = "Bought",
                        tint = Color.White,
                        modifier = Modifier.size(14.dp)
                    )
                }
            }

            Text(
                text = item.name,
                fontSize = 14.sp,
                fontWeight = FontWeight.Medium,
                textDecoration = if (item.isBought) TextDecoration.LineThrough else TextDecoration.None,
                color = if (item.isBought) MaterialTheme.colorScheme.onSurface.copy(alpha = 0.4f) else MaterialTheme.colorScheme.onSurface,
                modifier = Modifier.weight(1f)
            )

            IconButton(
                onClick = onDelete,
                modifier = Modifier.size(24.dp)
            ) {
                Icon(
                    Icons.Default.Delete,
                    contentDescription = "Delete",
                    tint = MaterialTheme.colorScheme.error.copy(alpha = 0.5f),
                    modifier = Modifier.size(16.dp)
                )
            }
        }
    }
}

@Composable
fun FrequentGroceryDialog(
    dataStore: DataStore,
    lang: AppLanguage,
    onDismiss: () -> Unit
) {
    var newFreqName by remember { mutableStateOf("") }
    var newFreqAisle by remember { mutableStateOf(GroceryAisle.PRODUCE) }

    Dialog(onDismissRequest = onDismiss) {
        Card(
            shape = RoundedCornerShape(24.dp),
            colors = CardDefaults.cardColors(containerColor = MaterialTheme.colorScheme.surface),
            modifier = Modifier
                .fillMaxWidth()
                .heightIn(max = 520.dp)
        ) {
            Column(
                modifier = Modifier
                    .padding(20.dp)
                    .fillMaxWidth(),
                verticalArrangement = Arrangement.spacedBy(14.dp)
            ) {
                Row(
                    modifier = Modifier.fillMaxWidth(),
                    horizontalArrangement = Arrangement.SpaceBetween,
                    verticalAlignment = Alignment.CenterVertically
                ) {
                    Text(
                        text = if (lang == AppLanguage.CHINESE) "我的常购库" else "Frequent Items",
                        fontWeight = FontWeight.Bold,
                        fontSize = 17.sp
                    )

                    TextButton(onClick = onDismiss) {
                        Text(if (lang == AppLanguage.CHINESE) "完成" else "Done")
                    }
                }

                // Add frequent item input
                Row(
                    modifier = Modifier.fillMaxWidth(),
                    horizontalArrangement = Arrangement.spacedBy(6.dp)
                ) {
                    TextField(
                        value = newFreqName,
                        onValueChange = { newFreqName = it },
                        placeholder = { Text(if (lang == AppLanguage.CHINESE) "添加新常购物品..." else "Add frequent item...") },
                        singleLine = true,
                        modifier = Modifier.weight(1f)
                    )

                    IconButton(
                        onClick = {
                            if (newFreqName.isNotBlank()) {
                                dataStore.addFrequentGrocery(
                                    GroceryItem(
                                        name = newFreqName.trim(),
                                        aisle = newFreqAisle,
                                        isFrequent = true
                                    )
                                )
                                newFreqName = ""
                            }
                        }
                    ) {
                        Icon(Icons.Default.Add, contentDescription = "Add", tint = BentoColors.GroceryMint)
                    }
                }

                // List of frequent items
                LazyColumn(
                    modifier = Modifier.weight(1f),
                    verticalArrangement = Arrangement.spacedBy(8.dp)
                ) {
                    items(dataStore.frequentGroceryList, key = { it.id }) { item ->
                        Row(
                            modifier = Modifier
                                .fillMaxWidth()
                                .clip(RoundedCornerShape(12.dp))
                                .background(MaterialTheme.colorScheme.surfaceVariant.copy(alpha = 0.4f))
                                .padding(horizontal = 12.dp, vertical = 8.dp),
                            verticalAlignment = Alignment.CenterVertically,
                            horizontalArrangement = Arrangement.SpaceBetween
                        ) {
                            Row(
                                verticalAlignment = Alignment.CenterVertically,
                                horizontalArrangement = Arrangement.spacedBy(6.dp)
                            ) {
                                Text(item.aisle.icon)
                                Text(item.name, fontWeight = FontWeight.Medium, fontSize = 13.sp)
                            }

                            Button(
                                onClick = {
                                    dataStore.addGroceryItem(item.copy(id = java.util.UUID.randomUUID().toString(), isBought = false))
                                },
                                shape = RoundedCornerShape(10.dp),
                                colors = ButtonDefaults.buttonColors(containerColor = BentoColors.GroceryMint.copy(alpha = 0.2f)),
                                contentPadding = PaddingValues(horizontal = 10.dp, vertical = 4.dp)
                            ) {
                                Text(
                                    text = if (lang == AppLanguage.CHINESE) "+ 加入买菜" else "+ Add",
                                    color = BentoColors.GroceryMint,
                                    fontWeight = FontWeight.Bold,
                                    fontSize = 11.sp
                                )
                            }
                        }
                    }
                }
            }
        }
    }
}
