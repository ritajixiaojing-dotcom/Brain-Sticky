//
//  NotificationManager.swift
//  Brain Sticky
//
//  Created for Brain Sticky - Personal Second Brain Super App.
//

import Foundation
import UserNotifications
import AudioToolbox
import UIKit

public final class NotificationManager: NSObject, UNUserNotificationCenterDelegate {
    public static let shared = NotificationManager()
    
    private override init() {
        super.init()
        UNUserNotificationCenter.current().delegate = self
    }
    
    /// 请求系统通知权限 (横幅 + 声音 + 角标)
    public func requestAuthorization() {
        UNUserNotificationCenter.current().requestAuthorization(options: [.alert, .badge, .sound]) { granted, error in
            if granted {
                print("[Brain Sticky] 🔔 Notification authorization granted.")
            } else if let error = error {
                print("[Brain Sticky] ❌ Notification error: \(error.localizedDescription)")
            }
        }
    }
    
    /// 调度待办事项定时提醒
    public func scheduleTodoReminder(item: TodoItem) {
        guard let minutes = item.reminderMinutes, minutes > 0 else { return }
        
        let content = UNMutableNotificationContent()
        content.title = "⚡ 待办提醒"
        content.body = item.title
        content.sound = .default
        content.badge = 1
        content.userInfo = ["itemId": item.id.uuidString, "type": "todo"]
        
        let seconds = TimeInterval(minutes * 60)
        let trigger = UNTimeIntervalNotificationTrigger(timeInterval: seconds, repeats: false)
        let request = UNNotificationRequest(
            identifier: "todo-\(item.id.uuidString)",
            content: content,
            trigger: trigger
        )
        
        UNUserNotificationCenter.current().add(request) { error in
            if let error = error {
                print("[Brain Sticky] ❌ Failed to schedule notification: \(error)")
            } else {
                print("[Brain Sticky] ✅ Successfully scheduled reminder in \(minutes) minutes for: \(item.title)")
            }
        }
    }
    
    /// 取消待办提醒
    public func cancelTodoReminder(id: UUID) {
        UNUserNotificationCenter.current().removePendingNotificationRequests(withIdentifiers: ["todo-\(id.uuidString)"])
        print("[Brain Sticky] 🗑️ Cancelled notification for: \(id.uuidString)")
    }
    
    /// 调度心愿冷静期到期提醒
    public func scheduleWishlistCoolOffAlert(item: WishlistItem) {
        guard item.daysRemaining > 0 && item.coolOffDaysTotal < 9999 else { return }
        
        let content = UNMutableNotificationContent()
        content.title = "🎁 剁手提醒"
        content.body = "「\(item.title)」的冷静期已结束，来看看现在是否依然想买？"
        content.sound = .default
        content.userInfo = ["itemId": item.id.uuidString, "type": "wishlist"]
        
        let seconds = TimeInterval(item.daysRemaining * 86400)
        let trigger = UNTimeIntervalNotificationTrigger(timeInterval: seconds, repeats: false)
        let request = UNNotificationRequest(
            identifier: "wishlist-\(item.id.uuidString)",
            content: content,
            trigger: trigger
        )
        
        UNUserNotificationCenter.current().add(request)
    }
    
    // MARK: - UNUserNotificationCenterDelegate (确保在前台与后台均能弹出横幅与声音、触觉震动)
    public func userNotificationCenter(
        _ center: UNUserNotificationCenter,
        willPresent notification: UNNotification,
        withCompletionHandler completionHandler: @escaping (UNNotificationPresentationOptions) -> Void
    ) {
        AudioServicesPlaySystemSound(kSystemSoundID_Vibrate)
        HapticManager.shared.notification(.warning)
        completionHandler([.banner, .sound, .badge, .list])
    }
    
    public func userNotificationCenter(
        _ center: UNUserNotificationCenter,
        didReceive response: UNNotificationResponse,
        withCompletionHandler completionHandler: @escaping () -> Void
    ) {
        AudioServicesPlaySystemSound(kSystemSoundID_Vibrate)
        completionHandler()
    }
}