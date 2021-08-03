//
//  GeoPoint.swift
//  GeoPoint
//
//  Created by Stuart Rankin on 7/18/21. Adapted from Flatland View.
//

import Foundation
import UIKit
import SQLite3

/// Encapsulates a geographic point.
public class GeoPoint: CustomStringConvertible
{
    public var description: String
    {
        get
        {
            return "\(Latitude.RoundedTo(4)),\(Longitude.RoundedTo(4))"
        }
    }
    
    /// Initializer.
    init()
    {
        NameEn = ""
        Latitude = 0.0
        Longitude = 0.0
    }
    
    /// Initializer.
    ///
    /// - Parameters:
    ///   - Lat: Initial latitude.
    ///   - Lon: Initial longitude.
    init (_ Lat: Double, _ Lon: Double)
    {
        Latitude = Lat
        Longitude = Lon
    }
    
    /// Initializer.
    /// - Parameter Lat: Initial latitude.
    /// - Parameter Lon: Initial longitude.
    /// - Parameter Alt: Initial altitude.
    init (_ Lat: Double, _ Lon: Double, _ Alt: Double)
    {
        Latitude = Lat
        Longitude = Lon
        Altitude = Alt
    }
    
    /// Initializer.
    /// - Parameters:
    ///   - Lat: Initial latitude.
    ///   - Lon: Initial longitude.
    ///   - Label: Initial name (stored in NameEn).
    init(_ Lat: Double, _ Lon: Double, _ Label: String)
    {
        Latitude = Lat
        Longitude = Lon
        NameEn = Label
    }
    
    /// Initializer.
    /// - Parameter Raw: String to convert to a latitude, longitude pair. Format is `latitude,longitude`.
    /// - Returns: Nil on failure.
    init?(Raw: String)
    {
        let Parts = Raw.split(separator: ",", omittingEmptySubsequences: true)
        if Parts.count != 2
        {
            return nil
        }
        let LatString = String(Parts[0])
        let LonString = String(Parts[1])
        guard let Lat = Double(LatString) else
        {
            return nil
        }
        guard let Lon = Double(LonString) else
        {
            return nil
        }
        Latitude = Lat
        Longitude = Lon
    }
    
    /// Contains the database record ID.
    private var LocalID: Int32 = 0
    /// Get or set the ID of the record.
    public var ID: Int32
    {
        get
        {
            return LocalID
        }
        set(NewID)
        {
            LocalID = NewID
        }
    }
    
    /// Contains the location type.
    private var LocalType: String = ""
    /// Get or set the location type.
    public var LocationType: String
    {
        get
        {
            return LocalType
        }
        set(NewType)
        {
            LocalType = NewType
            IsDirty = true
        }
    }
    
    /// Contains the location sub-type.
    private var LocalSubType: String = ""
    /// Get or set the location sub-type.
    public var LocationSubType: String
    {
        get
        {
            return LocalSubType
        }
        set(NewSubType)
        {
            LocalSubType = NewSubType
            IsDirty = true
        }
    }
    
    /// Contains the name of the location in English.
    private var LocalNameEN: String = ""
    /// Get or set the name of the location in English. All database records must have an English name. If for some
    /// reason the value read (or changed) is empty, the Name value will be returned instead.
    public var NameEn: String
    {
        get
        {
            if LocalNameEN.isEmpty
            {
                if Name.isEmpty
                {
                    return ""
                }
                return Name
            }
            return LocalNameEN
        }
        set(NewENName)
        {
            LocalNameEN = NewENName
            IsDirty = true
        }
    }
    
    /// Contains the local name of the location.
    private var LocalName: String = ""
    /// Get or set the lcoal name. May be in any character set supported by iOS.
    public var Name: String
    {
        get
        {
            return LocalName
        }
        set(NewName)
        {
            LocalName = NewName
            IsDirty = true
        }
    }
    
    /// Contains a list of local names. Not present in all databases.
    private var LocalNameList: [String] = [String]()
    /// Get or set the list of local names. Not present in all databases.
    public var LocalNames: [String]
    {
        get
        {
            return LocalNameList
        }
        set(NewLocalNameList)
        {
            LocalNameList = NewLocalNameList
            IsDirty = true
        }
    }
    
