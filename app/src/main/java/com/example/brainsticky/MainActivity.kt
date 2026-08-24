package com.example.brainsticky

import android.os.Bundle
import androidx.activity.ComponentActivity
import androidx.activity.compose.BackHandler
import androidx.activity.compose.setContent
import androidx.activity.enableEdgeToEdge
import androidx.compose.animation.*
import androidx.compose.foundation.layout.fillMaxSize
import androidx.compose.material3.MaterialTheme
import androidx.compose.material3.Surface
import androidx.compose.runtime.*
import androidx.compose.ui.Modifier
import com.example.brainsticky.data.DataStore
import com.example.brainsticky.theme.BrainStickyTheme
import com.example.brainsticky.ui.*
import com.example.brainsticky.ui.drops.DropsScreen
import com.example.brainsticky.ui.grocery.GroceryScreen
import com.example.brainsticky.ui.habits.HabitsScreen
import com.example.brainsticky.ui.settings.SettingsScreen
import com.example.brainsticky.ui.todo.TodoScreen
import com.example.brainsticky.ui.vault.VaultScreen
import com.example.brainsticky.ui.wishlist.WishlistScreen

class MainActivity : ComponentActivity() {
    override fun onCreate(savedInstanceState: Bundle?) {
        super.onCreate(savedInstanceState)
        enableEdgeToEdge()

        val dataStore = DataStore.getInstance(this)

        setContent {
            BrainStickyTheme {
                Surface(
                    modifier = Modifier.fillMaxSize(),
                    color = MaterialTheme.colorScheme.background
                ) {
                    var currentRoute by remember { mutableStateOf(ScreenRoute.DASHBOARD) }

                    val navigateToHome = {
                        dataStore.searchText = ""
                        currentRoute = ScreenRoute.DASHBOARD
                    }

                    // Hardware/Gesture Back Handler
                    BackHandler(enabled = currentRoute != ScreenRoute.DASHBOARD) {
                        navigateToHome()
                    }

                    AnimatedContent(
                        targetState = currentRoute,
                        transitionSpec = {
                            fadeIn() togetherWith fadeOut()
                        },
                        label = "ScreenTransition"
                    ) { route ->
                        when (route) {
                            ScreenRoute.DASHBOARD -> BentoDashboardScreen(
                                dataStore = dataStore,
                                onNavigate = { currentRoute = it }
                            )
                            ScreenRoute.TODO -> TodoScreen(
                                dataStore = dataStore,
                                onBack = navigateToHome
                            )
                            ScreenRoute.DROPS -> DropsScreen(
                                dataStore = dataStore,
                                onBack = navigateToHome
                            )
                            ScreenRoute.VAULT -> VaultScreen(
                                dataStore = dataStore,
                                onBack = navigateToHome
                            )
                            ScreenRoute.GROCERY -> GroceryScreen(
                                dataStore = dataStore,
                                onBack = navigateToHome
                            )
                            ScreenRoute.WISHLIST -> WishlistScreen(
                                dataStore = dataStore,
                                onBack = navigateToHome
                            )
                            ScreenRoute.HABITS -> HabitsScreen(
                                dataStore = dataStore,
                                onBack = navigateToHome
                            )
                            ScreenRoute.SETTINGS -> SettingsScreen(
                                dataStore = dataStore,
                                onBack = navigateToHome
                            )
                        }
                    }
                }
            }
        }
    }
}
