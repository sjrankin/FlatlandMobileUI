//
//  SolidColorParameters.swift
//  SolidColorParameters
//
//  Created by Stuart Rankin on 7/19/21. Adapted from Flatland View.
//

import Foundation
import UIKit
import simd

struct SolidColorParameters
{
    let DrawBorder: simd_bool
    let BorderThickness: simd_uint1
    let BorderColor: simd_float4
    let Fill: simd_float4
}
