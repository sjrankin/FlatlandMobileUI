//
//  USGS.swift
//  USGS
//
//  Created by Stuart Rankin on 7/18/21. Adapted from Flatland View.
//

import Foundation
import UIKit

/// This class is used to receive earthquake data from the USGS. Data is received asynchronously on a
/// background thread and posted to `Delegate` when available.
/// - Note:
///   - See [USGS GeoJSON](https://earthquake.usgs.gov/earthquakes/feed/v1.0/geojson.php)
///   - See [API Documentation - Earthqake Catalog](https://earthquake.usgs.gov/fdsnws/event/1/)
///   - See [USGS Developer's Corner](https://github.com/usgs/devcorner)
///   - See [USGS Web Services](https://earthquake.usgs.gov/ws/)
class USGS
{
    /// Number of times earthquakes were retrieved.
    public static var CallCount: Int = 0
    
    /// Total number of seconds needed to retrieve seconds from the USGS.
    public static var TotalDuration: Double = 0.0
    
    /// Total number of errors returned when attempting to retrieve data.
    public static var CommErrorCount: Int = 0
    
    /// Total number of parse errors.
    public static var ParseErrorCount: Int = 0
    
    /// Total number of response errors.
    public static var ResponseErrorCount: Int = 0
    
    /// Total number of time-out errors.
    public static var TimeOutCount: Int = 0
    
    /// Total number of earthquakes retrieved.
    public static var TotalRetrieved: Int = 0
    
    /// Cumulative distribution of earthquake magnitudes.
    public static var MagDistribution: [Int: Int] =
    [
        0: 0,
        1: 0,
        2: 0,
        3: 0,
        4: 0,
        5: 0,
        6: 0,
        7: 0,
        8: 0,
        9: 0,
        10: 0
    ]
    
    /// The delegate of who receives asynchronous data.
    public weak var Delegate: AsynchronousDataProtocol? = nil
    
    /// Start calling the USGS for earthquake data.
    /// - Note: Data is returned asynchronously via the `Delegate`. If `Delegate` is not assigned
    ///         by the caller, no data is returned.
    /// - Parameter Every: Number of seconds between calls. Suggest no more frequent than every
    ///                    ten minutes.
    func GetEarthquakes(Every: Double)
    {
        EarthquakeTimer?.invalidate()
        EarthquakeTimer = nil
        EarthquakeTimer = Timer.StartRepeating(withTimerInterval: Every, RunFirst: true)
        {
            [weak self] _ in
            self?.DoGetEarthquakes()
        }
    }
    
    /// Mose of the code to get earthquakes from the USGS.
    func DoGetEarthquakes()
    {
        _IsBusy = true
        defer
        {
            _IsBusy = false
        }
        USGS.CallCount = USGS.CallCount + 1
        EarthquakeStartTime = CACurrentMediaTime()
        let RetrievalQueue = OperationQueue()
        RetrievalQueue.qualityOfService = .background
        RetrievalQueue.name = "Earthquake Retrieval Queue"
        RetrievalQueue.addOperation
        {
            MemoryDebug.Open("\(#function)")
            self.GetUSGSEarthquakeData
            {
                [weak self] Results in
                if var Raw = Results
                {
                    do
                    {
                        let RawData = Data(Raw.utf8)
                        if let json = try JSONSerialization.jsonObject(with: RawData, options: []) as? [String: Any]
                        {
                            for (Name, _) in json
                            {
                                if Name == "features"
                                {
                                    if let Feature = json["features"] as? [[String: Any]]
                                    {
                                        let Quakes = USGS.ParseJsonEntity(Feature)
                                        self?.ClearEarthquakes()
                                        for Quake in Quakes
                                        {
                                            self?.AddEarthquakeToList(Quake)
                                        }
                                    }
                                }
                                
                            }
                        }
                    }
                    catch
                    {
                        USGS.ParseErrorCount = USGS.ParseErrorCount + 1
                        print("JSON error \(error)")
                    }
                    self?.HaveAllEarthquakes()
                    Raw.removeAll()
                    MemoryDebug.Close("\(#function)")
                }
                else
                {
                    print("Nothing to do")
                }
            }
        }
    }
    
