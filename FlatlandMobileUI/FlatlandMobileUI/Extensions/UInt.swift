//
//  UInt.swift
//  UInt
//
//  Created by Stuart Rankin on 7/20/21.
//

import Foundation
import UIKit

/// UInt extensions.
extension UInt
{
    /// Returns the layout size of a `UInt` for an instance value.
    /// - Returns: Layout size of a `UInt`.
    func SizeOf() -> Int
    {
        return MemoryLayout.size(ofValue: self)
    }
    
    /// Returns the layout size of a `UInt` when used against the `UInt` type.
    /// - Returns: Layout size of a `UInt`.
    static func SizeOf() -> Int
    {
        return MemoryLayout.size(ofValue: UInt(0))
    }
    
    /// Return the square of the instance value.
    var Squared: UInt
    {
        get
        {
            return self * self
        }
    }
    
    /// Return the cube of the instance value.
    var Cubed: UInt
    {
        get
        {
            return self * self * self
        }
    }
}


