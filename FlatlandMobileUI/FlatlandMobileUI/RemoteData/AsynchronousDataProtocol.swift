//
//  AsynchronousDataProtocol.swift
//  AsynchronousDataProtocol
//
//  Created by Stuart Rankin on 7/18/21. Adapted from Flatland View.
//

import Foundation

/// Protocol for the communication of the availability of remote/asynchronous data.
protocol AsynchronousDataProtocol: AnyObject
{
    /// Called when remote/asynchronous data is available.
    /// - Parameter CategoryType: The type of available data.
    /// - Parameter Actual: The data that was received. May be nil.
    /// - Parameter StartTime: The time the asynchronous process started.
    /// - Parameter Context: Optional contextual data.
    func AsynchronousDataAvailable(CategoryType: AsynchronousDataCategories, Actual: Any?, StartTime: Double,
                                   Context: Any?)
}

