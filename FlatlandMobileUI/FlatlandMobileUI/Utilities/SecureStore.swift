//
//  SecureStore.swift
//  SecureStore
//
//  Created by Stuart Rankin on 7/20/21. Adapted from Flatland View.
//

import Foundation
import Security
import UIKit

/// Handles access to the keychain.
class SecureStore
{
    /// Save a value in the keychain.
    /// - Parameter Key: The key name for the value.
    /// - Parameter Value: The value to save.
    /// - Returns: OSStatus value.
    static func SaveInStore(Key: String, Value: Data) -> OSStatus
    {
        let Query =
        [
            kSecClass as String: kSecClassGenericPassword as String,
            kSecAttrAccount as String: Key,
            kSecValueData as String: Value
        ] as [String: Any]
        SecItemDelete(Query as CFDictionary)
        let Result = SecItemAdd(Query as CFDictionary, nil)
        return Result
    }
    
    /// Deletes the key in the secure store.
    /// - Parameter Key: The key to delete (along with it's associated value, if any).
    /// - Returns: OSStatus value.
    @discardableResult static func ClearStoreKey(Key: String) -> OSStatus
    {
        let Query =
        [
            kSecClass as String: kSecClassGenericPassword as String,
            kSecAttrAccount as String: Key,
        ] as [String: Any]
        let Result = SecItemDelete(Query as CFDictionary)
        return Result
    }
    
    /// Return data from a saved key in the keychain.
    /// - Parameter Key: The key name for the value to return.
    /// - Returns: Data associated with `Key` on success, nil on error.
    static func GetFromStore(Key: String) -> Data?
    {
        let Query =
        [
            kSecClass as String: kSecClassGenericPassword,
            kSecAttrAccount as String: Key,
            kSecReturnData as String: kCFBooleanTrue!,
            kSecMatchLimit as String: kSecMatchLimitOne
        ] as [String: Any]
        var DataTypeReference: AnyObject? = nil
        let Status: OSStatus = SecItemCopyMatching(Query as CFDictionary, &DataTypeReference)
        if Status == noErr
        {
            return DataTypeReference as! Data?
        }
        else
        {
            if let Message = SecCopyErrorMessageString(Status, nil)
            {
                Debug.Print("SecItemCopyMatching returned error for key \(Key): \(Message)")
            }
            else
            {
                Debug.Print("SecItemCopyMatching returned error code for key \(Key): \(Status)")
            }
            return nil
        }
    }
}
