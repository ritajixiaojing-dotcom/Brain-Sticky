package com.example.brainsticky.model

import kotlinx.serialization.Serializable
import java.util.UUID

@Serializable
enum class AppLanguage(val code: String, val displayName: String) {
    CHINESE("zh", "🇨🇳 简体中文"),
    ENGLISH("en", "🇺🇸 English")
}

@Serializable
enum class BentoCategory(val titleZh: String, val titleEn: String, val icon: String, val colorHex: String) {
    TODO("待办", "Todo", "checklist", "#FF6B6B"),
    DROPS("日常", "Daily", "sparkles", "#FF9F1C"),
    VAULT("密码", "Vault", "lock", "#9D4EDD"),
    GROCERY("买菜", "Market", "cart", "#2EC4B6"),
    WISHLIST("剁手", "Wishlist", "gift", "#FF4081"),
    HABIT("打卡", "Check-in", "target", "#4D88FF")
}

enum class OmniType(val titleZh: String, val titleEn: String) {
    TODO("待办", "Todo"),
    DROP("日常", "Daily"),
    GROCERY("买菜", "Market"),
    WISHLIST("剁手", "Wishlist"),
    PASSWORD("密码", "Vault"),
    HABIT("打卡", "Check-in")
}

@Serializable
enum class TodoPriority(val labelZh: String, val labelEn: String, val hexColor: String) {
    URGENT("紧急", "Urgent", "#FF5A5F"),
    NORMAL("日常", "Normal", "#FF9F1C"),
    SOMEDAY("随缘", "Someday", "#4D88FF");

    fun getLabel(lang: AppLanguage): String = if (lang == AppLanguage.CHINESE) labelZh else labelEn
}

@Serializable
data class TodoItem(
    val id: String = UUID.randomUUID().toString(),
    val title: String,
    val isCompleted: Boolean = false,
    val priority: TodoPriority = TodoPriority.NORMAL,
    val reminderMinutes: Int? = null,
    val createdAt: Long = System.currentTimeMillis()
)

@Serializable
data class StickyNoteItem(
    val id: String = UUID.randomUUID().toString(),
    val content: String,
    val moodEmoji: String = "✨",
    val colorHex: String = "#FFF7D1",
    val textColorHex: String = "#1E293B",
    val isPinned: Boolean = false,
    val createdAt: Long = System.currentTimeMillis()
)

@Serializable
enum class VaultCategory(val labelZh: String, val labelEn: String) {
    DROP("日常", "Drops"),
    CUSTOM("密码", "Custom");

    fun getLabel(lang: AppLanguage): String = if (lang == AppLanguage.CHINESE) labelZh else labelEn
}

@Serializable
data class VaultItem(
    val id: String = UUID.randomUUID().toString(),
    val title: String,
    val category: VaultCategory = VaultCategory.CUSTOM,
    val accountOrKey: String = "",
    val secretValue: String,
    val notes: String = "",
    val updatedAt: Long = System.currentTimeMillis(),
    val isMasked: Boolean = true
)

@Serializable
enum class GroceryAisle(val labelZh: String, val labelEn: String, val icon: String) {
    PRODUCE("果蔬", "Produce", "🥬"),
    MEAT("肉禽", "Meat", "🥩"),
    DAIRY("乳品", "Dairy", "🥛"),
    SNACKS("零食", "Snacks", "🍿"),
    ESSENTIALS("粮油", "Pantry", "🌾"),
    DAILY("百货", "Daily", "🧴"),
    OTHERS("其他", "Other", "📦");

    fun getLabel(lang: AppLanguage): String = if (lang == AppLanguage.CHINESE) labelZh else labelEn
    fun getCuteTitle(lang: AppLanguage): String = "$icon ${getLabel(lang)}"
}

@Serializable
data class GroceryItem(
    val id: String = UUID.randomUUID().toString(),
    val name: String,
    val aisle: GroceryAisle = GroceryAisle.OTHERS,
    val quantity: String = "1",
    val isBought: Boolean = false,
    val isFrequent: Boolean = false,
    val createdAt: Long = System.currentTimeMillis()
)

@Serializable
enum class WishlistCurrency(val symbol: String, val nameZh: String, val nameEn: String) {
    CNY("¥", "元", "CNY"),
    USD("$", "美元", "USD"),
    JPY("円", "日币", "JPY"),
    EUR("€", "欧元", "EUR");

    fun getName(lang: AppLanguage): String = if (lang == AppLanguage.CHINESE) nameZh else nameEn

    fun format(price: Double): String {
        return if (this == JPY) {
            if (price < 0) "-${kotlin.math.abs(price.toLong())} 円" else "${price.toLong()} 円"
        } else {
            if (price < 0) "-$symbol${kotlin.math.abs(price.toLong())}" else "$symbol${price.toLong()}"
        }
    }

    companion object {
        fun fromSymbol(sym: String): WishlistCurrency {
            return when (sym) {
                "$", "USD" -> USD
                "円", "JPY", "JP¥" -> JPY
                "€", "EUR" -> EUR
                else -> CNY
            }
        }
    }
}

