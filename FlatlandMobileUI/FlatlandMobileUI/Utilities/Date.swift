//
//  Date.swift
//  Date
//
//  Created by Stuart Rankin on 7/18/21. Adapted from FlatlandView.
//

import Foundation
import UIKit

// MARK: - Date extensions.

/// Date extensions.
/// - Note: See [Converting UTC date formal to local](https://stackoverflow.com/questions/29392874/converting-utc-date-format-to-local-nsdate)
extension Date
{
    /// Create a time with the given components.
    /// - Note: The date is ignored and undefined.
    /// - Parameter Hour: The hour value. Must range from 0 to 23.
    /// - Parameter Minute: The minute value. Must range from 0 to 59.
    /// - Parameter Second: The second value. Must range from 0 to 59.
    /// - Returns: Date structure with the passed time (and undefined date). Nil on error.
    public static func DateFactory(Hour: Int, Minute: Int, Second: Int) -> Date?
    {
        if Hour < 0 || Hour > 23
        {
            return nil
        }
        if Minute < 0 || Minute > 59
        {
            return nil
        }
        if Second < 0 || Second > 59
        {
            return nil
        }
        let Cal = Calendar.current
        var Components = DateComponents()
        Components.hour = Hour
        Components.minute = Minute
        Components.second = Second
        return Cal.date(from: Components)
    }
    
    /// Create a date with the given components.
    /// - Year: The year of the date.
    /// - Month: The month of the date.
    /// - Day: The day of the date.
    /// - Hour: The hour of the day.
    /// - Minute: The minute of the day.
    /// - Second: The second of the day.
    /// - TimeZoneLabel: Valid time zone identifier. If not specified, the current calendar's time
    ///                  zone is used.
    public static func DateFactory(Year: Int, Month: Int, Day: Int, Hour: Int, Minute: Int, Second: Int,
                                   TimeZoneLabel: String? = "UTC") -> Date?
    {
        if Month < 1 || Month > 12
        {
            return nil
        }
        if Day < 1
        {
            return nil
        }
        if Month == 2
        {
            if IsLeapYear(Year)
            {
                if Day > 29
                {
                    return nil
                }
            }
            else
            {
                if Day > 28
                {
                    return nil
                }
            }
        }
        if [1, 3, 5, 7, 8, 10, 12].contains(Month)
        {
            if Day > 31
            {
                return nil
            }
        }
        if Hour < 0 || Hour > 23
        {
            return nil
        }
        if Minute < 0 || Minute > 59
        {
            return nil
        }
        if Second < 0 || Second > 59
        {
            return nil
        }
        var Cal: Calendar!
        if let ZoneLabel = TimeZoneLabel
        {
            Cal = Calendar(identifier: .gregorian)
            if let TZ = TimeZone(identifier: ZoneLabel)
            {
                Cal.timeZone = TZ
            }
            else
            {
                return nil
            }
        }
        else
        {
            Cal = Calendar.current
        }
        var Components = DateComponents()
        Components.year = Year
        Components.month = Month
        Components.day = Day
        Components.hour = Hour
        Components.minute = Minute
        Components.second = Second
        return Cal.date(from: Components)
    }
    
    /// Create a date with the given components. The time is set to 00:00:00.
    /// - Year: The year of the date.
    /// - Month: The month of the date.
    /// - Day: The day of the date.
    public static func DateFactory(Year: Int, Month: Int, Day: Int) -> Date?
    {
        return Date.DateFactory(Year: Year, Month: Month, Day: Day, Hour: 0, Minute: 0, Second: 0)
    }
    
    /// Determines if a given year is a leap year.
    /// - Parameter Year: The year to determine for leap yearness.
    /// - Returns: True if the passed year is a leap year, false if not.
    public static func IsLeapYear(_ Year: Int) -> Bool
    {
        if Year % 400 == 0
        {
            return true
        }
        if Year % 100 == 0
        {
            return false
        }
        if Year % 4 == 0
        {
            return true
        }
        return false
    }
    