    var EarthquakeStartTime: Double = 0.0
    
    var RetrievalQueue: OperationQueue? = nil
    
    /// Holds the busy flag.
    private var _IsBusy: Bool = false
    /// Get the busy flag. This is set when getting data from online sources and reset once all data has
    /// been received. When this flag is true, other threads should not access earthquakes.
    public var IsBusy: Bool
    {
        get
        {
            return _IsBusy
        }
    }
    
    /// Called by `GetNewEarthquakeData` when all data for a given asynchronous call have been
    /// received and parsed. Calls `Delegate` on the main thread. The array of earthquakes passed
    /// to the delegate is flat and uncombined.
    func HaveAllEarthquakes()
    {
        DispatchQueue.main.async
        {
            let FinalList = self.MakeEarthquakeList()
            self.GenerateMagDistribution(FinalList)
            USGS.TotalRetrieved = USGS.TotalRetrieved + FinalList.count
            self.CurrentList = FinalList.filter({$0.Magnitude >= 4.0})
            self.Delegate?.AsynchronousDataAvailable(CategoryType: .Earthquakes, Actual: FinalList as Any,
                                                     StartTime: self.EarthquakeStartTime, Context: nil)
        }
    }
    
    /// Accumulate the magnitude distribution for earthquakes.
    /// - Parameter Quakes: The list of earthquakes used to create the distribution.
    private func GenerateMagDistribution(_ Quakes: [Earthquake])
    {
        for Quake in Quakes
        {
            let Mag = Int(Quake.Magnitude)
            if var Current = USGS.MagDistribution[Mag]
            {
                Current = Current + 1
                USGS.MagDistribution[Mag] = Current
            }
        }
    }
    
    /// Creates a list of earthquakes.
    /// - Returns: Array of current earthquakes including debug and injected quakes.
    private func MakeEarthquakeList() -> [Earthquake]
    {
        var FinalList = RemoveDuplicates(From: EarthquakeList)
#if DEBUG
        FinalList.append(contentsOf: DebugEarthquakes)
        FinalList.append(contentsOf: InjectedEarthquakes)
#endif
        return FinalList
    }
    
    private var CurrentList = [Earthquake]()
    
    /// Determines if a given earthquake happened in the number of days prior to the instance.
    /// - Parameter Quake: The earthquake to test against `InRange`.
    /// - Parameter InRange: The range of allowable earthquakes.
    /// - Returns: True if `Quake` is within the age range specified by `InRange`, false if not.
    func InAgeRange(_ Quake: Earthquake, InRange: EarthquakeAges) -> Bool
    {
        let Index = EarthquakeAges.allCases.firstIndex(of: InRange)! + 1
        let Seconds = Index * (60 * 60 * 24)
        let Delta = Date().timeIntervalSinceReferenceDate - Quake.Time.timeIntervalSinceReferenceDate
        return Int(Delta) < Seconds
    }
    
    /// Removed duplicate related earthquakes.
    /// - Parameter Quakes: The array of earthquakes whose related earthquakes will be cleaned up.
    /// - Returns: New array of earthquakes with duplicate combined earthquakes removed.
    func CleanUpCombined(_ Quakes: [Earthquake]) -> [Earthquake]
    {
        let Working = Quakes
        for Quake in Working
        {
            if let RelatedQuakes = Quake.Related
            {
                var NewRelated = [String: Earthquake]()
                for RQuake in RelatedQuakes
                {
                    if RQuake.Code == Quake.Code
                    {
                        continue
                    }
                    if let _ = NewRelated[RQuake.Code]
                    {
                        continue
                    }
                    NewRelated[RQuake.Code] = RQuake
                }
                Quake.Related = [Earthquake]()
                for (_, SubQuake) in NewRelated
                {
                    Quake.Related?.append(SubQuake)
                }
            }
        }
        return Working
    }
    
    /// Force fetch earthquake data regardless of the fetch cycle.
    func ForceFetch()
    {
        DoGetEarthquakes()
    }
    
