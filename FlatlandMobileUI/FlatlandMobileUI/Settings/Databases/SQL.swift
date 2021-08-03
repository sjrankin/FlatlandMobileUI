//
//  SQL.swift
//  SQL
//
//  Created by Stuart Rankin on 7/19/21. Adapted from Flatland View.
//

import Foundation
import UIKit
import SQLite3

/// Utility class to make using SQLite3 more Swift-like.
class SQL
{
    /// Setup a query to access a database.
    /// - Parameter For: The database handle to the database to query.
    /// - Parameter Query: The query string.
    /// - Returns: Result for the operation. On success, the query's handle (non-optional) is returned.
    public static func SetupQuery(For Database: OpaquePointer?, Query: String) -> Result<OpaquePointer, DatabaseOperationResult>
    {
        if Database == nil
        {
            return .failure(.NilDatabase)
        }
        if Query.isEmpty
        {
            return .failure(.EmptyQuery)
        }
        var QueryHandle: OpaquePointer? = nil
        if sqlite3_prepare(Database, Query, -1, &QueryHandle, nil) != SQLITE_OK
        {
            LastSQLErrorMessage = String(cString: sqlite3_errmsg(Database))
            return .failure(.QueryPreparationError)
        }
        if QueryHandle == nil
        {
            return .failure(.BadQueryHandleReturned)
        }
        return .success(QueryHandle!)
    }
    
    /// Return the extended error message and value.
    /// - Parameter From: The handle of the database where the error occurred.
    /// - Returns: Tuple with the error message and error value.
    public static func ExtendedError(From: OpaquePointer?) -> (String, Int32)
    {
        let ExErrorCode = sqlite3_extended_errcode(From)
        var Message = ""
        if let CMessage = sqlite3_errmsg(From)
        {
            Message = String(cString: CMessage)
        }
        return (Message, ExErrorCode)
    }
    
    public static var LastSQLErrorMessage: String = ""
    
    /// Return the number of rows in a database table.
    /// - Parameter Database: Handle to the database with the table to count.
    /// - Parameter Table: Name of the table to count rows.
    /// - Returns: Result with the number of rows.
    public static func RowCount(Database Handle: OpaquePointer?, Table Name: String) -> Result<Int, DatabaseOperationResult>
    {
        let GetCount = "SELECT COUNT (*) FROM \(Name)"
        let QuerySetupResult = SetupQuery(For: Handle, Query: GetCount)
        switch QuerySetupResult
        {
            case .success(let CountQuery):
                while sqlite3_step(CountQuery) == SQLITE_ROW
                {
                    let Count = sqlite3_column_int(CountQuery, 0)
                    return .success(Int(Count))
                }
                
            default:
                break
        }
        return .failure(.ErrorGettingRowCount)
    }
    
    // MARK: - String-related functions
    
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
    
    // MARK: - Column reading functions.
    
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
    
    // MARK: - Higher-level functions.
    
    /// General purpose function to determine if a row exists in a database.
    /// - Parameter In: Open database handle. *Must be an open database!*
    /// - Parameter Table: Name of the table to search.
    /// - Parameter Where: Phrase used to determine if a record in the specified table exists or not. *Must
    ///                    be a properly-formated SQL phrase.*
    /// - Returns: Result value with success holding a boolean indicating existence (true) or non-existence
    ///            (false) of the row in the table. On error, .failure will contain the reason for the failure.
    public static func RowExists(In Database: OpaquePointer, Table Name: String, Where Phrase: String) -> Result<Bool, DatabaseOperationResult>
    {
        if Name.isEmpty
        {
            return .failure(.MissingTableName)
        }
        if Phrase.isEmpty
        {
            return .failure(.MissingSearchClause)
        }
        let Query = "SELECT EXISTS(SELECT 1 FROM \(Name) WHERE \(Phrase))"
        var QueryHandle: OpaquePointer? = nil
        let QuerySetupResult = SQL.SetupQuery(For: Database, Query: Query)
        switch QuerySetupResult
        {
            case .success(let Handle):
                QueryHandle = Handle
                
            case .failure(let Why):
                Debug.Print("Failure creating query \(Query): \(Why)")
                let (Message, Value) = SQL.ExtendedError(From: Database)
                Debug.Print("  \(Message) [\(Value)]")
                return .failure(.QueryError)
        }
        while (sqlite3_step(QueryHandle) == SQLITE_ROW)
        {
            let Value = sqlite3_column_int(QueryHandle, 0)
            return .success(Value == 0 ? false : true)
        }
        return .success(false)
    }
    
