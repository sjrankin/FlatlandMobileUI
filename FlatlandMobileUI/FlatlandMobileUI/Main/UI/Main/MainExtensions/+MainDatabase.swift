//
//  +MainDatabase.swift
//  Flatland
//
//  Created by Stuart Rankin on 10/6/20. Adapted from Flatland View.
//  Copyright © 2020, 2021 Stuart Rankin. All rights reserved.
//

import Foundation
import UIKit
import SQLite3

extension MainController
{
    /// Initialize the mappable item database. Mappable items are locations (or things) that can be mapped onto
    /// Flatland.
    /// - Note: This function only initializes access to the database. *It does not load the data.*
    ///   - Call `GetAllWorldHeritageSites` to load all World Heritage Sites.
    /// - Warning: Fatal errors are generated if:
    ///   - The URL of the mappable database is returned as nil.
    ///   - SQLite returns an error when attempting to open the mappable database.
    public static func InitializeMappableDatabase()
    {
        /*
        if MappableInitialized
        {
            return
        }
        MappableInitialized = true
        if let MappableURL = FileIO.GetMappableDatabaseURL()
        {
            if sqlite3_open_v2(MappableURL.path, &MainController.MappableHandle,
                               SQLITE_OPEN_READWRITE | SQLITE_OPEN_FULLMUTEX | SQLITE_OPEN_CREATE, nil) != SQLITE_OK
            {
                fatalError("Error opening \(MappableURL.path), \(String(cString: sqlite3_errmsg(MainController.MappableHandle!)))")
            }
        }
        else
        {
            fatalError("Error getting URL for the mappable database.")
        }
        
        #if false
        AssignSiteIDs()
        #endif
        #if false
        let AllCities = CitiesData.RawCityList
        MoveCities(Cities: AllCities)
        fatalError("All cities moved.")
        #endif
        */
    }
    
    /// Initialize the POI item database.
    /// - Note: This function only initializes access to the database. *It does not load the data.*
    /// - Warning: Fatal errors are generated if:
    ///   - The URL of the mappable database is returned as nil.
    ///   - SQLite returns an error when attempting to open the POI database.
    public static func InitializePOIDatabase()
    {
        if POIInitialized
        {
            return
        }
        POIInitialized = true
        if let POIURL = FileIO.GetPOIDatabaseURL()
        {
            if sqlite3_open_v2(POIURL.path, &MainController.POIHandle,
                               SQLITE_OPEN_READWRITE | SQLITE_OPEN_FULLMUTEX | SQLITE_OPEN_CREATE, nil) != SQLITE_OK
            {
                fatalError("Error opening \(POIURL.path), \(String(cString: sqlite3_errmsg(MainController.POIHandle!)))")
            }
        }
        else
        {
            fatalError("Error getting URL for the POI database.")
        }
        UserPOIs = GetAllUserPOIs()
        UserHomes = GetAllHomes()
        BuiltInPOIs = GetAllBuiltInPOIs()
    }
    
    /// Set up a query in to the database.
    /// - Parameter DB: The handle of the database for the query.
    /// - Parameter Query: The query string.
    /// - Returns: Handle for the query. Valid only for the same database the query was generated for.
    static func SetupQuery(DB: OpaquePointer?, Query: String) -> OpaquePointer?
    {
        if DB == nil
        {
            return nil
        }
        if Query.isEmpty
        {
            return nil
        }
        var QueryHandle: OpaquePointer? = nil
        if sqlite3_prepare(DB, Query, -1, &QueryHandle, nil) != SQLITE_OK
        {
            let LastSQLErrorMessage = String(cString: sqlite3_errmsg(DB))
            print("Error preparing query \"\(Query)\": \(LastSQLErrorMessage)")
            return nil
        }
        return QueryHandle
    }
    
    /// Remove apostrophe ("`'`") characters from the passed string.
    /// - Parameter From: The string from which apostrophes will be removed.
    /// - Returns: String wil all apostrophes removed.
    public static func RemoveApostrophes(From: String) -> String
    {
        var Working = From
        let Forbidden: Set<Character> = ["'"]
        Working.removeAll(where: {Forbidden.contains($0)})
        return Working
    }
    
    /// Add the SQLite escape character to characters that need to be escaped.
    /// - Parameter To: The string which will be escaped.
    /// - Returns: New string with proper escaping.
    public static func AddEscapes(To: String) -> String
    {
        var NewString = ""
        if To.contains("'")
        {
            for Char in To
            {
                if Char == String.Element("'")
                {
                    NewString.append("\\")
                    NewString.append(Char)
                }
                else
                {
                    NewString.append(Char)
                }
            }
        }
        else
        {
            return To
        }
        return NewString
    }
    
