package com.example.brainsticky.data

import android.content.Context
import android.content.SharedPreferences
import androidx.compose.runtime.getValue
import androidx.compose.runtime.mutableStateOf
import androidx.compose.runtime.setValue
import com.example.brainsticky.model.*
import kotlinx.serialization.encodeToString
import kotlinx.serialization.json.Json
import java.util.UUID

class DataStore private constructor(context: Context) {
    private val prefs: SharedPreferences = context.getSharedPreferences("brain_sticky_data", Context.MODE_PRIVATE)
    private val json = Json { ignoreUnknownKeys = true; prettyPrint = false }

    var language by mutableStateOf(AppLanguage.CHINESE)
        private set

    var searchText by mutableStateOf("")

    var todos by mutableStateOf<List<TodoItem>>(emptyList())
        private set

    var stickyNotes by mutableStateOf<List<StickyNoteItem>>(emptyList())
        private set

    var vaultItems by mutableStateOf<List<VaultItem>>(emptyList())
        private set

    var groceryItems by mutableStateOf<List<GroceryItem>>(emptyList())
        private set

    var frequentGroceryList by mutableStateOf<List<GroceryItem>>(emptyList())
        private set

    var wishlistItems by mutableStateOf<List<WishlistItem>>(emptyList())
        private set

    var customModules by mutableStateOf<List<CustomModule>>(emptyList())
        private set

    init {
        loadAll()
    }

    // MARK: - Language
    fun setAppLanguage(lang: AppLanguage) {
        language = lang
        prefs.edit().putString("app_lang", lang.code).apply()
    }

    // MARK: - Persistence
    private fun loadAll() {
        val langCode = prefs.getString("app_lang", "zh") ?: "zh"
        language = if (langCode == "en") AppLanguage.ENGLISH else AppLanguage.CHINESE

        val todosJson = prefs.getString("todos", null)
        todos = if (todosJson != null) try { json.decodeFromString(todosJson) } catch (e: Exception) { emptyList() } else emptyList()

        val notesJson = prefs.getString("notes", null)
        stickyNotes = if (notesJson != null) try { json.decodeFromString(notesJson) } catch (e: Exception) { emptyList() } else emptyList()

        val vaultJson = prefs.getString("vault", null)
        vaultItems = if (vaultJson != null) try { json.decodeFromString(vaultJson) } catch (e: Exception) { emptyList() } else emptyList()

        val groceryJson = prefs.getString("grocery", null)
        groceryItems = if (groceryJson != null) try { json.decodeFromString(groceryJson) } catch (e: Exception) { emptyList() } else emptyList()

        val freqJson = prefs.getString("frequent_grocery", null)
        frequentGroceryList = if (freqJson != null) try { json.decodeFromString(freqJson) } catch (e: Exception) { emptyList() } else emptyList()

        val wishlistJson = prefs.getString("wishlist", null)
        wishlistItems = if (wishlistJson != null) try { json.decodeFromString(wishlistJson) } catch (e: Exception) { emptyList() } else emptyList()

        val customJson = prefs.getString("custom_modules", null)
        customModules = if (customJson != null) try { json.decodeFromString(customJson) } catch (e: Exception) { emptyList() } else emptyList()

        if (todos.isEmpty() && stickyNotes.isEmpty() && vaultItems.isEmpty() && groceryItems.isEmpty() && wishlistItems.isEmpty() && customModules.isEmpty()) {
            seedSampleData()
        }
    }

    private fun saveTodos() = prefs.edit().putString("todos", json.encodeToString(todos)).apply()
    private fun saveNotes() = prefs.edit().putString("notes", json.encodeToString(stickyNotes)).apply()
    private fun saveVault() = prefs.edit().putString("vault", json.encodeToString(vaultItems)).apply()
    private fun saveGrocery() = prefs.edit().putString("grocery", json.encodeToString(groceryItems)).apply()
    private fun saveFrequentGrocery() = prefs.edit().putString("frequent_grocery", json.encodeToString(frequentGroceryList)).apply()
    private fun saveWishlist() = prefs.edit().putString("wishlist", json.encodeToString(wishlistItems)).apply()
    private fun saveCustomModules() = prefs.edit().putString("custom_modules", json.encodeToString(customModules)).apply()

    // MARK: - Todos
    fun addTodo(item: TodoItem) {
        todos = listOf(item) + todos
        saveTodos()
    }
    fun toggleTodo(id: String) {
        todos = todos.map { if (it.id == id) it.copy(isCompleted = !it.isCompleted) else it }
        saveTodos()
    }
    fun updateTodo(item: TodoItem) {
        todos = todos.map { if (it.id == item.id) item else it }
        saveTodos()
    }
    fun deleteTodo(id: String) {
        todos = todos.filter { it.id != id }
        saveTodos()
    }

