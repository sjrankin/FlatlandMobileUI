//
//  City2.swift
//  City2
//
//  Created by Stuart Rankin on 7/19/21. Adapted from Flatland View.
//

import Foundation
import UIKit

class City2: Hashable
{
    /// Default initializer. No properties set.
    init()
    {
    }
    
    /// Initialize the city from a point of interest.
    /// - Parameter From: The point of interest used to populate this class.
    init(From POI: POI2)
    {
        Name = POI.Name
        CityID = POI.ID
        Latitude = POI.Latitude
        Longitude = POI.Longitude
        CityColor = POI.Color
        IsUserCity = true
    }
    
    /// Initializer.
    /// - Parameters:
    ///   - Name: The name of the city.
    ///   - Country: The country where the city is.
    ///   - IsCapital: Capital city flag.
    ///   - Population: The population of the city or nil if not known.
    ///   - MetroPopulation: The population of the metropolitan area or nil if not known.
    ///   - Latitude: The latitude of the city.
    ///   - Longitude: The longitude of the city.
    ///   - Continent: Name of the continent of the city.
    ///   - ID: ID of the city.
    ///   - IsAddition: If true, the city is from the additional cities table. Otherwise,
    ///                 the city is from the standard city table. Defaults to `false`.
    ///   - SubNational: The subnational location. Defaults to empty string.
    init(_ Name: String, _ Country: String, _ IsCapital: Bool, _ Population: Int?, _ MetroPopulation: Int?,
         _ Latitude: Double, _ Longitude: Double, _ Continent: String, _ ID: UUID,
         _ IsAddition: Bool = false, _ SubNational: String = "")
    {
        var FinalContinent = Continent
        if FinalContinent == "NorthAmerica"
        {
            FinalContinent = Continents.NorthAmerica.rawValue
        }
        if FinalContinent == "SouthAmerica"
        {
            FinalContinent = Continents.SouthAmerica.rawValue
        }
        self.Continent = Continents(rawValue: FinalContinent)!
        self.Country = Country
        self.Name = Name
        self.IsCapital = IsCapital
        self.Population = Population
        self.MetropolitanPopulation = MetroPopulation
        self.Latitude = Latitude
        self.Longitude = Longitude
        self.CityID = ID
        self.IsAdditionalCity = IsAddition
        self.SubNational = SubNational
    }
    
    /// Return a population for the city. Always returns a value.
    /// - Parameter MetroPopulation: If true, the metropolitan population is returned.
    /// - Returns: Population of the city. If `MetroPopulation` is true and there is no metropolitan
    ///            population available, the city population is returned. If no city population is
    ///            available, `0` is returned.
    public func GetPopulation(_ MetroPopulation: Bool = true) -> Int
    {
        if MetroPopulation
        {
            if let Metro = MetropolitanPopulation
            {
                return Metro
            }
            else
            {
                if let CityPop = Population
                {
                    return CityPop
                }
            }
        }
        else
        {
            if let CityPop = Population
            {
                return CityPop
            }
        }
        return 0
    }
    
    /// Convenience property that holds a base-line location of the city after it was initially plotted.
    public var PlottedPoint: CGPoint? = nil
    
    /// City name.
    public var Name: String = ""
    
    /// Country name.
    public var Country: String = ""
    
    /// Capital city flag.
    public var IsCapital: Bool = false
    
    /// Population of the city. Nil if not known.
    public var Population: Int? = nil
    
    /// Population of the metropolitan area, or nil if not known.
    public var MetropolitanPopulation: Int? = nil
    
    /// Latitude of the city.
    public var Latitude: Double = 0.0
    
    /// Longitude of the city.
    public var Longitude: Double = 0.0
    
    /// Continent of the city.
    public var Continent: Continents = .Asia
    
    /// Color to use to render the city.
    public var CityColor: UIColor = UIColor.yellow
    
    /// User city flag.
    public var IsUserCity: Bool = false
    
    /// World city flag.
    public var IsWorldCity: Bool = false
    
    /// City ID.
    public var CityID: UUID = UUID()
    
    /// City PK.
    public var CityPK: Int? = nil
    
    /// Used by the UI when creating custom city lists.
    public var IsCustomCity: Bool = false
    
    /// Subnational location. Used by additional cities.
    public var SubNational: String = ""
    
    /// Determines which table in the database the city is from.
    public var IsAdditionalCity: Bool = false
    
    /// The date the city was added.
    public var Added: Date? = nil
    
    /// The date the city was modified.
    public var Modified: Date? = nil
    
    /// Holds the dirty flag.
    private var _IsDirty: Bool = false
    /// The dirty flag.
    public var IsDirty: Bool
    {
        get
        {
            return _IsDirty
        }
        set
        {
            _IsDirty = newValue
        }
    }
    
    // MARK: - Required for Hashable protocol.
    
    static func == (lhs: City2, rhs: City2) -> Bool
    {
        return ObjectIdentifier(lhs) == ObjectIdentifier(rhs)
    }
    
    func hash(into hasher: inout Hasher)
    {
        hasher.combine(ObjectIdentifier(self))
    }
}
