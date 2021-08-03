//
//  WorldHeritageSite.swift
//  WorldHeritageSite
//
//  Created by Stuart Rankin on 7/19/21. Adapted from Flatland.
//

import Foundation
import UIKit

/// Encapsulates a single world heritage site.
class WorldHeritageSite
{
    /// Initializer.
    /// - Parameter UID: UID value.
    /// - Parameter ID: ID value.
    /// - Parameter Name: The name of the site.
    /// - Parameter Year: The year the site was inscribed.
    /// - Parameter Latitude: The latitude of the site.
    /// - Parameter Longitude: The longitude of the site.
    /// - Parameter Hectares: The size of the site.
    /// - Parameter Category: The site category.
    /// - Parameter ShortCategory: The shorter site category name.
    /// - Parameter Countries: The counties of the site.
    /// - Parameter RuntimeID: The ID used at runtime.
    init(_ UID: Int, _ ID: Int, _ Name: String, _ Year: Int, _ Latitude: Double,
         _ Longitude: Double, _ Hectares: Double, _ Category: String,
         _ ShortCategory: String, _ Countries: String, _ RuntimeID: UUID)
    {
        self.UID = UID
        self.ID = ID
        self.Name = Name
        self.DateInscribed = Year
        self.Latitude = Latitude
        self.Longitude = Longitude
        self.Hectares = Hectares
        self.Category = Category
        self.ShortCategory = ShortCategory
        self.Countries = Countries
        self.RuntimeID = RuntimeID
    }
    
    var UID: Int = 0
    var ID: Int = 0
    private var _Name: String = ""
    var Name: String
    {
        get
        {
            return _Name
        }
        set
        {
            _Name = newValue.replacingOccurrences(of: "\\", with: "")
        }
    }
    var DateInscribed: Int = 0
    var Longitude: Double = 0.0
    var Latitude: Double = 0.0
    var Hectares: Double? = nil
    var Category: String = ""
    var ShortCategory: String = ""
    var Countries: String = ""
    var RuntimeID: UUID?
    {
        didSet
        {
            RuntimeID = oldValue ?? RuntimeID
        }
    }
}