    // MARK: - Sticky Notes (Drops)
    fun addStickyNote(note: StickyNoteItem) {
        stickyNotes = listOf(note) + stickyNotes
        saveNotes()
    }
    fun updateStickyNote(note: StickyNoteItem) {
        stickyNotes = stickyNotes.map { if (it.id == note.id) note else it }
        saveNotes()
    }
    fun deleteStickyNote(id: String) {
        stickyNotes = stickyNotes.filter { it.id != id }
        saveNotes()
    }

    // MARK: - Vault
    fun addVaultItem(item: VaultItem) {
        vaultItems = listOf(item) + vaultItems
        saveVault()
    }
    fun updateVaultItem(item: VaultItem) {
        vaultItems = vaultItems.map { if (it.id == item.id) item else it }
        saveVault()
    }
    fun toggleVaultMask(id: String) {
        vaultItems = vaultItems.map { if (it.id == id) it.copy(isMasked = !it.isMasked) else it }
        saveVault()
    }
    fun deleteVaultItem(id: String) {
        vaultItems = vaultItems.filter { it.id != id }
        saveVault()
    }

    // MARK: - Grocery
    fun addGroceryItem(item: GroceryItem) {
        groceryItems = groceryItems + item
        saveGrocery()
    }
    fun toggleGrocery(id: String) {
        groceryItems = groceryItems.map { if (it.id == id) it.copy(isBought = !it.isBought) else it }
        saveGrocery()
    }
    fun updateGroceryItem(item: GroceryItem) {
        groceryItems = groceryItems.map { if (it.id == item.id) item else it }
        saveGrocery()
    }
    fun deleteGroceryItem(id: String) {
        groceryItems = groceryItems.filter { it.id != id }
        saveGrocery()
    }
    fun clearBoughtGrocery() {
        groceryItems = groceryItems.filter { !it.isBought }
        saveGrocery()
    }
    fun addFrequentGrocery(item: GroceryItem) {
        if (frequentGroceryList.none { it.name.equals(item.name, ignoreCase = true) }) {
            frequentGroceryList = listOf(item) + frequentGroceryList
            saveFrequentGrocery()
        }
    }
    fun removeFrequentGrocery(id: String) {
        frequentGroceryList = frequentGroceryList.filter { it.id != id }
        saveFrequentGrocery()
    }
    fun clearAllFrequentGrocery() {
        frequentGroceryList = emptyList()
        saveFrequentGrocery()
    }

    // MARK: - Wishlist
    fun addWishlistItem(item: WishlistItem) {
        wishlistItems = listOf(item) + wishlistItems
        saveWishlist()
    }
    fun updateWishlistItem(item: WishlistItem) {
        wishlistItems = wishlistItems.map { if (it.id == item.id) item else it }
        saveWishlist()
    }
    fun toggleWishlistPurchased(id: String) {
        wishlistItems = wishlistItems.map { if (it.id == id) it.copy(isPurchased = !it.isPurchased, isAbandoned = false) else it }
        saveWishlist()
    }
    fun abandonWishlistItem(id: String) {
        wishlistItems = wishlistItems.map { if (it.id == id) it.copy(isAbandoned = true, isPurchased = false) else it }
        saveWishlist()
    }
    fun restoreWishlistItem(id: String) {
        wishlistItems = wishlistItems.map { if (it.id == id) it.copy(isAbandoned = false, isPurchased = false) else it }
        saveWishlist()
    }
    fun deleteWishlistItem(id: String) {
        wishlistItems = wishlistItems.filter { it.id != id }
        saveWishlist()
    }

    // MARK: - Custom Habits
    fun toggleHabitEntry(moduleId: String, entryId: String) {
        customModules = customModules.map { mod ->
            if (mod.id == moduleId) {
                val updatedEntries = mod.entries.map { entry ->
                    if (entry.id == entryId) {
                        val newCompleted = !entry.isCompleted
                        val newStreak = if (newCompleted) entry.streakDays + 1 else (entry.streakDays - 1).coerceAtLeast(0)
                        entry.copy(isCompleted = newCompleted, streakDays = newStreak)
                    } else entry
                }
                mod.copy(entries = updatedEntries)
            } else mod
        }
        saveCustomModules()
    }
    fun addHabitEntry(moduleId: String, entry: CustomEntryItem) {
        customModules = customModules.map { mod ->
            if (mod.id == moduleId) mod.copy(entries = mod.entries + entry) else mod
        }
        saveCustomModules()
    }
    fun updateHabitEntry(moduleId: String, entry: CustomEntryItem) {
        customModules = customModules.map { mod ->
            if (mod.id == moduleId) {
                mod.copy(entries = mod.entries.map { if (it.id == entry.id) entry else it })
            } else mod
        }
        saveCustomModules()
    }
    fun deleteHabitEntry(moduleId: String, entryId: String) {
        customModules = customModules.map { mod ->
            if (mod.id == moduleId) {
                mod.copy(entries = mod.entries.filter { it.id != entryId })
            } else mod
        }
        saveCustomModules()
    }
    fun updateHabitModule(module: CustomModule) {
        customModules = customModules.map { if (it.id == module.id) module else it }
        saveCustomModules()
    }