    /// Add a name to the local name list.
    ///
    /// - Parameter NewLocalName: Name to add. Not added if it is empty or already present.
    public func AddLocalName(NewLocalName: String)
    {
        if NewLocalName.isEmpty
        {
            return
        }
        if LocalNameList.contains(NewLocalName)
        {
            return
        }
        LocalNameList.append(NewLocalName)
        IsDirty = true
    }
    
    /// Return the preferred name. If the local name is not empty, it is returned. Otherwise, the local name in English is returned.
    public var ResolvedName: String
    {
        get
        {
            if Name.isEmpty
            {
                return NameEn
            }
            else
            {
                return Name
            }
        }
    }
    
    /// Contains the sub-national name of the location.
    private var LocalSubNational: String = ""
    /// Get or set the sub-national name of the location.
    public var SubNational: String
    {
        get
        {
            return LocalSubNational
        }
        set(NewSubNational)
        {
            LocalSubNational = NewSubNational
            IsDirty = true
        }
    }
    
    /// Contains the country name.
    private var LocalCountry: String = ""
    /// Get or set the country of the location.
    public var Country: String
    {
        get
        {
            return LocalCountry
        }
        set(NewCountry)
        {
            LocalCountry = NewCountry
            IsDirty = true
        }
    }
    
    /// Contains the second country name.
    private var LocalCountry2: String = ""
    /// Get or set the second country name (which may be empty or different from Country). This is not for localized country names.
    public var Country2: String
    {
        get
        {
            return LocalCountry2
        }
        set(NewCountry2)
        {
            LocalCountry2 = NewCountry2
            IsDirty = true
        }
    }
    
    /// Contains the name of the continent.
    private var LocalContinent: String = ""
    /// Get or set the continent name.
    public var Continent: String
    {
        get
        {
            return LocalContinent
        }
        set(NewContinent)
        {
            LocalContinent = NewContinent
            IsDirty = true
        }
    }
    
    /// Contains the population. Not present in all databases.
    private var LocalPopulation: Int = 0
    /// Get or set the population of the location. Not present in all databases.
    public var Population: Int
    {
        get
        {
            return LocalPopulation
        }
        set(NewPopulation)
        {
            LocalPopulation = NewPopulation
            IsDirty = true
        }
    }
    
    /// Contains the area. Not present in all databases.
    private var LocalArea: Int = 0
    /// Get or set the area of the location. Not present in all databases.
    public var Area: Int
    {
        get
        {
            return LocalArea
        }
        set(NewArea)
        {
            LocalArea = NewArea
            IsDirty = true
        }
    }
    
    /// Contains a year. Not present in all databases.
    private var LocalYear: Int = 0
    /// Get or set the year. Not present in all databases.
    public var Year: Int
    {
        get
        {
            return LocalYear
        }
        set(NewYear)
        {
            
            LocalYear = NewYear
            IsDirty = true
        }
    }
    
    /// Contains the is capital city flag. Not present in all databases.
    private var LocalIsCapital: Bool = false
    /// Get or set the capitcal city flag. Not present in all databases.
    public var IsCapital: Bool
    {
        get
        {
            return LocalIsCapital
        }
        set(NewIsCapital)
        {
            LocalIsCapital = NewIsCapital
            IsDirty = true
        }
    }
    
    /// Contains the latitude value of the location.
    private var LocalLatitude: Double = 0.0
    /// Get or set the latitude of the location.
    public var Latitude: Double
    {
        get
        {
            return LocalLatitude
        }
        set(NewLatitude)
        {
            LocalLatitude = NewLatitude
            IsDirty = true
        }
    }
    
    /// Synonomous with Latitude.
    public var Y: Double
    {
        get
        {
            return Latitude
        }
        set(NewY)
        {
            Latitude = NewY
        }
    }
    
