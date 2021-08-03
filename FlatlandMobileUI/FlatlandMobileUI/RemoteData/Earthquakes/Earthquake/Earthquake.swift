//
//  Earthquake.swift
//  Earthquake
//
//  Created by Stuart Rankin on 7/18/21. Adapted from Flatland View.
//

import Foundation
import UIKit

/// Encapsulates one or more earthquakes. Encapsulated earthquakes are those that are in a small
/// geographic region.
/// - Note: This class will generate strings to be used to add or update earthquakes in a SQLite database. To
///         do this, static functions make heavy use of reflection and rely on private backing stores for
///         field data to all start with two underscores (`__`).
/// - Note: See [ComCatDocumentation - Event Terms](https://earthquake.usgs.gov/data/comcat/data-eventterms.php)
class Earthquake: KMDataPoint, Hashable, CustomStringConvertible
{
    /// Number of dimensions.
    static var NumDimensions: UInt = 2
    
    /// Dimensional data.
    var Dimensions = [Double]()
    
    /// Initialized. Used when reading historic earthquakes from the database.
    /// - Warning: Until initialized by setting properties, instances of Earthquakes created with this
    ///            initializer are unstable.
    /// - Parameter PK: The database ID of the earthquake.
    init(_ PK: Int)
    {
        Marked = false
        PKID = PK
    }
    
    /// Initializer.
    required init(Values: [Double])
    {
        GreatestMagnitudeValue = 0.0
        Marked = false
        Latitude = Values[0]
        Longitude = Values[1]
        Dimensions = [Latitude, Longitude]
    }
    
    /// Initializer.
    /// - Parameter Latitude: The latitude of the earthquake.
    /// - Parameter Longitude: The longitude of the earthquake.
    /// - Parameter Magnitude: The magnitude of the earthquake.
    /// - Parameter IsDebug: Sets the debug flag. Defaults to `false`.
    init(Latitude: Double, Longitude: Double, Magnitude: Double, IsDebug: Bool = false)
    {
        GreatestMagnitudeValue = 0.0
        Marked = false
        self.Latitude = Latitude
        self.Longitude = Longitude
        self.Magnitude = Magnitude
        DebugQuake = IsDebug
        if IsDebug
        {
            Title = "Injected debug earthquake"
        }
    }
    
    /// Initializer.
    /// - Parameter Sequence: For debugging purposes.
    init(Sequence: Int)
    {
        self.Sequence = Sequence
        GreatestMagnitudeValue = 0.0
        Marked = false
        Dimensions = [Double]()
    }
    
    /// Initializer - uses data from the supplied earthquake to populate this instance.
    /// - Parameter Other: The other earthquake that will be used to populate this instance.
    /// - Parameter IncludeRelated: If true, related earthquakes in `Other` are assigned to this
    ///                             instance.
    /// - Parameter IsBiggest: Flag that determines if the quake is the biggest in a set.
    init(_ Other: Earthquake, IncludeRelated: Bool = false, IsBiggest: Bool = false)
    {
        _IsBiggest = IsBiggest
        GreatestMagnitudeValue = 0.0
        EventID = Other.EventID
        Sequence = Other.Sequence
        Code = Other.Code
        Place = Other.Place
        Magnitude = Other.Magnitude
        Time = Other.Time
        Tsunami = Other.Tsunami
        Latitude = Other.Latitude
        Longitude = Other.Longitude
        Dimensions = [Latitude, Longitude]
        Depth = Other.Depth
        Status = Other.Status
        Updated = Other.Updated
        MMI = Other.MMI
        Felt = Other.Felt
        Significance = Other.Significance
        MagType = Other.MagType
        MagError = Other.MagError
        MagNST = Other.MagNST
        DMin = Other.DMin
        Alert = Other.Alert
        Title = Other.Title
        Types = Other.Types
        EventType = Other.EventType
        Detail = Other.Detail
        TZ = Other.TZ
        Net = Other.Net
        NST = Other.NST
        Gap = Other.Gap
        IDs = Other.IDs
        HorizontalError = Other.HorizontalError
        CDI = Other.CDI
        RMS = Other.RMS
        NPH = Other.NPH
        LocationSource = Other.LocationSource
        MagSource = Other.MagSource
        EventPageURL = Other.EventPageURL
        Sources = Other.Sources
        DepthError = Other.DepthError
        Marked = false
        DebugQuake = Other.DebugQuake
        PKID = Other.PKID
        Notified = Other.Notified
        RegionName = Other.RegionName
        ContextDistance = Other.ContextDistance
        if IncludeRelated
        {
            if let OtherRelated = Other.Related
            {
                Related = OtherRelated
            }
        }
    }
    
