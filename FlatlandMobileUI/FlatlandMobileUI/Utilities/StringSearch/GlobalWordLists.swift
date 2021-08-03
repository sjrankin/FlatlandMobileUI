//
//  GlobalWordLists.swift
//  GlobalWordLists
//
//  Created by Stuart Rankin on 7/21/21. Adapted from Flatland View.
//

import Foundation
import UIKit

/// Class that maintains a global list of names/words/phrases that can be searched.
class GlobalWordLists
{
    /// Holds the list of lists of lists.
    private static var GlobalList: [GlobalWords: WordGroup] = [GlobalWords: WordGroup]()
    
    /// Add a global word list for the specified global world class.
    /// - Parameter For: The class of global words.
    /// - Parameter WordList: The word group/list for the class.
    public static func AddGlobalWordList(For: GlobalWords, WordList: WordGroup)
    {
        if GlobalList[For] == nil
        {
            GlobalList[For] = WordList
        }
        else
        {
            Debug.Print("\(For) already contains word list.")
        }
    }
    
    /// Remove the global word list for the specified word class.
    /// - Parameter For: Determines which global word list is removed.
    public static func RemoveGlobalWordList(For: GlobalWords)
    {
        GlobalList.removeValue(forKey: For)
    }
    
    /// Returns the global word list for the specified word class.
    /// - Parameter For: The class that determines which global word list will be returned.
    /// - Returns: The group of words for the specified global word class on success, nil
    ///            if not found.
    public static func WordList(For: GlobalWords) -> WordGroup?
    {
        return GlobalList[For]
    }
    
    /// Returns a selected set of word lists from the global word lists.
    /// - Parameter For: Array of global word list classes to return as a single `WordGroup` instance.
    /// - Returns: `WordGroup` instance with all of the passed word list classes. If a given
    ///            class does not exist, no action is taken. If `For` is empty, nil is returned.
    ///            If no data exists, an empty `WordGroup` instance is returned.
    public static func WordList(For: [GlobalWords]) -> WordGroup?
    {
        if For.isEmpty
        {
            return nil
        }
        let BigWordGroup = WordGroup()
        for SomeGroup in For
        {
            if let TheGroup = GlobalList[SomeGroup]
            {
                BigWordGroup.Merge(With: TheGroup)
            }
        }
        return BigWordGroup
    }
}

/// Classes of global words.
enum GlobalWords: String, CaseIterable
{
    /// City names.
    case CityNames = "City Names"
    /// Additional city names.
    case AdditionalCityNames = "Additional Cities"
    /// Point of interest names.
    case POINames = "Point of Interest Names"
    /// UNESCO site names.
    case UNESCOSiteNames = "UNESCO Site Names"
}
