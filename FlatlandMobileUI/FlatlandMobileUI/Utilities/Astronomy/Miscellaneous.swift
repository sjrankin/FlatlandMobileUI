//
//  Miscellaneous.swift
//  Miscellaneous
//
//  Created by Stuart Rankin on 7/18/21. Adapted from Flatland View.
//

import Foundation
import UIKit

class Miscellaneous
{
    //    let Settings = UserSettings()
    
    func InTimeRange(_ Test: Date, RangeLow: Date, RangeHigh: Date) -> Bool
    {
        if Test < RangeLow
        {
            return false
        }
        if Test > RangeHigh
        {
            return false
        }
        return true
    }
    
    func InTimeRange(_ Test: Date, RangeStart: Date, SecondsToRangeEnd: Int) -> Bool
    {
        return InTimeRange(Test,RangeLow: RangeStart, RangeHigh: RangeStart.addingTimeInterval(TimeInterval(SecondsToRangeEnd)))
    }
    
    func TimeFromString(_ Raw: String) -> Date?
    {
        if Raw.isEmpty
        {
            return nil
        }
        let Parts = Raw.split(separator: ":")
        let Hour: String = String(Parts[0])
        let IHour: Int = Int(Hour)!
        let Minute: String = String(Parts[1])
        let IMinute: Int = Int(Minute)!
        var Comp = DateComponents()
        Comp.hour = IHour
        Comp.minute = IMinute
        let Cal = Calendar.current
        let TheTime = Cal.date(from: Comp)
        return TheTime
    }
    
    func AppendIfNotNil(_ Root: String, ValueToAppend: String?, AddNewLine: Bool = true) -> String
    {
        if ValueToAppend == nil
        {
            return Root
        }
        var Scratch = Root + ValueToAppend!
        if AddNewLine
        {
            Scratch = Scratch + "\n"
        }
        return Scratch
    }
    
    func SameTimes(Date1: Date, Date2: Date, IncludeSecond: Bool = false) -> Bool
    {
        let Cal = Calendar.current
        let Hour1 = Cal.component(.hour, from: Date1)
        let Hour2 = Cal.component(.hour, from: Date2)
        if Hour1 != Hour2
        {
            return false
        }
        let Minute1 = Cal.component(.minute, from: Date1)
        let Minute2 = Cal.component(.minute, from: Date2)
        if Minute1 != Minute2
        {
            return false
        }
        if IncludeSecond
        {
            let Second1 = Cal.component(.second, from: Date1)
            let Second2 = Cal.component(.second, from: Date2)
            if Second1 != Second2
            {
                return false
            }
        }
        return true
    }
    
    func SameDates(Date1: Date, Date2: Date) -> Bool
    {
        let Cal = Calendar.current
        if Cal.component(.day, from: Date1) != Cal.component(.day, from: Date2)
        {
            return false
        }
        if Cal.component(.month, from: Date1) != Cal.component(.month, from: Date2)
        {
            return false
        }
        if Cal.component(.year, from: Date1) != Cal.component(.year, from: Date2)
        {
            return false
        }
        return true
    }
    
    func SameTimeAndDate(Date1: Date, Date2: DateComponents) -> Bool
    {
        let Cal = Calendar.current
        if Cal.component(.day, from: Date1) != Date2.day!
        {
            return false
        }
        if Cal.component(.month, from: Date1) != Date2.month!
        {
            return false
        }
        if Cal.component(.year, from: Date1) != Date2.year!
        {
            return false
        }
        if Cal.component(.hour, from: Date1) != Date2.hour!
        {
            return false
        }
        if Cal.component(.minute, from: Date1) != Date2.minute!
        {
            return false
        }
        return true
    }
    
    func SecondsSoFarToday() -> Int
    {
        let Now = Date()
        let Cal = Calendar.current
        let Seconds = Cal.component(.second, from: Now)
        let Minutes = Cal.component(.minute, from: Now)
        let Hours = Cal.component(.hour, from: Now)
        let Final = Seconds + (Minutes * 60) + (Hours * 60 * 60)
        return Final
    }
    
    func Pad(_ Raw: String, With: String, Count: Int, ToFront: Bool = true) -> String
    {
        if With.isEmpty
        {
            return Raw
        }
        if Count < 1
        {
            return Raw
        }
        
        var Scratch = ""
        for _ in 0..<Count
        {
            Scratch = Scratch + With
        }
        if Raw.isEmpty
        {
            return Scratch
        }
        if ToFront
        {
            return Scratch + Raw
        }
        else
        {
            return Raw + Scratch
        }
    }
    
    func PadTo(_ Raw: String, With: String, ToCount: Int, ToFront: Bool = true) -> String
    {
        if With.isEmpty
        {
            return Raw
        }
        if ToCount < 1
        {
            return Raw
        }
        let ToAdd = ToCount - Raw.count
        if ToAdd <= 0
        {
            return Raw
        }
        
        var Scratch = ""
        for _ in 0..<ToAdd
        {
            Scratch = Scratch + With
        }
        if Raw.isEmpty
        {
            return Scratch
        }
        if ToFront
        {
            return Scratch + Raw
        }
        else
        {
            return Raw + Scratch
        }
    }
    
