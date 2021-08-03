//
//  MainController.swift
//  Flatland
//
//  Created by Stuart Rankin on 9/13/20. Adapted from Flatland View.
//  Copyright © 2020, 2021 Stuart Rankin. All rights reserved.
//

import Foundation
import UIKit
import SceneKit

/// Controller for the view for the main window in Flatland.
class MainController: UIViewController
{
    /// Initialize the main window and program.
    override func viewDidLoad()
    {
        super.viewDidLoad()
        ElapsedTimeValue = 0.0
        
        MainTimeLabelTop.text = ""
        MainTimeLabelBottom.text = ""
        
        //Check the previous version - if it is different, reset the instantiation count.
        let IVersion = Versioning.VerySimpleVersionString()
        let PVersion = Settings.GetString(.InstantiationVersion)
        if PVersion != IVersion
        {
            Settings.SetString(.InstantiationVersion, IVersion)
            Settings.SetInt(.InstantiationCount, 0)
        }
        let InstantiationCount = Settings.IncrementInt(.InstantiationCount)
        //If the instantiation count is over a certain number, stop showing the initial version number.
        if InstantiationCount > 10
        {
            Settings.SetBool(.ShowInitialVersion, false)
        }
        
        MainController.StartTime = CACurrentMediaTime()
        UptimeStart = CACurrentMediaTime()
        FileIO.Initialize()
        Settings.Initialize()
        Settings.UpdateForFeatureLevel()
        Settings.AddSubscriber(self)
        SoundManager.Initialize()
        CityManager.Initialize()
        
        InterfaceInitialization()
        InitializeFlatland()
        InitializeWorldClock()
        
        Settings.SetInt(.Trigger_MemoryMeasured, 0)
        MemoryDebug.MeasurePeriodically
        {
            [weak self] Value in
#if DEBUG
            self?.MemoryOverTime.append(Value)
            Settings.SetInt(.Trigger_MemoryMeasured, (self?.MemoryOverTime.count)!)
#endif
        }
        
        InitializationFromEnvironment()
        ProgramInitialization()
        AsynchronousInitialization()
        
        Internet.IsAvailable
        {
            Connected in
            self.CurrentlyConnected = Connected
        }
        
        let _ = Timer.scheduledTimer(timeInterval: 1.0,
                                     target: self,
                                     selector: #selector(HandleMemoryInUseDisplay),
                                     userInfo: nil,
                                     repeats: true)
        
        let _ = Timer.scheduledTimer(withTimeInterval: 1.0, repeats: true)
        {
            _ in
#if DEBUG
            let CurrentMemory = LowLevel.MemoryStatistics(.PhysicalFootprint)
            objc_sync_enter(self.MemSizeLock)
            self.MemSize.append(CurrentMemory!)
            objc_sync_exit(self.MemSizeLock)
#endif
        }
        
#if DEBUG
        let _ = Timer.StartRepeating(withTimerInterval: 60.0, RunFirst: true)
        {
            [weak self] _ in
            var UsedMemory = ""
            var ActualMemory: UInt64 = 0
            if let InUse = LowLevel.MemoryStatistics(.PhysicalFootprint)
            {
                ActualMemory = InUse
                UsedMemory = InUse.WithSuffix()
            }
            let DurationValue = Utility.DurationBetween(Seconds1: CACurrentMediaTime(), Seconds2: (self?.UptimeStart)!)
            var ExtraData = ""
            if !CSV.HeadersSet
            {
                CSV.SetHeaders(MemoryHeaders.allCases.map({$0.rawValue}))
            }
            if !CSV.SaveNameSet
            {
                CSV.SetSaveName("MemoryDebug.csv")
            }
            
            guard let NodeCount = self?.Main3DView.TotalNodeCount() else
            {
                return
            }
            let Delta = NodeCount - (self?.PreviousCount)!
            var DeltaString = "\(Delta)"
            if Delta > 0
            {
                DeltaString = "+" + DeltaString
            }
            ExtraData = "Nodes: \(NodeCount), ∆\(DeltaString)"
            self?.PreviousCount = NodeCount
            let StatString = "Uptime: \(DurationValue), Memory: \(UsedMemory)"
            objc_sync_enter((self?.MemSizeLock)!)
            let EntryCount = (self?.MemSize.count)!
            if EntryCount > 0
            {
                let Sum: UInt64 = (self?.MemSize)!.reduce(0, +)
                self?.MemSize.removeAll()
                let Mean = Sum / UInt64(EntryCount)
                objc_sync_exit((self?.MemSizeLock)!)
                let MeanDelta = Int64(Mean) - Int64((self?.PreviousMean)!)
                self?.PreviousMean = Mean
                Debug.Print(StatString + " {\(ExtraData), \(Mean.Delimited()), ∆\(MeanDelta.Delimited())}")
                let PrettyTime = Date().PrettyTime()
                let NewTimeValue = CACurrentMediaTime()
                self?.ElapsedTimeValue = NewTimeValue - (self?.PreviousTimeValue)!
                var FinalElapsed = self?.ElapsedTimeValue.RoundedTo(2)
                if (self?.PreviousTimeValue)! == 0.0
                {
                    FinalElapsed = 0.0
                }
                self?.PreviousTimeValue = NewTimeValue
                CSV[MemoryHeaders.Time.rawValue] = "\"\(PrettyTime)\""
                CSV[MemoryHeaders.ElapsedTime.rawValue] = "\(FinalElapsed!)"
                CSV[MemoryHeaders.UsedMemory.rawValue] = "\(UsedMemory)"
                CSV[MemoryHeaders.ActualMemory.rawValue] = "\(ActualMemory)"
                CSV[MemoryHeaders.MeanMemory.rawValue] = "\"\(Mean.WithSuffix())\""
                CSV[MemoryHeaders.Delta.rawValue] = "\"\(MeanDelta.Delimited())\""
                CSV[MemoryHeaders.NodeCount.rawValue] = "\(NodeCount)"
                CSV[MemoryHeaders.Note.rawValue] = "Periodic Memory Check"
                CSV.SaveRowInFile()
            }
        }
#endif
    }
    
#if DEBUG
    var PreviousMean: UInt64 = 0
    let MemSizeLock = NSObject()
    var MemSize = [UInt64]()
    var PreviousCount = 0
    let MemoryLock = NSObject()
    var MemoryOverTime = [Int64]()
    //var ElapsedTimeValue: Double = 0.0
    var PreviousTimeValue: Double = 0.0
#endif
    var ElapsedTimeValue: Double = 0.0
    var CurrentlyConnected: Bool = false
    
