//
//  SettingsDB.swift
//  SettingsDB
//
//  Created by Stuart Rankin on 7/19/21. Adapted from Flatland View.
//

import Foundation

/// Constants related to the Settings.db Sqlite database.
enum SettingsDB: String, CaseIterable
{
    // MARK: - Table names.
    
    /// Event table name.
    case EventTable = "Events"
    /// Sound table name.
    case SoundTable = "Sounds"
}

enum EventColumns: Int32, CaseIterable
{
    case EventPK = 0
    case Name = 1
    case SoundID = 2
    case SoundMuted = 3
    case Enabled = 4
    case NoSound = 5
}

enum SoundColumns: Int32, CaseIterable
{
    case SoundPK = 0
    case Name = 1
    case IsFile = 2
    case FileName = 3
    case SoundName = 4
    case SoundClass = 5
    case CanDelete = 6
}