    /// Contains the longitude value of the location.
    private var LocalLongitude: Double = 0.0
    /// Get or set the longitude of the location.
    public var Longitude: Double
    {
        get
        {
            return LocalLongitude
        }
        set(NewLongitude)
        {
            LocalLongitude = NewLongitude
            IsDirty = true
        }
    }
    
    /// Synonmous with Longitude.
    public var X: Double
    {
        get
        {
            return Longitude
        }
        set(NewX)
        {
            Longitude = NewX
        }
    }
    
    /// Returns a normalized latitude, longitude coordinate based on the passed the current coordinate values.
    /// - Note: Normalized means all values are positive and:
    ///   - **Latitude** ranges from 0.0° (south pole) to 180° (north pole).
    ///   - **Longitude** ranges from 0.0° (prime meridian) to 360° (approaching the prime meridian from the west).
    /// - Returns: Tuple with the instance latitude and longitude in their normalized forms.
    public func Normalize() -> (Latitude: Double, Longitude: Double)
    {
        var NLat: Double = 0.0
        if Latitude < 0.0
        {
            NLat = 90.0 - abs(Latitude)
        }
        else
        {
            NLat = Latitude + 90.0
        }
        var NLon = 0.0
        if Longitude < 0.0
        {
            NLon = abs(Longitude) + 180.0
        }
        else
        {
            NLon = Longitude
        }
        return (NLat, NLon)
    }
    
    /// Converts the current latitude and longitude values into absolute coordinates on an equirectangular
    /// plain. Intended for use for plotting earthquake regions.
    /// - Parameter Width: Width of the target equirectanglular plain.
    /// - Parameter Height: Height of the target equirectangular plain.
    /// - Returns: Tuple with (X, Y) coordinates on the target equirectangular plain.
    public func ToEquirectangular(Width: Int, Height: Int) -> (X: Int, Y: Int)
    {
        var AdjustedLatitude: Double = 0
        if Latitude > 0.0
        {
            AdjustedLatitude = abs(Latitude - 90)
        }
        else
        {
            AdjustedLatitude = abs(Latitude) + 90
        }
        let AdjustedLongitude = Longitude + 180
        let LatPercent = AdjustedLatitude / 180.0
        let LonPercent = AdjustedLongitude / 360.0
        //Needed because macOS has inverted Y coordinates.
        let FinalX = Int(LonPercent * Double(Width))
        let FinalY = Int((1.0 - LatPercent) * Double(Height))
        return (X: FinalX, Y: FinalY)
    }
    
    // MARK: - Distance and transformation functions.
    
    /// Calculates the distance from the the instance point to the passed point.
    /// - Parameter ToOther: Tuple of a latitude and longitude indicating the location of the second point on
    ///                      an image.
    /// - Parameter Width: Width of the surface of the sphere when projected equirectangularly.
    /// - Parameter Height: Height of the surface of the sphere when projected equirectangularly.
    /// - Returns: Unitless distance from the instance point to `ToOther`.
    func Distance(ToOther: (Lat2: Double, Lon2: Double),
                  Width: Int, Height: Int) -> Double
    {
        var NotUsed1: Double = 0.0
        var NotUsed2: Double = 0.0
        let (PX1, PY1) = TransformToImageCoordinates(Latitude: Latitude, Longitude: Longitude,
                                                     Width: Width, Height: Height,
                                                     XPercent: &NotUsed1, YPercent: &NotUsed2)
        let (PX2, PY2) = TransformToImageCoordinates(Latitude: ToOther.Lat2, Longitude: ToOther.Lon2,
                                                     Width: Width, Height: Height,
                                                     XPercent: &NotUsed1, YPercent: &NotUsed2)
        let DeltaX = Double(PX1 - PX2)
        let DeltaY = Double(PY1 - PY2)
        return sqrt((DeltaX * DeltaX) + (DeltaY * DeltaY))
    }
    
