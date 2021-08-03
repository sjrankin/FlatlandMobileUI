//
//  InitialSettings.swift
//  InitialSettings
//
//  Created by Stuart Rankin on 7/29/21.
//

import Foundation
import UIKit

class InitialSettings: UITableViewController, UIPickerViewDelegate, UIPickerViewDataSource
{
    override func viewDidLoad()
    {
        super.viewDidLoad()
        ViewTypeSegment.selectedSegmentIndex = 3
        let CurrentClock = Settings.GetEnum(ForKey: .HourType, EnumType: HourTypes.self)
        let ClockIndex = [HourTypes.None,
                          HourTypes.Solar,
                          HourTypes.RelativeToNoon,
                          HourTypes.RelativeToLocation,
                          HourTypes.WallClock].firstIndex(of: CurrentClock ?? .None) ?? 0
        ClockTypeSegment.selectedSegmentIndex = ClockIndex
        QuickMapSelection.reloadAllComponents()
        QuickMapSelection.layer.borderColor = UIColor.systemGray.cgColor
        QuickMapSelection.layer.cornerRadius = 5
        QuickMapSelection.layer.borderWidth = 0.5
        let OldMap = Settings.GetEnum(ForKey: .MapType, EnumType: MapTypes.self) ?? .SimplePoliticalMap1
        var MapIndex = 0
        if MapList.contains(OldMap)
        {
             MapIndex = MapList.firstIndex(of: OldMap) ?? 0
        }
        QuickMapSelection.selectRow(MapIndex, inComponent: 0, animated: true)
    }
    
    let MapList = [MapTypes.SimplePoliticalMap1,
                   MapTypes.BlueMarble,
                   MapTypes.BlackWhiteShiny,
                   MapTypes.WhiteBlack]
    
    func numberOfComponents(in pickerView: UIPickerView) -> Int
    {
        return 1
    }
    
    func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int
    {
        return 4
    }
    
    func pickerView(_ pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String?
    {
        switch row
        {
            case 0:
                return "Simple Political"
                
            case 1:
                return "Blue Marble"
                
            case 2:
                return "Black & White"
                
            case 3:
                return "White & Black"
                
            default:
                return nil
        }
    }
    
    func pickerView(_ pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int)
    {
        let Selected = pickerView.selectedRow(inComponent: component)
        
        if Selected > MapList.count - 1
        {
            Debug.Print("Invalid map index (\(Selected)) returned.")
            return
        }
        let NewMap = MapList[Selected]
        Settings.SetEnum(NewMap, EnumType: MapTypes.self, ForKey: .MapType)
    }
    
    @IBAction func ViewTypeChangedHandler(_ sender: Any)
    {
        if let Segments = sender as? UISegmentedControl
        {
            
        }
    }
    
    @IBAction func ClockTypeChangedHandler(_ sender: Any)
    {
        if let Segments = sender as? UISegmentedControl
        {
            let NewClock = HourTypes.allCases[Segments.selectedSegmentIndex]
            Settings.SetEnum(NewClock, EnumType: HourTypes.self, ForKey: .HourType)
        }
    }
    
    @IBAction func DoneButtonHandler(_ sender: Any)
    {
        dismiss(animated: true, completion: nil)
    }
    
    @IBOutlet weak var QuickMapSelection: UIPickerView!
    @IBOutlet weak var ClockTypeSegment: UISegmentedControl!
    @IBOutlet weak var ViewTypeSegment: UISegmentedControl!
}
