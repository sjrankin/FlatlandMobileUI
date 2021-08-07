//
//  EventSoundEditor.swift
//  EventSoundEditor
//
//  Created by Stuart Rankin on 8/6/21.
//

import Foundation
import UIKit

class EventSoundEditor: UIViewController, UIPickerViewDelegate, UIPickerViewDataSource
{
    public var Parent: SoundEventEditorProtocol? = nil
    
    override func viewDidLoad()
    {
        super.viewDidLoad()
        SoundPicker.layer.borderWidth = 0.5
        SoundPicker.layer.borderColor = UIColor.systemGray.cgColor
        SoundPicker.layer.cornerRadius = 5
        SoundPicker.reloadAllComponents()
        if let SoundIndex = SoundList.firstIndex(of: PassedSound)
        {
            SoundPicker.selectRow(SoundIndex, inComponent: 0, animated: true)
        }
    }
    
    func SetEventData(Name: String, Sound: String)
    {
        self.title = "Sound for \(Name)"
        PassedEvent = Name
        PassedSound = Sound
    }
    
    var PassedEvent = ""
    var PassedSound = ""
    
    let SoundList =
    [
        "None",
        "Basso",
        "Blow",
        "Bottle",
        "Frog",
        "Funk",
        "Glass",
        "Hero",
        "Morse",
        "Ping",
        "Pop",
        "Purr",
        "Sosumi",
        "Submarine",
        "Tink",
        "Chime",
        "Cymbal",
        "Doorbell",
        "Fiddle",
        "Gong",
        "gts_pips",
        "NHKPips",
    ]
    
    func numberOfComponents(in pickerView: UIPickerView) -> Int
    {
        return 1
    }
    
    func pickerView(_ pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String?
    {
        return SoundList[row]
    }
    
    func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int
    {
        return SoundList.count
    }
    
    @IBAction func PlaySoundButtonHandler(_ sender: Any)
    {
        let SelectedIndex = SoundPicker.selectedRow(inComponent: 0)
        if SelectedIndex > -1
        {
            SoundManager.Play(Name: SoundList[SelectedIndex])
        }
    }
    
    override func viewWillDisappear(_ animated: Bool)
    {
        let SelectedIndex = SoundPicker.selectedRow(inComponent: 0)
        var SoundName = ""
        if SelectedIndex > -1
        {
            SoundName = SoundList[SelectedIndex]
        }
        Parent?.SetEventData(Name: PassedEvent, Sound: SoundName)
        super.viewWillDisappear(animated)
    }
    
    @IBOutlet weak var SoundPicker: UIPickerView!
}
