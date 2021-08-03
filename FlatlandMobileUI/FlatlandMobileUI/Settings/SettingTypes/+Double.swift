//
//  +Double.swift
//  +Double
//
//  Created by Stuart Rankin on 7/19/21. Adapted from Flatland View.
//

import Foundation
import UIKit

extension Settings
{
    // MARK: - Double functions.
    
    /// Initialize a Double setting. Subscribers are not notified.
    /// - Parameter Setting: The setting of the double to initialize.
    /// - Parameter Value: The initial value of the setting.
    public static func InitializeDouble(_ Setting: SettingKeys, _ Value: Double)
    {
        UserDefaults.standard.set(Value, forKey: Setting.rawValue)
    }
    
    /// Initialize a Double? setting. Subscribers are not notified.
    /// - Parameter Setting: The setting of the double? to initialize.
    /// - Parameter Value: The initial value of the setting.
    public static func InitializeDoubleNil(_ Setting: SettingKeys, _ Value: Double? = nil)
    {
        guard TypeIsValid(Setting, Type: Double?.self) else
        {
            Debug.FatalError("\(Setting) is not a Double?")
        }
        if let Actual = Value
        {
            UserDefaults.standard.set(Double(Actual), forKey: Setting.rawValue)
        }
        else
        {
            UserDefaults.standard.set(nil, forKey: Setting.rawValue)
        }
    }
    
    /// Returns a double value from the specified setting.
    /// - Parameter Setting: The setting whose double value will be returned.
    /// - Returns: Double found at the specified setting.
    public static func GetDouble(_ Setting: SettingKeys) -> Double
    {
        guard TypeIsValid(Setting, Type: Double.self) else
        {
            Debug.FatalError("\(Setting) is not a Double")
        }
        return UserDefaults.standard.double(forKey: Setting.rawValue)
    }
    
    /// Returns a double value from the specified setting.
    /// - Note: If the value in the settings is `0.0`, the value in `IfZero` is written then returned.
    /// - Parameter Setting: The setting whose double value will be returned.
    /// - Parameter IfZero: Default value to return if the original value is `0.0`.
    /// - Returns: The value at the specified settings. If that value is `0.0`, the value in `IfZero` is
    ///            returned.
    public static func GetDouble(_ Setting: SettingKeys, _ IfZero: Defaults) -> Double
    {
        guard TypeIsValid(Setting, Type: Double.self) else
        {
            Debug.FatalError("\(Setting) is not a Double")
        }
        let DoubleValue = UserDefaults.standard.double(forKey: Setting.rawValue)
        if DoubleValue == 0.0
        {
            UserDefaults.standard.set(IfZero.rawValue, forKey: Setting.rawValue)
            return IfZero.rawValue
        }
        return DoubleValue
    }
    
    /// Queries a double setting value.
    /// - Parameter Setting: The setting whose double value will be passed to the completion handler.
    /// - Parameter Completion: Code to execute after the value is retrieved. The value is passed
    ///                         to the completion handler.
    public static func QueryDouble(_ Setting: SettingKeys, Completion: (Double) -> Void)
    {
        guard TypeIsValid(Setting, Type: Double.self) else
        {
            Debug.FatalError("\(Setting) is not a Double")
        }
        let DoubleValue = UserDefaults.standard.double(forKey: Setting.rawValue)
        Completion(DoubleValue)
    }
    
    /// Returns a double value from the specified setting, returning a passed value if the setting
    /// value is 0.0.
    /// - Parameter Setting: The setting whose double value will be returned.
    /// - Parameter IfZero: The value to return if the stored value is 0.0.
    /// - Returns: Double found at the specified setting, the value found in `IfZero` if the stored
    ///            value is 0.0.
    public static func GetDouble(_ Setting: SettingKeys, _ IfZero: Double = 0) -> Double
    {
        guard TypeIsValid(Setting, Type: Double.self) else
        {
            Debug.FatalError("\(Setting) is not a Double")
        }
        let Value = UserDefaults.standard.double(forKey: Setting.rawValue)
        if Value == 0.0
        {
            return IfZero
        }
        return Value
    }
    