    /// Insert a debug earthquake.
    /// - Note: Will be returned at the next fetch cycle.
    /// - Parameter Latitude: The latitude of the debug earthquake.
    /// - Parameter Longitude: The longitude of the debug earthquake.
    /// - Parameter Magnitude: The magnitude of the debug earthquake.
    func InsertDebugEarthquake(Latitude: Double, Longitude: Double, Magnitude: Double)
    {
        let DebugQuake = Earthquake(Sequence: 100000)
        DebugQuake.Latitude = Latitude
        DebugQuake.Longitude = Longitude
        DebugQuake.Magnitude = Magnitude
        DebugEarthquakes.append(DebugQuake)
    }
    
    /// Insert a cluster of earthquakes for debug purposes.
    /// - Parameter Count: The number of earthquakes to insert.
    /// - Parameter Within: The number of earthquakes that will be within 500 kilometers of the first earthquake.
    ///                     If nil, all earthquakes will be within range.
    func InsertEarthquakeCluster(_ Count: Int, Within Distance: Int? = nil, ClusterRange: Double = 500.0)
    {
        let Base = Earthquake(Sequence: 200000)
        let (Lat, Lon) = RandomLocation()
        Base.Latitude = Lat
        Base.Longitude = Lon
        Base.Code = "Cluster Base"
        Base.Magnitude = Double.random(in: 5.0 ... 9.5)
        DebugEarthquakes.append(Base)
        var FinalCount = Count
        if let InRange = Distance
        {
            if InRange < FinalCount
            {
                FinalCount = FinalCount - InRange
                for Index in 0 ..< InRange
                {
                    let OutOfRangeQuake = Earthquake(Sequence: 200002)
                    let (Lat, Lon) = RandomLocation()
                    OutOfRangeQuake.Latitude = Lat
                    OutOfRangeQuake.Longitude = Lon
                    OutOfRangeQuake.Code = "Cluster far \(Index)"
                    OutOfRangeQuake.Magnitude = Double.random(in: 5.0 ... 9.5)
                    DebugEarthquakes.append(OutOfRangeQuake)
                }
            }
        }
        for Index in 0 ..< FinalCount
        {
            let InRangeQuake = Earthquake(Sequence: 200001)
            let (Lat, Lon) = RandomLocation(Near: Base, Distance: ClusterRange)
            InRangeQuake.Latitude = Lat
            InRangeQuake.Longitude = Lon
            InRangeQuake.Code = "Cluster close \(Index)"
            InRangeQuake.Magnitude = Double.random(in: 5.0 ... 9.5)
            DebugEarthquakes.append(InRangeQuake)
        }
    }
    
    /// Create a random location based on the passed earthquake and maximum distance.
    /// - Note: This is not optimized and if you are unlucky, will never return.
    /// - Parameter Near: The base earthquake.
    /// - Parameter Distance: The maximum distance of a random location from `Near`.
    /// - Returns: Tuple with the latitude and longitude of a randomly generated location.
    func RandomLocation(Near Quake: Earthquake, Distance: Double) -> (Latitude: Double, Longitude: Double)
    {
        while true
        {
            let (Lat, Lon) = RandomLocation()
            if Quake.DistanceTo(Lat, Lon) <= Distance
            {
                return (Lat, Lon)
            }
        }
    }
    
    /// Create a random location somewhere on the surface of the world.
    /// - Returns: Tuple with the latitude and longitude of a randomly generated location.
    func RandomLocation() -> (Latitude: Double, Longitude: Double)
    {
        return (Latitude: Double.random(in: -90.0 ... 90.0), Longitude: Double.random(in: -180.0 ... 180.0))
    }
    
    /// Remove all debug earthquakes.
    func ClearDebugEarthquakes()
    {
        DebugEarthquakes.removeAll()
    }
    
