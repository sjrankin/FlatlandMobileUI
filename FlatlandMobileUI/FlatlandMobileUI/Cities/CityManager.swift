//
//  CityManager.swift
//  CityManager
//
//  Created by Stuart Rankin on 7/19/21. Adapted from Flatland View
//

import Foundation
import UIKit

/// Manages cities in the mappable database.
class CityManager
{
    /// Initialize the City Manager. Loads all cities from the database.
    public static func Initialize()
    {
#if true
        AllCities = Settings.GetCities(.CityList)
        OtherCities = Settings.GetCities(.UserCityList)
#else
        AllCities = MainController.GetAllCities()
        OtherCities = MainController.GetAllAdditionalCities()
#endif
    }
    
    /// All cities from the database.
    public static var AllCities: [City2]? = nil
    
    /// All cities from the other/additional cities database.
    public static var OtherCities: [City2]? = nil
    
    /// Search for a city with the passed name.
    /// - Parameter Name: The name of the city. Case insensitive.
    /// - Returns: The city's record if found, nil if not.
    public static func FindCity(Name: String) -> City2?
    {
        if AllCities == nil
        {
            return nil
        }
        return FindCity(In: AllCities!, WithName: Name)
    }
    
    /// Search for a city with the passed name.
    /// - Parameter In: The list of cities to search.
    /// - Parameter WithName: The name of the city. Case insensitive.
    /// - Returns: The city's record if found, nil if not.
    public static func FindCity(In SourceList: [City2], WithName: String) -> City2?
    {
        for SomeCity in SourceList
        {
            if SomeCity.Name.lowercased() == WithName.lowercased()
            {
                return SomeCity
            }
        }
        return nil
    }
    
    /// Returns all capital cities.
    /// - Parameter DoSort: If true, cities are returned in name-sorted order.
    /// - Returns: All cities marked as a capital city.
    public static func AllCapitalCities(DoSort: Bool = false) -> [City2]
    {
        if AllCities != nil
        {
            return AllCapitalCities(In: AllCities!, DoSort: DoSort)
        }
        else
        {
            return [City2]()
        }
    }
    
    /// Returns all capital cities in the passed city list.
    /// - Parameter In: The list of cities to search for capital cities.
    /// - Parameter DoSort: If true, cities are returned in name-sorted order.
    /// - Returns: All cities marked as a capital city.
    public static func AllCapitalCities(In SourceList: [City2], DoSort: Bool = false) -> [City2]
    {
        var CapitalCities = [City2]()
        for SomeCity in SourceList
        {
            if SomeCity.IsCapital
            {
                CapitalCities.append(SomeCity)
            }
        }
        if DoSort
        {
            CapitalCities.sort(by: {$0.Name < $1.Name})
        }
        return CapitalCities
    }
    
    /// Return a list of all cities with a metropolitan population.
    /// - Parameter DoSort: If true, the returned list will be sorted in metropolitan population order.
    /// - Returns: List of all cities with a metropolitan population. If cities haven't been loaded, an empty
    ///            array is returned.
    public static func AllMetroAreas(DoSort: Bool = false) -> [City2]
    {
        if AllCities != nil
        {
            return AllMetroAreas(In: AllCities!, DoSort: DoSort)
        }
        else
        {
            return [City2]()
        }
    }
    
    /// Return a list of all cities with a metropolitan population.
    /// - Parameter In: The list of cities to search.
    /// - Parameter DoSort: If true, the returned list will be sorted in metropolitan population order.
    /// - Returns: List of all cities with a metropolitan population.
    public static func AllMetroAreas(In SourceList: [City2], DoSort: Bool = false) -> [City2]
    {
        var MetroAreas = [City2]()
        for SomeCity in SourceList
        {
            if SomeCity.MetropolitanPopulation != nil
            {
                MetroAreas.append(SomeCity)
            }
        }
        if DoSort
        {
            MetroAreas.sort(by: {$0.MetropolitanPopulation! < $1.MetropolitanPopulation!})
        }
        return MetroAreas
    }
    
