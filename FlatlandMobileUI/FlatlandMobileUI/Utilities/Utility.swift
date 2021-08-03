//
//  Utility.swift
//  Utility
//
//  Created by Stuart Rankin on 7/18/21. Adapted from Flatland View.
//

import Foundation
import UIKit
import CoreLocation
import SceneKit

class Utility
{
    /// Return a range enum for the passed earthquake magnitude.
    /// - Parameter For: The magnitude whose range will be returned.
    /// - Returns: Enum from `EarthquakeMagnitudes` that indicates it's range.
    public static func GetMagnitudeRange(For: Double) -> EarthquakeMagnitudes
    {
        let InitialValue = EarthquakeMagnitudes.allCases[0].rawValue
        let Modified = For - InitialValue
        if Modified < 0.0
        {
            return EarthquakeMagnitudes.allCases[0]
        }
        let IModified = Int(Modified)
        if IModified > EarthquakeMagnitudes.allCases.count - 1
        {
            return EarthquakeMagnitudes.allCases.last!
        }
        return EarthquakeMagnitudes.allCases[IModified]
    }
    
    /// Return the width of the string.
    /// - Parameters:
    ///   - TheString: The string to measure.
    ///   - TheFont: The font that will be used to render the string.
    /// - Returns: Width of the string.
    public static func StringWidth(TheString: String, TheFont: UIFont) -> CGFloat
    {
        let FontAttrs = [NSAttributedString.Key.font: TheFont]
        let TextWidth = (TheString as NSString).size(withAttributes: FontAttrs)
        return TextWidth.width
    }
    
    /// Return the height of the string.
    /// - Parameters:
    ///   - TheString: The string to measure.
    ///   - TheFont: The font that will be used to render the string.
    /// - Returns: Height of the string.
    public static func StringHeight(TheString: String, TheFont: UIFont) -> CGFloat
    {
        let FontAttrs = [NSAttributedString.Key.font: TheFont]
        let TextHeight = (TheString as NSString).size(withAttributes: FontAttrs)
        return TextHeight.height
    }
    
    /// Return the width of the string.
    /// - Note: [Calculate width of string](https://stackoverflow.com/questions/1324379/how-to-calculate-the-width-of-a-text-string-of-a-specific-font-and-font-size)
    /// - Parameters:
    ///   - TheString: The string to measure.
    ///   - FontName: The font the string will be rendered in.
    ///   - FontSize: The size of the font.
    /// - Returns: The width of the string.
    public static func StringWidth(TheString: String, FontName: String, FontSize: CGFloat) -> CGFloat
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
    /// - Parameters:
    ///   - TheString: The string to measure.
    ///   - FontName: The font the string will be rendered in.
    ///   - FontSize: The size of the font.
    /// - Returns: The height of the string.
    public static func StringHeight(TheString: String, FontName: String, FontSize: CGFloat) -> CGFloat
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
    public static func RecommendedFontSize(HorizontalConstraint: CGFloat, TheString: String, FontName: String, MinimumFontSize: CGFloat = 12.0,
                                           Margin: CGFloat = 40.0) -> CGFloat
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
    
