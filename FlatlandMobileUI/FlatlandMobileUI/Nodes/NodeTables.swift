//
//  NodeTables.swift
//  Flatland
//
//  Created by Stuart Rankin on 9/28/20. Adapted from Flatland View.
//  Copyright © 2020 Stuart Rankin. All rights reserved.
//

import Foundation
import UIKit
import SceneKit

/// This class maintains a dictionary of dictionaries of `SCNNode2` IDs and related data for use when the
/// user wants more information about a given visual node.
class NodeTables
{
    /// Initialize the node tables.
    /// - Warning: If city data and World Heritage Sites have not yet been loaded, item data for both class
    ///            types will be missing.
    /// - Note: City data is loaded here.
    /// - Parameter Unesco: Array of World Heritage Sites.
    public static func Initialize(Unesco: [WorldHeritageSite])
    {
        for SomeCity in CityManager.AllCities!
        {
            CityTable[SomeCity.CityID] = DisplayItem(ID: SomeCity.CityID, ItemType: .City, Name: SomeCity.Name,
                                                     Numeric: Double(SomeCity.GetPopulation()),
                                                     Location: GeoPoint(SomeCity.Latitude, SomeCity.Longitude),
                                                     Description: "",
                                                     ItemID: SomeCity.CityID)
        }
        
        for Site in Unesco
        {
            UNESCOTable[Site.RuntimeID!] = DisplayItem(ID: Site.RuntimeID!, ItemType: .WorldHeritageSite,
                                                       Name: Site.Name, Numeric: Double(Site.DateInscribed),
                                                       Location: GeoPoint(Site.Latitude, Site.Longitude),
                                                       Description: Site.Category,
                                                       ItemID: Site.RuntimeID!)
        }
        
        MiscTable[NorthPoleID] = DisplayItem(ID: NorthPoleID, ItemType: .Miscellaneous, Name: "North Pole",
                                             Numeric: 0.0, Location: GeoPoint(90.0, 0.0),
                                             Description: "Earth's north pole.",
                                             ItemID: UUID())
        MiscTable[SouthPoleID] = DisplayItem(ID: SouthPoleID, ItemType: .Miscellaneous, Name: "South Pole",
                                             Numeric: 0.0, Location: GeoPoint(-90.0, 0.0),
                                             Description: "Earth's south pole.",
                                             ItemID: UUID())
        MiscTable[SunID] = DisplayItem(ID: SunID, ItemType: .Miscellaneous, Name: "Sun",
                                       Numeric: 0.0, Location: nil, Description: "The sun",
                                       ItemID: UUID())
        MiscTable[SunID]?.HasNumber = false
#if false
        MiscTable[EarthGlobe] = DisplayItem(ID: EarthGlobe, ItemType: .Miscellaneous, Name: "Earth Node",
                                            Numeric: 0.0, Location: nil, Description: "Main Earth Node")
        MiscTable[EarthGlobe]?.HasNumber = false
        MiscTable[SeaGlobe] = DisplayItem(ID: SeaGlobe, ItemType: .Miscellaneous, Name: "Sea Node",
                                          Numeric: 0.0, Location: nil, Description: "Main Sea Node")
        MiscTable[SeaGlobe]?.HasNumber = false
#endif
    }
    
    /// Add an earthquake to the earthquake item table.
    /// - Parameter Quake: The earthquake to add to the table. Duplicate earthquakes overwrite previous
    ///                    earthquakes.
    public static func AddEarthquake(_ Quake: Earthquake)
    {
        let QItem = DisplayItem(ID: Quake.QuakeID, ItemType: .Earthquake, Name: "\(Quake.Time)",
                                Numeric: Quake.GreatestMagnitude, Location: Quake.LocationAsGeoPoint(),
                                Description: Quake.Title, ItemID: UUID())
        QuakeTable[QItem.ID] = QItem
    }
    
    /// Deletes all earthquakes.
    public static func RemoveEarthquakes()
    {
        QuakeTable.removeAll()
    }
    
    /// Add a known location.
    /// - Parameter: ID: The ID of the known location.
    /// - Parameter Latitude: The latitude of the known location.
    /// - Parameter Longitude: The longitude of the known location.
    /// - Parameter X: The SceneKit X position of the location.
    /// - Parameter Y: The SceneKit Y position of the location.
    /// - Parameter Z: The SceneKit Z position of the location.
    public static func AddKnownLocation(ID: UUID, _ Latitude: Double, _ Longitude: Double,
                                        X: Double, Y: Double, Z: Double)
    {
        let KItem = DisplayItem(ID: ID, ItemType: .KnownLocation, Name: "Known Location",
                                Numeric: 0.0, Location: GeoPoint(Latitude, Longitude),
                                Description: "\(X.RoundedTo(3)),\(Y.RoundedTo(3)),\(Z.RoundedTo(3))",
                                ItemID: UUID())
        KnownTable[ID] = KItem
    }
    
