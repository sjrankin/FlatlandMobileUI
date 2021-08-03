//
//  WordContainer.swift
//  WordContainer
//
//  Created by Stuart Rankin on 7/21/21. Adapted from Flatland View.
//

import Foundation
import UIKit

/// Contains a word for searching.
class WordContainer
{
    /// Initializer.
    /// - Warning: If `Word` is empty, a fatal error is thrown.
    /// - Parameter Word: The word to contain.
    init(_ Word: String)
    {
        if Word.isEmpty
        {
            Debug.FatalError("Empty word passed to WordContainer initializer.")
        }
        OriginalWord = Word
        SearchWord = Word.lowercased()
        Tag = nil
    }
    
    /// Initializer.
    /// - Warning: If `Word` is empty, a fatal error is thrown.
    /// - Parameter Word: The word to contain.
    /// - Parameter Tag: A tag value the caller wants to associate with this word.
    init(_ Word: String, _ Tag: Any?)
    {
        if Word.isEmpty
        {
            Debug.FatalError("Empty word passed to WordContainer initializer.")
        }
        OriginalWord = Word
        SearchWord = Word.lowercased()
        self.Tag = Tag
    }
    
    /// Initializer.
    /// - Warning: If `Word` is empty, a fatal error is thrown.
    /// - Parameter Word: The word to contain.
    /// - Parameter Significance: Determines if case is significant.
    /// - Parameter Tag: A tag value the caller wants to associate with this word.
    init(_ Word: String, _ Significance: Bool, _ Tag: Any?)
    {
        if Word.isEmpty
        {
            Debug.FatalError("Empty word passed to WordContainer initializer.")
        }
        OriginalWord = Word
        if !Significance
        {
            SearchWord = Word.lowercased()
        }
        self.Tag = Tag
        CaseSignificant = Significance
    }
    
    /// The word processed for searching.
    var SearchWord: String = ""
    
    /// The original, unmodified word.
    var OriginalWord: String = ""
    
    /// Tag value the caller may associate with the word.
    var Tag: Any? = nil
    
    /// Sets the case significance flag.
    var CaseSignificant: Bool = false
}