    /// Returns a list of all cities in the supplied continent.
    /// - Parameter Continent: The continent whose cities will be returned.
    /// - Parameter DoSort: If true, the returned list will be sorted in city names.
    /// - Returns: List of cities in the specified continent. If cities haven't been loaded, an empty array
    ///            is returned.
    public static func CitiesIn(_ Continent: Continents, DoSort: Bool = false) -> [City2]
    {
        if AllCities != nil
        {
            return CitiesIn(In: AllCities!, Continent: Continent, DoSort: DoSort)
        }
        else
        {
            return [City2]()
        }
    }
    
    /// Returns a list of all cities in the supplied continent.
    /// - Parameter In: List of cities to search.
    /// - Parameter Continent: The continent whose cities will be returned.
    /// - Parameter DoSort: If true, the returned list will be sorted in city names.
    /// - Returns: List of cities in the specified continent.
    public static func CitiesIn(In SourceList: [City2], Continent: Continents, DoSort: Bool = false) -> [City2]
    {
        var ContinentalCities = [City2]()
        for SomeCity in SourceList
        {
            if SomeCity.Continent == Continent
            {
                ContinentalCities.append(SomeCity)
            }
        }
        if DoSort
        {
            ContinentalCities.sort(by: {$0.Name < $1.Name})
        }
        return ContinentalCities
    }
    
    /// Returns a list of all cities in the supplied country.
    /// - Parameter Country: The continent whose cities will be returned. Country names are
    ///                      case insensitive
    /// - Parameter DoSort: If true, the returned list will be sorted in city names.
    /// - Returns: List of cities in the specified country.
    public static func CitiesIn(Country: String, DoSort: Bool = false) -> [City2]
    {
        if AllCities != nil
        {
            return CitiesIn(In: AllCities!, Country: Country, DoSort: DoSort)
        }
        else
        {
            return [City2]()
        }
    }
    
    /// Returns a list of all cities in the supplied country.
    /// - Parameter In: The list of cities to search.
    /// - Parameter Country: The continent whose cities will be returned. Country names are
    ///                      case insensitive
    /// - Parameter DoSort: If true, the returned list will be sorted in city names.
    /// - Returns: List of cities in the specified country.
    public static func CitiesIn(In SourceList: [City2], Country: String, DoSort: Bool = false) -> [City2]
    {
        var CountryCities = [City2]()
        for SomeCity in SourceList
        {
            if SomeCity.Country.lowercased() == Country.lowercased()
            {
                CountryCities.append(SomeCity)
            }
        }
        if DoSort
        {
            CountryCities.sort(by: {$0.Name < $1.Name})
        }
        return CountryCities
    }
    
    /// Return a list of cities whose population is greater than or equal to the passed value.
    /// - Parameter GreaterThan: The minimum value the population of the city must be to be included in the returned list.
    /// - Parameter UseMetroPopulation: If true, the metropolitan population is used. Otherwise, the city population
    ///                                 is used. In either case, if the population value is nil, it will not be
    ///                                 included in the returned list.
    /// - Parameter DoSort: If true, the returned list is sorted in name order.
    /// - Returns: List of cities whose population is greater than or equal to `GreaterThan`.
    public static func CitiesByPopulation(GreaterThan: Int, UseMetroPopulation: Bool, DoSort: Bool = false) -> [City2]
    {
        if AllCities != nil
        {
            return CitiesByPopulation(In: AllCities!, GreaterThan: GreaterThan, UseMetroPopulation: UseMetroPopulation, DoSort: DoSort)
        }
        else
        {
            return [City2]()
        }
    }
    
    /// Return a list of cities whose population is greater than or equal to the passed value.
    /// - Parameter In: List of cities to search.
    /// - Parameter GreaterThan: The minimum value the population of the city must be to be included in the returned list.
    /// - Parameter UseMetroPopulation: If true, the metropolitan population is used. Otherwise, the city population
    ///                                 is used. In either case, if the population value is nil, it will not be
    ///                                 included in the returned list.
    /// - Parameter DoSort: If true, the returned list is sorted in name order.
    /// - Returns: List of cities whose population is greater than or equal to `GreaterThan`.
    public static func CitiesByPopulation(In SourceList: [City2], GreaterThan: Int, UseMetroPopulation: Bool, DoSort: Bool = false) -> [City2]
    {
        var CityList = [City2]()
        for SomeCity in SourceList
        {
            if UseMetroPopulation
            {
                if let Population = SomeCity.MetropolitanPopulation
                {
                    if Population >= GreaterThan
                    {
                        CityList.append(SomeCity)
                    }
                }
            }
            else
            {
                if let Population = SomeCity.Population
                {
                    if Population >= GreaterThan
                    {
                        CityList.append(SomeCity)
                    }
                }
            }
        }
        if DoSort
        {
            CityList.sort(by: {$0.Name < $1.Name})
        }
        return CityList
    }
    
