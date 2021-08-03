//
//  WordList.swift
//  WordList
//
//  Created by Stuart Rankin on 7/21/21. Adapted from Flatland View.
//

import Foundation
import UIKit

/// Contains a list of words that, theoretically, all start with the same letter.
class WordList
{
    /// Initializer.
    /// - Warning: If `Initial` is empty, a fatal error is thrown.
    /// - Note: After initialization, all subsequent additions to the word list *must* start with the same
    ///         characters as `Word` or a fatal error will be thrown.
    /// - Parameter Initial: The first word added to the list. The first character of the word is used to determine
    ///                      the letter for the class.
    /// - Parameter Tag: Optional tag value.
    init(Initial Word: String, Tag: Any? = nil)
    {
        if Word.isEmpty
        {
            Debug.FatalError("Tried to add empty word to WordList.")
        }
        let FinalWord = WordContainer(Word)
        _Letter = Word.first!.lowercased()
        _Words.append(FinalWord)
    }
    
    /// Initializer.
    /// - Note: After initialization, all subsequent additions to the word list *must* start with the same
    ///         characters as `Word` or a fatal error will be thrown.
    /// - Parameter Initial: The first word added to the list (in a word container).
    init(Initial Word: WordContainer)
    {
        let SourceWord = Word.SearchWord
        _Letter = SourceWord.first!.lowercased()
        _Words.append(Word)
    }
    
    /// If true, words have been added and the list may not be in sorted order.
    var ShouldSort = false
    
    /// Holds all words for the given letter.
    private var _Words = [WordContainer]()
    /// Get the words being held by the letter.
    public var Words: [WordContainer]
    {
        get
        {
            return _Words
        }
    }
    
    /// Sorts the words. If no words were added since the last sort operation, control returns immediately.
    public func SortWords()
    {
        if !ShouldSort
        {
            return
        }
        _Words.sort(by: {$0.SearchWord < $1.SearchWord})
        ShouldSort = false
    }
    
    /// Determines if the current set of words contains the passed word.
    /// - Parameter FindWord: The word to search for in the list.
    /// - Returns: True if the word is in the list, false if not.
    func ContainsWord(_ FindWord: String) -> Bool
    {
        for Word in _Words
        {
            if Word.CaseSignificant
            {
                if Word.SearchWord == FindWord
                {
                    return true
                }
            }
            else
            {
                if Word.SearchWord == FindWord.lowercased()
                {
                    return true
                }
            }
        }
        return false
    }
    
    /// Add a word to the list of words. Duplicate words are discarded.
    /// - Warning: A fatal error is thrown if `Word` is empty or starts with a character that is not
    ///            the same as the class was initialized with.
    /// - Parameter Word: The word to add. All words are converted to lower case before being added.
    /// - Parameter Tag: Optional tag value.
    public func AddWord(_ Word: String, Tag: Any? = nil)
    {
        if Word.isEmpty
        {
            Debug.FatalError("Tried to add empty word to WordList{\(Letter)}")
        }
        let FirstLetter = Word.first!.lowercased()
        if FirstLetter != Letter
        {
            Debug.FatalError("Word with incorrect starting letter added: bad word is \(Word)")
        }
        if !ContainsWord(Word)
        {
            ShouldSort = true
            let NewWord = WordContainer(Word, false, Tag)
            _Words.append(NewWord)
        }
    }
    
    /// Add a word to the list of words. Duplicate words are discard.
    /// - Parameter Word: A word encapsulated in a `WordContainer` instance.
    public func AddWord(_ Word: WordContainer)
    {
        let FirstLetter = Word.SearchWord.first!.lowercased()
        if FirstLetter != Letter
        {
            Debug.FatalError("Word with incorrect starting letter added: bad word is \(Word.OriginalWord)")
        }
        if !ContainsWord(Word.SearchWord)
        {
            ShouldSort = true
            _Words.append(Word)
        }
    }
    
    /// Add a word then sort the resultant list.
    /// - Warning: A fatal error is thrown if `Word` is empty or starts with a character that is not
    ///            the same as the class was initialized with.
    /// - Note: It is more efficient to add all of the words then sort them when done adding.
    /// - Parameter: Word: The word to add. The word is converted to lower case before being added.
    public func AddThenSortWord(_ Word: String)
    {
        AddWord(Word)
        SortWords()
    }
    
    /// Holds the class' letter.
    private var _Letter = ""
    /// Get the letter represented by the class. Set on initialization by the initial word added.
    public var Letter: String
    {
        get
        {
            return _Letter
        }
    }
}
