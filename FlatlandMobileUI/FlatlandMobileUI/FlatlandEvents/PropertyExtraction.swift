//
//  PropertyExtraction.swift
//  PropertyExtraction
//
//  Created by Stuart Rankin on 7/18/21.
//

import Foundation
import UIKit

class PropertyExtraction
{
    /// Returns an array of tuples from the descendant class properties whose names begin with the value
    /// in `Prefix`.
    /// - Parameter Prefix: The prefix that property names must have to be included in the returned list. If
    ///                     the lenth of this value is less than 1, nil is returned. Defaults to `__`.
    /// - Returns: Array of tuples - the name of the property (with the prefix removed) and the current value
    ///            of the property. All values converted to `String`s.
    func Properties(Prefix: String = "__") -> [(Name: String, Value: String)]?
    {
        if Prefix.count < 1
        {
            return nil
        }
        var ReturnMe = [(Name: String, Value: String)]()
        let Properties = Mirror(reflecting: self).children
        for Property in Properties
        {
            if var PropertyName = Property.label
            {
                if PropertyName.starts(with: Prefix)
                {
                    var FinalValue = ""
                    PropertyName = String(PropertyName.dropFirst(Prefix.count))
                    if Mirror.IsOptional(Property.value)
                    {
                        FinalValue = "\(Property.value)"
                        if FinalValue == "nil"
                        {
                            if type(of: Property.value) == String.self
                            {
                                FinalValue = "\"\""
                            }
                            else
                            {
                                FinalValue = "0"
                            }
                        }
                    }
                    else
                    {
                        let PropertyType = "\(type(of: Property.value))"
                        switch PropertyType
                        {
                            case "Bool":
                                if let SomeBool = Property.value as? Bool
                                {
                                    FinalValue = SomeBool ? "1" : "0"
                                }
                                else
                                {
                                    FinalValue = "0"
                                }
                                
                            case "Date":
                                if let SomeDate = Property.value as? Date
                                {
                                    FinalValue = "\(SomeDate.timeIntervalSince1970)"
                                }
                                else
                                {
                                    FinalValue = "0"
                                }
                                
                            case "UUID":
                                if FinalValue.isEmpty
                                {
                                    FinalValue = "\"\(UUID().uuidString)\""
                                }
                                else
                                {
                                    FinalValue = "\"\(FinalValue)\""
                                }
                                
                            case "String":
                                FinalValue = "\"\(Property.value)\""
                                
                            default:
                                FinalValue = "\(Property.value)"
                        }
                    }
                    ReturnMe.append((Name: PropertyName, Value: FinalValue))
                }
            }
        }
        return ReturnMe
    }
}