    /// Creates a Sqlite column list.
    /// - Parameter Names: Names to add to the list.
    /// - Returns: String in the format `({name1}, {name2}...)`.
    public static func MakeColumnList(_ Names: [String]) -> String
    {
        var List = "("
        for Index in 0 ..< Names.count
        {
            List.append(Names[Index])
            if Index < Names.count - 1
            {
                List.append(", ")
            }
        }
        List.append(")")
        return List
    }
    
    /// Returns the extended error code and message from the passed pointer.
    /// - Parameter From: The database pointer where an error occurred.
    /// - Returns: Tuple with the message and error code.
    public static func ExtendedError(From: OpaquePointer?) -> (String, Int32)
    {
        let ExErrorCode = sqlite3_extended_errcode(From)
        let CMessage = sqlite3_errmsg(From)
        let Message = String(cString: CMessage!)
        return (Message, ExErrorCode)
    } 
    
    /// Read an integer from a SQLite table.
    /// - Parameter Handle: The prepared query handle for the table.
    /// - Parameter Index: The column index of the integer value to read.
    /// - Returns: Integer value at the specific column. Nil on error.
    public static func ReadIntColumn(Handle: OpaquePointer?, Index: Int32) -> Int?
    {
        let Value = Int(sqlite3_column_int(Handle, Index))
        return Value
    }
    
    /// Read an integer from a SQLite table.
    /// - Parameter Handle: The prepared query handle for the table.
    /// - Parameter Index: The column index of the integer value to read.
    /// - Parameter Default: Default value to return on error. Defaults to `0`.
    /// - Returns: Integer value at the specific column.
    public static func ReadIntColumn(Handle: OpaquePointer?, Index: Int32, Default: Int = 0) -> Int
    {
        let Value = Int(sqlite3_column_int(Handle, Index))
        return Value
    }
    
    /// Read a double from a SQLite table.
    /// - Parameter Handle: The prepared query handle for the table.
    /// - Parameter Index: The column index of the double value to read.
    /// - Returns: Double value at the specific column. Nil on error.
    public static func ReadDoubleColumn(Handle: OpaquePointer?, Index: Int32) -> Double?
    {
        let Value = sqlite3_column_double(Handle, Index)
        return Value
    }
    
    /// Read a double from a SQLite table.
    /// - Parameter Handle: The prepared query handle for the table.
    /// - Parameter Index: The column index of the double value to read.
    /// - Parameter Default: Default value to return on error. Defaults to `0.0`.
    /// - Returns: Double value at the specific column.
    public static func ReadDoubleColumn(Handle: OpaquePointer?, Index: Int32, Default: Double = 0.0) -> Double
    {
        let Value = sqlite3_column_double(Handle, Index)
        return Value
    }
    
    /// Read a boolean from a SQLite table.
    /// - Note: Booleans are stored as integers. A value of `0` is false and any other value is true.
    /// - Parameter Handle: The prepared query handle for the table.
    /// - Parameter Index: The column index of the boolean value to read.
    /// - Returns: Double value at the specific boolean. Nil on error.
    public static func ReadBoolColumn(Handle: OpaquePointer?, Index: Int32) -> Bool?
    {
        let Value = Int(sqlite3_column_int(Handle, Index))
        return Value > 0 ? true : false
    }
    
    /// Read a boolean from a SQLite table.
    /// - Note: Booleans are stored as integers. A value of `0` is false and any other value is true.
    /// - Parameter Handle: The prepared query handle for the table.
    /// - Parameter Index: The column index of the boolean value to read.
    /// - Parameter Default: Default value to return on error. Defaults to `true`.
    /// - Returns: Double value at the specific boolean.
    public static func ReadBoolColumn(Handle: OpaquePointer?, Index: Int32, Default: Bool = true) -> Bool
    {
        let Value = Int(sqlite3_column_int(Handle, Index))
        return Value > 0 ? true : false
    }
    
    /// Read a string from a SQLite table.
    /// - Parameter Handle: The prepared query handle for the table.
    /// - Parameter Index: The column index of the string value to read.
    /// - Returns: String value at the specific column. Nil on error.
    public static func ReadStringColumn(Handle: OpaquePointer?, Index: Int32) -> String?
    {
        var Value = ""
        if let ColumnValue = sqlite3_column_text(Handle, Index)
        {
            Value = String(cString: ColumnValue)
            return Value
        }
        return nil
    }
    
    /// Read a string from a SQLite table.
    /// - Parameter Handle: The prepared query handle for the table.
    /// - Parameter Index: The column index of the string value to read.
    /// - Parameter Default: The default value to return on error.
    /// - Returns: String value at the specific column. Nil on error.
    public static func ReadStringColumn(Handle: OpaquePointer?, Index: Int32, Default: String = "") -> String
    {
        var Value = ""
        if let ColumnValue = sqlite3_column_text(Handle, Index)
        {
            Value = String(cString: ColumnValue)
            return Value
        }
        return Default
    }
    