    /// Holds the biggest earthquake flag.
    private var _IsBiggest: Bool = false
    /// Get the biggest earthquake flag.
    public var IsBiggest: Bool
    {
        get
        {
            return _IsBiggest
        }
    }
    
    /// The sequence value.
    private var __Sequence: Int = 0
    /// Get or set the sequence value.
    var Sequence: Int
    {
        get
        {
            return __Sequence
        }
        set
        {
            __Sequence = newValue
        }
    }
    
    /// USGS earthquake code/ID.
    private var __Code: String = ""
    /// Get or set the USGS code/ID.
    var Code: String
    {
        get
        {
            return __Code
        }
        set
        {
            __Code = newValue
        }
    }
    
    /// Holds the place name. May be blank.
    private var __Place: String = ""
    /// Get or set the name of the place of the earthquake. May be blank.
    var Place: String
    {
        get
        {
            return __Place
        }
        set
        {
            __Place = newValue.trimmingCharacters(in: .whitespacesAndNewlines)
        }
    }
    
    /// Holds the magnitude value.
    private var __Magnitude: Double = 0.0
    /// The magnitude of the earthquake.
    var Magnitude: Double
    {
        get
        {
            return __Magnitude
        }
        set
        {
            __Magnitude = newValue
        }
    }
    
    /// Returns the greatest magnitude. If a given earthquake is not a cluster, this is merely the
    /// same value as in `Magnitude`. This this earthquake represents a cluster of earthquakes, the
    /// largest earthquake's magnitude will be returned. `0.0` returned on error.
    var GreatestMagnitude: Double
    {
        get
        {
            objc_sync_enter(EarthquakeLock)
            defer{objc_sync_exit(EarthquakeLock)}
            if let Quake = GreatestMagnitudeEarthquake
            {
                return Quake.Magnitude
            }
            return 0.0
        }
    }
    
    var GreatestMagnitudeValue: Double = 0.0
    
    /// Returns the earthquake with the greatest magnitude. If there are no related earthquakes,
    /// `self` is returned.
    var GreatestMagnitudeEarthquake: Earthquake?
    {
        get
        {
            objc_sync_enter(EarthquakeLock)
            defer{objc_sync_exit(EarthquakeLock)}
            if let Group = Related
            {
                if !Group.isEmpty
                {
                    let Sorted = Group.sorted(by: {$0.Magnitude > $1.Magnitude})
                    return Sorted[0]
                }
            }
            return self
        }
    }
    
    /// Returns `true` if this instance contains a cluster of earthqakes, false if not.
    var IsCluster: Bool
    {
        get
        {
            if let Group = Related
            {
                if !Group.isEmpty
                {
                    return true
                }
            }
            return false
        }
    }
    
    /// Returns the number of related earthquakes.
    var ClusterCount: Int
    {
        get
        {
            if let Group = Related
            {
                return Group.count
            }
            return 0
        }
    }
    
    /// Holds the time of the earthquake
    private var __Time: Date = Date()
    /// Date/time the earthquake occurred.
    var Time: Date
    {
        get
        {
            return __Time
        }
        set
        {
            __Time = newValue
        }
    }
    
    /// Returns the difference between the current time and the time of the earthquake. Smaller
    /// values indicate more recent earthquakes.
    func GetAge() -> Double
    {
        let Now = Date()
        let Delta = Now.timeIntervalSinceReferenceDate - Time.timeIntervalSinceReferenceDate
        return Delta
    }
    
    /// Holds the tsunami value.
    private var __Tsunami: Int = 0
    /// Tsunami value. If 1, tsunami information _may_ exist but also may not exist.
    var Tsunami: Int
    {
        get
        {
            return __Tsunami
        }
        set
        {
            __Tsunami = newValue
        }
    }
    
