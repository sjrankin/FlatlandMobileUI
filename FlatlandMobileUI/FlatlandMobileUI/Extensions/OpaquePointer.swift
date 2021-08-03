//
//  OpaquePointer.swift
//  OpaquePointer
//
//  Created by Stuart Rankin on 7/18/21.
//

import Foundation
import UIKit

// MARK: - OpaquePointer extensions for reading SQLite columns.

extension OpaquePointer
{
    /// Reads a double value from a SQL database table the instance `OpaquePointer` points to and
    /// returns what is found there.
    /// - Parameter Index: Index of the column to read. Assumes the column is of the proper type.
    /// - Parameter Double: The default value tor return if there is an error reading the column.
    /// - Returns: The double value in the column on success, the value of `Default` on error.
    func GetDouble(_ Index: Int32, Default: Double = 0.0) -> Double
    {
        if let Result = SQL.ReadDoubleColumn(Handle: self, Index: Index)
        {
            return Result
        }
        return Default
    }
    
    /// Reads an integer value from a SQL database table the instance `OpaquePointer` points to and
    /// returns what is found there.
    /// - Parameter Index: Index of the column to read. Assumes the column is of the proper type.
    /// - Parameter Double: The default value tor return if there is an error reading the column.
    /// - Returns: The integer value in the column on success, the value of `Default` on error.
    func GetInt(_ Index: Int32, Default: Int = 0) -> Int
    {
        if let Result = SQL.ReadIntColumn(Handle: self, Index: Index)
        {
            return Result
        }
        return Default
    }
    
    /// Reads a string value from a SQL database table the instance `OpaquePointer` points to and
    /// returns what is found there.
    /// - Parameter Index: Index of the column to read. Assumes the column is of the proper type.
    /// - Parameter Double: The default value tor return if there is an error reading the column.
    /// - Returns: The string value in the column on success, the value of `Default` on error.
    func GetString(_ Index: Int32, Default: String = "") -> String
    {
        if let Result = SQL.ReadStringColumn(Handle: self, Index: Index)
        {
            return Result
        }
        return Default
    }
    
    /// Reads a UUID value from a SQL database table the instance `OpaquePointer` points to and
    /// returns what is found there.
    /// - Parameter Index: Index of the column to read. Assumes the column is of the proper type.
    /// - Parameter Double: The default value tor return if there is an error reading the column.
    /// - Returns: The UUID value in the column on success, the value of `Default` on error.
    func GetUUID(_ Index: Int32, Default: UUID = UUID.Empty) -> UUID
    {
        if let Result = SQL.ReadUUIDColumn(Handle: self, Index: Index)
        {
            return Result
        }
        return Default
    }
    
    /// Reads a color value from a SQL database table the instance `OpaquePointer` points to and
    /// returns what is found there.
    /// - Note: The format of the color in the database must be a string in hex color value.
    /// - Parameter Index: Index of the column to read. Assumes the column is of the proper type.
    /// - Parameter Double: The default value tor return if there is an error reading the column.
    /// - Returns: The color value in the column on success, the value of `Default` on error.
    func GetColor(_ Index: Int32, Default: UIColor = UIColor.clear) -> UIColor
    {
        if let Result = SQL.ReadColorColumn(Handle: self, Index: Index)
        {
            return Result
        }
        return Default
    }
    
    /// Reads a boolean value from a SQL database table the instance `OpaquePointer` points to and
    /// returns what is found there.
    /// - Note: The format of the boolean in the database must be integer with 0 representing false and
    ///         all other values representing true.
    /// - Parameter Index: Index of the column to read. Assumes the column is of the proper type.
    /// - Parameter Double: The default value tor return if there is an error reading the column.
    /// - Returns: The boolean value in the column on success, the value of `Default` on error.
    func GetBool(_ Index: Int32, Default: Bool = false) -> Bool
    {
        if let Result = SQL.ReadBoolColumn(Handle: self, Index: Index)
        {
            return Result
        }
        return Default
    }
}