    func PrettifyBinary(Value: UInt8, SeparateBytes: Bool = true, AddPrefix: Bool = true) -> String
    {
        var Scratch = String(Value, radix: 2)
        Scratch = PadTo(Scratch, With: "0", ToCount: 8)
        if SeparateBytes
        {
            let Top = String(Scratch.prefix(4))
            let Bottom = String(Scratch.suffix(4))
            Scratch = Top + "_" + Bottom
        }
        if AddPrefix
        {
            Scratch = "0b" + Scratch
        }
        return Scratch
    }
    
    enum TimeDurations
    {
        case AtEvent
        case OneMinute
        case FiveMinutes
        case TenMinutes
        case ThirtyMinutes
        case SixtyMinutes
    }
    
    func GetTimeMask(Duration: TimeDurations) -> UInt8
    {
        switch Duration
        {
            case .OneMinute:
                return 0b0000_0001
                
            case .FiveMinutes:
                return 0b0000_0010
                
            case .TenMinutes:
                return 0b0000_0100
                
            case .ThirtyMinutes:
                return 0b0000_1000
                
            case .SixtyMinutes:
                return 0b0001_0000
                
            case .AtEvent:
                return 0b0010_0000
        }
    }
    
    func EnabledDurations(_ Raw: UInt8) -> [TimeDurations]
    {
        var Durations: [TimeDurations] = [TimeDurations]()
        if DurationIsEnabled(Raw, Duration: .AtEvent)
        {
            Durations.append(.AtEvent)
        }
        if DurationIsEnabled(Raw, Duration: .OneMinute)
        {
            Durations.append(.OneMinute)
        }
        if DurationIsEnabled(Raw, Duration: .FiveMinutes)
        {
            Durations.append(.FiveMinutes)
        }
        if DurationIsEnabled(Raw, Duration: .TenMinutes)
        {
            Durations.append(.TenMinutes)
        }
        if DurationIsEnabled(Raw, Duration: .ThirtyMinutes)
        {
            Durations.append(.ThirtyMinutes)
        }
        if DurationIsEnabled(Raw, Duration: .SixtyMinutes)
        {
            Durations.append(.SixtyMinutes)
        }
        return Durations
    }
    
    func GetDurationValue(_ Durations: [TimeDurations]) -> UInt8
    {
        if Durations.count < 1
        {
            return 0
        }
        var Value: UInt8 = 0
        for SomeDuration in Durations
        {
            Value = AccumulateTimes(Accumulator: Value, Duration: SomeDuration)
        }
        return Value
    }
    
    func DurationIsEnabled(_ Raw: UInt8, Duration: TimeDurations) -> Bool
    {
        let Mask = GetTimeMask(Duration: Duration)
        return Raw & Mask > 0
    }
    
    func AccumulateTimes(Accumulator: UInt8, Duration: TimeDurations) -> UInt8
    {
        let NewDuration = GetTimeMask(Duration: Duration)
        let NewAccumulation = Accumulator | NewDuration
        return NewAccumulation
    }
    
    func MakeLocationString(Latitude: Double, Longitude: Double, Altitude: Double? = nil) -> String
    {
        let FinalLongitude = RoundTo(abs(Longitude), ToNearest: 0.1)
        let FinalLatitude = RoundTo(abs(Latitude), ToNearest: 0.1)
        var FinalAltitude = 0.0
        if Altitude != nil
        {
            FinalAltitude = RoundTo(Altitude!, ToNearest: 0.1)
        }
        var LatString = String(describing: FinalLatitude)
        if Latitude < 0.0
        {
            LatString = LatString + "S"
        }
        else
        {
            LatString = LatString + "N"
        }
        var LonString = String(describing: FinalLongitude)
        if Longitude < 0.0
        {
            LonString = LonString + "W"
        }
        else
        {
            LonString = LonString + "E"
        }
        var AltString = ""
        if Altitude != nil
        {
            //let InMetric = Locale.current.usesMetricSystem
            let Units = "m"
            AltString = String(describing: FinalAltitude)
            AltString = ", " + AltString + Units
        }
        let Final = LatString + ", " + LonString + AltString
        return Final
    }
    
    func HexStringToInt(_ Raw: String) -> Int?
    {
        if Raw.count < 1
        {
            return nil
        }
        var Working = Raw.trimmingCharacters(in: .whitespacesAndNewlines)
        if Working.starts(with: "0x") || Working.starts(with: "0X")
        {
            Working = Working.replacingOccurrences(of: "0x", with: "")
            Working = Working.replacingOccurrences(of: "0X", with: "")
        }
        else
        {
            if Working.starts(with: "#")
            {
                Working = Working.replacingOccurrences(of: "#", with: "")
            }
        }
        if Working.count != 6
        {
            return nil
        }
        let Final = Int(Working, radix: 16)
        return Final
    }
    
