//
//  MemoryDebug.swift
//  MemoryDebug
//
//  Created by Stuart Rankin on 7/18/21. Adapted from Flatland View.
//

import Foundation
import UIKit

/// Contains functions to assist in memory debugging.
/// - Note: When compiled for release, no code is generated because all code is surrounded by `#if DEBUG`
///         blocks.
class MemoryDebug
{
    /// Initialize the memory debug class.
    public static func Initialize()
    {
#if DEBUG
        Locations = [String: MemoryData]()
#endif
    }
    
    /// Determines if a location has been set.
    /// - Parameter Name: Name of the location record.
    /// - Returns: True if a location record with the passed name exists, false if not. If compiled in release
    ///            mode, false is always returned.
    public static func HasLocation(_ Name: String) -> Bool
    {
#if DEBUG
        objc_sync_enter(LocationSync)
        defer{objc_sync_exit(LocationSync)}
        return Locations[Name] != nil
#else
        return false
#endif
    }
    
    public static var LocationSync = NSObject()
    
    /// Open a memory location for starting the measurement of memory.
    /// - Note: All previous data in pre-existing memory locations are zeroed and lost.
    /// - Parameter Name: The name of the memory location. If not found, a new record is created.
    /// - Parameter Field: The type of memory to return. Defaults to `.PhysicalFootprint`.
    public static func Open(_ Name: String, Field: MemoryFields = .PhysicalFootprint)
    {
#if DEBUG
        if !HasLocation(Name)
        {
            let NewRecord = MemoryData()
            NewRecord.Name = Name
            NewRecord.Field = Field
            Locations[Name] = NewRecord
        }
        if let Record = Locations[Name]
        {
            Record.Start = nil
            Record.End = nil
            Record.Delta = nil
            Record.Start = LowLevel.MemoryStatistics(Field)
        }
#endif
    }
    
    /// Close a memory location at the end of the measurement of memory.
    /// - Note:
    ///    - If the memory record does not exist, no action is taken (other than a diagnostic message
    ///      printed to the debug console).
    ///    - The delta memory is calculated here with `End` - `Start`. Positive deltas mean memory usage was
    ///      lessened and negative deltas mean more memory was used.
    /// - Parameter Name: The name of the memory location record. Must match the name used to open the record,
    ///                   including case.
    /// - Parameter DebugPrint: If true, a message is printed on the debug console showing the memory delta.
    /// - Returns: Delta value between the staring memory and the ending memory. Nil on error. If compiled
    ///            for release, nil is always returned.
    @discardableResult public static func Close(_ Name: String, DebugPrint: Bool = true) -> Int64?
    {
#if DEBUG
        if let Record = Locations[Name]
        {
            Record.End = LowLevel.MemoryStatistics(Record.Field)
            if Record.Start != nil
            {
                Record.Delta = Int64(Record.End!) - Int64(Record.Start!)
                if DebugPrint
                {
                    var Sign = ""
                    if Record.Delta! > 0
                    {
                        Sign = "+"
                    }
                    let PrettyTime = Date().PrettyTime(IncludeSeconds: true, ForFileName: false)
                    let CurrentMemory = LowLevel.MemoryStatistics(.PhysicalFootprint)!
                    let CMem = CurrentMemory.WithSuffix()
                    let RawDelta = Record.Delta!
                    let DeltaMem = RawDelta.Delimited()
                    let NameValue = Record.Name ?? "n/a"
                    CSV[MemoryHeaders.Time.rawValue] = PrettyTime
                    CSV[MemoryHeaders.UsedMemory.rawValue] = CMem
                    CSV[MemoryHeaders.ActualMemory.rawValue] = "\(CurrentMemory)"
                    CSV[MemoryHeaders.Delta.rawValue] = "\"\(DeltaMem)\""
                    CSV[MemoryHeaders.Note.rawValue] = "\"\(NameValue)\""
                    CSV.SaveRowInFile()
                    //CSV.SetData(RowData("\"\(PrettyTime)\"", "", "\(CMem)", "\(CurrentMemory)", "", "\"\(DeltaMem)\"",
                    //                    "", NameValue))
                    Debug.Print("MemoryDebug Operation \"\(Name)\": Memory delta \(Sign)\(Record.Delta!.Delimited())")
                }
                return Record.Delta
            }
        }
        else
        {
            Debug.Print("Attempted to close non-existent memory debug record \(Name).")
        }
        return nil
#else
        return nil
#endif
    }
    
    /// Open a memory location for starting the measurement of memory.
    /// - Note: All previous data in pre-existing memory locations are zeroed and lost.
    /// - Parameter Name: The name of the memory location. If not found, a new record is created.
    /// - Parameter Field: The type of memory to return. Defaults to `.PhysicalFootprint`.
    /// - Returns: Token to use for closing the debug measurement. If compiled in release mode, a newly
    ///            generated UUID is returned that has no contextual meaning.
    public static func OpenWithToken(_ Name: String, Field: MemoryFields = .PhysicalFootprint) -> UUID
    {
#if DEBUG
        let TokenValue = UUID()
        if !HasLocation(TokenValue.uuidString)
        {
            let NewRecord = MemoryData()
            NewRecord.Name = Name
            NewRecord.Field = Field
            Locations[Name] = NewRecord
        }
        if let Record = Locations[Name]
        {
            Record.Start = nil
            Record.End = nil
            Record.Delta = nil
            Record.Start = LowLevel.MemoryStatistics(Field)
        }
        return TokenValue
#else
        return UUID()
#endif
    }
    
