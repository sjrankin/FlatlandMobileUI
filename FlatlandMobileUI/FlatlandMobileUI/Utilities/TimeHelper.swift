//
//  TimeHelper.swift
//  TimeHelper
//
//  Created by Stuart Rankin on 7/18/21. Adapted from Flatland View.
//

import Foundation
import UIKit

/// Time and date helper functions.
public class TimeHelper
{
    /// Number of seconds in a year, disregarding leap year.
    public static let SecondsInYear = 365 * SecondsInDay
    /// Number of seconds in a day.
    public static let SecondsInDay = 24 * 60 * 60
    
    /// Return a date structure for 1 January 1900 at 00:00.
    ///
    /// - Returns: Date structure for epoch 1900.
    public static func Epoch() -> Date
    {
        return MakeYear(1900)
    }
    
    /// Return a date structure with the given date. Time is set to midnight.
    ///
    /// - Parameters:
    ///   - Year: The year of the date.
    ///   - Month: The month of the date.
    ///   - Day: The day of the date.
    /// - Returns: Date structure with the specified date, set to midnight.
    public static func MakeYear(_ Year: Int, Month: Int = 1, Day: Int = 1) -> Date
    {
        var Comp = DateComponents()
        Comp.year = Year
        Comp.month = Month
        Comp.day = Day
        Comp.hour = 0
        Comp.minute = 0
        Comp.second = 0
        let Cal = Calendar.current
        return Cal.date(from: Comp)!
    }
    
    /// Create a new date based on an old date.
    ///
    /// - Parameters:
    ///   - Base: Date/time the new date will be based on.
    ///   - Year: Optional new year.
    ///   - Month: Optional new month.
    ///   - Day: Optional new day.
    ///   - Hour: Optional new hour.
    ///   - Minute: Optional new minute.
    ///   - Second: Optional new second.
    /// - Returns: New date based on parameters.
    public static func EditDate(_ Base: Date, Year: Int? = nil, Month: Int? = nil, Day: Int? = nil, Hour: Int? = nil, Minute: Int? = nil, Second: Int? = nil) -> Date
    {
        let Cal = Calendar.current
        let OriginalYear = Cal.component(.year, from: Base)
        let OriginalMonth = Cal.component(.month, from: Base)
        let OriginalDay = Cal.component(.day, from: Base)
        let OriginalHour = Cal.component(.hour, from: Base)
        let OriginalMinute = Cal.component(.minute, from: Base)
        let OriginalSecond = Cal.component(.second, from: Base)
        var Components = DateComponents()
        Components.year = Year == nil ? OriginalYear : Year!
        Components.month = Month == nil ? OriginalMonth : Month!
        Components.day = Day == nil ? OriginalDay : Day!
        Components.hour = Hour == nil ? OriginalHour : Hour!
        Components.minute = Minute == nil ? OriginalMinute : Minute!
        Components.second = Second == nil ? OriginalSecond : Second!
        return Cal.date(from: Components)!
    }
    
    /// Returns the number of days in Year, taking into account leap years.
    ///
    /// - Parameter Year: The year whose number of days is returned.
    /// - Returns: The number of days in Year.
    public static func DaysInYear(Year: Int) -> Int
    {
        if Year % 4 != 0
        {
            return 365
        }
        if Year % 100 == 0
        {
            if Year % 400 == 0
            {
                return 366
            }
            else
            {
                return 365
            }
        }
        else
        {
            return 366
        }
    }
    
    /// Returns the number of seconds from teh beginning of the year in Now to the current time in Now. Leap year is
    /// accounted for.
    ///
    /// - Parameter Now: The time that determines the number of seconds returned.
    /// - Returns: Number of seconds since 00:00, 1 January Now.year and Now.
    public static func DateSeconds(Now: Date) -> Int
    {
        let Cal = Calendar.current
        let DayOfYear = Cal.ordinality(of: .day, in: .year, for: Now)
        let Second = Cal.component(.second, from: Now)
        let Minute = Cal.component(.minute, from: Now)
        let Hour = Cal.component(.hour, from: Now)
        //let Day = Cal.component(.day, from: Now) - 1
        let Month = Cal.component(.month, from: Now) - 1
        let Year = Cal.component(.year, from: Now)
        //print("\(Hour):\(Minute):\(Second), \(Year)-\(Month)-\(Day)")
        let IsLeapYear = DaysInYear(Year: Year) == 366
        var Total = Second
        Total = Total + (Minute * 60)
        Total = Total + (Hour * 60 * 60)
        Total = Total + ((DayOfYear! - 1) * SecondsInDay)
        if IsLeapYear
        {
            if Month > 1
            {
                Total = Total + SecondsInDay
            }
        }
        return Total
    }
    
