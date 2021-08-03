//
//  Int64.swift
//  Int64
//
//  Created by Stuart Rankin on 7/18/21. Adapted from Flatland View.
//

import Foundation
import UIKit

extension Int64
{
    /// Returns the value as a string with a suffix for KB, MB, or GB.
    /// - Returns: String with a rounded value with the appropriate suffix. If a suffix value cannot be
    ///            determined, the delimited value is returned instead.
    func WithSuffix() -> String
    {
        let Suffixes: [(Low: Int64, High: Int64, Suffix: String)] =
        [
            (0, 1023, ""),
            (1024, 1048575, "KB"),
            (1048576, 1073471823, "MB"),
            (1073471824, Int64.max, "GB")
        ]
        let IsNegative = self < 0 ? true : false
        let TestValue = abs(self)
        for (Low, High, Suffix) in Suffixes
        {
            if TestValue >= Low && TestValue <= High
            {
                var Value: Double = Double(TestValue) / Double(Low)
                Value = Value.RoundedTo(2)
                let SignString = IsNegative ? "-" : ""
                return "\(SignString)\(Value) \(Suffix)"
            }
        }
        return Delimited()
    }
    
    /// Returns the instance value as a delimited string.
    /// - Parameter Delimiter: The character to use to delimit thousands blocks.
    /// - Returns: Value as a character delimited string.
    func Delimited(Delimiter: String = ",") -> String
    {
        let Raw = "\(self)"
        if Raw.count <= 3
        {
            return Raw
        }
        var RawArray = Array(Raw)
        var Working = ""
        while RawArray.count > 0
        {
            let Last3 = RawArray.suffix(3)
            var Sub = ""
            for C in Last3
            {
                Sub = Sub + String(C)
            }
            if RawArray.count >= 3
            {
                RawArray.removeLast(3)
            }
            else
            {
                RawArray.removeAll()
            }
            let Separator = RawArray.count > 0 ? Delimiter : ""
            Working = "\(Separator)\(Sub)" + Working
        }
        if self < 0
        {
            let CheckFor = "-\(Delimiter)"
            if Working.hasPrefix(CheckFor)
            {
                Working.removeFirst(CheckFor.count)
                Working = "-" + Working
            }
        }
        else
        {
            if Working.first! == String.Element(Delimiter)
            {
                Working.removeFirst()
            }
        }
        return Working
    }
    
    /// Return the square of the instance value.
    var Squared: Int64
    {
        get
        {
            return self * self
        }
    }
    
    /// Return the cube of the instance value.
    var Cubed: Int64
    {
        get
        {
            return self * self * self
        }
    }
}

