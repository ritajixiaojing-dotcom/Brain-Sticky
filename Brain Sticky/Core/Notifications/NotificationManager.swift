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
import Combine

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
    
    /// 触发到期震动报警（4 波连续多频段复合震动，确保用户强烈感知时间已到）
    public static func triggerAlarmVibration() {
        // 遵循用户设置中的触感和震动开关
        guard UserDefaults.standard.object(forKey: "enableHaptics") as? Bool ?? true else { return }
        guard UserDefaults.standard.object(forKey: "enableTimerVibration") as? Bool ?? true else { return }
        
        // 第 1 波 (0ms)：核心物理马达震动 + 警告触感
        AudioServicesPlaySystemSound(kSystemSoundID_Vibrate)
        let noteGen = UINotificationFeedbackGenerator()
        noteGen.prepare()
        noteGen.notificationOccurred(.warning)
        
        // 第 2 波 (300ms)：重度打击触感 + 物理马达震动
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {
            AudioServicesPlaySystemSound(kSystemSoundID_Vibrate)
            let impact = UIImpactFeedbackGenerator(style: .heavy)
            impact.prepare()
            impact.impactOccurred()
        }
        
        // 第 3 波 (650ms)：错误级强警告触感 + 物理马达震动
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.65) {
            AudioServicesPlaySystemSound(kSystemSoundID_Vibrate)
            noteGen.notificationOccurred(.error)
        }
        
        // 第 4 波 (1000ms)：重度打击收尾震动
        DispatchQueue.main.asyncAfter(deadline: .now() + 1.0) {
            AudioServicesPlaySystemSound(kSystemSoundID_Vibrate)
            let impact = UIImpactFeedbackGenerator(style: .heavy)
            impact.prepare()
            impact.impactOccurred()
        }
    }
    
    /// 调度待办事项定时提醒
    public func scheduleTodoReminder(item: TodoItem) {
        guard let minutes = item.reminderMinutes, minutes > 0 else { return }
        
        // 自动检查并请求通知权限
        UNUserNotificationCenter.current().getNotificationSettings { [weak self] settings in
            if settings.authorizationStatus == .notDetermined {
                self?.requestAuthorization()
            }
        }
        
        let content = UNMutableNotificationContent()
        content.title = "⏰ 脑雾待办提醒 · 时间到了！"
        content.body = "「\(item.title)」设定时间已到，快去完成吧～"
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
        
        // 前台专属精确计时器：若用户正打开着 App，到期时间一到立即触发强力连续震动与界面刷新
        DispatchQueue.main.asyncAfter(deadline: .now() + seconds) {
            if let currentItem = DataStore.shared.todos.first(where: { $0.id == item.id }), !currentItem.isCompleted {
                NotificationManager.triggerAlarmVibration()
                DataStore.shared.objectWillChange.send()
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
        NotificationManager.triggerAlarmVibration()
        DispatchQueue.main.async {
            DataStore.shared.objectWillChange.send()
        }
        completionHandler([.banner, .sound, .badge, .list])
    }
    
    public func userNotificationCenter(
        _ center: UNUserNotificationCenter,
        didReceive response: UNNotificationResponse,
        withCompletionHandler completionHandler: @escaping () -> Void
    ) {
        NotificationManager.triggerAlarmVibration()
        DispatchQueue.main.async {
            DataStore.shared.objectWillChange.send()
        }
        completionHandler()
    }
}