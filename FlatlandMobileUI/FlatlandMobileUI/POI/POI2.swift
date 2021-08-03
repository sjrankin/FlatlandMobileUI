//
//  POI2.swift
//  POI2
//
//  Created by Stuart Rankin on 7/18/21. Adapted from Flatland View.
//

import Foundation
import UIKit

/// Contains information from the Point of Interest database.
class POI2
{
    /// Default initializer.
    init()
    {
        DeleteMe = false
        _IsDirty = false
        _IsNew = true
    }
    
    /// Initializer
    /// - Parameters:
    ///   - Meta: Meta POI type.
    ///   - PKID: Database ID of the item.
    ///   - ID: Logical ID of the item.
    ///   - Name: Name of the item.
    ///   - Description: Description of the item.
    ///   - Latitude: Latitude of the POI.
    ///   - Longitude: Longitude of the POI.
    ///   - Color: Color of the POI.
    ///   - Shape: Shape of the POI.
    ///   - POIType: Type of the POI.
    ///   - Numeric: Not currently used.
    ///   - Category: Category of the POI.
    ///   - SubCategory: Sub-category of the POI.
    ///   - Added: When the POI was added.
    ///   - Modified: When the POI was modified.
    init(Meta: POIMetaTypes, _ PKID: Int, _ ID: UUID, _ Name: String, _ Description: String,
         _ Latitude: Double, _ Longitude: Double, _ Color: UIColor, _ Shape: String,
         _ POIType: Int, _ Numeric: Double, _ Category: String? = nil, _ SubCategory: String? = nil,
         _ Added: Date? = nil, _ Modified: Date? = nil, _ Show: Bool = true)
    {
        MetaType = Meta
        self.PKID = PKID
        _Name = Name
        _ID = ID
        _Description = Description
        _Latitude = Latitude
        _Longitude = Longitude
        _Color = Color
        _Shape = Shape
        _POIType = POIType
        _Numeric = Numeric
        _Category = Category
        _SubCategory = SubCategory
        _Added = Added
        _Modified = Modified
        DeleteMe = false
        _IsDirty = false
        _IsNew = false
        _Show = Show
    }
    
    /// Initializer
    /// - Parameters:
    ///   - Meta: Meta POI type.
    ///   - PKID: Database ID of the item.
    ///   - ID: Logical ID of the item.
    ///   - Name: Name of the item.
    ///   - Description: Description of the item.
    ///   - Latitude: Latitude of the POI.
    ///   - Longitude: Longitude of the POI.
    ///   - Color: Color of the POI.
    ///   - Shape: Shape of the POI.
    ///   - POIType: Type of the POI.
    ///   - Numeric: Not currently used.
    ///   - Category: Category of the POI.
    ///   - SubCategory: Sub-category of the POI.
    ///   - Added: When the POI was added.
    ///   - Modified: When the POI was modified.
    init(Meta: POIMetaTypes, _ ID: UUID, _ Name: String, _ Description: String,
         _ Latitude: Double, _ Longitude: Double, _ Color: String, _ Shape: String,
         _ POIType: Int, _ Numeric: Double, _ Category: String? = nil, _ SubCategory: String? = nil,
         _ Added: Date? = nil, _ Modified: Date? = nil, _ Show: Bool = true)
    {
        MetaType = Meta
        self.PKID = -1
        _Name = Name
        _ID = ID
        _Description = Description
        _Latitude = Latitude
        _Longitude = Longitude
        _Color = UIColor(HexString: Color)!
        _Shape = Shape
        _POIType = POIType
        _Numeric = Numeric
        _Category = Category
        _SubCategory = SubCategory
        _Added = Added
        _Modified = Modified
        DeleteMe = false
        _IsDirty = false
        _IsNew = true
        _Show = Show
    }
    
    init(Meta: POIMetaTypes, _ PK: Int, _ ID: UUID, _ Name: String, _ Description: String,
         _ Latitude: Double, _ Longitude: Double, _ Color: UIColor, _ POIType: Int,
         _ Numeric: Double, _ Added: Date? = nil, _ Modified: Date? = nil,
         _ Show: Bool = true)
    {
        MetaType = Meta
        self.PKID = PK
        _Name = Name
        _ID = ID
        _Description = Description
        _Latitude = Latitude
        _Longitude = Longitude
        _Color = Color
        _POIType = POIType
        _Numeric = Numeric
        _Added = Added
        _Modified = Modified
        DeleteMe = false
        _IsDirty = false
        _IsNew = true
        _Show = Show
    }
    
