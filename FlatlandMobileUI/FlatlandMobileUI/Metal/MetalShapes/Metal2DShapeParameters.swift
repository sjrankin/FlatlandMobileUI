//
//  Metal2DShapeParameters.swift
//  Metal2DShapeParameters
//
//  Created by Stuart Rankin on 7/19/21.
//

import Foundation
import UIKit
import simd

struct ShapeParameters
{
    let CircleRadius: simd_uint1
    let BackgroundColor: simd_float4
    let InteriorColor: simd_float4
    let BorderWidth: simd_uint1
    let BorderColor: simd_float4
}
