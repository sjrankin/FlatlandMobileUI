//
//  +LocationCache.swift
//  +LocationCache
//
//  Created by Stuart Rankin on 7/19/21. Adapted from Flatland View.
//

import Foundation
import UIKit
import SQLite3
import CoreLocation

extension DBIF
{
    //MARK: - Cached location management
    
    /// Load cached locations from the database.
    /// - Returns: Array of previously cached loctions. May be empty if no queries saved.
    static func LoadLocations() -> [CachedLocation]
    {
        var Results = [CachedLocation]()
        if DBIF.CachedLocationHandle == nil
        {
            Debug.Print("Call to \(#function) before database initialized.")
            return Results
        }
        let GetQuery = "SELECT * FROM Cached"
        let QuerySetupResult = SQL.SetupQuery(For: DBIF.CachedLocationHandle, Query: GetQuery)
        var QueryHandle: OpaquePointer? = nil
        switch QuerySetupResult
        {
            case .success(let Handle):
                QueryHandle = Handle
                
            case .failure(let Why):
                Debug.Print("Failure creating query for cached locations: \(Why)")
                let (Message, Value) = SQL.ExtendedError(From: DBIF.CachedLocationHandle)
                Debug.Print("  \(Message) [\(Value)]")
                return [CachedLocation]()
        }
        while sqlite3_step(QueryHandle) == SQLITE_ROW
        {
            let PKID = SQL.ReadIntColumn(Handle: QueryHandle, Index: CachedColumns.ID.rawValue)!
            let Lat = SQL.ReadStringColumn(Handle: QueryHandle, Index: CachedColumns.Latitude.rawValue)!
            let Lon = SQL.ReadStringColumn(Handle: QueryHandle, Index: CachedColumns.Longitude.rawValue)!
            let Name = SQL.ReadStringColumn(Handle: QueryHandle, Index: CachedColumns.Name.rawValue)!
            let ISOCountry = SQL.ReadStringColumn(Handle: QueryHandle, Index: CachedColumns.ISOCountryCode.rawValue)!
            let Country = SQL.ReadStringColumn(Handle: QueryHandle, Index: CachedColumns.Country.rawValue)!
            let PostCode = SQL.ReadStringColumn(Handle: QueryHandle, Index: CachedColumns.PostalCode.rawValue)!
            let AdminArea = SQL.ReadStringColumn(Handle: QueryHandle, Index: CachedColumns.AdministrativeArea.rawValue)!
            let SubAdminArea = SQL.ReadStringColumn(Handle: QueryHandle, Index: CachedColumns.SubAdministrativeArea.rawValue)!
            let Locality = SQL.ReadStringColumn(Handle: QueryHandle, Index: CachedColumns.Locality.rawValue)!
            let SubLocality = SQL.ReadStringColumn(Handle: QueryHandle, Index: CachedColumns.SubLocality.rawValue)!
            let Road = SQL.ReadStringColumn(Handle: QueryHandle, Index: CachedColumns.ThoroughFare.rawValue)!
            let SubRoad = SQL.ReadStringColumn(Handle: QueryHandle, Index: CachedColumns.SubThoroughFare.rawValue)!
            let Region = SQL.ReadStringColumn(Handle: QueryHandle, Index: CachedColumns.Region.rawValue)!
            let TZ = SQL.ReadStringColumn(Handle: QueryHandle, Index: CachedColumns.TimeZone.rawValue)!
            let InlandWater = SQL.ReadStringColumn(Handle: QueryHandle, Index: CachedColumns.InlandWater.rawValue)!
            let Ocean = SQL.ReadStringColumn(Handle: QueryHandle, Index: CachedColumns.Ocean.rawValue)!
            let Areas = SQL.ReadStringColumn(Handle: QueryHandle, Index: CachedColumns.AreasOfInterest.rawValue)!
            let UTCSeconds = SQL.ReadStringColumn(Handle: QueryHandle, Index: CachedColumns.UTCOffset.rawValue)!
            let Abbr = SQL.ReadStringColumn(Handle: QueryHandle, Index: CachedColumns.Abbreviation.rawValue)!
            let Local = SQL.ReadStringColumn(Handle: QueryHandle, Index: CachedColumns.Localized.rawValue)!
            let Cached = CachedLocation()
            guard let CachedLatitude = Double(Lat) else
            {
                Debug.Print("Error converting latitude value \"\(Lat)\" for \(Name).")
                return [CachedLocation]()
            }
            guard let CachedLongitude = Double(Lon) else
            {
                Debug.Print("Error converting longitude value \"\(Lon)\" for \(Name).")
                return [CachedLocation]()
            }
            Cached.PKID = PKID
            Cached.Latitude = CachedLatitude
            Cached.Longitude = CachedLongitude
            Cached.Name = Name
            Cached.ISOCountryCode = ISOCountry
            Cached.Country = Country
            Cached.PostalCode = PostCode
            Cached.AdministrativeArea = AdminArea
            Cached.SubAdministrativeArea = SubAdminArea
            Cached.Locality = Locality
            Cached.SubLocality = SubLocality
            Cached.ThoroughFare = Road
            Cached.SubThoroughFare = SubRoad
            Cached.Region = Region
            Cached.LocationTimeZone = TZ
            Cached.InlandWater = InlandWater
            Cached.Ocean = Ocean
            if !Areas.isEmpty
            {
                Cached.AreasOfInterest = [String]()
                let Parts = Areas.split(separator: "∂", omittingEmptySubsequences: true)
                for Part in Parts
                {
                    Cached.AreasOfInterest.append(String(Part))
                }
            }
            else
            {
                Cached.AreasOfInterest = [String]()
            }
            Cached.UTCOffset = Int(UTCSeconds) ?? 0
            Cached.Abbreviation = Abbr
            Cached.Localized = Local
            Results.append(Cached)
        }
        Debug.Print("Found \(Results.count) cached locations")
        return Results
    }
    