    /// Return a list of cities whose population is less than the passed value.
    /// - Parameter LessThan: The maximum value the population of the city must be to be included in the returned list.
    /// - Parameter UseMetroPopulation: If true, the metropolitan population is used. Otherwise, the city population
    ///                                 is used. In either case, if the population value is nil, it will not be
    ///                                 included in the returned list.
    /// - Parameter DoSort: If true, the returned list is sorted in name order.
    /// - Returns: List of cities whose population is less than `LessThan`.
    public static func CitiesByPopulation(LessThan: Int, UseMetroPopulation: Bool, DoSort: Bool = false) -> [City2]
    {
        if AllCities != nil
        {
            return CitiesByPopulation(In: AllCities!, LessThan: LessThan, UseMetroPopulation: UseMetroPopulation, DoSort: DoSort)
        }
        else
        {
            return [City2]()
        }
    }
    
    /// Return a list of cities whose population is less than the passed value.
    /// - Parameter In: The list of cities to search.
    /// - Parameter LessThan: The maximum value the population of the city must be to be included in the returned list.
    /// - Parameter UseMetroPopulation: If true, the metropolitan population is used. Otherwise, the city population
    ///                                 is used. In either case, if the population value is nil, it will not be
    ///                                 included in the returned list.
    /// - Parameter DoSort: If true, the returned list is sorted in name order.
    /// - Returns: List of cities whose population is less than `LessThan`.
    public static func CitiesByPopulation(In SourceList: [City2], LessThan: Int, UseMetroPopulation: Bool, DoSort: Bool = false) -> [City2]
    {
        var CityList = [City2]()
        for SomeCity in SourceList
        {
            if UseMetroPopulation
            {
                if let Population = SomeCity.MetropolitanPopulation
                {
                    if Population < LessThan
                    {
                        CityList.append(SomeCity)
                    }
                }
            }
            else
            {
                if let Population = SomeCity.Population
                {
                    if Population < LessThan
                    {
                        CityList.append(SomeCity)
                    }
                }
            }
        }
        if DoSort
        {
            CityList.sort(by: {$0.Name < $1.Name})
        }
        return CityList
    }
    
    /// Returns the most populated city in the passed list of cities.
    /// - Parameter In: The list of cities to test.
    /// - Parameter UseMetroPopulation: If true, metropolitan populations are used. If a city does
    ///                                 not have a metropolitcan population, the normal city population
    ///                                 is used instead. Defaults to `true`.
    /// - Returns: The city with the greatest population in the passed list. Nil if none found.
    public static func MostPopulatedCity(In List: [City2], UseMetroPopulation: Bool = true) -> City2?
    {
        var Population = 0
        var TheCity: City2? = nil
        for SomeCity in List
        {
            if UseMetroPopulation
            {
                if let Metro = SomeCity.MetropolitanPopulation
                {
                    if Metro > Population
                    {
                        Population = Metro
                        TheCity = SomeCity
                    }
                }
                else
                {
                    if let CityPop = SomeCity.Population
                    {
                        if CityPop > Population
                        {
                            Population = CityPop
                            TheCity = SomeCity
                        }
                    }
                }
            }
            else
            {
                if let CityPop = SomeCity.Population
                {
                    if CityPop > Population
                    {
                        Population = CityPop
                        TheCity = SomeCity
                    }
                }
            }
        }
        return TheCity
    }
    
