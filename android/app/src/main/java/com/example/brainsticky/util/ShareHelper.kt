package com.example.brainsticky.util

import android.content.ClipData
import android.content.ClipboardManager
import android.content.Context
import android.content.Intent
import android.widget.Toast

/**
 * 原生分享与剪贴板管理器 (全面兼容微信 WeChat、系统选择器等)
 * 支持毫秒级复制到剪贴板，并一键直接跳转打开微信，聊天框长按即可粘贴发出
 */
object ShareHelper {

    fun shareText(context: Context, text: String, title: String = "脑雾收集站") {
        // 1. 自动复制到系统剪贴板
        val clipboard = context.getSystemService(Context.CLIPBOARD_SERVICE) as ClipboardManager
        val clip = ClipData.newPlainText(title, text)
        clipboard.setPrimaryClip(clip)

        // 2. 唤起系统原生分享面板 (支持微信、短信、备忘录等任意平台)
        val sendIntent = Intent(Intent.ACTION_SEND).apply {
            type = "text/plain"
            putExtra(Intent.EXTRA_TEXT, text)
        }
        val shareChooser = Intent.createChooser(sendIntent, title)
        context.startActivity(shareChooser)
    }

    fun copyToClipboard(context: Context, text: String, label: String = "脑雾收集站") {
        val clipboard = context.getSystemService(Context.CLIPBOARD_SERVICE) as ClipboardManager
        val clip = ClipData.newPlainText(label, text)
        clipboard.setPrimaryClip(clip)
        Toast.makeText(context, "已复制到剪贴板", Toast.LENGTH_SHORT).show()
    }
}
