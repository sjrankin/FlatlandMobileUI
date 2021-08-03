//
//  Solar.swift
//  Solar
//
//  Created by Stuart Rankin on 7/18/21.
//

import Foundation
import UIKit
import CoreLocation

public class Solar
{
    /// Converts the longitude to a standard set of seconds away from UTC.
    /// - Parameter Longitude: The longitude to convert to timezone seconds.
    /// - Returns: Seconds away from UTC for the given longitude. Longitudes in the western hemisphere
    ///            will be returned as negative values.
    static func LongitudeToTZSeconds(Longitude: Double) -> Int
    {
        let lo = Longitude.rounded()
        let Long = Int(lo)
        let LPercent = Double(Long) / 180.0
        let Hours = Int(LPercent * 12.0)
        return Int(Hours * 60 * 60)
    }
    
    /// Given the time, return the hour, minute and seconds parts.
    /// - Parameter TheDate: The date in string format (use `"\(Date())"`).
    /// - Returns: Tuple with the passed date's hour, minute, and seconds component. Nil on error.
    static func GetTimeFromDate(TheDate: String) -> (Int, Int, Int)?
    {
        let Parts = TheDate.split(separator: " ")
        let TimePart = String(Parts[1])
        let TimeParts = TimePart.split(separator: ":")
        let HourPart = String(TimeParts[0])
        let MinutePart = String(TimeParts[1])
        let SecondPart = String(TimeParts[2])
        guard let Hour = Int(HourPart) else
        {
            return nil
        }
        guard let Minute = Int(MinutePart) else
        {
            return nil
        }
        guard let Second = Int(SecondPart) else
        {
            return nil
        }
        return (Hour, Minute, Second)
    }
    
    /// Convert the passed hour and minute value into the equivalent number of seconds.
    /// - Parameter Hour: The hour to convert.
    /// - Parameter Minute: The minute to convert.
    /// - Returns: The number of seconds `Hour` and `Minute` represent.
    public static func SecondsFrom(Hour: Int, Minute: Int) -> Int
    {
        return Hour * 60 * 60 + Minute * 60
    }
    
    /// Determines if the passed location is in daylight or not.
    /// - Parameter Latitude: The latitude of the location.
    /// - Parameter Longitude: The longitude of the location.
    /// - Returns: True if the location is in the daylight, false if not. Nil on error or no sunrise or sunset.
    public static func IsInDaylight(_ Latitude: Double, _ Longitude: Double) -> Bool?
    {
        let TimeZoneSeconds = LongitudeToTZSeconds(Longitude: Longitude)
        let (RiseHour, RiseMinute, SetHour, SetMinute) = SunriseSunset(For: Date(),
                                                                       AtLatitude: Latitude,
                                                                       AtLongitude: Longitude,
                                                                       TimeZoneSeconds: TimeZoneSeconds)
        let LocalNow = Calendar.current.date(byAdding: .second, value: TimeZoneSeconds, to: Date())!
        if let (Hour, Minute, _) = GetTimeFromDate(TheDate: "\(LocalNow)")
        {
            guard RiseHour != nil, RiseMinute != nil, SetHour != nil, SetMinute != nil else
            {
                return nil
            }
            let RiseSeconds = SecondsFrom(Hour: RiseHour!, Minute: RiseMinute!)
            let SetSeconds = SecondsFrom(Hour: SetHour!, Minute: SetMinute!)
            let NowSeconds = SecondsFrom(Hour: Hour, Minute: Minute)
            if NowSeconds < RiseSeconds
            {
                return false
            }
            if NowSeconds > SetSeconds
            {
                return false
            }
            return true
        }
        else
        {
            print("Error getting time from date.")
            return nil
        }
    }
    