    /// Calculates the horizontal distance between the two coordinates.
    /// - Parameter Longitude1: Point 1's longitude.
    /// - Parameter Longigude2: Point 2's longitude.
    /// - Parameter Latitude: Latitude to use for both longitudinal values.
    /// - Parameter Width: Width of the surface of the sphere when projected equirectangularly.
    /// - Parameter Height: Height of the surface of the sphere when projected equirectangularly.
    /// - Returns: Horizontal distances between the two longitudinal locations.
    func HorizontalDistance(Longitude1: Double, Longitude2: Double, Latitude: Double,
                            Width: Int, Height: Int) -> Double
    {
        return Distance(ToOther: (Latitude, Longitude2), Width: Width, Height: Height)
    }
    
    /// Calculates the vertical distance between the two coordinates.
    /// - Parameter Latitude1: Point 1's latitude.
    /// - Parameter Latitude2: Point 2's latitude.
    /// - Parameter Longitude: Longitude to use for both latitudinal values.
    /// - Parameter Width: Width of the surface of the sphere when projected equirectangularly.
    /// - Parameter Height: Height of the surface of the sphere when projected equirectangularly.
    /// - Returns: Vertical distances between the two latitudinal locations.
    func VerticalDistance(Latitude1: Double, Latitude2: Double, Longitude: Double,
                          Width: Int, Height: Int) -> Double
    {
        return Distance(ToOther: (Latitude2, Longitude), Width: Width, Height: Height)
    }
    
    /// Transforms the passed coordinate to a location in the passed rectangle.
    /// - Parameter Latitude: Latitude of the coordinate to transform.
    /// - Parameter Longitude: Longitude of the coordinate to transform.
    /// - Parameter Width: Width of the rectangle into which the passed coordinate will be transformed.
    /// - Parameter Height: Height of the rectangle into which the passed coordinate will be transformed.
    /// - Parameter XPercent: Will contain the horizontal percent from the left side of the rectangle for the
    ///                       transformed horizontal rectangular coordinate.
    /// - Parameter YPercent: Will contain the vertical percent from the top side of the rectangle for the
    ///                       transformed vertical rectangular coordinate.
    /// - Returns: Tuple of the point's coordinate transformed to rectangular coordinates.
    func TransformToImageCoordinates(Latitude: Double, Longitude: Double, Width: Int, Height: Int,
                                     XPercent: inout Double, YPercent: inout Double) -> (X: Int, Y: Int)
    {
        let AdjustedLon = Longitude + 180.0
        let AdjustedLat = abs(Latitude - 90.0)
        let LonPercent = AdjustedLon / 360.0
        let LatPercent = AdjustedLat / 180.0
        XPercent = LonPercent
        YPercent = LatPercent
        let FinalX = Int(Double(Width) * LonPercent)
        let FinalY = Int(Double(Height) * LatPercent)
        return (FinalX, FinalY)
    }
    
    /// Returns teh distances between the two passed points.
    /// - Parameter From: First point.
    /// - Parameter To: Second point.
    /// - Parameter Width: Width of the surface of the sphere when projected equirectangularly.
    /// - Parameter Height: Height of the surface of the sphere when projected equirectangularly.
    /// - Returns: Unitless distance between the two passed points.
    static func Distance(From: (Lat: Double, Lon: Double), To: (Lat: Double, Lon: Double),
                         Width: Int, Height: Int) -> Double
    {
        var NotUsed1: Double = 0.0
        var NotUsed2: Double = 0.0
        let (PX1, PY1) = TransformToImageCoordinates(Latitude: From.Lat, Longitude: From.Lon,
                                                     Width: Width, Height: Height,
                                                     XPercent: &NotUsed1, YPercent: &NotUsed2)
        let (PX2, PY2) = TransformToImageCoordinates(Latitude: To.Lat, Longitude: To.Lon,
                                                     Width: Width, Height: Height,
                                                     XPercent: &NotUsed1, YPercent: &NotUsed2)
        let DeltaX = Double(PX1 - PX2)
        let DeltaY = Double(PY1 - PY2)
        return sqrt((DeltaX * DeltaX) + (DeltaY * DeltaY))
    }
    