    /// Delete a row in a database.
    /// - Parameter In: The database handle for the table where the row will be deleted.
    /// - Parameter Table: The name of the table that contains the row to delete.
    /// - Parameter DeletePhrase: The conditional that determines which row to delete.
    /// - Returns: Result code. Failure contains the reason why the operation failed.
    public static func DeleteRow(In Database: OpaquePointer, Table Name: String, DeletePhrase: String) -> Result<Bool, DatabaseOperationResult>
    {
        if Name.isEmpty
        {
            return .failure(.MissingTableName)
        }
        if DeletePhrase.isEmpty
        {
            return .failure(.MissingSearchClause)
        }
        let Command = "DELETE FROM \(Name) WHERE \(DeletePhrase)"
        var CommandHandle: OpaquePointer? = nil
        let QuerySetupResult = SQL.SetupQuery(For: Database, Query: Command)
        switch QuerySetupResult
        {
            case .success(let Handle):
                CommandHandle = Handle
                
            case .failure(let Why):
                Debug.Print("Failure creating query \(Command): \(Why)")
                let (Message, Value) = SQL.ExtendedError(From: Database)
                Debug.Print("  \(Message) [\(Value)]")
                return .failure(.QueryError)
        }
        
        if sqlite3_step(CommandHandle) == SQLITE_DONE
        {
            return .success(true)
        }
        
        return .failure(.ErrorDeletingRow)
    }
    
    /// Update a row in the table of the passed database.
    /// - Parameter Database: Database handle that contains the table to update.
    /// - Parameter Table: Name of the table that will be updated.
    /// - Parameter Columns: The update command.
    /// - Parameter Where: The clause that determines which row is updated.
    public static func UpdateRow(Database: OpaquePointer, Table Name: String, Columns Command: String,
                                 Where Conditional: String)
    {
        var SCommand = "UPDATE \(Name)"
        SCommand.append(" \(Command)")
        SCommand.append(" WHERE \(Conditional);")
        var UpdateHandle: OpaquePointer? = nil
        guard sqlite3_prepare_v2(Database, SCommand, -1, &UpdateHandle, nil) == SQLITE_OK else
        {
            Debug.Print("Failure in update statement \(SCommand) for row update")
            let (Message, Value) = SQL.ExtendedError(From: Database)
            Debug.Print("  \(Message) [\(Value)]")
            return
        }
        guard sqlite3_step(UpdateHandle) == SQLITE_DONE else
        {
            Debug.Print("Update execution failed: \(SCommand) for row update")
            let (Message, Value) = SQL.ExtendedError(From: Database)
            Debug.Print("  \(Message) [\(Value)]")
            return
        }
    }
    