    /// Convert a local date to UTC.
    /// - Returns: UTC date equivalent of the instance local date.
    func ToUTC() -> Date
    {
        let TZ = TimeZone.current
        let Seconds = -TimeInterval(TZ.secondsFromGMT(for: self))
        return Date(timeInterval: Seconds, since: self)
    }
    
    /// Convert a UTC date to a local date.
    /// - Returns: Local date equivalent of the instance UTC date.
    func ToLocal() -> Date
    {
        let TZ = TimeZone.current
        let Seconds = TimeInterval(TZ.secondsFromGMT(for: self))
        return Date(timeInterval: Seconds, since: self)
    }
    
    /// Given a number of seconds, return the number of hours, minutes, and remaining seconds in
    /// the total count of seconds.
    /// - Parameter SourceSeconds: Total number of seconds.
    /// - Returns: Tuple with the number of hours, minutes, and seconds.
    static func SecondsToTime(_ SourceSeconds: Int) -> (Hour: Int, Minute: Int, Second: Int)
    {
        let Hours = SourceSeconds / (60 * 60)
        let Minutes = (SourceSeconds - (Hours * 60 * 60)) / 60
        let Seconds = SourceSeconds - ((Hours * 60 * 60) + (Minutes * 60))
        return (Hours, Minutes, Seconds)
    }
    
    /// Return a pretty-printed time string based on the number of seconds passed.
    /// - Parameter From: The number of seconds used to form a time that is the basis of the pretty-printed
    ///                   string returned.
    /// - Parameter Separator: The separator between the time parts.
    /// - Returns: Pretty-printed number of hours, minutes, and seconds.
    static func PrettyTimeParts(From TotalSeconds: Int, Separator: String = ", ") -> String
    {
        if TotalSeconds <= 0
        {
            return "0s"
        }
        let (Hour, Minute, Second) = SecondsToTime(TotalSeconds)
        var Parts = [String]()
        if Hour > 0
        {
            Parts.append("\(Hour)h")
        }
        if Minute > 0
        {
            Parts.append("\(Minute)m")
        }
        if Second > 0
        {
            Parts.append("\(Second)s")
        }
        var Result = ""
        for Index in 0 ..< Parts.count
        {
            Result.append(Parts[Index])
            if Index < Parts.count - 1
            {
                Result.append(Separator)
            }
        }
        return Result
    }
    
    /// Return a date (only the time components are valid) based on the percent of a day that
    /// has passed.
    /// - Parameter Percent: Percent of a day that has passed. Used to calculate the time.
    /// - Parameter WithOffset: Offset value.
    /// - Returns: Date structure with only the time components being valid.
    static func DateFrom(Percent: Double, WithOffset: Int = 0) -> Date
    {
        var Components = DateComponents()
        let Current = Int(abs((24 * 60 * 60) * Percent) - 1)
        let Hours = Current / (60 * 60)
        let Minutes = (Current - (Hours * 60 * 60)) / 60
        let Seconds = Current - ((Hours * 60 * 60) + (Minutes * 60))
        Components.hour = Hours
        Components.minute = Minutes
        Components.second = Seconds
        Components.year = 2020
        Components.month = 4
        Components.day = 12
        let Cal = Calendar(identifier: .gregorian)
        let D = Cal.date(from: Components)
        return D!
    }
    
