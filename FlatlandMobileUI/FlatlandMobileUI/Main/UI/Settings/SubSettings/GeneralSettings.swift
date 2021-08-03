//
//  GeneralSettings.swift
//  GeneralSettings
//
//  Created by Stuart Rankin on 7/31/21.
//

import Foundation
import UIKit

class GeneralSettings: UITableViewController
{
    override func viewDidLoad()
    {
        super.viewDidLoad()
        ShowSecondsSwitch.isOn = Settings.GetBool(.TimeLabelSeconds)
        ShowVersionSwitch.isOn = Settings.GetBool(.ShowInitialVersion)
        let InputType = Settings.GetEnum(ForKey: .InputUnit, EnumType: InputUnits.self, Default: .Kilometers)
        switch InputType
        {
            case .Kilometers:
                InputSegment.selectedSegmentIndex = 0
                
            case .Miles:
                InputSegment.selectedSegmentIndex = 1
        }

        let HourSize = Settings.GetEnum(ForKey: .HourScale, EnumType: MapNodeScales.self, Default: .Normal)
        switch HourSize
        {
            case .Small:
                HourScaleSegment.selectedSegmentIndex =  0
                
            case .Normal:
                HourScaleSegment.selectedSegmentIndex =  1
                
            case .Large:
                HourScaleSegment.selectedSegmentIndex =  2
        }
        
        let TimeLabelType = Settings.GetEnum(ForKey: .TimeLabel, EnumType: TimeLabels.self, Default: .UTC)
        switch TimeLabelType
        {
            case .None:
                ClockFormatSegment.selectedSegmentIndex = 0
                
            case .UTC:
                ClockFormatSegment.selectedSegmentIndex = 1
                
            case .Local:
                ClockFormatSegment.selectedSegmentIndex = 2
        }
        
        let HoursType = Settings.GetEnum(ForKey: .HourType, EnumType: HourTypes.self, Default: .WallClock)
        switch HoursType
        {
            case .None:
                HourTypeSegment.selectedSegmentIndex = 0
                
            case .Solar:
                HourTypeSegment.selectedSegmentIndex = 1
                
            case .RelativeToNoon:
                HourTypeSegment.selectedSegmentIndex = 2
                
            case .RelativeToLocation:
                HourTypeSegment.selectedSegmentIndex = 3
                
            case .WallClock:
                HourTypeSegment.selectedSegmentIndex = 4
        }
        
        let MapsType = Settings.GetEnum(ForKey: .ViewType, EnumType: ViewTypes.self, Default: .Globe3D)
        switch MapsType
        {
            case .Rectangular:
                MapTypeSegment.selectedSegmentIndex = 0
                
            case .FlatNorthCenter:
                MapTypeSegment.selectedSegmentIndex = 1
                
            case .FlatSouthCenter:
                MapTypeSegment.selectedSegmentIndex = 2
                
            case .Globe3D:
                MapTypeSegment.selectedSegmentIndex = 3
                
            case .CubicWorld:
                MapTypeSegment.selectedSegmentIndex = 4
        }
    }
    
    @IBAction func InputUnitsChangedHandler(_ sender: Any)
    {
        if let Segment = sender as? UISegmentedControl
        {
            var NewUnit: InputUnits = .Kilometers
            switch Segment.selectedSegmentIndex
            {
                case 0:
                    NewUnit = .Kilometers
                    
                case 1:
                    NewUnit = .Miles
                    
                default:
                    return
            }
            Settings.SetEnum(NewUnit, EnumType: InputUnits.self, ForKey: .InputUnit)
        }
    }
    
    @IBAction func ShowVersionChangedHandler(_ sender: Any)
    {
        if let Switch = sender as? UISwitch
        {
            Settings.SetBool(.ShowInitialVersion, Switch.isOn)
        }
    }
    