    func ConvertTo12Hour(_ Raw: String) -> String
    {
        if Raw.count < 1
        {
            return ""
        }
        var Final = ""
        let P0 = Raw.split(separator: " ")
        if P0.count < 1
        {
            return ""
        }
        let Remainder: String = String(P0[0])
        let P1 = Remainder.split(separator: ":")
        if P1.count != 2
        {
            return ""
        }
        let MinuteString = P1[1]
        var Hour = Int(P1[0])
        var FinalHour = ""
        var AMPM = "AM"
        if Hour! >= 12
        {
            AMPM = "PM"
            Hour! = Hour! % 12
        }
        FinalHour = String(describing: Hour!)
        Final = FinalHour + ":" + MinuteString + " " + AMPM
        return Final
    }
    
    func MakeTimeString(TheDate: Date, IncludeSeconds: Bool = true) -> String
    {
        let Cal = Calendar.current
        let Hour = Cal.component(.hour, from: TheDate)
        var HourString = String(describing: Hour)
        if Hour < 10
        {
            HourString = "0" + HourString
        }
        let Minute = Cal.component(.minute, from: TheDate)
        var MinuteString = String(describing: Minute)
        if Minute < 10
        {
            MinuteString = "0" + MinuteString
        }
        let Second = Cal.component(.second, from: TheDate)
        var Result = HourString + ":" + MinuteString
        if IncludeSeconds
        {
            var SecondString = String(describing: Second)
            if Second < 10
            {
                SecondString = "0" + SecondString
            }
            Result = Result + ":" + SecondString
        }
        return Result
    }
    
    func MakeDateString(TheDate: Date, ShortMonth: Bool = true) -> String
    {
        let (Day, Month, Year) = GetDate(TheDate)
        let DayString = String(describing: Day)
        let YearString = String(describing: Year)
        let MonthString = MakeEnglishMonth(Month, ShortString: ShortMonth)
        let Final = DayString + " " + MonthString + " " + YearString
        return Final
    }
    
    func GetDate(_ TheDate: Date) -> (Int, Int, Int)
    {
        let Cal = Calendar.current
        let Day = Cal.component(.day, from: TheDate)
        let Month = Cal.component(.month, from: TheDate)
        let Year = Cal.component(.year, from: TheDate)
        return (Day, Month, Year)
    }
    
    func GetTime(_ TheDate: Date) -> (Int, Int)
    {
        let Cal = Calendar.current
        let Hour = Cal.component(.hour, from: TheDate)
        let Minute = Cal.component(.minute, from: TheDate)
        return (Hour, Minute)
    }
    
    // in the format dd mm yy, in order
    //https://stackoverflow.com/questions/24089999/how-do-you-create-a-swift-date-object
    func DateFromString(_ Raw: String) -> Date?
    {
        let Parts = Raw.split(separator: " ")
        if Parts.count != 3
        {
            return nil
        }
        let Day: Int = Int(Parts[0])!
        let Year: Int = Int(Parts[2])!
        let Month = GetMonthOrdinal(String(Parts[1]))
        if Month == nil
        {
            return nil
        }
        var Components = DateComponents()
        Components.year = Year
        Components.month = Month!
        Components.day = Day
        let Cal = Calendar.current
        return Cal.date(from: Components)
    }
    
    func TimeFromString(_ Raw: String, IncludeSeconds: Bool = false) -> Date?
    {
        let Parts = Raw.split(separator: ":")
        var PartCount = 2
        if IncludeSeconds
        {
            PartCount = 3
        }
        if Parts.count != PartCount
        {
            return nil
        }
        let Hour: Int = Int(Parts[0])!
        let Minute: Int = Int(Parts[1])!
        var Second: Int = 0
        if IncludeSeconds
        {
            Second = Int(Parts[2])!
        }
        var Components = DateComponents()
        Components.hour = Hour
        Components.minute = Minute
        Components.second = Second
        let Cal = Calendar.current
        return Cal.date(from: Components)
    }
    
    func SimpleTimeParse(RawTime: String) -> (Int, Int)?
    {
        if RawTime.count != 5
        {
            return nil
        }
        let Parts = RawTime.split(separator: ":")
        if Parts.count != 2
        {
            return nil
        }
        let Hour = Int(Parts[0])
        let Minute = Int(Parts[1])
        return (Hour!, Minute!)
    }
    
    func GetTimeParts(Is24Hour: Bool) -> (Int, Int, Int)
    {
        let Now = Date()
        let Cal = Calendar.current
        var Hour = Cal.component(.hour, from: Now)
        if Is24Hour
        {
            Hour = Hour % 12
        }
        let Minute = Cal.component(.minute, from: Now)
        let Second = Cal.component(.second, from: Now)
        return (Hour, Minute, Second)
    }
    