    /// Read a UUID from a SQLite table.
    /// - Note: UUIDs are stored as strings.
    /// - Parameter Handle: The prepared query handle for the table.
    /// - Parameter Index: The column index of the UUID value to read.
    /// - Returns: UUID value at the specific column. Nil on error.
    public static func ReadUUIDColumn(Handle: OpaquePointer?, Index: Int32) -> UUID?
    {
        var Value = ""
        if let ColumnValue = sqlite3_column_text(Handle, Index)
        {
            Value = String(cString: ColumnValue)
            if let UValue = UUID(uuidString: Value)
            {
                return UValue
            }
        }
        return nil
    }
    
    /// Read a UUID from a SQLite table.
    /// - Note: UUIDs are stored as strings.
    /// - Parameter Handle: The prepared query handle for the table.
    /// - Parameter Index: The column index of the UUID value to read.
    /// - Parameter Default: The default value to return on error.
    /// - Returns: UUID value at the specific column.
    public static func ReadUUIDColumn(Handle: OpaquePointer?, Index: Int32, Default: UUID = UUID()) -> UUID
    {
        var Value = ""
        if let ColumnValue = sqlite3_column_text(Handle, Index)
        {
            Value = String(cString: ColumnValue)
            if let UValue = UUID(uuidString: Value)
            {
                return UValue
            }
        }
        return Default
    }
    
    /// Read a date from a SQLite table.
    /// - Note: Dates are stored as strings.
    /// - Parameter Handle: The prepared query handle for the table.
    /// - Parameter Index: The column index of the date value to read.
    /// - Returns: Date value at the specific column. Nil on error.
    public static func ReadDateColumn(Handle: OpaquePointer?, Index: Int32) -> Date?
    {
        var Value = ""
        if let ColumnValue = sqlite3_column_text(Handle, Index)
        {
            Value = String(cString: ColumnValue)
            if let Final = Date.PrettyDateToDate(Value)
            {
                return Final
            }
        }
        return nil
    }
    
    /// Read a date from a SQLite table.
    /// - Note: Dates are stored as strings.
    /// - Parameter Handle: The prepared query handle for the table.
    /// - Parameter Index: The column index of the date value to read.
    /// - Parameter Default: The default value to return on error.
    /// - Returns: Date value at the specific column.
    public static func ReadDateColumn(Handle: OpaquePointer?, Index: Int32, Default: Date = Date()) -> Date
    {
        var Value = ""
        if let ColumnValue = sqlite3_column_text(Handle, Index)
        {
            Value = String(cString: ColumnValue)
            if let Final = Date.PrettyDateToDate(Value)
            {
                return Final
            }
        }
        return Default
    }
    
    /// Read a color from a SQLite table.
    /// - Note: Colors are stored as strings.
    /// - Parameter Handle: The prepared query handle for the table.
    /// - Parameter Index: The column index of the color value to read.
    /// - Returns: Color value at the specific column. Nil on error.
    public static func ReadColorColumn(Handle: OpaquePointer?, Index: Int32) -> UIColor?
    {
        var Value = ""
        if let ColumnValue = sqlite3_column_text(Handle, Index)
        {
            Value = String(cString: ColumnValue)
            if let Final = UIColor(HexString: Value)
            {
                return Final
            }
        }
        return nil
    }
    
    /// Read a color from a SQLite table.
    /// - Note: Colors are stored as strings.
    /// - Parameter Handle: The prepared query handle for the table.
    /// - Parameter Index: The column index of the color value to read.
    /// - Parameter Default: The default value to return on error. Defaults to `UIColor.gray`.
    /// - Returns: Color value at the specific column.
    public static func ReadColorColumn(Handle: OpaquePointer?, Index: Int32, Default: UIColor = UIColor.gray) -> UIColor
    {
        var Value = ""
        if let ColumnValue = sqlite3_column_text(Handle, Index)
        {
            Value = String(cString: ColumnValue)
            if let Final = UIColor(HexString: Value)
            {
                return Final
            }
        }
        return Default
    }
}

/// Database errors.
enum DatabaseErrors: String, CaseIterable, Error
{
    /// No URL for database found.
    case NoURL = "No URL"
    /// No error - success case.
    case Success = "Success"
    /// Specified table is invalid.
    case InvalidTable = "Invalid Table"
    /// Error when preparing a query.
    case QueryPreparationError = "Query Preparation Error"
    /// Error when preparing an insertion.
    case InsertPreparationError = "Insert Preparation Error"
    /// Invalid column type specified.
    case InvalidColumnType = "Invalid Column Type"
    /// Data conversion error.
    case ConversionError = "Conversion Error"
}

