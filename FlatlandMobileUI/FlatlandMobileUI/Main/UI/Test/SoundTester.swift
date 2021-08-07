//
//  SoundTester.swift
//  SoundTester
//
//  Created by Stuart Rankin on 8/7/21.
//

import Foundation
import UIKit
import AVFoundation

class SoundTester: UITableViewController, UIPickerViewDelegate, UIPickerViewDataSource
{
    override func viewDidLoad()
    {
        super.viewDidLoad()
        SoundPicker.layer.borderColor = UIColor.systemGray.cgColor
        SoundPicker.layer.borderWidth = 0.5
        SoundPicker.layer.cornerRadius = 5
        SoundPicker.reloadAllComponents()
    }
    
    let SoundList =
    [
        "Doorbell",
        "Chime",
        "Cymbal",
        "Gong",
        "gts_pips",
        "NHKPips"
    ]
    
    func numberOfComponents(in pickerView: UIPickerView) -> Int
    {
        return 1
    }
    
    func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int
    {
        return SoundList.count
    }
    
    func pickerView(_ pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String?
    {
        return SoundList[row]
    }
    
    @IBAction func TestSoundButtonHandler(_ sender: Any)
    {
        let Selected = SoundPicker.selectedRow(inComponent: 0)
        let Name = SoundList[Selected]
        #if true
        Name.Play()
        #else
        if let path = Bundle.main.path(forResource: Name, ofType: "mp3")
        {
            let url = URL(fileURLWithPath: path) as CFURL
            var soundID: SystemSoundID = 0
            AudioServicesCreateSystemSoundID(url, &soundID)
            AudioServicesPlaySystemSound(soundID)
        }
        else
        {
            print("\(Name).mp3 not found.")
        }
        #endif
    }
    
    @IBOutlet weak var SoundPicker: UIPickerView!
}