    public static func RecommendedFontSize(HorizontalConstraint: CGFloat, VerticalConstraint: CGFloat, TheString: String,
                                           FontName: String, MinimumFontSize: CGFloat = 12.0, HorizontalMargin: CGFloat = 40.0,
                                           VerticalMargin: CGFloat = 20.0) -> CGFloat
    {
        var FinalFontName = FontName
#if false
        if !StaticFontNames.contains(FontName)
        {
            FinalFontName = FontName.replacingOccurrences(of: " ", with: "")
        }
#endif
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
    
    /// Round the passed Float as specified.
    /// http://www.globalnerdy.com/2016/01/26/better-to-be-roughly-right-than-precisely-wrong-rounding-numbers-with-swift/
    /// - Parameters:
    ///   - Value: The Float value to round.
    ///   - ToNearest: Where to round the value to.
    /// - Returns: Rounded value.
    public static func RoundTo(_ Value: Float, ToNearest: Float) -> Float
    {
        return roundf(Value / ToNearest) * ToNearest
    }
    
    /// Round the passed Double as specified.
    /// http://www.globalnerdy.com/2016/01/26/better-to-be-roughly-right-than-precisely-wrong-rounding-numbers-with-swift/
    /// - Parameters:
    ///   - Value: The Double value to round.
    ///   - ToNearest: Where to round the value to.
    /// - Returns: Rounded value.
    public static func RoundTo(_ Value: Double, ToNearest: Double) -> Double
    {
        return round(Value / ToNearest) * ToNearest
    }
    
    /// Round the passed CGFloat as specified.
    /// http://www.globalnerdy.com/2016/01/26/better-to-be-roughly-right-than-precisely-wrong-rounding-numbers-with-swift/
    /// - Parameters:
    ///   - Value: The CGFloat value to round.
    ///   - ToNearest: Where to round the value to.
    /// - Returns: Rounded value.
    public static func RoundTo(_ Value: CGFloat, ToNearest: CGFloat) -> CGFloat
    {
        return CGFloat(round(Value / ToNearest) * ToNearest)
    }
    
    /// Truncate a double value to the number of places.
    /// - Parameters:
    ///   - Value: Value to truncate.
    ///   - ToPlaces: Where to truncate the value.
    /// - Returns: Truncated double value.
    public static func Truncate(_ Value: Double, ToPlaces: Int) -> Double
    {
        let D: Decimal = 10.0
        let X = pow(D, ToPlaces)
        let X1: Double = Double(truncating: X as NSNumber)
        let Working: Int = Int(Value * X1)
        let Final: Double = Double(Working) / X1
        return Final
    }
    
    /// Round a double value to the specified number of places.
    /// - Parameters:
    ///   - Value: Value to round.
    ///   - ToPlaces: Number of places to round to.
    /// - Returns: Rounded value.
    public static func Round(_ Value: Double, ToPlaces: Int) -> Double
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
    
    /// Make a string with the elapsed time.
    /// - Parameters:
    ///   - Seconds: Duration of the elapsed time in seconds.
    ///   - AppendSeconds: If true, the numer of seconds is added to the final string.
    /// - Returns: String equivalent of the elapsed time.
    public static func MakePrettyElapsedTime(_ Seconds: Int, AppendSeconds: Bool = true) -> String
    {
        if Seconds < 0
        {
            return ""
        }
        if Seconds == 0
        {
            return "0 seconds"
        }
        if Seconds == 1
        {
            return "1 second"
        }
        if Seconds < 60
        {
            return "\(Seconds) seconds"
        }
        let Hours = Seconds / (60 * 60)
        let Minutes = (Seconds % 3600) / 60
        var Result = ""
        if Hours > 0
        {
            Result = Result + String(describing: Hours) + ":"
        }
        if Minutes > 0
        {
            let Extra = Minutes < 10 ? "0" : ""
            Result = Result + Extra + String(describing: Minutes) + ":"
        }
        let RemainingSeconds = Seconds % 60
        let Extra = RemainingSeconds < 10 ? "0" : ""
        Result = Result + Extra + String(describing: RemainingSeconds)
        return Result
    }
    
    /// Create a Date structure with the passed time.
    /// - Parameters:
    ///   - Hours: Hours value.
    ///   - Minutes: Minutes value.
    ///   - Seconds: Seconds value.
    /// - Returns: Date structure initialized with the passed time.
    public static func MakeTimeFrom(Hours: Int, Minutes: Int, Seconds: Int = 0) -> Date
    {
        var Comp = DateComponents()
        Comp.hour = Hours
        Comp.minute = Minutes
        Comp.second = Seconds
        let Cal = Calendar.current
        let TheTime = Cal.date(from: Comp)
        return TheTime!
    }
    
    /// Convert an integer into a string and pad left with the specified number of zeroes.
    ///
    /// - Parameters:
    ///   - Value: Value to convert to a string.
    ///   - Count: Number of zeroes to pad left.
    /// - Returns: Value converted to a string then padded left with the specified number of zero characters.
    public static func PadLeft(Value: Int, Count: Int) -> String
    {
        var z = String(describing: Value)
        if z.count < Count
        {
            while z.count < Count
            {
                z = "0" + z
            }
        }
        return z
    }
    
    /// Convert a Date structure into a string.
    /// - Parameter Raw: The date to convert into a string.
    /// - Returns: String equivalent of the passed date.
    public static func MakeStringFrom(_ Raw: Date) -> String
    {
        let Cal = Calendar.current
        let Year = Cal.component(.year, from: Raw)
        let Month = Cal.component(.month, from: Raw)
        let Day  = Cal.component(.day, from: Raw)
        let Hour = Cal.component(.hour, from: Raw)
        let Minute = Cal.component(.minute, from: Raw)
        let Second = Cal.component(.second, from: Raw)
        let DatePart = "\(PadLeft(Value: Year, Count: 4))-\(PadLeft(Value: Month, Count: 2))-\(PadLeft(Value: Day, Count: 2)) "
        let TimePart = "\(PadLeft(Value: Hour, Count: 2)):\(PadLeft(Value: Minute, Count: 2)):\(PadLeft(Value: Second, Count: 2))"
        return DatePart + TimePart
    }
    
    /// Convert the passed `Date` into a calendar date to be used for returning Earth time data from NASA.
    /// - Parameter From: The `Date` to convert.
    /// - Returns: String in the format `YYYY-MM-DD`.
    public static func MakeEarthDate(From Raw: Date) -> String
    {
        let Cal = Calendar.current
        let Year = Cal.component(.year, from: Raw)
        let Month = Cal.component(.month, from: Raw)
        let Day  = Cal.component(.day, from: Raw)
        let YearS = "\(Year)"
        var MonthS = "\(Month)"
        if MonthS.count == 1
        {
            MonthS = "0" + MonthS
        }
        var DayS = "\(Day)"
        if DayS.count == 1
        {
            DayS = "0" + DayS
        }
        return "\(YearS)-\(MonthS)-\(DayS)"
    }
    
    /// Given a Date structure, return the date.
    /// - Parameter Raw: Date structure to convert.
    /// - Returns: Date portion of the date as a string.
    public static func MakeDateStringFrom(_ Raw: Date) -> String
    {
        let Cal = Calendar.current
        let Year = Cal.component(.year, from: Raw)
        let Month = Cal.component(.month, from: Raw)
        let Day  = Cal.component(.day, from: Raw)
        let DatePart = "\(PadLeft(Value: Year, Count: 4))-\(PadLeft(Value: Month, Count: 2))-\(PadLeft(Value: Day, Count: 2))"
        return DatePart
    }
    
    /// Given a date structure, return a date in the formate day month year{, weekday}.
    /// - Parameters:
    ///   - Raw: Date structure to convert.
    ///   - AddDay: If true, the day of week is appended to the date.
    /// - Returns: Date portion of the date as a string.
    public static func MakeDateString(_ Raw: Date, AddDay: Bool = true) -> String
    {
        let Cal = Calendar.current
        let Year = Cal.component(.year, from: Raw)
        let Month = Cal.component(.month, from: Raw)
        let Day  = Cal.component(.day, from: Raw)
        var Final = "\(Day) \(EnglishMonths[Month - 1]) \(Year)"
        if AddDay
        {
            let DayOfWeek = Cal.component(.weekday, from: Raw)
            let WeekDay = EnglishWeekDays[DayOfWeek - 1]
            Final = Final + ", \(WeekDay)"
        }
        return Final
    }
    
    /// Convert the passed string into a Date structure. String must be in the format of:
    /// yyyy-mm-dd hh:mm:ss
    /// - Parameter Raw: The string to convert.
    /// - Returns: Date equivalent of the string. nil on error.
    public static func MakeDateFrom(_ Raw: String) -> Date?
    {
        var Components = DateComponents()
        let Parts = Raw.split(separator: " ")
        if Parts.count != 2
        {
            return nil
        }
        
        let DatePart = String(Parts[0])
        let DateParts = DatePart.split(separator: "-")
        Components.year = Int(String(DateParts[0]))
        Components.month = Int(String(DateParts[1]))
        Components.day = Int(String(DateParts[2]))
        
        let TimePart = String(Parts[1])
        let TimeParts = TimePart.split(separator: ":")
        Components.hour = Int(String(TimeParts[0]))
        Components.minute = Int(String(TimeParts[1]))
        if TimeParts.count > 2
        {
            Components.second = Int(String(TimeParts[2]))
        }
        else
        {
            Components.second = 0
        }
        
        let Cal = Calendar.current
        return Cal.date(from: Components)
    }
    
    /// Given a Date structure, return a pretty string with the time.
    /// - Parameters:
    ///   - TheDate: The date structure whose time will be returned in a string.
    ///   - IncludeSeconds: If true, the number of seconds will be included in the string.
    /// - Returns: String representation of the time.
    public static func MakeTimeString(TheDate: Date, IncludeSeconds: Bool = true) -> String
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
    
    /// Return a dictionary of attributes to use to draw stroked text in AttributedString-related views/controls.
    /// - Parameters:
    ///   - Font: The font to use to draw the text.
    ///   - InteriorColor: The color of the text.
    ///   - StrokeColor: The color of the stroke.
    ///   - StrokeThickness: The thickness of the stroke.
    /// - Returns: Dictionary of attributes.
    public static func MakeOutlineTextAttributes(Font: UIFont, InteriorColor: UIColor, StrokeColor: UIColor, StrokeThickness: Int) -> [NSAttributedString.Key : Any]
    {
        return [
            NSAttributedString.Key.strokeColor: StrokeColor,
            NSAttributedString.Key.foregroundColor: InteriorColor,
            NSAttributedString.Key.strokeWidth: -StrokeThickness,
            NSAttributedString.Key.font: Font
        ]
    }
    
    /// Return a dictionary of attributes to use to draw non-stroked text in AttributedString-related views/controls. Explicitly
    /// sets stroke width to 0.
    /// - Parameters:
    ///   - Font: The font to use to draw the text.
    ///   - InteriorColor: The color of the text.
    /// - Returns: Dictionary of attributes.
    public static func MakeTextAttributes(Font: UIFont, InteriorColor: UIColor) -> [NSAttributedString.Key : Any]
    {
        return [
            NSAttributedString.Key.foregroundColor: InteriorColor,
            NSAttributedString.Key.font: Font,
            NSAttributedString.Key.strokeWidth: 0
        ]
    }
    
    /// List of full English month names.
    public static let EnglishMonths = ["January", "February", "March", "April", "May", "June", "July", "August", "September", "October", "November", "December"]
    
    /// List of full English weekday names.
    public static let EnglishWeekDays = ["Sunday", "Monday", "Tuesday", "Wednesday", "Thursday", "Friday", "Saturday"]
    
    /// Return a random integer between 0 and Max - 1.
    /// - Parameter Max: The maximum integer to return.
    /// - Returns: Random integer in specified range.
    public static func RandomInt(Max: UInt32) -> Int
    {
        let R = arc4random_uniform(Max)
        return Int(R)
    }
    
    /// Return a random integer in the specified range.
    /// - Parameters:
    ///   - Low: Low end of the range, inclusive.
    ///   - High: High end of the range, inclusive.
    /// - Returns: Random value in the specified range.
    public static func RandomIntInRange(Low: UInt32, High: UInt32) -> Int
    {
        let Range = High - Low + 1
        let R = arc4random_uniform(Range) + Low
        return Int(R)
    }
    
    /// Wrapper around drand48 that ensures the seed has been set before the first call.
    /// - Returns: Random double from drand48().
    public static func drand48s() -> Double
    {
        if !RandomSeedSet
        {
            RandomSeedSet = true
            let TimeInt = UInt32(Date().timeIntervalSinceReferenceDate)
            srand48(Int(TimeInt))
        }
        return drand48()
    }
    
    /// Holds the random seed was set flag.
    private static var RandomSeedSet = false
    
    /// Return a random CGFloat between 0.0 and Max.
    ///
    /// - Parameter Max: The maximum CGFloat to return.
    /// - Returns: Random CGFloat in the specified range.
    public static func RandomCGFloat(Max: CGFloat) -> CGFloat
    {
        let RD = drand48s()
        let Final = CGFloat(RD) * Max
        return Final
    }
    
    /// Return a random double between 0.0 and Max.
    /// - Parameter Max: The maximum double to return.
    /// - Returns: Random Double in the specified range.
    public static func RandomDouble(Max: Double) -> Double
    {
        return drand48s() * Max
    }
    
    /// Return a random Double in the specified range.
    /// - Parameters:
    ///   - Low: Low end of the range, inclusive.
    ///   - High: High end of the range, inclusive.
    /// - Returns: Random value in the specified range.
    public static func RandomDoubleInRange(Low: Double, High: Double) -> Double
    {
        let Range = High - Low + 1
        let Final = (drand48s() * Range) + Low
        return Final
    }
    
    /// Return a random CGFloat in the specified range. Wrapper around RandomDoubleInRange.
    /// - Parameters:
    ///   - Low: Low end of the range, inclusive.
    ///   - High: High end of the range, inclusive.
    /// - Returns: Random value in the specified range.
    public static func RandomCGFloatInRange(Low: CGFloat, High: CGFloat) -> CGFloat
    {
        let RD = RandomDoubleInRange(Low: Double(Low), High: Double(High))
        return CGFloat(RD)
    }
    
    /// Return a random double between 0.0 and 1.0.
    /// - Returns: Normalized random Double number.
    public static func NormalRandom() -> Double
    {
        return drand48s()
    }
    
    /// Return a random CGFloat between 0.0 and 1.0.
    /// - Returns: Normalized random CGFloat number.
    public static func NormalCGFloat() -> CGFloat
    {
        return CGFloat(drand48s())
    }
    
    /// Returns a random color.
    /// - Returns: Random color.
    public static func RandomColor() -> UIColor
    {
        let RR = NormalCGFloat()
        let RG = NormalCGFloat()
        let RB = NormalCGFloat()
        let Final = UIColor(red: RR, green: RG, blue: RB, alpha: 1.0)
        return Final
    }
    
    /// Returns a random color as a CGColor.
    /// - Returns: Random color as CGColor.
    public static func RandomCGColor() -> CGColor
    {
        return RandomColor().cgColor
    }
    
    /// Returns a random color.
    /// - Parameter RandomAlpha: If true, alpha is randomized. If false, alpha is set to 1.0.
    /// - Returns: Random color.
    public static func RandomColor(RandomAlpha: Bool) -> UIColor
    {
        let RR = NormalCGFloat()
        let RG = NormalCGFloat()
        let RB = NormalCGFloat()
        let RA = RandomAlpha ? NormalCGFloat() : 1.0
        let Final = UIColor(red: RR, green: RG, blue: RB, alpha: RA)
        return Final
    }
    
    /// Returns a random color as a CGColor.
    /// - Parameter RandomAlpha: If true, alpha is randomized. If false, alpha is set to 1.0.
    /// - Returns: Random color as CGColor.
    public static func RandomCGColor(RandomAlpha: Bool) -> CGColor
    {
        return RandomColor(RandomAlpha: RandomAlpha).cgColor
    }
    
    /// Returns a random color.
    /// - Parameter Alpha: The alpha level of the random color.
    /// - Returns: Random color.
    public static func RandomColorWith(Alpha: CGFloat) -> UIColor
    {
        let RR = NormalCGFloat()
        let RG = NormalCGFloat()
        let RB = NormalCGFloat()
        let Final = UIColor(red: RR, green: RG, blue: RB, alpha: Alpha)
        return Final
    }
    
    /// Returns a random color as a CGColor.
    /// - Parameter Alpha: The alpha level of the random color.
    /// - Returns: Random color as CGColor.
    public static func RandomColorWith(Alpha: CGFloat) -> CGColor
    {
        return RandomColorWith(Alpha: Alpha).cgColor
    }
    
    /// Return the source color darkened by the supplied multiplier.
    /// - Parameters:
    ///   - Source: The source color to darken.
    ///   - PercentMultiplier: How to darken the source color.
    /// - Returns: Darkened source color.
    public static func DarkerColor(_ Source: UIColor, PercentMultiplier: CGFloat = 0.8) -> UIColor
    {
        var Hue: CGFloat = 0.0
        var Saturation: CGFloat = 0.0
        var Brightness: CGFloat = 0.0
        var Alpha: CGFloat = 0.0
        Source.getHue(&Hue, saturation: &Saturation, brightness: &Brightness, alpha: &Alpha)
        var NewB = Brightness * PercentMultiplier
        if NewB < 0.0
        {
            NewB = 0.0
        }
        let Final = UIColor(hue: Hue, saturation: Saturation, brightness: NewB, alpha: Alpha)
        return Final
    }
    
    /// Return the source color brightened by the supplied multiplier.
    /// - Parameters:
    ///   - Source: The source color to brighten.
    ///   - PercentMultiplier: How to brighten the source color.
    /// - Returns: Brightened source color.
    public static func BrighterColor(_ Source: UIColor, PercentMultiplier: CGFloat = 1.2) -> UIColor
    {
        var Hue: CGFloat = 0.0
        var Saturation: CGFloat = 0.0
        var Brightness: CGFloat = 0.0
        var Alpha: CGFloat = 0.0
        Source.getHue(&Hue, saturation: &Saturation, brightness: &Brightness, alpha: &Alpha)
        var NewB = Brightness * PercentMultiplier
        if NewB > 1.0
        {
            NewB = 1.0
        }
        let Final = UIColor(hue: Hue, saturation: Saturation, brightness: NewB, alpha: Alpha)
        return Final
    }
    
    /// Change the alpha value of the source color to the supplied alpha value.
    /// - Parameters:
    ///   - Source: Source color.
    ///   - NewAlpha: New alpha value for the color.
    /// - Returns: New color with the supplied alpha.
    public static func ChangeAlpha(_ Source: UIColor, NewAlpha: CGFloat) -> UIColor
    {
        return Source.withAlphaComponent(NewAlpha)
    }
    
    public static func Spaces(_ Count: Int) -> String
    {
        return String(repeating: " ", count: Count)
    }
    
    /// Convert the raw number of seconds in a duration into the number of days, hours, minutes, and seconds in the total number of seconds.
    /// - Parameters:
    ///   - RawSeconds: Seconds to convert.
    ///   - Days: Days in RawSeconds.
    ///   - Hours: Hours in RawSeconds.
    ///   - Minutes: Minutes in RawSeconds.
    ///   - Seconds: Seconds in RawSeconds.
    public static func MakeDurationUnits(RawSeconds: Int, Days: inout Int, Hours: inout Int, Minutes: inout Int, Seconds: inout Int)
    {
        let SecondsInDay = 24 * 60 * 60
        let SecondsInHour = 60 * 60
        let SecondsInMinute = 60
        
        var Working = RawSeconds < 0 ? 0 : RawSeconds
        Days = Working / SecondsInDay
        Working = Working % SecondsInDay
        Hours = Working / SecondsInHour
        Working = Working % SecondsInHour
        Minutes = Working / SecondsInMinute
        Seconds = Working % SecondsInMinute
    }
    
    /// Returns the number of seconds in the passed days, hours, minutes, and seconds.
    /// - Parameters:
    ///   - FromDays: Number of days.
    ///   - FromHours: Number of hours.
    ///   - FromMinutes: Number of minutes.
    ///   - FromSeconds: Number of seconds.
    /// - Returns: Total number of seconds in the passed durations.
    public static func CreateDuration(FromDays: Int, FromHours: Int, FromMinutes: Int, FromSeconds: Int) -> Int
    {
        let SecondsInDay = 24 * 60 * 60
        let SecondsInHour = 60 * 60
        let SecondsInMinute = 60
        
        let Duration = (FromDays * SecondsInDay) + (FromHours * SecondsInHour) + (FromMinutes * SecondsInMinute) + FromSeconds
        return Duration
    }
    
    /// Convert a raw number of seconds into a formatted string with days, hours, minutes and seconds. Leading units of 0 duration
    /// are not included. If 0 is passed in RawSeconds, a string indicating 0 seconds is always returned.
    /// - Parameters:
    ///   - RawSeconds: Number of seconds to convert. Negative values converted to 0.
    ///   - UseShortLabels: Determines if short or long time unit labels are used.
    /// - Returns: String indicating the duration in terms of days, hours, minutes, and seconds.
    public static func DurationFromSeconds(RawSeconds: Int, UseShortLabels: Bool = true) -> String
    {
        let SecondsInDay = 24 * 60 * 60
        let SecondsInHour = 60 * 60
        let SecondsInMinute = 60
        
        var Results: [Int] = [0, 0, 0, 0]
        let ShortMap: [String] =
        [
            "d",
            "h",
            "m",
            "s"
        ]
        let LongMap: [String] =
        [
            "Day",
            "Hour",
            "Minute",
            "Second"
        ]
        var Working = RawSeconds < 0 ? 0 : RawSeconds
        let Days = Working / SecondsInDay
        Working = Working % SecondsInDay
        let Hours = Working / SecondsInHour
        Working = Working % SecondsInHour
        let Minutes = Working / SecondsInMinute
        let Seconds = Working % SecondsInMinute
        Results[0] = Days
        Results[1] = Hours
        Results[2] = Minutes
        Results[3] = Seconds
        
        var FoundNonZero = false
        var Result = ""
        var Index = 0
        for Duration in Results
        {
            if FoundNonZero || Duration != 0
            {
                FoundNonZero = true
                let Plural = Duration == 1 ? "" : "s"
                if UseShortLabels
                {
                    let ShortLabel = String(ShortMap[Index])
                    let stemp = "\(Duration)\(ShortLabel) "
                    Result = Result + stemp
                }
                else
                {
                    let stemp = "\(Duration) \(LongMap[Index])\(Plural) "
                    Result = Result + stemp
                }
            }
            Index = Index + 1
        }
        if Result.isEmpty
        {
            if UseShortLabels
            {
                Result = "0s"
            }
            else
            {
                Result = "0 Seconds"
            }
        }
        
        return Result
    }
    
    private static let LoremIpsumParagraphs =
    [
        "Lorem ipsum dolor sit amet, consectetur adipiscing elit. Nullam elementum consectetur nisl. Curabitur tincidunt orci non metus ullamcorper finibus. Vivamus ornare volutpat congue. Duis enim nulla, congue sed elit non, dignissim malesuada nisl. Quisque sit amet turpis ligula. Maecenas quam risus, sollicitudin sit amet dictum eu, auctor in lacus. Quisque rhoncus at ante in suscipit. Suspendisse efficitur arcu fermentum, lacinia sem non, vulputate arcu.",
        "Praesent placerat pellentesque ex eu tincidunt. Suspendisse ornare turpis et sapien elementum, et aliquet sem condimentum. Quisque erat eros, consectetur in nulla sit amet, interdum mollis tellus. Fusce ac maximus mauris. Sed venenatis feugiat lectus, eget egestas arcu vulputate non. Pellentesque habitant morbi tristique senectus et netus et malesuada fames ac turpis egestas. Curabitur ultricies ipsum et fermentum blandit.",
        "Nulla in facilisis augue. Sed bibendum est eu varius pharetra. Integer pharetra in enim volutpat rhoncus. Praesent neque ipsum, luctus eget sagittis id, consequat vel orci. Morbi ac turpis scelerisque sem blandit dignissim. Donec vehicula sollicitudin neque at blandit. In eu ultrices odio.",
        "Praesent ultricies rhoncus mauris, ut varius dui efficitur et. Nunc cursus lacus quis lorem efficitur, nec iaculis erat faucibus. Phasellus ut arcu in diam rhoncus suscipit. Suspendisse vestibulum purus eget mi elementum bibendum. Mauris sem magna, ullamcorper in dui auctor, rhoncus vulputate metus. Pellentesque neque ante, scelerisque at tincidunt a, varius id eros. Vivamus eleifend fringilla diam, a bibendum metus facilisis ut. In vehicula elementum ante sed dignissim. Donec in lacus condimentum, convallis magna sit amet, porttitor neque. In laoreet nulla purus, a placerat ligula tincidunt at. Orci varius natoque penatibus et magnis dis parturient montes, nascetur ridiculus mus. Vestibulum vehicula auctor lorem at varius.",
        "Aliquam fermentum elit vitae justo vulputate feugiat. Mauris facilisis ultricies mauris nec congue. Nullam mollis lacus et iaculis mattis. Proin consectetur, ligula vel varius varius, lacus nisl venenatis enim, in mollis felis eros bibendum velit. Aenean vitae tempus dolor. Morbi non dui a leo accumsan venenatis dignissim id leo. Nunc tempor sagittis quam, in vulputate ante aliquam et. Nulla mattis sit amet tellus id pretium. Ut interdum lacus a consectetur vulputate.",
        "Pellentesque dictum ipsum sed dolor mattis, nec rutrum odio ultricies. Sed ut varius nunc. In nec ligula sodales, viverra augue vel, sagittis dui. Pellentesque bibendum vitae lectus ultricies viverra. Vestibulum volutpat aliquam lobortis. Sed egestas nisl quam, eu rhoncus magna hendrerit sed. Interdum et malesuada fames ac ante ipsum primis in faucibus. Integer bibendum ligula in pellentesque suscipit. Lorem ipsum dolor sit amet, consectetur adipiscing elit. Nunc pharetra a ex non ornare. Donec sit amet ornare purus. Proin gravida imperdiet ante in porttitor. Nullam ut semper nunc. Ut ullamcorper consequat est nec convallis. In est libero, elementum at est eu, dignissim faucibus odio. Sed dictum, est vel lobortis faucibus, urna leo varius nisi, non imperdiet arcu metus sed nunc.",
        "Proin id sagittis metus. Nam auctor lobortis enim sed scelerisque. Curabitur blandit rutrum ultricies. Morbi laoreet dictum libero, scelerisque eleifend lacus. Nulla varius neque massa, cursus suscipit ligula dignissim id. Aliquam erat volutpat. Sed massa metus, consectetur id ante eu, condimentum dictum quam. Integer posuere erat nulla, nec molestie sem euismod vitae. Donec sit amet dui vel mauris rutrum egestas at eu sem. Nullam id arcu luctus, hendrerit lorem et, posuere nisi. In hac habitasse platea dictumst. Fusce non est sed felis mollis vehicula.",
        "Sed mattis laoreet molestie. Sed consequat in erat nec venenatis. Phasellus ac dui sed erat varius vehicula. Morbi tempus massa nibh, eu scelerisque enim consequat in. Donec lobortis tincidunt sapien nec sodales. Aliquam sit amet dapibus orci. Phasellus venenatis diam tincidunt, mollis velit vitae, gravida lorem. Curabitur efficitur, massa quis rhoncus efficitur, tortor justo dapibus nisi, quis fringilla felis felis id leo. Duis lectus ante, rutrum id felis aliquet, imperdiet volutpat turpis. Quisque lectus leo, elementum vel facilisis id, elementum ac enim. Cras nec lacus a ipsum rutrum blandit. Aliquam aliquam erat id arcu semper, ac viverra dui ultricies. Donec ornare malesuada felis in tincidunt. Duis faucibus porta sem eu hendrerit.",
        "Phasellus sed diam sagittis, efficitur orci nec, fringilla mi. Maecenas id hendrerit dolor. Praesent tincidunt nisl ac augue sollicitudin, in dictum risus ullamcorper. Aliquam luctus libero a ligula scelerisque venenatis. Donec consequat metus tortor, venenatis tristique dolor viverra et. In dignissim diam non elit ultricies, nec consequat sapien maximus. Sed gravida pellentesque tellus id bibendum. Vestibulum rhoncus enim a arcu volutpat lobortis. Aliquam lobortis massa malesuada nibh faucibus, id mollis nunc volutpat. Suspendisse tincidunt, justo ut finibus convallis, lacus metus pretium odio, sed dignissim leo lectus aliquet libero. Suspendisse tincidunt orci et consequat euismod. Vivamus feugiat nunc ut lorem pharetra, vel porttitor sem malesuada. Pellentesque scelerisque porttitor maximus. Lorem ipsum dolor sit amet, consectetur adipiscing elit. Praesent sed metus scelerisque, mattis magna porta, eleifend est.",
        "Nam sed eleifend nunc, at interdum lacus. Praesent pulvinar mauris non urna gravida, eget rhoncus arcu sagittis. Vivamus vitae ante diam. Vestibulum maximus mauris auctor magna molestie blandit. Vivamus eget molestie metus. Aenean nec nunc sit amet leo varius iaculis. Morbi eget nunc condimentum, posuere ipsum vel, porta nibh. Vestibulum orci lectus, laoreet ac quam ac, ornare fringilla orci. Duis dictum tellus mattis nisi imperdiet ultricies. Pellentesque nibh risus, rhoncus a purus vitae, tristique fringilla dolor. Ut ornare lectus consectetur egestas laoreet. Vivamus sodales libero dui, non ornare orci pulvinar fringilla. Sed a sollicitudin massa. Ut at dui congue, mollis velit eu, venenatis leo. Integer sodales eget dui sed bibendum.",
    ]
    
    public static func LoremIpsum(_ Paragraphs: Int) -> String
    {
        var Result: String = ""
        var Count = Paragraphs
        if Count < 1
        {
            Count = 1
        }
        if Count > 10
        {
            Count = 10
        }
        for Index in 0 ..< Count
        {
            Result = Result + LoremIpsumParagraphs[Index]
        }
        return Result
    }
    
    /// Converts a raw hex value (prefixed by one of: "0x", "0X", or "#") into a `UIColor`. **Color order is: rrggbbaa or rrggbb.**
    /// - Note: From code in Fouris.
    /// - Parameter RawString: The raw hex string to convert.
    /// - Returns: Tuple of color channel information.
    public static func ColorChannelsFromRGBA(_ RawString: String) -> (Red: CGFloat, Green: CGFloat, Blue: CGFloat, Alpha: CGFloat)?
    {
        var Working = RawString.trimmingCharacters(in: .whitespacesAndNewlines)
        if Working.isEmpty
        {
            return nil
        }
        if Working.uppercased().starts(with: "0X")
        {
            Working = Working.replacingOccurrences(of: "0x", with: "")
            Working = Working.replacingOccurrences(of: "0X", with: "")
        }
        if Working.starts(with: "#")
        {
            Working = Working.replacingOccurrences(of: "#", with: "")
        }
        switch Working.count
        {
            case 8:
                if let Value = UInt(Working, radix: 16)
                {
                    let Red: CGFloat = CGFloat((Value & 0xff000000) >> 24) / 255.0
                    let Green: CGFloat = CGFloat((Value & 0x00ff0000) >> 16) / 255.0
                    let Blue: CGFloat = CGFloat((Value & 0x0000ff00) >> 8) / 255.0
                    let Alpha: CGFloat = CGFloat((Value & 0x000000ff) >> 0) / 255.0
                    return (Red: Red, Green: Green, Blue: Blue, Alpha: Alpha)
                }
                
            case 6:
                if let Value = UInt(Working, radix: 16)
                {
                    let Red: CGFloat = CGFloat((Value & 0xff0000) >> 16) / 255.0
                    let Green: CGFloat = CGFloat((Value & 0x00ff00) >> 8) / 255.0
                    let Blue: CGFloat = CGFloat((Value & 0x0000ff) >> 0) / 255.0
                    return (Red: Red, Green: Green, Blue: Blue, Alpha: 1.0)
                }
                
            default:
                break
        }
        return nil
    }
    
    /// Converts a raw hex value (prefixed by one of: "0x", "0X", or "#") into an `UIColor`. **Color order is: aarrggbb.**
    /// - Note: From code in Fouris.
    /// - Note: All four channels **must** be included or nil is returned.
    /// - Parameter RawString: The raw hex string to convert.
    /// - Returns: Tuple of color channel information. Nil returned on badly formatted colors.
    public static func ColorChannelsFromARGB(_ RawString: String) -> (Red: CGFloat, Green: CGFloat, Blue: CGFloat, Alpha: CGFloat)?
    {
        var Working = RawString.trimmingCharacters(in: .whitespacesAndNewlines)
        if Working.isEmpty
        {
            return nil
        }
        if Working.uppercased().starts(with: "0X")
        {
            Working = Working.replacingOccurrences(of: "0x", with: "")
            Working = Working.replacingOccurrences(of: "0X", with: "")
        }
        if Working.starts(with: "#")
        {
            Working = Working.replacingOccurrences(of: "#", with: "")
        }
        switch Working.count
        {
            case 8:
                if let Value = UInt(Working, radix: 16)
                {
                    let Alpha: CGFloat = CGFloat((Value & 0xff000000) >> 24) / 255.0
                    let Red: CGFloat = CGFloat((Value & 0x00ff0000) >> 16) / 255.0
                    let Green: CGFloat = CGFloat((Value & 0x0000ff00) >> 8) / 255.0
                    let Blue: CGFloat = CGFloat((Value & 0x000000ff) >> 0) / 255.0
                    return (Red: Red, Green: Green, Blue: Blue, Alpha: Alpha)
                }
                
            default:
                break
        }
        return nil
    }
    
    /// Converts a raw hex value (prefixed by one of: "0x", "0X", or "#") into an `UIColor`. Color order is: rrggbbaa or rrggbb.
    /// - Note: From code in Fouris.
    /// - Parameter RawString: The raw hex string to convert.
    /// - Returns: Color represented by the raw string on success, nil on parse failure.
    public static func ColorFrom(_ RawString: String) -> UIColor?
    {
        if let (Red, Green, Blue, Alpha) = ColorChannelsFromRGBA(RawString)
        {
            return UIColor(red: Red, green: Green, blue: Blue, alpha: Alpha)
        }
        return nil
    }
    
    /// Resizes an UIImage such that the longest dimension of the returned image is `Longest`. If the
    /// image is smaller than `Longest`, it is *not* resized.
    /// - Parameter Image: The image to resize.
    /// - Parameter Longest: The new longest dimension.
    /// - Returns: Resized image. If the longest dimension of the original image is less than `Longest`, the
    ///            original image is returned unchanged.
    public static func ResizeImage(Image: UIImage, Longest: CGFloat) -> UIImage
    {
        let ImageMax = max(Image.size.width, Image.size.height)
        if ImageMax <= Longest
        {
            return Image
        }
        let Ratio = Longest / ImageMax
        let NewSize = CGSize(width: Image.size.width * Ratio, height: Image.size.height * Ratio)
        #if true
        let CgImage = MetalLibrary.AdjustColorSpace(For: Image, ForceSize: NewSize)
        return UIImage(cgImage: CgImage!)
        #else
        NewImage.lockFocus()
        Image.draw(in: CGRect(0, 0, NewSize.width, NewSize.height),
                   from: CGRect(0, 0, Image.size.width, Image.size.height),
                   operation: NSCompositingOperation.sourceOver,
                   fraction: CGFloat(1))
        NewImage.unlockFocus()
        NewImage.size = NewSize
        return NewImage
        #endif
    }
    
    /// Given the passed placemark, create an address string.
    /// - Note: The Apple API that creates the address is throttled to one address a minute (although when
    ///         there is low demand, it is entirely possible to get one a second).
    /// - Parameter From: The placemark from the system.
    /// - Returns: Address constructed from the placemark.
    public static func ConstructAddress(From: CLPlacemark) -> String
    {
        var Address = ""
        if let Name = From.name
        {
            Address.append(Name + "\n")
        }
        if let Country = From.country
        {
            Address.append(Country + " ")
        }
        if let PostCode = From.postalCode
        {
            Address.append(PostCode + " ")
        }
        if let Administrative = From.administrativeArea
        {
            Address.append(Administrative + " ")
        }
        if !Address.isEmpty
        {
            Address.append("\n")
        }
        var AddedLine2 = false
        if let SubAdministrative = From.subAdministrativeArea
        {
            AddedLine2 = true
            Address.append(SubAdministrative + " ")
        }
        if let Locality = From.locality
        {
            AddedLine2 = true
            Address.append(Locality + " ")
        }
        if let SubLocality = From.subLocality
        {
            AddedLine2 = true
            Address.append(SubLocality + " ")
        }
        if AddedLine2
        {
            Address.append("\n")
        }
        if let Thoroughfare = From.thoroughfare
        {
            Address.append(Thoroughfare + " ")
        }
        if let SubThoroughfare = From.subThoroughfare
        {
            Address.append(SubThoroughfare + " ")
        }
        if let TimeZone = From.timeZone
        {
            Address.append(TimeZone.abbreviation()!)
        }
        return Address
    }
    
    /// Create an "opposite" color from the passed color. The general idea is the returned color
    /// will be contrasting enough to show up against the source color.
    /// - Parameter From: The source color used to create an "opposite" color.
    /// - Returns: Color that hopefully constrasts with the passed color.
    public static func OppositeColor(From: UIColor) -> UIColor
    {
        let (H, S, B) = From.HSB
        if B > 0.8
        {
            return UIColor.black
        }
        if B < 0.2
        {
            return UIColor.white
        }
        if S < 0.2
        {
            return UIColor(hue: H, saturation: 1.0, brightness: 1.0 - B, alpha: 1.0)
        }
        let Final = UIColor(hue: 1.0 - H, saturation: S, brightness: 1.0 - B, alpha: 1.0)
        return Final
    }
    
    /// Returns a transparent spherical node with a 3D-extruded sentence on it. Intended to be used
    /// for the about view.
    /// - Parameter Radius: Radius of the sphere with the sentence.
    /// - Parameter Words: Words of the sentence to display.
    /// - Returns: Node that can be used in the about view.
    public static func MakeAboutSentence(Radius: Double, Words: [String]) -> SCNNode
    {
        let NodeShape = SCNSphere(radius: CGFloat(Radius))
        let Node = SCNNode2(geometry: NodeShape)
        Node.position = SCNVector3(0.0, 0.0, 0.0)
        Node.geometry?.firstMaterial?.diffuse.contents = UIColor.clear
        Node.geometry?.firstMaterial?.specular.contents = UIColor.clear
        Node.name = "Hour Node"
        
        let StartAngle = -100
        var Angle = StartAngle
        for Word in Words
        {
            var WorkingAngle: CGFloat = CGFloat(Angle)
            var PreviousEnding: CGFloat = 0.0
            for (_, Letter) in Word.enumerated()
            {
                let Radians = WorkingAngle.Radians
                let HourText = SCNText(string: String(Letter), extrusionDepth: 5.0)
                var LetterColor = UIColor.systemYellow
                var SpecularColor = UIColor.white
                var VerticalOffset: CGFloat = 0.8
                
                if Word == Versioning.ApplicationName
                {
                    HourText.font = UIFont(name: "Avenir-Black", size: 28.0)
                    LetterColor = UIColor.systemRed
                    SpecularColor = UIColor.systemOrange
                }
                else
                {
                    HourText.font = UIFont(name: "Avenir-Heavy", size: 24.0)
                    VerticalOffset = 0.6
                }
                
                var CharWidth: Float = 0
                if Letter == " "
                {
                    CharWidth = 3.5
                }
                else
                {
                    CharWidth = Float(abs(HourText.boundingBox.max.x - HourText.boundingBox.min.x))
                }
                PreviousEnding = CGFloat(CharWidth)
                if Letter == "V"
                {
                    PreviousEnding = CGFloat(12.0)
                }
                if Letter == "l"
                {
                    PreviousEnding = CGFloat(6.0)
                }
                if ["0", "1", "2", "3", "4", "5", "6", "7", "8", "9"].contains(Letter)
                {
                    PreviousEnding = CGFloat(10.0)
                }
                WorkingAngle = WorkingAngle - (PreviousEnding * 0.5)
                HourText.firstMaterial?.diffuse.contents = LetterColor
                HourText.firstMaterial?.specular.contents = SpecularColor
                HourText.flatness = Settings.GetCGFloat(.TextSmoothness, 0.1)
                let X = CGFloat(Radius) * cos(Radians)
                let Z = CGFloat(Radius) * sin(Radians)
                let HourTextNode = SCNNode2(geometry: HourText)
                HourTextNode.scale = SCNVector3(0.07, 0.07, 0.07)
                HourTextNode.position = SCNVector3(X, -VerticalOffset, Z)
                let HourRotation = (90.0 - Double(WorkingAngle) + 00.0).Radians
                HourTextNode.eulerAngles = SCNVector3(0.0, HourRotation, 0.0)
                Node.addChildNode(HourTextNode)
            }
            Angle = Angle + 65
        }
        
        return Node
    }
    
    /// Create an `SCNNode` of a word that floats over a globe.
    /// - Note: Each child node has a name of `LetterNode`.
    /// - Parameter Radius: The radius of the globe.
    /// - Parameter Word: The word to draw.
    /// - Parameter Scale: The scale for the final node.
    /// - Parameter Latitude: The latitude of the word.
    /// - Parameter Longitude: The longitude of the word.
    /// - Parameter Extrusion: Depth of the word.
    /// - Parameter TextColor: The color of the word.
    /// - Returns: `SCNNode` with the word as a 3D object.
    public static func MakeFloatingWord(Radius: Double, Word: String, Scale: CGFloat = 0.07,
                                        Latitude: Double, Longitude: Double,
                                        Extrusion: CGFloat = 1.0,
                                        TextColor: UIColor = UIColor.gray) -> SCNNode
    {
        let WordNode = SCNNode2()
        WordNode.position = SCNVector3(0.0, 0.0, 0.0)
        let WordFont = UIFont.systemFont(ofSize: 24.0)
        let FontAttribute = [NSAttributedString.Key.font: WordFont]
        var CumulativeLetterLocation: CGFloat = 0.0
        for (_, Letter) in Word.enumerated()
        {
            let LetterSize = NSString(string: String(Letter)).size(withAttributes: FontAttribute)
            let LetterShape = SCNText(string: String(Letter), extrusionDepth: Extrusion)
            LetterShape.font = WordFont
            LetterShape.firstMaterial?.diffuse.contents = TextColor
            LetterShape.firstMaterial?.specular.contents = UIColor.white
            let LetterNode = SCNNode2(geometry: LetterShape)
            LetterNode.position = SCNVector3(CumulativeLetterLocation, 0.0, 0.0)
            LetterNode.name = "LetterNode"
            CumulativeLetterLocation = CumulativeLetterLocation + LetterSize.width
            WordNode.addChildNode(LetterNode)
        }
        WordNode.scale = SCNVector3(Scale, Scale, Scale)
        return WordNode
    }
    
    /// Create an `SCNNode2` of a word that floats over a globe.
    /// - Note: Each child node has a name of `LetterNode`.
    /// - Parameter Radius: The radius of the globe.
    /// - Parameter Word: The word to draw.
    /// - Parameter Scale: The scale for the final node.
    /// - Parameter Latitude: The latitude of the word.
    /// - Parameter Longitude: The longitude of the word.
    /// - Parameter Extrusion: Depth of the word.
    /// - Parameter Mask: The light mask. Defaults to `0`.
    /// - Parameter TextFont: The font to use to draw the text. Defaults to `nil`. If not specified
    ///                       of if `nil` is passed, the current system font (of size `24.0`) is
    ///                       used.
    /// - Parameter TextColor: The color of the word.
    /// - Parameter OnSurface: Where the word will be plotted.
    /// - Parameter WithTag: Tag value to assign to the word. If nil, "WordLetterNode" is used.
    /// - Parameter AngleOffset: Offset to apply to letter positions.
    /// - Parameter ShowShadows: Determines if extruded words show shadows.
    /// - Returns: Array with letter nodes.
    public static func MakeFloatingWord(Radius: Double, Word: String, Scale: CGFloat = 0.07,
                                        Latitude: Double, Longitude: Double,
                                        Extrusion: CGFloat = 1.0, Mask: Int = 0,
                                        TextFont: UIFont? = nil,
                                        TextColor: UIColor = UIColor.gray,
                                        OnSurface: SCNNode, WithTag: String? = nil,
                                        AngleOffset: Double = 0.0,
                                        ShowShadows: Bool = true) -> [SCNNode2]
    {
        var WordFont: UIFont = UIFont()
        if let SomeFont = TextFont
        {
            WordFont = SomeFont
        }
        else
        {
            WordFont = UIFont.systemFont(ofSize: 24.0)
        }
        var LetterNodes = [SCNNode2]()
        let FontAttribute = [NSAttributedString.Key.font: WordFont]
        var CumulativeLetterLocation: CGFloat = CGFloat(Longitude + AngleOffset)
        let EqCircumference = 2.0 * Radius * Double.pi
        for (_, Letter) in Word.enumerated()
        {
            let LetterSize = NSString(string: String(Letter)).size(withAttributes: FontAttribute)
            let LetterShape = SCNText(string: String(Letter), extrusionDepth: Extrusion)
            LetterShape.font = WordFont
            LetterShape.firstMaterial?.diffuse.contents = TextColor
            LetterShape.firstMaterial?.specular.contents = UIColor.white
            let LetterNode = SCNNode2(geometry: LetterShape)
            LetterNode.IsTextNode = true
            LetterNode.categoryBitMask = Mask
            LetterNode.scale = SCNVector3(Scale, Scale, Scale)
            LetterNode.castsShadow = ShowShadows
            if let Tag = WithTag
            {
                LetterNode.name = Tag
            }
            else
            {
                LetterNode.name = "WordLetterNode"
            }
            let (X, Y, Z) = Geometry.ToECEF(Latitude, Double(CumulativeLetterLocation),
                                            LatitudeOffset: -1.5, LongitudeOffset: -0.5,
                                            Radius: Radius)
            LetterNode.position = SCNVector3(X, Y, Z)
            let YRotation = -Latitude
            let XRotation = Double(CumulativeLetterLocation)
            let ZRotation = 0.0
            LetterNode.eulerAngles = SCNVector3(YRotation.Radians, XRotation.Radians, ZRotation.Radians)
            OnSurface.addChildNode(LetterNode)
#if true
            var AngleAdjustment = Double(LetterSize.width) / EqCircumference
            AngleAdjustment = AngleAdjustment * 10.0
            CumulativeLetterLocation = CumulativeLetterLocation + CGFloat(AngleAdjustment)
#else
            //http://mathforum.org/library/drmath/view/54158.html
            let Circumference = cos(EqCircumference.Radians)
            var AngleAdjustment = Double(LetterSize.width) / Circumference
            AngleAdjustment = AngleAdjustment * 10.0
            CumulativeLetterLocation = CumulativeLetterLocation + CGFloat(AngleAdjustment)
#endif
            LetterNodes.append(LetterNode)
        }
        return LetterNodes
    }
    
    /// Create a text node of a word that floats over a globe.
    /// - Note: Each child node has the name of `WordLetterNode`.
    /// - Parameters:
    ///   - Radius: The radius of the globe.
    ///   - Word: The word to draw.
    ///   - Scale: The scale for the final node. Defaults to `0.07`.
    ///   - SpacingConstant: The constant used to help control spacing between letters. Defaults to `30.0`.
    ///   - Latitude: The latitude of the word.
    ///   - Longitude: the longitude of the word.
    ///   - LatitudeOffset: Latitude offset value. Defaults to `-1.0`.
    ///   - LongitudeOffset: Longitude offet value. Defaults to `-0.5`.
    ///   - Extrusion: Extrusion depth of each character.
    ///   - Mask: Lighting mask to apply. Defaults to `nil`.
    ///   - TextFont: Font to use to render the text.
    ///   - DayAttributes: Attributes for day time.
    ///   - NightAttributes: Attributes for night time.
    ///   - WithTag: If present, the node's name is assigned this value. Defaults to `nil`.
    ///   - Flatness: Flatness/smoothness level of the rendered text. Defaults to `0.1`.
    ///   - Chamfer: Chamfer radius. Defaults to `0.0`.
    /// - Returns: An array of nodes, one node per character, spaced correctly.
    public static func MakeFloatingWord3(Radius: Double,
                                         Word: String,
                                         Scale: CGFloat = 0.07,
                                         SpacingConstant: Double = 30.0,
                                         Latitude: Double,
                                         Longitude: Double,
                                         LatitudeOffset: Double = -1.0,
                                         LongitudeOffset: Double = -0.5,
                                         Extrusion: CGFloat = 1.0,
                                         Mask: Int? = nil,
                                         TextFont: UIFont? = nil,
                                         DayAttributes: TimeAttributes,
                                         NightAttributes: TimeAttributes,
                                         WithTag: String? = nil,
                                         Flatness: CGFloat = 0.1,
                                         Chamfer: CGFloat = 0.0) -> [SCNNode2]
    {
        var WordFont: UIFont = UIFont()
        if let SomeFont = TextFont
        {
            WordFont = SomeFont
        }
        else
        {
            WordFont = UIFont.systemFont(ofSize: 24.0)
        }
        var LetterNodes = [SCNNode2]()
        let FontAttribute = [NSAttributedString.Key.font: WordFont]
        var CumulativeLetterLocation: CGFloat = CGFloat(Longitude)
        let EqCircumference = 2.0 * Radius * Double.pi
        for (_, Letter) in Word.enumerated()
        {
            let LetterSize = NSString(string: String(Letter)).size(withAttributes: FontAttribute)
            let LetterShape = SCNText(string: String(Letter), extrusionDepth: Extrusion)
            LetterShape.flatness = 0.1
            LetterShape.font = WordFont
            LetterShape.chamferRadius = Chamfer
            
            let LetterNode = SCNNode2(geometry: LetterShape)
            LetterNode.SetLocation(Latitude, Longitude)
            DayAttributes.ApplyTo(LetterNode)
            NightAttributes.ApplyTo(LetterNode)
            LetterNode.SetDaylightState()
            
            if let LightMask = Mask
            {
                LetterNode.categoryBitMask = LightMask
            }
            LetterNode.scale = SCNVector3(Scale)
            if let Tag = WithTag
            {
                LetterNode.name = Tag
            }
            else
            {
                LetterNode.name = "WordLetterNode"
            }
            let (X, Y, Z) = Geometry.ToECEF(Latitude, Double(CumulativeLetterLocation),
                                            LatitudeOffset: LatitudeOffset, LongitudeOffset: LongitudeOffset,
                                            Radius: Radius)
            LetterNode.position = SCNVector3(X, Y, Z)
            let YRotation = -Latitude
            let XRotation = Double(CumulativeLetterLocation)
            let ZRotation = 0.0
            LetterNode.eulerAngles = SCNVector3(YRotation.Radians, XRotation.Radians, ZRotation.Radians)
            var AngleAdjustment = Double(LetterSize.width) / EqCircumference
            AngleAdjustment = AngleAdjustment * SpacingConstant
            CumulativeLetterLocation = CumulativeLetterLocation + CGFloat(AngleAdjustment)
            LetterNodes.append(LetterNode)
        }
        
        return LetterNodes
    }
    
    /// Create a text node of a word that floats over a globe.
    /// - Note: Each child node has the name of `WordLetterNode`.
    /// - Parameters:
    ///   - Radius: The radius of the globe.
    ///   - Word: The word to draw.
    ///   - Scale: The scale for the final node. Defaults to `0.07`.
    ///   - SpacingConstant: The constant used to help control spacing between letters. Defaults to `30.0`.
    ///   - Latitude: The latitude of the word.
    ///   - Longitude: the longitude of the word.
    ///   - LatitudeOffset: Latitude offset value. Defaults to `-1.0`.
    ///   - LongitudeOffset: Longitude offet value. Defaults to `-0.5`.
    ///   - Extrusion: Extrusion depth of each character.
    ///   - Mask: Lighting mask to apply. Defaults to `nil`.
    ///   - TextFont: Font to use to render the text.
    ///   - TextColor: Color the top and bottom (and sides if `SideColor` is nil) of the text. Defaults to
    ///                `.gray`.
    ///   - SideColor: Color of the side of the text. Defaults to `nil` meaning `TextColor` is applied to the
    ///                entire node surface.
    ///   - TextSpecular: Specular color of the text. Defaults to `.white`.
    ///   - IsMetallic: If true, the text is rendered to simulate a metallic surface.
    ///   - WithTag: If present, the node's name is assigned this value. Defaults to `nil`.
    ///   - Flatness: Flatness/smoothness level of the rendered text. Defaults to `0.1`.
    /// - Returns: An array of nodes, one node per character, spaced correctly.
    public static func MakeFloatingWord2(Radius: Double, Word: String, Scale: CGFloat = 0.07,
                                         SpacingConstant: Double = 30.0,
                                         Latitude: Double, Longitude: Double,
                                         LatitudeOffset: Double = -1.0, LongitudeOffset: Double = -0.5,
                                         Extrusion: CGFloat = 1.0, Mask: Int? = nil,
                                         TextFont: UIFont? = nil,
                                         TextColor: UIColor = UIColor.gray,
                                         SideColor: UIColor? = nil,
                                         TextSpecular: UIColor = UIColor.white,
                                         IsMetallic: Bool = false,
                                         WithTag: String? = nil,
                                         Flatness: CGFloat = 0.1) -> [SCNNode2]
    {
        var WordFont: UIFont = UIFont()
        if let SomeFont = TextFont
        {
            WordFont = SomeFont
        }
        else
        {
            WordFont = UIFont.systemFont(ofSize: 24.0)
        }
        var LetterNodes = [SCNNode2]()
        let FontAttribute = [NSAttributedString.Key.font: WordFont]
        var CumulativeLetterLocation: CGFloat = CGFloat(Longitude)
        let EqCircumference = 2.0 * Radius * Double.pi
        for (_, Letter) in Word.enumerated()
        {
            let LetterSize = NSString(string: String(Letter)).size(withAttributes: FontAttribute)
            let LetterShape = SCNText(string: String(Letter), extrusionDepth: Extrusion)
            LetterShape.flatness = 0.1
            LetterShape.font = WordFont
            
            //LetterShape.firstMaterial?.diffuse.contents = TextColor
            //LetterShape.firstMaterial?.specular.contents = TextSpecular
            if IsMetallic
            {
                LetterShape.firstMaterial?.lightingModel = .physicallyBased
            }
            let LetterNode = SCNNode2(geometry: LetterShape)
            
            let Material1 = SCNMaterial()
            Material1.diffuse.contents = TextColor
            Material1.specular.contents = TextSpecular
            LetterNode.geometry?.insertMaterial(Material1, at: 0)
            if let Side = SideColor
            {
                let Material2 = SCNMaterial()
                Material2.diffuse.contents = Side
                //Material2.specular.contents = TextSpecular
                LetterNode.geometry?.insertMaterial(Material2, at: 1)
            }
            
            if let LightMask = Mask
            {
                LetterNode.categoryBitMask = LightMask
            }
            LetterNode.scale = SCNVector3(Scale, Scale, Scale)
            if let Tag = WithTag
            {
                LetterNode.name = Tag
            }
            else
            {
                LetterNode.name = "WordLetterNode"
            }
            let (X, Y, Z) = Geometry.ToECEF(Latitude, Double(CumulativeLetterLocation),
                                            LatitudeOffset: LatitudeOffset, LongitudeOffset: LongitudeOffset,
                                            Radius: Radius)
            LetterNode.position = SCNVector3(X, Y, Z)
            let YRotation = -Latitude
            let XRotation = Double(CumulativeLetterLocation)
            let ZRotation = 0.0
            LetterNode.eulerAngles = SCNVector3(YRotation.Radians, XRotation.Radians, ZRotation.Radians)
            var AngleAdjustment = Double(LetterSize.width) / EqCircumference
            AngleAdjustment = AngleAdjustment * SpacingConstant
            CumulativeLetterLocation = CumulativeLetterLocation + CGFloat(AngleAdjustment)
            LetterNodes.append(LetterNode)
        }
        
        return LetterNodes
    }
    
    public static func MakeRadialWord(Radius: Double,
                                      Word: String,
                                      StartAt: Double = 90.0,
                                      Scale: CGFloat = 0.07,
                                      SpacingConstant: Double = 30.0,
                                      Extrusion: Double = 1.0,
                                      Mask: Int? = nil,
                                      TextFont: UIFont? = nil,
                                      TextColor: UIColor = UIColor.gray,
                                      TextSpecular: UIColor = UIColor.white,
                                      IsMetallic: Bool = false,
                                      WithTag: String? = nil,
                                      Flatness: CGFloat = 0.1) -> SCNNode
    {
        let FinalNode = SCNNode2()
        FinalNode.position = SCNVector3(0.0, 0.0, 0.0)
        var WordFont: UIFont = UIFont()
        if let SomeFont = TextFont
        {
            WordFont = SomeFont
        }
        else
        {
            WordFont = UIFont.systemFont(ofSize: 24.0)
        }
        let FontAttribute = [NSAttributedString.Key.font: WordFont]
        var CumulativeLetterLocation: CGFloat = CGFloat(StartAt)
        let EqCircumference = 2.0 * Radius * Double.pi
        for (_, Letter) in Word.enumerated()
        {
            let LetterSize = NSString(string: String(Letter)).size(withAttributes: FontAttribute)
            let LetterShape = SCNText(string: String(Letter), extrusionDepth: CGFloat(Extrusion))
            LetterShape.flatness = Flatness
            LetterShape.font = WordFont
            LetterShape.firstMaterial?.diffuse.contents = TextColor
            LetterShape.firstMaterial?.specular.contents = TextSpecular
            if IsMetallic
            {
                LetterShape.firstMaterial?.lightingModel = .physicallyBased
            }
            let LetterNode = SCNNode2(geometry: LetterShape)
            if let LightMask = Mask
            {
                LetterNode.categoryBitMask = LightMask
            }
            LetterNode.scale = SCNVector3(Scale, Scale, Scale)
            if let Tag = WithTag
            {
                LetterNode.name = Tag
            }
            else
            {
                LetterNode.name = "WordLetterNode"
            }
            
            var AngleAdjustment = Double(LetterSize.width) / EqCircumference
            
#if true
            let (X, Y, _) = Geometry.ToECEF(0.0, Double(CumulativeLetterLocation), Radius: Radius)
#else
            let X = Radius * Double(cos(CumulativeLetterLocation.Radians))
            let Y = Radius * Double(sin(CumulativeLetterLocation.Radians))
#endif
            LetterNode.position = SCNVector3(X, Y, 1.0)
            let Yaw = (CumulativeLetterLocation) - 90
            LetterNode.eulerAngles = SCNVector3(0.0, 0.0, Yaw.Radians)
            
            AngleAdjustment = AngleAdjustment * SpacingConstant
            CumulativeLetterLocation = CumulativeLetterLocation + CGFloat(AngleAdjustment)
            FinalNode.addChildNode(LetterNode)
        }
        
        let cyl = SCNCylinder(radius: CGFloat(Radius * 1.0), height: CGFloat(Extrusion))
        let cyln = SCNNode2(geometry: cyl)
        cyln.position = SCNVector3(0.0, 0.0, 0.0)
        cyln.eulerAngles = SCNVector3(90.0.Radians, 0.0, 0.0)
        cyl.firstMaterial?.diffuse.contents = UIColor.systemYellow
        //FinalNode.addChildNode(cyln)
        return FinalNode
    }
    
    /// Create an `SCNNode` of a word that floats over a globe.
    /// - Note: Each child node has a name of `LetterNode`.
    /// - Parameter Radius: The radius of the globe.
    /// - Parameter Word: The word to draw.
    /// - Parameter Scale: The scale for the final node.
    /// - Parameter SpacingConstant: The constant used to help control spacing between letters.
    /// - Parameter Latitude: The latitude of the word.
    /// - Parameter Longitude: The longitude of the word.
    /// - Parameter Extrusion: Depth of the word.
    /// - Parameter Mask: The light mask. Defaults to nil.
    /// - Parameter TextFont: The font to use to draw the text. Defaults to `nil`. If not specified
    ///                       of if `nil` is passed, the current system font (of size `24.0`) is
    ///                       used.
    /// - Parameter TextColor: The color of the word.
    /// - Parameter WithTag: Tag value to assign to the word. If nil, "WordLetterNode" is used.
    /// - Parameter Flatness: The flatness value that determines the smoothness of the letters. Defaults
    ///                       to 0.1.
    /// - Parameter RotationalOffset: Multiplier to the width of the letter used to adjust for some strange
    ///                               rotational value. This value helps to offset the unexpected rotational
    ///                               value.
    /// - Returns: `SCNNode` that contains all of the letters.
    public static func MakeFloatingWord2D(Radius: Double,
                                          Word: String,
                                          Scale: CGFloat = 0.07,
                                          SpacingConstant: Double = 30.0,
                                          Latitude: Double, Longitude: Double,
                                          LatitudeOffset: Double = -1.0,
                                          LongitudeOffset: Double = -0.5,
                                          Extrusion: CGFloat = 1.0,
                                          Mask: Int? = nil,
                                          TextFont: UIFont? = nil,
                                          TextColor: UIColor = UIColor.gray,
                                          TextSpecular: UIColor = UIColor.white,
                                          IsMetallic: Bool = false,
                                          WithTag: String? = nil,
                                          Flatness: CGFloat = 0.1,
                                          RotationalOffset: Double = 1.0) -> SCNNode2
    {
        let FinalNode = SCNNode2()
        FinalNode.position = SCNVector3(0.0, 0.0, 0.0)
        var WordFont: UIFont = UIFont()
        if let SomeFont = TextFont
        {
            WordFont = SomeFont
        }
        else
        {
            WordFont = UIFont.systemFont(ofSize: 24.0)
        }
        let FontAttribute = [NSAttributedString.Key.font: WordFont]
        var CumulativeLetterLocation: CGFloat = CGFloat(Longitude)
        let EqCircumference = 2.0 * Radius * Double.pi
        for (_, Letter) in Word.enumerated()
        {
            let LetterSize = NSString(string: String(Letter)).size(withAttributes: FontAttribute)
            let LetterShape = SCNText(string: String(Letter), extrusionDepth: Extrusion)
            LetterShape.flatness = Flatness
            LetterShape.font = WordFont
            LetterShape.firstMaterial?.diffuse.contents = TextColor
            LetterShape.firstMaterial?.specular.contents = TextSpecular
            if IsMetallic
            {
                LetterShape.firstMaterial?.lightingModel = .physicallyBased
            }
            let LetterNode = SCNNode2(geometry: LetterShape)
            if let LightMask = Mask
            {
                LetterNode.categoryBitMask = LightMask
            }
            LetterNode.scale = SCNVector3(Scale, Scale, Scale)
            if let Tag = WithTag
            {
                LetterNode.name = Tag
            }
            else
            {
                LetterNode.name = "WordLetterNode"
            }
            let (X, Y, Z) = Geometry.ToECEF(Latitude,
                                            Double(CumulativeLetterLocation),
                                            LatitudeOffset: LatitudeOffset,
                                            LongitudeOffset: LongitudeOffset,
                                            Radius: Radius)
            LetterNode.position = SCNVector3(X, Y, Z)
            let XRotation = -Latitude
            let YRotation = Double(CumulativeLetterLocation)
            let ZRotation = 0.0
            LetterNode.eulerAngles = SCNVector3(XRotation.Radians, YRotation.Radians, ZRotation.Radians)
            LetterNode.SourceAngle = Double(CumulativeLetterLocation) + Double(LetterSize.width) * RotationalOffset
            LetterNode.AuxiliaryTag = String(Letter)
            var AngleAdjustment = Double(LetterSize.width) / EqCircumference
            AngleAdjustment = AngleAdjustment * SpacingConstant
            CumulativeLetterLocation = CumulativeLetterLocation + CGFloat(AngleAdjustment)
            FinalNode.addChildNode(LetterNode)
        }
        FinalNode.eulerAngles = SCNVector3(90.0.Radians, 0.0.Radians, 0.0.Radians)
        
#if false
        // Used for debugging.
        let cyl = SCNCylinder(radius: CGFloat(Radius * 0.9), height: CGFloat(Extrusion))
        let cyln = SCNNode2(geometry: cyl)
        cyl.firstMaterial?.diffuse.contents = UIColor.systemYellow
        FinalNode.addChildNode(cyln)
#endif
        
        return FinalNode
    }
    
    /// Create an `SCNNode` of a word that floats over a globe.
    /// - Note: Each child node has a name of `LetterNode`.
    /// - TODO: Have the text follow the curve of the globe.
    /// - Parameter Radius: The radius of the globe.
    /// - Parameter Word: The word to draw.
    /// - Parameter Scale: The scale for the final node.
    /// - Parameter Latitude: The latitude of the word.
    /// - Parameter Longitude: The longitude of the word.
    /// - Parameter Extrusion: Depth of the word.
    /// - Parameter Mask: The light mask. Defaults to `0`.
    /// - Parameter TextFont: The font to use to draw the text. Defaults to `nil`. If not specified
    ///                       of if `nil` is passed, the current system font (of size `24.0`) is
    ///                       used.
    /// - Parameter TextColor: The color of the word.
    /// - Parameter WithTag: Tag value to assign to the word. If nil, "WordLetterNode" is used.
    public static func MakeFloatingWord(Radius: Double, Word: String, Scale: CGFloat = 0.07,
                                        Latitude: Double, Longitude: Double,
                                        Extrusion: CGFloat = 1.0, Mask: Int = 0,
                                        TextFont: UIFont? = nil,
                                        TextColor: UIColor = UIColor.gray,
                                        WithTag: String? = nil) -> SCNNode
    {
        var WordFont: UIFont = UIFont()
        if let SomeFont = TextFont
        {
            WordFont = SomeFont
        }
        else
        {
            WordFont = UIFont.systemFont(ofSize: 24.0)
        }
        let FontAttribute = [NSAttributedString.Key.font: WordFont]
        var CumulativeLetterLocation: CGFloat = CGFloat(Longitude)
        let EqCircumference = 2.0 * Radius * Double.pi
        let FinalNode = SCNNode2()
        for (_, Letter) in Word.enumerated()
        {
            let LetterSize = NSString(string: String(Letter)).size(withAttributes: FontAttribute)
            let LetterShape = SCNText(string: String(Letter), extrusionDepth: Extrusion)
            LetterShape.font = WordFont
            LetterShape.firstMaterial?.diffuse.contents = TextColor
            LetterShape.firstMaterial?.specular.contents = UIColor.white
            let LetterNode = SCNNode2(geometry: LetterShape)
            LetterNode.categoryBitMask = Mask
            LetterNode.scale = SCNVector3(Scale, Scale, Scale)
            if let Tag = WithTag
            {
                LetterNode.name = Tag
            }
            else
            {
                LetterNode.name = "WordLetterNode"
            }
            let (X, Y, Z) = Geometry.ToECEF(Latitude, Double(CumulativeLetterLocation),
                                            LatitudeOffset: -1.0, LongitudeOffset: -0.5,
                                            Radius: Radius)
            LetterNode.position = SCNVector3(X, Y, Z)
            let YRotation = -Latitude
            let XRotation = Double(CumulativeLetterLocation)
            let ZRotation = 0.0
            LetterNode.eulerAngles = SCNVector3(YRotation.Radians, XRotation.Radians, ZRotation.Radians)
            FinalNode.addChildNode(LetterNode)
            var AngleAdjustment = Double(LetterSize.width) / EqCircumference
            AngleAdjustment = AngleAdjustment * 10.0
            CumulativeLetterLocation = CumulativeLetterLocation + CGFloat(AngleAdjustment)
        }
        return FinalNode
    }
    
    /// Returns all of the cases in the passed enum type.
    /// - Parameter EnumType: The enum type whose cases will be returned.
    /// - Returns: Array of case values in the passed enum type.
    public static func EnumCases<T: RawRepresentable & CaseIterable>(EnumType: T.Type) -> [String] where T.RawValue == String
    {
        var CaseList = [String]()
        for SomeCase in EnumType.allCases
        {
            CaseList.append("\(SomeCase)")
        }
        return CaseList
    }
    
    /// Given a date, return a mask image for a flat map.
    /// - Parameter From: The date for the night mask.
    /// - Parameter IsRectangular: If true, the name returned will be for rectangular night masks.
    /// - Returns: Name of the night mask image file.
    public static func MakeNightMaskName(From: Date, IsRectangular: Bool = false) -> String
    {
        let Day = Calendar.current.component(.day, from: From)
        let Month = Calendar.current.component(.month, from: From) - 1
        var MonthName = ["Jan", "Feb", "Mar", "Apr", "May", "Jun", "Jul", "Aug", "Sep", "Oct", "Nov", "Dec"][Month]
        if IsRectangular
        {
            MonthName = MonthName + "a"
        }
        var Prefix = ""
        if IsRectangular
        {
            Prefix = "Flat_"
        }
        else
        {
            if Settings.GetEnum(ForKey: .ViewType, EnumType: ViewTypes.self, Default: .FlatSouthCenter) == .FlatNorthCenter
            {
                Prefix = ""
            }
            else
            {
                Prefix = "South_"
            }
        }
        return "\(Prefix)\(Day)_\(MonthName)"
    }
    
    /// Get a night mask image for a flat map for the specified date.
    /// - Parameter ForDate: The date of the night mask.
    /// - Returns: Image for the passed date (and flat map orientation). Nil returned on error.
    public static func GetNightMask(ForDate: Date) -> UIImage?
    {
        let AlphaLevels: [NightDarknesses: CGFloat] =
        [
            .VeryLight: 0.25,
            .Light: 0.4,
            .Dark: 0.6,
            .VeryDark: 0.75
        ]
        let ImageName = MakeNightMaskName(From: ForDate)
        let DarkLevel = Settings.GetEnum(ForKey: .NightDarkness, EnumType: NightDarknesses.self, Default: .Light)
        let MaskAlpha = AlphaLevels[DarkLevel]!
        let MaskImage = UIImage(named: ImageName)!
        let Final = MaskImage.Alpha(CGFloat(MaskAlpha))
        return Final
    }
    
    /// Get a night mask image for a flat map for the specified date. This is for rectangular night masks.
    /// - Parameter ForDate: The date of the night mask.
    /// - Returns: Image for the passed date (and flat map orientation). Nil returned on error.
    public static func GetRectangularNightMask(ForDate: Date) -> UIImage?
    {
        let AlphaLevels: [NightDarknesses: CGFloat] =
        [
            .VeryLight: 0.25,
            .Light: 0.4,
            .Dark: 0.6,
            .VeryDark: 0.75
        ]
        let ImageName = MakeNightMaskName(From: ForDate, IsRectangular: true)
        let DarkLevel = Settings.GetEnum(ForKey: .NightDarkness, EnumType: NightDarknesses.self, Default: .Light)
        let MaskAlpha = AlphaLevels[DarkLevel]!
        let MaskImage = UIImage(named: ImageName)!
        let Final = MaskImage.Alpha(CGFloat(MaskAlpha))
        return Final
    }
    
    /// Returns a geographical coordinate as a pretty string.
    /// - Parameter Latitude: The latitude of the coordinate.
    /// - Parameter Longitude: The longitude of the coordinate.
    /// - Parameter Separator: The separator string between the two parts of the
    ///                        coordinate. Defaults to `,`.
    /// - Parameter Precision: The precision of the coordinates when converted to strings.
    /// - Returns: A string with the `Latitude` and `Longitude` prettified.
    public static func PrettyCoordinates(_ Latitude: Double, _ Longitude: Double,
                                         Separator: String = ",", Precision: Int = 4) -> String
    {
        let LatS = PrettyLatitude(Latitude, Precision: Precision)
        let LonS = PrettyLongitude(Longitude, Precision: Precision)
        return "\(LatS)\(Separator)\(LonS)"
    }
    
    /// Returns a pretty latitude value. "Pretty" is defined as a rounded off number
    /// with a north or south indicated appended as appropriate. (0.0 is considered
    /// north).
    /// - Parameter Raw: The raw latitude to convert.
    /// - Parameter Precision: The precision of the coordinates when converted to strings.
    /// - Returns: A string version of the passed latitude.
    public static func PrettyLatitude(_ Raw: Double, Precision: Int = 4) -> String
    {
        let Lat = Raw.RoundedTo(Precision)
        let LatS = Lat < 0.0 ? "\(abs(Lat))S" : "\(Lat)N"
        return LatS
    }
    
    /// Returns a pretty longitude value. "Pretty" is defined as a rounded off number
    /// with a east or west indicated appended as appropriate. (0.0 is considered
    /// east).
    /// - Parameter Raw: The raw longitude to convert.
    /// - Parameter Precision: The precision of the coordinates when converted to strings.
    /// - Returns: A string version of the passed longitude.
    public static func PrettyLongitude(_ Raw: Double, Precision: Int = 4) -> String
    {
        let Lon = Raw.RoundedTo(Precision)
        let LonS = Lon < 0.0 ? "\(abs(Lon))W" : "\(Lon)E"
        return LonS
    }
    
    /// Returns the latitude and longitude from a string with the latitude and longitude in
    /// string format separated by a space.
    /// - Parameter Pretty: The string to convert to the latitude and longitude. Individual
    ///                     coordinate components may have suffixes ("N" or "S" for latitude
    ///                     or "E" or "W" for longitude) or be negative. Invalidly formatted
    ///                     strings result in a nil return value.
    /// - Returns: Tuple with the latitude and longitude on success, nil if the source was
    ///            not formatted correctly.
    public static func PrettyCoordinateToActual(_ Pretty: String) -> (Latitude: Double, Longitude: Double)?
    {
        let Parts = Pretty.split(separator: " ", omittingEmptySubsequences: true)
        if Parts.count != 2
        {
            return nil
        }
        var LatS = String(Parts[0]).lowercased()
        var LonS = String(Parts[1]).lowercased()
        var LatMultiplier = 1.0
        if LatS.contains("n")
        {
            LatS = LatS.replacingOccurrences(of: "n", with: "")
        }
        if LatS.contains("s")
        {
            LatS = LatS.replacingOccurrences(of: "s", with: "")
            LatMultiplier = -1.0
        }
        guard var FinalLat = Double(LatS) else
        {
            return nil
        }
        FinalLat = FinalLat * LatMultiplier
        var LonMultiplier = 1.0
        if LonS.contains("e")
        {
            LonS = LonS.replacingOccurrences(of: "e", with: "")
        }
        if LonS.contains("w")
        {
            LonS = LonS.replacingOccurrences(of: "w", with: "")
            LonMultiplier = -1.0
        }
        guard var FinalLon = Double(LonS) else
        {
            return nil
        }
        FinalLon = FinalLon * LonMultiplier
        return (FinalLat, FinalLon)
    }
    
    /// Converts the delta between the two values into a time duration in the form of
    /// HH:MM:SS.
    /// - Note: Both `Seconds1` and `Seconds2` are converted to integers before processing.
    /// - Parameter Seconds1: First seconds value (assumed to be an absolute time but need
    ///                       not be).
    /// - Parameter Seconds2: Second seconds value (assumed to be an absolute time but need
    ///                       not be).
    /// - Returns: String in the form of `HH:MM:SS` where `HH` is unbounded (eg, may be a very
    ///            large number).
    public static func DurationBetween(Seconds1: Double, Seconds2: Double) -> String
    {
        let Delta = abs(Int(Seconds1) - Int(Seconds2))
        let HourCount = Delta / (60 * 60)
        let Remainder = Delta % (60 * 60)
        let MinuteCount = Remainder / 60
        let SecondCount = Remainder % 60
        let HourS = "\(HourCount)"
        var MinuteS = "\(MinuteCount)"
        if MinuteCount < 10
        {
            MinuteS = "0" + MinuteS
        }
        var SecondS = "\(SecondCount)"
        if SecondCount < 10
        {
            SecondS = "0" + SecondS
        }
        return "\(HourS):\(MinuteS):\(SecondS)"
    }
}