    /// Returns the sunrise and sunset time for the pass location.
    /// - Parameter Latitude: The latitude of the location.
    /// - Parameter Longitude: The longitude of the location.
    /// - Returns: Result whose success result is a tuple. The first item is the number of seconds into the day
    ///            for the sunset, and the second item is the number of seconds into the day for the sunset.
    public static func SunriseSunsetAt(_ Latitude: Double, _ Longitude: Double) -> Result<(Sunrise: Int, Sunset: Int), SolarResults>
    {
        let TimeZoneSeconds = LongitudeToTZSeconds(Longitude: Longitude)
        let (RiseHour, RiseMinute, SetHour, SetMinute) = SunriseSunset(For: Date(),
                                                                       AtLatitude: Latitude,
                                                                       AtLongitude: Longitude,
                                                                       TimeZoneSeconds: TimeZoneSeconds)
        guard RiseHour != nil, RiseMinute != nil, SetHour != nil, SetMinute != nil else
        {
            return .failure(.Error)
        }
        let RiseSeconds = SecondsFrom(Hour: RiseHour!, Minute: RiseMinute!)
        let SetSeconds = SecondsFrom(Hour: SetHour!, Minute: SetMinute!)
        
        return .success((Sunrise: RiseSeconds, Sunset: SetSeconds))
    }
    
    /// Determines if the location in the passed point is in day or night time.
    /// - Parameter Where: Contains the location of the point.
    /// - Returns: True if the point is in the day, false if in the night.
    public static func CalculateSunVisibility(Where: GeoPoint) -> Bool
    {
        let OverHorizon = SunAboveHorizon(ForWhen: Where.CurrentTime, Latitude: Where.Latitude, Longitude: Where.Longitude, TimeZoneSeconds: Where.TimeZoneSeconds)
        if OverHorizon == nil
        {
            return true
        }
        return OverHorizon!
    }
    
    /// Determines whether the sun is above the specified location's ideal horizon. Local terrain may get in the way...
    /// - Parameters:
    ///   - ForWhen: Date to determine the location of the sun with respect to the horizon.
    ///   - Latitude: Latitude of the location.
    ///   - Longitude: Longitude of the location.
    ///   - TimeZoneSeconds: Timze zone's seconds.
    /// - Returns: True if the sun is above the horizon, flase if not. Nil if cannot be determined.
    public static func SunAboveHorizon(ForWhen: Date, Latitude: Double, Longitude: Double, TimeZoneSeconds: Int) -> Bool?
    {
        let Cal = Calendar.current
        let CurrentHour = Cal.component(.hour, from: ForWhen)
        let CurrentMinute = Cal.component(.minute, from: ForWhen)
        let (SunriseHour, SunriseMinute, SunsetHour, SunsetMinute) = SunriseSunset(For: ForWhen, AtLatitude: Latitude, AtLongitude: Longitude, TimeZoneSeconds: TimeZoneSeconds)
        if SunriseHour == nil || SunriseMinute == nil || SunsetHour == nil || SunsetMinute == nil
        {
            return nil
        }
        if CurrentHour >= SunriseHour! && CurrentHour <= SunsetHour!
        {
            if CurrentMinute >= SunriseMinute! && CurrentMinute <= SunsetMinute!
            {
                return true
            }
        }
        return false
    }
    
    /// Determines whether the sun is above the local, ideal horizon. Local terrain may cause varying results...
    /// - Parameters:
    ///   - ForWhen: Date to determine the location of the sun with respect to the horizon.
    ///   - TheLatitude: Latitude of the location.
    ///   - TheLongitude: Longitude of the location.
    ///   - Where: Placemark of the location - needed to get seconds from GMT.
    /// - Returns: True if the sun is above the horizon, false if not, nil if cannot be determined.
    public static func SunAboveHorizon(ForWhen: Date, TheLatitude: Double, TheLongitude: Double, Where: CLPlacemark) -> Bool?
    {
        return SunAboveHorizon(ForWhen: ForWhen, Latitude: TheLatitude, Longitude: TheLongitude, TimeZoneSeconds: Where.timeZone!.secondsFromGMT())
    }
    
#if false
    /// Determines whether the sun is above the local, ideal horizon. Local terrain not accounted for. Current location used.
    /// - Parameters:
    ///   - ForWhen: Date to determine the lcoation of the sun with respect to the horizon.
    ///   - Where: Placemark of the location - needed to get seconds from GMT.
    /// - Returns: True if the sun is above the horizon, false if not, nil if cannot be determined.
    public static func SunAboveHorizon(ForWhen: Date, Where: CLPlacemark) -> Bool?
    {
        return SunAboveHorizon(ForWhen: ForWhen, Latitude: CurrentState.AsDouble(CurrentState.CurrentLatitude)!,
                               Longitude: CurrentState.AsDouble(CurrentState.CurrentLongitude)!,
                               TimeZoneSeconds: (Where.timeZone?.secondsFromGMT())!)
    }
#endif
    
