//
//  ActualMap.swift
//  ActualMap
//
//  Created by Stuart Rankin on 7/19/21. Adapted from Flatland View.
//

import Foundation
import UIKit

/// Contains information about an actual map on the file system.
class ActualMap: CustomStringConvertible
{
    /// Get the dirty flag - if this property is true, someone set a property that needs to be saved.
    private(set) public var IsDirty = false
    
    /// Initialize a map.
    /// - Parameters:
    ///   - Title: Title of the map (for users).
    ///   - ID: ID of the map.
    ///   - Global: Directory path for the global (3D) map.
    ///   - North: Directory path for the north-centered 2D map.
    ///   - South: Directory path for the south-centered 2D map.
    init(_ Title: String, _ ID: UUID, _ Global: String, _ North: String, _ South: String)
    {
        self.Title = Title
        self.ID = ID
        self.GlobalPath = Global
        self.NorthPath = North
        self.SouthPath = South
        IsDirty = false
    }
    
    /// Get or set the title (for users) of the map.
    public var Title: String = ""
    {
        didSet
        {
            IsDirty = true
        }
    }
    
    /// Set the map title. The dirty flag is immediately reset.
    /// - Parameter NewPath: New map title.
    public func SetTitle(_ NewTitle: String)
    {
        Title = NewTitle
        IsDirty = false
    }
    
    /// Get or set the ID of the map (not intended for user consumption).
    public var ID: UUID = UUID()
    {
        didSet
        {
            IsDirty = true
        }
    }
    
    /// Set the map ID. The dirty flag is immediately reset.
    /// - Parameter NewPath: New ID.
    public func SetID(_ NewID: UUID)
    {
        ID = NewID
        IsDirty = false
    }
    
    /// Get or set the file path for the 3D map.
    public var GlobalPath: String = ""
    {
        didSet
        {
            IsDirty = true
        }
    }
    
    /// Set the global map image path. The dirty flag is immediately reset.
    /// - Parameter NewPath: New file path.
    public func SetGlobalPath(_ NewPath: String)
    {
        GlobalPath = NewPath
        IsDirty = false
    }
    
    /// Get or set the file path for the north-centered 2D map.
    public var NorthPath: String = ""
    {
        didSet
        {
            IsDirty = true
        }
    }
    
    /// Set the north-centered map image path. The dirty flag is immediately reset.
    /// - Parameter NewPath: New file path.
    public func SetNorthPath(_ NewPath: String)
    {
        NorthPath = NewPath
        IsDirty = false
    }
    
    /// Get or set the file path for the south-centered 2D map.
    public var SouthPath: String = ""
    {
        didSet
        {
            IsDirty = true
        }
    }
    
    /// Set the south-centered map image path. The dirty flag is immediately reset.
    /// - Parameter NewPath: New file path.
    public func SetSouthPath(_ NewPath: String)
    {
        SouthPath = NewPath
        IsDirty = false
    }
    
    /// Returns a run-time description of the contents of `ActualMap`.
    var description: String
    {
        get
        {
            var MapData = "    \(Title), \(ID.uuidString)\n"
            MapData.append("      Global: [\(GlobalPath)]\n")
            MapData.append("      North: [\(NorthPath)]\n")
            MapData.append("      South: [\(SouthPath)]\n")
            return MapData
        }
    }
    
    /// Return the contents of the run-time class as an XML fragment.
    func AsXML(_ Indent: Int = 8) -> String
    {
        var XString = String(repeating: " ", count: Indent)
        XString.append("<Map ")
        XString.append("Name=\"\(Title)\" ")
        XString.append("ID=\"\(ID.uuidString)\" ")
        XString.append("Global=\"\(GlobalPath)\" ")
        XString.append("North=\"\(NorthPath)\" ")
        XString.append("South=\"\(SouthPath)\"")
        XString.append("/>")
        return XString
    }
}
