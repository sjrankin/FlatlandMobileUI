//
//  ImageShiftParameters.swift
//  ImageShiftParameters
//
//  Created by Stuart Rankin on 7/19/21. Adapted from Flatland View.
//

import Foundation
import UIKit
import simd

struct ImageShiftParameters
{
    let XOffset: simd_int1
    let YOffset: simd_int1
    let ImageWidth: simd_uint1
    let ImageHeight: simd_uint1
}