    /// Remove duplicate entries from the passed list of earthquakes.
    /// - Note: Duplicates are defined as earthquakes with the same code.
    /// - Parameter From: The source list of earthquakes with possible duplicates.
    /// - Returns: List of earthquakes with no duplicates.
    func RemoveDuplicates(From: [Earthquake]) -> [Earthquake]
    {
        var Unique = [String: Earthquake]()
        for Quake in From
        {
            if let _ = Unique[Quake.Code]
            {
                continue
            }
            Unique[Quake.Code] = Quake
        }
        return Unique.map{$1}
    }
    
    public static func RemoveDuplicates(From: [Earthquake]) -> [Earthquake]
    {
        var Unique = [String: Earthquake]()
        for Quake in From
        {
            let QuakeCode = Quake.Code.trimmingCharacters(in: .whitespacesAndNewlines)
            if let _ = Unique[QuakeCode]
            {
                continue
            }
            Unique[QuakeCode] = Quake
        }
        return Unique.map{$1}
    }
    
    /// Filter the passed list for minimum magnitude. Earthquakes that have a magnitude less than
    /// the passed value are excluded from the returned list.
    /// - Parameter List: The source list to filter.
    /// - Parameter Magnitude: The minimum magnitude an earthquake must have to be returned.
    /// - Returns: List of earthquakes from `List` that have a magnitude greater or equal to `Magnitude`.
    func FilterForMagnitude(_ List: [Earthquake], Magnitude: Double) -> [Earthquake]
    {
        var Final = [Earthquake]()
        for Quake in List
        {
            if Quake.Magnitude >= Magnitude
            {
                Final.append(Quake)
            }
        }
        return Final
    }
    
    /// Perform the actual web call here to get the list of USGS earthquakes.
    /// - Parameter completion: The completion handler called when results are available.
    func GetUSGSEarthquakeData(_ completion: @escaping (String?) -> Void)
    {
        //let url = URL(string: "http://earthquake.usgs.gov/earthquakes/feed/v1.0/summary/all_month.geojson")
        let url = URL(string: "https://earthquake.usgs.gov/earthquakes/feed/v1.0/summary/4.5_week.geojson")
        URLSession.shared.downloadTask(with: url!)
        {
            Local, Response, error in
            guard let HTTPResponse = Response as? HTTPURLResponse,
                  (200 ... 299).contains(HTTPResponse.statusCode) else
                  {
                      if let HTTPResponse = Response as? HTTPURLResponse
                      {
                          Debug.Print("Response error: \(HTTPResponse)")
                          USGS.ResponseErrorCount = USGS.ResponseErrorCount + 1
                          completion(nil)
                          return
                      }
                      else
                      {
                          Debug.Print("HTTP error but no response. Probably timed-out.")
                          USGS.TimeOutCount = USGS.TimeOutCount + 1
                          completion(nil)
                          return
                      }
                  }
            USGS.CommErrorCount = USGS.CommErrorCount + 1
            if let LocalURL = Local
            {
                if let Results = try? String(contentsOf: LocalURL)
                {
                    completion(Results)
                }
            }
        }.resume()
    }
    
    /// Stops the timer to get earthquakes from the USGS.
    func StopReceivingEarthquakes()
    {
        EarthquakeTimer?.invalidate()
        EarthquakeTimer = nil
    }
    
    /// Timer for getting USGS earthquakes.
    var EarthquakeTimer: Timer? = nil
    
