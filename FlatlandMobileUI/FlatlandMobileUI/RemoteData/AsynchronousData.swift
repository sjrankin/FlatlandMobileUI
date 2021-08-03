//
//  AsynchronousData.swift
//  AsynchronousData
//
//  Created by Stuart Rankin on 7/18/21. Adapted from Flatland View.
//

import Foundation
import UIKit

class AsynchronousData
{
    var Category: AsynchronousDataCategories = .Earthquakes
    var DataType: AsynchronousDataTypes = .None
    
    var Raw: [Any]? = nil
}

enum AsynchronousDataTypes: String, CaseIterable
{
    case None = "None"
    case Point = "Point"
    case Area = "Area"
}