    /// Return today's sunset and tomorrow's sunrise. Uses current location.
    /// - Parameter Where: Placemark needed to get seconds from GMT.
    /// - Returns: Tuple with the sequence of (Set Hour, Set Minute, Rise Hour, Rise Minute)
    public static func SunsetForTodaySunriseForTomorrow (Where: CLPlacemark) -> (Int?, Int?, Int?, Int?)
    {
        let Now = Date()
#if true
        let Latitude = Where.location?.coordinate.latitude
        let Longitude = Where.location?.coordinate.longitude
        let (_, _, TodaySunsetHour, TodaySunsetMinute) = SunriseSunset(For: Now, AtLatitude: Latitude!,
                                                                       AtLongitude: Longitude!,
                                                                       TimeZoneSeconds: (Where.timeZone?.secondsFromGMT())!)
        let Tomorrow = Calendar.current.date(byAdding: .day, value: 1, to: Now)
        let (TomorrowSunriseHour, TomorrowSunriseMinute, _, _) = SunriseSunset(For: Tomorrow!, AtLatitude: Latitude!,
                                                                               AtLongitude: Longitude!,
                                                                               TimeZoneSeconds: (Where.timeZone?.secondsFromGMT())!)
        return (TodaySunsetHour, TodaySunsetMinute, TomorrowSunriseHour, TomorrowSunriseMinute)
#else
        let (_, _, TodaySunsetHour, TodaySunsetMinute) = SunriseSunset(For: Now, Where: Where)
        let Tomorrow = Calendar.current.date(byAdding: .day, value: 1, to: Now)
        let (TomorrowSunriseHour, TomorrowSunriseMinute, _, _) = SunriseSunset(For: Tomorrow!, Where: Where)
        return (TodaySunsetHour, TodaySunsetMinute, TomorrowSunriseHour, TomorrowSunriseMinute)
#endif
    }
    
    public static func TodaysSunsetTomorrowsSunrise(Where: CLPlacemark) -> (String?, String?)
    {
        let (SunsetHour, SunsetMinute, SunriseHour, SunriseMinute) = SunsetForTodaySunriseForTomorrow(Where: Where)
        if SunsetHour == nil || SunsetMinute == nil || SunriseHour == nil || SunriseMinute == nil
        {
            return (nil, nil)
        }
        let Misc = Miscellaneous()
#if true
        return ("","")
#else
        let SunsetString = Misc.MakeTimeString(Hour: SunsetHour!, Minute: SunsetMinute!)
        let SunriseString = Misc.MakeTimeString(Hour: SunriseHour!, Minute: SunriseMinute!)
        return (SunsetString, SunriseString)
#endif
    }
    
    /// Get the current day's sunset time and the length of the night.
    /// - Parameter Where: Placemark needed to get seconds from GMT.
    /// - Returns: The sunset time and the duration (in seconds) to sunrise.
    public static func GetSunsetAndLengthOfNight(Where: CLPlacemark) -> (Date?, Int?)
    {
        let (SunsetHour, SunsetMinute, SunriseHour, SunriseMinute) = SunsetForTodaySunriseForTomorrow(Where: Where)
        if SunsetHour == nil || SunsetMinute == nil || SunriseHour == nil || SunriseMinute == nil
        {
            return (nil, nil)
        }
        let SetTime = Utility.MakeTimeFrom(Hours: SunsetHour!, Minutes: SunsetMinute!)
        let RiseTime = Utility.MakeTimeFrom(Hours: SunriseHour!, Minutes: SunriseMinute!)
        let Duration = TimeHelper.SecondsBetween(Time1: SetTime, Time2: RiseTime)
        return (SetTime, Duration)
    }
    
