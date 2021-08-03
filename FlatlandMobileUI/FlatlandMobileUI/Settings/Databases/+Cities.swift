//
//  +Cities.swift
//  +Cities
//
//  Created by Stuart Rankin on 7/19/21.
//

import Foundation
import UIKit
import SQLite3

extension DBIF
{
    // MARK: - City-related database handling.
    
    /// Get all cities in the city database table.
    /// - Returns: All cities in the pre-defined cities table. Empty array returned on error.
    public static func GetAllCities() -> [City2]
    {
        var Results = [City2]()
        let GetQuery = "SELECT * FROM \(MappableTableNames.Cities.rawValue)"
        let QuerySetupResult = SQL.SetupQuery(For: DBIF.MappableHandle, Query: GetQuery)
        var QueryHandle: OpaquePointer? = nil
        switch QuerySetupResult
        {
            case .success(let Handle):
                QueryHandle = Handle
                
            case .failure(let Why):
                Debug.Print("Failure creating query for Cities: \(Why)")
                let (Message, Value) = SQL.ExtendedError(From: DBIF.MappableHandle)
                Debug.Print("  \(Message) [\(Value)]")
                return [City2]()
        }
        
        while (sqlite3_step(QueryHandle) == SQLITE_ROW)
        {
            let PKID = SQL.ReadIntColumn(Handle: QueryHandle, Index: CityColumns.CityPK.rawValue)!
            let ID = SQL.ReadUUIDColumn(Handle: QueryHandle, Index: CityColumns.CityID.rawValue)!
            let Name = SQL.ReadStringColumn(Handle: QueryHandle, Index: CityColumns.CityName.rawValue)!
            let Country = SQL.ReadStringColumn(Handle: QueryHandle, Index: CityColumns.CityCountry.rawValue)!
            let IsCapital = SQL.ReadBoolColumn(Handle: QueryHandle, Index: CityColumns.CityIsCaptial.rawValue)!
            let Population = SQL.ReadIntColumn(Handle: QueryHandle, Index: CityColumns.CityPopulation.rawValue)
            let MetroPopulation = SQL.ReadIntColumn(Handle: QueryHandle, Index: CityColumns.CityMetroPopulation.rawValue)
            let Latitude = SQL.ReadDoubleColumn(Handle: QueryHandle, Index: CityColumns.CityLatitude.rawValue)!
            let Longitude = SQL.ReadDoubleColumn(Handle: QueryHandle, Index: CityColumns.CityLongitude.rawValue)!
            let Continent = SQL.ReadStringColumn(Handle: QueryHandle, Index: CityColumns.CityContinent.rawValue)!
            let Color = SQL.ReadColorColumn(Handle: QueryHandle, Index: CityColumns.CityColor.rawValue)!
            let WorldCity = SQL.ReadBoolColumn(Handle: QueryHandle, Index: CityColumns.CityWorldCity.rawValue)!
            
            let NewCity = City2()
            NewCity.CityPK = PKID
            NewCity.CityID = ID
            NewCity.Name = Name
            NewCity.Country = Country
            NewCity.Continent = GetContinent(From: Continent)
            NewCity.IsCapital = IsCapital
            NewCity.Population = Population
            NewCity.MetropolitanPopulation = MetroPopulation
            NewCity.Latitude = Latitude
            NewCity.Longitude = Longitude
            NewCity.CityColor = Color
            NewCity.IsWorldCity = WorldCity
            NewCity.IsCustomCity = false
            
            Results.append(NewCity)
        }
        return Results
    }
    
    /// Returns all additional (eg, user-defined) cities.
    /// - Returns: Array of additional/user-defined cities. On error, will be empty. If nothing defined, will
    ///            be empty.
    public static func GetAllAdditionalCities() -> [City2]
    {
        var Results = [City2]()
        let GetQuery = "SELECT * FROM \(MappableTableNames.AdditionalCities.rawValue)"
        let QuerySetupResult = SQL.SetupQuery(For: DBIF.MappableHandle, Query: GetQuery)
        var QueryHandle: OpaquePointer? = nil
        switch QuerySetupResult
        {
            case .success(let Handle):
                QueryHandle = Handle
                
            case .failure(let Why):
                Debug.Print("Failure creating query for Additional Cities: \(Why)")
                let (Message, Value) = SQL.ExtendedError(From: DBIF.MappableHandle)
                Debug.Print("  \(Message) [\(Value)]")
                return [City2]()
        }
        
        while (sqlite3_step(QueryHandle) == SQLITE_ROW)
        {
            let PKID = SQL.ReadIntColumn(Handle: QueryHandle, Index: CityColumns.CityPK.rawValue)!
            let ID = SQL.ReadUUIDColumn(Handle: QueryHandle, Index: CityColumns.CityID.rawValue)!
            let Name = SQL.ReadStringColumn(Handle: QueryHandle, Index: CityColumns.CityName.rawValue)!
            let Country = SQL.ReadStringColumn(Handle: QueryHandle, Index: CityColumns.CityCountry.rawValue)!
            let IsCapital = SQL.ReadBoolColumn(Handle: QueryHandle, Index: CityColumns.CityIsCaptial.rawValue)!
            let Population = SQL.ReadIntColumn(Handle: QueryHandle, Index: CityColumns.CityPopulation.rawValue)
            let MetroPopulation = SQL.ReadIntColumn(Handle: QueryHandle, Index: CityColumns.CityMetroPopulation.rawValue)
            let Latitude = SQL.ReadDoubleColumn(Handle: QueryHandle, Index: CityColumns.CityLatitude.rawValue)!
            let Longitude = SQL.ReadDoubleColumn(Handle: QueryHandle, Index: CityColumns.CityLongitude.rawValue)!
            let Continent = SQL.ReadStringColumn(Handle: QueryHandle, Index: CityColumns.CityContinent.rawValue)!
            let Color = SQL.ReadColorColumn(Handle: QueryHandle, Index: CityColumns.CityColor.rawValue)!
            let WorldCity = SQL.ReadBoolColumn(Handle: QueryHandle, Index: CityColumns.CityWorldCity.rawValue)!
            let SubNational = SQL.ReadStringColumn(Handle: QueryHandle, Index: CityColumns.SubNational.rawValue)!
            
            let NewCity = City2()
            NewCity.CityPK = PKID
            NewCity.CityID = ID
            NewCity.Name = Name
            NewCity.Country = Country
            NewCity.Continent = GetContinent(From: Continent)
            NewCity.IsCapital = IsCapital
            NewCity.Population = Population
            NewCity.MetropolitanPopulation = MetroPopulation
            NewCity.Latitude = Latitude
            NewCity.Longitude = Longitude
            NewCity.CityColor = Color
            NewCity.IsWorldCity = WorldCity
            NewCity.SubNational = SubNational
            NewCity.IsCustomCity = true
            
            Results.append(NewCity)
        }
        return Results
    }
    
    private static func GetContinent(From Raw: String) -> Continents
    {
        switch Raw.lowercased()
        {
            case "africa":
                return .Africa
                
            case "asia":
                return .Asia
                
            case "europe":
                return .Europe
                
            case "northamerica":
                return .NorthAmerica
                
            case "southamerica":
                return .SouthAmerica
                
            default:
                return .NoName
        }
    }
}
