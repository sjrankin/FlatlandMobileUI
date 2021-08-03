//
//  +HistoricEarthquakes.swift
//  +HistoricEarthquakes
//
//  Created by Stuart Rankin on 7/19/21. Adapted from Flatland View.
//

import Foundation
import UIKit
import SQLite3

// MARK: - Historic earthquake database handling.

extension DBIF
{
    /// Get historic earthquakes by date range.
    /// - Parameter Start: The starting date for the range of earthquakes to return.
    /// - Parameter End: The ending date for the range of earthquakes to return.
    /// - Returns: Array of earthquakes from the specified range. May be empty if nothing found.
    public static func GetEarthquakesInRange(Start: Date, End: Date) -> [Earthquake]
    {
        let StartSeconds = Start.timeIntervalSince1970
        let EndSeconds = End.timeIntervalSince1970
        return GetEarthquakesInRange(Start: StartSeconds, End: EndSeconds)
    }
    
    /// Get historic earthquakes by date range.
    /// - Parameter Start: The starting date for the range of earthquakes to return. The starting date is
    ///                    defined as the number of seconds since 1970.
    /// - Parameter End: The ending date for the range of earthquakes to return. The ending date is
    ///                  defined as the number of seconds since 1970.
    /// - Returns: Array of earthquakes from the specified range. May be empty if nothing found.
    public static func GetEarthquakesInRange(Start: Double, End: Double) -> [Earthquake]
    {
        var Results = [Earthquake]()
        let WherePhrase = "WHERE Time BETWEEN \(Start) AND \(End)"
        let GetQuery = "SELECT * FROM \(QuakeTableNames.Historic.rawValue) \(WherePhrase)"
        var QueryHandle: OpaquePointer? = nil
        let QuerySetupResult = SQL.SetupQuery(For: DBIF.QuakeHandle, Query: GetQuery)
        switch QuerySetupResult
        {
            case .success(let Handle):
                QueryHandle = Handle
                
            case .failure(let Why):
                Debug.Print("Failure creating query \(GetQuery) for historic earthquakes: \(Why)")
                let (Message, Value) = SQL.ExtendedError(From: DBIF.QuakeHandle)
                Debug.Print("  \(Message) [\(Value)]")
                return [Earthquake]()
        }
        
        while (sqlite3_step(QueryHandle) == SQLITE_ROW)
        {
            let PKID = SQL.ReadIntColumn(Handle: QueryHandle, Index: QuakeColumns.PKID.rawValue)!
            let Latitude = SQL.ReadDoubleColumn(Handle: QueryHandle, Index: QuakeColumns.Latitude.rawValue)!
            let Longitude = SQL.ReadDoubleColumn(Handle: QueryHandle, Index: QuakeColumns.Longitude.rawValue)!
            let Place = SQL.ReadStringColumn(Handle: QueryHandle, Index: QuakeColumns.Place.rawValue)!
            let Magnitude = SQL.ReadDoubleColumn(Handle: QueryHandle, Index: QuakeColumns.Magnitude.rawValue)!
            let Depth = SQL.ReadDoubleColumn(Handle: QueryHandle, Index: QuakeColumns.Depth.rawValue)!
            let Time = SQL.ReadDoubleColumn(Handle: QueryHandle, Index: QuakeColumns.Time.rawValue)!
            let Updated = SQL.ReadDoubleColumn(Handle: QueryHandle, Index: QuakeColumns.Updated.rawValue)!
            let Code = SQL.ReadStringColumn(Handle: QueryHandle, Index: QuakeColumns.Code.rawValue)!
            let Tsunami = SQL.ReadIntColumn(Handle: QueryHandle, Index: QuakeColumns.Tsunami.rawValue)!
            let Status = SQL.ReadStringColumn(Handle: QueryHandle, Index: QuakeColumns.Status.rawValue)!
            let MMI = SQL.ReadDoubleColumn(Handle: QueryHandle, Index: QuakeColumns.MMI.rawValue)!
            let Felt = SQL.ReadIntColumn(Handle: QueryHandle, Index: QuakeColumns.Felt.rawValue)!
            let Significance = SQL.ReadIntColumn(Handle: QueryHandle, Index: QuakeColumns.Significance.rawValue)!
            let Sequence = SQL.ReadIntColumn(Handle: QueryHandle, Index: QuakeColumns.Sequence.rawValue)!
            let Notified = SQL.ReadIntColumn(Handle: QueryHandle, Index: QuakeColumns.Notified.rawValue)!
            let Region = SQL.ReadStringColumn(Handle: QueryHandle, Index: QuakeColumns.RegionName.rawValue)!
            let Marked = SQL.ReadIntColumn(Handle: QueryHandle, Index: QuakeColumns.Marked.rawValue)!
            let MagType = SQL.ReadStringColumn(Handle: QueryHandle, Index: QuakeColumns.MagType.rawValue)!
            let MagError = SQL.ReadDoubleColumn(Handle: QueryHandle, Index: QuakeColumns.MagError.rawValue)!
            let MagNST = SQL.ReadIntColumn(Handle: QueryHandle, Index: QuakeColumns.MagNST.rawValue)!
            let DMin = SQL.ReadDoubleColumn(Handle: QueryHandle, Index: QuakeColumns.DMin.rawValue)!
            let Alert = SQL.ReadStringColumn(Handle: QueryHandle, Index: QuakeColumns.Alert.rawValue)!
            let Title = SQL.ReadStringColumn(Handle: QueryHandle, Index: QuakeColumns.Title.rawValue)!
            let Types = SQL.ReadStringColumn(Handle: QueryHandle, Index: QuakeColumns.Types.rawValue)!
            let EventType = SQL.ReadStringColumn(Handle: QueryHandle, Index: QuakeColumns.EventType.rawValue)!
            let Detail = SQL.ReadStringColumn(Handle: QueryHandle, Index: QuakeColumns.Detail.rawValue)!
            let TZ = SQL.ReadIntColumn(Handle: QueryHandle, Index: QuakeColumns.TZ.rawValue)!
            let EventPageURL = SQL.ReadStringColumn(Handle: QueryHandle, Index: QuakeColumns.EventPageURL.rawValue)!
            let Sources = SQL.ReadStringColumn(Handle: QueryHandle, Index: QuakeColumns.Sources.rawValue)!
            let Net = SQL.ReadStringColumn(Handle: QueryHandle, Index: QuakeColumns.Net.rawValue)!
            let NST = SQL.ReadIntColumn(Handle: QueryHandle, Index: QuakeColumns.NST.rawValue)!
            let Gap = SQL.ReadDoubleColumn(Handle: QueryHandle, Index: QuakeColumns.Gap.rawValue)!
            let IDs = SQL.ReadStringColumn(Handle: QueryHandle, Index: QuakeColumns.IDs.rawValue)!
            let HorizontalError = SQL.ReadDoubleColumn(Handle: QueryHandle, Index: QuakeColumns.HorizontalError.rawValue)!
            let CDI = SQL.ReadDoubleColumn(Handle: QueryHandle, Index: QuakeColumns.CDI.rawValue)!
            let RMS = SQL.ReadDoubleColumn(Handle: QueryHandle, Index: QuakeColumns.RMS.rawValue)!
            let NPH = SQL.ReadStringColumn(Handle: QueryHandle, Index: QuakeColumns.NPH.rawValue)!
            let LocationSource = SQL.ReadStringColumn(Handle: QueryHandle, Index: QuakeColumns.LocationSource.rawValue)!
            let MagSource = SQL.ReadStringColumn(Handle: QueryHandle, Index: QuakeColumns.MagSource.rawValue)!
            let ContextDistance = SQL.ReadDoubleColumn(Handle: QueryHandle, Index: QuakeColumns.ContextDistance.rawValue)!
            let DebugQuake = SQL.ReadIntColumn(Handle: QueryHandle, Index: QuakeColumns.DebugQuake.rawValue)!
            //let QuakeDate = SQL.ReadStringColumn(Handle: QueryHandle, Index: QuakeColumns.QuakeDate.rawValue, Default: "")
            let QuakeID = SQL.ReadUUIDColumn(Handle: QueryHandle, Index: QuakeColumns.QuakeID.rawValue, Default: UUID.Empty)
            let EventID = SQL.ReadStringColumn(Handle: QueryHandle, Index: QuakeColumns.EventID.rawValue)!
            
            let HQuake = Earthquake(PKID)
            HQuake.Latitude = Latitude
            HQuake.Longitude = Longitude
            HQuake.Place = Place
            HQuake.Magnitude = Magnitude
            HQuake.Depth = Depth
            HQuake.Time = Date(timeIntervalSince1970: Time)
            HQuake.Updated = Date(timeIntervalSince1970: Updated)
            HQuake.Code = Code
            HQuake.Tsunami = Tsunami
            HQuake.Status = Status
            HQuake.MMI = MMI
            HQuake.Felt = Felt
            HQuake.Significance = Significance
            HQuake.Sequence = Sequence
            HQuake.Notified = Notified == 0 ? false : true
            HQuake.RegionName = Region
            HQuake.Marked = Marked == 0 ? false : true
            HQuake.MagType = MagType
            HQuake.MagError = MagError
            HQuake.MagNST = MagNST
            HQuake.DMin = DMin
            HQuake.Alert = Alert
            HQuake.Title = Title
            HQuake.Types = Types
            HQuake.EventType = EventType
            HQuake.Detail = Detail
            HQuake.TZ = TZ
            HQuake.EventPageURL = EventPageURL
            HQuake.Sources = Sources
            HQuake.Net = Net
            HQuake.NST = NST
            HQuake.Gap = Gap
            HQuake.IDs = IDs
            HQuake.HorizontalError = HorizontalError
            HQuake.CDI = CDI
            HQuake.RMS = RMS
            HQuake.NPH = NPH
            HQuake.LocationSource = LocationSource
            HQuake.MagSource = MagSource
            HQuake.ContextDistance = ContextDistance
            HQuake.DebugQuake = DebugQuake == 0 ? false : true
            HQuake.QuakeID = QuakeID
            HQuake.EventID = EventID
            
            Results.append(HQuake)
        }
        
        return Results
    }
    