    /// Returns the population of the most populated city in the passed list.
    /// - Parameter In: The list of cities to test.
    /// - Parameter UseMetroPopulation: If true, metropolitan populations are used. If a city does
    ///                                 not have a metropolitcan population, the normal city population
    ///                                 is used instead. Defaults to `true`.
    /// - Returns: The population of the most populated city in the list. If `UseMetroPopulation` is
    ///            true but the city does not have a metropolitan population, the city population is
    ///            returned. If the city does not have a city population, 0 is returned.
    public static func MostPopulatedCityPopulation(In List: [City2], UseMetroPopulation: Bool = true) -> Int
    {
        if let PopulatedCity = MostPopulatedCity(In: List, UseMetroPopulation: UseMetroPopulation)
        {
            if UseMetroPopulation
            {
                if let Metro = PopulatedCity.MetropolitanPopulation
                {
                    return Metro
                }
                else
                {
                    if let CityPop = PopulatedCity.Population
                    {
                        return CityPop
                    }
                }
            }
            else
            {
                if let CityPop = PopulatedCity.Population
                {
                    return CityPop
                }
            }
        }
        return 0
    }
    
    /// Returns a list of cities that have a metropolitan population associated with it. All known
    /// cities are searched.
    /// - Returns: List of cities with a valid metropolitan population.
    public static func CitiesWithMetroPopulation() -> [City2]
    {
        if AllCities != nil
        {
            return CitiesWithMetroPopulation(In: AllCities!)
        }
        else
        {
            return [City2]()
        }
    }
    
    /// Returns a list of cities from `In` that have a metropolitan population associated.
    /// - Returns: List of cities in `In` that have a valid metropolitan population.
    public static func CitiesWithMetroPopulation(In SourceList: [City2]) -> [City2]
    {
        var Final = [City2]()
        for SomeCity in SourceList
        {
            if SomeCity.MetropolitanPopulation != nil
            {
                Final.append(SomeCity)
            }
        }
        return Final
    }
    
    /// Returns a list of cities that have a valid population. All known cities are searched.
    /// - Returns: List of cities that have a valid population.
    public static func CitiesWithPopulation() -> [City2]
    {
        if AllCities != nil
        {
            return CitiesWithPopulation(In: AllCities!)
        }
        else
        {
            return [City2]()
        }
    }
    
    /// Returns a list of cities from `In` that have a population associated.
    /// - Returns: List of cities in `In` that have a valid population.
    public static func CitiesWithPopulation(In SourceList: [City2]) -> [City2]
    {
        var Final = [City2]()
        for SomeCity in SourceList
        {
            if SomeCity.Population != nil
            {
                Final.append(SomeCity)
            }
        }
        return Final
    }
    
    /// Returns a list of cities by population. The top `N` cities are returned. All known cities
    /// are searched.
    /// - Parameter N: The top-most n city value. For example, if `N` is 50, the top 50 cities by
    ///                population are returned.
    /// - Parameter UseMetroPopulation: If true, the metropolitan population is used to determine
    ///             which cities to return.
    /// - Returns: List of cities that meet the passed criteria.
    public static func TopNCities(N: Int, UseMetroPopulation: Bool = true) -> [City2]
    {
        if AllCities != nil
        {
            return TopNCities(In: AllCities!, N: N, UseMetroPopulation: UseMetroPopulation)
        }
        else
        {
            return [City2]()
        }
    }
    
    /// Returns a list of cities by population. The top `N` cities are returned.
    /// - Parameter In: The source list of cities to search.
    /// - Parameter N: The top-most n city value. For example, if `N` is 50, the top 50 cities by
    ///                population are returned.
    /// - Parameter UseMetroPopulation: If true, the metropolitan population is used to determine
    ///             which cities to return.
    /// - Returns: List of cities that meet the passed criteria.
    public static func TopNCities(In SourceList: [City2], N: Int, UseMetroPopulation: Bool = true) -> [City2]
    {
        var Sorted = [City2]()
        if UseMetroPopulation
        {
            Sorted = CitiesWithMetroPopulation(In: SourceList).sorted(by: {$0.MetropolitanPopulation! > $1.MetropolitanPopulation!})
        }
        else
        {
            Sorted = CitiesWithPopulation(In: SourceList).sorted(by: {$0.Population! > $1.Population!})
        }
        let FinalCount = Sorted.count - N
        if FinalCount < 1
        {
            return Sorted
        }
        if FinalCount > Sorted.count - 1
        {
            return Sorted
        }
        return Sorted.dropLast(FinalCount)
    }
    
