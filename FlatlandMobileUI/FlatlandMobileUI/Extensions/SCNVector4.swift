//
//  SCNVector4.swift
//  SCNVector4
//
//  Created by Stuart Rankin on 7/19/21.
//

import Foundation
import UIKit
import SceneKit

extension SCNVector4
{
    public func RoundedTo(_ Places: Int) -> String
    {
        let X = "\(self.x.RoundedTo(3))"
        let Y = "\(self.y.RoundedTo(3))"
        let Z = "\(self.z.RoundedTo(3))"
        let W = "\(self.w.RoundedTo(3))"
        return "(x: \(X), y: \(Y), z: \(Z), w: \(W))"
    }
}