    /// Holds the latitude.
    var __Latitude: Double = 0.0
    /// Get or set the latitude of the earthquake.
    var Latitude: Double
    {
        get
        {
            return __Latitude
        }
        set
        {
            __Latitude = newValue
        }
    }
    
    /// Holds the longitude.
    private var __Longitude: Double = 0.0
    /// Longitude of the earthquake.
    var Longitude: Double
    {
        get
        {
            return __Longitude
        }
        set
        {
            __Longitude = newValue
        }
    }
    
    /// Set the location of the earthquake.
    /// - Parameter Latitude: The latitude of the earthquake.
    /// - Parameter Longitude: The longitude of the earthquake.
    func SetLocation(_ Latitude: Double, _ Longitude: Double)
    {
        Dimensions = [Latitude, Longitude]
        self.Latitude = Latitude
        self.Longitude = Longitude
    }
    
    /// Return the location of the earthquake as a `GeoPoint` class.
    /// - Returns: A `GeoPoint` instance initialized with the location of the earthquake.
    func LocationAsGeoPoint() -> GeoPoint
    {
        return GeoPoint(Latitude, Longitude)
    }
    
    /// Holds the ID of the quake.
    private var __PKID: Int? = nil
    /// Database ID of the quake. If nil, quake is not from a database.
    var PKID: Int?
    {
        get
        {
            return __PKID
        }
        set
        {
            __PKID = newValue
        }
    }
    
    /// Holds the depth of the quake.
    var __Depth: Double = 0.0
    /// Depth of the earthquake in kilometers.
    var Depth: Double
    {
        get
        {
            return __Depth
        }
        set
        {
            __Depth = newValue
        }
    }
    
    /// Holds the uncertainty of the depth.
    var __DepthError: Double = 0.0
    /// Uncertainty of the depth.
    var DepthError: Double
    {
        get
        {
            return __DepthError
        }
        set
        {
            __DepthError = newValue
        }
    }
    
    /// Holds the status of the event.
    private var __Status: String = ""
    /// Status of the event.
    var Status: String
    {
        get
        {
            return __Status
        }
        set
        {
            __Status = newValue
        }
    }
    
    /// Holds the updated time.
    private var __Updated: Date = Date.init(timeIntervalSince1970: 0)
    /// When updated. If the date is the beginning of 1970, no value has been set.
    var Updated: Date
    {
        get
        {
            return __Updated
        }
        set
        {
            __Updated = newValue
        }
    }
    
    /// Holds the shakemap intensity.
    private var __MMI: Double = 0.0
    /// Shakemap intensity.
    var MMI: Double
    {
        get
        {
            return __MMI
        }
        set
        {
            __MMI = newValue
        }
    }
    
    /// Holds the DYFI data point.
    private var __Felt: Int = 0
    /// Reports from the DYFI system.
    var Felt: Int
    {
        get
        {
            return __Felt
        }
        set
        {
            __Felt = newValue
        }
    }
    
    /// Holds the significance.
    private var __Significance: Int = 0
    /// Subjective significance value. Greater values indicate greater significance.
    var Significance: Int
    {
        get
        {
            return __Significance
        }
        set
        {
            __Significance = newValue
        }
    }
    
    /// Holds the QuakeID.
    private var __QuakeID: UUID = UUID()
    /// Unique (per instance) ID of the earthquake.
    var QuakeID: UUID
    {
        get
        {
            return __QuakeID
        }
        set
        {
            __QuakeID = newValue
        }
    }
    
    /// Holds the event ID.
    private var __EventID: String = ""
    /// The event ID.
    var EventID: String
    {
        get
        {
            return __EventID
        }
        set
        {
            __EventID = newValue
        }
    }
    
    /// Holds the magnitude calculation methd.
    private var __MagType: String = ""
    /// How magnitude was calculated.
    /// - Notes: See [Magnitude Types](https://www.usgs.gov/natural-hazards/earthquake-hazards/science/magnitude-types?qt-science_center_objects=0#qt-science_center_objects)
    var MagType: String
    {
        get
        {
            return __MagType
        }
        set
        {
            __MagType = newValue
        }
    }
    
