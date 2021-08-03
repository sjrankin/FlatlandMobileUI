//
//  MapAttributes.swift
//  MapAttributes
//
//  Created by Stuart Rankin on 7/31/21.
//

import Foundation
import UIKit

class MapAttributes: UITableViewController, UIPickerViewDelegate, UIPickerViewDataSource
{
    override func viewDidLoad()
    {
        FlatDarknessPicker.layer.borderWidth = 0.5
        FlatDarknessPicker.layer.borderColor = UIColor.gray.cgColor
        FlatDarknessPicker.layer.cornerRadius = 5
        GridLineColorPicker.layer.borderWidth = 0.5
        GridLineColorPicker.layer.borderColor = UIColor.gray.cgColor
        GridLineColorPicker.layer.cornerRadius = 5
        BackgroundColorPicker.layer.borderWidth = 0.5
        BackgroundColorPicker.layer.borderColor = UIColor.gray.cgColor
        BackgroundColorPicker.layer.cornerRadius = 5
        FlatDarknessPicker.reloadAllComponents()
        GridLineColorPicker.reloadAllComponents()
        BackgroundColorPicker.reloadAllComponents()
        
        switch Settings.GetEnum(ForKey: .PolarShape, EnumType: PolarShapes.self)
        {
            case .None:
                PolarShapeSegment.selectedSegmentIndex = 0
                
            case .Flag:
                PolarShapeSegment.selectedSegmentIndex = 1

            case .Pole:
                PolarShapeSegment.selectedSegmentIndex = 2

            default:
                PolarShapeSegment.selectedSegmentIndex = 0
        }
        
        InitializeColors()
        
        let Dark = Settings.GetEnum(ForKey: .NightDarkness, EnumType: NightDarknesses.self)
        var DarkIndex = 0
        switch Dark
        {
            case .VeryLight:
                DarkIndex = 0
                
            case .Light:
                    DarkIndex = 1
                
            case .Dark:
                DarkIndex = 2
                
            case .VeryDark:
                DarkIndex = 3
                
            default:
                break
        }
        FlatDarknessPicker.selectRow(DarkIndex, inComponent: 0, animated: true)
        
        GridLineSwitch.isOn = Settings.GetBool(.GridLinesDrawnOnMap)
        ShowMoonlightSwitch.isOn = Settings.GetBool(.ShowMoonLight)
        ShowWallClockSeparatorSwitch.isOn = Settings.GetBool(.ShowWallClockSeparators)
    }
    
    func IndexOfColor(_ Color: UIColor) -> Int?
    {
        var Index = 0
        for (SomeColor, _) in ColorList
        {
            if SomeColor.SameAs(Color)
            {
                return Index
            }
            Index = Index + 1
        }
        return nil
    }
    
    func InitializeColors()
    {
        let BGColor = Settings.GetColor(.BackgroundColor3D, .black)
        let BGIndex = IndexOfColor(BGColor) ?? 0
        BackgroundColorPicker.selectRow(BGIndex, inComponent: 0, animated: true)
        let GridColor = Settings.GetColor(.GridLineColor, .black)
        let GridIndex = IndexOfColor(GridColor) ?? 0
        GridLineColorPicker.selectRow(GridIndex, inComponent: 0, animated: true)
    }
    
    let ColorList =
    [
        (UIColor.black, "Black"),
        (UIColor.white, "White"),
        (UIColor.red, "Red"),
        (UIColor.green, "Green"),
        (UIColor.blue, "Blue"),
        (UIColor.cyan, "Cyan"),
        (UIColor.magenta, "Magenta"),
        (UIColor.yellow, "Yellow"),
        (UIColor.orange, "Orange")
    ]
    
    let DarkLevels =
    [
    "Very Light",
    "Light",
    "Dark",
    "Very Dark"
    ]
    
    func numberOfComponents(in pickerView: UIPickerView) -> Int
    {
        return 1
    }
    
    func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int
    {
        switch pickerView
        {
            case FlatDarknessPicker:
                return DarkLevels.count
                
            default:
                return ColorList.count
        }
    }
    
