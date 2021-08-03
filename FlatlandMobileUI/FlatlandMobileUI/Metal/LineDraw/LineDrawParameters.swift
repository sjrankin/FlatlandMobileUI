//
//  LineDrawParameters.swift
//  LineDrawParameters
//
//  Created by Stuart Rankin on 7/19/21. Adapted from Flatland View.
//

import Foundation
import UIKit
import simd

struct LineDrawParameters
{
    let IsHorizontal: simd_bool
    let HorizontalAt: simd_uint1
    let VerticalAt: simd_uint1
    let Thickness: simd_uint1
    let LineColor: simd_float4
}

struct LineArray
{
    let Count: simd_uint1
    let Lines: [LineDrawParameters]
}
