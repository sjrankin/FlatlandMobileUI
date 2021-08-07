//
//  EventListController.swift
//  EventListController
//
//  Created by Stuart Rankin on 8/6/21.
//

import Foundation
import UIKit

class EventListController: UITableViewController, SoundEventEditorProtocol
{
    override func viewDidLoad()
    {
        super.viewDidLoad()
        let Events = Settings.GetEvents()
        for SomeEvent in Events
        {
           if let EvSd = SomeEvent.EventSound
            {
               switch SomeEvent.Name
               {
                   case "Hour Chime":
                       EventDictionary[SomeEvent.Name] = EvSd.Name
                       HourChimeSound.setTitle(EvSd.Name, for: .normal)
                       
                   case "Bad Input":
                       EventDictionary[SomeEvent.Name] = EvSd.Name
                       BadInputSound.setTitle(EvSd.Name, for: .normal)
                       
                   case "New Earthquake":
                       EventDictionary[SomeEvent.Name] = EvSd.Name
                       NewEarthquakeSound.setTitle(EvSd.Name, for: .normal)
                       
                   default:
                       break
               }
           }
        }
    }
    
    var EventDictionary = [String: String]()
    
    func SetEventData(Name: String, Sound: String)
    {
        print("EventListController.SetEventData(\(Name), \(Sound))")
        EventDictionary[Name] = Sound
        switch Name
        {
            case "Hour Chime":
                HourChimeSound.setTitle(Sound, for: .normal)
                
            case "Bad Input":
                BadInputSound.setTitle(Sound, for: .normal)
                
            case "New Earthquake":
                NewEarthquakeSound.setTitle(Sound, for: .normal)
                
            default:
                return
        }
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?)
    {
        switch segue.identifier
        {
            case "HourChimeSegue":
                if let Dest = segue.destination as? EventSoundEditor
                {
                    Dest.Parent = self
                    Dest.SetEventData(Name: "Hour Chime", Sound: EventDictionary["Hour Chime"]!)
                }
                
            case "NewEarthquakeSegue":
                if let Dest = segue.destination as? EventSoundEditor
                {
                    Dest.Parent = self
                    Dest.SetEventData(Name: "New Earthquake", Sound: EventDictionary["New Earthquake"]!)
                }
                
            case "BadInputSegue":
                if let Dest = segue.destination as? EventSoundEditor
                {
                    Dest.Parent = self
                    Dest.SetEventData(Name: "Bad Input", Sound: EventDictionary["Bad Input"]!)
                }
                
            default:
                break
        }
        
        super.prepare(for: segue, sender: self)
    }

    
    @IBAction func HourChimePressed(_ sender: Any)
    {
        
    }
    
    @IBOutlet weak var HourChimeSound: UIButton!
    @IBOutlet weak var BadInputSound: UIButton!
    @IBOutlet weak var NewEarthquakeSound: UIButton!
}
