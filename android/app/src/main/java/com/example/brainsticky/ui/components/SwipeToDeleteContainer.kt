package com.example.brainsticky.ui.components

import androidx.compose.animation.core.Animatable
import androidx.compose.animation.core.Spring
import androidx.compose.animation.core.spring
import androidx.compose.animation.core.tween
import androidx.compose.foundation.background
import androidx.compose.foundation.clickable
import androidx.compose.foundation.gestures.detectHorizontalDragGestures
import androidx.compose.foundation.layout.*
import androidx.compose.foundation.shape.RoundedCornerShape
import androidx.compose.material.icons.Icons
import androidx.compose.material.icons.filled.Delete
import androidx.compose.material3.Icon
import androidx.compose.material3.Text
import androidx.compose.runtime.*
import androidx.compose.ui.Alignment
import androidx.compose.ui.Modifier
import androidx.compose.ui.draw.clip
import androidx.compose.ui.graphics.Color
import androidx.compose.ui.input.pointer.pointerInput
import androidx.compose.ui.platform.LocalDensity
import androidx.compose.ui.text.font.FontWeight
import androidx.compose.ui.unit.IntOffset
import androidx.compose.ui.unit.dp
import androidx.compose.ui.unit.sp
import kotlinx.coroutines.launch
import kotlin.math.roundToInt

@Composable
fun SwipeToDeleteContainer(
    onDelete: () -> Unit,
    modifier: Modifier = Modifier,
    cornerRadius: Int = 18,
    deleteLabel: String = "删除",
    content: @Composable () -> Unit
) {
    val currentOnDelete by rememberUpdatedState(onDelete)
    val coroutineScope = rememberCoroutineScope()
    val offsetX = remember { Animatable(0f) }
    val density = LocalDensity.current
    val triggerThresholdPx = with(density) { -35.dp.toPx() }
    val maxDragPx = with(density) { -130.dp.toPx() }

    Box(
        modifier = modifier
            .fillMaxWidth()
            .clip(RoundedCornerShape(cornerRadius.dp))
    ) {
        // Red background with delete action
        Box(
            modifier = Modifier
                .matchParentSize()
                .background(Color(0xFFEF4444))
                .clickable {
                    coroutineScope.launch {
                        offsetX.animateTo(0f, tween(180, easing = androidx.compose.animation.core.FastOutSlowInEasing))
                    }
                    currentOnDelete()
                }
                .padding(end = 18.dp),
            contentAlignment = Alignment.CenterEnd
        ) {
            Row(
                verticalAlignment = Alignment.CenterVertically,
                horizontalArrangement = Arrangement.spacedBy(6.dp)
            ) {
                Icon(
                    imageVector = Icons.Default.Delete,
                    contentDescription = "Delete",
                    tint = Color.White,
                    modifier = Modifier.size(20.dp)
                )
                Text(
                    text = deleteLabel,
                    color = Color.White,
                    fontWeight = FontWeight.Bold,
                    fontSize = 14.sp
                )
            }
        }

        // Foreground Card Content
        Box(
            modifier = Modifier
                .fillMaxWidth()
                .offset { IntOffset(offsetX.value.roundToInt(), 0) }
                .pointerInput(Unit) {
                    detectHorizontalDragGestures(
                        onDragStart = {},
                        onDragEnd = {
                            val shouldDelete = offsetX.value <= triggerThresholdPx
                            coroutineScope.launch {
                                offsetX.animateTo(0f, tween(200, easing = androidx.compose.animation.core.FastOutSlowInEasing))
                            }
                            if (shouldDelete) {
                                currentOnDelete()
                            }
                        },
                        onDragCancel = {
                            coroutineScope.launch {
                                offsetX.animateTo(0f, tween(200, easing = androidx.compose.animation.core.FastOutSlowInEasing))
                            }
                        },
                        onHorizontalDrag = { change, dragAmount ->
                            change.consume()
                            coroutineScope.launch {
                                val target = (offsetX.value + dragAmount).coerceIn(maxDragPx, 0f)
                                offsetX.snapTo(target)
                            }
                        }
                    )
                }
        ) {
            content()
        }
    }
}
