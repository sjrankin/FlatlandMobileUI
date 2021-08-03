//
//  CachedLocation.swift
//  CachedLocation
//
//  Created by Stuart Rankin on 7/19/21. Adapted from Flatland View.
//

import Foundation
import UIKit
import CoreLocation
import SQLite3

/// Holds one cached location.
class CachedLocation
{
    /// Default initializer.
    init()
    {
    }
    
    /// Initializer.
    /// - Notes: Latitude and longitude are not set with this intializer and retain initial start-up values.
    /// - Parameter From: The placemark to use to populate the instance.
    init(From Source: CLPlacemark)
    {
        Populate(From: Source)
    }
    
    /// Initializer.
    /// - Parameter From: The placemark to use to populate the instance.
    /// - Parameter Latitude: The latitude of the location.
    /// - Parameter Longitude: The longitude of the location.
    init(From Source: CLPlacemark, Latitude: Double, Longitude: Double)
    {
        Populate(From: Source, Latitude, Longitude)
    }
    
    /// Populate the instance with a placemark.
    /// - Parameter From: The placemark to use to populate the instance. All nil values are converted to
    ///                   empty strings or context equivalent.
    /// - Parameter Latitude: The latitude of the location. If nil, `0.0` is assigned.
    /// - Parameter Longitude: The longitude of the location. If nil, `0.0` is assigned.
    func Populate(From: CLPlacemark, _ Latitude: Double? = nil, _ Longitude: Double? = nil)
    {
        self.Latitude = Latitude ?? 0.0
        self.Longitude = Longitude ?? 0.0
        self.Name = From.name ?? ""
        self.ISOCountryCode = From.isoCountryCode ?? ""
        self.Country = From.country ?? ""
        self.PostalCode = From.postalCode ?? ""
        self.AdministrativeArea = From.administrativeArea ?? ""
        self.SubAdministrativeArea = From.subAdministrativeArea ?? ""
        self.Locality = From.locality ?? ""
        self.SubLocality = From.subLocality ?? ""
        self.ThoroughFare = From.thoroughfare ?? ""
        self.SubThoroughFare = From.subThoroughfare ?? ""
        self.Region = ""
        if let TZ = From.timeZone
        {
            self.LocationTimeZone = TZ.abbreviation() ?? ""
            self.Abbreviation = TZ.localizedName(for: .shortStandard, locale: nil) ?? ""
            self.UTCOffset = TZ.secondsFromGMT()
            self.Localized = CachedLocation.GetActualAbbreviation(From: TZ.identifier)
        }
        else
        {
            self.LocationTimeZone = ""
        }
        self.InlandWater = From.inlandWater ?? ""
        self.Ocean = From.ocean ?? ""
        if let Areas = From.areasOfInterest
        {
            for Area in Areas
            {
                AreasOfInterest.append(Area)
            }
        }
    }
    
    /// The PKID of the entry.
    var PKID: Int = 0
    
    /// Latitude of the location.
    var Latitude: Double = 0.0
    
    /// Longitude of the location.
    var Longitude: Double = 0.0
    
    /// Name of the location.
    var Name: String = ""
    
    /// ISO country code of the location.
    var ISOCountryCode: String = ""
    
    /// Country name of the location.
    var Country: String = ""
    
    /// Postal code of the location.
    var PostalCode: String = ""
    
    /// Administrative area of the location.
    var AdministrativeArea: String = ""
    
    /// Sub-administrative area of the location.
    var SubAdministrativeArea: String = ""
    
    /// Locality of the location.
    var Locality: String = ""
    
    /// Sub-locality of the location.
    var SubLocality: String = ""
    
    /// Thoroughfare of the location.
    var ThoroughFare: String = ""
    
    /// Sub-thoroughfare of the location.
    var SubThoroughFare: String = ""
    
    /// Not currently used - always an empty string
    var Region: String = ""
    
    /// Time-zone abbreviation of the location.
    var LocationTimeZone: String = ""
    
    /// Name of associated inland water of the location.
    var InlandWater: String = ""
    
    /// Name of associated ocean of the location.
    var Ocean: String = ""
    
    /// List of areas of interest.
    var AreasOfInterest = [String]()
    
    /// Time offset from UTC.
    var UTCOffset: Int = 0
    
    /// Time-zone abbreviation (not always available).
    var Abbreviation: String = ""
    
    /// Localized time-zone.
    var Localized: String = ""
    
    /// Return a list of column names for storing data into the cached database.
    /// - Returns: List of database column names.
    static func MakeColumnList() -> String
    {
        let ColumnList = ["Latitude","Longitude","Name","ISOCountryCode","Country",
                          "PostalCode","AdministrativeArea","SubAdministrativeArea",
                          "Locality","SubLocality","ThoroughFare","SubThoroughFare",
                          "Region","TimeZone","InlandWater","Ocean","AreasOfInterest",
                          "UTCOffset","Abbreviation","Localized"]
        return "(\(ColumnList.joined(separator: ",")))"
    }
    
    /// Return a list of values that can be used when inserting into the cached database.
    /// - Parameter From: The instance placemark used to populate the returned string.
    /// - Parameter Latitude: The latitude of the location.
    /// - Parameter Longitude: The longitude of the location.
    /// - Returns: String that can be used to update the cached database.
    static func MakeValueList(From: CLPlacemark, Latitude: Double, Longitude: Double) -> String
    {
        var Values = [String]()
        Values.append("\(Latitude)")
        Values.append("\(Longitude)")
        Values.append("\(From.name ?? "\"\"")")
        Values.append("\(From.isoCountryCode ?? "\"\"")")
        Values.append("\(From.country ?? "\"\"")")
        Values.append("\(From.postalCode ?? "\"\"")")
        Values.append("\(From.administrativeArea ?? "\"\"")")
        Values.append("\(From.subAdministrativeArea ?? "\"\"")")
        Values.append("\(From.locality ?? "\"\"")")
        Values.append("\(From.subLocality ?? "\"\"")")
        Values.append("\(From.thoroughfare ?? "\"\"")")
        Values.append("\(From.subThoroughfare ?? "\"\"")")
        Values.append("\"\",")
        var UTCOffsetValue = "\"\""
        var Abbreviation = "\"\""
        var Localized = "\"\""
        if let TZ = From.timeZone
        {
            Values.append("\(TZ.abbreviation() ?? "\"\",")")
            UTCOffsetValue = "\(TZ.secondsFromGMT())"
            Abbreviation = GetActualAbbreviation(From: TZ.identifier)
            Localized = TZ.localizedName(for: .shortStandard, locale: nil) ?? "\"\""
        }
        else
        {
            Values.append("\"\",")
        }
        Values.append("\(From.inlandWater ?? "\"\"")")
        Values.append("\(From.ocean ?? "\"\"")")
        if let Areas = From.areasOfInterest
        {
            let AreaList = Areas.joined(separator: "∂")
            Values.append("\(AreaList)")
        }
        else
        {
            Values.append("\"\"")
        }
        Values.append("\(UTCOffsetValue)")
        Values.append("\(Abbreviation)")
        Values.append("\(Localized)")
        return Values.joined(separator: ",")
    }
    
    /// Given a time zone identifier, return its abbreviation.
    /// - Parameter From: The time zone identifier.
    /// - Returns Time zone abbreviation if available, empty string if not.
    static func GetActualAbbreviation(From: String) -> String
    {
        for (Key, Value) in TimeZone.abbreviationDictionary
        {
            if Value == From
            {
                return Key
            }
        }
        return "\"\""
    }
}

