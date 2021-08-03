//
//  EarthquakeSettings.swift
//  EarthquakeSettings
//
//  Created by Stuart Rankin on 8/1/21.
//

import Foundation
import UIKit

class EarthquakeSettings: UITableViewController, UIPickerViewDelegate, UIPickerViewDataSource
{
    override func viewDidLoad()
    {
        super.viewDidLoad()
        NewQuakePicker.layer.borderWidth = 0.5
        NewQuakePicker.layer.borderColor = UIColor.gray.cgColor
        NewQuakePicker.layer.cornerRadius = 5
        ShapesPicker.layer.borderWidth = 0.5
        ShapesPicker.layer.borderColor = UIColor.gray.cgColor
        ShapesPicker.layer.cornerRadius = 5
        NewQuakePicker.reloadAllComponents()
        ShapesPicker.reloadAllComponents()
        let QShape = Settings.GetEnum(ForKey: .EarthquakeShapes, EnumType: EarthquakeShapes.self, Default: .Arrow)
        switch QShape
        {
            case .Arrow:
                ShapesPicker.selectRow(0, inComponent: 0, animated: true)
                
            case .StaticArrow:
                ShapesPicker.selectRow(1, inComponent: 0, animated: true)
                
            case .Pyramid:
                ShapesPicker.selectRow(2, inComponent: 0, animated: true)
                
            case .Cone:
                ShapesPicker.selectRow(3, inComponent: 0, animated: true)
                
            case .Box:
                ShapesPicker.selectRow(4, inComponent: 0, animated: true)
                
            case .Cylinder:
                ShapesPicker.selectRow(5, inComponent: 0, animated: true)
                
            case .Capsule:
                ShapesPicker.selectRow(6, inComponent: 0, animated: true)
                
            default:
                ShapesPicker.selectRow(0, inComponent: 0, animated: true)
        }
        let NQValue = Settings.GetEnum(ForKey: .EarthquakeStyles, EnumType: EarthquakeIndicators.self, Default: .AnimatedRing)
        switch NQValue
        {
            case .AnimatedRing:
                NewQuakePicker.selectRow(0, inComponent: 0, animated: true)
                
            case .RadiatingRings:
                NewQuakePicker.selectRow(1, inComponent: 0, animated: true)
                
            case .GlowingSphere:
                NewQuakePicker.selectRow(2, inComponent: 0, animated: true)
                
            case .TriangleRingOut:
                NewQuakePicker.selectRow(3, inComponent: 0, animated: true)
                
            case .TriangleRingIn:
                NewQuakePicker.selectRow(4, inComponent: 0, animated: true)
        
             default:
                NewQuakePicker.selectRow(0, inComponent: 0, animated: true)
        }
        
        HighlightNewQuakesSwitch.isOn = Settings.GetBool(.HighlightRecentEarthquakes)
        EnableQuakesSwitch.isOn = Settings.GetBool(.EnableEarthquakes)
    
        let QuakeScale = Settings.GetEnum(ForKey: .QuakeScales, EnumType: MapNodeScales.self, Default: .Normal)
        switch QuakeScale
        {
            case .Small:
                ScaleSegment.selectedSegmentIndex = 0
                
            case .Normal:
                ScaleSegment.selectedSegmentIndex = 1
                
            case .Large:
                ScaleSegment.selectedSegmentIndex = 2
        }
        
        let FetchTime = Settings.GetDouble(.EarthquakeFetchInterval, 5.0)
        switch Int(FetchTime)
        {
            case 1:
                FetchSegment.selectedSegmentIndex = 0
                
            case 2:
                FetchSegment.selectedSegmentIndex = 1
                
            case 3:
                FetchSegment.selectedSegmentIndex = 2
                
            case 5:
                FetchSegment.selectedSegmentIndex = 3
                
            case 10:
                FetchSegment.selectedSegmentIndex = 4
                
            case 15:
                FetchSegment.selectedSegmentIndex = 5
                
            case 30:
                FetchSegment.selectedSegmentIndex = 6
                
            default:
                FetchSegment.selectedSegmentIndex = 3
        }
    }
    
    let QuakeShapes =
    [
        "Animated Arrow",
        "Static Arrow",
        "Pyramid",
        "Cone",
        "Box",
        "Cylinder",
        "Capsule",
    ]
    
    let NewQuakes =
    [
        "Animated Ring",
        "Radiating Ring",
        "Glowing Sphere",
        "Triangles Out",
        "Triangles In"
    ]
    
    func numberOfComponents(in pickerView: UIPickerView) -> Int
    {
        return 1
    }
    