    /// Close a memory location at the end of the measurement of memory.
    /// - Note:
    ///    - If the memory record does not exist, no action is taken (other than a diagnostic message
    ///      printed to the debug console).
    ///    - The delta memory is calculated here with `End` - `Start`. Positive deltas mean memory usage was
    ///      lessened and negative deltas mean more memory was used.
    /// - Parameter Token: The token from `OpenWithToken`.
    /// - Parameter DebugPrint: If true, a message is printed on the debug console showing the memory delta.
    /// - Returns: Delta value between the staring memory and the ending memory. Nil on error. If compiled
    ///            for release, nil is always returned.
    @discardableResult public static func CloseWithToken(_ Token: UUID, DebugPrint: Bool = true) -> Int64?
    {
#if DEBUG
        if let Record = Locations[Token.uuidString]
        {
            Record.End = LowLevel.MemoryStatistics(Record.Field)
            if Record.Start != nil
            {
                Record.Delta = Int64(Record.End!) - Int64(Record.Start!)
                if DebugPrint
                {
                    var Sign = ""
                    if Record.Delta! > 0
                    {
                        Sign = "+"
                    }
                    let NameValue = Record.Name ?? "n/a"
                    let PrettyTime = Date().PrettyTime(IncludeSeconds: true, ForFileName: false)
                    let CurrentMemory = LowLevel.MemoryStatistics(.PhysicalFootprint)!
                    let CMem = CurrentMemory.WithSuffix()
                    let DeltaMem = Record.Delta!.WithSuffix()
                    CSV[MemoryHeaders.Time.rawValue] = PrettyTime
                    CSV[MemoryHeaders.UsedMemory.rawValue] = CMem
                    CSV[MemoryHeaders.ActualMemory.rawValue] = "\(CurrentMemory)"
                    CSV[MemoryHeaders.Delta.rawValue] = "\"\(DeltaMem)\""
                    CSV[MemoryHeaders.Note.rawValue] = "\"\(NameValue)\""
                    CSV.SaveRowInFile()
                    //                    CSV.SetData(RowData("\"\(PrettyTime)\"", "", "\(CMem)", "\(CurrentMemory)", "", "\(DeltaMem)",
                    //                                        "", NameValue))
                    Debug.Print("MemoryDebug Operation \"\(NameValue)\": Memory delta \(Sign)\(Record.Delta!.Delimited())")
                }
                return Record.Delta
            }
        }
        else
        {
            Debug.Print("Attempted to close non-existent memory debug record \(Token.uuidString).")
        }
        return nil
#else
        return nil
#endif
    }
    
    /// Wraps a the `Open` and `Close` operations around a closure to provide conveniece to callers.
    /// - Note:
    ///    - As an alternative to this function, the caller can issue a normal `Open` call then immediately
    ///         specify a deferred call to `Close`, such as:
    ///
    ///           MemoryDebug.Open("Some Name")
    ///           defer{MemoryDebug.Close("Some Name")}
    ///           //Caller's code here.
    ///    - If compiled for release, no memory debug takes place but `Closure` will still be called.
    /// - Parameter Name: The name of the location to measure.
    /// - Parameter DebugPrint: If true, a statement is issued to the console showing the delta memory size.
    /// - Parameter Field: The memory field to use. Defaults to `.PhysicalFootprint`.
    /// - Parameter Closure: Closure executed after the `Open` call and before the `CloseCall`. If the code in
    ///                      `Closure` makes background calls, the measured memory usage will not be valid.
    /// - Returns: The location's memory record data. Nil returned on error. If compiled for release, nil is
    ///            always returned.
    @discardableResult public static func Block(_ Name: String, DebugPrint DoPrint: Bool = true,
                                                Field MemoryField: MemoryFields = .PhysicalFootprint,
                                                _ Closure: ((String) -> ())?) -> MemoryData?
    {
#if DEBUG
        Open(Name, Field: MemoryField)
        Closure?(Name)
        Close(Name, DebugPrint: DoPrint)
        return Locations[Name]
#else
        Closure?(Name)
        return nil
#endif
    }
    
#if DEBUG
    /// Holds the dictionary of memory location records.
    static var Locations = [String: MemoryData]()
#endif
    
    /// Starts periodic measuring of the memory footprint of the process.
    /// - Parameter Frequency: How often (in seconds) to measure memory. If 0.0 or less, no action is taken.
    /// - Parameter Closure: Closure block to execute at each period of the timer.
    public static func MeasurePeriodically(_ Frequency: Double = 60.0, _ Closure: ((Int64) -> ())?)
    {
#if DEBUG
        if Frequency <= 0.0
        {
            return
        }
        if let Current = LowLevel.MemoryStatistics(.PhysicalFootprint)
        {
            Closure?(Int64(Current))
        }
        PeriodicTimer = Timer.scheduledTimer(withTimeInterval: Frequency, repeats: true)
        {
            _ in
            if let Current = LowLevel.MemoryStatistics(.PhysicalFootprint)
            {
                Closure?(Int64(Current))
            }
        }
#endif
    }
    
    /// Periodic measurement timer.
    private static var PeriodicTimer: Timer? = nil
    
    /// Stops periodic measurement.
    public static func StopMeasuring()
    {
#if DEBUG
        PeriodicTimer?.invalidate()
        PeriodicTimer = nil
#endif
    }
}

/// Contains one measurement of information for a given program location.
class MemoryData
{
    /// Holds the starting measurement value. Nil if not set.
    public var Start: UInt64? = nil
    
    /// Holds the ending measurement value. Nil if not set.
    public var End: UInt64? = nil
    
    /// Holds the delta memory measurement value. Nil if not set.
    public var Delta: Int64? = nil
    
    /// Name of the memory location record.
    public var Name: String? = nil
    
    /// Field to use for memory calculations.
    public var Field: MemoryFields = .PhysicalFootprint
}