    func GetTimeParts(Hour: Int, Minute: Int, Second: Int, AddLeadingZero: Bool, Is24Hour: Bool) -> (String, String, String)
    {
        var HourString = GetNumerals(Value: Hour)
        var DoAddLeading0 = true
        if !Is24Hour && !AddLeadingZero
        {
            DoAddLeading0 = false
        }
        if Hour < 10
        {
            if DoAddLeading0
            {
                HourString = "0" + HourString
            }
        }
        var MinuteString = GetNumerals(Value: Minute)
        if Minute < 10
        {
            MinuteString = "0" + MinuteString
        }
        var SecondString = GetNumerals(Value: Second)
        if Second < 10
        {
            SecondString = "0" + SecondString
        }
        return (HourString, MinuteString, SecondString)
    }
    
    func GetTimePartsEx(AddLeadingZero: Bool, Is24Hour: Bool) -> (String, String, String)
    {
        let (Hour, Minute, Second) = GetTimeParts(Is24Hour: Is24Hour)
        return GetTimeParts(Hour: Hour, Minute: Minute, Second: Second, AddLeadingZero: AddLeadingZero, Is24Hour: Is24Hour)
    }
    
    func MakeEnglishWeekDay(_ DayOfWeek: Int) -> String
    {
        var DayName = ""
        switch DayOfWeek
        {
            case 1:
                DayName = "Sunday"
                
            case 2:
                DayName = "Monday"
                
            case 3:
                DayName = "Tuesday"
                
            case 4:
                DayName = "Wednesday"
                
            case 5:
                DayName = "Thursday"
                
            case 6:
                DayName = "Friday"
                
            case 7:
                DayName = "Saturday"
                
            default:
                DayName = ""
        }
        return DayName
    }
    
    func MakeEnglishMonth(_ Month: Int, ShortString: Bool = false) -> String
    {
        if Month < 1 || Month > 12
        {
            return String(describing: Month)
        }
        if ShortString
        {
            return MakeEnglishShortMonth(Month)
        }
        return LongMonthNames[Month - 1]
    }
    
    func MakeEnglishShortMonth(_ Month: Int) -> String
    {
        if Month < 1 || Month > 12
        {
            return String(describing: Month)
        }
        return ShortMonthNames[Month - 1]
    }
    
    func GetMonthOrdinal(_ Month: String, IsShort: Bool = true) -> Int?
    {
        if IsShort
        {
            return ShortMonthNames.firstIndex(of: Month)
        }
        else
        {
            return LongMonthNames.firstIndex(of: Month)
        }
    }
    
    let ShortMonthNames = ["Jan", "Feb", "Mar", "Apr", "May", "Jun", "Jul", "Aug", "Sep", "Oct", "Nov", "Dec"]
    let LongMonthNames = ["January", "February", "March", "April", "May", "June", "July", "August", "September", "October", "November", "December"]
    
    func MakeAttributedString(_ Text: String, Attributes: [NSAttributedString.Key : Any]) -> NSAttributedString
    {
        return NSAttributedString(string: Text, attributes: Attributes)
    }
    
    //https://stackoverflow.com/questions/24666515/how-do-i-make-an-attributed-string-using-swift
    func MakeMutableAttributedString(_ Text: String, Attributes: [NSAttributedString.Key : Any]) -> NSMutableAttributedString
    {
        return NSMutableAttributedString(string: Text, attributes: Attributes)
    }
    
#if false
    func ShiftColor(_ TheColor: UIColor, ByDegrees: Float) -> UIColor
    {
        let (Hue, Saturation, Brightness) = UIColor.GetHSB(SourceColor: TheColor)
        var ShiftBy = ByDegrees
        if ShiftBy < -360.0
        {
            ShiftBy = -360.0
        }
        if ShiftBy > 360.0
        {
            ShiftBy = 360.0
        }
        let NormalizedShift = ShiftBy / 360.0
        var NewHue = Hue + CGFloat(NormalizedShift)
        if NewHue < 0.0
        {
            NewHue = NewHue + 1.0
        }
        if NewHue > 1.0
        {
            NewHue = NewHue - 1.0
        }
        let ShiftedColor = UIColor.init(hue: NewHue, saturation: Saturation, brightness: Brightness, alpha: 1.0)
        return ShiftedColor
    }
#endif
    
    func EnsureNormalized(_ Value: CGFloat) -> CGFloat
    {
        if Value < 0.0
        {
            return 0.0
        }
        if Value > 1.0
        {
            return 1.0
        }
        return Value
    }
    
#if false
    func BuildColor(NewHue: CGFloat, NewSaturation: CGFloat, NewBrightness: CGFloat) -> UIColor
    {
        return UIColor.init(hue: EnsureNormalized(NewHue), saturation: EnsureNormalized(NewSaturation), brightness: EnsureNormalized(NewBrightness), alpha: 1.0)
    }
    
    func EditColor(_ TheColor: UIColor, NewHue: CGFloat) -> UIColor
    {
        let (_, OldSaturation, OldBrightness) = UIColor.GetHSB(SourceColor: TheColor)
        return BuildColor(NewHue: NewHue, NewSaturation: OldSaturation, NewBrightness: OldBrightness)
    }
    
