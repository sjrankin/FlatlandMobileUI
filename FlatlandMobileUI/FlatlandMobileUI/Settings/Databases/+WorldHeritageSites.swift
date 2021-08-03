//
//  +WorldHeritageSites.swift
//  +WorldHeritageSites
//
//  Created by Stuart Rankin on 7/19/21. Adapted from Flatland View.
//

import Foundation
import UIKit
import SQLite3

extension DBIF
{
    // MARK: - World Heritage Site database-related functions.
    
    /// Loads all World Heritage Sites.
    /// - Returns: Array of all World Heritage Sites in the database. On error, an empty array is returned.
    public static func LoadWorldHeritageSites() -> [WorldHeritageSite]
    {
        var Results = [WorldHeritageSite]()
        let GetQuery = "SELECT * FROM \(MappableTableNames.UNESCOSites.rawValue)"
        let QuerySetupResult = SQL.SetupQuery(For: DBIF.MappableHandle, Query: GetQuery)
        var QueryHandle: OpaquePointer? = nil
        switch QuerySetupResult
        {
            case .success(let Handle):
                QueryHandle = Handle
                
            case .failure(let Why):
                Debug.Print("Failure creating query for World Heritage Sites: \(Why)")
                let (Message, Value) = SQL.ExtendedError(From: DBIF.MappableHandle)
                Debug.Print("  \(Message) [\(Value)]")
                return [WorldHeritageSite]()
        }
        while (sqlite3_step(QueryHandle) == SQLITE_ROW)
        {
            let UID = Int(sqlite3_column_int(QueryHandle, 0))
            let ID = Int(sqlite3_column_int(QueryHandle, 1))
            let Name = String(cString: sqlite3_column_text(QueryHandle, 2))
            let Year = Int(sqlite3_column_int(QueryHandle, 3))
            let Longitude = Double(sqlite3_column_double(QueryHandle, 4))
            let Latitude = Double(sqlite3_column_double(QueryHandle, 5))
            let Hectares = Double(sqlite3_column_double(QueryHandle, 6))
            let Category = String(cString: sqlite3_column_text(QueryHandle, 7))
            let ShortCategory = String(cString: sqlite3_column_text(QueryHandle, 8))
            let Countries = String(cString: sqlite3_column_text(QueryHandle, 9))
            var RuntimeID: UUID!
            if let Column10 = sqlite3_column_text(QueryHandle, 10)
            {
                let RID = String(cString: Column10)
                RuntimeID = UUID(uuidString: RID)!
            }
            else
            {
                RuntimeID = UUID()
            }
            //let RuntimeID = String(cString: sqlite3_column_text(QueryHandle, 10))
            let Site = WorldHeritageSite(UID, ID, Name, Year, Latitude, Longitude, Hectares,
                                         Category, ShortCategory, Countries, RuntimeID)
            Results.append(Site)
        }
        let PlaceGroup = WordGroup()
        for Place in Results
        {
            PlaceGroup.AddWord(Place.Name)
        }
        GlobalWordLists.AddGlobalWordList(For: .UNESCOSiteNames, WordList: PlaceGroup)
        return Results
    }
    
    /// Returns the number of World Heritage Sites in the database.
    /// - Returns: Number of World Heritage Sites in the database. 0 on error.
    public static func WorldHeritageSiteCount() -> Int
    {
        let Result = SQL.RowCount(Database: DBIF.MappableHandle, Table: MappableTableNames.UNESCOSites.rawValue)
        switch Result
        {
            case .success(let Count):
                return Count
                
            default:
                return 0
        }
    }
    
    /// Returns a list of all unique county names in the passed set of world heritage sites.
    /// - Parameter FromSites: List of world heritage sites.
    /// - Returns: Array of unique country names derived from the passed list of sites.
    public static func WorldHeritageCountryList(_ FromSites: [WorldHeritageSite]) -> [String]
    {
        var CountrySet = Set<String>()
        for Site in FromSites
        {
            CountrySet.insert(Site.Countries)
        }
        return Array(CountrySet).sorted()
    }
    
    /// Returns a list of all unique inscription years in the passed set of world heritage sites.
    /// - Parameter FromSites: List of world heritage sites.
    /// - Returns: Array of unique inscription years derived from the passed list of sites.
    public static func WorldHeritageInscriptionDates(_ FromSites: [WorldHeritageSite]) -> [Int]
    {
        var YearSet = Set<Int>()
        for Site in FromSites
        {
            YearSet.insert(Site.DateInscribed)
        }
        return Array(YearSet).sorted()
    }
    
    /// Filter a set of World Heritage Sites by country.
    /// - Parameter Sites: The set of World Heritage Sites to filter.
    /// - Parameter ByCountry: The country to return. Case senstive. If empty, all countries are returned.
    /// - Returns: List of World Heritage Sites filtered by the supplied parameters.
    public static func FilterWorldHeritageSites(_ Sites: [WorldHeritageSite], ByCountry: String) -> [WorldHeritageSite]
    {
        if ByCountry.isEmpty
        {
            return Sites
        }
        var Results = [WorldHeritageSite]()
        for Site in Sites
        {
            if Site.Countries == ByCountry
            {
                Results.append(Site)
            }
        }
        return Results
    }
    