    /// Call after a dirty POI instance has been saved to reset dirty flags.
    func Saved()
    {
        _IsDirty = false
        DeleteMe = false
        _IsNew = false
    }
    
    var PKID: Int = 0
    
    var _ID: UUID = UUID()
    {
        didSet
        {
            _IsDirty = true
        }
    }
    var ID: UUID
    {
        get
        {
            return _ID
        }
        set
        {
            _ID = newValue
        }
    }
    
    var _Name: String = ""
    {
        didSet
        {
            _IsDirty = true
        }
    }
    var Name: String
    {
        get
        {
            return _Name
        }
        set
        {
            _Name = newValue
        }
    }
    
    var _Show: Bool = true
    {
        didSet
        {
            _IsDirty = true
        }
    }
    var Show: Bool
    {
        get
        {
            return _Show
        }
        set
        {
            _Show = newValue
        }
    }
    
    var _Description: String = ""
    {
        didSet
        {
            _IsDirty = true
        }
    }
    var Description: String
    {
        get
        {
            return _Description
        }
        set
        {
            _Description = newValue
        }
    }
    
    var _Latitude: Double = 0.0
    {
        didSet
        {
            _IsDirty = true
        }
    }
    var Latitude: Double
    {
        get
        {
            return _Latitude
        }
        set
        {
            _Latitude = newValue
        }
    }
    
    var _Longitude: Double = 0.0
    {
        didSet
        {
            _IsDirty = true
        }
    }
    var Longitude: Double
    {
        get
        {
            return _Longitude
        }
        set
        {
            _Longitude = newValue
        }
    }
    
    var _Color: UIColor = UIColor.red
    {
        didSet
        {
            _IsDirty = true
        }
    }
    var Color: UIColor
    {
        get
        {
            return _Color
        }
        set
        {
            _Color = newValue
        }
    }
    
    var _Shape: String = ""
    {
        didSet
        {
            _IsDirty = true
        }
    }
    var Shape: String
    {
        get
        {
            return _Shape
        }
        set
        {
            _Shape = newValue
        }
    }
    
    var _POIType: Int = 0
    {
        didSet
        {
            _IsDirty = true
        }
    }
    var POIType: Int
    {
        get
        {
            return _POIType
        }
        set
        {
            _POIType = newValue
        }
    }
    
    var MetaType: POIMetaTypes = .Home
    
    var _Numeric: Double = 0.0
    {
        didSet
        {
            _IsDirty = true
        }
    }
    var Numeric: Double
    {
        get
        {
            return _Numeric
        }
        set
        {
            _Numeric = newValue
        }
    }
    
    var _Category: String? = nil
    {
        didSet
        {
            _IsDirty = true
        }
    }
    var Category: String?
    {
        get
        {
            return _Category
        }
        set
        {
            _Category = newValue
        }
    }
    
    var _SubCategory: String? = nil
    {
        didSet
        {
            _IsDirty = true
        }
    }
    var SubCategory: String?
    {
        get
        {
            return _SubCategory
        }
        set
        {
            _SubCategory = newValue
        }
    }
    
    var _Added: Date? = nil
    {
        didSet
        {
            _IsDirty = true
        }
    }
    var Added: Date?
    {
        get
        {
            return _Added
        }
        set
        {
            _Added = newValue
        }
    }
    
    var _Modified: Date? = nil
    {
        didSet
        {
            _IsDirty = true
        }
    }
    var Modified: Date?
    {
        get
        {
            return _Modified
        }
        set
        {
            _Modified = newValue
        }
    }
    
    var _IsDirty = false
    var IsDirty: Bool
    {
        get
        {
            return _IsDirty
        }
    }
    
    var _IsNew = false
    var IsNew: Bool
    {
        get
        {
            return _IsNew
        }
        set
        {
            _IsNew = newValue
        }
    }
    
    var DeleteMe: Bool = false
}

enum POIMetaTypes: String, CaseIterable
{
    case Home = "Home"
    case User = "UserPOI"
    case Standard = "StandardPOI"
}