    /// Return the sunrise and sunset times for the given date and location.
    /// - Parameters:
    ///   - For: The date whose sunset and sunrise times will be returned.
    ///   - AtLatitude: The latitude of the location.
    ///   - AtLongitude: The longitude of the location.
    ///   - TimeZoneSeconds: How far away GMT is from the location in seconds.
    /// - Returns: Tuple with the sequence of (Rise Hour, Rise Minute, Set Hour, Set Minute)
    public static func SunriseSunset(For: Date, AtLatitude: Double, AtLongitude: Double,
                                     TimeZoneSeconds: Int) -> (Int?, Int?, Int?, Int?)
    {
        SunNeverVisible = false
        SunAlwaysVisible = false
        
        let TimeZone36: Double = Double(TimeZoneSeconds) / 3600.0
        let Zone = -Int(round(TimeZone36))
        var JD: Double = GetJulianDay(For: For) - 2451545.0
        
        if Sign(Double(Zone)) == Sign(AtLongitude) && Zone != 0
        {
            print("Time zone and longitude do not match.")
            return (nil, nil, nil, nil)
        }
        
        let Longitude: Double = AtLongitude / 360.0
        let TZ: Double = Double(Zone) / 24.0
        let Centuries: Double = (JD / 36525.0) + 1.0
        let SiderealTime: Double = LocalSideralTime(Longitude: Longitude, JulianDate: JD, Zone: TZ)
        
        JD = JD + TZ
        CalculateSunPosition(JulianDate: JD, Centuries: Centuries)
        let RA0: Double = mSunPositionInSkyArr[0]
        let Dec0: Double = mSunPositionInSkyArr[1]
        
        JD = JD + 1.0
        CalculateSunPosition(JulianDate: JD, Centuries: Centuries)
        var RA1 = mSunPositionInSkyArr[0]
        let Dec1 = mSunPositionInSkyArr[1]
        
        if RA1 < RA0
        {
            RA1 = RA1 + (2.0 * Double.pi)
        }
        
        IsSunset = false
        IsSunrise = false
        mRightAscentionArr[0] = RA0
        mDeclinationArr[0] = Dec0
        
        for K: Int in 0 ..< 24
        {
            mRightAscentionArr[2] = RA0 + (Double(K) + 1.0) * (RA1 - RA0) / 24.0
            mDeclinationArr[2] = Dec0 + (Double(K) + 1.0) * (Dec1 - Dec0) / 24.0
            mVHzArr[2] = TestHour(TheHour: K, Zone: Double(Zone), SidTime: SiderealTime, Latitude: AtLatitude)
            
            mRightAscentionArr[0] = mRightAscentionArr[2]
            mDeclinationArr[0] = mDeclinationArr[2]
            mVHzArr[0] = mVHzArr[2]
        }
        
        let RiseHour = mRiseTimeArr[0]
        let RiseMinute = mRiseTimeArr[1]
        let SetHour = mSetTimeArr[0]
        let SetMinute = mSetTimeArr[1]
        
        if !IsSunset && !IsSunrise
        {
            if mVHzArr[2] < 0
            {
                SunNeverVisible = true
                SunAlwaysVisible = false
            }
            else
            {
                SunNeverVisible = false
                SunAlwaysVisible = true
            }
            return (nil, nil, nil, nil)
        }
        if !IsSunrise
        {
            return (nil, nil, SetHour, SetMinute)
        }
        if !IsSunset
        {
            return (RiseHour, RiseMinute, nil, nil)
        }
        return (RiseHour, RiseMinute, SetHour, SetMinute)
    }
    
    public static var SunAlwaysVisible: Bool = false
    public static var SunNeverVisible: Bool = false
    
    /// Returns the Julian Date equivalent of Date.
    /// - Parameter For: The date whose Julian Date equivalent will be returned.
    /// - Returns: Julian date value for Date.
    public static func GetJulianDay(For: Date) -> Double
    {
        let Cal = Calendar.current
        let Day = Cal.component(.day, from: For)
        var Month = Cal.component(.month, from: For)
        var Year = Cal.component(.year, from: For)
        //print("Getting Julian day for \(Day), \(Month), \(Year)")
        
        var IsGregorian: Bool = false
        if Year < 1583
        {
            IsGregorian = false
        }
        else
        {
            IsGregorian = true
        }
        
        if Month == 1 || Month == 2
        {
            Year = Year - 1
            Month = Month + 12
        }
        
        let A: Double = floor(Double(Year) / 100.0)
        var B: Double = 0
        if IsGregorian
        {
            B = 2.0 - A + floor(A / 4.0)
        }
        else
        {
            B = 0
        }
        
        var JD: Double = floor(365.25 * (Double(Year) + 4716.0))
        JD = JD + floor(30.6001 * (Double(Month) + 1.0))
        JD = JD + Double(Day) + B - 1524.5
        
        return JD
    }
    