    /// Initial window position set flag.
    var InitialWindowPositionSet = false
    
    /// Called when a stenciling operation has completed.
    func DoneWithStenciling()
    {
        Debug.Print("Stenciling completed.")
    }
    
    /// Respond to the user command to take a snapshot of the current view.
    /// - Parameter sender: Not used.
    @IBAction func TakeSnapShot(_ sender: Any)
    {
        let Snapshot = Main3DView.snapshot()
        PhotoLibrary.Initialize()
        UIImageWriteToSavedPhotosAlbum(Snapshot, nil, nil, nil)
    }
    
    /// Array of previous earthquakes (used in a cache-like fashion).
    var PreviousEarthquakes = [Earthquake]()
    
    /// Respond to the user command to reset the view. Works with both 2D and 3D views.
    /// - Parameter sender: Not used.
    @IBAction func Reset3DView(_ sender: Any)
    {
        Main3DView.ResetCamera()
    }
    
    /// Set the night mask for the day.
    func SetNightMask()
    {
        let TheView = Settings.GetEnum(ForKey: .ViewType, EnumType: ViewTypes.self, Default: ViewTypes.FlatSouthCenter)
        switch TheView
        {
            case .FlatNorthCenter, .FlatSouthCenter:
                break
                
            case .Rectangular:
#if false
                Rect2DView.HideNightMask()
                if let Image = Utility.GetRectangularNightMask(ForDate: Date())
                {
                    Rect2DView.AddNightMask(Image)
                }
                else
                {
                    print("No rectangular night mask for \(Date()) found.")
                }
#endif
                break
                
            default:
                return
        }
    }
    
    /// Resond to the user command to show the flat map in north-centered mode.
    /// - Parameter sender: Not used.
    @IBAction func ViewTypeNorthCentered(_ sender: Any)
    {
        /*
         Settings.SetEnum(.FlatNorthCenter, EnumType: ViewTypes.self, ForKey: .ViewType)
         let MapValue = Settings.GetEnum(ForKey: .MapType, EnumType: MapTypes.self, Default: .Simple)
         if let MapImage = MapManager.ImageFor(MapType: MapValue, ViewType: .FlatNorthCenter)
         {
         Main2DView.SetEarthMap(MapImage)
         }
         else
         {
         Debug.Print("Error getting image for north centered: \(MapValue)")
         }
         */
    }
    
