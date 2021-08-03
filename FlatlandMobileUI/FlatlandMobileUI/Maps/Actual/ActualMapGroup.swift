//
//  ActualMapGroup.swift
//  ActualMapGroup
//
//  Created by Stuart Rankin on 7/19/21. Adapted from Flatland View.
//

import Foundation
import UIKit

/// Contains information about a logical group of maps.
class ActualMapGroup: CustomStringConvertible
{
    /// Create a logical group of maps.
    /// - Parameters:
    ///   - Title: Title of the map group (for the user).
    ///   - ListOfMaps: List of map information.
    ///   - ID: ID of the group.
    init(_ Title: String, _ ListOfMaps: [ActualMap]? = nil, _ ID: UUID)
    {
        self.MapGroup = Title
        self.ID = ID
        if let MapList = ListOfMaps
        {
            self.Maps = MapList
        }
        else
        {
            self.Maps = [ActualMap]()
        }
        _IsDirty = false
    }
    
    /// Holds the dirty flag.
    private var _IsDirty = false
    /// Get the dirty flag.
    public var IsDirty: Bool
    {
        get
        {
            if _IsDirty
            {
                return true
            }
            for Actual in Maps
            {
                if Actual.IsDirty
                {
                    return true
                }
            }
            return false
        }
    }
    
    /// Get or set the ID of the map group.
    public var ID: UUID = UUID()
    {
        didSet
        {
            _IsDirty = true
        }
    }
    
    /// Sets the ID and immediately resets the dirty flag.
    /// - Parameter ID: The new ID.
    public func SetID(_ ID: UUID)
    {
        self.ID = ID
        _IsDirty = false
    }
    
    /// Get or set the list of actual map locations and information.
    public var Maps: [ActualMap] = [ActualMap]()
    {
        didSet
        {
            _IsDirty = true
        }
    }
    
    /// Add a map to the list of maps. Immediately resets the dirty flag.
    /// - Parameter NewMap: The new map to add.
    public func AddMap(_ NewMap: ActualMap)
    {
        Maps.append(NewMap)
        _IsDirty = false
    }
    
    /// Get or set the name (visible to the user) fo the map group.
    public var MapGroup: String = ""
    {
        didSet
        {
            _IsDirty = true
        }
    }
    
    /// Sets the group name. Immediately resets the dirty flag.
    /// - Parameter Name: The new group name.
    public func SetGroupName(_ Name: String)
    {
        MapGroup = Name
        _IsDirty = false
    }
    
    var description: String
    {
        get
        {
            var GroupString = "  \(MapGroup), \(ID.uuidString)\n"
            for Map in Maps
            {
                GroupString.append("\(Map)")
            }
            return GroupString
        }
    }
    
    /// Return the contents of the run-time class as an XML fragment.
    func AsXML(_ Indent: Int = 4) -> String
    {
        var XString = String(repeating: " ", count: Indent)
        XString.append("<GroupList ")
        XString.append("Name=\"\(MapGroup)\" ")
        XString.append("ID=\"\(ID.uuidString)\"")
        XString.append(">\n")
        
        for SomeMap in Maps
        {
            XString.append(SomeMap.AsXML(4) + "\n")
        }
        
        XString.append(String(repeating: " ", count: Indent))
        XString.append("</GroupList>\n")
        return XString
    }
}