    /// Holds the uncertainty of the magnitude.
    private var __MagError: Double = 0.0
    /// Uncertainty of reported magnitude of event.
    var MagError: Double
    {
        get
        {
            return __MagError
        }
        set
        {
            __MagError = newValue
        }
    }
    
    /// Number of seismic stations.
    private var __MagNST: Int = 0
    /// Number of seismic stations used to calculate magnitude.
    var MagNST: Int
    {
        get
        {
            return __MagNST
        }
        set
        {
            __MagNST = newValue
        }
    }
    
    /// Distance from epicenter to nearest station.
    private var __DMin: Double = 0.0
    /// Horizontal distance from the epicenter to the nearest station in degrees.
    var DMin: Double
    {
        get
        {
            return __DMin
        }
        set
        {
            __DMin = newValue
        }
    }
    
    /// Alert value.
    private var __Alert: String = ""
    /// Alert level from PAGER.
    var Alert: String
    {
        get
        {
            return __Alert
        }
        set
        {
            __Alert = newValue
        }
    }
    
    /// Holds the title.
    private var __Title: String = ""
    /// Title.
    var Title: String
    {
        get
        {
            return __Title
        }
        set
        {
            __Title = newValue
        }
    }
    
    /// Holds the product types.
    private var __Types: String = ""
    /// List of product types associated with this event.
    var Types: String
    {
        get
        {
            return __Types
        }
        set
        {
            __Types = newValue
        }
    }
    
    /// Holds the event type.
    private var __EventType: String = ""
    /// Type of seismic event.
    var EventType: String
    {
        get
        {
            return __EventType
        }
        set
        {
            __EventType = newValue
        }
    }
    
    /// Hold the Detail value.
    private var __Detail: String = ""
    /// Link to GeoJSON detail.
    var Detail: String
    {
        get
        {
            return __Detail
        }
        set
        {
            __Detail = newValue
        }
    }
    
    /// Holds the time zone value.
    private var __TZ: Int = Int.min
    /// Timezone offset from UTC in minutes at the epicenter. If no value set, `Int.min` will be returned.
    var TZ: Int
    {
        get
        {
            return __TZ
        }
        set
        {
            __TZ = newValue
        }
    }
    
    /// USGS event page address.
    private var __EventPageURL: String = ""
    /// Link to USGS event page for the event.
    var EventPageURL: String
    {
        get
        {
            return __EventPageURL
        }
        set
        {
            __EventPageURL = newValue
        }
    }
    
    /// Holds the network sources.
    private var __Sources: String = ""
    /// List of network contributors.
    var Sources: String
    {
        get
        {
            return __Sources
        }
        set
        {
            __Sources = newValue
        }
    }
    
    /// Holds the ID of data contributors.
    private var __Net: String = ""
    /// ID of data contributors.
    var Net: String
    {
        get
        {
            return __Net
        }
        set
        {
            __Net = newValue
        }
    }
    
    /// Holds the number of seismic stations
    private var __NST: Int = 0
    /// Number of seismic stations used to determine location.
    var NST: Int
    {
        get
        {
            return __NST
        }
        set
        {
            __NST = newValue
        }
    }
    
    /// Holds the azimuthal gap.
    private var __Gap: Double = 0.0
    /// The largest azimuthal gap between adjacent stations.
    var Gap: Double
    {
        get
        {
            return __Gap
        }
        set
        {
            __Gap = newValue
        }
    }
    
    /// Holds event IDs.
    private var __IDs: String = ""
    /// List of event IDs associated with an event.
    var IDs: String
    {
        get
        {
            return __IDs
        }
        set
        {
            __IDs = newValue
        }
    }
    
    /// Holds the horizontal error.
    private var __HorizontalError: Double = 0.0
    /// Uncertainty of reported location of even in kilometers.
    var HorizontalError: Double
    {
        get
        {
            return __HorizontalError
        }
        set
        {
            __HorizontalError = newValue
        }
    }
    
    /// Holds the DYFI maximum intensity.
    private var __CDI: Double = 0.0
    /// Maximum reported intensity for the event - computed by DYFI. Should be reported as a Roman numeral.
    var CDI: Double
    {
        get
        {
            return __CDI
        }
        set
        {
            __CDI = newValue
        }
    }
    
