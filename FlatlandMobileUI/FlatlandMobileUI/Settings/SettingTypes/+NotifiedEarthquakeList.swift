//
//  +NotifiedEarthquakeList.swift
//  +NotifiedEarthquakeList
//
//  Created by Stuart Rankin on 7/19/21. Adapted from Flatland View.
//

import Foundation
import UIKit

extension Settings
{
    // MARK: - Notified earthquake list.
    
    /// Returns all earthquakes the user has been notified about. Earthquakes older than 30 days old are
    /// discarded here and not returned.
    /// - Returns: Array of tuples of an earthquake ID and its age in reference seconds.
    public static func GetNotifiedEarthquakes() -> [(String, Double)]
    {
        let Raw = Settings.GetString(.NotifiedEarthquakes, "")
        if Raw.isEmpty
        {
            return [(String, Double)]()
        }
        let Now = Date().timeIntervalSinceReferenceDate
        let Parts = Raw.split(separator: "/", omittingEmptySubsequences: true)
        var Final = [(String, Double)]()
        for Part in Parts
        {
            let SubParts = Part.split(separator: ",", omittingEmptySubsequences: true)
            if SubParts.count != 2
            {
                continue
            }
            let ID = String(SubParts[0])
            let RawTime = String(SubParts[1])
            if let When = Double(RawTime)
            {
                let Delta = Now - When
                let Days = Delta / (24.0 * 60.0 * 60.0)
                if Days < 31.0
                {
                    Final.append((ID, When))
                }
            }
        }
        return Final
    }
    
    /// Save earthquakes the user has been notified about.
    /// - Parameter QuakeList: The list of earthquakes (tuple of USGS ID and reference seconds)) to save.
    public static func SetNotifiedEarthquakes(_ QuakeList: [(String, Double)])
    {
        var Final = ""
        for (ID, When) in QuakeList
        {
            let Quake = "\(ID)/\(When),"
            Final.append(Quake)
        }
        UserDefaults.standard.set(Final, forKey: SettingKeys.NotifiedEarthquakes.rawValue)
    }
}
