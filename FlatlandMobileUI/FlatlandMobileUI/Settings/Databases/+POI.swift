//
//  +POI.swift
//  +POI
//
//  Created by Stuart Rankin on 7/19/21. Adapted from Flatland View.
//

import Foundation
import UIKit
import SQLite3

extension DBIF
{
    // MARK: - Points of interest table handling.
    
    /// Return all user-defined points of interest.
    /// - Returns: Array of user-defined points of interest. May be empty if nothing defined or on error.
    public static func GetAllUserPOIs() -> [POI2]
    {
        var Results = [POI2]()
        if DBIF.MappableHandle == nil
        {
            Debug.Print("Call to \(#function) before database initialized.")
            return Results
        }
        let GetQuery = "SELECT * FROM \(POITableNames.UserPOI.rawValue)"
        let QuerySetupResult = SQL.SetupQuery(For: DBIF.MappableHandle, Query: GetQuery)
        var QueryHandle: OpaquePointer? = nil
        switch QuerySetupResult
        {
            case .success(let Handle):
                QueryHandle = Handle
                
            case .failure(let Why):
                Debug.Print("Failure creating query for user points of interest: \(Why)")
                let (Message, Value) = SQL.ExtendedError(From: DBIF.MappableHandle)
                Debug.Print("  \(Message) [\(Value)]")
                return [POI2]()
        }
        while (sqlite3_step(QueryHandle) == SQLITE_ROW)
        {
            let PKID = SQL.ReadIntColumn(Handle: QueryHandle, Index: POIColumns2.ID.rawValue)!
            let POIID = SQL.ReadUUIDColumn(Handle: QueryHandle, Index: POIColumns2.POIID.rawValue)!
            let Name = SQL.ReadStringColumn(Handle: QueryHandle, Index: POIColumns2.Name.rawValue)!
            let Description = SQL.ReadStringColumn(Handle: QueryHandle, Index: POIColumns2.Description.rawValue, Default: "")
            let Latitude = SQL.ReadDoubleColumn(Handle: QueryHandle, Index: POIColumns2.Latitude.rawValue)!
            let Longitude = SQL.ReadDoubleColumn(Handle: QueryHandle, Index: POIColumns2.Longitude.rawValue)!
            let Color = SQL.ReadColorColumn(Handle: QueryHandle, Index: POIColumns2.Color.rawValue, Default: UIColor.yellow)
            let POIType = SQL.ReadIntColumn(Handle: QueryHandle, Index: POIColumns2.POIType.rawValue)!
            let Numeric = SQL.ReadDoubleColumn(Handle: QueryHandle, Index: POIColumns2.Numeric.rawValue)!
            let Added = SQL.ReadDateColumn(Handle: QueryHandle, Index: POIColumns2.Added.rawValue)
            let Modified = SQL.ReadDateColumn(Handle: QueryHandle, Index: POIColumns2.Added.rawValue)
            let UPOI = POI2(Meta: .User, PKID, POIID, Name, Description, Latitude, Longitude,
                            Color, POIType, Numeric, Added, Modified)
            Results.append(UPOI)
            if PKID > GreatestUserPOIPK
            {
                GreatestUserPOIPK = PKID
            }
        }
        return Results
    }
    
    /// The largest PK found in the user POI table.
    public static var GreatestUserPOIPK: Int = -1
    
    /// Return an unused PK value for inserting into tables.
    public static func GetUnusuedUserPOIPK() -> Int
    {
        GreatestUserPOIPK = GreatestUserPOIPK + 1
        return GreatestUserPOIPK
    }
    
