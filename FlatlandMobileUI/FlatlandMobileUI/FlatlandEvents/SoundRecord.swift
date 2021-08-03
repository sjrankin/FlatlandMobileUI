//
//  SoundRecord.swift
//  SoundRecord
//
//  Created by Stuart Rankin on 7/18/21. Adapted from Flatland View.
//

import Foundation
import UIKit

/// Encapsulates one sound.
class SoundRecord: PropertyExtraction
{
    /// Default initializer.
    override init()
    {
        super.init()
    }
    
    /// Initializer.
    /// - Parameters:
    ///   - PK: Database PK value.
    ///   - Name: Name of the sound.
    ///   - SoundName: Human-readable name of the sound.
    ///   - IsFile: Sound is local in a file flag.
    ///   - FileName: Name of the local sound file.
    ///   - SoundClass: Sound class name.
    ///   - CanDelete: Can delete flag.
    init(_ PK: Int, _ Name: String, _ SoundName: String, _ IsFile: Bool, _ FileName: String,
         _ SoundClass: String, _ CanDelete: Bool)
    {
        super.init()
        __SoundPK = PK
        __Name = Name
        __SoundName = SoundName
        __IsFile = IsFile
        __FileName = FileName
        __SoundClass = SoundClass
        __CanDelete = CanDelete
    }
    
    /// Reset the dirty flag after changed data has been saved.
    func ResetDirtyFlag()
    {
        _IsDirty = false
    }
    
    /// Holds the database PK value.
    private var __SoundPK: Int = 0
    /// Get the database PK value.
    public var SoundPK: Int
    {
        get
        {
            return __SoundPK
        }
    }
    
    /// Holds the sound name.
    private var __Name: String = ""
    /// Get or set the name of the sound. This is the name sent to the API to play the sound. See also
    /// `SoundName`.
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
    
    /// Holds the sound-is-a-file flag.
    private var __IsFile: Bool = false
    /// Get or set the flag that indicates the sound is a file and not built-in.
    public var IsFile: Bool
    {
        get
        {
            return __IsFile
        }
        set
        {
            __IsFile = newValue
            _IsDirty = true
        }
    }
    
    /// Holds the file name of the sound.
    private var __FileName: String = ""
    /// File name for the sound for non-built-in sounds. Ignored if `IsFile` is false.
    public var FileName: String
    {
        get
        {
            return __FileName
        }
        set
        {
            __FileName = newValue
            _IsDirty = true
        }
    }
    
    /// Holds the user-visible sound name.
    private var __SoundName: String = ""
    /// Get or set the user-visible sound name.
    public var SoundName: String
    {
        get
        {
            return __SoundName
        }
        set
        {
            __SoundName = newValue
            _IsDirty = true
        }
    }
    
    /// Holds the sound class.
    private var __SoundClass: String = ""
    /// Get or set the sound class.
    public var SoundClass: String
    {
        get
        {
            return __SoundClass
        }
        set
        {
            __SoundClass = newValue
            _IsDirty = true
        }
    }
    
    /// Get the sound class (derived from the value in `SoundClass`).
    public var Class: SoundClasses
    {
        get
        {
            if let Actual = SoundClasses(rawValue: __SoundClass)
            {
                return Actual
            }
            return .General
        }
    }
    
    /// Holds the can delete flag.
    private var __CanDelete: Bool = false
    /// Get the can delete flag.
    public var CanDelete: Bool
    {
        get
        {
            return __CanDelete
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
