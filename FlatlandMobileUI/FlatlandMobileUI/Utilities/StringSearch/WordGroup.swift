//
//  WordGroup.swift
//  WordGroup
//
//  Created by Stuart Rankin on 7/21/21. Adapted from Flatland View.
//

import Foundation
import UIKit

/// Contains all words for a contextual group.
class WordGroup
{
    /// Merge another word group with this word group. Duplicate words are discarded.
    /// - Parameter With: The other word group whose contents will be added.
    func Merge(With Other: WordGroup)
    {
        for List in Other.Lists
        {
            for ContainedWord in List.Words
            {
                AddWord(ContainedWord)
            }
        }
    }
    
    /// List of words for the word group.
    var Lists = [WordList]()
    
    /// Return a sorted list of letters that represent each list of words.
    /// - Returns: List of letters, one letter for each list.
    func LetterSet() -> [String]
    {
        var Letters = [String]()
        for List in Lists
        {
            Letters.append(List.Letter)
        }
        Letters.sort()
        return Letters
    }
    
    /// Returns the word list for the specified letter.
    /// - Parameter StartingLetter: The letter used to find the related word list.
    /// - Returns: The word list associated with the passed letter if found, nil if not found.
    func HasLetter(_ StartingLetter: String) -> WordList?
    {
        for List in Lists
        {
            if List.Letter == StartingLetter
            {
                return List
            }
        }
        return nil
    }
    
    /// Add a new word to the word list.
    /// - Parameter Word: Encapsulated word to add.
    func AddWord(_ Word: WordContainer)
    {
        let Start = String(Word.SearchWord.first!)
        if let Existing = HasLetter(Start)
        {
            Existing.AddWord(Word)
        }
        else
        {
            let NewWordList = WordList(Initial: Word)
            Lists.append(NewWordList)
        }
    }
    
    /// Add the passed word to the word group list.
    /// - Warning: Empty words will throw fatal exceptions.
    /// - Parameter Word: The word to add. Duplicate words are discarded. All words are converted to
    ///                   lower case.
    func AddWord(_ Word: String)
    {
        if Word.isEmpty
        {
            Debug.FatalError("Empty word passed to WordGroup.AddWord.")
        }
        let Start = String(Word.first!).lowercased()
        if let Existing = HasLetter(Start)
        {
            Existing.AddWord(Word)
        }
        else
        {
            let NewWordList = WordList(Initial: Word)
            Lists.append(NewWordList)
        }
    }
    
    /// Return a list of words that start with the contents of `Find`.
    /// - Note: All of the words in each word list are sorted before any searching occurs. Provided no other
    ///         words have been added between searches, lists are sorted only once.
    /// - Note: The only character not allowed in the word list or the search for word is **💲**. Note that this
    ///         is *not* a regular **$** character but is the Heavy Dollar Sign emoji character (U+**1f4b2**).
    /// - Parameter Find: The target word used to return a set of potential matches. Only the words preivous
    ///                   added to the instance will be searched. `Find` is converted to lower case before
    ///                   searching occurs.
    /// - Parameter SearchHow: Determines how matches are returned. Defaults to `.StartsWith`. See
    ///                        `StringSearchTypes` for more information.
    /// - Returns: List of words that start with the contents of `Find`. Nil if no matches.
    func MatchingWords(Find: String, SearchHow: StringSearchTypes = .StartsWith) -> [String]?
    {
        if Find.isEmpty
        {
            return nil
        }
        for List in Lists
        {
            List.SortWords()
        }
        var Matched = [String]()
        let FinalFind = Find.lowercased()
        let StartsWith = String(FinalFind.first!)
        if let AlphaSubset = HasLetter(StartsWith)
        {
            for TestMe in AlphaSubset.Words
            {
                if let ZIndex = ZAlgorithm.IndexesOf(SearchFor: FinalFind, SearchIn: TestMe.SearchWord)
                {
                    switch SearchHow
                    {
                        case .StartsWith:
                            if ZIndex.contains(0)
                            {
                                Matched.append(TestMe.OriginalWord)
                            }
                            
                        case .Contains:
                            if ZIndex.count > 0
                            {
                                print("\(Find):ZIndex=\(ZIndex)")
                                Matched.append(TestMe.OriginalWord)
                            }
                    }
                }
            }
            if Matched.count > 0
            {
                return Matched
            }
            else
            {
                return nil
            }
        }
        else
        {
            print("No letter \(StartsWith) found")
            return nil
        }
    }
    
    /// Sort all of the words in all of the lists.
    func SortWords()
    {
        for List in Lists
        {
            List.SortWords()
        }
        Lists = Lists.sorted(by: {$0.Letter < $1.Letter})
    }
}

/// How to search strings
enum StringSearchTypes: String, CaseIterable
{
    /// The string matches when the first substring matches.
    case StartsWith
    /// The string matches when the substring is anywhere in the string.
    case Contains
}