    /// Parse a JSON dictionary into an array of earthquake data.
    /// - Parameter JSON: Array of arrays of JSON data.
    static func ParseJsonEntity(_ JSON: [[String: Any]]) -> [Earthquake]
    {
        var Seq = 0
        var Quakes = [Earthquake]()
        for OneFeature in JSON
        {
            let NewEarthquake = Earthquake(Sequence: Seq)
            for subset in OneFeature
            {
                
                Seq = Seq + 1
                let Dict = Dictionary(dictionaryLiteral: subset)
                for (Key, Value) in Dict
                {
                    let SubDict = Value as? [String: Any]
                    if SubDict == nil
                    {
                        continue
                    }
                    switch Key
                    {
                        case "geometry":
                            for (GeoKey, GeoVal) in SubDict!
                            {
                                if GeoKey == "coordinates"
                                {
                                    if let A = GeoVal as? [Double]
                                    {
                                        NewEarthquake.SetLocation(A[1], A[0])
                                        NewEarthquake.Depth = A[2]
                                    }
                                }
                            }
                            
                        case "properties":
                            for (PropKey, PropVal) in SubDict!
                            {
                                switch PropKey
                                {
                                    case "mag":
                                        if let Magnitude = PropVal as? Double
                                        {
                                            NewEarthquake.Magnitude = Magnitude
                                        }
                                        else
                                        {
                                            NewEarthquake.Magnitude = 0.0
                                        }
                                        
                                    case "place":
                                        NewEarthquake.Place = PropVal as! String
                                        
                                    case "time":
                                        var TimeDouble = PropVal as! Double
                                        TimeDouble = TimeDouble / 1000.0
                                        NewEarthquake.Time = Date(timeIntervalSince1970: TimeDouble)
                                        
                                    case "tsunami":
                                        NewEarthquake.Tsunami = PropVal as! Int
                                        
                                    case "code":
                                        NewEarthquake.Code = PropVal as! String
                                        
                                    case "status":
                                        NewEarthquake.Status = PropVal as! String
                                        
                                    case "updated":
                                        var UpdatedDouble = PropVal as! Double
                                        UpdatedDouble = UpdatedDouble / 1000.0
                                        NewEarthquake.Updated = Date(timeIntervalSince1970: UpdatedDouble)
                                        
                                    case "mmi":
                                        if let MMI = PropVal as? Double
                                        {
                                            NewEarthquake.MMI = MMI
                                        }
                                        
                                    case "felt":
                                        if let Felt = PropVal as? Int
                                        {
                                            NewEarthquake.Felt = Felt
                                        }
                                        
                                    case "sig":
                                        NewEarthquake.Significance = PropVal as! Int
                                        
                                    case "title":
                                        NewEarthquake.Title = PropVal as! String
                                        
                                    case "magError":
                                        if let MagError = PropVal as? Double
                                        {
                                            NewEarthquake.MagError = MagError
                                        }
                                        
                                    case "magNst":
                                        NewEarthquake.MagNST = PropVal as! Int
                                        
                                    case "magSource":
                                        NewEarthquake.MagSource = PropVal as! String
                                        
                                    case "magType":
                                        if let MagType = PropVal as? String
                                        {
                                            NewEarthquake.MagType = MagType
                                        }
                                        
                                    case "net":
                                        NewEarthquake.Net = PropVal as! String
                                        
                                    case "nph":
                                        NewEarthquake.NPH = PropVal as! String
                                        
                                    case "nst":
                                        if let NST = PropVal as? Int
                                        {
                                            NewEarthquake.NST = NST
                                        }
                                        
                                    case "sources":
                                        NewEarthquake.Sources = PropVal as! String
                                        
                                    case "type":
                                        NewEarthquake.EventType = PropVal as! String
                                        
                                    case "types":
                                        NewEarthquake.Types = PropVal as! String
                                        
                                    case "tz":
                                        if let TZ = PropVal as? Int
                                        {
                                            NewEarthquake.TZ = TZ
                                        }
                                        
                                    case "alert":
                                        if let Alert = PropVal as? String
                                        {
                                            NewEarthquake.Alert = Alert
                                        }
                                        
                                    case "url":
                                        NewEarthquake.EventPageURL = PropVal as! String
                                        
                                    case "cdi":
                                        if let CDI = PropVal as? Double
                                        {
                                            NewEarthquake.CDI = CDI
                                        }
                                        
                                    case "depthError":
                                        if let DepthError = PropVal as? Double
                                        {
                                            NewEarthquake.DepthError = DepthError
                                        }
                                        
                                    case "detail":
                                        NewEarthquake.Detail = PropVal as! String
                                        
                                    case "dmin":
                                        if let DMin = PropVal as? Double
                                        {
                                            NewEarthquake.DMin = DMin
                                        }
                                        
                                    case "gap":
                                        if let Gap = PropVal as? Double
                                        {
                                            NewEarthquake.Gap = Gap
                                        }
                                        
                                    case "horizontalError":
                                        if let HError = PropVal as? Double
                                        {
                                            NewEarthquake.HorizontalError = HError
                                        }
                                        
                                    case "id":
                                        NewEarthquake.EventID = PropVal as! String
                                        
                                    case "ids":
                                        NewEarthquake.IDs = PropVal as! String
                                        
                                    case "locationSource":
                                        NewEarthquake.LocationSource = PropVal as! String
                                        
                                    case "rms":
                                        if let RMS = PropVal as? Double
                                        {
                                            NewEarthquake.RMS = RMS
                                        }
                                        
                                    default:
                                        continue
                                }
                            }
                            
                        default:
                            continue
                    }
                }
                
                
#if true
                Quakes.append(NewEarthquake)
#else
                /// To prevent too many earthquakes from slowing things down, if an earthquake is less than
                /// a general minimum magnitude, it won't be included.
                if NewEarthquake.Magnitude >= Settings.GetDouble(.GeneralMinimumMagnitude, 4.0)
                {
                    AddEarthquakeToList(NewEarthquake)
                }
#endif
            }
        }
        return Quakes
    }
    