    /// Update a row in the table of the passed database.
    /// - Parameter Database: Database handle that contains the table to update.
    /// - Parameter Table: Name of the table that will be updated.
    /// - Parameter Row: Command to use to update the database.
    public static func UpdateRow(Database: OpaquePointer, Table Name: String, Row Command: String)
    {
        let SCommand = Command
        var UpdateHandle: OpaquePointer? = nil
        guard sqlite3_prepare_v2(Database, SCommand, -1, &UpdateHandle, nil) == SQLITE_OK else
        {
            Debug.Print("Failure: update statement \(SCommand) for row update")
            let (Message, Value) = SQL.ExtendedError(From: Database)
            Debug.Print("  \(Message) [\(Value)]")
            return
        }
        guard sqlite3_step(UpdateHandle) == SQLITE_DONE else
        {
            Debug.Print("Update execution failed: \(SCommand) for row update")
            let (Message, Value) = SQL.ExtendedError(From: Database)
            Debug.Print("  \(Message) [\(Value)]")
            return
        }
    }
    
#if false
    public static func AddOrUpdate(Database: OpaquePointer, Table Name: String, SearchPhrase: String,
                                   InsertCommand: String)
    {
        var RowExists = false
        let SearchResults = SQL.RowExists(In: Database, Table: Name, Where: SearchPhrase)
        switch SearchResults
        {
            case .success(let DoesExist):
                RowExists = DoesExist
                
            case .failure(let Why):
                return
        }
        if RowExists
        {
            let DeleteResults = DeleteRow(In: Database, Table: Name, DeletePhrase: SearchPhrase)
            print("Deleting row with \(SearchPhrase)")
            switch DeleteResults
            {
                case .success(let NotUsed):
                    break
                    
                case .failure(let AlsoNotUsed):
                    return
            }
        }
        
        var InsertHandle: OpaquePointer? = nil
        guard sqlite3_prepare_v2(Database, InsertCommand, -1, &InsertHandle, nil) == SQLITE_OK else
        {
            Debug.Print("Failure insert statement \(InsertCommand) for row insertion")
            let (Message, Value) = SQL.ExtendedError(From: Database)
            Debug.Print("  \(Message) [\(Value)]")
            return
        }
        guard sqlite3_step(InsertHandle) == SQLITE_DONE else
        {
            Debug.Print("Insert execution failed: \(InsertCommand) for row insertion")
            let (Message, Value) = SQL.ExtendedError(From: Database)
            Debug.Print("  \(Message) [\(Value)]")
            return
        }
    }
#endif
    
    /// Create an insert statement.
    /// - Parameter From: Array of name, value pairs to insert.
    /// - Parameter For: Name of the table where to insert the row.
    /// - Parameter ExcludedColumns: Array of columns in `From` to exclude.
    /// - Returns: SQLite statement for inserting data into a table.
    public static func MakeInsertStatement(From: [(String, String)], For Table: String,
                                           ExcludedColumns: [String] = [String]()) -> String
    {
        var ColumnList = ""
        var ValueList = ""
        for (Name, Value) in From
        {
            if ExcludedColumns.contains(Name)
            {
                continue
            }
            ColumnList.append(Name)
            ColumnList.append(",")
            ValueList.append(Value)
            ValueList.append(",")
        }
        ColumnList = String(ColumnList.dropLast(1))
        ValueList = String(ValueList.dropLast(1))
        let Final = "INSERT INTO \(Table) (\(ColumnList)) VALUES(\(ValueList));"
        return Final
    }
    
    /// Create and return a statement for updating a table.
    /// - Parameter From: Array of name, value pairs to update.
    /// - Parameter For: Name of the table where to insert the row.
    /// - Parameter ExcludedColumns: Array of columns in `From` to exclude.
    /// - Returns: SQLite statement for updating data in a table.
    public static func MakeUpdateStatement(From: [(String, String)], For Table: String,
                                           ExcludedColumns: [String] = [String]()) -> String
    {
        var ColumnList = ""
        var ValueList = ""
        for (Name, Value) in From
        {
            if ExcludedColumns.contains(Name)
            {
                continue
            }
            ColumnList.append(Name)
            ColumnList.append(",")
            ValueList.append(Value)
            ValueList.append(",")
        }
        ColumnList = String(ColumnList.dropLast(1))
        ValueList = String(ValueList.dropLast(1))
        let Final = "INSERT OR REPLACE INTO \(Table) (\(ColumnList)) VALUES(\(ValueList));"
        return Final
    }
}

/// High-level result types for SQL database operations.
enum DatabaseOperationResult: String, CaseIterable, Error
{
    /// Operational success.
    case Success = "Success"
    /// Error preparing query.
    case QueryPreparationError = "Query preparation error"
    /// General query error.
    case QueryError = "Query error"
    /// Invalid query handle returned.
    case BadQueryHandleReturned = "Bad query handle returned"
    /// Database handle is unexpectedly nil.
    case NilDatabase = "Database handle is nil"
    /// Result of query is empty.
    case EmptyQuery = "Query is empty"
    /// Error in preparation to get row count.
    case ErrorGettingRowCount = "Error preparing for getting row count"
    /// Missing table name.
    case MissingTableName = "Missing table name for query"
    /// Search clause for query missing.
    case MissingSearchClause = "Missing search clause for query"
    /// Error deleting row.
    case ErrorDeletingRow = "Error deleting row."
}
