//
//  +Menus.swift
//  Flatland
//
//  Created by Stuart Rankin on 12/26/20.
//  Copyright © 2020 Stuart Rankin. All rights reserved.
//

import Foundation
import UIKit
import SceneKit

extension GlobeView
{
    #if false
    // MARK: - Menu handling
    
    /// Return a menu to display provided the passed event is a right mouse down event.
    /// - Note: Depending on whether the mouse is over the Earth or not, the menu will look different. If the
    ///         mouse is over the Earth, options for determining what is nearby, and setting and editing
    ///         POIs will appear. Otherwise, they will not appear.
    /// - Parameter for: The event that determines if a menu is returned.
    /// - Returns: An `NSMenu` if `event` is `.rightMouseDown`, nil if not.
    override func menu(for event: NSEvent) -> NSMenu?
    {
        var MouseOverEarth = true
        if event.type == .rightMouseDown
        {
            if CurrentMouseLocation != nil
            {
                MouseOverEarth = true
            }
            else
            {
                MouseOverEarth = false
            }
            let Menu = NSMenu(title: "Actions")
            if MouseOverEarth
            {
                if InRegionCreationMode || InPointCreationMode
                {
                    Menu.items =
                        [
                            MakeWhatsHereMenu(),
                            MakeClearSearchMenu(),
                            MakeOtherSearchMenu(),
                            NSMenuItem.separator(),
                            MakeMapMenu(),
                            MakeTimeMenu(),
                            NSMenuItem.separator(),
                            MakeResetMenu(),
                            MakeLockMenu(),
                            NSMenuItem.separator(),
                            MakePOIMenu(),
                            NSMenuItem.separator(),
                            MakeFollowMenu()
                        ]
                }
                else
                {
                    Menu.items =
                        [
                            MakeWhatsHereMenu(),
                            MakeClearSearchMenu(),
                            MakeOtherSearchMenu(),
                            NSMenuItem.separator(),
                            MakeMapMenu(),
                            MakeTimeMenu(),
                            NSMenuItem.separator(),
                            MakeResetMenu(),
                            MakeLockMenu(),
                            NSMenuItem.separator(),
                            MakePOIMenu(),
                            MakeEarthquakeMenu(),
                            NSMenuItem.separator(),
                            MakeFollowMenu()
                        ]
                }
            }
            else
            {
                Menu.items =
                    [
                        MakeMapMenu(),
                        MakeTimeMenu(),
                        NSMenuItem.separator(),
                        MakeResetMenu(),
                        MakeLockMenu(),
                        NSMenuItem.separator(),
                        MakeEarthquakeMenu(),
                        NSMenuItem.separator(),
                        MakeFollowMenu()
                    ]
            }
            #if DEBUG
            Menu.items.append(NSMenuItem.separator())
            Menu.items.append(MakeDebugMenu())
            #endif
            return Menu
        }
        return nil
    }
    
    func SmallIconImage(_ Name: String) -> UIImage
    {
        var IconImage = UIImage(named: Name)
        IconImage = Utility.ResizeImage(Image: IconImage!, Longest: 24.0)
        return IconImage!
    }
    
    @objc func Context_AddPOI(_ sender: Any)
    {
        if POIEditorOpen
        {
            return
        }
        POIEditorOpen = true
        let Storyboard = NSStoryboard(name: "POIEntryUI", bundle: nil)
        if let WindowController = Storyboard.instantiateController(withIdentifier: "POIEntryWindow") as? POIEntryWindow
        {
            let Window = WindowController.window
            if let Controller = Window?.contentViewController as? POIEntryController
            {
                InPointCreationMode = true
                Settings.SetBool(.WorldIsLocked, true)
                Controller.ParentDelegate = self
                Controller.MainDelegate = MainDelegate
                MouseClickReceiver = Controller
                Controller.CreateNewPoint(ClickPoint: GeoPoint(CurrentMouseLatitude, CurrentMouseLongitude))
                WindowController.showWindow(nil)
            }
        }
        else
        {
            POIEditorOpen = false
        }
    }
    
    @objc func Context_EditPOI(_ sender: Any)
    {
        print("Edit POI here!")
    }
    