    /// Holds the RMS.
    private var __RMS: Double = 0.0
    /// Root mean square travel time residual in seconds.
    var RMS: Double
    {
        get
        {
            return __RMS
        }
        set
        {
            __RMS = newValue
        }
    }
    
    /// Holds the NPH.
    private var __NPH: String = ""
    /// Number of phases used.
    var NPH: String
    {
        get
        {
            return __NPH
        }
        set
        {
            __NPH = newValue
        }
    }
    
    /// Holds the name of the network.
    private var __LocationSource: String = ""
    /// Network that authored the report.
    var LocationSource: String
    {
        get
        {
            return __LocationSource
        }
        set
        {
            __LocationSource = newValue
        }
    }
    
    /// Holds the magnitude source network.
    private var __MagSource: String = ""
    /// Network that generated the magnitude.
    var MagSource: String
    {
        get
        {
            return __MagSource
        }
        set
        {
            __MagSource = newValue
        }
    }
    
    /// Holds the context distance.
    private var __ContextDistance: Double = -Double.greatestFiniteMagnitude
    /// Distance from something else. If value is `-Double.greatestFiniteMagnitude`, no value has been set.
    var ContextDistance: Double
    {
        get
        {
            return __ContextDistance
        }
        set
        {
            __ContextDistance = newValue
        }
    }
    
    /// Holds the debug flag.
    private var __DebugQuake: Bool = false
    /// If true, the earthquake was injected and is intended for debug use.
    var DebugQuake: Bool
    {
        get
        {
            return __DebugQuake
        }
        set
        {
            __DebugQuake = newValue
        }
    }
    
    /// Holds the notification flag.
    private var __Notified: Bool = false
    /// User was notified flag.
    var Notified: Bool
    {
        get
        {
            return __Notified
        }
        set
        {
            __Notified = newValue
        }
    }
    
    /// Holds the region name.
    private var __RegionName: String = ""
    /// Region name where the quake occurred.
    var RegionName: String
    {
        get
        {
            return __RegionName
        }
        set
        {
            __RegionName = newValue
        }
    }
    
    /// Dirty flag.
    var IsDirty: Bool = false
    
    // MARK: - Code for data manipulation
    
    /// Determines if this earthquake (or any clustered/related earthquakes) have the specified
    /// Code value.
    /// - Parameter Code: The value to look for.
    /// - Returns: True if this or any sub-earthquake has a Code of `Code`, false otherwise.
    func Contains(Code: String) -> Bool
    {
        if self.Code == Code
        {
            return true
        }
        if let Clustered = Related
        {
            for RelatedEarthquake in Clustered
            {
                if RelatedEarthquake.Contains(Code: Code)
                {
                    return true
                }
            }
        }
        return false
    }
    
    /// Related earthquakes. Used for aftershocks.
    var Related: [Earthquake]? = nil
    
    /// Remove duplicate earthquakes from the related earthquake list. If there are no child earthquakes,
    /// no action is taken.
    public func RemoveDuplicates()
    {
        if let Children = Related
        {
            var Unique = [String: Earthquake]()
            for Quake in Children
            {
                if let _ = Unique[Quake.Code]
                {
                    continue
                }
                Unique[Quake.Code] = Quake
            }
            Related = Children
        }
    }
    
    /// Adds another earthquake to this earthquake if it occurs within a specific timeframe and
    /// distance.
    /// - Note: If the earthquake is already in the related list, do not add it again. In this case
    ///         `true` is returned to prevent the caller from adding it elsewhere.
    /// - Parameter Other: The other earthquake to add if it is close enough geographically and
    ///                    chronologically.
    /// - Returns: True if `Other` was added to this earthquake, false if not.
    @discardableResult func AddIfRelated(_ Other: Earthquake) -> Bool
    {
        objc_sync_enter(EarthquakeLock)
        defer{objc_sync_exit(EarthquakeLock)}
        if IsRelated(Other)
        {
            if Related == nil
            {
                Related = [Earthquake]()
            }
            for Already in Related!
            {
                if Already.Code == Other.Code
                {
                    //If the earthquake is already present, return true but do not add it.
                    return true
                }
            }
            Related?.append(Other)
            if Other.Magnitude > GreatestMagnitudeValue
            {
                GreatestMagnitudeValue = Other.Magnitude
            }
            return true
        }
        return false
    }
    
