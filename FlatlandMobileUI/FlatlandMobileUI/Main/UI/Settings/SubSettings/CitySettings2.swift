//
//  CitySettings.swift
//  CitySettings
//
//  Created by Stuart Rankin on 8/4/21.
//

import Foundation
import UIKit

class CitySettings2: UITableViewController, UIPickerViewDelegate, UIPickerViewDataSource
{
    override func viewDidLoad()
    {
        super.viewDidLoad()
        
        ShapesPicker.layer.borderColor = UIColor.gray.cgColor
        ShapesPicker.layer.borderWidth = 0.5
        ShapesPicker.layer.cornerRadius = 5
        
        PopulationPicker.layer.borderColor = UIColor.gray.cgColor
        PopulationPicker.layer.borderWidth = 0.5
        PopulationPicker.layer.cornerRadius = 5
        
        ShowCitiesSwitch.isOn = Settings.GetBool(.ShowCities)
        
        for CityDisplayType in CityDisplayTypes.allCases
        {
            CityShapeList.append(CityDisplayType.rawValue)
        }
        
        let Rank = Settings.GetInt(.PopulationRank)
        let RankIndex = GetRankingIndex(From: Rank)
        PopulationPicker.selectRow(RankIndex, inComponent: 0, animated: true)
    
        let CurrentShape = Settings.GetEnum(ForKey: .CityShapes, EnumType: CityDisplayTypes.self, Default: .RelativeFloatingSpheres)
        let ShapeIndex = CityDisplayTypes.allCases.firstIndex(of: CurrentShape) ?? 0
        ShapesPicker.selectRow(ShapeIndex, inComponent: 0, animated: true)
    }
    
    var CityShapeList = [String]()
    let CityRanking =
    [
        (5, "Top 5"),
        (10, "Top 10"),
        (20, "Top 20"),
        (50, "Top 50"),
        (100, "Top 100"),
        (200, "Top 200"),
    ]

    func GetRankingIndex(From: Int) -> Int
    {
        for Index in 0 ..< CityRanking.count
        {
            if From <= CityRanking[Index].0
            {
                return Index
            }
        }
        return 4
    }
    
    func pickerView(_ pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int)
    {
        let Selected = pickerView.selectedRow(inComponent: component)
    switch pickerView
        {
        case PopulationPicker:
            let NewRanking = CityRanking[Selected].0
            Settings.SetInt(.PopulationRank, NewRanking)
            
        case ShapesPicker:
            let NewShape = CityDisplayTypes.allCases[Selected]
            Settings.SetEnum(NewShape, EnumType: CityDisplayTypes.self, ForKey: .CityShapes)
            
        default:
            return
    }
    }
    
    func pickerView(_ pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String?
    {
        switch pickerView
        {
            case PopulationPicker:
                return CityRanking[row].1
                
            case ShapesPicker:
                return CityShapeList[row]
                
            default:
                return nil
        }
    }
    
    func numberOfComponents(in pickerView: UIPickerView) -> Int
    {
        return 1
    }
    
    func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int
    {
        switch pickerView
        {
            case PopulationPicker:
                return CityRanking.count
                
            case ShapesPicker:
                return CityShapeList.count
                
            default:
                return 0
        }
    }
    
    @IBAction func ShowCitiesChanged(_ sender: Any)
    {
        if let Switch = sender as? UISwitch
        {
            Settings.SetBool(.ShowCities, Switch.isOn)
        }
    }
    
    @IBAction func CityFilterChanged(_ sender: Any)
    {
        if let Segment = sender as? UISegmentedControl
        {
            SetVisualStateForPopulation(At: Segment.selectedSegmentIndex)
        }
    }
    
    func SetVisualStateForPopulation(At Index: Int)
    {
        if Index == 0
        {
            UIView.animate(withDuration: 0.1, delay: 0, options: [], animations:
                            { [weak self] in
                self!.PopulationPicker.alpha = 1.0
                self!.PopulationLabel.alpha = 1.0
            }, completion: nil)
        }
        else
        {
            UIView.animate(withDuration: 0.35, delay: 0, options: [], animations:
                            { [weak self] in
                self!.PopulationPicker.alpha = 0.0
                self!.PopulationLabel.alpha = 0.0
            }, completion: nil)
        }
    }
    
    @IBOutlet weak var ShapesPicker: UIPickerView!
    @IBOutlet weak var PopulationPicker: UIPickerView!
    @IBOutlet weak var CityFilterSegment: UISegmentedControl!
    @IBOutlet weak var ShowCitiesSwitch: UISwitch!
    @IBOutlet weak var PopulationLabel: UILabel!
}
