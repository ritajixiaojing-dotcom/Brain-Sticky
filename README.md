# 🧠 Brain Sticky

<p align="center">
  <img src="Brain%20Sticky/Assets.xcassets/AppIcon.appiconset/AppIcon.png" width="120" height="120" style="border-radius: 28px; box-shadow: 0 8px 24px rgba(0,0,0,0.15);" alt="Brain Sticky Icon" />
</p>

<p align="center">
  <b>A Minimal, Privacy-First Personal Second Brain & Micro-Habit Super App for iOS.</b><br>
  <i>Clear brain fog, tame daily chores, prevent impulse spending, and capture fleeting thoughts with delight.</i>
</p>

<p align="center">
  <img src="https://img.shields.io/badge/iOS-17.0+-pink.svg?style=flat-square&logo=apple" alt="iOS 17+" />
  <img src="https://img.shields.io/badge/Swift-5.9-orange.svg?style=flat-square&logo=swift" alt="Swift 5.9" />
  <img src="https://img.shields.io/badge/SwiftUI-Native-blue.svg?style=flat-square" alt="SwiftUI" />
  <img src="https://img.shields.io/badge/Privacy-100%25%20Offline-green.svg?style=flat-square" alt="100% Offline" />
  <img src="https://img.shields.io/badge/Security-Face%20ID%20/%20Secure%20Enclave-purple.svg?style=flat-square" alt="Secure Enclave" />
</p>

---

## ✨ Key Features & Bento Modules

### 1. ⚡️ Todo (Quick Checklist)
- **Fast Capture**: Instant task creation with custom minute timer countdowns (5m, 15m, 30m, 60m).
- **Three-Tier Priority**: Urgent (Coral), Normal (Amber), and Someday (Electric Blue).
- **Interactive Checklist**: Dynamic strikethroughs, tactile haptic feedback, and local notification alarms.

### 2. 🫧 Drops (Moments & Sticky Notes)
- **Fluid Note Taking**: Capture sudden epiphanies, emotional snapshots, and thoughts in seconds.
- **Visual Mood Palette**: 8 pastel background tints and delightful mood emojis.
- **Masonry Layout**: Intuitive, colorful sticky-note wall with tap-to-expand details.

### 3. 🔐 Vault (Password & Secret Keeper)
- **Hardware-Level Security**: Biometric lock powered by Apple Secure Enclave (`Face ID` / `Touch ID`).
- **Zero-Cloud Privacy**: Secrets and credentials stay entirely on your device with hardware encryption.
- **Large Display Card**: One-tap full-screen zoom for quick reading of verification codes or Wi-Fi passwords.

### 4. 🥦 Market (Smart Grocery List)
- **Categorized Aisles**: Auto-grouping by aisles (Produce, Meat, Dairy, Snacks, Pantry, Daily, Other).
- **Frequent Items Drawer**: One-tap quick restock drawer for daily essentials.
- **Interactive Progress**: Real-time completion progress ring and purchase status toggles.

### 5. 🛍️ Wishlist (Cool-off & Anti-Impulse Hub)
- **Cool-off Mechanism**: Set 7, 14, 30-day, or infinite cooling periods before making a purchase.
- **Multi-Currency Support**: Real-time tracking in `¥ CNY`, `$ USD`, `円 JPY`, and `€ EUR`.
- **Mindful Spending Stats**: Live aggregation of total budget, active cooling items, and total money saved.

### 6. 🎯 Check-in & Micro-Habits
- **Customizable Daily Habits**: Built-in rich library of kawaii icons and mood-themed colors.
- **Streak & Daily Tracking**: One-tap toggle for hydration, workouts, meditation, reading, and daily goals.

### 7. 🔍 Omni Deep Search
- **Instant Global Search**: Millisecond full-text search across all 6 modules simultaneously.
- **Organized Results**: Grouped match cards highlighting relevant entries from todos, notes, secrets, grocery, and wishlist.

---

## 🔒 100% Offline & Privacy Architecture

- **Zero Cloud Tracking**: No remote servers, analytics, or third-party SDK trackers.
- **On-Device Storage**: Persistent local storage with granular JSON encryption.
- **Biometric Enclave**: Hardware-isolated biometric authentication for the password vault.

---

## 🛠️ Requirements & Tech Stack

- **Platform**: iOS 17.0+ / iPadOS 17.0+ / macOS 14.0+ (Designed for iPhone & iPad)
- **Language**: Swift 5.9+
- **Framework**: SwiftUI, Combine, LocalAuthentication, UserNotifications, WidgetKit
- **IDE**: Xcode 15.0+

---

## 🚀 Getting Started

1. Clone the repository:
   ```bash
   git clone https://github.com/ritajixiaojing-dotcom/Brain-Sticky.git
   cd Brain-Sticky
   ```

2. Open the project in Xcode:
   ```bash
   open "Brain Sticky.xcodeproj"
   ```

3. Select your target device or iOS Simulator (iPhone 15/16/17) and press **Cmd + R** to build and run!

---

## 📄 License

Distributed under the MIT License. See `LICENSE` for more information.
