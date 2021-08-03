//
//  UInt8.swift
//  UInt8
//
//  Created by Stuart Rankin on 7/20/21. Adapted from Flatland View.
//

import Foundation
import UIKit

extension UInt8
{
    /// Returns the layout size of a `UInt8` for an instance value.
    /// - Returns: Layout size of a `UInt8`.
    func SizeOf() -> Int
    {
        return MemoryLayout.size(ofValue: self)
    }
    
    /// Returns the layout size of a `UInt8` when used against the `UInt8` type.
    /// - Returns: Layout size of a `UInt8`.
    static func SizeOf() -> Int
    {
        return MemoryLayout.size(ofValue: UInt8(0))
    }
    
    /// Return the square of the instance value.
    var Squared: UInt8
    {
        get
        {
            return self * self
        }
    }
    
    /// Return the cube of the instance value.
    var Cubed: UInt8
    {
        get
        {
            return self * self * self
        }
    }
}