    /// Converts the passed date's time components into a pretty string.
    /// - Parameter From: The date whose time components will be used to generate a pretty string.
    /// - Parameter IncludeSeconds: If true, seconds are included in the time. If false, they are omitted.
    /// - Parameter ForFileName: If true, colons will be replaced by periods.
    /// - Returns: String value of the time components of `From`.
    static func PrettyTime(From: Date, IncludeSeconds: Bool = true, ForFileName: Bool = false) -> String
    {
        let Cal = Calendar.current
        let Hour = Cal.component(.hour, from: From)
        let Minute = Cal.component(.minute, from: From)
        let Second = Cal.component(.second, from: From)
        var HourS = "\(Hour)"
        if Hour < 10
        {
            HourS = " " + HourS
        }
        var MinuteS = "\(Minute)"
        if Minute < 10
        {
            MinuteS = "0" + MinuteS
        }
        var SecondS = "\(Second)"
        if Second < 10
        {
            SecondS = "0" + SecondS
        }
        var Final = ""
        if ForFileName
        {
            let SecondString = IncludeSeconds ? ".\(SecondS)" : ""
            Final = "\(HourS).\(MinuteS)\(SecondString)"
        }
        else
        {
            let SecondString = IncludeSeconds ? ":\(SecondS)" : ""
            Final = "\(HourS):\(MinuteS)\(SecondString)"
        }
        return Final
    }
    
    static func PrettyDateTime(From Now: Date, IncludeSeconds: Bool = true, ForFileName: Bool = false) -> String
    {
        let TimePart = Date.PrettyTime(From: Now, IncludeSeconds: IncludeSeconds, ForFileName: ForFileName)
        let Cal = Calendar.current
        let Day = Cal.component(.day, from: Now)
        let Month = Cal.component(.month, from: Now)
        let Year = Cal.component(.year, from: Now)
        let MonthName = ["Jan", "Feb", "Mar", "Apr", "May", "Jun", "Jul", "Aug", "Sep", "Oct", "Nov", "Dec"][Month - 1]
        let DatePart = "\(Day) \(MonthName) \(Year)"
        return "\(DatePart)_\(TimePart)"
    }
    
    /// Converts the passed date's date components into a pretty string.
    /// - Parameter From: The date whose date components will be used to generate a pretty string.
    /// - Returns: String value of the date components of `From`.
    static func PrettyDate(From: Date) -> String
    {
        let Cal = Calendar.current
        let Day = Cal.component(.day, from: From)
        let Month = Cal.component(.month, from: From)
        let Year = Cal.component(.year, from: From)
        let MonthName = ["Jan", "Feb", "Mar", "Apr", "May", "Jun", "Jul", "Aug", "Sep", "Oct", "Nov", "Dec"][Month - 1]
        return "\(Day) \(MonthName) \(Year)"
    }
    
    /// Converts the passed pretty date string (created with `PrettyDate`) to a Date.
    /// - Parameter Pretty: The pretty string to convert. See `PrettyDate`.
    /// - Returns: Date based on the contents of `Pretty`. Nil returned on error.
    static func PrettyDateToDate(_ Pretty: String) -> Date?
    {
        let Parts = Pretty.split(separator: " ", omittingEmptySubsequences: true)
        if Parts.count != 3
        {
            return nil
        }
        let MonthString = String(Parts[1])
        if let MonthIndex = ["Jan", "Feb", "Mar", "Apr", "May", "Jun", "Jul", "Aug", "Sep", "Oct", "Nov", "Dec"].firstIndex(of: MonthString)
        {
            let DayString = String(Parts[0])
            let Day = Int(DayString)
            if Day == nil
            {
                return nil
            }
            let YearString = String(Parts[2])
            let Year = Int(YearString)
            if Year == nil
            {
                return nil
            }
            return DateFactory(Year: Year!, Month: MonthIndex + 1, Day: Day!)
        }
        return nil
    }
    
    /// Converts the passed date's date and time components into a pretty string.
    /// - Parameter From: The date whose date and time components will be used to generate a pretty string.
    /// - Parameter Separator: Determines how the time and date are separated.
    /// - Parameter DateFirst: If true, the date preceeds the time. If false, the time preceeds the date.
    /// - Returns: String value of the date and time components of `From`.
    static func PrettyDateTime(From: Date, Separator: DateTimeSeparators = .Comma, DateFirst: Bool = true) -> String
    {
        let NiceTime = From.PrettyTime()
        let NiceDate = From.PrettyDate()
        if DateFirst
        {
            return "\(NiceDate)\(Separator.rawValue) \(NiceTime)"
        }
        else
        {
            return "\(NiceTime)\(Separator.rawValue) \(NiceDate)"
        }
    }
    
