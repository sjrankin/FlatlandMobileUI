//
//  ActualMapIO.swift
//  ActualMapIO
//
//  Created by Stuart Rankin on 7/19/21.
//

import Foundation
import UIKit

/// I/O and processing of stored map list files.
class ActualMapIO
{
    #if false
    /// Load the map list file from mass storage, parse it, and return it.
    /// - Returns: A map list with paths for image files. Nil on error.
    public static func LoadMapList() -> ActualMapList?
    {
        if let Raw = FileIO.GetMapStructure()
        {
            return ParseRaw(XML: Raw)
        }
        return nil
    }
    
    /// Save the passed map list.
    /// - Parameter MapData: The map list to save. If this structure is not dirty, it is not saved.
    public static func SaveMapList(_ MapData: ActualMapList)
    {
        if MapData.IsDirty
        {
            var XSave = "<?xml version=\"1.0\" encoding=\"UTF-8\"?>\n"
            XSave.append(MapData.AsXML(0))
            FileIO.SetMapStructure(XSave)
        }
        else
        {
            print("Map data not saved - not dirty.")
        }
    }
    
    /// Parse the passed raw XML string into an `ActualMapList`.
    /// - Parameter XML: The XML string to parse. Assumed to have been read from the Maps.xml file.
    /// - Returns: An instance of an `ActualMapList` on success, nil on failure.
    public static func ParseRaw(XML: String) -> ActualMapList?
    {
        do
        {
            let XDoc = try XMLDocument(xmlString: XML, options: [])
            if let AllMaps = CreateMapList(XDoc.children)
            {
                return AllMaps
            }
            return nil
        }
        catch
        {
            print("Error reading XML data: \(error)")
            return nil
        }
    }
    
    /// Wolds the working map list.
    private static var MapList: ActualMapList? = nil
    
    /// Create the actual map list from a set of `XMLNode`s.
    /// - Parameter FromNodes: Array of `XMLNode`s to parse to create the map list. If nil, no
    ///                        processing is done and nil is returned.
    /// - Returns: An instance of an `ActualMapList` on success, nil on failure or no nodes to process.
    static func CreateMapList(_ FromNodes: [XMLNode]?) -> ActualMapList?
    {
        var Title = ""
        var ID = UUID()
        if let Nodes = FromNodes
        {
            for Child in Nodes
            {
                if let AsElement = Child as? XMLElement
                {
                    if let NodeTitle = AsElement.attribute(forName: "Title")
                    {
                        if let NodeTitleValue = NodeTitle.objectValue as? String
                        {
                            Title = NodeTitleValue
                        }
                    }
                    if let NodeID = AsElement.attribute(forName: "ID")
                    {
                        if let NodeIDValue = NodeID.objectValue as? String
                        {
                            ID = UUID(uuidString: NodeIDValue)!
                        }
                    }
                }
                if let ChildName = Child.name
                {
                    for SomeType in TreeNodeTypes.allCases
                    {
                        if SomeType.rawValue == ChildName
                        {
                            MapList = ActualMapList(Title, ID, [ActualMapGroup]())
                            EnumerateChildren(Child.children)
                        }
                    }
                }
            }
        }
        else
        {
            return nil
        }
        return MapList
    }
    
    /// Holds the working group.
    private static var CurrentGroup: ActualMapGroup? = nil
    
    /// Enumerate the children if the passed set of nodes.
    /// - Parameter Children: The set of nodes to enumerate. If nil, no action is taken.
    static func EnumerateChildren(_ Children: [XMLNode]?)
    {
        if let AllChildren = Children
        {
            for Child in AllChildren
            {
                EnumerateChild(Child)
            }
        }
    }
    
    /// Process a node then enumerate its children.
    /// - Parameter Child: The node to process.
    static func EnumerateChild(_ Child: XMLNode)
    {
        if let NodeType = Child.name
        {
            switch NodeType
            {
                case "Map":
                    if CurrentGroup == nil
                    {
                        fatalError("Missing group.")
                    }
                    let SomeMap = ActualMap("", UUID(), "", "", "")
                    if let AsElement = Child as? XMLElement
                    {
                        if let MapName = AsElement.attribute(forName: "Name")
                        {
                            if let MapNameValue = MapName.objectValue as? String
                            {
                                SomeMap.SetTitle(MapNameValue)
                            }
                        }
                        if let MapID = AsElement.attribute(forName: "ID")
                        {
                            if let MapIDValue = MapID.objectValue as? String
                            {
                                SomeMap.SetID(UUID(uuidString: MapIDValue)!)
                            }
                        }
                        if let Global = AsElement.attribute(forName: "Global")
                        {
                            if let GlobalValue = Global.objectValue as? String
                            {
                                SomeMap.SetGlobalPath(GlobalValue)
                            }
                        }
                        if let North = AsElement.attribute(forName: "North")
                        {
                            if let NorthValue = North.objectValue as? String
                            {
                                SomeMap.SetNorthPath(NorthValue)
                            }
                        }
                        if let South = AsElement.attribute(forName: "South")
                        {
                            if let SouthValue = South.objectValue as? String
                            {
                                SomeMap.SetSouthPath(SouthValue)
                            }
                        }
                        CurrentGroup?.AddMap(SomeMap)
                    }
                    
                case "GroupList":
#if false
                    if CurrentGroup != nil
                    {
                        MapList?.MapGroupList.append(CurrentGroup!)
                    }
#endif
                    CurrentGroup = ActualMapGroup("", [ActualMap](), UUID())
                    MapList?.MapGroupList.append(CurrentGroup!)
                    if let AsElement = Child as? XMLElement
                    {
                        if let GroupID = AsElement.attribute(forName: "ID")
                        {
                            if let GroupIDValue = GroupID.objectValue as? String
                            {
                                CurrentGroup?.SetID(UUID(uuidString: GroupIDValue)!)
                            }
                        }
                        if let GroupName = AsElement.attribute(forName: "Name")
                        {
                            if let GroupNameValue = GroupName.objectValue as? String
                            {
                                CurrentGroup?.SetGroupName(GroupNameValue)
                            }
                        }
                    }
                    
                default:
                    fatalError("Encountered unexpected node type \(NodeType) in Maps.xml.")
            }
        }
        EnumerateChildren(Child.children)
    }
    #endif
}

enum TreeNodeTypes: String, CaseIterable
{
    case Maps = "Maps"
    case GroupList = "GroupList"
    case Map = "Map"
}
