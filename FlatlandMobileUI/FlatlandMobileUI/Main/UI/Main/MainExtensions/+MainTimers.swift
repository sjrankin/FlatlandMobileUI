//
//  +MainTimers.swift
//  Flatland
//
//  Created by Stuart Rankin on 9/18/20.
//  Copyright © 2020 - 2021 Stuart Rankin. All rights reserved.
//

import Foundation
import UIKit

extension MainController
{
    // MARK: - Main Timer
    
    /// Returns the date in UTC time zone. (Given the documentation, returning a new instance of `Date`
    /// is sufficient.)
    func GetUTC() -> Date
    {
        return Date()
    }
    
    /// Returns the local time zone abbreviation (a three-letter indicator, not a set of words).
    /// - Returns: The local time zone identifier if found, nil if not found.
    func GetLocalTimeZoneID() -> String?
    {
        let TZID = TimeZone.current.identifier
        for (Abbreviation, Wordy) in TimeZone.abbreviationDictionary
        {
            if Wordy == TZID
            {
                return Abbreviation
            }
        }
        return nil
    }
    
    #if DEBUG
    @objc func DebugTimerHandler()
    {
        let DurationValue = Utility.DurationBetween(Seconds1: CACurrentMediaTime(),
                                                    Seconds2: UptimeStart)
        //UptimeValue.stringValue = DurationValue
    }
    #endif
}
