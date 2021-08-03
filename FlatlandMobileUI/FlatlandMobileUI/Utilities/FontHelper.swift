//
//  FontHelper.swift
//  Flatland
//
//  Created by Stuart Rankin on 7/8/20. Adapted from Flatland View.
//  Copyright © 2020 - 2021 Stuart Rankin. All rights reserved.
//

import Foundation
import UIKit

/// Font-related helper functions.
class FontHelper
{
    /// Initialize data tables.
    static func Initialize()
    {
        GetFontList()
    }
    
    public static func GetFontList()
    {
        for Family in UIFont.familyNames
        {
            let FD = FontDataType(Family)
            for FontName in UIFont.fontNames(forFamilyName: Family)
            {
                FD.Variants.append((Family, FontName))
            }
            FontData.append(FD)
        }
        FontData.sort(by: {$0.FontFamilyName.caseInsensitiveCompare($1.FontFamilyName) == .orderedAscending})
    }
    
    /// Holds the font data table.
    private static var _FontData: [FontDataType] = [FontDataType]()
    /// Get or set the table of fonts.
    public static var FontData: [FontDataType]
    {
        get
        {
            return _FontData
        }
        set
        {
            _FontData = newValue
        }
    }
    
    /// Find the font family name for the passed Postscript name.
    /// - Parameter Postscript: The Postscript font name.
    /// - Returns: The font family associated with `Postscript` on success, nil if not found.
    public static func FontFamilyForPostscriptFile(_ Postscript: String) -> String?
    {
        if let CachedName = FontFamilyNameCache[Postscript]
        {
            return CachedName
        }
        for FData in FontData
        {
            for (_, PSName) in FData.Variants
            {
                if PSName.compare(Postscript) == .orderedSame
                {
                    FontFamilyNameCache[Postscript] = FData.FontFamilyName
                    return FData.FontFamilyName
                }
            }
        }
        return nil
    }
    
    /// Cache for searched Postscript font family names.
    private static var FontFamilyNameCache = [String: String]()
    
    /// Given a font family and Postscript name, return the style name of the Postscript
    /// font.
    /// - Parameter In: The font's family name.
    /// - Parameter Postscript: The Postscript name whose style name will be returned.
    /// - Returns: The style name of the passed Postscript font on success, nil if not found.
    public static func PostscriptStyle(In Family: String, Postscript: String) -> String?
    {
        if let FamilyFont = GetFamily(Family)
        {
            for (Style, PSName) in FamilyFont.Variants
            {
                if PSName == Postscript
                {
                    return Style
                }
            }
        }
        return nil
    }
    
    /// Given a font family name, return its data.
    /// - Parameter Name: The font family name whose data will be returned.
    /// - Returns: The font data related to the passed font family name on success, nil
    ///            if not found.
    public static func GetFamily(_ Name: String) -> FontDataType?
    {
        for FData in FontData
        {
            if FData.FontFamilyName == Name
            {
                return FData
            }
        }
        return nil
    }
    
    /// Given a font family name, return its font data from the passed list of fonts.
    /// - Parameter FontFamily: The name of the font family whose data will be returned.
    /// - Parameter In: The array of fonts to search.
    /// - Returns: The `FontDataType` for the specified font family on success, nil if not found.
    public static func FontDataFor(_ FontFamily: String, In Families: [FontDataType]) -> FontDataType?
    {
        for FData in Families
        {
            if FData.FontFamilyName == FontFamily
            {
                return FData
            }
        }
        return nil
    }
    
    /// Given a font family name and a list of font data, return the index of the font whose font family
    /// matches the passed name.
    /// - Note: This function does an exact match so it is case sensitive.
    /// - Parameter FontFamily: The name of the font family the caller is searching for.
    /// - Parameter In: The array of font data to search.
    /// - Returns: The index in `In` of the font data that has a font family name of `FontFamily`. Nil
    ///            if not found.
    public static func FamilyIndex(_ FontFamily: String, In Families: [FontDataType]) -> Int?
    {
        var Index = 0
        for FData in Families
        {
            if FData.FontFamilyName == FontFamily
            {
                return Index
            }
            Index = Index + 1
        }
        return nil
    }
    
    /// Given a Postscript font name, return its index in the passed `FontDataType`.
    /// - Parameter PostscriptName: The name of the Postscript font whose index the caller wants.
    /// - Parameter In: The font data to search.
    /// - Returns: The index of the Postscript font name in the passed `FontDataType` on success, nil
    ///            if not found.
    public static func StyleIndex(_ PostscriptName: String, In FontData: FontDataType) -> Int?
    {
        var Index = 0
        for Variant in FontData.Variants
        {
            if Variant.Postscript == PostscriptName
            {
                return Index
            }
            Index = Index + 1
        }
        return nil
    }
    
    /// Given a Postscript font name, return a pretty font name consisting of the font family and style.
    /// - Parameter From: The Postscript font name.
    /// - Returns: Pretty font name in the form `Font Family` `Font Style`. Nil return on error.
    public static func PrettyFontName(From PSName: String) -> String?
    {
        if let FamilyName = FontFamilyForPostscriptFile(PSName)
        {
            if let FontStyle = PostscriptStyle(In: FamilyName, Postscript: PSName)
            {
                return "\(FamilyName) \(FontStyle)"
            }
        }
        return nil
    }
}
