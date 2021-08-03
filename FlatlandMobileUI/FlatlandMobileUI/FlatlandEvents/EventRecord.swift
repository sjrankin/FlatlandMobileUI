//
//  EventRecord.swift
//  EventRecord
//
//  Created by Stuart Rankin on 7/18/21. Adapted from Flatland View.
//

import Foundation
import UIKit

/// Holds event definition data for one event stored in the settings database.
class EventRecord: PropertyExtraction
{
    /// Default initializer.
    override init()
    {
        super.init()
    }
    
    /// Initializer.
    /// - Parameters:
    ///   - PK: Primary key value from the database.
    ///   - Name: Name of the event.
    ///   - ID: ID of the event.
    ///   - Enabled: Event's enabled flag.
    ///   - Muted: Event sound muted flag.
    ///   - NoSound: No sound for event flag.
    init(_ PK: Int, _ Name: String, _ ID: Int, _ Enabled: Bool, _ Muted: Bool, _ NoSound: Bool)
    {
        super.init()
        __EventPK = PK
        __Name = Name
        __SoundID = ID
        __Enabled = Enabled
        __SoundMuted = Muted
        __NoSound = NoSound
    }
    
    /// Resets the dirty flag. Should be called only after data has been saved.
    func ResetDirtyFlag()
    {
        _IsDirty = false
    }
    
    /// Holds the event PK ID.
    private var __EventPK: Int = 0
    /// Get the event PK.
    public var EventPK: Int
    {
        get
        {
            return __EventPK
        }
    }
    
    /// Holds the event name.
    private var __Name: String = ""
    /// Get or set the event name.
    public var Name: String
    {
        get
        {
            return __Name
        }
        set
        {
            __Name = newValue
            _IsDirty = true
        }
    }
    
    /// Holds the ID of the associated sound.
    private var __SoundID: Int = 0
    /// Get or set the ID of the associated sound.
    /// - Note: This value is the same as the sound's PK value in the settings database.
    public var SoundID: Int
    {
        get
        {
            return __SoundID
        }
        set
        {
            __SoundID = newValue
            _IsDirty = true
        }
    }
    
    /// Holds the sound for the event. Nil if not set or found.
    public var EventSound: SoundRecord? = nil
    
    /// Holds the sound is muted flag.
    private var __SoundMuted: Bool = false
    /// Get or set the sound is muted flag.
    public var SoundMuted: Bool
    {
        get
        {
            return __SoundMuted
        }
        set
        {
            __SoundMuted = newValue
            _IsDirty = true
        }
    }
    
    /// Holds the event is enabled flag.
    private var __Enabled: Bool = true
    /// Get or set the event is enabled flag.
    public var Enabled: Bool
    {
        get
        {
            return __Enabled
        }
        set
        {
            __Enabled = newValue
            _IsDirty = true
        }
    }
    
    /// Holds the no sound flag.
    private var __NoSound: Bool = false
    /// Get or set the flag that indicates whether the sound information is valid or not. This is set to `true`
    /// when the user disables sound for the event.
    public var NoSound: Bool
    {
        get
        {
            return __NoSound
        }
        set
        {
            __NoSound = newValue
            _IsDirty = true
        }
    }
    
    /// Holds the dirty flag.
    private var _IsDirty: Bool = false
    /// Get the dirty flag.
    public var IsDirty: Bool
    {
        get
        {
            return _IsDirty
        }
    }
}