    /// Returns the number of seconds in the year Year, taking into account leap years.
    ///
    /// - Parameter Year: The year whose quantity of seconds will be returned.
    /// - Returns: The number of seconds in Year, taking into account leap years.
    public static func SecondsInYear(Year: Int) -> Int
    {
        let Days = DaysInYear(Year: Year)
        return Days * 60 * 60 * 24
    }
    
    /// Returns the number of seconds for each whole year in the range Start...End. (Whole years are defined as those
    /// years in the middle of the range.
    ///
    /// - Parameters:
    ///   - Start: Starting year.
    ///   - End: Ending year.
    /// - Returns: Number of seconds in the range (Start + 1)...(End - 1)
    public static func SecondsInYearRange(Start: Int, End: Int) -> Int
    {
        var StartYear = Start
        var EndYear = End
        if StartYear > EndYear
        {
            let temp = StartYear
            StartYear = EndYear
            EndYear = temp
        }
        StartYear = StartYear + 1
        EndYear = EndYear - 1
        if EndYear < StartYear
        {
            return 0
        }
        var Seconds = 0
        for SomeYear in StartYear...EndYear
        {
            Seconds = Seconds + SecondsInYear(Year: SomeYear)
        }
        return Seconds
    }
    
    /// Returns the number of seconds since 00:00, 1 January 1900 and Time.
    ///
    /// - Parameter Time: The time/date that determines the number of seconds returned.
    /// - Returns: Number of seconds between 00:00, 1 January 1900 and Time.
    public static func SecondsFromEpoch(Time: Date) -> Int
    {
        return SecondsBetween(Time1: Epoch(), Time2: Time)
    }
    
    /// Returns the number of seconds between the two date/time structures.
    ///
    /// - Parameters:
    ///   - Time1: Starting time.
    ///   - Time2: Ending time.
    /// - Returns: Absolute value of the number of seconds between Time1 and Time2
    public static func SecondsBetween(Time1: Date, Time2: Date) -> Int
    {
        let Cal = Calendar.current
        let Year1 = Cal.component(.year, from: Time1)
        let Year2 = Cal.component(.year, from: Time2)
        let YearsSeconds = SecondsInYearRange(Start: Year1, End: Year2)
        if YearsSeconds == 0
        {
            let Time1Seconds = DateSeconds(Now: Time1)
            let Time2Seconds = DateSeconds(Now: Time2)
            return abs(Time1Seconds - Time2Seconds)
        }
        let StartDateSeconds = SecondsInYear - DateSeconds(Now: Time1)
        let EndDateSeconds = DateSeconds(Now: Time2)
        return abs(YearsSeconds + StartDateSeconds + EndDateSeconds)
    }
    
    /// Determines if the specified date is in the range specified.
    ///
    /// - Parameters:
    ///   - Now: The date to determine whether is in the range or not.
    ///   - Of: Start of the range.
    ///   - Duration: Duration of the range in seconds.
    /// - Returns: True if the passed date is in the range, false if not.
    public static func IsInRange(_ Now: Date, Of: Date, Duration: Int) -> Bool
    {
        if Now < Of
        {
            //Time to check is before start of range.
            return false
        }
        let Gap = SecondsBetween(Time1: Of, Time2: Now)
        if Gap > Duration
        {
            return false
        }
        else
        {
            return true
        }
    }
    
    public static func SubStringsToInts(_ SubStringArray: [Substring]) -> [Int]?
    {
        var Results = [Int]()
        
        for SomeSub in SubStringArray
        {
            if let SomeValue = Int(SomeSub)
            {
                Results.append(SomeValue)
            }
            else
            {
                return nil
            }
        }
        
        return Results
    }
    
    /// Converts a string representation of a date into a date.
    ///
    /// - Parameter Raw: The string representation of the date.
    /// - Returns: Actual date. Nil on error.
    public static func StringToDate(_ Raw: String) -> Date?
    {
        if Raw.isEmpty
        {
            return nil
        }
        let Parts = Raw.split(separator: " ")
        if Parts.count < 2
        {
            return nil
        }
        let RawDate = String(Parts[0])
        let RawTime = String(Parts[1])
        
        let DateParts = RawDate.split(separator: "-")
        if DateParts.count != 3
        {
            return nil
        }
        let DateInts = SubStringsToInts(DateParts)
        if DateInts == nil
        {
            return nil
        }
        let Year = DateInts?[0]
        let Month = DateInts?[1]
        let Day = DateInts?[2]
        
        let TimeParts = RawTime.split(separator: ":")
        if TimeParts.count != 3
        {
            return nil
        }
        let TimeInts = SubStringsToInts(TimeParts)
        if TimeInts == nil
        {
            return nil
        }
        let Hour = TimeInts?[0]
        let Minute = TimeInts?[1]
        let Second = TimeInts?[2]
        
        var Components = DateComponents()
        Components.year = Year
        Components.month = Month
        Components.day = Day
        Components.hour = Hour
        Components.minute = Minute
        Components.second = Second
        let Cal = Calendar.current
        return Cal.date(from: Components)
    }
    
