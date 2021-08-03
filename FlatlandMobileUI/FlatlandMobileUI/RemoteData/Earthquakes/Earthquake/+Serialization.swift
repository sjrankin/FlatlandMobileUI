//
//  +Serialization.swift
//  +Serialization
//
//  Created by Stuart Rankin on 7/18/21. Adapted from Flatland View.
//

import Foundation
import UIKit

extension Earthquake
{
    // MARK: - Earthquke Serialization/Deserialization
    
    /// Separator used to separate key/value pairs in serialized earthquakes.
    public static var Separator = "¶"
    
    /// Create a key/value pair from earthquake data.
    /// - Note: The returned format is `key`=`valueSeparator`
    /// - Parameter Key: The name of the key.
    /// - Parameter Value: The value of the key. `String` type.
    /// - Returns: Key/value pair as a string.
    private static func MakeKVP(_ Key: String, _ Value: String) -> String
    {
        return "\(Key)=\(Value)\(Separator)"
    }
    
    /// Create a key/value pair from earthquake data.
    /// - Note: The returned format is `key`=`valueSeparator`
    /// - Parameter Key: The name of the key.
    /// - Parameter Value: The value of the key. `Int` type.
    /// - Returns: Key/value pair as a string.
    private static func MakeKVP(_ Key: String, _ Value: Int) -> String
    {
        return MakeKVP(Key, "\(Value)")
    }
    
    /// Create a key/value pair from earthquake data.
    /// - Note: The returned format is `key`=`valueSeparator`
    /// - Parameter Key: The name of the key.
    /// - Parameter Value: The value of the key. `Double` type.
    /// - Returns: Key/value pair as a string.
    private static func MakeKVP(_ Key: String, _ Value: Double) -> String
    {
        return MakeKVP(Key, "\(Value)")
    }
    
    /// Serialize the passed earthquake to a string.
    /// - Parameter From: The earthquake to serialize.
    /// - Result: Serialized earthquake.
    public static func Serialize(From Quake: Earthquake) -> String
    {
        var Working: String = ""
        Working.append(MakeKVP("EventID", Quake.EventID))
        Working.append(MakeKVP("Sequence", Quake.Sequence))
        Working.append(MakeKVP("Code", Quake.Code))
        Working.append(MakeKVP("Place", Quake.Place))
        Working.append(MakeKVP("Magnitude", Quake.Magnitude))
        Working.append(MakeKVP("Time", Date.PrettyDate(From: Quake.Time)))
        Working.append(MakeKVP("Tsunami", Quake.Tsunami))
        Working.append(MakeKVP("Latitude", Quake.Latitude))
        Working.append(MakeKVP("Longitude", Quake.Longitude))
        Working.append(MakeKVP("Depth", Quake.Depth))
        Working.append(MakeKVP("Status", Quake.Status))
        if Quake.Updated.timeIntervalSince1970 > Date().timeIntervalSince1970
        {
            Working.append(MakeKVP("Updated", "\(Quake.Updated)"))
        }
        Working.append(MakeKVP("MMI", Quake.MMI))
        Working.append(MakeKVP("Felt", Quake.Felt))
        Working.append(MakeKVP("Significance", Quake.Significance))
        Working.append(MakeKVP("MagType", Quake.MagType))
        Working.append(MakeKVP("MagError", Quake.MagError))
        Working.append(MakeKVP("MagNST", Quake.MagNST))
        Working.append(MakeKVP("DMin", Quake.DMin))
        Working.append(MakeKVP("Alert", Quake.Alert))
        Working.append(MakeKVP("Title", Quake.Title))
        Working.append(MakeKVP("Types", Quake.Types))
        Working.append(MakeKVP("EventType", Quake.EventType))
        Working.append(MakeKVP("Detail", Quake.Detail))
        if Quake.TZ > -24
        {
            Working.append(MakeKVP("TZ", Quake.TZ))
        }
        Working.append(MakeKVP("Net", Quake.Net))
        Working.append(MakeKVP("NST", Quake.NST))
        Working.append(MakeKVP("Gap", Quake.Gap))
        Working.append(MakeKVP("IDs", Quake.IDs))
        Working.append(MakeKVP("HorizontalError", Quake.HorizontalError))
        Working.append(MakeKVP("CDI", Quake.CDI))
        Working.append(MakeKVP("RMS", Quake.RMS))
        Working.append(MakeKVP("NPH", Quake.NPH))
        Working.append(MakeKVP("LocationSource", Quake.LocationSource))
        Working.append(MakeKVP("MagSource", Quake.MagSource))
        Working.append(MakeKVP("EventPageURL", Quake.EventPageURL))
        Working.append(MakeKVP("Sources", Quake.Sources))
        Working.append(MakeKVP("DepthError", Quake.DepthError))
        return Working
    }
    
