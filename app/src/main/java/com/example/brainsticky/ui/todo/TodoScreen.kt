package com.example.brainsticky.ui.todo

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
import com.example.brainsticky.data.DataStore
import com.example.brainsticky.model.AppLanguage
import com.example.brainsticky.model.TodoItem
import com.example.brainsticky.model.TodoPriority
import com.example.brainsticky.theme.BentoColors

@OptIn(ExperimentalMaterial3Api::class)
@Composable
fun TodoScreen(
    dataStore: DataStore,
    onBack: () -> Unit
) {
    val lang = dataStore.language
    var newTodoTitle by remember { mutableStateOf("") }
    var selectedPriority by remember { mutableStateOf(TodoPriority.NORMAL) }
    var selectedMinutes by remember { mutableStateOf<Int?>(15) }

    Scaffold(
        topBar = {
            TopAppBar(
                title = {
                    Text(
                        if (lang == AppLanguage.CHINESE) "待办清单" else "Todo List",
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
            verticalArrangement = Arrangement.spacedBy(14.dp)
        ) {
            // Quick Add Card
            Card(
                shape = RoundedCornerShape(20.dp),
                colors = CardDefaults.cardColors(containerColor = MaterialTheme.colorScheme.surface),
                modifier = Modifier.fillMaxWidth()
            ) {
                Column(
                    modifier = Modifier.padding(14.dp),
                    verticalArrangement = Arrangement.spacedBy(10.dp)
                ) {
                    TextField(
                        value = newTodoTitle,
                        onValueChange = { newTodoTitle = it },
                        placeholder = {
                            Text(
                                if (lang == AppLanguage.CHINESE) "输入待办事项..." else "Add a new todo...",
                                fontSize = 14.sp
                            )
                        },
                        singleLine = true,
                        colors = TextFieldDefaults.colors(
                            focusedContainerColor = MaterialTheme.colorScheme.surfaceVariant.copy(alpha = 0.4f),
                            unfocusedContainerColor = MaterialTheme.colorScheme.surfaceVariant.copy(alpha = 0.3f),
                            focusedIndicatorColor = Color.Transparent,
                            unfocusedIndicatorColor = Color.Transparent
                        ),
                        shape = RoundedCornerShape(12.dp),
                        modifier = Modifier.fillMaxWidth()
                    )

                    // Priority Selector
                    Row(
                        modifier = Modifier.fillMaxWidth(),
                        horizontalArrangement = Arrangement.spacedBy(8.dp)
                    ) {
                        TodoPriority.entries.forEach { p ->
                            val isSelected = selectedPriority == p
                            val pColor = BentoColors.colorForHex(p.hexColor)
                            Box(
                                modifier = Modifier
                                    .weight(1f)
                                    .clip(RoundedCornerShape(10.dp))
                                    .background(if (isSelected) pColor else MaterialTheme.colorScheme.surfaceVariant.copy(alpha = 0.4f))
                                    .clickable { selectedPriority = p }
                                    .padding(vertical = 8.dp),
                                contentAlignment = Alignment.Center
                            ) {
                                Text(
                                    text = p.getLabel(lang),
                                    color = if (isSelected) Color.White else MaterialTheme.colorScheme.onSurface,
                                    fontWeight = FontWeight.Bold,
                                    fontSize = 12.sp
                                )
                            }
                        }
                    }

                    // Time / Reminder Selector Row
                    Text(
                        text = if (lang == AppLanguage.CHINESE) "⏰ 提醒时间" else "⏰ Reminder Time",
                        fontSize = 11.sp,
                        fontWeight = FontWeight.Bold,
                        color = MaterialTheme.colorScheme.onSurface.copy(alpha = 0.6f)
                    )

                    val timeOptions = listOf(
                        Pair(null, if (lang == AppLanguage.CHINESE) "无提醒" else "None"),
                        Pair(15, if (lang == AppLanguage.CHINESE) "15 分钟" else "15m"),
                        Pair(30, if (lang == AppLanguage.CHINESE) "30 分钟" else "30m"),
                        Pair(60, if (lang == AppLanguage.CHINESE) "1 小时" else "1h"),
                        Pair(120, if (lang == AppLanguage.CHINESE) "2 小时" else "2h"),
                        Pair(480, if (lang == AppLanguage.CHINESE) "今晚" else "Tonight"),
                        Pair(1440, if (lang == AppLanguage.CHINESE) "明天" else "Tomorrow")
                    )

                    LazyRow(
                        horizontalArrangement = Arrangement.spacedBy(8.dp),
                        modifier = Modifier.fillMaxWidth()
                    ) {
                        items(timeOptions) { (mins, label) ->
                            val isSelected = selectedMinutes == mins
                            Box(
                                modifier = Modifier
                                    .clip(RoundedCornerShape(10.dp))
                                    .background(
                                        if (isSelected) BentoColors.UrgentCoral.copy(alpha = 0.2f) else MaterialTheme.colorScheme.surfaceVariant.copy(alpha = 0.4f)
                                    )
                                    .border(
                                        width = if (isSelected) 1.5.dp else 0.dp,
                                        color = if (isSelected) BentoColors.UrgentCoral else Color.Transparent,
                                        shape = RoundedCornerShape(10.dp)
                                    )
                                    .clickable { selectedMinutes = mins }
                                    .padding(horizontal = 10.dp, vertical = 6.dp)
                            ) {
                                Text(
                                    text = label,
                                    fontSize = 11.sp,
                                    fontWeight = if (isSelected) FontWeight.Bold else FontWeight.Normal,
                                    color = if (isSelected) BentoColors.UrgentCoral else MaterialTheme.colorScheme.onSurface
                                )
                            }
                        }
                    }

                    // Add Button
                    Button(
                        onClick = {
                            if (newTodoTitle.isNotBlank()) {
                                dataStore.addTodo(
                                    TodoItem(
                                        title = newTodoTitle.trim(),
                                        priority = selectedPriority,
                                        reminderMinutes = selectedMinutes
                                    )
                                )
                                newTodoTitle = ""
                            }
                        },
                        enabled = newTodoTitle.isNotBlank(),
                        shape = RoundedCornerShape(12.dp),
                        colors = ButtonDefaults.buttonColors(containerColor = BentoColors.UrgentCoral),
                        modifier = Modifier.fillMaxWidth()
                    ) {
                        Text(
                            text = if (lang == AppLanguage.CHINESE) "添加待办" else "Add Todo",
                            fontWeight = FontWeight.Bold,
                            color = Color.White
                        )
                    }
                }
            }

            // List of Todos
            if (dataStore.todos.isEmpty()) {
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
                        Text(text = "✨", fontSize = 36.sp)
                        Text(
                            text = if (lang == AppLanguage.CHINESE) "脑袋放空，今天超棒 ✨" else "Mind is clear, having a great day ✨",
                            style = MaterialTheme.typography.bodyMedium,
                            color = MaterialTheme.colorScheme.onSurface.copy(alpha = 0.6f)
                        )
                    }
                }
            } else {
                LazyColumn(
                    modifier = Modifier.weight(1f),
                    verticalArrangement = Arrangement.spacedBy(8.dp)
                ) {
                    items(dataStore.todos, key = { it.id }) { item ->
                        TodoCardRow(
                            item = item,
                            lang = lang,
                            onToggle = { dataStore.toggleTodo(item.id) },
                            onDelete = { dataStore.deleteTodo(item.id) }
                        )
                    }
                }
            }
        }
    }
}

@Composable
fun TodoCardRow(
    item: TodoItem,
    lang: AppLanguage,
    onToggle: () -> Unit,
    onDelete: () -> Unit
) {
    val pColor = BentoColors.colorForHex(item.priority.hexColor)

    Card(
        shape = RoundedCornerShape(16.dp),
        colors = CardDefaults.cardColors(containerColor = MaterialTheme.colorScheme.surface),
        modifier = Modifier.fillMaxWidth()
    ) {
        Row(
            modifier = Modifier
                .fillMaxWidth()
                .padding(horizontal = 14.dp, vertical = 12.dp),
            verticalAlignment = Alignment.CenterVertically,
            horizontalArrangement = Arrangement.spacedBy(12.dp)
        ) {
            // Checkbox Circle
            Box(
                modifier = Modifier
                    .size(26.dp)
                    .clip(CircleShape)
                    .background(if (item.isCompleted) BentoColors.GroceryMint else Color.Transparent)
                    .border(
                        width = 2.dp,
                        color = if (item.isCompleted) BentoColors.GroceryMint else pColor,
                        shape = CircleShape
                    )
                    .clickable { onToggle() },
                contentAlignment = Alignment.Center
            ) {
                if (item.isCompleted) {
                    Icon(
                        Icons.Default.Check,
                        contentDescription = "Completed",
                        tint = Color.White,
                        modifier = Modifier.size(16.dp)
                    )
                }
            }

            // Title & Priority
            Column(
                modifier = Modifier.weight(1f),
                verticalArrangement = Arrangement.spacedBy(2.dp)
            ) {
                Text(
                    text = item.title,
                    fontSize = 14.sp,
                    fontWeight = FontWeight.Medium,
                    textDecoration = if (item.isCompleted) TextDecoration.LineThrough else TextDecoration.None,
                    color = if (item.isCompleted) MaterialTheme.colorScheme.onSurface.copy(alpha = 0.4f) else MaterialTheme.colorScheme.onSurface
                )

                Row(
                    horizontalArrangement = Arrangement.spacedBy(6.dp),
                    verticalAlignment = Alignment.CenterVertically
                ) {
                    Box(
                        modifier = Modifier
                            .clip(RoundedCornerShape(6.dp))
                            .background(pColor.copy(alpha = 0.15f))
                            .padding(horizontal = 6.dp, vertical = 2.dp)
                    ) {
                        Text(
                            text = item.priority.getLabel(lang),
                            fontSize = 10.sp,
                            fontWeight = FontWeight.Bold,
                            color = pColor
                        )
                    }

                    if (item.reminderMinutes != null) {
                        val timeLabel = when (item.reminderMinutes) {
                            15 -> if (lang == AppLanguage.CHINESE) "15分钟" else "15m"
                            30 -> if (lang == AppLanguage.CHINESE) "30分钟" else "30m"
                            60 -> if (lang == AppLanguage.CHINESE) "1小时" else "1h"
                            120 -> if (lang == AppLanguage.CHINESE) "2小时" else "2h"
                            480 -> if (lang == AppLanguage.CHINESE) "今晚" else "Tonight"
                            1440 -> if (lang == AppLanguage.CHINESE) "明天" else "Tomorrow"
                            else -> "${item.reminderMinutes}m"
                        }
                        Box(
                            modifier = Modifier
                                .clip(RoundedCornerShape(6.dp))
                                .background(BentoColors.UrgentCoral.copy(alpha = 0.12f))
                                .padding(horizontal = 6.dp, vertical = 2.dp)
                        ) {
                            Text(
                                text = "⏰ $timeLabel",
                                fontSize = 10.sp,
                                fontWeight = FontWeight.Bold,
                                color = BentoColors.UrgentCoral
                            )
                        }
                    }
                }
            }

            // Delete button
            IconButton(
                onClick = onDelete,
                modifier = Modifier.size(28.dp)
            ) {
                Icon(
                    Icons.Default.Delete,
                    contentDescription = "Delete",
                    tint = MaterialTheme.colorScheme.error.copy(alpha = 0.7f),
                    modifier = Modifier.size(18.dp)
                )
            }
        }
    }
}