    func AddToRelated(_ Other: Earthquake)
    {
        objc_sync_enter(EarthquakeLock)
        defer{objc_sync_exit(EarthquakeLock)}
        if Related == nil
        {
            Related = [Earthquake]()
        }
        Related?.append(Other)
        if Other.Magnitude > GreatestMagnitudeValue
        {
            GreatestMagnitudeValue = Other.Magnitude
        }
    }
    
    static let DefaultTimeDelta = 5.0 * 24.0 * 60.0 * 50.0
    static let DefaultClusterDistance = 300.0
    
    /// Determines if the passed earthquake is spatially and chronologically related (but *not* geologically)
    /// to this earthquake. Used to group earthquakes together to reduce the clutter of the display.
    /// - Parameter Quake: Other earthquake to compare to this earthquake.
    /// - Parameter MaxTimeDelta: Maximum amount of time away from this earthquake the other earthquake
    ///                           must be to be related.
    /// - Parameter MaxDistanceDelta: Maximum distance from this earthquake the other earthquake must
    ///                               be to be related.
    /// - Returns: True if the passed earthquake is chronologically and spatially close to this earthquake,
    ///            false otherwise.
    func IsRelated(_ Quake: Earthquake, MaxTimeDelta: Double = DefaultTimeDelta,
                   MaxDistanceDelta: Double = DefaultClusterDistance) -> Bool
    {
        let TimeDelta = abs(Quake.Time.timeIntervalSinceReferenceDate - Time.timeIntervalSinceReferenceDate)
        if TimeDelta > MaxTimeDelta
        {
            return false
        }
        return IsCloseBy(Quake)
    }
    
    func IsCloseBy(_ Quake: Earthquake, MaxDistanceDelta: Double = DefaultClusterDistance) -> Bool
    {
        let DistanceToQuake = Distance(To: Quake)
        if DistanceToQuake > MaxDistanceDelta
        {
            return false
        }
        return true
    }

    public func Distance<Point: KMDataPoint>(To: Point) -> Double
    {
        return sqrt(zip(Dimensions, To.Dimensions).map({pow(($0.1 - $0.0), 2)}).Sum)
    }
    
    /// Returns the distance between the instance earthquake to the passed earthquake.
    /// - Parameter Quake: The quake used to calculate the distance.
    /// - Returns: Distance between the instance earthquake and the passed earthquake, in kilometers.
    func DistanceTo(_ Quake: Earthquake) -> Double
    {
#if true
        return DistanceTo(Quake.Latitude, Quake.Longitude)
#else
        let Lat1 = Latitude.Radians
        let Lon1 = Longitude.Radians
        let Lat2 = Quake.Latitude.Radians
        let Lon2 = Quake.Longitude.Radians
        let LonDelta = Lon2 - Lon1
        let LatDelta = Lat2 - Lat1
        let Step1 = pow(sin(LatDelta / 2), 2) +
        cos(Lat1) * cos(Lat2) * pow(sin(LonDelta / 2), 2)
        let Step2 = 2 * asin(sqrt(Step1))
        let Step3 = Step2 * 6371
        return Step3
#endif
    }
    
    /// Returns the distance between the instance earthquake and the passed coordinates.
    /// - Parameter OtherLatitude: The latitude of the other point.
    /// - Parameter OtherLongitude: The longitude of the other point.
    /// - Returns: Distance between the instance earthquake and the passed coordinate, in kilometers.
    func DistanceTo(_ OtherLatitude: Double, _ OtherLongitude: Double) -> Double
    {
        let Lat1 = Latitude.Radians
        let Lon1 = Longitude.Radians
        let Lat2 = OtherLatitude.Radians
        let Lon2 = OtherLongitude.Radians
        let LonDelta = Lon2 - Lon1
        let LatDelta = Lat2 - Lat1
        let Step1 = pow(sin(LatDelta / 2), 2) +
        cos(Lat1) * cos(Lat2) * pow(sin(LonDelta / 2), 2)
        let Step2 = 2 * asin(sqrt(Step1))
        let Step3 = Step2 * 6371
        return Step3
    }
    
