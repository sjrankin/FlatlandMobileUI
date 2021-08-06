//
//  Screens.swift
//  Screens
//
//  Created by Stuart Rankin on 8/5/21.
//

import Foundation
import UIKit

/// Miscellaneous routines realted to screen sizes.
class Screens
{
    /// Return a multiplier for certain elements based on the size of the screen.
    /// - Returns: Multiplier value for 3D elements.
    public static func GetScreenMultiplier() -> Double
    {
        let NativeWidth = UIScreen.main.nativeBounds.width
        if let UIMultiplier = Multipliers[Int(NativeWidth)]
        {
            return UIMultiplier
        }
        return 1.0
    }
    
    /// Dictionary of minimum screen dimensions to UI element multipliers.
    public static let Multipliers: [Int: Double] =
    [
        //iPhones
        1170: 1.0,
        1080: 1.0,
        1284: 1.0,
        1170: 1.0,
        750: 1.0,
        1242: 1.0,
        1125: 1.0,
        828: 1.0,
        
        //iPads
        2048: 1.0,
        1668: 1.0,
        1640: 1.0,
        1536: 1.0,
        768: 1.0
    ]
}