    /// Returns a nilable double value from the specified setting.
    /// - Note: If the setting resolves down to a secure string, different handling will occur
    ///         but the returned value will follow the semantics of normal processing.
    /// - Parameter Setting: The setting whose double value will be returned.
    /// - Parameter Default: The default value to return if the stored value is nil. Not returned
    ///                      if the contents of `Default` is nil.
    /// - Returns: The value stored at the specified setting, the contents of `Double` if the stored
    ///            value is nil, nil if `Default` is nil.
    public static func GetDoubleNil(_ Setting: SettingKeys, _ Default: Double? = nil) -> Double?
    {
        /*
        if SecureStringKeyTypes.contains(Setting)
        {
            return SecureStringAsDoubleNil(Setting, Default)
        }
         */
        guard TypeIsValid(Setting, Type: Double?.self) else
        {
            Debug.FatalError("\(Setting) is not a Double?")
        }
        if let Raw = UserDefaults.standard.string(forKey: Setting.rawValue)
        {
            if let Final = Double(Raw)
            {
                return Final
            }
        }
        if let UseDefault = Default
        {
            UserDefaults.standard.set("\(UseDefault)", forKey: Setting.rawValue)
            return UseDefault
        }
        return nil
    }
    
    /// Reads a value in the secure store and attempts to return it as a double.
    /// - Note: This function is not intended to be called by user code.
    /// - Parameter Setting: The setting key.
    /// - Parameter Default: Value to return if no value is found. If this value is nil, nil is returned.
    /// - Returns: A double value based on the stored value in secure storage, nil if not found and
    ///            no default value passed.
    public static func SecureStringAsDoubleNil(_ Setting: SettingKeys, _ Default: Double? = nil) -> Double?
    {
        if let StoredValue = SecureStore.GetFromStore(Key: Setting.rawValue)
        {
            if let StoredString = String(data: StoredValue, encoding: .utf8)
            {
                if let ActualValue = Double(StoredString)
                {
                    return ActualValue
                }
            }
            return nil
        }
        else
        {
            if let DefaultValue = Default
            {
                return DefaultValue
            }
            return nil
        }
    }
    
    /// Queries a Double? setting value.
    /// - Parameter Setting: The setting whose Double? value will be passed to the completion handler.
    /// - Parameter Completion: Code to execute after the value is retrieved. The value is passed
    ///                         to the completion handler.
    public static func QueryDoubleNil(_ Setting: SettingKeys, Completion: (Double?) -> Void)
    {
        guard TypeIsValid(Setting, Type: Double?.self) else
        {
            Debug.FatalError("\(Setting) is not a Double?")
        }
        let DoubleNil = GetDoubleNil(Setting)
        Completion(DoubleNil)
    }
    
    /// Save a double value at the specified setting.
    /// - Parameter Setting: The setting where the double value will be stored.
    /// - Parameter Value: The value to save.
    public static func SetDouble(_ Setting: SettingKeys, _ Value: Double)
    {
        guard TypeIsValid(Setting, Type: Double.self) else
        {
            Debug.FatalError("\(Setting) is not a Double?")
        }
        let OldValue = UserDefaults.standard.double(forKey: Setting.rawValue)
        let NewValue = Value
        UserDefaults.standard.set(NewValue, forKey: Setting.rawValue)
        NotifySubscribers(Setting: Setting, OldValue: OldValue, NewValue: NewValue)
    }
    
    /// Save a nilable double value at the specified setting.
    /// - Note: `Double?` values are saved as strings but converted before being returned.
    /// - Parameter Setting: The setting where the double? value will be stored.
    /// - Parameter Value: The double? value to save.
    public static func SetDoubleNil(_ Setting: SettingKeys, _ Value: Double? = nil)
    {
        if SecureStringKeyTypes.contains(Setting)
        {
            SaveDoubleNilInSecureStorage(Setting, Value)
            return
        }
        guard TypeIsValid(Setting, Type: Double?.self) else
        {
            Debug.FatalError("\(Setting) is not a Double?")
        }
        let OldValue = GetDoubleNil(Setting)
        let NewValue = Value
        UserDefaults.standard.set(Value, forKey: Setting.rawValue)
        NotifySubscribers(Setting: Setting, OldValue: OldValue, NewValue: NewValue)
    }
    
    /// Save a `Double?` in secure storage as a string.
    /// - Note: Subscribers are notified of changes but the passed `OldValue` and `NewValue`s are nil.
    /// - Note: This function is not intended to be called by user code.
    /// - Parameter Setting: The setting key where to save the value.
    /// - Parameter Value: The value to store. If this value is nil, the key is erased.
    public static func SaveDoubleNilInSecureStorage(_ Setting: SettingKeys, _ Value: Double? = nil)
    {
        if Value == nil
        {
            SecureStore.ClearStoreKey(Key: Setting.rawValue)
        }
        else
        {
            let StringValue = "\(Value!)"
            SetSecureString(Setting, StringValue)
        }
        NotifySubscribers(Setting: Setting, OldValue: nil, NewValue: nil)
    }
}
