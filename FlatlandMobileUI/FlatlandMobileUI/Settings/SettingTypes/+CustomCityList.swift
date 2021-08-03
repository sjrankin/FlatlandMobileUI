//
//  +CustomCityList.swift
//  +CustomCityList
//
//  Created by Stuart Rankin on 7/19/21.
//

import Foundation
import UIKit

extension Settings
{
    // MARK: - Custom city lists
    
    /// Returns the list of all cities in the user's custom city list.
    /// - Note: Invalid city IDs (eg, not property formed UUIDs) are ignored and not added to the returned list.
    /// - Returns: List of city IDs.
    public static func GetCustomCities() -> [UUID]
    {
        var IDList = [UUID]()
        let Raw = Settings.GetString(.CustomCityList, "")
        if Raw.isEmpty
        {
            return IDList
        }
        let Parts = Raw.split(separator: ",", omittingEmptySubsequences: true)
        for Part in Parts
        {
            let RawID = String(Part)
            if let CityID = UUID(uuidString: RawID)
            {
                IDList.append(CityID)
            }
        }
        return IDList
    }
    
    /// Save the user's custom city list.
    /// - Parameter List: The list of custom cities created by the user. Each item in the list is a valid
    ///                   city ID found in the city table.
    /// - Parameter Notify: If true, subscribers are notified of changes to the list when it is set.
    public static func SetCustomCities(_ List: [UUID], Notify: Bool = true)
    {
        var Working = ""
        for ID in List
        {
            Working.append(ID.uuidString)
            Working.append(",")
        }
        UserDefaults.standard.setValue(Working, forKey: SettingKeys.CustomCityList.rawValue)
        if Notify
        {
            NotifySubscribers(Setting: .CustomCityList, OldValue: nil, NewValue: List)
        }
    }
}
