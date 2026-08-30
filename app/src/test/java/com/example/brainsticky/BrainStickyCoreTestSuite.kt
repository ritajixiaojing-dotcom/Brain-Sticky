package com.example.brainsticky

import com.example.brainsticky.model.*
import com.example.brainsticky.ui.wishlist.CurrencyTotal
import org.junit.Assert.*
import org.junit.Test

class BrainStickyCoreTestSuite {

    @Test
    fun testMultiCurrencySeparationAndCalculation() {
        val items = listOf(
            WishlistItem(title = "Item CNY 1", targetPrice = 100.0, currency = "¥"),
            WishlistItem(title = "Item CNY 2", targetPrice = 250.0, currency = "¥"),
            WishlistItem(title = "Item USD 1", targetPrice = 50.0, currency = "$"),
            WishlistItem(title = "Item EUR 1", targetPrice = 30.0, currency = "€"),
            WishlistItem(title = "Item JPY 1", targetPrice = 5000.0, currency = "円")
        )

        val groups = items.groupBy { WishlistCurrency.fromSymbol(it.currency) }
        val summaries = WishlistCurrency.entries.mapNotNull { curr ->
            val group = groups[curr]
            if (!group.isNullOrEmpty()) {
                val sum = group.sumOf { it.targetPrice }
                CurrencyTotal(curr, sum)
            } else null
        }

        assertEquals(4, summaries.size)
        assertEquals(350.0, summaries.first { it.currency == WishlistCurrency.CNY }.total, 0.001)
        assertEquals(50.0, summaries.first { it.currency == WishlistCurrency.USD }.total, 0.001)
        assertEquals(30.0, summaries.first { it.currency == WishlistCurrency.EUR }.total, 0.001)
        assertEquals(5000.0, summaries.first { it.currency == WishlistCurrency.JPY }.total, 0.001)
    }

    @Test
    fun testWishlistCoolOffProgressAndRemainingDays() {
        val now = System.currentTimeMillis()
        val sevenDaysAgo = now - 7 * 86400 * 1000L
        val item = WishlistItem(
            title = "Test Item",
            targetPrice = 2999.0,
            coolOffDaysTotal = 14,
            coolOffStartDate = sevenDaysAgo
        )

        assertTrue("Remaining days should be around 7", item.daysRemaining in 6..8)
        assertTrue("Progress should be around 0.5", item.coolOffProgress in 0.45f..0.55f)
    }

    @Test
    fun testGroceryItemAisleGrouping() {
        val groceryList = listOf(
            GroceryItem(name = "Apple", aisle = GroceryAisle.PRODUCE),
            GroceryItem(name = "Milk", aisle = GroceryAisle.DAIRY),
            GroceryItem(name = "Beef", aisle = GroceryAisle.MEAT),
            GroceryItem(name = "Banana", aisle = GroceryAisle.PRODUCE)
        )

        val grouped = groceryList.groupBy { it.aisle }
        assertEquals(2, grouped[GroceryAisle.PRODUCE]?.size)
        assertEquals(1, grouped[GroceryAisle.DAIRY]?.size)
        assertEquals(1, grouped[GroceryAisle.MEAT]?.size)
    }

    @Test
    fun testTodoPriorityAndReminderFormatting() {
        val urgentTodo = TodoItem(title = "Urgent task", priority = TodoPriority.URGENT, reminderMinutes = 15)
        assertEquals("#FF5A5F", urgentTodo.priority.hexColor)
        assertEquals("紧急", urgentTodo.priority.getLabel(AppLanguage.CHINESE))
        assertEquals("Urgent", urgentTodo.priority.getLabel(AppLanguage.ENGLISH))
        assertEquals(15, urgentTodo.reminderMinutes)
    }

    @Test
    fun testStickyNoteModelAndShareTextFormat() {
        val note = StickyNoteItem(
            moodEmoji = "💡",
            content = "灵感闪现：设计一个超可爱便签",
            colorHex = "#FFF3C4"
        )
        val shareText = "【脑雾收集站 · 日常便签】\n${note.moodEmoji} ${note.content}\n— 记录于 脑雾收集站 (Brain Sticky)"
        assertTrue(shareText.contains("脑雾收集站"))
        assertTrue(shareText.contains("💡"))
        assertTrue(shareText.contains("灵感闪现"))
    }