    @objc func RunAddEditHomeDialog(_ sender: Any)
    {
        print("Add/edit home")
    }
    
    @objc func SetHomeAtLocation(_ sender: Any)
    {
        if let MouseLocation = CurrentMouseLocation
        {
            let (Latitude, Longitude) = MakeWhereFromTexture(MouseLocation)
            print("Add/move home to \(Latitude),\(Longitude)")
        }
    }
    
    @objc func Context_AddRadialQuakeRegion(_ sender: Any)
    {
        if RegionEditorOpen
        {
            return
        }
        RegionEditorOpen = true
        let Storyboard = NSStoryboard(name: "RegionEntryUI", bundle: nil)
        if let WindowController = Storyboard.instantiateController(withIdentifier: "RadialRegionEntryWindow") as? RadialRegionEntryWindow
        {
            let Window = WindowController.window
            if let Controller = Window?.contentViewController as? RadialRegionEntryController
            {
                InRegionCreationMode = true
                OldLockState = Settings.GetBool(.WorldIsLocked)
                Settings.SetBool(.WorldIsLocked, true)
                Controller.ParentDelegate = self
                Controller.MainDelegate = MainDelegate
                MouseClickReceiver = Controller
                WindowController.showWindow(nil)
            }
        }
    }
    
    @objc func Context_AddQuakeRegion(_ sender: Any)
    {
        if RegionEditorOpen
        {
            return
        }
        RegionEditorOpen = true
        let Storyboard = NSStoryboard(name: "RegionEntryUI", bundle: nil)
        if let WindowController = Storyboard.instantiateController(withIdentifier: "RegionEntryWindow") as? RegionEntryWindow
        {
            let Window = WindowController.window
            if let Controller = Window?.contentViewController as? RegionEntryController
            {
                InRegionCreationMode = true
                OldLockState = Settings.GetBool(.WorldIsLocked)
                Settings.SetBool(.WorldIsLocked, true)
                Controller.ParentDelegate = self
                Controller.MainDelegate = MainDelegate
                MouseClickReceiver = Controller
                WindowController.showWindow(nil)
            }
        }
    }
    
    @objc func Context_EditQuakeRegion(_ sender: Any)
    {
        #if false
        let Storyboard = NSStoryboard(name: "SubPanels", bundle: nil)
        if let WindowController = Storyboard.instantiateController(withIdentifier: "EarthquakeRegionWindow2") as? EarthquakeRegionWindow2
        {
            let Window = WindowController.window
            if let Controller = Window?.contentViewController as? EarthquakeRegionController2
            {
                Controller.IsModal(false)
                WindowController.showWindow(nil)
            }
        }
        #endif
    }
    
    @objc func Context_MakeCircularRegion(_ sender: Any)
    {
        
    }
    
    @objc func Context_MakeRectangularRegion(_ sender: Any)
    {
        
    }
    
    /// Run the what's here dialog.
    /// - Parameter sender: Not used.
    @objc func HandleWhatsHereMenu(_ sender: Any)
    {
        if let MouseLocation = CurrentMouseLocation
        {
            let Storyboard = NSStoryboard(name: "Popovers", bundle: nil)
            if let WindowController = Storyboard.instantiateController(withIdentifier: "WhatsHereWindow") as? WhatsHereWindow
            {
                let Window = WindowController.window
                let Controller = Window?.contentViewController as? WhatsHereViewer
                WindowController.showWindow(nil)
                let (Latitude, Longitude) = MakeWhereFromTexture(MouseLocation)
                Controller?.SetLocation(Latitude, Longitude, Main: MainDelegate)
                ShowSearchForLocation(Latitude, Longitude)
            }
        }
    }
    
    /// Remove all icons indicating the position of previous searches.
    /// - Parameter sender: Not used.
    @objc func ClearPastSearches(_ sender: Any)
    {
        for Index in 0 ..< SearchedNodeIcons.count
        {
            let Node = SearchedNodeIcons[Index]
            let FadeAway = SCNAction.fadeOut(duration: 1.0)
            Node.runAction(FadeAway)
            {
                Node.removeFromParentNode()
                Node.geometry = nil
                if Index == self.SearchedNodeIcons.count - 1
                {
                    self.SearchedNodeIcons.removeAll()
                }
            }
        }
    }
    
