//
//  Array.swift
//  Array
//
//  Created by Stuart Rankin on 7/20/21. Adapted from Flatland View.
//

import Foundation
import UIKit

// MARK: - Array extensions.

/// Extension to Arrays to return the delta between the instance and another array.
/// - Note: See [How to find the different between two arrays](https://www.hackingwithswift.com/example-code/language/how-to-find-the-difference-between-two-arrays)
extension Array where Element: Hashable
{
    func Difference(From Other: [Element]) -> [Element]
    {
        let ThisSet = Set(self)
        let OtherSet = Set(Other)
        return Array(ThisSet.symmetricDifference(OtherSet))
    }
}

/// Array[Double] extensions. Used for k-means clustering of earthquakes.
extension Array where Element == Double
{
    var Sum: Double
    {
        return self.reduce(0.0, +)
    }
    
    var Mean: Double
    {
        return Sum / Double(self.count)
    }
    
    var Variance: Double
    {
        let TheMean = self.Mean
        return self.map{($0 - TheMean) * ($0 - TheMean)}.Mean
    }
    
    var Std: Double
    {
        return sqrt(Variance)
    }
    
    var ZScore: [Double]
    {
        let TheMean = self.Mean
        let Standard = self.Std
        return self.map{Standard != 0 ? (($0 - TheMean) / Standard) : 0.0}
    }
}

/// Array extensions.
extension Array
{
    /// Shift the contents of an array by a specified amount.
    /// - Note: See [Shift arrays in Swift](https://stackoverflow.com/questions/31554670/shift-swift-array/44739098)
    /// - Parameter By: The number of elements to shift the array, positive or negative.
    /// - Rturns: Shifted array.
    public func Shift(By Index: Int) -> Array
    {
        if Index == 0
        {
            return self
        }
        let AdjustedIndex = Index %% self.count
        return Array(self[AdjustedIndex ..< self.count] + self[0 ..< AdjustedIndex])
    }
}

infix operator %%
/// Modulo operator.
/// - Note: See [Shift arrays in Swift](https://stackoverflow.com/questions/31554670/shift-swift-array/44739098)
/// - dividend: The dividend value.
/// - divisor: The divisor value. Fails is 0.
/// - Returns: Infix modulo.
public func %%(_ dividend: Int, _ divisor: Int) -> Int
{
    precondition(divisor > 0, "modulus must be positive")
    let Reminder = dividend % divisor
    return Reminder >= 0 ? Reminder: Reminder + divisor
}
