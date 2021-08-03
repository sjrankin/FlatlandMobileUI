//
//  ImageBlendParameters.swift
//  ImageBlendParameters
//
//  Created by Stuart Rankin on 7/19/21. Adapted from Flatland View.
//

import Foundation
import UIKit
import simd


struct ImageBlendParameters
{
    let XOffset: simd_uint1
    let YOffset: simd_uint1
    let FinalAlphaPixelIs1: simd_bool
    let HorizontalWrap: simd_bool
    let VerticalWrap: simd_bool
}