    /// Construct the earthquake list.
    /// - Note: Duplicate earthquakes are not added.
    /// - Parameter New: The new earthquake to add to the list.
    /// - Parameter To: The existing earthquake list.
    public static func AddEarthquake(New Quake: Earthquake, To Current: inout [Earthquake])
    {
        for Existing in Current
        {
            let Added = Existing.AddIfRelated(Quake)
            if Added
            {
                return
            }
        }
        for Existing in Current
        {
            if Existing.Code == Quake.Code
            {
                return
            }
        }
        Current.append(Quake)
    }
    
    private var EarthquakeLock = NSObject()
    
    /// Add an earthquake related to this earthquake as a sub-earthquake. "Related" only means the passed
    /// earthquake happened within a certain distance and time of this earthquake, not that they are necessarily
    /// due to the same cause.
    /// - Note: Only one thread at a time is allowed to access this function and it is synchronized to
    ///         enforce that.
    /// - Parameter Quake: The quake to add to this quake's related earthquakes.
    public func AddRelated(_ Quake: Earthquake)
    {
        objc_sync_enter(EarthquakeLock)
        defer{objc_sync_exit(EarthquakeLock)}
        if Related == nil
        {
            Related = [Earthquake]()
        }
        Related?.append(Quake)
        if Quake.Magnitude > GreatestMagnitudeValue
        {
            GreatestMagnitudeValue = Quake.Magnitude
        }
    }
    
    /// Used by other classes for inclusion into groups.
    public var Marked: Bool = false
    
    /// Provides a debug description.
    var description: String
    {
        if let Related = Related
        {
            return "\(Magnitude.RoundedTo(3))@(\(Latitude),\(Longitude))#=\(Related.count), Max=\(GreatestMagnitude)"
        }
        else
        {
            return "\(Magnitude.RoundedTo(3))@(\(Latitude),\(Longitude))#=0"
        }
    }
    
    // MARK: - Hashable functions.
    
    static func == (lhs: Earthquake, rhs: Earthquake) -> Bool
    {
        return ObjectIdentifier(lhs) == ObjectIdentifier(rhs)
    }
    
    func hash(into hasher: inout Hasher)
    {
        hasher.combine(Code)
    }
    
    var hasValue: Int
    {
        return ObjectIdentifier(self).hashValue
    }
    
    // MARK: Database helper functions
    
    static func MakeValueList(_ From: Earthquake) -> String
    {
        var Values = "("
        Values.append("\(From.Latitude),")
        Values.append("\(From.Longitude),")
        Values.append("\"\(From.Place)\",")
        Values.append("\(From.Magnitude),")
        Values.append("\(From.Depth),")
        Values.append("\(From.Time.timeIntervalSince1970),")
        Values.append("\(From.Updated.timeIntervalSince1970),")
        Values.append("\"\(From.Code)\",")
        Values.append("\(From.Tsunami),")
        Values.append("\"\(From.Status)\",")
        Values.append("\(From.MMI),")
        Values.append("\(From.Felt),")
        Values.append("\(From.Significance),")
        Values.append("\(From.Sequence),")
        Values.append("\(From.Notified ? 1 : 0),")
        Values.append("\"\(From.RegionName)\",")
        Values.append("\(From.Marked ? 1 : 0),")
        Values.append("\"\(From.MagType)\",")
        Values.append("\(From.MagError),")
        Values.append("0,")
        Values.append("\(From.DMin),")
        Values.append("\"\(From.Alert)\",")
        Values.append("\"\(From.Title)\",")
        Values.append("\"\(From.Types)\",")
        Values.append("\"\(From.EventType)\",")
        Values.append("\"\(From.Detail)\",")
        Values.append("\(From.TZ),")
        Values.append("\"\(From.EventPageURL)\",")
        Values.append("\"\(From.Sources)\",")
        Values.append("\"\(From.Net)\",")
        Values.append("\(From.NST),")
        Values.append("\(From.Gap),")
        Values.append("\"\(From.IDs)\",")
        Values.append("\(From.HorizontalError),")
        Values.append("\(From.CDI),")
        Values.append("\(From.RMS),")
        Values.append("\"\(From.NPH)\",")
        Values.append("\"\(From.LocationSource)\",")
        Values.append("\"\(From.MagSource)\",")
        Values.append("\(From.ContextDistance),")
        Values.append("\(From.DebugQuake ? 1 : 0),")
        Values.append("0.0,")
        Values.append("\"\(From.EventID)\"")
        Values.append(")")
        return Values
    }
    