    /// Serialize the instance earthquake to a string.
    /// - Result: Serialized earthquake. Nil returned on error.
    func Serialize() -> String
    {
        return Earthquake.Serialize(From: self)
    }
    
    private static func GetKVP(From Raw: String) -> (Key: String, Value: String)?
    {
        let Parts = Raw.split(separator: "=", omittingEmptySubsequences: true)
        if Parts.count != 2
        {
            return nil
        }
        return (Key: String(Parts[0]), Value: String(Parts[1]))
    }
    
    private static func ParseSerializedEarthquake(_ Raw: String) -> Earthquake?
    {
        if Raw.isEmpty
        {
            return nil
        }
        let Parts = Raw.split(separator: String.Element(Separator), omittingEmptySubsequences: true)
        if Parts.count < 1
        {
            return nil
        }
        let Quake = Earthquake(Sequence: 0)
        for Part in Parts
        {
            let KVP = String(Part)
            if let (Key, Value) = GetKVP(From: KVP)
            {
                switch Key
                {
                    case "EventID":
                        Quake.EventID = Value
                    case "Sequence":
                        if let IValue = Int(Value)
                        {
                            Quake.Sequence = IValue
                        }
                    case "Code":
                        Quake.Code = Value
                    case "Place":
                        Quake.Place = Value
                    case "Magnitude":
                        if let DValue = Double(Value)
                        {
                            Quake.Magnitude = DValue
                        }
                    case "Time":
                        if let TValue = Date.PrettyDateToDate(Value)
                        {
                            Quake.Time = TValue
                        }
                    case "Tsunami":
                        if let IValue = Int(Value)
                        {
                            Quake.Tsunami = IValue
                        }
                    case "Latitude":
                        if let DValue = Double(Value)
                        {
                            Quake.Latitude = DValue
                        }
                    case "Longitude":
                        if let DValue = Double(Value)
                        {
                            Quake.Longitude = DValue
                        }
                    case "Depth":
                        if let DValue = Double(Value)
                        {
                            Quake.Depth = DValue
                        }
                    case "Status":
                        Quake.Status = Value
                    case "Updated":
                        if let TValue = Date.PrettyDateToDate(Value)
                        {
                            Quake.Updated = TValue
                        }
                    case "MMI":
                        if let DValue = Double(Value)
                        {
                            Quake.MMI = DValue
                        }
                    case "Felt":
                        if let IValue = Int(Value)
                        {
                            Quake.Felt = IValue
                        }
                    case "Significance":
                        if let IValue = Int(Value)
                        {
                            Quake.Significance = IValue
                        }
                    case "MagType":
                        Quake.MagType = Value
                    case "MagNST":
                        if let IValue = Int(Value)
                        {
                            Quake.MagNST = IValue
                        }
                    case "DMin":
                        if let DValue = Double(Value)
                        {
                            Quake.DMin = DValue
                        }
                    case "Alert":
                        Quake.Alert = Value
                    case "Title":
                        Quake.Title = Value
                    case "Types":
                        Quake.Types = Value
                    case "EventType":
                        Quake.EventType = Value
                    case "Detail":
                        Quake.Detail = Value
                    case "TZ":
                        if let IValue = Int(Value)
                        {
                            Quake.TZ = IValue
                        }
                    case "Net":
                        Quake.Net = Value
                    case "NST":
                        if let IValue = Int(Value)
                        {
                            Quake.NST = IValue
                        }
                    case "Gap":
                        if let DValue = Double(Value)
                        {
                            Quake.Gap = DValue
                        }
                    case "IDs":
                        Quake.IDs = Value
                    case "HorizontalError":
                        if let DValue = Double(Value)
                        {
                            Quake.HorizontalError = DValue
                        }
                    case "CDI":
                        if let DValue = Double(Value)
                        {
                            Quake.CDI = DValue
                        }
                    case "RMS":
                        if let DValue = Double(Value)
                        {
                            Quake.RMS = DValue
                        }
                    case "NPH":
                        Quake.NPH = Value
                    case "LocationSource":
                        Quake.LocationSource = Value
                    case "MagSource":
                        Quake.MagSource = Value
                    case "EventPageURL":
                        Quake.EventPageURL = Value
                    case "Sources":
                        Quake.Sources = Value
                    case "DepthError":
                        if let DValue = Double(Value)
                        {
                            Quake.DepthError = DValue
                        }
                    default:
                        break
                }
            }
        }
        return Quake
    }
    
    /// Deserialize the passed string into an Earthquake.
    /// - Result: Serialized earthquake. Nil returned on error.
    public static func Deserialize(_ Serialized: String) -> Earthquake?
    {
        return ParseSerializedEarthquake(Serialized)
    }
}
