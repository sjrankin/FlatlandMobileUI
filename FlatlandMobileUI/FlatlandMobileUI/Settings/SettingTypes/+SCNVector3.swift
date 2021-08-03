//
//  +SCNVector3.swift
//  +SCNVector3
//
//  Created by Stuart Rankin on 7/19/21. Adapted from Flatland View.
//

import Foundation
import UIKit
import SceneKit

extension Settings
{
    // MARK: - SCNVector3 settings.
    
    /// Get a stored `SCNVector3` value from settings.
    /// - Note: If the specified setting does not exist or returns an error when it is parsed, the default
    ///         value will be stored in its place and returned.
    /// - Parameter Setting: The setting key where the vector lives in the setting.
    /// - Parameter Default: The default value returned if there is no valid value currently stored in
    ///                      the settings. Standard default value is (0.0, 0.0, 0.0).
    /// - Returns: Populated `SCNVector3` value from user settings. If not available, the value of `Default`
    ///            is returned.
    public static func GetVector(_ Setting: SettingKeys, _ Default: SCNVector3 = SCNVector3(0.0, 0.0, 0.0)) -> SCNVector3
    {
        guard TypeIsValid(Setting, Type: SCNVector3.self) else
        {
            Debug.FatalError("\(Setting) is not SCNVector3")
        }
        if let Raw = UserDefaults.standard.string(forKey: Setting.rawValue)
        {
            if let StoredVector = SCNVector3.Deserialize(Raw)
            {
                return StoredVector
            }
        }
        let Serialized = SCNVector3.Serialize(Default)
        UserDefaults.standard.setValue(Serialized, forKey: Setting.rawValue)
        return Default
    }
    
    /// Saves the passed `SCNVector3` value in user settings.
    /// - Parameter Setting: The setting key where to store the value.
    /// - Parameter NewValue: The value to store.
    public static func SetVector(_ Setting: SettingKeys, _ NewValue: SCNVector3)
    {
        guard TypeIsValid(Setting, Type: SCNVector3.self) else
        {
            Debug.FatalError("\(Setting) is not SCNVector3")
        }
        let Serialized = SCNVector3.Serialize(NewValue)
        UserDefaults.standard.setValue(Serialized, forKey: Setting.rawValue)
        NotifySubscribers(Setting: Setting, OldValue: nil, NewValue: NewValue as Any)
    }
}