    /// Filter a set of World Heritage Sites by date inscribed.
    /// - Parameter Sites: The set of World Heritage Sites to filter.
    /// - Parameter ByYear: The year to filter by. If nil, all World Heritage Sites are returned.
    /// - Parameter YearFilter: How to use `ByYear` when filtering sites.
    /// - Returns: List of World Heritage Sites filtered by the supplied parameters.
    public static func FilterWorldHeritageSites(_ Sites: [WorldHeritageSite], ByYear: Int? = nil,
                                                YearFilter: YearFilters) -> [WorldHeritageSite]
    {
        if let Year = ByYear
        {
            var Results = [WorldHeritageSite]()
            for Site in Sites
            {
                switch YearFilter
                {
                    case .Only:
                        if Site.DateInscribed == Year
                        {
                            Results.append(Site)
                        }
                        
                    case .UpTo:
                        if Site.DateInscribed <= Year
                        {
                            Results.append(Site)
                        }
                        
                    case .After:
                        if Site.DateInscribed >= Year
                        {
                            Results.append(Site)
                        }
                        
                    case .All:
                        Results.append(Site)
                }
            }
            return Results
        }
        else
        {
            return Sites
        }
    }
    
    /// Filter a set of World Heritage Sites by site type.
    /// - Parameter Sites: The set of World Heritage Sites to filter.
    /// - Parameter ByType: The type of stie to return.
    /// - Returns: List of World Heritage Sites filtered by the supplied parameters.
    public static func FilterWorldHeritageSites(_ Sites: [WorldHeritageSite], ByType: WorldHeritageSiteTypes) -> [WorldHeritageSite]
    {
        var Results = [WorldHeritageSite]()
        for Site in Sites
        {
            switch ByType
            {
                case .Mixed:
                    if Site.Category == "Mixed"
                    {
                        Results.append(Site)
                    }
                    
                case .Cultural:
                    if Site.Category == "Cultural"
                    {
                        Results.append(Site)
                    }
                    
                case .Natural:
                    if Site.Category == "Natural"
                    {
                        Results.append(Site)
                    }
                    
                case .AllSites:
                    Results.append(Site)
            }
        }
        return Results
    }
    
    /// Apply multiple filters to the source list of World Heritage Sites.
    /// - Note: Filters are applied in this order:
    ///        1 Site type.
    ///        2 Site country.
    ///        3 Site inscribed year.
    /// - Parameter Sites: Source list to filter.
    /// - Parameter ByType: The type of site to return.
    /// - Parameter ByCountry: The country of the site.
    /// - Parameter ByYear: The year the site was inscribed.
    /// - Parameter WithYearFilter: How to filter the year.
    /// - Returns: List of sites that meet all passed criteria.
    public static func FilterWorldHeritageSites(_ Sites: [WorldHeritageSite],
                                                ByType: WorldHeritageSiteTypes,
                                                ByCountry: String,
                                                ByYear: Int?,
                                                WithYearFilter: YearFilters) -> [WorldHeritageSite]
    {
        var Results = [WorldHeritageSite]()
        Results = FilterWorldHeritageSites(Sites, ByType: ByType)
        Results = FilterWorldHeritageSites(Results, ByCountry: ByCountry)
        Results = FilterWorldHeritageSites(Results, ByYear: ByYear, YearFilter: WithYearFilter)
        return Results
    }
    
    /// Applies all currently saved World Heritage Site filters to the passed list of World Heritage
    /// Sites and returns the result.
    /// - Parameter Sites: The list of World Heritage Sites to filter.
    /// - Returns: Filtered result.
    public static func FilterWorldHeritageSites(_ Sites: [WorldHeritageSite]) -> [WorldHeritageSite]
    {
#if true
        let SiteType = Settings.GetEnum(ForKey: .WorldHeritageSiteType, EnumType: WorldHeritageSiteTypes.self, Default: .AllSites)
        let SiteCountry = Settings.GetString(.SiteCountry, "")
        let SiteYear = Settings.GetInt(.SiteYear)
        let SiteYearFilter = Settings.GetEnum(ForKey: .SiteYearFilter, EnumType: YearFilters.self, Default: .All)
#else
        let SiteType = Settings.GetWorldHeritageSiteTypeFilter()
        let SiteCountry = Settings.GetWorldHeritageSiteCountry()
        let SiteYear = Settings.GetWorldHeritageSiteInscribedYear()
        let SiteYearFilter = Settings.GetWorldHeritageSiteInscribedYearFilter()
#endif
        return FilterWorldHeritageSites(Sites,
                                        ByType: SiteType,
                                        ByCountry: SiteCountry,
                                        ByYear: SiteYear,
                                        WithYearFilter: SiteYearFilter)
    }
}