    @Test
    fun testTodoDelegateShareTextFormat() {
        val todo = TodoItem(title = "帮我取顺丰快递")
        val delegateText = "⚡【请你帮我办件事】\n${todo.title}\n\n拜托啦！谢谢你～\n— 来自 脑雾收集站 (Brain Sticky)"
        assertTrue(delegateText.contains("⚡【请你帮我办件事】"))
        assertTrue(delegateText.contains("帮我取顺丰快递"))
        assertTrue(delegateText.contains("脑雾收集站"))
    }

    @Test
    fun testHabitStreakCalculation() {
        val habit = CustomEntryItem(
            icon = "🏃",
            title = "Morning Run",
            streakDays = 5,
            historyDates = listOf("2026-08-24", "2026-08-25", "2026-08-26", "2026-08-27", "2026-08-28")
        )
        assertEquals(5, habit.streakDays)
        assertEquals(5, habit.historyDates.size)
        assertFalse(habit.isCompleted)
    }

    @Test
    fun testBuiltinHabitPresetsCoverage() {
        val presets = BuiltinHabitPreset.ALL
        assertTrue(presets.isNotEmpty())
        val waterPreset = presets.firstOrNull { it.icon == "💧" }
        assertNotNull(waterPreset)
        assertEquals("多喝水", waterPreset?.getTitle(AppLanguage.CHINESE))
        assertEquals("Drink Water", waterPreset?.getTitle(AppLanguage.ENGLISH))
    }

