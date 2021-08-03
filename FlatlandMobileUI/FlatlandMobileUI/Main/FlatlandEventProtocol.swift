//
//  FlatlandEventProtocol.swift
//  Flatland
//
//  Created by Stuart Rankin on 9/27/20. Adapted from Flatland View.
//  Copyright © 2020, 2021 Stuart Rankin. All rights reserved.
//

import Foundation
import UIKit

protocol FlatlandEventProtocol: AnyObject
{
    func NewWorldClockTime(WorldDate: Date)
}