    func EditColor(_ TheColor: UIColor, NewSaturation: CGFloat) -> UIColor
    {
        let (OldHue, _, OldBrightness) = UIColor.GetHSB(SourceColor: TheColor)
        return BuildColor(NewHue: OldHue, NewSaturation: NewSaturation, NewBrightness: OldBrightness)
    }
    
    func EditColor(_ TheColor: UIColor, NewBrightness: CGFloat) -> UIColor
    {
        let (OldHue, OldSaturation, _) = UIColor.GetHSB(SourceColor: TheColor)
        return BuildColor(NewHue: OldHue, NewSaturation: OldSaturation, NewBrightness: NewBrightness)
    }
    
    func EditColor(_ TheColor: UIColor, HuePercent: Float) -> UIColor
    {
        let (OldHue, OldSaturation, OldBrightness) = UIColor.GetHSB(SourceColor: TheColor)
        let NewHue: CGFloat = OldHue * EnsureNormalized(CGFloat(HuePercent))
        return BuildColor(NewHue: NewHue, NewSaturation: OldSaturation, NewBrightness: OldBrightness)
    }
    
    func EditColor(_ TheColor: UIColor, SaturationPercent: Float) -> UIColor
    {
        let (OldHue, OldSaturation, OldBrightness) = UIColor.GetHSB(SourceColor: TheColor)
        let NewSaturation: CGFloat = OldSaturation * EnsureNormalized(CGFloat(SaturationPercent))
        return BuildColor(NewHue: OldHue, NewSaturation: NewSaturation, NewBrightness: OldBrightness)
    }
    
    func EditColor(_ TheColor: UIColor, BrightnessPercent: Float) -> UIColor
    {
        let (OldHue, OldSaturation, OldBrightness) = UIColor.GetHSB(SourceColor: TheColor)
        let NewBrightness: CGFloat = OldBrightness * EnsureNormalized(CGFloat(BrightnessPercent))
        return BuildColor(NewHue: OldHue, NewSaturation: OldSaturation, NewBrightness: NewBrightness)
    }
#endif
    
    //http://www.globalnerdy.com/2016/01/26/better-to-be-roughly-right-than-precisely-wrong-rounding-numbers-with-swift/
    func RoundTo(_ Value: Float, ToNearest: Float) -> Float
    {
        return roundf(Value / ToNearest) * ToNearest
    }
    
    //http://www.globalnerdy.com/2016/01/26/better-to-be-roughly-right-than-precisely-wrong-rounding-numbers-with-swift/
    func RoundTo(_ Value: Double, ToNearest: Double) -> Double
    {
        return round(Value / ToNearest) * ToNearest
    }
    
    //http://www.globalnerdy.com/2016/01/26/better-to-be-roughly-right-than-precisely-wrong-rounding-numbers-with-swift/
    func RoundTo(_ Value: CGFloat, ToNearest: CGFloat) -> CGFloat
    {
        return CGFloat(round(Value / ToNearest) * ToNearest)
    }
    
    /// Truncate a double value to the number of places.
    ///
    /// - Parameters:
    ///   - Value: Value to truncate.
    ///   - ToPlaces: Where to truncate the value.
    /// - Returns: Truncated double value.
    func Truncate(_ Value: Double, ToPlaces: Int) -> Double
    {
        let D: Decimal = 10.0
        let X = pow(D, ToPlaces)
        let X1: Double = Double(truncating: X as NSNumber)
        let Working: Int = Int(Value * X1)
        let Final: Double = Double(Working) / X1
        return Final
    }
    
    /// Round a double value to the specified number of places.
    ///
    /// - Parameters:
    ///   - Value: Value to round.
    ///   - ToPlaces: Number of places to round to.
    /// - Returns: Rounded value.
    func Round(_ Value: Double, ToPlaces: Int) -> Double
    {
        let D: Decimal = 10.0
        let X = pow(D, ToPlaces + 1)
        let X1: Double = Double(truncating: X as NSNumber)
        var Working: Int = Int(Value * X1)
        let Last = Working % 10
        Working = Working / 10
        if Last >= 5
        {
            Working = Working + 1
        }
        let Final: Double = Double(Working) / (X1 / 10.0)
        return Final
    }
    
    func SplitByCapitalLetters(Target: String) -> [String]
    {
        var Results: [String] = [String]()
        let CapitalRange = "A"..."Z"
        var Accumulator = ""
        for SomeChar in Target
        {
            if CapitalRange.contains(String(SomeChar))
            {
                if Accumulator.count > 0
                {
                    Results.append(Accumulator)
                    Accumulator = ""
                }
                Accumulator = Accumulator + String(SomeChar)
            }
        }
        if Accumulator.count > 0
        {
            Results.append(Accumulator)
        }
        return Results
    }
    