    var ListAccess = NSObject()
    
    private func AddEarthquakeToList(_ NewQuake: Earthquake)
    {
        objc_sync_enter(ListAccess)
        defer{objc_sync_exit(ListAccess)}
        EarthquakeList.append(NewQuake)
    }
    
    private func ClearEarthquakes()
    {
        objc_sync_enter(ListAccess)
        defer{objc_sync_exit(ListAccess)}
        EarthquakeList.removeAll()
    }
    
    public func GetCurrentEarthquakes() -> [Earthquake]
    {
        objc_sync_enter(ListAccess)
        defer{objc_sync_exit(ListAccess)}
        return EarthquakeList
    }
    
    /// Current list of earthquakes.
    var EarthquakeList = [Earthquake]()
    var DebugEarthquakes = [Earthquake]()
    
    /// Determines if two lists of earthquakes have the same contents. This function works regardless
    /// of the order of the contents.
    /// - Note: Equality is based on the `Code` of each earthquake, assigned by the USGS.
    /// - Parameter List1: First earthquake list.
    /// - Parameter List2: Second earthquake list.
    /// - Returns: True if the lists have equal contents, false if not.
    public static func SameEarthquakes(_ List1: [Earthquake], _ List2: [Earthquake]) -> Bool
    {
        if List1.count != List2.count
        {
            return false
        }
        let SList1 = List1.sorted(by: {$0.Code < $1.Code})
        let SList2 = List2.sorted(by: {$0.Code < $1.Code})
        return SList1 == SList2
    }
    
    /// Flatten the passed list of earthquakes. All earthquakes will be at the top-most level
    /// of the array.
    /// - Parameter Quakes: The array of earthquakes to flatten.
    /// - Returns: Array of earthquakes, all at the top-most level.
    public static func FlattenEarthquakes(_ Quakes: [Earthquake]) -> [Earthquake]
    {
        var Final = [Earthquake]()
        for Quake in Quakes
        {
            if let Related = Quake.Related
            {
                for RelatedQuake in Related
                {
                    Final.append(RelatedQuake)
                }
                Quake.Related?.removeAll()
                Quake.Related = nil
                Quake.Marked = false
                Final.append(Quake)
            }
            else
            {
                Quake.Marked = false
                Final.append(Quake)
            }
        }
        return Final
    }
    
    /// Place an earthquake in the proper location. Passed earthquakes are added to earthquakes already in
    /// `To` if they are close enough. Otherwise, the are added at the end of the array.
    /// - Parameter Quake: The earthquake to place into the passed earthquake list.
    /// - Parameter To: The earthquake list where `Quake` will be placed.
    /// - Parameter InRange: How close `Quake` must be to an earthquake in `To` in order for it to be added
    ///                      to that earthquake.
    private static func AddForCombined(_ Quake: Earthquake, To: inout [Earthquake], InRange: Double)
    {
        if To.isEmpty
        {
            To.append(Quake)
            return
        }
        for Combined in To
        {
            let Distance = Combined.DistanceTo(Quake)
            if Distance <= InRange
            {
                Combined.AddRelated(Quake)
                return
            }
        }
        To.append(Quake)
    }
    
