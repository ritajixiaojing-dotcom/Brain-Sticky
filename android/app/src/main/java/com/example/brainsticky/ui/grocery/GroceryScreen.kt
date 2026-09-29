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
import androidx.compose.foundation.text.KeyboardActions
import androidx.compose.foundation.text.KeyboardOptions
import androidx.compose.material.icons.Icons
import androidx.compose.material.icons.automirrored.filled.ArrowBack
import androidx.compose.material.icons.filled.Add
import androidx.compose.material.icons.filled.ArrowDropDown
import androidx.compose.material.icons.filled.Check
import androidx.compose.material.icons.filled.Delete
import androidx.compose.material3.*
import androidx.compose.runtime.*
import androidx.compose.ui.Alignment
import androidx.compose.ui.Modifier
import androidx.compose.ui.draw.clip
import androidx.compose.ui.graphics.Color
import androidx.compose.ui.text.font.FontWeight
import androidx.compose.ui.text.input.ImeAction
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
    var groceryToDelete by remember { mutableStateOf<GroceryItem?>(null) }

    val totalCount = dataStore.groceryItems.size
    val boughtCount = dataStore.groceryItems.count { it.isBought }
    val progress = if (totalCount > 0) boughtCount.toFloat() / totalCount.toFloat() else 0f

    val groupedItems = remember(dataStore.groceryItems) {
        dataStore.groceryItems.groupBy { it.aisle }
    }

    val commitAddGrocery = {
        if (newItemName.isNotBlank()) {
            dataStore.addGroceryItem(
                GroceryItem(
                    name = newItemName.trim(),
                    aisle = selectedAisle
                )
            )
            newItemName = ""
        }
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

            // Quick Add Row with Left Aisle Category Dropdown Menu
            Row(
                modifier = Modifier.fillMaxWidth(),
                horizontalArrangement = Arrangement.spacedBy(8.dp),
                verticalAlignment = Alignment.CenterVertically
            ) {
                // Standalone Left Category Pill
                Box {
                    Row(
                        modifier = Modifier
                            .height(52.dp)
                            .clip(RoundedCornerShape(14.dp))
                            .background(BentoColors.GroceryMint.copy(alpha = 0.15f))
                            .clickable { isAisleMenuExpanded = true }
                            .padding(horizontal = 10.dp),
                        verticalAlignment = Alignment.CenterVertically,
                        horizontalArrangement = Arrangement.spacedBy(3.dp)
                    ) {
                        Text(selectedAisle.icon, fontSize = 18.sp)
                        Text(
                            text = selectedAisle.getLabel(lang),
                            fontSize = 13.sp,
                            fontWeight = FontWeight.Bold,
                            color = BentoColors.GroceryMint
                        )
                        Icon(
                            Icons.Default.ArrowDropDown,
                            contentDescription = "Select Aisle",
                            tint = BentoColors.GroceryMint,
                            modifier = Modifier.size(18.dp)
                        )
                    }

                    DropdownMenu(
                        expanded = isAisleMenuExpanded,
                        onDismissRequest = { isAisleMenuExpanded = false }
                    ) {
                        GroceryAisle.entries.forEach { aisle ->
                            DropdownMenuItem(
                                text = {
                                    Row(
                                        horizontalArrangement = Arrangement.spacedBy(8.dp),
                                        verticalAlignment = Alignment.CenterVertically
                                    ) {
                                        Text(aisle.icon, fontSize = 18.sp)
                                        Text(
                                            text = aisle.getLabel(lang),
                                            fontWeight = if (selectedAisle == aisle) FontWeight.Bold else FontWeight.Normal,
                                            color = if (selectedAisle == aisle) BentoColors.GroceryMint else MaterialTheme.colorScheme.onSurface
                                        )
                                    }
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
                            if (lang == AppLanguage.CHINESE) "想买点什么呢 🍓..." else "What to buy 🍓...",
                            fontSize = 13.sp
                        )
                    },
                    singleLine = true,
                    keyboardOptions = KeyboardOptions(imeAction = ImeAction.Done),
                    keyboardActions = KeyboardActions(onDone = { commitAddGrocery() }),
                    shape = RoundedCornerShape(14.dp),
                    colors = TextFieldDefaults.colors(
                        focusedContainerColor = MaterialTheme.colorScheme.surfaceVariant.copy(alpha = 0.45f),
                        unfocusedContainerColor = MaterialTheme.colorScheme.surfaceVariant.copy(alpha = 0.3f),
                        focusedIndicatorColor = Color.Transparent,
                        unfocusedIndicatorColor = Color.Transparent
                    ),
                    modifier = Modifier
                        .weight(1f)
                        .height(52.dp)
                )

                IconButton(
                    onClick = commitAddGrocery,
                    enabled = newItemName.isNotBlank(),
                    modifier = Modifier
                        .size(52.dp)
                        .clip(RoundedCornerShape(14.dp))
                        .background(if (newItemName.isNotBlank()) BentoColors.GroceryMint else MaterialTheme.colorScheme.surfaceVariant.copy(alpha = 0.3f))
                ) {
                    Icon(
                        Icons.Default.Add,
                        contentDescription = "Add",
                        tint = Color.White
                    )
                }
            }

            // Clean Unified Grocery Items List
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
                    verticalArrangement = Arrangement.spacedBy(10.dp)
                ) {
                    items(dataStore.groceryItems, key = { it.id }) { item ->
                        com.example.brainsticky.ui.components.SwipeToDeleteContainer(
                            onDelete = { groceryToDelete = item },
                            deleteLabel = if (lang == AppLanguage.CHINESE) "删除" else "Delete"
                        ) {
                            GroceryItemRow(
                                item = item,
                                onToggle = { dataStore.toggleGrocery(item.id) },
                                onDelete = { groceryToDelete = item }
                            )
                        }
                    }
                }
            }
        }
    }

    // Delete Confirmation Dialog
    groceryToDelete?.let { item ->
        AlertDialog(
            onDismissRequest = { groceryToDelete = null },
            title = {
                Text(
                    text = if (lang == AppLanguage.CHINESE) "确认删除此物品？" else "Delete Grocery Item?",
                    fontWeight = FontWeight.Bold
                )
            },
            text = {
                Text(
                    text = if (lang == AppLanguage.CHINESE) "确定要从买菜清单中删除「${item.name}」吗？" else "Are you sure you want to delete \"${item.name}\" from list?"
                )
            },
            confirmButton = {
                Button(
                    onClick = {
                        dataStore.deleteGroceryItem(item.id)
                        groceryToDelete = null
                    },
                    colors = ButtonDefaults.buttonColors(containerColor = MaterialTheme.colorScheme.error)
                ) {
                    Text(if (lang == AppLanguage.CHINESE) "删除" else "Delete")
                }
            },
            dismissButton = {
                TextButton(onClick = { groceryToDelete = null }) {
                    Text(if (lang == AppLanguage.CHINESE) "取消" else "Cancel")
                }
            }
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

            Text(item.aisle.icon, fontSize = 18.sp)

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
                    tint = MaterialTheme.colorScheme.onSurface.copy(alpha = 0.35f),
                    modifier = Modifier.size(16.dp)
                )
            }
        }
    }
}