    func AddPrefixToCapitalLetters(Target: String, Prefix: String) -> String
    {
        let CapitalRange = "A"..."Z"
        var Accumulator = ""
        var Index = 0
        for SomeChar in Target
        {
            if CapitalRange.contains(String(SomeChar)) && Index > 0
            {
                Accumulator = Accumulator + Prefix
            }
            Accumulator = Accumulator + String(SomeChar)
            Index = Index + 1
        }
        return Accumulator
    }
    
    func GetFontParts(FullName: String) -> [String]
    {
        let Parts = FullName.components(separatedBy: "-")
        var Result: [String] = [String]()
        Result.append(Parts[0])
        if Parts.count > 1
        {
            Result.append(Parts[1])
        }
        else
        {
            Result.append("")
        }
        return Result
    }
    
    func StripAttributesFromName(FullName: String) -> String
    {
        let Parts = FullName.components(separatedBy: "-")
        return Parts[0]
    }
    
    func StripNameFromAttributes(FullName: String) -> String
    {
        let Parts = FullName.components(separatedBy: "-")
        return Parts[1]
    }
    
    func CreateFullName(FamilyName: String, FontName: String) -> String
    {
        if FontName.count == 0
        {
            return FamilyName
        }
        return FamilyName + "-" + FontName
    }
    
    /// Given an array of user data, determine if any key in the array matches NotificationKey.
    /// - Parameters:
    ///   - NotificationKey: The key to search for.
    ///   - UserData: Array of data to search.
    /// - Returns: Element associated with Notification key if UserData contains a key that matches NotificationKey, nil if not found.
    public func GetNotificationData(NotificationKey: String, UserData: [String : Any]) -> Any?
    {
        if UserData.count < 1
        {
            return nil
        }
        for (Key, Element) in UserData
        {
            if Key == NotificationKey
            {
                return Element
            }
        }
        return nil
    }
    
    /// Return the width of the string.
    ///
    /// - Parameters:
    ///   - TheString: The string to measure.
    ///   - TheFont: The font that will be used to render the string.
    /// - Returns: Width of the string.
    public func StringWidth(TheString: String, TheFont: UIFont) -> CGFloat
    {
        let FontAttrs = [NSAttributedString.Key.font: TheFont]
        let TextWidth = (TheString as NSString).size(withAttributes: FontAttrs)
        return TextWidth.width
    }
    
    /// Return the height of the string.
    ///
    /// - Parameters:
    ///   - TheString: The string to measure.
    ///   - TheFont: The font that will be used to render the string.
    /// - Returns: Height of the string.
    public func StringHeight(TheString: String, TheFont: UIFont) -> CGFloat
    {
        let FontAttrs = [NSAttributedString.Key.font: TheFont]
        let TextHeight = (TheString as NSString).size(withAttributes: FontAttrs)
        return TextHeight.height
    }
    
    //https://stackoverflow.com/questions/1324379/how-to-calculate-the-width-of-a-text-string-of-a-specific-font-and-font-size
    /// Return the width of the string.
    ///
    /// - Parameters:
    ///   - TheString: The string to measure.
    ///   - FontName: The font the string will be rendered in.
    ///   - FontSize: The size of the font.
    /// - Returns: The width of the string.
    public func StringWidth(TheString: String, FontName: String, FontSize: CGFloat) -> CGFloat
    {
        if let TheFont = UIFont(name: FontName, size: FontSize)
        {
            let FontAttrs = [NSAttributedString.Key.font: TheFont]
            let TextWidth = (TheString as NSString).size(withAttributes: FontAttrs)
            return TextWidth.width
        }
        return 0.0
    }
    
    /// Return the height of the string.
    ///
    /// - Parameters:
    ///   - TheString: The string to measure.
    ///   - FontName: The font the string will be rendered in.
    ///   - FontSize: The size of the font.
    /// - Returns: The height of the string.
    public func StringHeight(TheString: String, FontName: String, FontSize: CGFloat) -> CGFloat
    {
        if let TheFont = UIFont(name: FontName, size: FontSize)
        {
            let FontAttrs = [NSAttributedString.Key.font: TheFont]
            let TextHeight = (TheString as NSString).size(withAttributes: FontAttrs)
            return TextHeight.height
        }
        return 0.0
    }
    
    /// Given a string, a font, and a constraining size, return the size of the largest font that will fit in the
    /// constraint.
    /// - Parameters:
    ///   - HorizontalConstraint: Constraint - the returned font size will ensure the string will fit into this horizontal constraint.
    ///   - TheString: The string to fit into the constraint.
    ///   - FontName: The name of the font to draw the text.
    ///   - Margin: Extra value to subtrct from the HorizontalConstraint.
    /// - Returns: Font size to use with the specified font and text.
    public func RecommendedFontSize(HorizontalConstraint: CGFloat, TheString: String, FontName: String, MinimumFontSize: CGFloat = 12.0, Margin: CGFloat = 40.0) -> CGFloat
    {
        let ConstraintWithMargin = HorizontalConstraint - Margin
        var LastGoodSize: CGFloat = 0.0
        for Scratch in 1...500
        {
            let TextWidth = StringWidth(TheString: TheString, FontName: FontName, FontSize: CGFloat(Scratch))
            if (TextWidth > ConstraintWithMargin)
            {
                return LastGoodSize
            }
            LastGoodSize = CGFloat(Scratch)
        }
        return MinimumFontSize
    }
    