    /// Returns the Hours, Minutes, and Seconds for the passed date.
    /// - Parameter RawDate: The date used to extract the time returned.
    /// - Parameter For: The time zone of the date. Defaults to "UTC".
    /// - Returns: Tuple of the hours, minutes, and seconds for the date. Nil on error.
    public static func DateToDateComponents(_ RawDate: Date, For TZ: String = "UTC") -> (Hour: Int, Minute: Int, Second: Int)?
    {
        if let TimeZ = TimeZone(abbreviation: TZ)
        {
            let Formatter = DateFormatter()
            Formatter.timeZone = TimeZ
            let UnitSeparator = ":"
            Formatter.dateFormat = "HH\(UnitSeparator)mm\(UnitSeparator)ss"
            let StringDate = Formatter.string(from: RawDate)
            let Parts = StringDate.split(separator: String.Element(UnitSeparator))
            guard Parts.count == 3 else
            {
                return nil
            }
            guard let Hours = Int(String(Parts[0])) else
            {
                return nil
            }
            guard let Minutes = Int(String(Parts[1])) else
            {
                return nil
            }
            guard let Seconds = Int(String(Parts[2])) else
            {
                return nil
            }
            return (Hours, Minutes, Seconds)
        }
        return nil
    }
    
    /// Return the passed date to seconds.
    /// - Parameter RawDate: The date to convert.
    /// - Parameter For: Time zone name. Defaults to "UTC".
    /// - Returns: Number of seconds for the date on success, nil on error.
    public static func DateToSeconds(_ RawDate: Date, For TZ: String = "UTC") -> Int?
    {
        if let (Hours, Minutes, Seconds) = DateToDateComponents(RawDate, For: TZ)
        {
            let Total = (Hours * 60 * 60) + (Minutes * 60) + Seconds
            return Total
        }
        return nil
    }
    
    /// Returns the current solar time at the specified longitude.
    /// - Note: The solar time does *not* take into account time zones so the time may be up to 59 minutes
    ///         off from the wall clock.
    /// - Parameter Longitude: The longitude of the location whose solar time will be returned.
    /// - Parameter As24Hour: If true, the returned value will be returned as a 24-hour formatted string.
    ///                       Otherwise, AM/PM indicators are added.
    /// - Returns: String value representing the date. Nil on error.
    public static func SolarTimeAt(Longitude: Double, As24Hour: Bool = true) -> String?
    {
        let DateNow = Date()
        let Hours = Longitude / 15.0
        let Seconds = Int(Hours * 60.0 * 60.0)
        if let UTCSeconds = DateToSeconds(DateNow, For: "UTC")
        {
            var FinalSeconds = abs(UTCSeconds + Seconds)
            var LocalHours = FinalSeconds / (60 * 60)
            FinalSeconds = FinalSeconds - (LocalHours * 60 * 60)
            let LocalMinutes = FinalSeconds / 60
            let LocalSeconds = FinalSeconds % 60
            var HourS = "\(LocalHours)"
            if LocalHours < 10
            {
                HourS = "0" + HourS
            }
            var MinuteS = "\(LocalMinutes)"
            if LocalMinutes < 10
            {
                MinuteS = "0" + MinuteS
            }
            var SecondS = "\(LocalSeconds)"
            if LocalSeconds < 10
            {
                SecondS = "0" + SecondS
            }
            if As24Hour
            {
                return "\(HourS):\(MinuteS):\(SecondS)"
            }
            else
            {
                var Indicator = ""
                let InAfternoon = LocalHours >= 12
                if InAfternoon
                {
                    Indicator = "PM"
                    LocalHours = 12 - LocalHours
                    HourS = "\(LocalHours)"
                }
                else
                {
                    Indicator = "AM"
                }
                return "\(HourS):\(MinuteS):\(SecondS) \(Indicator)"
            }
        }
        return nil
    }
}
