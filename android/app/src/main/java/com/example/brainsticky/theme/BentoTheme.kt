package com.example.brainsticky.theme

import androidx.compose.foundation.isSystemInDarkTheme
import androidx.compose.material3.MaterialTheme
import androidx.compose.material3.darkColorScheme
import androidx.compose.material3.lightColorScheme
import androidx.compose.runtime.Composable
import androidx.compose.ui.graphics.Color

object BentoColors {
    val BgPrimaryLight = Color(0xFFF7F8FA)
    val BgPrimaryDark = Color(0xFF121214)

    val BgSecondaryLight = Color(0xFFEDEFF2)
    val BgSecondaryDark = Color(0xFF1E1E22)

    val BgCardLight = Color(0xFFFFFFFF)
    val BgCardDark = Color(0xFF28282D)

    val UrgentCoral = Color(0xFFFF5A5F)
    val NoteAmber = Color(0xFFFF9F1C)
    val VaultViolet = Color(0xFF845EC2)
    val GroceryMint = Color(0xFF2EC4B6)
    val WishlistRuby = Color(0xFFFF4B6E)
    val OmniElectric = Color(0xFF4D88FF)

    val TextPrimaryLight = Color(0xFF1C1C1E)
    val TextPrimaryDark = Color(0xFFF2F2F7)

    val TextSecondaryLight = Color(0xFF8E8E93)
    val TextSecondaryDark = Color(0xFFA1A1A6)

    val AllStickyHexes = listOf(
        "#FFF7D1", // Soft yellow
        "#FFE4D6", // Soft coral/peach
        "#E8F5E9", // Soft mint
        "#E1F5FE", // Soft sky blue
        "#F3E5F5", // Soft purple
        "#FFF0F5", // Soft pink
        "#E0F2F1", // Soft teal
        "#FCE4EC"  // Rose
    )

    fun colorForHex(hex: String, defaultColor: Color = Color(0xFFFFF7D1)): Color {
        return try {
            val cleanHex = hex.removePrefix("#")
            val colorInt = if (cleanHex.length == 6) {
                ("FF$cleanHex").toLong(16)
            } else {
                cleanHex.toLong(16)
            }
            Color(colorInt)
        } catch (e: Exception) {
            defaultColor
        }
    }
}

@Composable
fun BrainStickyTheme(
    darkTheme: Boolean = isSystemInDarkTheme(),
    content: @Composable () -> Unit
) {
    val colorScheme = if (darkTheme) {
        darkColorScheme(
            primary = BentoColors.OmniElectric,
            background = BentoColors.BgPrimaryDark,
            surface = BentoColors.BgCardDark,
            onPrimary = Color.White,
            onBackground = BentoColors.TextPrimaryDark,
            onSurface = BentoColors.TextPrimaryDark
        )
    } else {
        lightColorScheme(
            primary = BentoColors.OmniElectric,
            background = BentoColors.BgPrimaryLight,
            surface = BentoColors.BgCardLight,
            onPrimary = Color.White,
            onBackground = BentoColors.TextPrimaryLight,
            onSurface = BentoColors.TextPrimaryLight
        )
    }

    MaterialTheme(
        colorScheme = colorScheme,
        content = content
    )
}
