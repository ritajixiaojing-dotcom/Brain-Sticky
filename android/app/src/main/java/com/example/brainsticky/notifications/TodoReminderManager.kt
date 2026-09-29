package com.example.brainsticky.notifications

import android.app.AlarmManager
import android.app.PendingIntent
import android.content.Context
import android.content.Intent
import android.os.Build
import android.util.Log
import com.example.brainsticky.model.TodoItem

object TodoReminderManager {
    private const val TAG = "TodoReminderManager"

    fun scheduleTodoReminder(context: Context, item: TodoItem) {
        val minutes = item.reminderMinutes ?: return
        if (minutes <= 0) return

        val alarmManager = context.getSystemService(Context.ALARM_SERVICE) as? AlarmManager ?: return
        val intent = Intent(context, TodoAlarmReceiver::class.java).apply {
            putExtra("todo_id", item.id)
            putExtra("todo_title", item.title)
        }

        val pendingIntent = PendingIntent.getBroadcast(
            context,
            item.id.hashCode(),
            intent,
            PendingIntent.FLAG_UPDATE_CURRENT or PendingIntent.FLAG_IMMUTABLE
        )

        val triggerAtMillis = System.currentTimeMillis() + (minutes * 60 * 1000L)

        try {
            if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.M) {
                alarmManager.setExactAndAllowWhileIdle(
                    AlarmManager.RTC_WAKEUP,
                    triggerAtMillis,
                    pendingIntent
                )
            } else {
                alarmManager.setExact(
                    AlarmManager.RTC_WAKEUP,
                    triggerAtMillis,
                    pendingIntent
                )
            }
            Log.d(TAG, "Scheduled reminder for '${item.title}' in $minutes minutes (at $triggerAtMillis)")
        } catch (e: Exception) {
            Log.e(TAG, "Failed to schedule alarm: ${e.message}")
        }
    }

    fun cancelTodoReminder(context: Context, itemId: String) {
        val alarmManager = context.getSystemService(Context.ALARM_SERVICE) as? AlarmManager ?: return
        val intent = Intent(context, TodoAlarmReceiver::class.java)
        val pendingIntent = PendingIntent.getBroadcast(
            context,
            itemId.hashCode(),
            intent,
            PendingIntent.FLAG_UPDATE_CURRENT or PendingIntent.FLAG_IMMUTABLE
        )
        try {
            alarmManager.cancel(pendingIntent)
            Log.d(TAG, "Cancelled reminder for ID: $itemId")
        } catch (e: Exception) {
            Log.e(TAG, "Failed to cancel alarm: ${e.message}")
        }
    }
}
