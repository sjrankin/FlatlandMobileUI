//
//  SoundManager.swift
//  SoundManager
//
//  Created by Stuart Rankin on 7/21/21. Adapted from Flatland View.
//

import Foundation
import UIKit
import AVFoundation

/// Manages sounds and the playing of sounds.
/// - Note:
///    - When playing sounds, control returns immediately.
///    - All sounds are played in the `SoundManager.Play` function. If the global setting `.EnableSounds` is
///      false, no sounds will be played regardless of the event.
class SoundManager
{
    /// Initialize the sound manager.
    public static func Initialize()
    {
#if DEBUG
        EventSoundMap[.Debug] = Sounds.Frog.rawValue
#endif
    }
    
    /// Determines if the current time is in the mute period.
    /// - Returns: `True` if the current time is in the mute period, `false` if not. A returned value of `false`
    ///            means the sound should play.
    public static var IsInMutePeriod: Bool
    {
        get
        {
            return IsInMutePeriod(Date())
        }
    }
    
    /// Determines if the passed time is in the mute period.
    /// - Note: Only the time portion of `When` is used.
    /// - Parameter When: The date (only the time portion) to use to determine if the current time is in
    ///                   the global mute period.
    /// - Returns: `True` if the current time is in the mute period, `false` if not. A returned value of `false`
    ///            means the sound should play.
    public static func IsInMutePeriod(_ When: Date) -> Bool
    {
        if !Settings.GetBool(.EnableMutePeriod)
        {
            return false
        }
        let MuteDuration = Settings.GetInt(.MutePeriodDuration)
        let MuteStart = Settings.GetInt(.MutePeriodStart)
        let Now = When
        let NowHour = Now.Hour
        let NowMinute = Now.Minute
        let NowSeconds = (NowHour * 60 * 60) + (NowMinute * 60)
        if MuteStart + MuteDuration > (24 * 60 * 60)
        {
            //The duration spans midnight.
            if NowSeconds < ((MuteStart + MuteDuration) - (24 * 60 * 60))
            {
                return true
            }
            if NowSeconds > MuteStart
            {
                return true
            }
        }
        else
        {
            //The duration is contained within a day.
            if NowSeconds > MuteStart && NowSeconds < MuteStart + MuteDuration
            {
                return true
            }
        }
        return false
    }
    
    /// Holds the `AVAudioPlayer` instance. If not stored as a property (or global), no sound will be heard
    /// because the `AVAudioPlayer` will go out of scope almost immediately.
    /// - Note: See: [AVAudioPlayer play does not play sound](https://stackoverflow.com/questions/29379524/avaudioplayer-play-does-not-play-sound)
    private static var Player: AVAudioPlayer? = nil
    
    /// Play a sound packaged with the bundle.
    /// - Note: If there are errors playing the sound, control will return immediately.
    /// - Parameter Name: Name of the sound. All sounds in the bundle must end with `.mp3` (and be that type)
    ///                   but the name passed here should not include the extension.
    /// - Parameter OverrideMute: If true, the sound will play even if in the mute period. Intended for use
    ///                           by settings code.
    private static func PlayBundleSound(_ Name: String, OverrideMute: Bool = false)
    {
        if !OverrideMute
        {
            if IsInMutePeriod
            {
                return
            }
        }
        
        guard let TheSound = Sounds(rawValue: Name) else
        {
            return
        }
        guard let ResourceName = AdditionalToResource[TheSound] else
        {
            return
        }
        if let List = Bundle.main.urls(forResourcesWithExtension: "mp3", subdirectory: nil)
        {
            for ListItem in List
            {
                print(">>> \(ListItem.lastPathComponent )")
            }
        }
        guard let SoundUrl = Bundle.main.url(forResource: ResourceName, withExtension: "mp3") else
        {
            Debug.Print("Error getting \(ResourceName) in bundle.")
            return
        }
        do
        {
            Player = try AVAudioPlayer(contentsOf: SoundUrl, fileTypeHint: AVFileType.mp3.rawValue)
            guard let ThePlayer = Player else
            {
                Debug.Print("Error creating audio player")
                return
            }
            ThePlayer.play()
        }
        catch
        {
            Debug.Print("Error creating audio player: \(error.localizedDescription)")
        }
    }
    
