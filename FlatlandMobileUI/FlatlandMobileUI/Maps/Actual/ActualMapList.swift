//
//  ActualMapList.swift
//  ActualMapList
//
//  Created by Stuart Rankin on 7/19/21.
//

import Foundation
import UIKit

/// Holds all map information on the user's system.
class ActualMapList: CustomStringConvertible
{
    /// Initialize the map list.
    /// - Parameters:
    ///   - Title: The title of the map list.
    ///   - ID: The ID of the map list.
    ///   - Groups: List of all map groups.
    init(_ Title: String, _ ID: UUID, _ Groups: [ActualMapGroup])
    {
        self.Title = Title
        self.ID = ID
        self.MapGroupList = Groups
        _IsDirty = false
    }
    
    /// Holds the dirty flag.
    private var _IsDirty = false
    /// Get the dirty flag. Any object that was changed will result in `true` being returned.
    public var IsDirty: Bool
    {
        get
        {
            if _IsDirty
            {
                return true
            }
            for Group in MapGroupList
            {
                if Group.IsDirty
                {
                    return true
                }
            }
            return false
        }
    }
    
    /// Get or set the list of map groups.
    public var MapGroupList = [ActualMapGroup]()
    {
        didSet
        {
            _IsDirty = true
        }
    }
    
    /// Get or set the user-visible title for the map list.
    public var Title = ""
    {
        didSet
        {
            _IsDirty = true
        }
    }
    
    /// Get or set the ID of the map list.
    public var ID = UUID()
    {
        didSet
        {
            _IsDirty = true
        }
    }
    
    var description: String
    {
        get
        {
            var Top = "\(Title), \(ID.uuidString)\n"
            for Group in MapGroupList
            {
                Top.append("\(Group)\n")
            }
            return Top
        }
    }
    
    func AsXML(_ Indent: Int) -> String
    {
        var XString = "<Maps "
        XString.append("Title=\"\(Title)\" ")
        XString.append("ID=\"\(ID.uuidString)>\n")
        
        for Group in MapGroupList
        {
            XString.append(Group.AsXML(2))
        }
        
        XString.append("</Maps>\n")
        return XString
    }
}
