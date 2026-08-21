//
//  OmniClassifier.swift
//  Brain Sticky
//
//  Created for Brain Sticky - Personal Second Brain Super App.
//

import Foundation

public struct ClassificationResult {
    public let suggestedCategory: OmniCategory
    public let suggestedAisle: GroceryAisle?
    public let suggestedVaultCategory: VaultCategory?
    public let suggestedMinutes: Int?
}

public final class OmniClassifier {
    public static let shared = OmniClassifier()
    private init() {}
    
    public func classify(text: String) -> ClassificationResult {
        let lower = text.lowercased()
        
        // 1. Password / Vault keywords
        if lower.contains("密码") || lower.contains("wifi") || lower.contains("门禁") ||
           lower.contains("开门") || lower.contains("卡号") || lower.contains("账号") ||
           lower.contains("钥匙") || lower.contains("身份证") || lower.contains("验证码") {
            return ClassificationResult(
                suggestedCategory: .passwordVault,
                suggestedAisle: nil,
                suggestedVaultCategory: .custom,
                suggestedMinutes: nil
            )
        }
        
        // 2. Grocery keywords
        if lower.contains("买") || lower.contains("超市") || lower.contains("菜") ||
           lower.contains("蛋") || lower.contains("奶") || lower.contains("肉") ||
           lower.contains("水果") || lower.contains("纸") {
            var aisle: GroceryAisle = .others
            if lower.contains("菜") || lower.contains("果") || lower.contains("西红柿") { aisle = .produce }
            else if lower.contains("肉") || lower.contains("牛") || lower.contains("鸡") { aisle = .meat }
            else if lower.contains("奶") || lower.contains("面包") { aisle = .dairy }
            else if lower.contains("水") || lower.contains("可乐") || lower.contains("零食") { aisle = .snacks }
            else if lower.contains("纸") || lower.contains("洗") || lower.contains("袋") { aisle = .daily }
            
            return ClassificationResult(
                suggestedCategory: .grocery,
                suggestedAisle: aisle,
                suggestedVaultCategory: nil,
                suggestedMinutes: nil
            )
        }
        
        // 3. Wishlist keywords
        if lower.contains("想买") || lower.contains("心愿") || lower.contains("种草") ||
           lower.contains("耳机") || lower.contains("相机") || lower.contains("电脑") {
            return ClassificationResult(
                suggestedCategory: .wishlist,
                suggestedAisle: nil,
                suggestedVaultCategory: nil,
                suggestedMinutes: nil
            )
        }
        
        // 4. Todo keywords
        if lower.contains("关火") || lower.contains("快递") || lower.contains("开会") ||
           lower.contains("闹钟") || lower.contains("马上") || lower.contains("待办") {
            var mins: Int? = 15
            if lower.contains("5分") { mins = 5 }
            else if lower.contains("30分") { mins = 30 }
            else if lower.contains("60分") || lower.contains("1小时") { mins = 60 }
            
            return ClassificationResult(
                suggestedCategory: .urgentTodo,
                suggestedAisle: nil,
                suggestedVaultCategory: nil,
                suggestedMinutes: mins
            )
        }
        
        // Default: 点滴
        return ClassificationResult(
            suggestedCategory: .stickyNote,
            suggestedAisle: nil,
            suggestedVaultCategory: nil,
            suggestedMinutes: nil
        )
    }
}