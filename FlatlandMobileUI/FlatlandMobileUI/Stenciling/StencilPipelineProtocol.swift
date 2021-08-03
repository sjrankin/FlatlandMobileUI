//
//  StencilPipelineProtocol.swift
//  Flatland
//
//  Created by Stuart Rankin on 11/22/20.
//  Copyright © 2020 Stuart Rankin. All rights reserved.
//

import Foundation
import UIKit

/// Protocol that consumers of stenciled images must conform to when using the pipeline stenciler.
protocol StencilPipelineProtocol: AnyObject
{
    /// Called when a given pipeline stage has been completed.
    /// - Parameter Image: The image after having undergone stenciling at the specified pipeline stage. If
    ///                    nil, an error occurred.
    /// - Parameter Stage: The completed stage. If nil, an error occurred and `Image` is undefined.
    /// - Parameter Time: The time in seconds from the start of the pipeline execution. If nil, `Image` is
    ///                   undefined.
    func StageCompleted(_ Image: UIImage?, _ Stage: StencilStages?, _ Time: Double?)
    
    /// Called at the start of the pipeline process.
    /// - Parameter Time: The start time of the pipeline process. It is not intended to be used directly but
    ///                   as the base to the returned time from `StencilPipelineCompleted`.
    func StencilPipelineStarted(Time: Double)
    
    /// Called a tthe end of the pipeline process.
    /// - Parameter Time: The end time of the pipeline process. To determine duration, subtract the value from
    ///                   `StencilPipelineStarted` from this value to get the duration in seconds.
    /// - Parameter Final: The last image from the pipeline. If nil, an error occurred.
    func StencilPipelineCompleted(Time: Double, Final: UIImage?)
    
    func StencilPipelineCompleted2(_ Context: StencilContext)
    
    func StencilStageCompleted2(_ Context: StencilContext, _ Stage: StencilStages?)
}