    /// Play a sound with the specified name. No error checking is done.
    /// - Parameter Name: The name of the sound to play.
    /// - Parameter OverrideMute: If true, the sound will play even if in the mute period. Intended for use
    ///                           by settings code.
    public static func Play(Name: String, OverrideMute: Bool = false)
    {
        if Settings.GetBool(.EnableSounds)
        {
            if !OverrideMute
            {
                if IsInMutePeriod
                {
                    return
                }
            }
            if IsAsset(Name)
            {
                PlayBundleSound(Name)
                return
            }
#if true
            PlaySound(With: Name)
#else
            NSSound(named: Name)?.play()
#endif
        }
    }
    
    private static var player: AVAudioPlayer?
    
    //https://stackoverflow.com/questions/32036146/how-to-play-a-sound-using-swift
    private static func PlaySound(With Name: String)
    {
        guard let url = Bundle.main.url(forResource: "soundName", withExtension: "mp3") else
        {
            return
            
        }
        
        do {
            try AVAudioSession.sharedInstance().setCategory(.playback, mode: .default)
            try AVAudioSession.sharedInstance().setActive(true)
            
            /* The following line is required for the player to work on iOS 11. Change the file type accordingly*/
            player = try AVAudioPlayer(contentsOf: url, fileTypeHint: AVFileType.mp3.rawValue)
            
            /* iOS 10 and earlier require the following line:
             player = try AVAudioPlayer(contentsOf: url, fileTypeHint: AVFileTypeMPEGLayer3) */
            
            guard let player = player else
            {
                return
                
            }
            
            player.play()
            
        }
        catch let error
        {
            print(error.localizedDescription)
        }
    }
    
    private static func IsAsset(_ Name: String) -> Bool
    {
        for SoundName in AdditionalSounds
        {
            if SoundName.rawValue == Name
            {
                return true
            }
        }
        return false
    }
    
    /// Plays a sound given the passed sound enumeration.
    /// - Note: See [Accessing Audio Files in Asset Catalogs](https://developer.apple.com/library/archive/qa/qa1913/_index.html)
    /// - Parameter Sound: The sound enumeration to play. If nil, no action is taken.
    /// - Parameter OverrideMute: If true, the sound will be played even if in the mute period. Intended to be
    ///                           used for settings.
    public static func Play(Sound: Sounds?, OverrideMute: Bool = false)
    {
        if !OverrideMute
        {
            if IsInMutePeriod
            {
                return
            }
        }
        if let TheSound = Sound
        {
            if AdditionalSounds.contains(TheSound)
            {
                if let SoundName = AdditionalToResource[TheSound]
                {
                    if let Asset = NSDataAsset(name: SoundName)
                    {
                        do
                        {
                            let Player = try AVAudioPlayer(data: Asset.data, fileTypeHint: "mp3")
                            Player.play()
                        }
                        catch
                        {
                            Debug.Print("Error playing \(TheSound.rawValue): \(error.localizedDescription)")
                        }
                    }
                }
            }
            else
            {
                Play(Name: TheSound.rawValue)
            }
        }
    }
    
    /// Play a sound for the passed event.
    /// - Parameter ForEvent: The event whose sound will be played.
    public static func Play(ForEvent: SoundEvents)
    {
#if true
        Play(Sound: GetEventSound(ForEvent))
#else
        if let SoundName = GetSoundForEvent(ForEvent)
        {
            Play(Name: SoundName)
        }
#endif
    }
    