    /// Converts the instance date's time components into a pretty string.
    /// - Parameter IncludeSeconds: If true, seconds are included. Defaults to `true`.
    /// - Parameter ForFileName: If true, colons (`:`) will be replaced with periods (`.`).
    /// - Returns: String value of the time components of the instance date.
    func PrettyTime(IncludeSeconds: Bool = true, ForFileName: Bool = false) -> String
    {
        return Date.PrettyTime(From: self, IncludeSeconds: IncludeSeconds, ForFileName: ForFileName)
    }
    
    /// Converts the instance date's date components into a pretty string.
    /// - Returns: String value of the date components of the instance date.
    func PrettyDate() -> String
    {
        return Date.PrettyDate(From: self)
    }
    
    /// Converts the instance date's time and date components into a pretty string.
    /// - Parameter Separator: Determines how the date and time are separated.
    /// - Parameter DateFirst: If true, the date preceeds the time. Otherwise the time preceeds the date.
    /// - Returns: String value of the time and date components of the instance date.
    func PrettyDateTime(Separator: DateTimeSeparators = .Comma, DateFirst: Bool = true) -> String
    {
        return Date.PrettyDateTime(From: self, Separator: Separator, DateFirst: DateFirst)
    }
    
    /// Returns the time zone of the instance date.
    /// - Returns: Time zone for the the instance date. May be nil if not known or set.
    func GetTimeZone() -> TimeZone?
    {
        let Cal = Calendar(identifier: .gregorian)
        let Components = Cal.dateComponents([.timeZone], from: self)
        let TZ = Components.timeZone
        return TZ
    }
    
    /// Returns the number of seconds represented by the time component (*not* the date component)
    /// of the instance date.
    /// - Returns: Number of seconds represented by the time components of the instance value.
    func AsSeconds() -> Int
    {
        let Cal = Calendar.current
        let Hour = Cal.component(.hour, from: self)
        let Minute = Cal.component(.minute, from: self)
        let Second = Cal.component(.second, from: self)
        return Second + (Minute * 60) + (Hour * 60 * 60)
    }
    
    /// The year component value for the instance value.
    public var Year: Int
    {
        get
        {
            let Cal = Calendar.current
            return Cal.component(.year, from: self)
        }
    }
    
    /// The month component value for the instance value.
    public var Month: Int
    {
        get
        {
            let Cal = Calendar.current
            return Cal.component(.month, from: self)
        }
    }
    
    /// The day component value for the instance value.
    public var Day: Int
    {
        get
        {
            let Cal = Calendar.current
            return Cal.component(.day, from: self)
        }
    }
    
    /// The hour component value for the instance value.
    public var Hour: Int
    {
        get
        {
            let Cal = Calendar.current
            return Cal.component(.hour, from: self)
        }
    }
    
    /// The minute component value for the instance value.
    public var Minute: Int
    {
        get
        {
            let Cal = Calendar.current
            return Cal.component(.minute, from: self)
        }
    }
    
    /// The second component value for the instance value.
    public var Second: Int
    {
        get
        {
            let Cal = Calendar.current
            return Cal.component(.second, from: self)
        }
    }
    
    /// Given a number of seconds, return the number of years, days, hours, minutes, and remaining
    /// seconds the value represents.
    /// - Parameter SecondCount: The number of seconds to convert to the returned units.
    /// - Returns: Tuple of years, days, hours, minutes, and seconds `SecondCount` represents.
    public static func UnitDuration(_ SecondCount: Int) -> (Years: Int, Days: Int, Hours: Int, Minutes: Int, Seconds: Int)
    {
        var Working = SecondCount
        let YearCount = Working / SecondsIn(.Year)
        if YearCount > 0
        {
            Working = Working - (YearCount * SecondsIn(.Year))
        }
        let DayCount = Working / SecondsIn(.Day)
        if DayCount > 0
        {
            Working = Working - (DayCount * SecondsIn(.Day))
        }
        let HourCount = Working / SecondsIn(.Hour)
        if HourCount > 0
        {
            Working = Working - (HourCount * SecondsIn(.Hour))
        }
        let MinuteCount = Working / SecondsIn(.Minute)
        if MinuteCount > 0
        {
            Working = Working - (MinuteCount * SecondsIn(.Minute))
        }
        if Working > 59
        {
            fatalError("Too many seconds left over! (\(Working)")
        }
        return (YearCount, DayCount, HourCount, MinuteCount, Working)
    }
    
