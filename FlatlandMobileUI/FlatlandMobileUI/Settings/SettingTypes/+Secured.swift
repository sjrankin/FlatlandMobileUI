//
//  +Secured.swift
//  +Secured
//
//  Created by Stuart Rankin on 7/19/21.
//

import Foundation
import UIKit

/// Settings that live in the keychain. All settings are expected to be strings and converted as appropriate
/// by the caller.
extension Settings
{
    // MARK: - Storage and retrieval
    /// Get a string that lives in the keychain.
    /// - Parameter Setting: The setting key whose value will be returned.
    /// - Returns: The string in the keychain on success, nil if not found or not a string.
    public static func GetSecureString(_ Setting: SettingKeys) -> String?
    {
        #if true
        return GetString(Setting)
        #else
        if let Raw = SecureStore.GetFromStore(Key: Setting.rawValue)
        {
            if let Actual = String(data: Raw, encoding: .utf8)
            {
                return Actual
            }
            else
            {
                Debug.Print("Secure string for \(Setting.rawValue) not readable.")
                return nil
            }
        }
        else
        {
            Debug.Print("Secure string for \(Setting.rawValue) not available.")
            return nil
        }
        #endif
    }
    
    /// Set the passed value to the setting key.
    /// - Parameter Setting: The setting key where to save the passed string in the keychain.
    /// - Parameter Value: The value to save in the keychain.
    /// - Returns: True on success, false on failure.
    @discardableResult public static func SetSecureString(_ Setting: SettingKeys, _ Value: String) -> Bool
    {
        #if true
        SetString(Setting, Value)
        return true
        #else
        let ValueToWrite = Value.data(using: .utf8)
        let StoreResult = SecureStore.SaveInStore(Key: Setting.rawValue, Value: ValueToWrite!)
        if StoreResult == noErr
        {
            return true
        }
        Debug.Print("SaveInStore returned error code \(StoreResult)")
        return false
        #endif
    }
    
    // MARK: - Specialized
    
    /// Determines if the user has set a home location.
    /// - Note: This function only checks to see if there are entries at the `.UserHomeLongitude` and
    ///         `.UserHomeLatitude` - no check is made with respect to the contents.
    /// - Returns: True if the user has set a home location, false if not.
    public static func HomeLocationSet() -> Bool
    {
        #if true
        if let _ = GetString(.UserHomeLatitude)
        {
            if let _ = GetString(.UserHomeLongitude)
            {
                return true
            }
        }
        #else
        if let _ = GetSecureString(.UserHomeLongitude)
        {
            if let _ = GetSecureString(.UserHomeLatitude)
            {
                return true
            }
        }
        #endif
        return false
    }
}
