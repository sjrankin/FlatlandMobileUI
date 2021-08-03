//
//  +StoredFont.swift
//  +StoredFont
//
//  Created by Stuart Rankin on 7/19/21. Adapted from Flatland View.
//

import Foundation
import UIKit

extension Settings
{
    // MARK: - Font settings.
    
    /// Return a stored font object.
    /// - Note: Stored fonts are stored in serialized form. Serialized stored fonts are strings. So therefore,
    ///         if no string can be found, nil is returned.
    /// - Parameter Setting: Where the stored font resides.
    /// - Returns: Deserialized stored string on success, nil if not found.
    public static func GetFont(_ Setting: SettingKeys) -> StoredFont?
    {
        if let Raw = Settings.GetString(Setting)
        {
            return StoredFont(RawValue: Raw)
        }
        return nil
    }
    
    /// Return a stored font object.
    /// - Parameter Setting: Where the stored font resides.
    /// - Parameter Default: The default to use if no stored font is found. If no stored font is found, the
    ///                      default is written to user settings.
    /// - Returns: The stored font at the specified setting, `Default` if not found.
    public static func GetFont(_ Setting: SettingKeys, _ Default: StoredFont) -> StoredFont
    {
        if let Stored = GetFont(Setting)
        {
            return Stored
        }
        SetFont(Setting, Default)
        return Default
    }
    
    /// Save a stored font object.
    /// - Parameter Setting: Where to save the stored font.
    /// - Paramater Value: The stored font to save. It is serialized before being saved.
    public static func SetFont(_ Setting: SettingKeys, _ Value: StoredFont)
    {
        let PreviousFont = GetFont(Setting)
        let Serialized = Value.SerializeFont()
        UserDefaults.standard.set(Serialized, forKey: Setting.rawValue)
        NotifySubscribers(Setting: Setting, OldValue: PreviousFont, NewValue: Value)
    }
    
    /// Extract the font name from a saved font record. Font records have the name as the first item in the
    /// font record.
    /// - Parameter From: The font record from which the font name will be extracted.
    /// - Returns: The name of the font from the passed font record. Nil on error.
    public static func ExtractFontName(From Saved: String) -> String?
    {
        let Parts = Saved.split(separator: ",", omittingEmptySubsequences: true)
        if Parts.count < 1
        {
            return nil
        }
        let Part = String(Parts[0])
        return Part
    }
    
    /// Extract the font size from a saved font record. Font records have the size as the second item in the
    /// font record.
    /// - Parameter From: The font record from which the font size will be extracted.
    /// - Returns: The size of the font from the passed font record. Nil on error.
    public static func ExtractFontSize(From Saved: String) -> CGFloat?
    {
        let Parts = Saved.split(separator: ",", omittingEmptySubsequences: true)
        if Parts.count < 2
        {
            return nil
        }
        let Part = String(Parts[1])
        if let DFontSize = Double(Part)
        {
            return CGFloat(DFontSize)
        }
        return nil
    }
}