    /// Calculates the horizontal distance between the two coordinates.
    /// - Parameter Longitude1: Point 1's longitude.
    /// - Parameter Longigude2: Point 2's longitude.
    /// - Parameter Latitude: Latitude to use for both longitudinal values.
    /// - Parameter Width: Width of the surface of the sphere when projected equirectangularly.
    /// - Parameter Height: Height of the surface of the sphere when projected equirectangularly.
    /// - Returns: Horizontal distances between the two longitudinal locations.
    static func HorizontalDistance(Longitude1: Double, Longitude2: Double, Latitude: Double,
                                   Width: Int, Height: Int) -> Double
    {
        return Distance(From: (Latitude, Longitude1), To: (Latitude, Longitude2), Width: Width, Height: Height)
    }
    
    /// Calculates the vertical distance between the two coordinates.
    /// - Parameter Latitude1: Point 1's latitude.
    /// - Parameter Latitude2: Point 2's latitude.
    /// - Parameter Longitude: Longitude to use for both latitudinal values.
    /// - Parameter Width: Width of the surface of the sphere when projected equirectangularly.
    /// - Parameter Height: Height of the surface of the sphere when projected equirectangularly.
    /// - Returns: Vertical distances between the two latitudinal locations.
    static func VerticalDistance(Latitude1: Double, Latitude2: Double, Longitude: Double,
                                 Width: Int, Height: Int) -> Double
    {
        return Distance(From: (Latitude1, Longitude), To: (Latitude2, Longitude), Width: Width, Height: Height)
    }
    
    /// Transforms the passed coordinate to a location in the passed rectangle.
    /// - Parameter Latitude: Latitude of the coordinate to transform.
    /// - Parameter Longitude: Longitude of the coordinate to transform.
    /// - Parameter Width: Width of the rectangle into which the passed coordinate will be transformed.
    /// - Parameter Height: Height of the rectangle into which the passed coordinate will be transformed.
    /// - Parameter XPercent: Will contain the horizontal percent from the left side of the rectangle for the
    ///                       transformed horizontal rectangular coordinate.
    /// - Parameter YPercent: Will contain the vertical percent from the top side of the rectangle for the
    ///                       transformed vertical rectangular coordinate.
    /// - Returns: Tuple of the point's coordinate transformed to rectangular coordinates.
    static func TransformToImageCoordinates(Latitude: Double, Longitude: Double, Width: Int, Height: Int,
                                            XPercent: inout Double, YPercent: inout Double) -> (X: Int, Y: Int)
    {
        let AdjustedLon = Longitude + 180.0
        let AdjustedLat = abs(Latitude - 90.0)
        let LonPercent = AdjustedLon / 360.0
        let LatPercent = AdjustedLat / 180.0
        XPercent = LonPercent
        YPercent = LatPercent
        let FinalX = Int(Double(Width) * LonPercent)
        let FinalY = Int(Double(Height) * LatPercent)
        return (FinalX, FinalY)
    }
    
    /// Transforms the instance coordinate to a location in the passed rectangle.
    /// - Parameter Width: Width of the rectangle into which the passed coordinate will be transformed.
    /// - Parameter Height: Height of the rectangle into which the passed coordinate will be transformed.
    /// - Parameter XPercent: Will contain the horizontal percent from the left side of the rectangle for the
    ///                       transformed horizontal rectangular coordinate.
    /// - Parameter YPercent: Will contain the vertical percent from the top side of the rectangle for the
    ///                       transformed vertical rectangular coordinate.
    /// - Returns: Tuple of the point's coordinate transformed to rectangular coordinates.
    func TransformToImageCoordinates(Width: Int, Height: Int,
                                     XPercent: inout Double,
                                     YPercent: inout Double) -> (X: Int, Y: Int)
    {
        let AdjustedLon = Longitude + 180.0
        let AdjustedLat = abs(Latitude - 90.0)
        let LonPercent = AdjustedLon / 360.0
        let LatPercent = AdjustedLat / 180.0
        XPercent = LonPercent
        YPercent = LatPercent
        let FinalX = Int(Double(Width) * LonPercent)
        let FinalY = Int(Double(Height) * LatPercent)
        return (FinalX, FinalY)
    }
    
