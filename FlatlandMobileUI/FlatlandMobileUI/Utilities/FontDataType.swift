//
//  FontDataType.swift
//  FontDataType
//
//  Created by Stuart Rankin on 7/20/21. Adapted from Flatland View.
//

import Foundation
import UIKit

/// Class used to manage the font picker.
class FontDataType
{
    /// Initializer.
    /// - Parameter FamilyName: Font family name.
    init(_ FamilyName: String)
    {
        FontFamilyName = FamilyName
    }
    
    /// The font family name.
    var FontFamilyName: String = ""
    
    /// Font variants. Array of tuples with the first element as the style, and the second element as the
    /// Postscript font name.
    var Variants: [(Style: String, Postscript: String)] = [(String, String)]()
}

/// Class used to serialize and deserialize font information to user settings.
class StoredFont: CustomStringConvertible
{
    /// Default initializer.
    init()
    {
    }
    
    /// Initializer. Should be used when deserialized saved font information.
    /// - Parameter RawValue: The raw, saved value.
    /// - Returns: Nil on error.
    init?(RawValue: String)
    {
        if !ParseRaw(RawValue)
        {
            return nil
        }
    }
    
    /// Initializer.
    /// - Parameter Name: The Postscript font name.
    /// - Parameter Size: The size of the font. Defaults to 24.0.
    /// - Parameter Color: The color of the font. Defaults to black.
    init(_ Name: String, _ Size: CGFloat = 24.0, _ Color: UIColor = UIColor.black)
    {
        PostscriptName = Name
        FontSize = Size
        FontColor = Color
    }
    
    /// Parse a raw serialized string.
    /// - Parameter Raw: The raw string to parse. The format of the string is: `Postscript Name,FontSize,FontColor`
    ///                  where `Fontsize` is a double and `FontColor` is a `#`-prefixed hex value of a color.
    /// - Returns: True on success, false on failure.
    func ParseRaw(_ Raw: String) -> Bool
    {
        if Raw.isEmpty
        {
            print("Parsing raw font: empty raw string.")
            return false
        }
        let Parts = Raw.split(separator: ",", omittingEmptySubsequences: true)
        if Parts.count != 3
        {
            print("Parsing raw font: insufficient sub-strings")
            return false
        }
        PostscriptName = String(Parts[0])
        if let DVal = Double(String(Parts[1]))
        {
            FontSize = CGFloat(DVal)
        }
        else
        {
            print("Parsing raw font: bad font size")
            return false
        }
        if let Color = UIColor(HexString: String(Parts[2]))
        {
            FontColor = Color
        }
        else
        {
            print("Parsing raw font: cannot create color")
            return false
        }
        return true
    }
    
    /// Serializes the contents of the class.
    /// - Returns: String of the serialized contents of the class. See `ParseRaw` for the format.
    func SerializeFont() -> String
    {
        var Final = ""
        Final.append(PostscriptName)
        Final.append(",")
        Final.append("\(FontSize)")
        Final.append(",")
        Final.append("\(FontColor.Hex)")
        return Final
    }
    
    /// The Postscript file name of the font.
    var PostscriptName: String = ""
    
    /// The font size.
    var FontSize: CGFloat = 12.0
    
    /// The font color.
    var FontColor: UIColor = UIColor.black
    
    var description: String
    {
        return "\(PostscriptName),\(FontSize),\(FontColor.Hex)"
    }
    
    /// Return the stored font as an UIFont.
    /// - Returns: `UIFont` equivalent of the stored font.
    func AsFont() -> UIFont
    {
        if PostscriptName.isEmpty
        {
            return UIFont()
        }
        return UIFont(name: PostscriptName, size: FontSize)!
    }
}
