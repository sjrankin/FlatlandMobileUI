//
//  UUID.swift
//  UUID
//
//  Created by Stuart Rankin on 7/18/21. Adapted from Flatland View.
//

import Foundation
import UIKit

extension UUID
{
    /// Returns an empty UUID.
    /// - Note: "Empty" means a UUID with all `0` values.
    public static var Empty: UUID
    {
        get
        {
            return UUID(uuidString: "00000000-0000-0000-0000-000000000000")!
        }
    }
}