    /// Inject the passed earthquake. Presumed to be for debugged purposes.
    /// - Note: `HaveAllEarthquakes` is called immediately after adding the injected earthquake.
    /// - Parameter Quake: The earthquake to inject.
    public func InjectEarthquake(_ Quake: Earthquake)
    {
        InjectedEarthquakes.append(Quake)
        print("InjectedEarthquakes.count=\(InjectedEarthquakes.count)")
        HaveAllEarthquakes()
    }
    
    /// Remove all injected earthquakes.
    /// - Note: `HaveAllEarthquakes` is called immediately after clearing injected earthquakes.
    public func ClearInjectedEarthquakes()
    {
        InjectedEarthquakes.removeAll()
        HaveAllEarthquakes()
    }
    
    /// Array of injected earthquakes.
    private var InjectedEarthquakes = [Earthquake]()
    
    private static var USGSLock = NSObject()
    
    /// Return an `Earthquake2` class with the greatest magnitude of `Quake` and its child earthquakes. If
    /// `Quake` does not have any related earthquakes, it is returned as is.
    /// - Parameter From: The earthquake whose child earthquakes are used to determine the greatest earthquake.
    /// - Returns: `Earthquake2` class with the greatest earthquake (based on magnitude) of `Quake`. If a child
    ///            earthquake has a greater magnitude than `Quake`, `Quake` is converted to a child earthquake.
    private static func GetGreatestMagnitude(From Quake: Earthquake) -> Earthquake
    {
        objc_sync_enter(USGSLock)
        defer{objc_sync_exit(USGSLock)}
        let ParentMagnitude = Quake.Magnitude
        var MaxChild: Earthquake? = nil
        MaxChild = Quake.Related!.max(by: {(E1, E2) -> Bool in E1.Magnitude > E2.Magnitude})
        MaxChild?.Related?.removeAll()
        if MaxChild!.Magnitude < ParentMagnitude
        {
            return Quake
        }
        for ChildQuake in Quake.Related!
        {
            if ChildQuake.Code != MaxChild?.Code
            {
                MaxChild?.AddRelated(ChildQuake)
            }
        }
        let OldParent = Earthquake(Quake)
        MaxChild?.AddRelated(OldParent)
        return MaxChild!
    }
    
    /// Return an `Earthquake2` class with the earliest date of `Quake` and its child earthquakes. If
    /// `Quake` does not have any related earthquakes, it is returned as is.
    /// - Parameter From: The earthquake whose child earthquakes are used to determine the earliest date.
    /// - Returns: `Earthquake2` class with the earliest earthquake (based on date) of `Quake`. If a child
    ///            earthquake has an earlier date than `Quake`, `Quake` is converted to a child earthquake.
    private static func GetEarliestEarthquake(From Quake: Earthquake) -> Earthquake
    {
        let ParentDate = Quake.Time
        var EarliestChild: Earthquake? = nil
        EarliestChild = Quake.Related!.max(by: {(E1, E2) -> Bool in E1.Time < E2.Time})
        if EarliestChild!.Time > ParentDate
        {
            return Quake
        }
        for ChildQuake in Quake.Related!
        {
            if ChildQuake.Code != EarliestChild?.Code
            {
                EarliestChild?.AddRelated(ChildQuake)
            }
        }
        let OldParent = Earthquake(Quake)
        EarliestChild?.AddRelated(OldParent)
        return EarliestChild!
    }
    
    /// Determines whether an earthquake is related to another solely based on distance.
    /// - Parameter Quake: The quake to determine which group it belongs to.
    /// - Parameter To: The set of grouped earthquakes. If no other earthquake is found, `Quake` is placed
    ///                 at the top level. The first earthquake that is within `InRange` is used even if there
    ///                 are closer earthquakes.
    /// - Parameter InRange: Distance that determines inclusion.
    private static func AddForCombined2(_ Quake: Earthquake, To TopLevel: inout [Earthquake], InRange: Double)
    {
        if TopLevel.isEmpty
        {
            TopLevel.append(Quake)
            return
        }
        for SomeQuake in TopLevel
        {
            let Distance = SomeQuake.DistanceTo(Quake)
            if Distance <= InRange
            {
                SomeQuake.AddRelated(Quake)
                return
            }
        }
        TopLevel.append(Quake)
    }
    
