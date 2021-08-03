//
//  CSV.swift
//  CSV
//
//  Created by Stuart Rankin on 7/18/21. Adapted from Flatland View.
//

import Foundation
import UIKit

/// Stores tabular data and saves it as a .csv file.
class CSV
{
    /// Used to store the order of the headers.
    private static var Order = [String]()
    
    /// Working columnar data dictionary.
    private static var ColumnData = [String: String]()
    
    /// Holds all data sent.
    private static var CSVData = [[String: String]]()
    
    /// Set the headers of the columns.
    /// - Note:
    ///    - Do not specify duplicate header values.
    ///    - When adding data, each row's data is specified by the associated column header.
    /// - Parameter Headers: Array of header strings.
    public static func SetHeaders(_ Headers: [String])
    {
        ColumnData.removeAll()
        Order.removeAll()
        for Header in Headers
        {
            ColumnData[Header] = ""
            Order.append(Header)
        }
        _HeadersSet = true
    }
    
    /// Holds the headers set flag.
    private static var _HeadersSet: Bool = false
    /// Get the headers set flag. If the headers have not been set, most functionality is not available.
    public static var HeadersSet: Bool
    {
        get
        {
            return _HeadersSet
        }
    }
    
    /// Overrides the subscript operator to allow getting or setting of the data in the *current* row.
    /// - Parameter Key: The header column name. Must match exactly.
    /// - Returns: The value at the specified column. Nil if the column does not exist.
    static subscript(Key: String) -> String?
    {
        get
        {
            return ColumnData[Key]
        }
        set
        {
            objc_sync_enter(CSVLock)
            defer{objc_sync_exit(CSVLock)}
            if !HeadersSet
            {
                return
            }
            if ColumnData.keys.contains(Key)
            {
                ColumnData[Key] = newValue
            }
            else
            {
                Debug.FatalError("CSV does not contain key \(Key)")
            }
        }
    }
    
    /// Saves the current row in the internal data set. Does not write data to the file.
    public static func SaveRow()
    {
        objc_sync_enter(CSVLock)
        defer{objc_sync_exit(CSVLock)}
        _IsDirty = true
        CSVData.append(ColumnData)
        for (Key, _) in ColumnData
        {
            ColumnData[Key] = ""
        }
    }
    
    /// Saves the current row in the internal data set. Writes the full dataset to a file.
    /// - Notes:
    ///   - If the name has not been set (via a previous call or through `SetSaveName`, the passed name is
    ///     saved for the next call and all subsequent calls do not need to specify a file name.
    ///   - For convenience, the caller can call `SetSaveName` prior to calling this function and not specify
    ///     any parameters.
    ///   - If the caller does not specify a file name in the call and no previous name was set, a fatal error
    ///     is generated.
    /// - Warning: Fatal errors are generated if there is no file name available.
    /// - Parameter Name: Name of the file to write. See the Notes section.
    /// - Parameter With: The delimiter to use to separate values. Defaults to "`,`".
    public static func SaveRowInFile(Name ForFile: String? = nil, With Delimiter: String = ",")
    {
        if !HeadersSet
        {
            return
        }
        SaveRow()
        var ActualName: String = ""
        if let SomeName = ForFile
        {
            _SaveNameSet = true
            PreviousFileName = SomeName
            ActualName = SomeName
        }
        else
        {
            if PreviousFileName == nil
            {
                Debug.FatalError("No file name specified.")
            }
            ActualName = PreviousFileName!
        }
        WriteTo(Name: ActualName, With: Delimiter)
    }
    
    /// Saves the name of the file to use when writing.
    /// - Note: Provided for convenience. If used, should be called just after headers are assigned.
    /// - Parameter FileName: The name of the file (including extension) to use when writing the file.
    public static func SetSaveName(_ FileName: String)
    {
        objc_sync_enter(CSVLock)
        defer{objc_sync_exit(CSVLock)}
        if FileName.isEmpty
        {
            Debug.FatalError("Invalid file name.")
        }
        _SaveNameSet = true
        PreviousFileName = FileName
    }
    
    /// Holds the name set flag.
    private static var _SaveNameSet: Bool = false
    /// Get the name set flag.
    public static var SaveNameSet: Bool
    {
        get
        {
            return _SaveNameSet
        }
    }
    
    /// Holds the previous file name used.
    private static var PreviousFileName: String? = nil
    
    /// Data access lock object.
    private static let CSVLock = NSObject()
    
    /// Holds the dirty flag.
    private static var _IsDirty: Bool = false
    /// Get the dirty flag.
    public static var IsDirty: Bool
    {
        get
        {
            return _IsDirty
        }
    }
    
    /// Write the data to a text file with the specified name.
    /// - Note: Data is saved to the application's main root directory in the documents directory. While assumed,
    ///         is is not required the extension of the file name ends in `.csv`.
    /// - Parameter Name: The name of the file to save. Specifying the same file name will result in overwriting
    ///                   any files with the same name.
    /// - Parameter With: Delimiter between values. Defaults to "`,`".
    public static func WriteTo(Name ForFile: String, With Delimiter: String = ",")
    {
        objc_sync_enter(CSVLock)
        defer{objc_sync_exit(CSVLock)}
        if !HeadersSet
        {
            return
        }
        if !IsDirty
        {
            return
        }
        _IsDirty = false
        var Contents = ""
        Contents = Order.joined(separator: Delimiter)
        Contents = Contents + "\n"
        for SomeRow in CSVData
        {
            var Row = ""
            for Header in Order
            {
                if let Value = SomeRow[Header]
                {
                    Row = Row + Value + Delimiter
                }
                else
                {
                    Row = Row + "" + Delimiter
                }
            }
            Row.removeLast()
            Row = Row + "\n"
            Contents = Contents + Row
        }
        let FileName = ForFile
        FileIO.WriteString(Contents, To: FileName)
    }
}

/// Headers to use with CSV.
enum MemoryHeaders: String, CaseIterable
{
    case Time = "Time"
    case ElapsedTime = "ElapsedTime"
    case UsedMemory = "Used Memory"
    case ActualMemory = "Actual Memory"
    case MeanMemory = "Mean Memory (60s)"
    case Delta = "Delta"
    case NodeCount = "Node Count"
    case Note = "Note"
}
