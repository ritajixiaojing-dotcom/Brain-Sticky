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
        // 1. 毫秒级自动复制到系统剪贴板
        val clipboard = context.getSystemService(Context.CLIPBOARD_SERVICE) as ClipboardManager
        val clip = ClipData.newPlainText(title, text)
        clipboard.setPrimaryClip(clip)

        // 2. 检测是否安装微信 (com.tencent.mm)
        val pm = context.packageManager
        val wechatIntent = pm.getLaunchIntentForPackage("com.tencent.mm")
        if (wechatIntent != null) {
            Toast.makeText(context, "文字已自动复制，正在打开微信...", Toast.LENGTH_SHORT).show()
            try {
                context.startActivity(wechatIntent)
                return
            } catch (e: Exception) {
                // 如果直接拉起失败，平滑降级为系统分享选择器
            }
        }

        // 3. 未安装微信或直接拉起失败：降级唤起系统原生分享选择器
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