    /// Combine earthquakes according to how close they are to each other.
    /// - Parameter Quakes: The source list of earthquakes.
    /// - Parameter Closeness: Determines the radius of how close earthquakes must be to be considered to be
    ///                        in a group.
    /// - Returns: List of grouped earthquakes.
    public static func CombineEarthquakes2(_ Quakes: [Earthquake], Closeness: Double = 100.0) -> [Earthquake]
    {
        var Combined = [Earthquake]()
        for Quake in Quakes
        {
            AddForCombined2(Quake, To: &Combined, InRange: Closeness)
        }
        var Final = [Earthquake]()
        for Quake in Combined
        {
            if !Quake.IsCluster
            {
                Final.append(Quake)
            }
            else
            {
                if let Biggest = Quake.GreatestMagnitudeEarthquake
                {
                    let NewQuake = Earthquake(Biggest, IncludeRelated: false, IsBiggest: true)
                    for ChildQuake in Quake.Related!
                    {
                        NewQuake.AddRelated(ChildQuake)
                    }
                    NewQuake.RemoveDuplicates()
                    Final.append(NewQuake)
                }
            }
        }
        Final = RemoveDuplicates(From: Final)
        return Final
    }
    
    /// Combined the passed list of earthquakes. All earthquakes within a certain radius will be
    /// put into a single earthquake node.
    /// - Note: This function assumes the passed earthquake list is flat.
    /// - Parameter Quakes: The array of earthquakes to combine.
    /// - Parameter Closeness: How close earthquakes must be to be considered to be combined. Units
    ///                        are kilometers. Default is `100.0`.
    /// - Parameter RelatedOrderedBy: Determines how earthquakes with related earthquakes are ordered. Defaults
    ///                               to `.ByGreatestMagnitude`.
    /// - Returns: Array of combined earthquakes.
    public static func CombineEarthquakesX(_ Quakes: [Earthquake], Closeness: Double = 100.0,
                                           RelatedOrderedBy: MultipleQuakeOrders = .ByGreatestMagnitude) -> [Earthquake]
    {
        var Combined = [Earthquake]()
        for Quake in Quakes
        {
            AddForCombined(Quake, To: &Combined, InRange: Closeness)
        }
        switch RelatedOrderedBy
        {
            case .Unordered:
                return Combined
                
            case .ByGreatestMagnitude:
                var Fixed = [Earthquake]()
                for Quake in Combined
                {
                    if Quake.IsCluster
                    {
                        let Greatest = GetGreatestMagnitude(From: Quake)
                        Fixed.append(Greatest)
                    }
                    else
                    {
                        Fixed.append(Quake)
                    }
                }
                return Fixed
                
            case .ByEarliestDate:
                var Fixed = [Earthquake]()
                for Quake in Combined
                {
                    if Quake.IsCluster
                    {
                        let Greatest = GetGreatestMagnitude(From: Quake)
                        Fixed.append(Greatest)
                    }
                    else
                    {
                        Fixed.append(Quake)
                    }
                }
                return Fixed
        }
    }
    
    /// Returns the name of the region where the earthquake occurred.
    /// - Parameter Quake: The quake whose region name will be returned.
    /// - Returns: Name of the region where the quake occurred. If the quake did not occur in a region,
    ///            an empty string is returned.
    public static func InRegion(_ Quake: Earthquake) -> String
    {
        for Region in Settings.GetEarthquakeRegions()
        {
            if Region.IsFallback
            {
                continue
            }
            if Region.InRegion(Latitude: Quake.Latitude, Longitude: Quake.Longitude)
            {
                return Region.RegionName
            }
        }
        return ""
    }
}