    /// Remove all known locations from the Known Table.
    public static func RemoveKnownLocations()
    {
        KnownTable.removeAll()
    }
    
    /// Add user points of interest.
    /// - Parameter ID: The ID of the user POI.
    /// - Parameter Name: The name of the user POI.
    /// - Parameter Location: The location of the user POI.
    public static func AddUserPOI(ID: UUID, Name: String, Location: GeoPoint,
                                  ItemID: UUID)
    {
        let UserPOI = DisplayItem(ID: ID, ItemType: .UserPOI, Name: Name,
                                  Numeric: 0.0, Location: Location, ItemID: ItemID)
        POITable[UserPOI.ID] = UserPOI
    }
    
    /// Deletes all user POIs.
    public static func RemoveUserPOI()
    {
        POITable.removeAll()
    }
    
    /// Add built-in points of interest.
    /// - Parameter ID: The ID of the built-in POI.
    /// - Parameter Name: The name of the built-in POI.
    /// - Parameter Location: The location of the built-in POI.
    public static func AddBuiltInPOI(ID: UUID, Name: String, Location: GeoPoint)
    {
        let BuiltInPOILocation = DisplayItem(ID: ID, ItemType: .BuiltInPOI, Name: Name,
                                             Numeric: 0.0, Location: Location, ItemID: UUID())
        BuiltInPOITable[BuiltInPOILocation.ID] = BuiltInPOILocation
    }
    
    /// Deletes all built-in POIs.
    public static func RemoveBuiltInPOI()
    {
        BuiltInPOITable.removeAll()
    }
    
    /// Add the user's home location.
    /// - Parameter ID: ID of the home location.
    /// - Parameter Name: Name of the home location.
    /// - Parameter Location" Location of the home location.
    public static func AddHome(ID: UUID, Name: String, Location: GeoPoint)
    {
        let UserHome = DisplayItem(ID: ID, ItemType: .Home, Name: Name,
                                   Numeric: 0.0, Location: Location, ItemID: UUID())
        HomeTable[UserHome.ID] = UserHome
    }
    
    /// Deletes all home data.
    public static func RemoveUserHome()
    {
        HomeTable.removeAll()
    }
    
    /// Add miscellaneous data.
    /// - Parameter ID: ID of the item.
    /// - Parameter Name: Name of the item.
    /// - Parameter Numeric: Value of the item.
    /// - Parameter Location: Location of the item.
    /// - Parameter Description: Description of the item.
    public static func AddMiscellaneous(ID: UUID, Name: String, Numeric: Double,
                                        Location: GeoPoint?, Description: String)
    {
        let MiscData = DisplayItem(ID: ID, ItemType: .Miscellaneous, Name: Name,
                                   Numeric: Numeric, Location: Location,
                                   Description: Description, ItemID: UUID())
        MiscTable[MiscData.ID] = MiscData
    }
    
    /// Deletes all hour data.
    public static func RemoveMiscellaneous()
    {
        MiscTable.removeAll()
    }
    
    /// Add a rectangular region.
    /// - Parameter ID: ID of the item.
    /// - Parameter Name: Name of the item.
    /// - Parameter UpperLeft: Upper-left (northwest) coordinate of the region.
    /// - Parameter LowerRight: Lower-right (southeast) coordinate of the region.
    /// - Parameter Description: Description of the region.
    public static func AddRegion(ID: UUID, Name: String,
                                 UpperLeft: GeoPoint?, LowerRight: GeoPoint?,
                                 Description: String)
    {
        let Rgn = DisplayItem(ID: ID, ItemType: .Region, Name: Name,
                              Numeric: 0.0, Location: UpperLeft,
                              Description: Description, ItemID: UUID())
        Rgn.Location2 = LowerRight
        RegionTable[Rgn.ID] = Rgn
    }
    
    /// Add a circular region.
    /// - Parameter ID: ID of the item.
    /// - Parameter Name: Name of the item.
    /// - Parameter Radius: Radius of the region.
    /// - Parameter Center: Center location of the region.
    /// - Paraemter Description: Descripiton of the region.
    public static func AddRegion(ID: UUID, Name: String, Radius: Double,
                                 Center: GeoPoint?, Description: String)
    {
        let Rgn = DisplayItem(ID: ID, ItemType: .Region, Name: Name,
                              Numeric: Radius, Location: Center,
                              Description: Description, ItemID: UUID())
        RegionTable[Rgn.ID] = Rgn
    }
    
