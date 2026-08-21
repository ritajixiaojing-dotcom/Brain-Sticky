//
//  BiometricAuthManager.swift
//  MindOS
//
//  Created for MindOS - Personal Second Brain Super App.
//

import Foundation
import LocalAuthentication
import SwiftUI
import Combine

@MainActor
public final class BiometricAuthManager: ObservableObject {
    public static let shared = BiometricAuthManager()
    
    @Published public var isVaultUnlocked: Bool = false
    @Published public var biometricType: LABiometryType = .none
    @Published public var authErrorMessage: String? = nil
    
    private init() {
        checkBiometricAvailability()
    }
    
    public func checkBiometricAvailability() {
        let context = LAContext()
        var error: NSError?
        if context.canEvaluatePolicy(.deviceOwnerAuthenticationWithBiometrics, error: &error) {
            self.biometricType = context.biometryType
        } else if context.canEvaluatePolicy(.deviceOwnerAuthentication, error: &error) {
            self.biometricType = .none
        }
    }
    
    public var biometricName: String {
        switch biometricType {
        case .faceID: return "Face ID"
        case .touchID: return "Touch ID"
        case .opticID: return "Optic ID"
        default: return "密码解锁"
        }
    }
    
    public var biometricIcon: String {
        switch biometricType {
        case .faceID: return "faceid"
        case .touchID: return "touchid"
        case .opticID: return "eye"
        default: return "lock.fill"
        }
    }
    
    public func authenticate(reason: String = "解锁您的健忘密码保险盒", completion: ((Bool) -> Void)? = nil) {
        let context = LAContext()
        context.localizedCancelTitle = "取消"
        
        var error: NSError?
        // Fallback to device passcode if biometrics not available or failed
        let policy: LAPolicy = context.canEvaluatePolicy(.deviceOwnerAuthenticationWithBiometrics, error: &error) 
            ? .deviceOwnerAuthenticationWithBiometrics 
            : .deviceOwnerAuthentication
            
        context.evaluatePolicy(policy, localizedReason: reason) { [weak self] success, authError in
            Task { @MainActor in
                if success {
                    self?.isVaultUnlocked = true
                    self?.authErrorMessage = nil
                    HapticManager.shared.notification(.success)
                    completion?(true)
                } else {
                    self?.isVaultUnlocked = false
                    self?.authErrorMessage = authError?.localizedDescription ?? "验证未通过"
                    HapticManager.shared.notification(.error)
                    completion?(false)
                }
            }
        }
    }
    
    public func lockVault() {
        isVaultUnlocked = false
        HapticManager.shared.impact(.light)
    }
}