    /// Creates a list of columns of earthquake data for storage or retrieval.
    /// - Returns: List of column names in the earthquake database, comma separated and encapsulated
    ///            in parentheses.
    public static func MakeQuakeColumnList() -> String
    {
        var Columns = "("
        for Index in 1 ..< Earthquake.QuakeColumnTable.count
        {
            Columns.append(Earthquake.QuakeColumnTable[Index])
            if Index < Earthquake.QuakeColumnTable.count - 1
            {
                Columns.append(",")
            }
        }
        Columns.append(")")
        return Columns
    }
    
    /// Create an insert statement string for an earthquake.
    /// - Parameter From: The earthquake for which an insert statement is created.
    /// - Returns: String to be used as an insert statement for the database.
    public static func MakeInsertStatement(From: Earthquake) -> String
    {
        var Statement = "INSERT INTO \(QuakeTableNames.Historic.rawValue) \(MakeQuakeColumnList()) "
        Statement.append("VALUES \(Earthquake.MakeValueList(From));")
        return Statement
    }
    
    /// Insert the passed earthquake into the historic earthquake database.
    /// - Parameter Quake: The earthquake to insert into the database.
    public static func InsertQuake(_ Quake: Earthquake)
    {
        let InsertStatement = MakeInsertStatement(From: Quake)
        var InsertHandle: OpaquePointer? = nil
        guard sqlite3_prepare_v2(DBIF.QuakeHandle, InsertStatement, -1, &InsertHandle, nil) == SQLITE_OK else
        {
            Debug.Print("Failure with insert statement \(InsertStatement) for historic earthquakes")
            let (Message, Value) = SQL.ExtendedError(From: DBIF.QuakeHandle)
            Debug.Print("  \(Message) [\(Value)]")
            return
        }
        guard sqlite3_step(InsertHandle) == SQLITE_DONE else
        {
            Debug.Print("Insert execution failed: \(InsertStatement) for historic earthquakes")
            let (Message, Value) = SQL.ExtendedError(From: DBIF.QuakeHandle)
            Debug.Print("  \(Message) [\(Value)]")
            return
        }
    }
    
