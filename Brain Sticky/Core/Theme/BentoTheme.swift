//
//  BentoTheme.swift
//  Brain Sticky
//
//  Created for Brain Sticky - Personal Second Brain Super App.
//

import SwiftUI

// MARK: - Modern Airy & Pastel Color Palette
public struct BentoColors {
    // Backgrounds
    public static let bgPrimary = Color(uiColor: .systemGroupedBackground)
    public static let bgSecondary = Color(uiColor: .secondarySystemGroupedBackground)
    public static let bgCard = Color(uiColor: .tertiarySystemGroupedBackground)
    
    // Soft & Aesthetic Sticky Pastel Palette (Nordic Minimalist)
    public static let stickyYellow = Color(red: 255/255, green: 247/255, blue: 209/255) // Buttercream
    public static let stickyGreen  = Color(red: 226/255, green: 250/255, blue: 236/255) // Mint Sorbet
    public static let stickyPink   = Color(red: 255/255, green: 235/255, blue: 238/255) // Marshmallow Rose
    public static let stickyBlue   = Color(red: 230/255, green: 244/255, blue: 255/255) // Ice Cloud
    public static let stickyPurple = Color(red: 245/255, green: 238/255, blue: 255/255) // Lavender Haze
    public static let stickyOrange = Color(red: 255/255, green: 241/255, blue: 224/255) // Apricot Glow
    
    // Dynamic Accent Pops
    public static let urgentCoral  = Color(red: 255/255, green: 107/255, blue: 107/255) // Playful Coral
    public static let noteAmber    = Color(red: 245/255, green: 166/255, blue: 35/255)  // Warm Honey
    public static let vaultViolet  = Color(red: 124/255, green: 92/255, blue: 252/255)  // Iris Purple
    public static let groceryMint  = Color(red: 16/255, green: 196/255, blue: 147/255)  // Vibrant Mint
    public static let wishlistRuby = Color(red: 255/255, green: 75/255, blue: 120/255)  // Berry Red
    public static let omniElectric = Color(red: 79/255, green: 140/255, blue: 255/255) // Vivid Sky
    
    public static let allStickyHexes: [String] = [
        "#FFF7D1", "#E2FAEC", "#FFEbee", "#E6F4FF", "#F5EEFF", "#FFF1E0"
    ]
    
    public static func colorForHex(_ hex: String) -> Color {
        var cleanHex = hex.trimmingCharacters(in: .whitespacesAndNewlines).uppercased()
        if cleanHex.hasPrefix("#") {
            cleanHex.remove(at: cleanHex.startIndex)
        }
        if cleanHex.count == 6 {
            let scanner = Scanner(string: cleanHex)
            var rgbValue: UInt64 = 0
            if scanner.scanHexInt64(&rgbValue) {
                let r = Double((rgbValue & 0xFF0000) >> 16) / 255.0
                let g = Double((rgbValue & 0x00FF00) >> 8) / 255.0
                let b = Double(rgbValue & 0x0000FF) / 255.0
                return Color(red: r, green: g, blue: b)
            }
        }
        return stickyYellow
    }
}

// MARK: - Playful Bouncy Button Style
public struct BouncyButtonStyle: ButtonStyle {
    public var scale: CGFloat = 0.94
    public var opacity: CGFloat = 0.88
    
    public init(scale: CGFloat = 0.94, opacity: CGFloat = 0.88) {
        self.scale = scale
        self.opacity = opacity
    }
    
    public func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .scaleEffect(configuration.isPressed ? scale : 1.0)
            .opacity(configuration.isPressed ? opacity : 1.0)
            .animation(.spring(response: 0.3, dampingFraction: 0.65, blendDuration: 0), value: configuration.isPressed)
    }
}

public extension View {
    func bouncyTap(scale: CGFloat = 0.94) -> some View {
        self.buttonStyle(BouncyButtonStyle(scale: scale))
    }
    
    /// 点击任意空白处收起键盘
    func dismissKeyboardOnTap() -> some View {
        self.modifier(DismissKeyboardOnTap())
    }
}

// MARK: - 全局点击空白处收起键盘 (Global Dismiss Keyboard Support)
public extension UIApplication {
    func endEditing() {
        sendAction(#selector(UIResponder.resignFirstResponder), to: nil, from: nil, for: nil)
    }
}

public struct DismissKeyboardOnTap: ViewModifier {
    public func body(content: Content) -> some View {
        content
            .contentShape(Rectangle())
            .onTapGesture {
                UIApplication.shared.endEditing()
            }
    }
}

// MARK: - Haptic Tactile Engine
public final class HapticManager {
    public static let shared = HapticManager()
    private init() {}
    
    public func impact(_ style: UIImpactFeedbackGenerator.FeedbackStyle = .medium) {
        let generator = UIImpactFeedbackGenerator(style: style)
        generator.prepare()
        generator.impactOccurred()
    }
    
    public func notification(_ type: UINotificationFeedbackGenerator.FeedbackType) {
        let generator = UINotificationFeedbackGenerator()
        generator.prepare()
        generator.notificationOccurred(type)
    }
    