    /// Deletes all regions.
    public static func RemoveRegion()
    {
        RegionTable.removeAll()
    }
    
    /// Return the associated data for the passed ID.
    /// - Parameter For: The ID of the item whose data will be returned.
    /// - Returns: The associated data on success, nil if not found.
    public static func GetItemData(For ID: UUID) -> DisplayItem?
    {
        for (ItemID, ItemData) in QuakeTable
        {
            if ItemID == ID
            {
                return ItemData
            }
        }
        for (ItemID, ItemData) in CityTable
        {
            if ItemID == ID
            {
                return ItemData
            }
        }
        for (ItemID, ItemData) in HomeTable
        {
            if ItemID == ID
            {
                return ItemData
            }
        }
        for (ItemID, ItemData) in POITable
        {
            if ItemID == ID
            {
                return ItemData
            }
        }
        for (ItemID, ItemData) in BuiltInPOITable
        {
            if ItemID == ID
            {
                return ItemData
            }
        }
        for (ItemID, ItemData) in MiscTable
        {
            if ItemID == ID
            {
                return ItemData
            }
        }
        for (ItemID, ItemData) in UNESCOTable
        {
            if ItemID == ID
            {
                return ItemData
            }
        }
        for (ItemID, ItemData) in KnownTable
        {
            if ItemID == ID
            {
                return ItemData
            }
        }
        for (ItemID, ItemData) in RegionTable
        {
            if ItemID == ID
            {
                return ItemData
            }
        }
        return nil
    }
    
    /// Get the number of entries in a class table.
    /// - Parameter For: Identifies the class whose entry count is returned.
    /// - Returns: Number of entries for the specified class. Nil if the class is not defined.
    public static func TableCount(For: NodeClasses) -> Int?
    {
        switch For
        {
            case .City:
                return CityTable.count
                
            case .Earthquake:
                return QuakeTable.count
                
            case .HomeLocation:
                return HomeTable.count
                
            case .UserPOI:
                return POITable.count
                
            case .WorldHeritageSite:
                return UNESCOTable.count
                
            case .Miscellaneous:
                return MiscTable.count
                
            case .KnownLocation:
                return KnownTable.count
                
            case .Region:
                return RegionTable.count
                
            case .BuiltInPOI:
                return BuiltInPOITable.count
                
            default:
                return nil
        }
    }
    
    private static var QuakeTable = [UUID: DisplayItem]()
    private static var CityTable = [UUID: DisplayItem]()
    private static var POITable = [UUID: DisplayItem]()
    private static var BuiltInPOITable = [UUID: DisplayItem]()
    private static var HomeTable = [UUID: DisplayItem]()
    private static var UNESCOTable = [UUID: DisplayItem]()
    private static var MiscTable = [UUID: DisplayItem]()
    private static var KnownTable = [UUID: DisplayItem]()
    private static var RegionTable = [UUID: DisplayItem]()
    
#if DEBUG
    public static func DumpTableKeys(For Class: NodeClasses)
    {
        switch Class
        {
            case .City:
                Debug.Print("City Keys:")
                for (Key, _) in CityTable
                {
                    Debug.Print("  \(Key.uuidString)")
                }
                
            case .Earthquake:
                Debug.Print("Earthquake Keys:")
                for (Key, _) in QuakeTable
                {
                    Debug.Print("  \(Key.uuidString)")
                }
                
            case .HomeLocation:
                Debug.Print("Home Keys:")
                for (Key, _) in HomeTable
                {
                    Debug.Print("  \(Key.uuidString)")
                }
                
            case .UserPOI:
                Debug.Print("User POI Keys:")
                for (Key, _) in POITable
                {
                    Debug.Print("  \(Key.uuidString)")
                }
                
            case .BuiltInPOI:
                Debug.Print("Built-in POI Keys:")
                for (Key, _) in BuiltInPOITable
                {
                    Debug.Print("  \(Key.uuidString)")
                }
                
            case .WorldHeritageSite:
                Debug.Print("UNESCO Keys:")
                for (Key, _) in UNESCOTable
                {
                    Debug.Print("  \(Key.uuidString)")
                }
                
            case .Miscellaneous:
                Debug.Print("Miscellaneous Keys:")
                for (Key, _) in MiscTable
                {
                    Debug.Print("  \(Key.uuidString)")
                }
                
            case .KnownLocation:
                Debug.Print("Known Location Keys:")
                for (Key, _) in KnownTable
                {
                    Debug.Print("  \(Key.uuidString)")
                }
                
            case .Region:
                Debug.Print("Region Keys:")
                for (Key, _) in RegionTable
                {
                    Debug.Print("  \(Key.uuidString)")
                }
                
            default:
                Debug.Print("Unknown class \"\(Class)\" specified")
        }
    }
#endif
    
