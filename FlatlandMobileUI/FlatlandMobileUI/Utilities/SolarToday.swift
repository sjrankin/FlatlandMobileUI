//
//  SolarToday.swift
//  SolarToday
//
//  Created by Stuart Rankin on 7/18/21. Adapted from Flatland View.
//

import Foundation
import UIKit
import Contacts
import CoreLocation

/// Calculates various time events for a geographical point for a given date.
class SolarToday
{
    /// Type alias for the initializer closure.
    typealias GeocoderCompletedType = ((Bool) -> ())
    /// Type alias for more complex closure.
    typealias GeocoderCompletedType2 = ((Bool, Date?, Date?, String, String, Int, Int, Date,
                                         Double, Double, LocationData?) -> ())
    
    /// Initializer.
    /// - Note: Data will become available asynchronously and is dependent on a working internet connection to
    ///         Apple's servers to get certain information.
    /// - Warning: If the caller does not specify the closure, the caller will not be notified when all
    ///            results will be available. Alternativately, the caller can use the alternative initializer.
    /// - Parameter For: The date to get the times for.
    /// - Parameter Latitude: The latitude of the location.
    /// - Parameter Longitude: The longitude of the location.
    /// - Parameter Completed: The closure that will receive the notification when data are available. The
    ///                        parameter will be true on success, false on failure.
    init?(For When: Date, Latitude: Double, Longitude: Double, _ Completed: GeocoderCompletedType2? = nil)
    {
        SolarDate = When
        self.Latitude = Latitude
        self.Longitude = Longitude
        GeocoderCompleted2 = Completed
        let Location = CLLocation(latitude: Latitude, longitude: Longitude)
        if !CLLocationCoordinate2DIsValid(Location.coordinate)
        {
            return nil
        }
        let GeoCoder = CLGeocoder()
        GeoCoder.reverseGeocodeLocation(Location, completionHandler: GeocoderCompletion2)
        CurrentTimezoneSeconds = TimeZone.current.secondsFromGMT()
    }
    
    /// Initializer.
    /// - Note: Data will become available asynchronously and is dependent on a working internet connection to
    ///         Apple's servers to get certain information.
    /// - Warning: If the caller does not specify the closure, the caller will not be notified when all
    ///            results will be available. Alternativately, the caller can use the alternative initializer.
    /// - Parameter For: The date to get the times for.
    /// - Parameter Latitude: The latitude of the location.
    /// - Parameter Longitude: The longitude of the location.
    /// - Parameter Completed: The closure that will receive the notification when data are available. The
    ///                        parameter will be true on success, false on failure.
    init?(For When: Date, Latitude: Double, Longitude: Double, _ Completed: GeocoderCompletedType? = nil)
    {
        SolarDate = When
        self.Latitude = Latitude
        self.Longitude = Longitude
        GeocoderCompleted = Completed
        let Location = CLLocation(latitude: Latitude, longitude: Longitude)
        if !CLLocationCoordinate2DIsValid(Location.coordinate)
        {
            return nil
        }
        let GeoCoder = CLGeocoder()
        GeoCoder.reverseGeocodeLocation(Location, completionHandler: GeocoderCompletion)
        CurrentTimezoneSeconds = TimeZone.current.secondsFromGMT()
    }
    
    /// Closure to finalized location and times. Called by `reverseGeocodeLocation`.
    /// - Parameter Placemarks: Array of returned placemarks.
    /// - Parameter Err: If present the error returned.
    func GeocoderCompletion(_ Placemarks: [CLPlacemark]?, _ Err: Error?)
    {
        if let SomeError = Err
        {
            Debug.Print("Error \(SomeError.localizedDescription) returned by reverseGeocodeLocation.")
            GeocoderCompleted?(false)
        }
        if let PM = Placemarks?[0]
        {
            Country = PM.country ?? "unknown"
            let TimeZoneDescription = PM.timeZone?.description ?? "unknown"
            Timezone = PM.timeZone
            let Offset = PM.timeZone?.secondsFromGMT()
            var OffsetString = ""
            if let TZOffset = Offset
            {
                let OffsetValue = TZOffset / (60 * 60)
                var OffsetSign = ""
                if OffsetValue > 0
                {
                    OffsetSign = "+"
                }
                OffsetString = "\(OffsetSign)\(OffsetValue)"
            }
            PrettyTimezoneName = "\(CleanupTimezone(TimeZoneDescription)) \(OffsetString)"
            if let TZ = PM.timeZone
            {
                TimezoneSeconds = TZ.secondsFromGMT(for: SolarDate!)
            }
            CalculateTimes()
            GeocoderCompleted?(true)
            return
        }
        GeocoderCompleted?(false)
    }
    