    /// Resond to the user command to show the flat map in south-centered mode.
    /// - Parameter sender: Not used.
    @IBAction func ViewTypeSouthCentered(_ sender: Any)
    {
        /*
         Settings.SetEnum(.FlatSouthCenter, EnumType: ViewTypes.self, ForKey: .ViewType)
         let MapValue = Settings.GetEnum(ForKey: .MapType, EnumType: MapTypes.self, Default: .Simple)
         if let MapImage = MapManager.ImageFor(MapType: MapValue, ViewType: .FlatSouthCenter)
         {
         Main2DView.SetEarthMap(MapImage)
         }
         else
         {
         Debug.Print("Error getting image for south centered: \(MapValue)")
         }
         */
    }
    
    /// Resond to the user command to show the flat map in rectangular mode.
    /// - Parameter sender: Not used.
    @IBAction func ViewTypeRectangular(_ sender: Any)
    {
        /*
         Settings.SetEnum(.Rectangular, EnumType: ViewTypes.self, ForKey: .ViewType)
         let MapValue = Settings.GetEnum(ForKey: .MapType, EnumType: MapTypes.self, Default: .Simple)
         if let MapImage = MapManager.ImageFor(MapType: MapValue, ViewType: .Rectangular)
         {
         Rect2DView.SetEarthMap(MapImage)
         }
         else
         {
         Debug.Print("Error getting image for north centered: \(MapValue)")
         }
         */
    }
    
    let EQMessageID = UUID()
    
    public static var StartTime: Double = 0.0
    public var MainApp: AppDelegate!
    
    /// Update timer.
    var UpdateTimer: Timer? = nil
    /// Program started flag.
    var Started = false
    
    var LastQuakeDownloadTime: Date? = nil
    
    /// Holds the most recent stenciled image.
    var StenciledImage: UIImage? = nil
    
#if DEBUG
    /// Time stamp for when the program started.
    var StartDebugCount: Double = 0.0
    /// Number of seconds running in the current instantiation.
    var UptimeSeconds: Int = 0
#endif
    /// Previous second count.
    var OldSeconds: Double = 0.0
    
    // MARK: - Extension variables
    
    /// ID used for settings subscriptions.
    var ClassID = UUID()
    /// Earthquake source (asynchronous data from the USGS).
    var Earthquakes: USGS? = nil
    /// Primary map list.
    var PrimaryMapList: ActualMapList? = nil
    /// The latest earthquakes from the USGS.
    var LatestEarthquakes = [Earthquake]()
    /// The set of cached quakes from startup.
    var CachedQuakes = [Earthquake]()
    
    // MARK: - Database handles/variables
    
    /// Location of the mappable database.
    var MappableURL: URL? = nil
    /// Flag that indicates whether the mappable database was initialized or not.
    static var MappableInitialized = false
    /// Handle to the mappable database.
    static var MappableHandle: OpaquePointer? = nil
    /// Array of World Heritage Sites.
    var WorldHeritageSites: [WorldHeritageSite]? = nil
    /// Location of the POI database.
    var POIURL: URL? = nil
    /// Flag that indicates whether the POI database was initialized or not.
    static var POIInitialized = false
    /// Handle to the POI database.
    static var POIHandle: OpaquePointer? = nil
    /// User POIs from the POI database.
    static var UserPOIs = [POI2]()
    /// User homes from the POI database.
    static var UserHomes = [POI2]()
    /// Additional cities defined by the user.
    static var OtherCities = [City2]()
    /// Built-in POIs.
    static var BuiltInPOIs = [POI2]()
    
    // MARK: - World clock variables.
    var WorldClockTimer: Timer? = nil
    var WorldClockTimeMultiplier: Double = 1.0
    var CurrentWorldTime: Double = 0.0
    var WorldClockStartTime: Date? = nil
    
    var HourSoundTriggered: Bool = false
    
    // MARK: - Storyboard outlets
    //@IBOutlet var PrimaryView: ParentView!
    //@IBOutlet weak var Main2DView: FlatView!
    //@IBOutlet weak var Rect2DView: RectangleView!
    @IBOutlet var Main3DView: GlobeView!
    @IBOutlet weak var MainTimeLabelTop: UILabel!
    @IBOutlet weak var MainTimeLabelBottom: UILabel!
    
    var ChangeDelta: Double = 0.0
    var PreviousMemoryUsed: UInt64? = nil
    /// Start time (in seconds) of the current instance.
    var UptimeStart: Double = 0.0
    var PreviousHourValue: String = ""
}
