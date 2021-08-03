//
//  +LoadSettings.swift
//  +LoadSettings
//
//  Created by Stuart Rankin on 7/19/21. Adapted from Flatland View
//

import Foundation
import UIKit
import SQLite3

extension DBIF
{
    /// Load tables from the settings database.
    static func LoadSettingsTables()
    {
        SoundList = LoadSounds()
        EventList = LoadEvents()
        AttachSoundsToEvents()
    }
    
    /// Attach sounds to events.
    static func AttachSoundsToEvents()
    {
        for SomeEvent in EventList
        {
            let EventSoundID = SomeEvent.SoundID
            if let Sound = GetSound(By: EventSoundID)
            {
                SomeEvent.EventSound = Sound
            }
        }
    }
    
    /// Return a sound from the loaded sound table.
    /// - Parameter By: The ID of the sound to return.
    static func GetSound(By ID: Int) -> SoundRecord?
    {
        for SomeSound in SoundList
        {
            if SomeSound.SoundPK == ID
            {
                return SomeSound
            }
        }
        return nil
    }
    
    /// Load events from the database.
    /// - Returns: Array of events from the database.
    static func LoadEvents() -> [EventRecord]
    {
        var Results = [EventRecord]()
        let GetQuery = "SELECT * FROM \(SettingsDB.EventTable.rawValue)"
        let QuerySetupResult = SQL.SetupQuery(For: DBIF.SettingsHandle, Query: GetQuery)
        var QueryHandle: OpaquePointer? = nil
        switch QuerySetupResult
        {
            case .success(let Handle):
                QueryHandle = Handle
                
            case .failure(let Why):
                Debug.Print("Failure creating query for events: \(Why)")
                let (Message, Value) = SQL.ExtendedError(From: DBIF.SettingsHandle)
                Debug.Print("  \(Message) [\(Value)]")
                return [EventRecord]()
        }
        
        while sqlite3_step(QueryHandle) == SQLITE_ROW
        {
            let PKID = SQL.ReadIntColumn(Handle: QueryHandle, Index: EventColumns.EventPK.rawValue)!
            let Name = SQL.ReadStringColumn(Handle: QueryHandle, Index: EventColumns.Name.rawValue)!
            let SoundID = SQL.ReadIntColumn(Handle: QueryHandle, Index: EventColumns.SoundID.rawValue)!
            let Muted = SQL.ReadBoolColumn(Handle: QueryHandle, Index: EventColumns.SoundMuted.rawValue)!
            let Enabled = SQL.ReadBoolColumn(Handle: QueryHandle, Index: EventColumns.Enabled.rawValue)!
            let NoSound = SQL.ReadBoolColumn(Handle: QueryHandle, Index: EventColumns.NoSound.rawValue)!
            let SomeEvent = EventRecord(PKID, Name, SoundID, Enabled, Muted, NoSound)
            Results.append(SomeEvent)
        }
        
        return Results
    }
    
    /// Load sounds from the database.
    /// - Note: The actual sounds are not stored in the database - just descriptions of the sounds.
    /// - Returns: Array of sound records.
    static func LoadSounds() -> [SoundRecord]
    {
        var Results = [SoundRecord]()
        let GetQuery = "SELECT * FROM \(SettingsDB.SoundTable.rawValue)"
        let QuerySetupResult = SQL.SetupQuery(For: DBIF.SettingsHandle, Query: GetQuery)
        var QueryHandle: OpaquePointer? = nil
        switch QuerySetupResult
        {
            case .success(let Handle):
                QueryHandle = Handle
                
            case .failure(let Why):
                Debug.Print("Failure creating query for sounds: \(Why)")
                let (Message, Value) = SQL.ExtendedError(From: DBIF.SettingsHandle)
                Debug.Print("  \(Message) [\(Value)]")
                return [SoundRecord]()
        }
        
        while sqlite3_step(QueryHandle) == SQLITE_ROW
        {
            let PKID = SQL.ReadIntColumn(Handle: QueryHandle, Index: SoundColumns.SoundPK.rawValue)!
            let Name = SQL.ReadStringColumn(Handle: QueryHandle, Index: SoundColumns.Name.rawValue)!
            //let IsFile = SQL.ReadBoolColumn(Handle: QueryHandle, Index: SoundColumns.IsFile.rawValue)!
            let IsFile = false
            let FileName = SQL.ReadStringColumn(Handle: QueryHandle, Index: SoundColumns.FileName.rawValue)!
            let SoundName = SQL.ReadStringColumn(Handle: QueryHandle, Index: SoundColumns.SoundName.rawValue)!
            let SoundClass = SQL.ReadStringColumn(Handle: QueryHandle, Index: SoundColumns.SoundClass.rawValue)!
            let CanDelete = SQL.ReadBoolColumn(Handle: QueryHandle, Index: SoundColumns.CanDelete.rawValue)!
            let SomeSound = SoundRecord(PKID, Name, SoundName, IsFile, FileName, SoundClass, CanDelete)
            Results.append(SomeSound)
        }
        
        return Results
    }
    
    /// Save the contents of the event list.
    public static func SaveEvents()
    {
        for SomeEvent in EventList
        {
            if SomeEvent.IsDirty
            {
                if let RawData = SomeEvent.Properties()
                {
                    let Command = SQL.MakeUpdateStatement(From: RawData, For: SettingsDB.EventTable.rawValue)
                    SQL.UpdateRow(Database: DBIF.SettingsHandle!, Table: SettingsDB.EventTable.rawValue,
                                  Row: Command)
                }
                SomeEvent.ResetDirtyFlag()
            }
        }
    }
    
    /// Save the contents of the sound list.
    public static func SaveSounds()
    {
        for SomeSound in SoundList
        {
            if SomeSound.IsDirty
            {
                if let RawData = SomeSound.Properties()
                {
                    let Command = SQL.MakeUpdateStatement(From: RawData, For: SettingsDB.EventTable.rawValue)
                    SQL.UpdateRow(Database: DBIF.SettingsHandle!, Table: SettingsDB.SoundTable.rawValue,
                                  Row: Command)
                }
                SomeSound.ResetDirtyFlag()
            }
        }
    }
}
