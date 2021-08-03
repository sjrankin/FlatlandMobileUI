//
//  POIManager.swift
//  POIManager
//
//  Created by Stuart Rankin on 7/18/21. Adapted from Flatland View.
//

import Foundation
import UIKit

class POIManager
{
    public static func Initialize()
    {
        //AllPOIs = MainController.GetAllPOIs()
    }
    
    public static var AllPOIs: [POI]? = nil
    
    public static func GetPOIs(By POIType: POITypes) -> [POI]
    {
        if AllPOIs == nil
        {
            return [POI]()
        }
        var Result = [POI]()
        for SomePOI in AllPOIs!
        {
            if SomePOI.POIType == POIType.rawValue
            {
                Result.append(SomePOI)
            }
        }
        return Result
    }
}