    /// Mapping from class ID to ItemType.
    private static let ClassToItemType =
    [
        UUID(uuidString: NodeClasses.Unknown.rawValue)!: ItemTypes.Unknown,
        UUID(uuidString: NodeClasses.City.rawValue)!: ItemTypes.City,
        UUID(uuidString: NodeClasses.Earthquake.rawValue)!: ItemTypes.Earthquake,
        UUID(uuidString: NodeClasses.HomeLocation.rawValue)!: ItemTypes.Home,
        UUID(uuidString: NodeClasses.UserPOI.rawValue)!: ItemTypes.UserPOI,
        UUID(uuidString: NodeClasses.WorldHeritageSite.rawValue)!: ItemTypes.WorldHeritageSite,
        UUID(uuidString: NodeClasses.Miscellaneous.rawValue)!: ItemTypes.Miscellaneous,
        UUID(uuidString: NodeClasses.KnownLocation.rawValue)!: ItemTypes.KnownLocation,
        UUID(uuidString: NodeClasses.Region.rawValue)!: ItemTypes.Region,
        UUID(uuidString: NodeClasses.BuiltInPOI.rawValue)!: ItemTypes.BuiltInPOI,
    ]
    
    /// The home ID.
    public static let HomeID = UUID()
    /// The north pole ID.
    public static let NorthPoleID = UUID()
    /// The south pole ID.
    public static let SouthPoleID = UUID()
    /// The sun's ID.
    public static let SunID = UUID()
    /// The Earth globe.
    public static let EarthGlobe = UUID()
    /// The sea globe.
    public static let SeaGlobe = UUID()
}

/// Information to display to the user.
class DisplayItem
{
    /// Initializer.
    /// - Parameter ID: The ID of the owning item.
    /// - Parameter ItemType: The item type of the owning item.
    /// - Parameter Name: The name of the item.
    /// - Parameter Numeric: The numeric value (when appropriate) of the item.
    /// - Parameter Location: The geographic location of the item.
    /// - Parameter Description: The description of the item.
    /// - Parameter ItemID: The ID of the individual item.
    init(ID: UUID, ItemType: ItemTypes, Name: String, Numeric: Double, Location: GeoPoint?,
         Description: String = "", ItemID: UUID)
    {
        self.ID = ID
        self.ItemType = ItemType
        self.Name = Name
        self.Numeric = Numeric
        self.Location = Location
        self.Description = Description
        self.ItemID = ItemID
    }
    
    var ID: UUID = UUID()
    var ItemType: ItemTypes = .Unknown
    var Name: String = ""
    var Numeric: Double = 0.0
    var Location: GeoPoint? = nil
    var Location2: GeoPoint? = nil
    var Description: String = ""
    var HasNumber: Bool = true
    var ItemID: UUID = UUID()
}

enum ItemTypes: String, CaseIterable
{
    case Unknown = "Unknown"
    case City = "City"
    case Home = "Home"
    case UserPOI = "User POI"
    case BuiltInPOI = "Built-in POI"
    case Earthquake = "Earthquake"
    case WorldHeritageSite = "World Heritage Site"
    case Miscellaneous = "Miscellaneous"
    case KnownLocation = "Known Location"
    case Region = "Region"
}

enum NodeClasses: String, CaseIterable
{
    case Unknown = "5f893956-1f90-468a-8475-f066824af425"
    case City = "8d4e5448-943e-4feb-a2e0-e83ab8bcd0b4"
    case UserPOI = "8b0437b8-24fd-4813-b8c6-af78c9dfd1a4"
    case BuiltInPOI = "e3a36057-710f-416d-a6c0-75487af1f958"
    case HomeLocation = "21599d45-7ace-47f1-ad40-f302b019dc2c"
    case Earthquake = "fff542af-daf9-4629-8325-a26d8e54b427"
    case WorldHeritageSite = "f0b85fc5-c761-4b74-91fc-5b79b3d7d606"
    case Miscellaneous = "736aec23-506e-4eb5-bda6-03af23c85126"
    case KnownLocation = "1727d4c5-a660-42bb-ab39-ceaed478fb59"
    case Region = "9159f963-b6e0-4f07-95c9-4c1b59159fcb"
}

