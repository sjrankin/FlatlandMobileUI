//
//  +Threading.swift
//  Flatland
//
//  Created by Stuart Rankin on 1/15/21.
//  Copyright © 2021 Stuart Rankin. All rights reserved.
//

import Foundation
import UIKit

extension MainController
{
    /// Try to kill any background threads that may be running.
    func ForceKillThreads()
    {
        if let StencilQueue = Stenciler.StencilingQueue
        {
            if !StencilQueue.isSuspended
            {
                Debug.Print("Canceling stencil queue.")
                StencilQueue.cancelAllOperations()
            }
        }
        if let QuakeQueue = Earthquakes?.RetrievalQueue
        {
            if !QuakeQueue.isSuspended
            {
                Debug.Print("Canceling earthquake queue.")
                QuakeQueue.cancelAllOperations()
            }
        }
    }
}