    /// Return an array of cities based on teh user-settings filter.
    /// - Returns: Array of cities based on the user settings.
    public static func FilteredCities() -> [City2]
    {
        if AllCities != nil
        {
            return FilteredCities(In: AllCities!)
        }
        else
        {
            return [City2]()
        }
    }
    
    /// Return an array of cities based on the user-settings filter.
    /// - Parameter In: The source of the cities to filter.
    /// - Returns: Array of cities based on the user settings.
    public static func FilteredCities(In SourceList: [City2]) -> [City2]
    {
        if AllCities == nil
        {
            return [City2]()
        }
        if Settings.GetBool(.ShowCitiesByPopulation)
        {
            switch Settings.GetEnum(ForKey: .PopulationFilterType, EnumType: PopulationFilterTypes.self,
                                    Default: .ByRank)
            {
                case .ByRank:
                    let Rank = Settings.GetInt(.PopulationRank)
                    let IsMetro = Settings.GetBool(.PopulationRankIsMetro)
                    let TopCities = TopNCities(In: AllCities!, N: Rank, UseMetroPopulation: IsMetro)
                    return TopCities
                    
                case .ByPopulation:
                    let GreaterThan = Settings.GetBool(.PopulationFilterGreater)
                    let ComparedTo = Settings.GetInt(.PopulationFilterValue, IfZero: 1000000)
                    let UseMetro = Settings.GetBool(.PopulationRankIsMetro)
                    var TopCities = [City2]()
                    for SomeCity in AllCities!
                    {
                        if GreaterThan
                        {
                            if UseMetro
                            {
                                if SomeCity.GetPopulation(true) > ComparedTo
                                {
                                    TopCities.append(SomeCity)
                                }
                            }
                            else
                            {
                                if SomeCity.GetPopulation(false) > ComparedTo
                                {
                                    TopCities.append(SomeCity)
                                }
                            }
                        }
                        else
                        {
                            if UseMetro
                            {
                                if SomeCity.GetPopulation(true) < ComparedTo
                                {
                                    TopCities.append(SomeCity)
                                }
                            }
                            else
                            {
                                if SomeCity.GetPopulation(false) < ComparedTo
                                {
                                    TopCities.append(SomeCity)
                                }
                            }
                        }
                    }
                    Debug.Print("Found \(TopCities.count) cities")
                    return TopCities
            }
        }
        var Filters = [CityTypes]()
        if Settings.GetBool(.ShowWorldCities)
        {
            Filters.append(.World)
        }
        if Settings.GetBool(.ShowCapitalCities)
        {
            Filters.append(.Capital)
        }
        if Settings.GetBool(.ShowCustomCities)
        {
            Filters.append(.User)
        }
        if Settings.GetBool(.ShowAfricanCities)
        {
            Filters.append(.African)
        }
        if Settings.GetBool(.ShowAsianCities)
        {
            Filters.append(.Asian)
        }
        if Settings.GetBool(.ShowEuropeanCities)
        {
            Filters.append(.European)
        }
        if Settings.GetBool(.ShowNorthAmericanCities)
        {
            Filters.append(.NorthAmerican)
        }
        if Settings.GetBool(.ShowSouthAmericanCities)
        {
            Filters.append(.SouthAmerican)
        }
        
        let CitySet = GetCities(In: AllCities!, FilteredBy: Filters)
        return Array(CitySet)
    }
    
    /// Returns a set of cities from the passed array based on `FilteredBy`.
    /// - Parameter In: The set of cities to search.
    /// - Parameter FilteredBy: Array of filters. A city will be returned if any one of the filters
    ///                         is a match.
    /// - Returns: Set of cities, each of which matches at least one of the criteria in `FilteredBy`.
    public static func GetCities(In SourceList: [City2], FilteredBy: [CityTypes]) -> Set<City2>
    {
        var Filtered = Set<City2>()
        for SomeCity in SourceList
        {
            if FilteredBy.contains(.African)
            {
                if SomeCity.Continent == .Africa
                {
                    Filtered.insert(SomeCity)
                }
            }
            if FilteredBy.contains(.Asian)
            {
                if SomeCity.Continent == .Asia
                {
                    Filtered.insert(SomeCity)
                }
            }
            if FilteredBy.contains(.European)
            {
                if SomeCity.Continent == .Europe
                {
                    Filtered.insert(SomeCity)
                }
            }
            if FilteredBy.contains(.NorthAmerican)
            {
                if SomeCity.Continent == .NorthAmerica
                {
                    Filtered.insert(SomeCity)
                }
            }
            if FilteredBy.contains(.SouthAmerican)
            {
                if SomeCity.Continent == .SouthAmerica
                {
                    Filtered.insert(SomeCity)
                }
            }
            if FilteredBy.contains(.Capital)
            {
                if SomeCity.IsCapital
                {
                    Filtered.insert(SomeCity)
                }
            }
            if FilteredBy.contains(.User)
            {
                if SomeCity.IsUserCity
                {
                    Filtered.insert(SomeCity)
                }
            }
            if FilteredBy.contains(.World)
            {
                if SomeCity.IsWorldCity
                {
                    Filtered.insert(SomeCity)
                }
            }
        }
        return Filtered
    }
    