    // MARK: - Sample Data & Reset
    fun seedSampleData() {
        todos = listOf(
            TodoItem(title = "出门关掉厨房燃气与电源", priority = TodoPriority.URGENT, reminderMinutes = 15),
            TodoItem(title = "去菜鸟驿站取快件包裹", priority = TodoPriority.NORMAL, reminderMinutes = 30),
            TodoItem(title = "整理周末徒步装备清单", priority = TodoPriority.SOMEDAY)
        )
        stickyNotes = listOf(
            StickyNoteItem(content = "今天晚霞特别美，像打翻了粉橙色的气泡水 🌇", moodEmoji = "✨", colorHex = "#FFF7D1"),
            StickyNoteItem(content = "想法：做一个极简的双语个人第二大脑，清空所有脑雾与琐事 💡", moodEmoji = "💡", colorHex = "#E8F5E9")
        )
        vaultItems = listOf(
            VaultItem(title = "门禁与入户密码", accountOrKey = "入户大门", secretValue = "9527#"),
            VaultItem(title = "家庭 Wi-Fi 口令", accountOrKey = "5G-Home-Ultra", secretValue = "SuperBrain2026!")
        )
        groceryItems = listOf(
            GroceryItem(name = "羽衣甘蓝 & 罗马生菜", aisle = GroceryAisle.PRODUCE),
            GroceryItem(name = "高钙燕麦奶 1L", aisle = GroceryAisle.DAIRY),
            GroceryItem(name = "原切牛眼肉牛排", aisle = GroceryAisle.MEAT)
        )
        frequentGroceryList = listOf(
            GroceryItem(name = "无抗鲜鸡蛋 10枚", aisle = GroceryAisle.PRODUCE, isFrequent = true),
            GroceryItem(name = "零卡气泡苏打水", aisle = GroceryAisle.SNACKS, isFrequent = true)
        )
        wishlistItems = listOf(
            WishlistItem(
                title = "降噪头戴式无线耳机",
                targetPrice = 2299.0,
                currency = "¥",
                coolOffDaysTotal = 14,
                coolOffStartDate = System.currentTimeMillis() - (1000L * 60 * 60 * 24 * 3),
                notes = "等大促降价，先冷静两周看是否真需降噪"
            ),
            WishlistItem(
                title = "人体工学电脑升降桌",
                targetPrice = 1699.0,
                currency = "¥",
                coolOffDaysTotal = 30,
                coolOffStartDate = System.currentTimeMillis() - (1000L * 60 * 60 * 24 * 12),
                notes = "缓解颈椎酸痛"
            )
        )
        customModules = listOf(
            CustomModule(
                id = "habit_module",
                title = "打卡",
                subtitle = "坚持微小日常，日积月累 ✨",
                icon = "target",
                themeColorHex = "#4D88FF",
                entries = listOf(
                    CustomEntryItem(icon = "🏃", title = "晨跑锻炼", detail = "有氧 20 分钟", streakDays = 7, isCompleted = true),
                    CustomEntryItem(icon = "💧", title = "多喝水", detail = "每天 8 杯温水", streakDays = 12, isCompleted = true),
                    CustomEntryItem(icon = "📖", title = "每日阅读", detail = "读 10 页好书", streakDays = 5, isCompleted = false)
                )
            )
        )

        saveTodos()
        saveNotes()
        saveVault()
        saveGrocery()
        saveFrequentGrocery()
        saveWishlist()
        saveCustomModules()
    }

    fun clearAllData() {
        todos = emptyList()
        stickyNotes = emptyList()
        vaultItems = emptyList()
        groceryItems = emptyList()
        frequentGroceryList = emptyList()
        wishlistItems = emptyList()
        customModules = listOf(
            CustomModule(
                id = "habit_module",
                title = "打卡",
                subtitle = "坚持微小日常，日积月累 ✨",
                icon = "target",
                themeColorHex = "#4D88FF",
                entries = emptyList()
            )
        )

        saveTodos()
        saveNotes()
        saveVault()
        saveGrocery()
        saveFrequentGrocery()
        saveWishlist()
        saveCustomModules()
    }

    companion object {
        @Volatile
        private var instance: DataStore? = null

        fun getInstance(context: Context): DataStore {
            return instance ?: synchronized(this) {
                instance ?: DataStore(context.applicationContext).also { instance = it }
            }
        }
    }
}