    func pickerView(_ pickerView: UIPickerView, viewForRow row: Int, forComponent: Int, reusing: UIView?) -> UIView
    {
        switch pickerView
        {
            case BackgroundColorPicker, GridLineColorPicker:
                let SomeView = UIView()
                let Swatch = UIView()
                Swatch.layer.borderWidth = 0.5
                Swatch.layer.cornerRadius = 5
                Swatch.layer.borderColor = UIColor.black.cgColor
                Swatch.layer.backgroundColor = ColorList[row].0.cgColor
                Swatch.bounds = CGRect(origin: .zero, size: CGSize(width: 40.0, height: 22))
                Swatch.frame = CGRect(x: 5, y: 2, width: 40, height: 22)
                SomeView.addSubview(Swatch)
                let Label = UILabel()
                Label.text = ColorList[row].1
                Label.bounds = CGRect(origin: .zero, size: CGSize(width: 300, height: 22))
                Label.frame = CGRect(x: 50, y: 2, width: 400, height: 22)
                SomeView.addSubview(Label)
                return SomeView
                
            case FlatDarknessPicker:
                let Label = UILabel()
                Label.text = DarkLevels[row]
                return Label
                
            default:
                return UIView()
        }
    }
    
    func pickerView(_ pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int)
    {
        let Selected = pickerView.selectedRow(inComponent: component)
        switch pickerView
        {
            case BackgroundColorPicker:
                let Color = ColorList[Selected].0
                Settings.SetColor(.BackgroundColor3D, Color)
                
            case GridLineColorPicker:
                let Color = ColorList[Selected].0
                Settings.SetColor(.GridLineColor, Color)
                
            case FlatDarknessPicker:
                var DarkLevel = NightDarknesses.Dark
                switch Selected
                {
                    case 0:
                        DarkLevel = .VeryLight
                        
                    case 1:
                        DarkLevel = .Light
                        
                    case 2:
                        DarkLevel = .Dark
                        
                    case 3:
                        DarkLevel = .VeryDark
                        
                    default:
                        DarkLevel = .Dark
                }
                Settings.SetEnum(DarkLevel, EnumType: NightDarknesses.self, ForKey: .NightDarkness)
                
            default:
                return
        }
    }
    
    @IBAction func PolarShapeChangeHandler(_ sender: Any)
    {
        if let Segment = sender as? UISegmentedControl
        {
            let Index = Segment.selectedSegmentIndex
            switch Index
            {
                case 0:
                    Settings.SetEnum(.None, EnumType: PolarShapes.self, ForKey: .PolarShape)
                    
                case 1:
                    Settings.SetEnum(.Flag, EnumType: PolarShapes.self, ForKey: .PolarShape)
                    
                case 2:
                    Settings.SetEnum(.Pole, EnumType: PolarShapes.self, ForKey: .PolarShape)
                    
                default:
                    break
            }
        }
    }
    
    @IBAction func WallClockSeparatorChangeHandler(_ sender: Any)
    {
        if let Switch = sender as? UISwitch
        {
            Settings.SetBool(.ShowWallClockSeparators, Switch.isOn)
        }
    }
    
    @IBAction func MoonlightChangedHandler(_ sender: Any)
    {
        if let Switch = sender as? UISwitch
        {
            Settings.SetBool(.ShowMoonLight, Switch.isOn)
        }
    }
    
    @IBAction func GridLinesChanged(_ sender: Any)
    {
        if let Switch = sender as? UISwitch
        {
            Settings.SetBool(.GridLinesDrawnOnMap, Switch.isOn)
        }
    }
    
    @IBOutlet weak var GridLineSwitch: UISwitch!
    @IBOutlet weak var FlatDarknessPicker: UIPickerView!
    @IBOutlet weak var ShowWallClockSeparatorSwitch: UISwitch!
    @IBOutlet weak var PolarShapeSegment: UISegmentedControl!
    @IBOutlet weak var BackgroundColorPicker: UIPickerView!
    @IBOutlet weak var ShowMoonlightSwitch: UISwitch!
    @IBOutlet weak var GridLineColorPicker: UIPickerView!
}