    /// Gets the name of the column for the specified column enum.
    /// - Parameter For: The column enum whose name will be returned.
    /// - Returns: The name of the database column for the specified enum on success, nil if not found or
    ///            on other error condition.
    static func ColumnName(For: QuakeColumns) -> String?
    {
        let Index = For.rawValue
        if Index < 0 || Index > QuakeColumnTable.count - 1
        {
            return nil
        }
        return QuakeColumnTable[Int(Index)]
    }
    
    // MARK: - Static functions for reflecting data.
    
    /// Returns an array of property names and values for fields backed by a database.
    /// - Parameter Quake: The quake whose property data will be returned.
    /// - Returns: Array of tuples. Each tuple has a property name and property value. The property value is
    ///            converted to a string. Nil values are converted to default values for the type (eg, strings
    ///            are converted to "" and numbers to 0).
    static func GetFieldData(_ Quake: Earthquake) -> [(String, String)]
    {
        var FieldData = [(String, String)]()
        let QuakeProperties = Mirror(reflecting: Quake).children
        for Property in QuakeProperties
        {
            if var PropertyName = Property.label
            {
                if PropertyName.starts(with: "__")
                {
                    var FinalValue = ""
                    PropertyName = String(PropertyName.dropFirst(2))
                    if Mirror.IsOptional(Property.value)
                    {
                        FinalValue = "\(Property.value)"
                        if FinalValue == "nil"
                        {
                            if type(of: Property.value) == String.self
                            {
                                FinalValue = "\"\""
                            }
                            else
                            {
                                FinalValue = "0"
                            }
                        }
                    }
                    else
                    {
                        let PropertyType = "\(type(of: Property.value))"
                        switch PropertyType
                        {
                            case "Date":
                                if let SomeDate = Property.value as? Date
                                {
                                    FinalValue = "\(SomeDate.timeIntervalSince1970)"
                                }
                                else
                                {
                                    FinalValue = "0"
                                }
                                
                            case "UUID":
                                if FinalValue.isEmpty
                                {
                                    FinalValue = "\"\(UUID().uuidString)\""
                                }
                                else
                                {
                                    FinalValue = "\"\(FinalValue)\""
                                }
                                
                            case "String":
                                FinalValue = "\"\(Property.value)\""
                                
                            default:
                                FinalValue = "\(Property.value)"
                        }
                    }
                    FieldData.append((PropertyName, FinalValue))
                }
            }
        }
        return FieldData
    }
    
    /// Array of quake column names.
    static let QuakeColumnTable: [String] =
    [
        "ID",
        "Latitude",
        "Longitude",
        "Place",
        "Magnitude",
        "Depth",
        "Time",
        "Updated",
        "Code",
        "Tsunami",
        "Status",
        "MMI",
        "Felt",
        "Significance",
        "Sequence",
        "Notified",
        "FlatlandRegion",
        "Marked",
        "MagType",
        "MagError",
        "MagNS",
        "DMin",
        "Alert",
        "Title",
        "Types",
        "EventType",
        "Detail",
        "TZ",
        "EventPageURL",
        "Sources",
        "Net",
        "NST",
        "Gap",
        "IDs",
        "HorizontalError",
        "CDI",
        "RMS",
        "NPH",
        "LocationSource",
        "MagSource",
        "ContextDistance",
        "DebugQuake",
        "QuakeDate",
        "QuakeID",
        "EventID"
    ]
}


extension Mirror
{
    static func IsOptional(_ Something: Any) -> Bool
    {
        guard let style = Mirror(reflecting: Something).displayStyle,
              style == .optional else
              {
                  return false
              }
        return true
    }
}