    /// Calculate the position of the sun in the sky. Position stored in private class variables.
    /// - Parameters:
    ///   - JulianDate: The Julian Date.
    ///   - Centuries: The Julian Century.
    private static func CalculateSunPosition(JulianDate: Double, Centuries: Double)
    {
        var g: Double = 0.0
        var lo: Double = 0.0
        var s: Double = 0.0
        var u: Double = 0.0
        var v: Double = 0.0
        var w: Double = 0.0
        
        lo = 0.779072 + 0.00273790931 * JulianDate;
        lo = lo - floor(lo);
        lo = lo * 2.0 * Double.pi;
        
        g = 0.993126 + 0.0027377785 * JulianDate;
        g = g - floor(g);
        g = g * 2.0 * Double.pi;
        
        v = 0.39785 * sin(lo);
        v = v - 0.01 * sin(lo - g);
        v = v + 0.00333 * sin(lo + g);
        v = v - 0.00021 * Centuries * sin(lo);
        
        u = 1 - 0.03349 * cos(g);
        u = u - 0.00014 * cos(2.0 * lo);
        u = u + 0.00008 * cos(lo);
        
        w = -0.0001 - 0.04129 * sin(2.0 * lo);
        w = w + 0.03211 * sin(g);
        w = w + 0.00104 * sin(2.0 * lo - g);
        w = w - 0.00035 * sin(2.0 * lo + g);
        w = w - 0.00008 * Centuries * sin(g);
        
        // compute sun's right ascension
        s = w / sqrt(u - v * v);
        let Ascension: Double = lo + atan(s / sqrt(1.0 - s * s))
        mSunPositionInSkyArr[0] = Ascension
        
        // ...and declination
        s = v / sqrt(u);
        let Declination: Double = atan(s / sqrt(1.0 - s * s))
        mSunPositionInSkyArr[1] = Declination
    }
    
    /// Return the current siderial time.
    /// - Parameters:
    ///   - Longitude: Longitude of the location where for the siderial time.
    ///   - JulianDate: Julian date of the day to get the siderial time.
    ///   - Zone: Calculated time zone based on degrees, not political lines.
    /// - Returns: Siderial time for the location and date.
    private static func LocalSideralTime(Longitude: Double, JulianDate: Double, Zone: Double) -> Double
    {
        var S: Double = 24110.5 + (8640184.812999999 * JulianDate / 36525.0) + (86636.6 * Zone) + (86400.0 * Longitude)
        S = S / 86400.0
        S = S - floor(S)
        return ToRadians(S * 360.0)
    }
    
    static var TestBlock: NSObject = NSObject()
    