    /// Returns the number of seconds in the specified time unit.
    /// - Parameter Unit: The time unit whose number of seconds is returned.
    /// - Returns: Number of seconds in the specified time unit.
    public static func SecondsIn(_ Unit: TimeUnits) -> Int
    {
        switch Unit
        {
            case .Minute:
                return 60
                
            case .Hour:
                return 60 * 60
                
            case .Day:
                return 24 * 60 * 60
                
            case .Year:
                return 365 * 24 * 60 * 60
        }
    }
    
    /// Returns the data for yesterday. The time components are undefined but probably are the same as
    /// when this property was called.
    var Yesterday: Date
    {
        var DayComponent = DateComponents()
        DayComponent.day = -1
        let Cal = Calendar.current
        let Yesterday = Cal.date(byAdding: DayComponent, to: self)!
        return Yesterday
    }
    
    /// Return the date a specified number of days ago.
    /// - Parameter Days: The number of days prior to the day this function was called.
    /// - Returns: The date, `Days` ago.
    func DaysAgo(_ Days: Int) -> Date
    {
        var DayComponent = DateComponents()
        DayComponent.day = -Days
        let Cal = Calendar.current
        let Ago = Cal.date(byAdding: DayComponent, to: self)!
        return Ago
    }
    
    /// Return the date a specfied number of hours ago.
    /// - Parameter Horus: The number of hours prior to the call of this function.
    /// - Returns: The date, `Hours` ago.
    func HoursAgo(_ Hours: Int) -> Date
    {
        var HourComponent = DateComponents()
        HourComponent.hour = -Hours
        let Cal = Calendar.current
        let Ago = Cal.date(byAdding: HourComponent, to: self)!
        return Ago
    }
    
    /// Determines if the instance time is on or later than the passed time.
    /// - Parameter Than: The other time to compare to the instance time. Date components are ignored.
    /// - Returns: True if the instance time is the same or later than the passed time, false otherwise.
    func IsOnOrLater(Than Time: Date) -> Bool
    {
        let SelfHour = self.Hour
        let SelfMinute = self.Minute
        let SelfSecond = self.Second
        let SelfSeconds = (SelfHour * 60 * 60) + (SelfMinute * 60) + SelfSecond
        let OtherHour = Time.Hour
        let OtherMinute = Time.Minute
        let OtherSecond = Time.Second
        let OtherSeconds = (OtherHour * 60 * 60) + (OtherMinute * 60) + OtherSecond
        return SelfSeconds >= OtherSeconds
    }
    
    /// Determines if the instance time is in equatorial night or day.
    /// - Returns: True if the instance time is between 17:30 and 6:00 the following date, false if not.
    func IsInEquatorialNight() -> Bool
    {
        let SelfHour = self.Hour
        let SelfMinute = self.Minute
        let SelfSecond = self.Second
        let SelfSeconds = Double((SelfHour * 60 * 60) + (SelfMinute * 60) + SelfSecond)
        if SelfSeconds <= HourConstants.NightEnd.rawValue * (60.0 * 60.0)
        {
            return true
        }
        if SelfSeconds >= HourConstants.NightStart.rawValue * (60.0 * 60.0)
        {
            return true
        }
        return false
    }
}

enum DateTimeSeparators: String, CaseIterable
{
    case Space = " "
    case Comma = ", "
    case OneTab = "\t"
    case TwoTabs = "\t\t"
}
