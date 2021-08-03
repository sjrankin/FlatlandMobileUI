//
//  +POISettings.swift
//  +POISettings
//
//  Created by Stuart Rankin on 7/19/21. Adapted from Flatland View.
//

import Foundation
import UIKit

extension Settings
{
    // MARK: - Functions related to getting and setting POIs (both user and built-in).
    
    /// Get all built-in POIs.
    /// - Note: There is no corresponding SetPOIs call because built-in POIs are considered read only.
    /// - Parameter Cached: If true, cached (already read) built-in POIs are returned. If there are no cached
    ///                     POIs, the database is read and those POIs are returned.
    /// - Returns: Array of built-in POIs.
    public static func GetPOIs(Cached: Bool = false) -> [POI2]
    {
        if Cached
        {
            if DBIF.BuiltInPOIs.count > 0
            {
                return DBIF.BuiltInPOIs
            }
        }
        return DBIF.GetAllBuiltInPOIs()
    }
    
    /// Get all user POIs.
    /// - Parameter Cached: If true, cached (already read) user POIs are returned. If there are no cached
    ///                     POIs, the database is read and those POIs are returned.
    /// - Returns: Array of user POIs.
    public static func GetUserPOIs(Cached: Bool = false) -> [POI2]
    {
        if Cached
        {
            if DBIF.UserPOIs.count > 0
            {
                return DBIF.UserPOIs
            }
        }
        return DBIF.GetAllUserPOIs()
    }
    
    /// Set user-modified POIs. Only dirty POIs are updated/added.
    /// - Parameter POIs: Array of user POIs with potentially modified/new POIs to update/save.
    public static func SetUserPOIs(_ POIs: [POI2])
    {
        DBIF.SetUserPOIs(POIs)
    }
}
