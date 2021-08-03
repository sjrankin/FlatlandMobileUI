//
//  ZAlgorithm.swift
//  ZAlgorithm
//
//  Created by Stuart Rankin on 7/21/21. Adapted from Flatland View.
//

import Foundation
import UIKit

/// Implementes the Z-Algorithm for substring searching.
class ZAlgorithm
{
    /// Returns an array of all indices in `SearchIn` where the substring `SearchFor` is.
    /// - Parameter SearchFor: The substring to search for in the (presumably) larger `SearchIn`.
    /// - Parameter SearchIn: The target text that is searched for substrings.
    /// - Returns: Array of indices where `SearchFor` is in `SearchIn`. Nil if the substring was not found
    ///            in `SearchFor`.
    public static func IndexesOf(SearchFor: String, SearchIn: String) -> [Int]?
    {
        let PatternLength: Int = SearchFor.count
        //Calculate the Z-Algorithm on the concatenation of pattern and text.
        let ZArray = Z_Algorithm(SearchFor + "💲" + SearchIn)
        
        guard ZArray != nil else
        {
            return nil
        }
        
        var IndexArray = [Int]()
        
        //Scan the zeta array to find matched patterns.
        for i in 0 ..< ZArray!.count
        {
            if ZArray![i] == PatternLength
            {
                IndexArray.append(i - PatternLength - 1)
            }
        }
        
        guard !IndexArray.isEmpty else
        {
            return nil
        }
        
        return IndexArray
    }
    
    /// Creates an array of substring values for the passed string.
    /// - Note: See [Z-Algorithm](https://github.com/raywenderlich/swift-algorithm-club/tree/master/Z-Algorithm) in the
    ///         Swift Algorithm Club.
    /// - Parameter Pattern: The string that will eventually be searched for substring.
    /// - Returns: Array of substring counts. Nil if `Pattern` is empty.
    private static func Z_Algorithm(_ Pattern: String) -> [Int]?
    {
        let PatternArray = Array(Pattern)
        let patternLength: Int = PatternArray.count
        
        guard patternLength > 0 else
        {
            return nil
        }
        
        var zeta: [Int] = [Int](repeating: 0, count: patternLength)
        
        var left: Int = 0
        var right: Int = 0
        var k_1: Int = 0
        var betaLength: Int = 0
        var textIndex: Int = 0
        var patternIndex: Int = 0
        
        for k in 1 ..< patternLength
        {
            if k > right
            {
                //Outside a Z-box: compare the characters until mismatch.
                patternIndex = 0
                
                while k + patternIndex < patternLength  &&
                        PatternArray[k + patternIndex] == PatternArray[patternIndex]
                {
                    patternIndex = patternIndex + 1
                }
                
                zeta[k] = patternIndex
                
                if zeta[k] > 0
                {
                    left = k
                    right = k + zeta[k] - 1
                }
            }
            else
            {
                //Inside a Z-box.
                k_1 = k - left + 1
                betaLength = right - k + 1
                
                if zeta[k_1 - 1] < betaLength
                {
                    //Entirely inside a Z-box: we can use the values computed before.
                    zeta[k] = zeta[k_1 - 1]
                }
                else
                {
                    if zeta[k_1 - 1] >= betaLength
                    {
                        //Not entirely inside a Z-box: we must proceed with comparisons too.
                        textIndex = betaLength
                        patternIndex = right + 1
                        
                        while patternIndex < patternLength &&
                                PatternArray[textIndex] == PatternArray[patternIndex]
                        {
                            textIndex = textIndex + 1
                            patternIndex = patternIndex + 1
                        }
                        
                        zeta[k] = patternIndex - k
                        left = k
                        right = patternIndex - 1
                    }
                }
            }
        }
        return zeta
    }
}