    enum CityTypes
    {
        case African
        case Asian
        case European
        case NorthAmerican
        case SouthAmerican
        case Capital
        case User
        case World
    }
    
    /// Returns a list of all cities read from the database.
    /// - Returns: List of all cities.
    public static func GetAllCities() -> [City2]
    {
        if AllCities != nil
        {
            return AllCities!
        }
        else
        {
            return [City2]()
        }
    }
    
    /// Return the maximum and minimum population in the set a set of cities.
    /// - Parameter CityList: The list of cities whose maximum and minimum populations will be returned.
    /// - Parameter UseMetroPopulation: If true, the metropolitan population is used. If false, the city
    ///                                 population is used. If no population is available, the city is
    ///                                 ignored for the purposes of this function.
    /// - Returns: Tuple with the maximum population and the minimum population values.
    public static func GetPopulationsIn(CityList: [City2], UseMetroPopulation: Bool = false) -> (Max: Int, Min: Int)
    {
        var MaxValue: Int = Int.min
        var MinValue: Int = Int.max
        for SomeCity in CityList
        {
            if UseMetroPopulation
            {
                if let Population = SomeCity.MetropolitanPopulation
                {
                    if MaxValue < Population
                    {
                        MaxValue = Population
                    }
                    if MinValue > Population
                    {
                        MinValue = Population
                    }
                }
            }
            else
            {
                if let Population = SomeCity.Population
                {
                    if MaxValue < Population
                    {
                        MaxValue = Population
                    }
                    if MinValue > Population
                    {
                        MinValue = Population
                    }
                }
            }
        }
        return (MaxValue, MinValue)
    }
    
    /// Returns a color for the passed city based on the continent of the city.
    /// - Parameter SomeCity: The city whose continent-based color is returned.
    /// - Parameter OverrideType: If this value is not `.None`, continental colors are returned. Otherwise,
    ///                           the type of color specified by this parameter is returned.
    public static func ColorForCity(_ SomeCity: City2, OverrideType: CityColorOverrides = .None) -> UIColor
    {
        switch OverrideType
        {
            case .None:
                switch SomeCity.Continent
                {
                    case .Africa:
                        return UIColor.Botan
                        //                        return Settings.GetColor(.AfricanCityColor, UIColor.Botan)
                        
                    case .Asia:
                        return UIColor.LightSkyBlue
                        //                        return Settings.GetColor(.AsianCityColor, UIColor.PrussianBlue)
                        
                    case .Europe:
                        return UIColor.ArtichokeGreen
                        //                        return Settings.GetColor(.EuropeanCityColor, UIColor.Midori)
                        
                    case .NorthAmerica:
                        return UIColor.Pistachio
                        //                        return Settings.GetColor(.NorthAmericanCityColor, UIColor.Pistachio)
                        
                    case .SouthAmerica:
                        return UIColor.Gold
                        //                        return Settings.GetColor(.SouthAmericanCityColor, UIColor.Gold)
                        
                    case .NoName:
                        return UIColor.white
                }
                
            case .CapitalCities:
                return UIColor.cyan
                //                return Settings.GetColor(.CapitalCityColor, UIColor.cyan)
                
            case .WorldCities:
                return UIColor.yellow
                //return Settings.GetColor(.WorldCityColor, UIColor.yellow)
                
            case .AdditionalCities:
                return SomeCity.CityColor
        }
    }
}