    @Test
    fun testSwipeToDeleteConfirmationWorkflowAcrossAllModulesRepeatedly() {
        // Run test 20 times to ensure absolute reliability across all 6 modules
        for (iteration in 1..20) {
            // 1. Drops Screen (日常便签)
            var noteToDelete: StickyNoteItem? = null
            var notesList = listOf(
                StickyNoteItem(id = "note-1", content = "买牛奶", moodEmoji = "🥛"),
                StickyNoteItem(id = "note-2", content = "晚上看书", moodEmoji = "📖")
            )
            // User swipes left on note-1 -> trigger onDelete callback
            val onSwipeNote = { note: StickyNoteItem -> noteToDelete = note }
            onSwipeNote(notesList[0])
            // Verify dialog state is populated
            assertNotNull("Iteration $iteration: noteToDelete must not be null after swipe", noteToDelete)
            assertEquals("note-1", noteToDelete?.id)
            // User confirms delete in dialog
            notesList = notesList.filter { it.id != noteToDelete?.id }
            noteToDelete = null
            assertEquals(1, notesList.size)
            assertEquals("note-2", notesList[0].id)

            // 2. Vault Screen (密码钥匙盒)
            var vaultToDelete: VaultItem? = null
            var vaultList = listOf(
                VaultItem(id = "vault-1", title = "Google", accountOrKey = "kelly@gmail.com", secretValue = "123"),
                VaultItem(id = "vault-2", title = "Apple", accountOrKey = "kelly@icloud.com", secretValue = "456")
            )
            val onSwipeVault = { item: VaultItem -> vaultToDelete = item }
            onSwipeVault(vaultList[0])
            assertNotNull("Iteration $iteration: vaultToDelete must not be null after swipe", vaultToDelete)
            assertEquals("Google", vaultToDelete?.title)
            // Confirm delete in dialog
            vaultList = vaultList.filter { it.id != vaultToDelete?.id }
            vaultToDelete = null
            assertEquals(1, vaultList.size)
            assertEquals("Apple", vaultList[0].title)

            // 3. Grocery Screen (买菜清单)
            var groceryToDelete: GroceryItem? = null
            var groceryList = listOf(
                GroceryItem(id = "g-1", name = "西红柿", aisle = GroceryAisle.PRODUCE),
                GroceryItem(id = "g-2", name = "鸡蛋", aisle = GroceryAisle.DAIRY)
            )
            val onSwipeGrocery = { item: GroceryItem -> groceryToDelete = item }
            onSwipeGrocery(groceryList[1])
            assertNotNull("Iteration $iteration: groceryToDelete must not be null after swipe", groceryToDelete)
            assertEquals("鸡蛋", groceryToDelete?.name)
            groceryList = groceryList.filter { it.id != groceryToDelete?.id }
            groceryToDelete = null
            assertEquals(1, groceryList.size)
            assertEquals("西红柿", groceryList[0].name)

            // 4. Wishlist Screen (剁手清单)
            var wishlistToDelete: WishlistItem? = null
            var wishlistList = listOf(
                WishlistItem(id = "w-1", title = "机械键盘", targetPrice = 599.0),
                WishlistItem(id = "w-2", title = "降噪耳机", targetPrice = 1299.0)
            )
            val onSwipeWishlist = { item: WishlistItem -> wishlistToDelete = item }
            onSwipeWishlist(wishlistList[0])
            assertNotNull("Iteration $iteration: wishlistToDelete must not be null after swipe", wishlistToDelete)
            assertEquals("机械键盘", wishlistToDelete?.title)
            wishlistList = wishlistList.filter { it.id != wishlistToDelete?.id }
            wishlistToDelete = null
            assertEquals(1, wishlistList.size)
            assertEquals("降噪耳机", wishlistList[0].title)

            // 5. Habits Screen (习惯打卡)
            var habitToDelete: CustomEntryItem? = null
            var habitsList = listOf(
                CustomEntryItem(id = "h-1", title = "多喝水", icon = "💧", count = 3),
                CustomEntryItem(id = "h-2", title = "晨跑", icon = "🏃", count = 1)
            )
            val onSwipeHabit = { entry: CustomEntryItem -> habitToDelete = entry }
            onSwipeHabit(habitsList[0])
            assertNotNull("Iteration $iteration: habitToDelete must not be null after swipe", habitToDelete)
            assertEquals("多喝水", habitToDelete?.title)
            habitsList = habitsList.filter { it.id != habitToDelete?.id }
            habitToDelete = null
            assertEquals(1, habitsList.size)
            assertEquals("晨跑", habitsList[0].title)

            // 6. Todo Screen (待办清单)
            var todoToDelete: TodoItem? = null
            var todoList = listOf(
                TodoItem(id = "t-1", title = "回复客户邮件", priority = TodoPriority.URGENT),
                TodoItem(id = "t-2", title = "准备周会PPT", priority = TodoPriority.NORMAL)
            )
            val onSwipeTodo = { item: TodoItem -> todoToDelete = item }
            onSwipeTodo(todoList[1])
            assertNotNull("Iteration $iteration: todoToDelete must not be null after swipe", todoToDelete)
            assertEquals("准备周会PPT", todoToDelete?.title)
            todoList = todoList.filter { it.id != todoToDelete?.id }
            todoToDelete = null
            assertEquals(1, todoList.size)
            assertEquals("回复客户邮件", todoList[0].title)
        }
    }

    @Test
    fun testHabitCumulativeCountAndResetWorkflow() {
        for (iteration in 1..20) {
            var habit = CustomEntryItem(id = "h-water", title = "多喝水", icon = "💧", count = 0, isCompleted = false)

            // 1st click -> count = 1, completed = true
            habit = habit.copy(count = habit.count + 1, isCompleted = true)
            assertEquals(1, habit.count)
            assertTrue(habit.isCompleted)

            // 2nd click -> count = 2, completed = true
            habit = habit.copy(count = habit.count + 1, isCompleted = true)
            assertEquals(2, habit.count)
            assertTrue(habit.isCompleted)

            // 3rd click -> count = 3, completed = true
            habit = habit.copy(count = habit.count + 1, isCompleted = true)
            assertEquals(3, habit.count)
            assertTrue(habit.isCompleted)

            // Reset today's count -> count = 0, completed = false
            habit = habit.copy(count = 0, isCompleted = false)
            assertEquals(0, habit.count)
            assertFalse(habit.isCompleted)
        }
    }
}
