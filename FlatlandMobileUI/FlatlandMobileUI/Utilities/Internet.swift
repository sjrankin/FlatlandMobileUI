//
//  Internet.swift
//  Flatland
//
//  Created by Stuart Rankin on 11/27/20. Adapted from Flatland View.
//  Copyright © 2020 Stuart Rankin. All rights reserved.
//

import Foundation
import UIKit
import Network

class Internet
{
    /// Determines if the computer is connected to the internet.
    /// - Note: See [iOS Tutorial Check Internet Connection](https://daddycoding.com/2020/03/04/ios-tutorial-check-internet-connection-with-nwpathmonitor/)
    /// - Parameter Completion: Closure called on status change.
    public static func IsAvailable(_ Completion: ((Bool) -> Void)? = nil)
    {
        let Monitor = NWPathMonitor()
        let Queue = DispatchQueue(label: "Monitor")
        Monitor.pathUpdateHandler = {Path in
            if Path.status == .satisfied
            {
                Completion?(true)
            }
            else
            {
                Completion?(false)
            }
        }
        Monitor.start(queue: Queue)
    }
}