    /// Contains the altitude of the location.
    private var LocalAltitude: Double = 0.0
    /// Get or set the altitude of the location.
    public var Altitude: Double
    {
        get
        {
            return LocalAltitude
        }
        set(NewAltitude)
        {
            LocalAltitude = NewAltitude
            IsDirty = true
        }
    }
    
    /// Contains a user-defined magnitude value.
    private var LocalMagnitude: Int = 0
    /// Get or set the user-defined magnitude value.
    public var Magnitude: Int
    {
        get
        {
            return LocalMagnitude
        }
        set(NewMagnitude)
        {
            LocalMagnitude = NewMagnitude
            IsDirty = true
        }
    }
    
    /// Contains the date the location was added. Not present in all databases.
    private var LocalAddDate: Date = Date()
    /// Get or set the date the location was added. Not present in all databases. Defaults to the current date and time.
    public var AddDate: Date
    {
        get
        {
            return LocalAddDate
        }
        set(NewDate)
        {
            LocalAddDate = NewDate
            IsDirty = true
        }
    }
    
    /// Contains user-defined notes.
    private var LocalNotes: String = ""
    /// Get or set user-defined notes.
    public var Notes: String
    {
        get
        {
            return LocalNotes
        }
        set(NewNotes)
        {
            LocalNotes = NewNotes
            IsDirty = true
        }
    }
    
    /// Contains the time zone (in hours). Not present in all databases.
    private var LocalTimeZone: Int = 0
    /// Get or set the time zone (in hours). Not present in all databases.
    public var TimeZone: Int
    {
        get
        {
            return LocalTimeZone
        }
        set(NewTimeZone)
        {
            LocalTimeZone = NewTimeZone
            IsDirty = true
        }
    }
    
    /// Contains the time-zone seconds.
    private var LocalTZSeconds: Int = 0
    /// Get or set the time-zone seconds of the location.
    public var TimeZoneSeconds: Int
    {
        get
        {
            return LocalTZSeconds
        }
        set(NewTZSeconds)
        {
            LocalTZSeconds = NewTZSeconds
            IsDirty = true
        }
    }
    
    /// Contains the display flag.
    private var LocalDisplay: Bool = true
    /// Get or set the flag that determines if the location should be displayed.
    public var Display: Bool
    {
        get
        {
            return LocalDisplay
        }
        set(DoDisplay)
        {
            LocalDisplay = DoDisplay
            IsDirty = true
        }
    }
    
    /// Contains the use for clock flag. Not present in all databases.
    private var LocalUseForClock: Bool = false
    /// Get or set the use for clock flag.
    public var UseForClock: Bool
    {
        get
        {
            return LocalUseForClock
        }
        set(NewUseForClock)
        {
            LocalUseForClock = NewUseForClock
            IsDirty = true
        }
    }
    
    /// Contains the world city type. Not present in all databases.
    private var LocalWorldCity: String = ""
    /// Get or set the world city type. Blank if not set in database. Not present in all databases.
    public var WordCity: String
    {
        get
        {
            return LocalWorldCity
        }
        set(NewWorldCity)
        {
            LocalWorldCity = NewWorldCity
            IsDirty = true
        }
    }
    
    /// Contains the name of the mountain range. Not present in all databases.
    private var LocalRange: String = ""
    /// Get or set the name of the mountain range. Not present in all databases.
    public var Range: String
    {
        get
        {
            return LocalRange
        }
        set(NewRange)
        {
            LocalRange = NewRange
            IsDirty = true
        }
    }
    
    /// Contains a reference. Not present in all databases.
    private var LocalReference: String = ""
    /// Get or set a reference. Not present in all databases.
    public var Reference: String
    {
        get
        {
            return LocalReference
        }
        set(NewReference)
        {
            LocalReference = NewReference
            IsDirty = true
        }
    }
    
    /// Contains the dirty flag.
    private var LocalDirt: Bool = false
    /// Get or set the dirty flag. Not used with all databases.
    public var IsDirty: Bool
    {
        get
        {
            return LocalDirt
        }
        set(NewDirt)
        {
            LocalDirt = NewDirt
        }
    }
    