    /// Closure to finalized location and times. Called by `reverseGeocodeLocation`.
    /// - Note: See [Getting full address string from CLPlacemark](https://stackoverflow.com/questions/46576338/getting-full-address-string-from-clplacemark-using-swift-4-xcode-9)
    /// - Parameter Placemarks: Array of returned placemarks.
    /// - Parameter Err: If present the error returned.
    func GeocoderCompletion2(_ Placemarks: [CLPlacemark]?, _ Err: Error?)
    {
        if let SomeError = Err
        {
            Debug.Print("Error \(SomeError.localizedDescription) returned by reverseGeocodeLocation.")
            GeocoderCompleted2?(false, nil, nil, "", "", 0, 0, Date(), 0.0, 0.0, nil)
        }
        if let PM = Placemarks?[0]
        {
            Country = PM.country ?? "unknown"
            let TimeZoneDescription = PM.timeZone?.description ?? "unknown"
            Timezone = PM.timeZone
            let Offset = PM.timeZone?.secondsFromGMT()
            var OffsetString = ""
            if let TZOffset = Offset
            {
                let OffsetValue = TZOffset / (60 * 60)
                var OffsetSign = ""
                if OffsetValue > 0
                {
                    OffsetSign = "+"
                }
                OffsetString = "\(OffsetSign)\(OffsetValue)"
            }
            PrettyTimezoneName = "\(CleanupTimezone(TimeZoneDescription)) \(OffsetString)"
            if let TZ = PM.timeZone
            {
                TimezoneSeconds = TZ.secondsFromGMT(for: SolarDate!)
            }
            CalculateTimes()
            let OtherData = LocationData(Name: PM.name,
                                         CountryCode: PM.isoCountryCode,
                                         PostalCode: PM.postalCode,
                                         AdministrativeArea: PM.administrativeArea,
                                         SubAdministrativeArea: PM.subAdministrativeArea,
                                         Locality: PM.locality,
                                         SubLocality: PM.subLocality,
                                         Thoroughfare: PM.thoroughfare,
                                         SubThoroughfare: PM.subThoroughfare,
                                         Region: PM.region,
                                         PostalAddress: PM.postalAddress,
                                         InlandWater: PM.inlandWater,
                                         Ocean: PM.ocean,
                                         AreasOfInterest: PM.areasOfInterest)
            GeocoderCompleted2?(true, Sunrise, Sunset, Country!, PrettyTimezoneName!, TimezoneSeconds!,
                                CurrentTimezoneSeconds, SolarDate!, Latitude!, Longitude!, OtherData)
            return
        }
        GeocoderCompleted2?(false, nil, nil, "", "", 0, 0, Date(), 0.0, 0.0, nil)
    }
    
    /// Clean up the raw timezone string.
    /// - Parameter Raw: The timezone string from Apple.
    /// - Returns: Cleaned up string with the "(something)" string removed.
    func CleanupTimezone(_ Raw: String) -> String
    {
        let Parts = Raw.split(separator: "(", omittingEmptySubsequences: true)
        if Parts.count != 2
        {
            return Raw
        }
        let CleanedUp = String(Parts[0]).trimmingCharacters(in: .whitespaces)
        return CleanedUp
    }
    
