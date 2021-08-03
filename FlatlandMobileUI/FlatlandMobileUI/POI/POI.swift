//
//  POI.swift
//  POI
//
//  Created by Stuart Rankin on 7/18/21. Adapted from Flatland View.
//

import Foundation
import UIKit

/// Defines a point of interest location.
class POI
{
    /// Initializer.
    /// - Parameters:
    ///   - ID: POI ID (_not_ the primary key).
    ///   - Name: Name of the POI.
    ///   - Latitude: Latitude of the POI.
    ///   - Longitude: Longitude of the POI.
    ///   - Description: Description of the POI.
    ///   - Numeric: Numeric value - usage to be determined.
    ///   - POIType: Type of POI.
    ///   - Color: The color of the POI.
    init(_ ID: UUID, _ Name: String, _ Latitude: Double, _ Longitude: Double,
         _ Description: String, _ Numeric: Double, _ POIType: Int, _ Color: UIColor)
    {
        self.POIID  = ID
        self.Name = Name
        self.Latitude = Latitude
        self.Longitude = Longitude
        self.Description = Description
        self.Numeric = Numeric
        self.POIType = POIType
        self.POIColor = Color
    }
    
    /// Primary database key for the POI entry.
    var DBID: Int = 0
    
    /// ID of the POI.
    var POIID: UUID = UUID()
    
    /// Name of the POI.
    var Name = ""
    
    /// Latitude of the POI.
    var Latitude: Double = 0.0
    
    /// Longitude of the POI.
    var Longitude: Double = 0.0
    
    /// Description of the POI.
    var Description: String = ""
    
    /// Numeric value associated with the POI.
    var Numeric: Double = 0.0
    
    /// POI general type.
    var POIType: Int = 0
    //var POIType: POITypes = .Standard
    
    /// Date POI was added.
    var POIAdded: Date? = nil
    
    /// Date POI was modified.
    var POIModified: Date? = nil
    
    /// The color of the POI.
    var POIColor: UIColor = UIColor.white
}

/// Types of points-of-interest.
enum POITypes: Int, CaseIterable
{
    /// Standard, built-in POIs.
    case Standard = 0
    /// User-defined POIs.
    case UserPOI = 1
    /// Home location(s).
    case Home = 2
}