    /// Return the name of the sound for the specified event.
    /// - Parameter EventType: The event whose sound name is returned.
    /// - Returns: Name of the file for the event on success, nil if not found.
    public static func GetSoundForEvent(_ EventType: SoundEvents) -> String?
    {
        if let SoundName = EventSoundMap[EventType]
        {
            if SoundName == Sounds.None.rawValue
            {
                return nil
            }
            return SoundName
        }
        return nil
    }
    
    /// Plays a sound for the passed event.
    /// - Note: Events are examined to determine if sounds should be played or not (eg, if `.NoSound` or
    ///         `.SoundMuted` are `true`).
    /// - Parameter Event: The event record whose sound will be played.
    /// - Parameter OverrideMute: If true, the sound will be played even if in the mute period. Intended to be
    ///                           used for settings.
    public static func PlaySoundFor(Event: EventRecord, OverrideMute: Bool = false)
    {
        if Event.NoSound
        {
            return
        }
        if Event.SoundMuted
        {
            return
        }
        if let Sound = Event.EventSound
        {
            Play(Name: Sound.Name)
        }
    }
    
    /// Return the sound enumeration for the passed sound event.
    /// - Parameter EventType: The event whose sound enumeration is returned.
    /// - Returns: `Sounds` enumeration for the passed event.
    public static func GetEventSound(_ EventType: SoundEvents) -> Sounds?
    {
        if let TheEvent = EventSoundMap[EventType]
        {
            return Sounds(rawValue: TheEvent)
        }
        return nil
    }
    
    /// Map of events to sound names.
    static var EventSoundMap: [SoundEvents: String] =
    [
        .BadInput: Sounds.Tink.rawValue,
        .HourChime: Sounds.Blow.rawValue,
        .NewEarthquake: Sounds.Sosumi.rawValue,
    ]
    
    /// Array of sounds in the asset catelog.
    static var AdditionalSounds = [Sounds.Chime, Sounds.Cymbal, Sounds.Doorbell, Sounds.Fiddle,
                                   Sounds.Gong, Sounds.TimeSignal1, Sounds.TimeSignal2]
    
    /// Map of sounds to non-system sound names.
    static var AdditionalToResource: [Sounds: String] =
    [
        Sounds.Chime: "Chime3",
        Sounds.Cymbal: "Cymbal",
        Sounds.Doorbell: "Doorbell",
        Sounds.Fiddle: "Fiddle",
        Sounds.Gong: "Gong",
        Sounds.TimeSignal1: "gts_pips",
        Sounds.TimeSignal2: "NHKPips",
    ]
}

/// Sound classes. Not used yet.
enum SoundClasses: String, CaseIterable
{
    case General = "General"
    case BuiltIn = "Built-In"
    case Flatland = "Flatland"
    case Asset = "Asset"
    case User = "User"
}

/// Sounds for events.
enum Sounds: String, CaseIterable
{
    case None = "None"
    case User = "User File"
    case Basso = "Basso"
    case Blow = "Blow"
    case Bottle = "Bottle"
    case Frog = "Frog"
    case Funk = "Funk"
    case Glass = "Glass"
    case Hero = "Hero"
    case Morse = "Morse"
    case Ping = "Ping"
    case Pop = "Pop"
    case Purr = "Purr"
    case Sosumi = "Sosumi"
    case Submarine = "Submarine"
    case Tink = "Tink"
    //Non-built-in sounds
    case Chime = "Chime"
    case Cymbal = "Cymbal"
    case Doorbell = "Doorbell"
    case Fiddle = "Fiddle"
    case Gong = "Gong"
    case TimeSignal1 = "Time Signal 1"
    case TimeSignal2 = "Time Signal 2"
}

/// Events that can have associated sounds.
enum SoundEvents: String, CaseIterable
{
    /// Bad input (such as invalid numbers and the like). Should be a short, soft sound.
    case BadInput = "Bad Input"
    /// New hour event for indicating aurally the hour has changed.
    case HourChime = "Hour Chime"
    /// New earthquake received event.
    case NewEarthquake = "New Earthquake"
#if DEBUG
    /// Debug events of some type.
    case Debug = "Debug Event"
#endif
}