@Serializable
data class WishlistItem(
    val id: String = UUID.randomUUID().toString(),
    val title: String,
    val targetPrice: Double = 0.0,
    val currency: String = "¥",
    val coolOffDaysTotal: Int = 14,
    val coolOffStartDate: Long = System.currentTimeMillis(),
    val notes: String = "",
    val isPurchased: Boolean = false,
    val isAbandoned: Boolean = false
) {
    val daysPassed: Int
        get() {
            val diff = System.currentTimeMillis() - coolOffStartDate
            return (diff / (1000 * 60 * 60 * 24)).toInt().coerceAtLeast(0)
        }

    val daysRemaining: Int
        get() = if (coolOffDaysTotal >= 9999) 9999 else (coolOffDaysTotal - daysPassed).coerceAtLeast(0)

    val coolOffProgress: Float
        get() {
            if (coolOffDaysTotal >= 9999) return 0f
            if (coolOffDaysTotal <= 0) return 1f
            return (daysPassed.toFloat() / coolOffDaysTotal.toFloat()).coerceIn(0f, 1f)
        }
}

@Serializable
data class CustomEntryItem(
    val id: String = UUID.randomUUID().toString(),
    val icon: String = "⭐️",
    val title: String,
    val detail: String = "",
    val isCompleted: Boolean = false,
    val streakDays: Int = 0,
    val count: Int = 0,
    val lastCompletedDate: String = "",
    val historyDates: List<String> = emptyList(),
    val lastCheckedInTimestamp: Long = 0L
) {
    val isCheckedInWithin24Hours: Boolean
        get() {
            if (lastCheckedInTimestamp <= 0L) return count > 0
            return (System.currentTimeMillis() - lastCheckedInTimestamp) < 24L * 3600L * 1000L
        }

    fun nextCheckInCountdown(lang: AppLanguage): String {
        if (lastCheckedInTimestamp <= 0L) {
            return if (lang == AppLanguage.CHINESE) "24小时后可再次打卡" else "Next check-in in 24h"
        }
        val elapsed = System.currentTimeMillis() - lastCheckedInTimestamp
        val total24h = 24L * 3600L * 1000L
        if (elapsed >= total24h) {
            return if (lang == AppLanguage.CHINESE) "已满24小时，可+1打卡 ✨" else "24h reached, ready for +1 ✨"
        }
        val remaining = total24h - elapsed
        val hours = (remaining / (1000 * 3600)).toInt()
        val minutes = ((remaining % (1000 * 3600)) / (1000 * 60)).toInt()
        return if (lang == AppLanguage.CHINESE) {
            if (hours > 0) "24小时倒数：${hours}小时${minutes}分后可再次打卡" else "24小时倒数：${kotlin.math.max(1, minutes)}分钟后可再次打卡"
        } else {
            if (hours > 0) "Next +1 available in ${hours}h ${minutes}m" else "Next +1 available in ${kotlin.math.max(1, minutes)}m"
        }
    }
}

@Serializable
data class CustomModule(
    val id: String = "habit_module",
    val title: String = "打卡",
    val subtitle: String = "坚持微小日常，日积月累 ✨",
    val icon: String = "target",
    val themeColorHex: String = "#4D88FF",
    val entries: List<CustomEntryItem> = emptyList()
)

data class BuiltinHabitPreset(
    val icon: String,
    val titleZh: String,
    val titleEn: String,
    val detailZh: String,
    val detailEn: String
) {
    fun getTitle(lang: AppLanguage): String = if (lang == AppLanguage.CHINESE) titleZh else titleEn
    fun getDetail(lang: AppLanguage): String = if (lang == AppLanguage.CHINESE) detailZh else detailEn

    companion object {
        val ALL = listOf(
            BuiltinHabitPreset("🏃", "晨跑锻炼", "Morning Run", "有氧 20 分钟", "20 mins cardio"),
            BuiltinHabitPreset("💧", "多喝水", "Drink Water", "每天 8 杯温水", "8 cups of water"),
            BuiltinHabitPreset("🌙", "早睡早起", "Sleep Early", "23:00 前放下手机", "No phone after 11 PM"),
            BuiltinHabitPreset("📖", "每日阅读", "Daily Reading", "读 10 页好书", "Read 10 pages"),
            BuiltinHabitPreset("🧘", "正念冥想", "Meditation", "深呼吸放空 10 分钟", "10 mins breathing"),
            BuiltinHabitPreset("🇬🇧", "背单词", "Vocab & English", "打卡 20 个新单词", "Learn 20 new words"),
            BuiltinHabitPreset("💰", "今日记账", "Expense Tracking", "记录每一笔开销", "Log all daily spendings"),
            BuiltinHabitPreset("🧴", "早晚护肤", "Skincare Routine", "防晒与补水", "Moisturize & sunscreen"),
            BuiltinHabitPreset("✨", "其他", "Other", "", "")
        )
    }
}