    //https://metalbyexample.com/modelio-materials/
    func ShowSearchForLocation(_ Latitude: Double, _ Longitude: Double)
    {
        let Radius = Double(GlobeRadius.Primary.rawValue + GlobeRadius.SearchIconRadialOffset.rawValue)
        let (X, Y, Z) = Geometry.ToECEF(Latitude, Longitude, Radius: Radius)
        let QMark = SCNText(string: "?", extrusionDepth: 4.0)
        QMark.font = UIFont.boldSystemFont(ofSize: 20.0)
        QMark.flatness = 0.1
        let QM = SCNNode2(geometry: QMark)
        QM.name = GlobeNodeNames.SearchedLocationNode.rawValue
        QM.scale = SCNVector3(NodeScales3D.SearchLocationScale.rawValue)
        QM.SetLocation(Latitude, Longitude)
        QM.geometry?.firstMaterial?.diffuse.contents = UIColor.Gold
        QM.geometry?.firstMaterial?.specular.contents = UIColor.yellow
        QM.position = SCNVector3(X, Y, Z)
        QM.geometry?.firstMaterial?.lightingModel = .physicallyBased
        QM.categoryBitMask = LightMasks3D.Sun.rawValue | LightMasks3D.Moon.rawValue
        
        let XRotation = (90.0 - Latitude).Radians
        let YRotation = Longitude.Radians
        let ZRotation = 0.0.Radians
        QM.eulerAngles = SCNVector3(XRotation, YRotation, ZRotation)
        
        let Day: EventAttributes =
            {
                let D = EventAttributes()
                D.ForEvent = .SwitchToDay
                D.Diffuse = UIColor.Gold
                D.Specular = UIColor.yellow
                D.Emission = nil
                return D
            }()
        let Night: EventAttributes =
            {
                let N = EventAttributes()
                N.ForEvent = .SwitchToDay
                N.Diffuse = UIColor.Gold
                N.Specular = UIColor.white
                N.Emission = UIColor.Gold
                return N
            }()
        QM.CanSwitchState = true
        QM.AddEventAttributes(Event: .SwitchToDay, Attributes: Day)
        QM.AddEventAttributes(Event: .SwitchToNight, Attributes: Night)
        QM.IsInDaylight = Solar.IsInDaylight(Latitude, Longitude) ?? true
        SearchedNodeIcons.append(QM)
        EarthNode?.addChildNode(QM)
    }
    