    /// Return the antipodal location of this location.
    ///
    /// - Returns: Tuple in the form of (antipodal latitude, antipodal longitude)
    public func GetAntipodalLocation() -> (Double, Double)
    {
        return (-Latitude, -Longitude)
    }
    
    private var LocalIsHere: Bool = false
    /// If true, this point was designated (by someone) as the "here" point.
    public var IsHere: Bool
    {
        get
        {
            return LocalIsHere
        }
        set(NewIsHere)
        {
            LocalIsHere = NewIsHere
        }
    }
    
    private var LocalIsHome: Bool = false
    /// If true, this point was designated (by someone) as the "home" point.
    public var IsHome: Bool
    {
        get
        {
            return LocalIsHome
        }
        set(NewIsHome)
        {
            LocalIsHome = NewIsHome
        }
    }
    
    private var LocalIsAntipodal: Bool = false
    /// If true, this point was designated as an antipodal point.
    public var IsAntipodal: Bool
    {
        get
        {
            return LocalIsAntipodal
        }
        set(NewAntipodal)
        {
            LocalIsAntipodal = NewAntipodal
        }
    }
    
    /// Holds the date/time.
    private var LocalTime: Date = Date()
    /// Get or set the current date and time.
    public var CurrentTime: Date
    {
        get
        {
            return LocalTime
        }
        set(NewTime)
        {
            LocalTime = NewTime
        }
    }
    
    /// Holds the sun is visible flag.
    private var LocalSunIsUp: Bool = true
    /// Get or set the sun is visible flag.
    public var SunIsVisible: Bool
    {
        get
        {
            return LocalSunIsUp
        }
        set(SunUp)
        {
            LocalSunIsUp = SunUp
        }
    }
    
    // MARK: Static functions.
    
    /// Create the time-zone seconds value given a longitude.
    ///
    /// - Parameter Longitude: Longitude for which the time-zone seconds value will be returned.
    /// - Returns: Number of seconds away from UTC.
    public static func GenerateTimeZoneSeconds(Longitude: Double) -> Int
    {
        let Hours: Double = Longitude / 15.0
        let Seconds: Double = Hours * 60.0 * 60.0
        let FinalSeconds = Int(Seconds)
        return FinalSeconds
    }
    
    /// Returns the distance (in kilometers) from OtherPoint to this instantiated point. Calls a function that uses the Haversine formula.
    ///
    /// - Parameter OtherPoint: The other point used to calculate distance.
    /// - Returns: Distance between OtherPoint and this point, in kilometers.
    public func DistanceFrom(OtherPoint: GeoPoint) -> Double
    {
        return Geometry.HaversineDistance(Point1: self, Point2: OtherPoint)
    }
    
    /// Returns the distance (in kilometers) from the current location to the prime meridian at the same latitude.
    ///
    /// - Returns: Kilometers from the current location to the prime meridian at the same latitude.
    public func PrimeMeridianDistance() -> Double
    {
        let PrimeMeridian = GeoPoint(self.Latitude, 0.0)
        return Geometry.HaversineDistance(Point1: self, Point2: PrimeMeridian)
    }
    
    /// Returns the initial bearing (in degrees) from the instantiated point to OtherPoint.
    ///
    /// - Parameter OtherPoint: The target point from which the bearing will be calculated.
    /// - Returns: Initial bearing from this point to the passed point.
    public func BearingTo(OtherPoint: GeoPoint) -> Double
    {
        return Geometry.Bearing(Start: self, End: OtherPoint)
    }
    
    /// Returns the intial bearing (in degress) from the instantiated point to the OtherPoint.
    ///
    /// - Parameter OtherPoint: The target point from which the bearing will be calculated.
    /// - Returns: Initial bearing from this point to the passed point.
    public func Bearing(OtherPoint: GeoPoint) -> Int
    {
        let Angle = Geometry.Bearing2I(Start: self, End: OtherPoint)
        return Angle
    }
}