    @IBAction func ShowSecondsChangedHandler(_ sender: Any)
    {
        if let Switch = sender as? UISwitch
        {
            Settings.SetBool(.TimeLabelSeconds, Switch.isOn)
        }
    }
    
    @IBAction func ClockFormatChangedHandler(_ sender: Any)
    {
        if let Segment = sender as? UISegmentedControl
        {
            let Index = Segment.selectedSegmentIndex
            switch Index
            {
                case 0:
                    Settings.SetEnum(.None, EnumType: TimeLabels.self, ForKey: .TimeLabel)
                    
                case 1:
                    Settings.SetEnum(.UTC, EnumType: TimeLabels.self, ForKey: .TimeLabel)
                    
                case 2:
                    Settings.SetEnum(.Local, EnumType: TimeLabels.self, ForKey: .TimeLabel)
                    
                default:
                    return
            }
        }
    }
    
    @IBAction func MapTypeChangedHandler(_ sender: Any)
    {
        if let Segment = sender as? UISegmentedControl
        {
            let Index = Segment.selectedSegmentIndex
            switch Index
            {
                case 0:
                    Settings.SetEnum(.Rectangular, EnumType: ViewTypes.self, ForKey: .ViewType)
                    
                case 1:
                    Settings.SetEnum(.FlatNorthCenter, EnumType: ViewTypes.self, ForKey: .ViewType)
                    
                case 2:
                    Settings.SetEnum(.FlatSouthCenter, EnumType: ViewTypes.self, ForKey: .ViewType)
                    
                case 3:
                    Settings.SetEnum(.Globe3D, EnumType: ViewTypes.self, ForKey: .ViewType)
                    
                case 4:
                    Settings.SetEnum(.CubicWorld, EnumType: ViewTypes.self, ForKey: .ViewType)
                    
                default:
                    return
            }
        }
    }
    
    @IBAction func HourTypeChangedHandler(_ sender: Any)
    {
        if let Segment = sender as? UISegmentedControl
        {
            let Index = Segment.selectedSegmentIndex
            switch Index
            {
                case 0:
                    Settings.SetEnum(.None, EnumType: HourTypes.self, ForKey: .HourType)
                    
                case 1:
                    Settings.SetEnum(.Solar, EnumType: HourTypes.self, ForKey: .HourType)
                    
                case 2:
                    Settings.SetEnum(.RelativeToNoon, EnumType: HourTypes.self, ForKey: .HourType)
                    
                case 3:
                    Settings.SetEnum(.RelativeToLocation, EnumType: HourTypes.self, ForKey: .HourType)
                    
                case 4:
                    Settings.SetEnum(.WallClock, EnumType: HourTypes.self, ForKey: .HourType)
                    
                default:
                    return
            }
        }
    }
    
    @IBAction func HourScaleChangedHandler(_ sender: Any)
    {
        if let Segment = sender as? UISegmentedControl
        {
            let Index = Segment.selectedSegmentIndex
            switch Index
            {
                case 0:
                    Settings.SetEnum(.Small, EnumType: MapNodeScales.self, ForKey: .HourScale)
                    
                case 1:
                    Settings.SetEnum(.Normal, EnumType: MapNodeScales.self, ForKey: .HourScale)
                    
                case 2:
                    Settings.SetEnum(.Large, EnumType: MapNodeScales.self, ForKey: .HourScale)
                    
                default:
                    return
            }
        }
    }
    
    @IBOutlet weak var InputSegment: UISegmentedControl!
    @IBOutlet weak var ShowVersionSwitch: UISwitch!
    @IBOutlet weak var ShowSecondsSwitch: UISwitch!
    @IBOutlet weak var ClockFormatSegment: UISegmentedControl!
    @IBOutlet weak var MapTypeSegment: UISegmentedControl!
    @IBOutlet weak var HourTypeSegment: UISegmentedControl!
    @IBOutlet weak var HourScaleSegment: UISegmentedControl!
}