    func MakeDebugMenu() -> NSMenuItem
    {
        #if DEBUG
        DebugMenu = NSMenuItem()
        DebugMenu?.title = "Debug"
        DebugMenu?.submenu = NSMenu(title: "Debug")
        RotateTo0Menu = NSMenuItem(title: "Rotate to 0°", action: #selector(TestRotation), keyEquivalent: "")
        RotateTo0Menu?.target = self
        RotateTo90Menu = NSMenuItem(title: "Rotate to 90°", action: #selector(TestRotation), keyEquivalent: "")
        RotateTo90Menu?.target = self
        RotateTo180Menu = NSMenuItem(title: "Rotate to 180°", action: #selector(TestRotation), keyEquivalent: "")
        RotateTo180Menu?.target = self
        RotateTo270Menu = NSMenuItem(title: "Rotate to 270°", action: #selector(TestRotation), keyEquivalent: "")
        RotateTo270Menu?.target = self
        CoupleTimerMenu = NSMenuItem(title: "Couple Earth to Timer", action: #selector(TestRotation), keyEquivalent: "")
        CoupleTimerMenu?.target = self
        DebugMenu?.submenu?.items.append(RotateTo0Menu!)
        DebugMenu?.submenu?.items.append(RotateTo90Menu!)
        DebugMenu?.submenu?.items.append(RotateTo180Menu!)
        DebugMenu?.submenu?.items.append(RotateTo270Menu!)
        DebugMenu?.submenu?.items.append(CoupleTimerMenu!)
        DebugMenu?.submenu?.items.append(NSMenuItem.separator())
        DebugMenu?.submenu?.items.append(MakeCameraDebugMenu())
        return DebugMenu!
        #else
        return NSMenuItem()
        #endif
    }
    
    func MakeCameraDebugMenu() -> NSMenuItem
    {
        #if DEBUG
        CameraDebugMenu = NSMenuItem()
        CameraDebugMenu?.title = "Camera Debug"
        CameraDebugMenu?.submenu = NSMenu(title: "Camera Debug")
        MoveCameraTestMenu = NSMenuItem(title: "Move camera", action: #selector(DebugTestCamera), keyEquivalent: "")
        MoveCameraTestMenu?.target = self
        SpinCameraTestMenu = NSMenuItem(title: "Spin camera", action: #selector(DebugTestCamera), keyEquivalent: "")
        SpinCameraTestMenu?.target = self
        CameraDebugMenu?.submenu?.items.append(MoveCameraTestMenu!)
        CameraDebugMenu?.submenu?.items.append(SpinCameraTestMenu!)
        
        return CameraDebugMenu!
        #else
        return NSMenuItem()
        #endif
    }
    
    @objc func DebugTestCamera(_ sender: Any)
    {
        #if DEBUG
        if let Menu = sender as? NSMenuItem
        {
            switch Menu
            {
                case MoveCameraTestMenu:
                    RotateCameraTo(Latitude: 0.0, Longitude: 180.0)
                    
                case SpinCameraTestMenu:
                    SpinCamera()
                    
                default:
                    return
            }
        }
        #endif
    }
    
    @objc func TestRotation(_ sender: Any)
    {
        #if DEBUG
        if let Menu = sender as? NSMenuItem
        {
            switch Menu
            {
                case RotateTo0Menu:
                    RotateEarthTo(Latitude: 0.0, Longitude: 0.0)
                    
                case RotateTo90Menu:
                    RotateEarthTo(Latitude: 0.0, Longitude: 90.0)
                    
                case RotateTo180Menu:
                    RotateEarthTo(Latitude: 0.0, Longitude: 180.0)
                    
                case RotateTo270Menu:
                    RotateEarthTo(Latitude: 0.0, Longitude: -90.0)
                    
                case CoupleTimerMenu:
                    ResetEarthRotation()
                    
                case MoveCameraTestMenu:
                    RotateCameraTo(Latitude: 0.0, Longitude: 180.0)
                    
                default:
                    return
            }
        }
        #endif
    }
    
    func MakeMapMenu() -> NSMenuItem
    {
        MapTypeMenu = NSMenuItem()
        MapTypeMenu?.title = "Map Type"
        MapTypeMenu?.submenu = NSMenu(title: "Map Types")
        
        let CurrentMap = Settings.GetEnum(ForKey: .ViewType, EnumType: ViewTypes.self, Default: .Globe3D)
        
        NCenter = NSMenuItem(title: "North-Centered Flat", action: #selector(Context_SetMapType), keyEquivalent: "")
        NCenter?.image = SmallIconImage("NorthCenterIcon")
        NCenter?.target = self
        NCenter?.state = CurrentMap == .FlatNorthCenter ? .on : .off
        SCenter = NSMenuItem(title: "South-Centered Flat", action: #selector(Context_SetMapType), keyEquivalent: "")
        SCenter?.image = SmallIconImage("SouthCenterIcon")
        SCenter?.target = self
        SCenter?.state = CurrentMap == .FlatSouthCenter ? .on : .off
        RectMap = NSMenuItem(title: "Rectangular Flat", action: #selector(Context_SetMapType), keyEquivalent: "")
        RectMap?.image = SmallIconImage("RectangleIcon")
        RectMap?.target = self
        RectMap?.state = CurrentMap == .Rectangular ? .on : .off
        GlobeMapMenu = NSMenuItem(title: "Globe", action: #selector(Context_SetMapType), keyEquivalent: "")
        GlobeMapMenu?.image = SmallIconImage("GlobeIcon")
        GlobeMapMenu?.target = self
        GlobeMapMenu?.state = CurrentMap == .Globe3D ? .on : .off
        MapTypeMenu?.submenu?.items.append(NCenter!)
        MapTypeMenu?.submenu?.items.append(SCenter!)
        MapTypeMenu?.submenu?.items.append(RectMap!)
        MapTypeMenu?.submenu?.items.append(GlobeMapMenu!)
        Features.FeatureEnabled(.CubicEarth)
        {
            IsEnabled in
            if IsEnabled
            {
                self.CubicMapMenu = NSMenuItem(title: "Cubic", action: #selector(self.Context_SetMapType), keyEquivalent: "")
                self.CubicMapMenu?.image = self.SmallIconImage("CubeIcon")
                self.CubicMapMenu?.target = self
                self.CubicMapMenu?.state = CurrentMap == .CubicWorld ? .on : .off
                self.MapTypeMenu?.submenu?.items.append(self.CubicMapMenu!)
            }
        }
        return MapTypeMenu!
    }
    
    @objc func Context_SetMapType(_ sender: Any)
    {
        if let MenuItem = sender as? NSMenuItem
        {
            switch MenuItem
            {
                case NCenter:
                    Settings.SetEnum(.FlatNorthCenter, EnumType: ViewTypes.self, ForKey: .ViewType)
                    let ActualMap = Settings.GetEnum(ForKey: .MapType, EnumType: MapTypes.self, Default: .Simple)
                    Settings.SetEnum(ActualMap, EnumType: MapTypes.self, ForKey: .MapType)
                    
                case SCenter:
                    Settings.SetEnum(.FlatSouthCenter, EnumType: ViewTypes.self, ForKey: .ViewType)
                    let ActualMap = Settings.GetEnum(ForKey: .MapType, EnumType: MapTypes.self, Default: .Simple)
                    Settings.SetEnum(ActualMap, EnumType: MapTypes.self, ForKey: .MapType)
                    
                case RectMap:
                    Settings.SetEnum(.Rectangular, EnumType: ViewTypes.self, ForKey: .ViewType)
                    let ActualMap = Settings.GetEnum(ForKey: .MapType, EnumType: MapTypes.self, Default: .Simple)
                    Settings.SetEnum(ActualMap, EnumType: MapTypes.self, ForKey: .MapType)
                    
                case CubicMapMenu:
                    if Features.FeatureEnabled(.CubicEarth)
                    {
                    Settings.SetEnum(.CubicWorld, EnumType: ViewTypes.self, ForKey: .ViewType)
                    }
                    
                case GlobeMapMenu:
                    Settings.SetEnum(.Globe3D, EnumType: ViewTypes.self, ForKey: .ViewType)
                    
                default:
                    return
            }
        }
    }
    
    func MakeTimeMenu() -> NSMenuItem
    {
        TimeMenu = NSMenuItem()
        TimeMenu?.title = "Hours"
        TimeMenu?.submenu = NSMenu(title: "Hours")
        
        let HourType = Settings.GetEnum(ForKey: .HourType, EnumType: HourTypes.self, Default: HourTypes.Solar)
        
        NoTimeMenu = NSMenuItem(title: "No Hours Shown", action: #selector(Context_SetHourType), keyEquivalent: "")
        NoTimeMenu?.image = SmallIconImage("CircleIcon")
        NoTimeMenu?.target = self
        NoTimeMenu?.state = HourType == .None ? .on : .off
        SolarTimeMenu = NSMenuItem(title: "Solar Hours", action: #selector(Context_SetHourType), keyEquivalent: "")
        SolarTimeMenu?.image = SmallIconImage("ClockIcon")
        SolarTimeMenu?.target = self
        SolarTimeMenu?.state = HourType == .Solar ? .on : .off
        DeltaTimeMenu = NSMenuItem(title: "Relative to Noon", action: #selector(Context_SetHourType), keyEquivalent: "")
        DeltaTimeMenu?.image = SmallIconImage("DeltaIcon")
        DeltaTimeMenu?.target = self
        DeltaTimeMenu?.state = HourType == .RelativeToNoon ? .on : .off
        PinnedTimeMenu = NSMenuItem(title: "Relative to Location", action: #selector(Context_SetHourType), keyEquivalent: "")
        PinnedTimeMenu?.image = SmallIconImage("PinIcon")
        PinnedTimeMenu?.target = self
        PinnedTimeMenu?.state = HourType == .RelativeToLocation ? .on : .off
        WallClockTimeMenu = NSMenuItem(title: "Wall Clock", action: #selector(Context_SetHourType), keyEquivalent: "")
        WallClockTimeMenu?.image = SmallIconImage("WallClockIcon")
        WallClockTimeMenu?.target = self
        WallClockTimeMenu?.state = HourType == .WallClock ? .on : .off
        
        TimeMenu?.submenu?.items.append(NoTimeMenu!)
        TimeMenu?.submenu?.items.append(SolarTimeMenu!)
        TimeMenu?.submenu?.items.append(DeltaTimeMenu!)
        TimeMenu?.submenu?.items.append(PinnedTimeMenu!)
        TimeMenu?.submenu?.items.append(WallClockTimeMenu!)
        return TimeMenu!
    }
    
    @objc func Context_SetHourType(_ sender: Any)
    {
        if let MenuItem = sender as? NSMenuItem
        {
            switch MenuItem
            {
                case NoTimeMenu:
                    Settings.SetEnum(.None, EnumType: HourTypes.self, ForKey: .HourType)
                    
                case SolarTimeMenu:
                    Settings.SetEnum(.Solar, EnumType: HourTypes.self, ForKey: .HourType)
                    
                case DeltaTimeMenu:
                    Settings.SetEnum(.RelativeToNoon, EnumType: HourTypes.self, ForKey: .HourType)
                    
                case PinnedTimeMenu:
                    Settings.SetEnum(.RelativeToLocation, EnumType: HourTypes.self, ForKey: .HourType)
                    
                case WallClockTimeMenu:
                    Settings.SetEnum(.WallClock, EnumType: HourTypes.self, ForKey: .HourType)
                    
                default:
                    return
            }
        }
    }
    
    func MakeWhatsHereMenu() -> NSMenuItem
    {
        UnderMouseMenu = NSMenuItem(title: "What's Here?", action: #selector(HandleWhatsHereMenu), keyEquivalent: "")
        UnderMouseMenu?.target = self
        return UnderMouseMenu!
    }
    
    func MakeOtherSearchMenu() -> NSMenuItem
    {
        let OtherSearch = NSMenuItem()
        OtherSearch.title = "More Searches"
        OtherSearch.submenu = NSMenu(title: "More Searches")
        let Antipode = NSMenuItem(title: "Antipode", action: #selector(MarkAntipode), keyEquivalent: "")
        Antipode.target = self
        let ClearAntipodesMenu = NSMenuItem(title: "Clear Antipodes", action: #selector(ClearAntipodes), keyEquivalent: "")
        ClearAntipodesMenu.target = self
        let MeasureDistanceMenu = NSMenuItem(title: "Measure Distance", action: #selector(MeasureDistance), keyEquivalent: "")
        MeasureDistanceMenu.target = self
        OtherSearch.submenu?.items.append(Antipode)
        OtherSearch.submenu?.items.append(ClearAntipodesMenu)
        OtherSearch.submenu?.items.append(NSMenuItem.separator())
        OtherSearch.submenu?.items.append(MeasureDistanceMenu)
        return OtherSearch
    }
    
    @objc func MarkAntipode(_ sender: Any)
    {
        
    }
    
    @objc func ClearAntipodes(_ sender: Any)
    {
        
    }
    
    @objc func MeasureDistance(_ sender: Any)
    {
        
    }
    
    func MakeClearSearchMenu() -> NSMenuItem
    {
        ClearSearchMenu = NSMenuItem(title: "Clear searches", action: #selector(ClearPastSearches), keyEquivalent: "")
        return ClearSearchMenu!
    }
    
    func MakeResetMenu() -> NSMenuItem
    {
        ResetMenu = NSMenuItem(title: "Reset View", action: #selector(HandleResetViewMenu), keyEquivalent: "")
        return ResetMenu!
    }
    
    /// Reset the camera.
    /// - Parameter sender: Not used.
    @objc func HandleResetViewMenu(_ sender: Any)
    {
        ResetCamera()
    }
    
    func MakePOIMenu() -> NSMenuItem
    {
        POIMenu = NSMenuItem()
        POIMenu?.title = "Points of Interest"
        POIMenu?.submenu = NSMenu(title: "Points of Interest")
        let AddPOI = NSMenuItem(title: "Add POI", action: #selector(Context_AddPOI), keyEquivalent: "")
        AddPOI.target = self
        let EditPOI = NSMenuItem(title: "Edit POI", action: #selector(Context_EditPOI), keyEquivalent: "")
        EditPOI.target = self
        AddEditHomeMenu = NSMenuItem(title: "Add/Edit Home", action: #selector(RunAddEditHomeDialog), keyEquivalent: "")
        AddEditHomeMenu?.target = self
        POIMenu?.submenu?.items.append(AddPOI)
        POIMenu?.submenu?.items.append(EditPOI)
        POIMenu?.submenu?.items.append(NSMenuItem.separator())
        POIMenu?.submenu?.items.append(MakeHomeMenu())
        return POIMenu!
    }
    
    func MakeHomeMenu() -> NSMenuItem
    {
        AddEditHomeMenu = NSMenuItem()
        AddEditHomeMenu?.title = "Home"
        AddEditHomeMenu?.submenu = NSMenu(title: "Home")
        RunAddEditDialogMenu = NSMenuItem(title: "Add/Edit Home Location", action: #selector(RunAddEditHomeDialog),
                                          keyEquivalent: "")
        RunAddEditDialogMenu?.target = self
        SetHomeAtMouseMenu = NSMenuItem(title: "Make Home at Mouse", action: #selector(SetHomeAtLocation),
                                        keyEquivalent: "")
        SetHomeAtMouseMenu?.target = self
        AddEditHomeMenu?.submenu?.items.append(RunAddEditDialogMenu!)
        AddEditHomeMenu?.submenu?.items.append(SetHomeAtMouseMenu!)
        return AddEditHomeMenu!
    }
    
    func MakeEarthquakeMenu() -> NSMenuItem
    {
        QuakeMenu = NSMenuItem()
        QuakeMenu?.title = "Earthquakes"
        QuakeMenu?.submenu = NSMenu(title: "Earthquakes")
        let AddRegion = NSMenuItem(title: "Add Earthquake Region", action: #selector(Context_AddQuakeRegion), keyEquivalent: "")
        AddRegion.target = self
        let AddRadial = NSMenuItem(title: "Add Circular Region", action: #selector(Context_AddRadialQuakeRegion), keyEquivalent: "")
        AddRadial.target = self
        QuakeMenu?.submenu?.items.append(AddRegion)
        #if false
        QuakeMenu?.submenu?.items.append(AddRadial)
        #endif
        return QuakeMenu!
    }
    
    func MakeLockMenu() -> NSMenuItem
    {
        LockMenu = NSMenuItem(title: "Lock Camera", action: #selector(HandleLockMenu), keyEquivalent: "")
        LockMenu?.target = self
        let IsLocked = Settings.GetBool(.WorldIsLocked)
        LockMenu?.state = IsLocked ? .on : .off
        return LockMenu!
    }
    
    /// Toggle the world locked flag. Settings changed handlers will detect the change and act accordingly.
    /// - Parameter sender: Not used.
    @objc func HandleLockMenu(_ sender: Any)
    {
        Settings.InvertBool(.WorldIsLocked)
    }
    
    func MakeFollowMenu() -> NSMenuItem
    {
        FollowMenu = NSMenuItem()
        FollowMenu?.title = "Follow Mode"
        FollowMenu?.submenu = NSMenu(title: "Follow")
        let FollowMouse = NSMenuItem(title: "Follow Mouse", action: #selector(ContextToggleFollowMouse), keyEquivalent: "")
        FollowMouse.target = self
        FollowMouse.state = Settings.GetBool(.FollowMouse) ? .on : .off
        FollowMenu?.submenu?.items.append(FollowMouse)
        return FollowMenu!
    }
    #endif
}