    /// Returns all built-in points of interest.
    /// - Returns: Array of all points of interest.
    public static func GetAllBuiltInPOIs() -> [POI2]
    {
        var Results = [POI2]()
        if DBIF.MappableHandle == nil
        {
            Debug.Print("Call to \(#function) before database initialized.")
            return Results
        }
        let GetQuery = "SELECT * FROM \(POITableNames.POI.rawValue)"
        let QuerySetupResult = SQL.SetupQuery(For: DBIF.MappableHandle, Query: GetQuery)
        var QueryHandle: OpaquePointer? = nil
        switch QuerySetupResult
        {
            case .success(let Handle):
                QueryHandle = Handle
                
            case .failure(let Why):
                let StackTrace = Debug.StackFrameContents(10)
                Debug.Print("\(Debug.PrettyStackTrace(StackTrace))")
                Debug.Print("Failure creating query for built-in points of interest: \(Why)")
                let (Message, Value) = SQL.ExtendedError(From: DBIF.MappableHandle)
                Debug.Print("  \(Message) [\(Value)]")
                return [POI2]()
        }
        while (sqlite3_step(QueryHandle) == SQLITE_ROW)
        {
            let PKID = SQL.ReadIntColumn(Handle: QueryHandle, Index: POIColumns2.ID.rawValue)!
            let POIID = SQL.ReadUUIDColumn(Handle: QueryHandle, Index: POIColumns2.POIID.rawValue)!
            let Name = SQL.ReadStringColumn(Handle: QueryHandle, Index: POIColumns2.Name.rawValue)!
            let Description = SQL.ReadStringColumn(Handle: QueryHandle, Index: POIColumns2.Description.rawValue, Default: "")
            let Latitude = SQL.ReadDoubleColumn(Handle: QueryHandle, Index: POIColumns2.Latitude.rawValue)!
            let Longitude = SQL.ReadDoubleColumn(Handle: QueryHandle, Index: POIColumns2.Longitude.rawValue)!
            let Color = SQL.ReadColorColumn(Handle: QueryHandle, Index: POIColumns2.Color.rawValue, Default: UIColor.yellow)
            let POIType = SQL.ReadIntColumn(Handle: QueryHandle, Index: POIColumns2.POIType.rawValue)!
            let Numeric = SQL.ReadDoubleColumn(Handle: QueryHandle, Index: POIColumns2.Numeric.rawValue)!
            let Added = SQL.ReadDateColumn(Handle: QueryHandle, Index: POIColumns2.Added.rawValue)
            let Modified = SQL.ReadDateColumn(Handle: QueryHandle, Index: POIColumns2.Added.rawValue)
            let UPOI = POI2(Meta: .User, PKID, POIID, Name, Description, Latitude, Longitude,
                            Color, POIType, Numeric, Added, Modified)
            Results.append(UPOI)
        }
        return Results
    }
    
    /// Insert a new POI into the mappable database.
    /// - Parameter POI: The POI to insert.
    /// - Parameter Into: The name of the table.
    public static func InsertPOI(_ POI: POI2, Into Table: String)
    {
        if DBIF.MappableHandle == nil
        {
            Debug.Print("Call to \(#function) before database initialized.")
            return
        }
        let NextPK = GetUnusuedUserPOIPK()
        var InsertStatement = "INSERT INTO \(Table) "
        var Values = "VALUES ("
        var Names = "(ID,"
        Values.append("\(NextPK),")
        Names.append("POIID,")
        Values.append("\"\(POI.ID.uuidString)\",")
        Names.append("Name,")
        Values.append("\"\(POI.Name)\",")
        Names.append("Latitude,")
        Values.append("\(POI.Latitude),")
        Names.append("Longitude,")
        Values.append("\(POI.Longitude),")
        if !POI.Description.isEmpty
        {
            Names.append("Description,")
            Values.append("\"\(POI.Description)\",")
        }
        Names.append("Numeric,")
        Values.append("\(POI.Numeric),")
        Names.append("POIType,")
        Values.append("\(POI.POIType),")
        if let Added = POI.Added
        {
            Names.append("Added,")
            Values.append("\"\(Added.PrettyDate())\",")
        }
        if let Modified = POI.Modified
        {
            Names.append("Modified,")
            Values.append("\"\(Modified.PrettyDate())\",")
        }
        Names.append("Color")
        Values.append("\"\(POI.Color.Hex)\"")
        Names.append(")")
        Values.append(")")
        InsertStatement.append("\(Names) \(Values);")
        var InsertHandle: OpaquePointer? = nil
        guard sqlite3_prepare_v2(DBIF.MappableHandle, InsertStatement, -1, &InsertHandle, nil) == SQLITE_OK else
        {
            Debug.Print("Failure in insert statement preparation: \(InsertStatement)")
            let (Message, Value) = SQL.ExtendedError(From: DBIF.MappableHandle)
            Debug.Print("  \(Message) [\(Value)]")
            return
        }
        guard sqlite3_step(InsertHandle) == SQLITE_DONE else
        {
            Debug.Print("Insert execution failed: \(InsertStatement)")
            let (Message, Value) = SQL.ExtendedError(From: DBIF.MappableHandle)
            Debug.Print("  \(Message) [\(Value)]")
            return
        }
    }
    