    /// Calculate the times for the date and location.
    func CalculateTimes()
    {
        let SunTimes = Sun()
        
        var RiseAndSetAvailable = true
        let Location = GeoPoint(Latitude!, Longitude!)
        if let SunriseTime = SunTimes.Sunrise(For: SolarDate!, At: Location, TimeZoneOffset: 0)
        {
            Sunrise = SunriseTime
        }
        else
        {
            RiseAndSetAvailable = false
        }
        if let SunsetTime = SunTimes.Sunset(For: SolarDate!, At: Location, TimeZoneOffset: 0)
        {
            Sunset = SunsetTime
        }
        else
        {
            RiseAndSetAvailable = false
        }
        if RiseAndSetAvailable
        {
            let Cal = Calendar.current
            let RiseHour = Cal.component(.hour, from: Sunrise!)
            let RiseMinute = Cal.component(.minute, from: Sunrise!)
            let RiseSecond = Cal.component(.second, from: Sunrise!)
            let SetHour = Cal.component(.hour, from: Sunset!)
            let SetMinute = Cal.component(.minute, from: Sunset!)
            let SetSecond = Cal.component(.second, from: Sunset!)
            let RiseSeconds = RiseSecond + (RiseMinute * 60) + (RiseHour * 60 * 60)
            let SetSeconds = SetSecond + (SetMinute * 60) + (SetHour * 60 * 60)
            let SecondDelta = SetSeconds - RiseSeconds
            let NoonTime = RiseSeconds + (SecondDelta / 2)
            let NoonPercent = Double(NoonTime) / (24.0 * 60.0 * 60.0)
            LocalNoon = Date.DateFrom(Percent: NoonPercent)
            let SunlightSeconds = SetSeconds - RiseSeconds + 1
            DaylightHours = Double(SunlightSeconds) / (60.0 * 60.0)
            DaylightPercent = Double(SunlightSeconds) / Double(24.0 * 60.0 * 60.0) * 100.0
        }
        Inclination = Sun.Declination(For: SolarDate!)
    }
    
    /// Holds the completion handler.
    private var GeocoderCompleted: GeocoderCompletedType? = nil
    
    private var GeocoderCompleted2: GeocoderCompletedType2? = nil
    
    /// The date used to calculate solar times. The time component is ignored.
    fileprivate(set) var SolarDate: Date? = nil
    
    /// The sunrise time. If nil, no sunrise for that day/location (eg, polar day or night).
    /// - Warning: Only the time component is valid.
    fileprivate(set) var Sunrise: Date? = nil
    
    /// The sunset time. If nil, no sunset for the day/location (eg, polar day or night).
    /// - Warning: Only the time component is valid.
    fileprivate(set) var Sunset: Date? = nil
    
    /// Local noon. If nil, in the polar night.
    /// - Warning: Only the time component is valid.
    fileprivate(set) var LocalNoon: Date? = nil
    
    /// Number of daylight house. If nil, in the polar night.
    fileprivate(set) var DaylightHours: Double? = nil
    
    /// Percent of the day the sun is shining. If nil, in the polar night.
    fileprivate(set) var DaylightPercent: Double? = nil
    
    /// The latitude used to calculate solar times.
    fileprivate(set) var Latitude: Double? = nil
    
    /// The longitude used to calcualte solar times.
    fileprivate(set) var Longitude: Double? = nil
    
    /// The timezone of the location.
    fileprivate(set) var Timezone: TimeZone? = nil
    
    /// The seconds offset from GMT of the location.
    fileprivate(set) var TimezoneSeconds: Int? = nil
    
    /// The seconds offset from GMT of the user's location.
    fileprivate(set) var CurrentTimezoneSeconds: Int = 0
    
    /// The pretty time zone name.
    fileprivate(set) var PrettyTimezoneName: String? = nil
    
    /// The country of the location (if known).
    fileprivate(set) var Country: String? = nil
    
    /// The solar inclination on the specified day.
    fileprivate(set) var Inclination: Double? = nil
}

struct LocationData
{
    let Name: String?
    let CountryCode: String?
    let PostalCode: String?
    let AdministrativeArea: String?
    let SubAdministrativeArea: String?
    let Locality: String?
    let SubLocality: String?
    let Thoroughfare: String?
    let SubThoroughfare: String?
    let Region: CLRegion?
    let PostalAddress: CNPostalAddress?
    let InlandWater: String?
    let Ocean: String?
    let AreasOfInterest: [String]?
}