    /// Return the cached location at the specified geographical point.
    /// - Warning: A fatal error is thrown if the cached database has not been opened prior to calling
    ///            this function.
    /// - Parameter Latitude: The latitude of the location to return.
    /// - Parameter Longitude: The longitude of the location to return.
    /// - Returns: The cached location at the specified point, nil if not found.
    public static func GetLocation(Latitude: Double, Longitude: Double) -> CachedLocation?
    {
        guard LocationCacheInstalled else
        {
            Debug.FatalError("Cached location database not installed.")
        }
        let TestLatitude = Latitude.RoundedTo(2)
        let TestLongitude = Longitude.RoundedTo(2)
        for Somewhere in CachedLocations
        {
            if Somewhere.Latitude == TestLatitude && Somewhere.Longitude == TestLongitude
            {
                return Somewhere
            }
        }
        return nil
    }
    
    /// Save a location retrieved from reverse geocoding into the database cache. On success, the cached
    /// location is added to the list of cached locations in the instance.
    /// - Parameter Latitude: The latitude of the cached location.
    /// - Parameter Longitude: The longitude of the cached location.
    /// - Parameter Location: The placemark returned by reverse geocoding.
    /// - Returns: A cached location instance on success, nil on error.
    public static func SaveLocation(Latitude: Double, Longitude: Double, Location: CLPlacemark) -> CachedLocation?
    {
        var Statement = "INSERT INTO Cached "
        Statement.append(CachedLocation.MakeColumnList())
        Statement.append(" ")
        Statement.append("VALUES \(CachedLocation.MakeValueList(From: Location, Latitude: Latitude, Longitude: Longitude));")
        var InsertHandle: OpaquePointer? = nil
        guard sqlite3_prepare_v2(DBIF.CachedLocationHandle, Statement, -1, &InsertHandle, nil) == SQLITE_OK else
        {
            Debug.Print("Failure with insert statement \(Statement) for cached location")
            let (Message, Value) = SQL.ExtendedError(From: DBIF.CachedLocationHandle)
            Debug.Print("  \(Message) [\(Value)]")
            return nil
        }
        guard sqlite3_step(InsertHandle) == SQLITE_DONE else
        {
            Debug.Print("Insert execution failed: \(Statement) for cached location")
            let (Message, Value) = SQL.ExtendedError(From: DBIF.CachedLocationHandle)
            Debug.Print("  \(Message) [\(Value)]")
            return nil
        }
        let Final = CachedLocation(From: Location, Latitude: Latitude, Longitude: Longitude)
        CachedLocations.append(Final)
        return Final
    }
}

/// Columns in the cached item database.
enum CachedColumns: Int32
{
    case ID = 0
    case Latitude = 1
    case Longitude = 2
    case Name = 3
    case ISOCountryCode = 4
    case Country = 5
    case PostalCode = 6
    case AdministrativeArea = 7
    case SubAdministrativeArea = 8
    case Locality = 9
    case SubLocality = 10
    case ThoroughFare = 11
    case SubThoroughFare = 12
    case Region = 13
    case TimeZone = 14
    case InlandWater = 15
    case Ocean = 16
    case AreasOfInterest = 17
    case UTCOffset = 18
    case Abbreviation = 19
    case Localized = 20
}