    func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int
    {
        switch pickerView
        {
            case ShapesPicker:
                return QuakeShapes.count
                
            case NewQuakePicker:
                return NewQuakes.count
                
            default:
                return 0
        }
    }
    
    func pickerView(_ pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String?
    {
        switch pickerView
        {
            case ShapesPicker:
                return QuakeShapes[row]
                
            case NewQuakePicker:
                return NewQuakes[row]
                
            default:
                return nil
        }
    }
    
    func pickerView(_ pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int)
    {
        let Selected = pickerView.selectedRow(inComponent: component)
        
        switch pickerView
        {
            case ShapesPicker:
                switch Selected
                {
                    case 0:
                        Settings.SetEnum(.Arrow, EnumType: EarthquakeShapes.self, ForKey: .EarthquakeShapes)
                        
                    case 1:
                        Settings.SetEnum(.StaticArrow, EnumType: EarthquakeShapes.self, ForKey: .EarthquakeShapes)
                        
                    case 2:
                        Settings.SetEnum(.Pyramid, EnumType: EarthquakeShapes.self, ForKey: .EarthquakeShapes)
                        
                    case 3:
                        Settings.SetEnum(.Cone, EnumType: EarthquakeShapes.self, ForKey: .EarthquakeShapes)
                        
                    case 4:
                        Settings.SetEnum(.Box, EnumType: EarthquakeShapes.self, ForKey: .EarthquakeShapes)
                        
                    case 5:
                        Settings.SetEnum(.Cylinder, EnumType: EarthquakeShapes.self, ForKey: .EarthquakeShapes)
                        
                    case 6:
                        Settings.SetEnum(.Capsule, EnumType: EarthquakeShapes.self, ForKey: .EarthquakeShapes)
                        
                    default:
                        return
                }
                
            case NewQuakePicker:
                switch Selected
                {
                    case 0:
                        Settings.SetEnum(.AnimatedRing, EnumType: EarthquakeIndicators.self, ForKey: .EarthquakeStyles)
                        
                    case 1:
                        Settings.SetEnum(.RadiatingRings, EnumType: EarthquakeIndicators.self, ForKey: .EarthquakeStyles)
                        
                    case 2:
                        Settings.SetEnum(.GlowingSphere, EnumType: EarthquakeIndicators.self, ForKey: .EarthquakeStyles)
                        
                    case 3:
                        Settings.SetEnum(.TriangleRingOut, EnumType: EarthquakeIndicators.self, ForKey: .EarthquakeStyles)
                        
                    case 4:
                        Settings.SetEnum(.TriangleRingIn, EnumType: EarthquakeIndicators.self, ForKey: .EarthquakeStyles)
                        
                    default:
                        return
                }
                
            default:
                return
        }
    }
    
    @IBAction func CheckNowHandler(_ sender: Any)
    {
    }
    
    @IBAction func EnableQuakesHandler(_ sender: Any)
    {
        if let Switch = sender as? UISwitch
        {
            Settings.SetBool(.EnableEarthquakes, Switch.isOn)
        }
    }
    
    @IBAction func HighlightNewQuakesHandler(_ sender: Any)
    {
        if let Switch = sender as? UISwitch
        {
            Settings.SetBool(.HighlightRecentEarthquakes, Switch.isOn)
        }
    }
    
    @IBAction func FetchTimeChangedHandler(_ sender: Any)
    {
        if let Segment = sender as? UISegmentedControl
        {
            let Durations = [1, 2, 3, 5, 10, 15, 30]
            Settings.SetDouble(.EarthquakeFetchInterval, Double(Durations[Segment.selectedSegmentIndex]))
        }
    }
    
    @IBAction func ScaleChangedHandler(_ sender: Any)
    {
        if let Segment = sender as? UISegmentedControl
        {
            switch Segment.selectedSegmentIndex
            {
                case 0:
                    Settings.SetEnum(.Small, EnumType: MapNodeScales.self, ForKey: .QuakeScales)
                    
                case 1:
                    Settings.SetEnum(.Normal, EnumType: MapNodeScales.self, ForKey: .QuakeScales)
                    
                case 2:
                    Settings.SetEnum(.Large, EnumType: MapNodeScales.self, ForKey: .QuakeScales)
                    
                default:
                    return
            }
        }
    }
    
    @IBOutlet weak var ScaleSegment: UISegmentedControl!
    @IBOutlet weak var FetchSegment: UISegmentedControl!
    @IBOutlet weak var HighlightNewQuakesSwitch: UISwitch!
    @IBOutlet weak var EnableQuakesSwitch: UISwitch!
    @IBOutlet weak var ShapesPicker: UIPickerView!
    @IBOutlet weak var NewQuakePicker: UIPickerView!
}