    public func RecommendedFontSize(HorizontalConstraint: CGFloat, VerticalConstraint: CGFloat, TheString: String,
                                    FontName: String, MinimumFontSize: CGFloat = 12.0, HorizontalMargin: CGFloat = 40.0, VerticalMargin: CGFloat = 20.0) -> CGFloat
    {
        var FinalFontName = FontName
        if !StaticFontNames.contains(FontName)
        {
            FinalFontName = FontName.replacingOccurrences(of: " ", with: "")
        }
        let HConstraint = HorizontalConstraint - HorizontalMargin
        let VConstraint = VerticalConstraint - VerticalMargin
        var LastGoodSize: CGFloat = 0.0
        for Scratch in 1...500
        {
            let TextWidth = StringWidth(TheString: TheString, FontName: FinalFontName, FontSize: CGFloat(Scratch))
            let TextHeight = StringHeight(TheString: TheString, FontName: FinalFontName, FontSize: CGFloat(Scratch))
            if TextWidth > HConstraint && TextHeight > VConstraint
            {
                return LastGoodSize
            }
            LastGoodSize = CGFloat(Scratch)
        }
        return MinimumFontSize
    }
    
    public let StaticFontNames = ["Academy Engraved LET","Party LET","Savoye LET"]
    
    // Return a color based on TimePercent, which must be a normalized value. TimePercent
    // is converted to a range of 0 to 360 and used as the Hue parameter for a new HSL
    // color, which is returned. FinalHue contains the hue used to generate the color and
    // is provided for debugging purposes.
    public func GetColorForTime(TimePercent: CGFloat, FinalHue: inout CGFloat) -> UIColor
    {
        if (TimePercent < 0.0)
        {
            return UIColor.white
        }
        if (TimePercent > 1.0)
        {
            return UIColor.white
        }
        let Hue = TimePercent
        FinalHue = Hue
        let Final = UIColor(hue: Hue, saturation: 1.0, brightness: 1.0, alpha: 1.0)
        return Final
    }
    
    // Returns a color to be used to paint the background. The color returned depends on the setting of
    // the ColorRotation UserDefault value. Some settings return a solid, unchanging color while others
    // have a variable color depending on the time of day. The actual hue used is returned in FinalHue and
    // is provided for debugging purposes.
    public func GetBackgroundColor(FinalHue: inout CGFloat) -> UIColor
    {
        let Now = Date()
        let Cal = Calendar.current
        let Hour = CGFloat(Cal.component(.hour, from: Now))
        let Minute = CGFloat(Cal.component(.minute, from: Now))
        let Second = CGFloat(Cal.component(.second, from: Now))
        switch  UserDefaults.standard.integer(forKey: "ColorRotation")
        {
            case 0:
                FinalHue = -1.0
#if true
                //https://stackoverflow.com/questions/55982244/how-to-nskeyedunarchiver-unarchiveobject
                let ColorBlock = UserDefaults.standard.data(forKey: "ClockBackgroundColor")
                do
                {
                    let BGColor = try NSKeyedUnarchiver.unarchivedObject(ofClass: UIColor.self, from: ColorBlock!)
                    return BGColor!
                }
                catch
                {
                    return UIColor.black
                }
#else
                let ColorBlock = UserDefaults.standard.data(forKey: "ClockBackgroundColor")
                let BGColor = NSKeyedUnarchiver.unarchiveObject(with: ColorBlock!) as? UIColor
                return BGColor!
#endif
                
            case 1:
                //One cycle a minute
                let Percent = Second / 60.0
                return GetColorForTime(TimePercent: Percent, FinalHue: &FinalHue)
                
            case 2:
                //One cycle an hour
                let TotalSeconds = CGFloat((Minute * 60.0) + Second)
                let Percent = TotalSeconds / (60.0 * 60.0)
                return GetColorForTime(TimePercent: Percent, FinalHue: &FinalHue)
                
            case 3:
                //One cycle a day
                let TotalSeconds = CGFloat((((Hour * 60.0) + Minute) * 60.0) + Second)
                let Percent = TotalSeconds / (24.0 * 60.0 * 60.0)
                return GetColorForTime(TimePercent: Percent, FinalHue: &FinalHue)
                
            default:
                return UIColor.black
        }
    }
    
    func GetNumerals(Value: Int) -> String
    {
        return String(Value)
        /*
         let SValue = String(Value)
         var Final: String = ""
         for C in SValue
         {
         Final = Final + KanjiTable[C]!
         }
         if (Value < 10)
         {
         Final = KanjiTable["0"]! + Final
         }
         return Final
         */
    }
    