    public func selection() {
        let generator = UISelectionFeedbackGenerator()
        generator.prepare()
        generator.selectionChanged()
    }
}

// MARK: - 可爱治愈系梦幻微光背景 (Cute Soft Pastel Ambient Background)
public struct CuteAmbientBackground: View {
    public init() {}
    public var body: some View {
        ZStack {
            Color(red: 250/255, green: 248/255, blue: 245/255)
                .ignoresSafeArea()
            
            // 蜜桃粉光晕 (右上)
            Circle()
                .fill(Color(red: 255/255, green: 228/255, blue: 232/255).opacity(0.7))
                .frame(width: 260, height: 260)
                .blur(radius: 50)
                .offset(x: 120, y: -220)
            
            // 奶油黄光晕 (左上)
            Circle()
                .fill(Color(red: 255/255, green: 247/255, blue: 209/255).opacity(0.75))
                .frame(width: 240, height: 240)
                .blur(radius: 45)
                .offset(x: -120, y: -180)
            
            // 薰衣草紫光晕 (右下)
            Circle()
                .fill(Color(red: 242/255, green: 235/255, blue: 255/255).opacity(0.65))
                .frame(width: 280, height: 280)
                .blur(radius: 60)
                .offset(x: 110, y: 280)
            
            // 薄荷绿光晕 (左下)
            Circle()
                .fill(Color(red: 226/255, green: 250/255, blue: 238/255).opacity(0.6))
                .frame(width: 220, height: 220)
                .blur(radius: 50)
                .offset(x: -110, y: 200)
        }
        .ignoresSafeArea()
    }
}

// MARK: - Modern Squircle Bento Card Component
public struct BentoCardView<Content: View>: View {
    let title: String
    let subtitle: String?
    let icon: String
    let iconColor: Color
    let badgeCount: Int?
    let customBg: Color?
    let content: () -> Content
    
    public init(
        title: String,
        subtitle: String? = nil,
        icon: String,
        iconColor: Color,
        badgeCount: Int? = nil,
        customBg: Color? = nil,
        @ViewBuilder content: @escaping () -> Content
    ) {
        self.title = title
        self.subtitle = subtitle
        self.icon = icon
        self.iconColor = iconColor
        self.badgeCount = badgeCount
        self.customBg = customBg
        self.content = content
    }
    
    public var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            // Header
            HStack(spacing: 8) {
                Image(systemName: icon)
                    .font(.system(size: 14, weight: .bold))
                    .foregroundColor(iconColor)
                    .frame(width: 28, height: 28)
                    .background(iconColor.opacity(0.12))
                    .clipShape(RoundedRectangle(cornerRadius: 10, style: .continuous))
                
                CuteHollowTitleView(
                    text: title,
                    fontSize: 17,
                    strokeColor: Color(red: 155/255, green: 150/255, blue: 165/255),
                    strokeWidth: 1.2,
                    fillColor: Color.white
                )
                
                if let sub = subtitle {
                    Text(sub)
                        .font(.system(size: 12, weight: .medium, design: .rounded))
                        .foregroundColor(.secondary)
                }
                
                Spacer()
                
                if let count = badgeCount, count > 0 {
                    Text("\(count)")
                        .font(.system(size: 12, weight: .heavy, design: .rounded))
                        .foregroundColor(iconColor)
                        .padding(.horizontal, 8)
                        .padding(.vertical, 3)
                        .background(iconColor.opacity(0.12))
                        .clipShape(Capsule())
                }
            }
            
            // Content
            content()
                .frame(maxWidth: .infinity, alignment: .topLeading)
        }
        .padding(16)
        .frame(maxWidth: .infinity, minHeight: 152, alignment: .topLeading)
        .background(customBg ?? Color.white.opacity(0.92))
        .clipShape(RoundedRectangle(cornerRadius: 22, style: .continuous))
        .overlay(
            RoundedRectangle(cornerRadius: 22, style: .continuous)
                .stroke(Color.white.opacity(0.9), lineWidth: 1.2)
        )
        .shadow(color: Color(red: 145/255, green: 135/255, blue: 165/255).opacity(0.12), radius: 10, x: 0, y: 5)
        .shadow(color: Color.black.opacity(0.04), radius: 3, x: 0, y: 1)
    }
}

// MARK: - 可爱幼圆体空心艺术字 (Cute Rounded Hollow/Outlined Text - 极致圆润柔和灰)
public struct CuteHollowTitleView: View {
    let text: String
    var fontSize: CGFloat
    var strokeColor: Color
    var strokeWidth: CGFloat
    var fillColor: Color
    
    public init(
        text: String,
        fontSize: CGFloat = 22,
        strokeColor: Color = Color(red: 155/255, green: 150/255, blue: 165/255), // 柔和高级浅烟灰
        strokeWidth: CGFloat = 1.3,
        fillColor: Color = Color.white
    ) {
        self.text = text
        self.fontSize = fontSize
        self.strokeColor = strokeColor
        self.strokeWidth = strokeWidth
        self.fillColor = fillColor
    }
    
    // 16点环形三角函数平滑采样，消除任何方角棱角，呈现极致圆润的幼圆描边
    private var circularOffsets: [(CGFloat, CGFloat)] {
        (0..<16).map { i in
            let angle = Double(i) * (2.0 * Double.pi / 16.0)
            return (CGFloat(cos(angle)) * strokeWidth, CGFloat(sin(angle)) * strokeWidth)
        }
    }
    
    public var body: some View {
        ZStack {
            // 16点全向极度圆润描边 (柔和灰边框)
            ForEach(0..<circularOffsets.count, id: \.self) { idx in
                Text(text)
                    .font(.system(size: fontSize, weight: .black, design: .rounded))
                    .foregroundColor(strokeColor)
                    .offset(x: circularOffsets[idx].0, y: circularOffsets[idx].1)
            }
            
            // 内部纯白空心填充
            Text(text)
                .font(.system(size: fontSize, weight: .black, design: .rounded))
                .foregroundColor(fillColor)
        }
        .shadow(color: strokeColor.opacity(0.18), radius: 4, y: 2)
    }
}