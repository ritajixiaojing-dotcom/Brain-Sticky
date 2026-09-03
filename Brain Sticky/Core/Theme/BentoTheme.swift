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
            .scrollDismissesKeyboard(.interactively)
    }
}

// MARK: - Haptic Tactile Engine
public final class HapticManager {
    public static let shared = HapticManager()
    private init() {}
    
    private var isEnabled: Bool {
        if UserDefaults.standard.object(forKey: "enableHaptics") == nil {
            return true
        }
        return UserDefaults.standard.bool(forKey: "enableHaptics")
    }
    
    public func impact(_ style: UIImpactFeedbackGenerator.FeedbackStyle = .medium) {
        guard isEnabled else { return }
        let generator = UIImpactFeedbackGenerator(style: style)
        generator.prepare()
        generator.impactOccurred()
    }
    
    public func notification(_ type: UINotificationFeedbackGenerator.FeedbackType) {
        guard isEnabled else { return }
        let generator = UINotificationFeedbackGenerator()
        generator.prepare()
        generator.notificationOccurred(type)
    }
    
    public func selection() {
        guard isEnabled else { return }
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
                    strokeColor: Color(red: 120/255, green: 112/255, blue: 135/255),
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
        strokeColor: Color = Color(red: 120/255, green: 112/255, blue: 135/255), // 柔和高级灰
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

// MARK: - 原生分享与剪贴板管理器 (全面兼容微信 WeChat、WhatsApp、备忘录等)
public final class ShareManager {
    public static let shared = ShareManager()
    private init() {}
    
    /// 生成精美图文分享卡片（支持微信、朋友圈、相册等无缝接收）
    public static func generateCardImage(text: String, title: String = "脑雾收集站 · 便签") -> UIImage {
        let width: CGFloat = 380
        let padding: CGFloat = 24
        let contentWidth = width - padding * 2
        
        let titleFont = UIFont.systemFont(ofSize: 15, weight: .bold)
        let bodyFont = UIFont.systemFont(ofSize: 15, weight: .regular)
        let footerFont = UIFont.systemFont(ofSize: 12, weight: .medium)
        
        let titleAttrs: [NSAttributedString.Key: Any] = [
            .font: titleFont,
            .foregroundColor: UIColor(red: 60/255, green: 60/255, blue: 70/255, alpha: 1.0)
        ]
        
        let paragraphStyle = NSMutableParagraphStyle()
        paragraphStyle.lineSpacing = 6
        let bodyAttrs: [NSAttributedString.Key: Any] = [
            .font: bodyFont,
            .foregroundColor: UIColor(red: 30/255, green: 30/255, blue: 40/255, alpha: 1.0),
            .paragraphStyle: paragraphStyle
        ]
        
        let footerAttrs: [NSAttributedString.Key: Any] = [
            .font: footerFont,
            .foregroundColor: UIColor(red: 140/255, green: 140/255, blue: 155/255, alpha: 1.0)
        ]
        
        let bodyHeight = (text as NSString).boundingRect(
            with: CGSize(width: contentWidth, height: .greatestFiniteMagnitude),
            options: [.usesLineFragmentOrigin, .usesFontLeading],
            attributes: bodyAttrs,
            context: nil
        ).height
        
        let height: CGFloat = max(180, padding + 26 + 16 + bodyHeight + 20 + 20 + padding)
        let format = UIGraphicsImageRendererFormat()
        format.scale = 3.0 // Retina 高清输出
        
        let renderer = UIGraphicsImageRenderer(size: CGSize(width: width, height: height), format: format)
        return renderer.image { _ in
            let rect = CGRect(origin: .zero, size: CGSize(width: width, height: height))
            
            // 温暖质感圆角底卡
            let bgPath = UIBezierPath(roundedRect: rect, cornerRadius: 24)
            UIColor(red: 254/255, green: 253/255, blue: 250/255, alpha: 1.0).setFill()
            bgPath.fill()
            
            // 细致微描边
            let borderPath = UIBezierPath(roundedRect: rect.insetBy(dx: 1, dy: 1), cornerRadius: 23)
            UIColor(red: 230/255, green: 226/255, blue: 218/255, alpha: 0.8).setStroke()
            borderPath.lineWidth = 1.2
            borderPath.stroke()
            
            // 顶部小标
            let headerRect = CGRect(x: padding, y: padding, width: contentWidth, height: 22)
            (title as NSString).draw(in: headerRect, withAttributes: titleAttrs)
            
            // 正文内容
            let bodyRect = CGRect(x: padding, y: padding + 32, width: contentWidth, height: bodyHeight + 8)
            (text as NSString).draw(in: bodyRect, withAttributes: bodyAttrs)
            
            // 分隔线
            let dividerY = height - padding - 22
            let dividerPath = UIBezierPath()
            dividerPath.move(to: CGPoint(x: padding, y: dividerY))
            dividerPath.addLine(to: CGPoint(x: width - padding, y: dividerY))
            UIColor(red: 225/255, green: 222/255, blue: 215/255, alpha: 0.6).setStroke()
            dividerPath.lineWidth = 0.8
            dividerPath.stroke()
            
            // 底部外脑署名
            let footerText = "💡 脑雾收集站 (Brain Sticky) · 你的贴身外脑"
            let footerRect = CGRect(x: padding, y: height - padding - 16, width: contentWidth, height: 18)
            (footerText as NSString).draw(in: footerRect, withAttributes: footerAttrs)
        }
    }
    
    /// 触发一键直达微信分享：毫秒级复制文本到剪贴板，并一键直接跳转打开微信，聊天框长按即可粘贴发出
    public static func shareText(_ text: String, title: String = "脑雾收集站") {
        // 1. 毫秒级自动复制到系统剪贴板
        UIPasteboard.general.string = text
        HapticManager.shared.notification(.success)
        
        let wechatURL = URL(string: "weixin://")
        if let url = wechatURL, UIApplication.shared.canOpenURL(url) {
            // 2. 检测到微信：一键直接跳转打开微信！
            UIApplication.shared.open(url, options: [:], completionHandler: nil)
        } else {
            // 3. 未安装微信（如模拟器或未装微信）时：降级唤起系统原生分享面板
            guard let windowScene = UIApplication.shared.connectedScenes.first(where: { $0.activationState == .foregroundActive }) as? UIWindowScene ?? UIApplication.shared.connectedScenes.first as? UIWindowScene,
                  let rootVC = windowScene.windows.first(where: { $0.isKeyWindow })?.rootViewController else { return }
            
            var topController = rootVC
            while let presented = topController.presentedViewController {
                topController = presented
            }
            
            let cardImage = generateCardImage(text: text, title: title)
            let activityVC = UIActivityViewController(activityItems: [text, cardImage], applicationActivities: nil)
            if let popover = activityVC.popoverPresentationController {
                popover.sourceView = topController.view
                popover.sourceRect = CGRect(x: topController.view.bounds.midX, y: topController.view.bounds.midY, width: 0, height: 0)
                popover.permittedArrowDirections = []
            }
            topController.present(activityVC, animated: true)
        }
    }
    
    /// 复制到剪贴板，提供触感反馈
    public static func copyToClipboard(_ text: String) {
        UIPasteboard.general.string = text
        HapticManager.shared.notification(.success)
    }
}