    /// Called iteratively to calculate sunrise and sunset times.
    /// - Parameters:
    ///   - TheHour: Test house.
    ///   - Zone: Time zone.
    ///   - SidTime: Sidereal time.
    ///   - Latitude: Latitude.
    /// - Returns: Transit time.
    private static func TestHour(TheHour: Int, Zone: Double, SidTime: Double, Latitude: Double) -> Double
    {
        objc_sync_enter(TestBlock)
        defer{objc_sync_exit(TestBlock)}
        //        var HA = Array(repeating: 0.0, count: 3)
        var HA: [Double] = [0.0, 0.0, 0.0]
        HA[0] = SidTime - mRightAscentionArr[0] + (Double(TheHour) * MK1)
        HA[2] = SidTime - mRightAscentionArr[2] + ((Double(TheHour) * MK1) + MK1)
        
        HA[1] = (HA[2] + HA[0]) / 2.0
        mDeclinationArr[1] = (mDeclinationArr[2] + mDeclinationArr[0]) / 2.0
        
        let S: Double = sin(ToRadians(Latitude))
        let C: Double = cos(ToRadians(Latitude))
        let Z: Double = cos(ToRadians(90.833))
        
        if TheHour <= 0
        {
            mVHzArr[0] = (S * sin(mDeclinationArr[0])) + (C * cos(mDeclinationArr[0]) * cos(HA[0])) - Z
        }
        mVHzArr[2] = (S * sin(mDeclinationArr[2])) + (C * cos(mDeclinationArr[2]) * cos(HA[2])) - Z
        
        if (Sign(mVHzArr[0]) == Sign(mVHzArr[2]))
        {
            return mVHzArr[2]
        }
        
        let t0 = S * sin(mDeclinationArr[1])
        let t1 = C * cos(mDeclinationArr[1]) * cos(HA[1])
        let t2 = t0 + t1 - Z
        mVHzArr[1] = t2
        
        let A: Double = (2.0 * mVHzArr[0]) - (4.0 * mVHzArr[1]) + (2.0 * mVHzArr[2])
        let B: Double = (-3.0 * mVHzArr[0]) + (4.0 * mVHzArr[1]) - mVHzArr[2]
        var D: Double = (B * B) - (4.0 * A * mVHzArr[0])
        
        if D < 0
        {
            return mVHzArr[2]
        }
        
        D = sqrt(D)
        var E: Double = (-B + D) / (2.0 * A)
        if E > 1.0 || E < 0.0
        {
            E = (-B - D) / (2.0 * A)
        }
        
        let Time: Double = Double(TheHour) + E + (1.0 / 120.0)
        
        let Hour: Int = Int(floor(Time))
        let m1 = Time - Double(Hour)
        let m2 = m1 * 60.0
        let m3 = floor(m2)
        let Minute: Int = Int(m3)
        
        let HZ: Double = HA[0] + (E * (HA[2] - HA[0]))
        let NZ: Double = -cos(mDeclinationArr[1]) * sin(HZ)
        let DZ: Double = (C * sin(mDeclinationArr[1])) - (S * cos(mDeclinationArr[1]) * cos(HZ))
        var Azimuth: Double = atan2(NZ, DZ) / (Double.pi / 180.0)
        if Azimuth < 0
        {
            Azimuth = Azimuth + 360.0
        }
        
        if mVHzArr[0] < 0 && mVHzArr[2] > 0
        {
            mRiseTimeArr[0] = Hour
            mRiseTimeArr[1] = Minute
            mRiseAzimuth = Azimuth
            IsSunrise = true
        }
        if mVHzArr[0] > 0 && mVHzArr[2] < 0
        {
            mSetTimeArr[0] = Hour
            mSetTimeArr[1] = Minute
            mSetAzimuth = Azimuth
            IsSunset = true
        }
        
        return mVHzArr[2]
    }
    
    /// Returns the sign of Value as a normalized integer.
    /// - Parameter Value: The value to test.
    /// - Returns: Normalized integer whose sign is the same as Value.
    private static func Sign(_ Value: Double) -> Int
    {
        var RV: Int = 0
        
        if Value > 0.0
        {
            RV = 1
        }
        if Value < 0.0
        {
            RV = -1
        }
        
        return RV
    }
    
    private static var IsSunrise: Bool = false
    private static var IsSunset: Bool = false
    
    private static let MK1: Double = 0.26251616834300473 //ToRadians(15.0 * 1.0027379)
    
    private static var mRiseTimeArr: [Int] = [0, 0]
    private static var mSetTimeArr: [Int] = [0, 0]
    private static var mRiseAzimuth: Double = 0.0
    private static var mSetAzimuth: Double = 0.0
    private static var mSunPositionInSkyArr: [Double] = [0.0, 0.0]
    private static var mRightAscentionArr: [Double] = [0.0, 0.0, 0.0]
    private static var mDeclinationArr: [Double] = [0.0, 0.0, 0.0]
    private static var mVHzArr: [Double] = [0.0, 0.0, 0.0]
    
    /// Convert an angle to radians.
    /// - Parameter Angle: The angle to convert.
    /// - Returns: Radians equivalent to Angle.
    public static func ToRadians(_ Angle: Double) -> Double
    {
        return (Double.pi * Angle) / 180.0
    }
    
    /// Convert radians to an angle.
    /// - Parameter Radians: The radial value to convert.
    /// - Returns: Angle equivalent of Radians.
    public static func ToDegrees(_ Radians: Double) -> Double
    {
        return (180.0 * Radians) / Double.pi
    }
}

public enum SolarResults: String, CaseIterable, Error
{
    case Success = "Success"
    case Error = "Calculation Error"
}