    let EasternArabic: [Character : String] =
    ["0" : "٠", "1" : "١", "2" : "٢", "3" : "٣", "4" : "٤", "5" : "٥", "6" : "٦", "7" : "٧", "8" : "٨", "9" : "٩"]
    let KanjiTable: [Character : String] =
    ["0" : "〇", "1" : "一", "2" : "二", "3" : "三", "4" : "四", "5" : "五", "6" : "六", "7" : "七", "8" : "八", "9" : "九"]
    let HangulTable: [Character : String] =
    ["0" : "영", "1" : "일", "2" : "이", "3" : "삼", "4" : "사", "5" : "오", "6" : "육", "7" : "칠", "8" : "팔", "9" : "구"]
    
    /// Converts a UIColor to a human-readable string.
    /// - Parameters:
    ///   - ColorValue: The color to convert.
    ///   - InHex: If true, the color's hex value (no alpha) is returned as a string.
    ///   - AsName: If true, the color's name, if known, is returned. If the name is not known, an RGB string is returned instead.
    /// - Returns: String representation of the passed UIColor
    public func ColorToString(ColorValue: UIColor, InHex: Bool = true, AsName: Bool = false) -> String
    {
        var Red: CGFloat = 0.0
        var Green: CGFloat = 0.0
        var Blue: CGFloat = 0.0
        var Alpha: CGFloat = 0.0
        ColorValue.getRed(&Red, green: &Green, blue: &Blue, alpha: &Alpha)
        let IRed = Int(Red * 255.0)
        let IGreen = Int(Green * 255.0)
        let IBlue = Int(Blue * 255.0)
        if InHex
        {
            let RGBHex = (IRed << 16) | (IGreen << 8) | (IBlue << 0)
            return String(RGBHex, radix: 16, uppercase: false)
        }
        if AsName
        {
            switch ColorValue
            {
                case UIColor.black:
                    return "Black"
                    
                case UIColor.blue:
                    return "Blue"
                    
                case UIColor.brown:
                    return "Brown"
                    
                case UIColor.clear:
                    return "Clear"
                    
                case UIColor.darkGray:
                    return "Dark Gray"
                    
                case UIColor.gray:
                    return "Gray"
                    
                case UIColor.green:
                    return "Green"
                    
                case UIColor.lightGray:
                    return "Light Gray"
                    
                case UIColor.magenta:
                    return "Magenta"
                    
                case UIColor.orange:
                    return "Orange"
                    
                case UIColor.purple:
                    return "Purple"
                    
                case UIColor.red:
                    return "Red"
                    
                case UIColor.white:
                    return "White"
                    
                case UIColor.yellow:
                    return "Yellow"
                    
                default:
                    break
            }
        }
        var Final = String(IRed)
        Final = Final + ","
        Final = Final + String(IGreen)
        Final = Final + ","
        Final = Final + String(IBlue)
        return Final
    }
    
    // Convert the passed number to a Roman numeral string. If ShowZero is true, a special zero
    // character is returned.
    public func ConvertToRoman(ArabicValue: Int, ShowZero: Bool = false) -> String
    {
        if (ArabicValue < 0 || ArabicValue > 59)
        {
            return ""
        }
        if (ArabicValue == 0 && !ShowZero)
        {
            return ""
        }
        return RomanNumbers[ArabicValue]!
    }
    
    let RomanNumbers: [Int : String] =
    [
        0  : "〇",
        1  : "I",
        2  : "II",
        3  :  "III",
        4  : "IV",
        5  : "V",
        6  : "VI",
        7  : "VII",
        8  : "VIII",
        9  : "IX",
        10 : "X",
        11 : "XI",
        12 : "XII",
        13 : "XIII",
        14 : "XIV",
        15 : "XV",
        16 : "XVI",
        17 : "XVII",
        18 : "XVIII",
        19 : "XIX",
        20 : "XX",
        21 : "XXI",
        22 : "XXII",
        23 : "XXIII",
        24 : "XXIV",
        25 : "XXV",
        26 : "XXVI",
        27 : "XXVII",
        28 : "XXVIII",
        29 : "XXIX",
        30 : "XXX",
        31 : "XXXI",
        32 : "XXXII",
        33 : "XXXIII",
        34 : "XXXIV",
        35 : "XXXV",
        36 : "XXXVI",
        37 : "XXXVII",
        38 : "XXXVIII",
        39 : "XXXIX",
        40 : "XL",
        41 : "XLI",
        42 : "XLII",
        43 : "XLIII",
        44 : "XLIV",
        45 : "XLV",
        46 : "XLVI",
        47 : "XLVII",
        48 : "XLVIII",
        49 : "XLIX",
        50 : "L",
        51 : "LI",
        52 : "LII",
        53 : "LIII",
        54 : "LIV",
        55 : "LV",
        56 : "LVI",
        57 : "LVII",
        58 : "LVIII",
        59 : "LIX"
    ]
}