    /// Insert the list of earthquakes into the database.
    /// - Note: Duplicate earthquakes (determined by the value of each earthquake's `Code` property) will not
    ///         be inserted.
    /// - Parameter Quakes: Array of quakes to insert.
    public static func InsertQuakes(_ Quakes: [Earthquake])
    {
        for Quake in Quakes
        {
            InsertQuake(Quake)
        }
    }
    
    /// Determines if an earthquake with the passed code is in the earthquake database.
    /// - Parameter Code: The code to search in the database.
    /// - Returns: True if an earthquake with `Code` is found in the database, false if not.
    public static func QuakeInDatabase(_ Code: String) -> Bool
    {
        let Where = "Code=\"\(Code)\""
        let Result = SQL.RowExists(In: DBIF.QuakeHandle!, Table: QuakeTableNames.Historic.rawValue,
                                   Where: Where)
        switch Result
        {
            case .success(let Exists):
                return Exists
                
            default:
                return false
        }
    }
    
    /// Insert an earthquake into the database.
    /// - Parameter Code: The code of the earthquake. If an earthquake with this code already exists, the
    ///                   passed earthquake will not be inserted.
    /// - Parameter With: The properly formatted Sqlite insert statement with the earthquake data to insert.
    public static func InsertQuake(Code: String, With Statement: String)
    {
        if QuakeInDatabase(Code)
        {
            return
        }
        InsertQuake(WithInsert: Statement)
    }
    
    /// Insert an earthquake into the database.
    /// - Note: Intended to be called only by `InsertQuake(String, String)` and not by anyone else.
    /// - Parameter WithInsert: The properly formatted Sqlite insert statement with the earthquake data to
    ///                         insert. The earthquake is unconditionally inserted.
    private static func InsertQuake(WithInsert Statement: String)
    {
        var InsertHandle: OpaquePointer? = nil
        guard sqlite3_prepare_v2(DBIF.QuakeHandle, Statement, -1, &InsertHandle, nil) == SQLITE_OK else
        {
            Debug.Print("Failure insert statement \(Statement) for historic earthquakes")
            let (Message, Value) = SQL.ExtendedError(From: DBIF.QuakeHandle)
            Debug.Print("  \(Message) [\(Value)]")
            return
        }
        guard sqlite3_step(InsertHandle) == SQLITE_DONE else
        {
            Debug.Print("Insert execution failed: \(Statement) for historic earthquakes")
            let (Message, Value) = SQL.ExtendedError(From: DBIF.QuakeHandle)
            Debug.Print("  \(Message) [\(Value)]")
            return
        }
    }
}