    /// Write the array of user POIs to the database.
    /// - Important: After calling this function, the user POI table should be reloaded. See `ReloadTables`.
    /// - Note:
    ///   - POIs that are not dirty are not modified.
    ///   - POIs that are marked as `DeleteMe` are removed.
    ///   - Dirty POIs are updated in place
    /// - Parameter POIs: Array of user POIs to write.
    public static func SetUserPOIs(_ POIs: [POI2])
    {
        for POI in POIs
        {
            if POI.IsDirty
            {
                POI.Saved()
                var Columns = "SET Name=\"\(POI.Name)\","
                Columns.append("Color=\"\(POI.Color.Hex)\",")
                Columns.append("Latitude=\(POI.Latitude),")
                Columns.append("Longitude=\(POI.Longitude)")
                let ForRow = "POIID=\"\(POI.ID)\""
                SQL.UpdateRow(Database: DBIF.MappableHandle!,
                              Table: POITableNames.UserPOI.rawValue,
                              Columns: Columns, Where: ForRow)
                continue
            }
            if POI.DeleteMe
            {
                let DeletePhrase = "POIID=\"\(POI.ID.uuidString)\""
                let Result = SQL.DeleteRow(In: DBIF.MappableHandle!,
                                           Table: POITableNames.UserPOI.rawValue,
                                           DeletePhrase: DeletePhrase)
                switch Result
                {
                    case .failure(let Why):
                        Debug.Print("Error deleting POI \(POI.Name): \(Why)")
                        
                    default:
                        break
                }
                continue
            }
        }
    }
    
    /// Return the user POI for the specified ID.
    /// - Parameter ID: The ID of the user POI the caller wants.
    /// - Returns: The user POI with the specified ID on success, nil if not found.
    public static func UserPOIFor(ID: UUID) -> POI2?
    {
        for SomePOI in UserPOIs
        {
            if SomePOI.ID == ID
            {
                return SomePOI
            }
        }
        return nil
    }
    
    /// Edit an existing user POI.
    /// - Note:
    ///   - Changes will be saved immediately.
    ///   - If the specified ID is not found, no action is taken.
    /// - Parameter ID: The ID of the POI to edit.
    /// - Parameter Name: Name of the user POI.
    /// - Parameter Color: Color for the user POI.
    /// - Parameter Point: Location of the user POI.
    public static func EditUserPOI(ID: UUID, Name: String, Color: UIColor, Point: GeoPoint)
    {
        for SomePOI in UserPOIs
        {
            if SomePOI.ID == ID
            {
                SomePOI.Name = Name
                SomePOI.Color = Color
                SomePOI.Latitude = Point.Latitude
                SomePOI.Longitude = Point.Longitude
                SetUserPOIs(UserPOIs)
                return
            }
        }
    }
    
    /// Delete an existing user POI.
    /// - Note:
    ///   - Changes will be saved immediately.
    ///   - If the ID of the specified user POI is not found, no action is taken.
    /// - Parameter ID: The ID of the user POI to delete.
    public static func DeleteUserPOI(ID: UUID)
    {
        for SomePOI in UserPOIs
        {
            if SomePOI.ID == ID
            {
                SomePOI.DeleteMe = true
                SetUserPOIs(UserPOIs)
                return
            }
        }
        Debug.Print("Could not delete user POI with ID \(ID)")
    }
    
    /// Adds a new user POI.
    /// - Note: The updated user POI list will be saved immediately.
    /// - Parameter Name: Name of the user POI.
    /// - Parameter Color: Color for the user POI.
    /// - Parameter Point: Location of the user POI.
    public static func AddUserPOI(Name: String, Color: UIColor, Point: GeoPoint)
    {
        let NewPOI = POI2()
        NewPOI.MetaType = .User
        NewPOI.Added = Date()
        NewPOI.Category = .none
        NewPOI.Color = Color
        NewPOI.DeleteMe = false
        NewPOI.Description = ""
        NewPOI.ID = UUID()
        NewPOI.IsNew = true
        NewPOI.Latitude = Point.Latitude
        NewPOI.Longitude = Point.Longitude
        NewPOI.Name = Name
        NewPOI.Show = true
        InsertPOI(NewPOI, Into: POITableNames.UserPOI.rawValue)
    }
}

/// Columns for POI tables.
enum POIColumns2: Int32
{
    case ID = 0
    case POIID = 1
    case Name = 2
    case Latitude = 3
    case Longitude = 4
    case Description = 5
    case Numeric = 6
    case POIType = 7
    case Added = 8
    case Modified = 9
    case Color = 10
}
