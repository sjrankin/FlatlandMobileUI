//
//  Features.swift
//  Features
//
//  Created by Stuart Rankin on 7/20/21. Adapted from Flatland View.
//

import Foundation
import UIKit

/// Manages availability of features in Flatland.
/// - Note:
///   - This is "voluntary" in the sense the code may choose to ignore this class.
///   - Each feature controlled must have an associated value in the `ManagedFeatures` enum. The enum's
///     value is compared to `Versioning.FeatureLevel` and if the the level value in `ManagedFeatures` is
///     less than or equal to `Versioning.FeatureLevel`, the feature is "enabled."
class Features
{
    /// Determines if the passed feature is enabled via the managed features functionality.
    /// - Parameter Feature: The feature to test for enablement.
    /// - Returns: True if the feature level is less than or equal to the value in `Versioning.FeatureLevel`.
    public static func FeatureEnabled(_ Feature: ManagedFeatures) -> Bool
    {
        if let Level = FeatureMap[Feature]
        {
            if Level <= Versioning.FeatureLevel
            {
                return true
            }
            else
            {
                return false
            }
        }
        return true
    }
    
    /// Execute a closure if the passed feature is enabled.
    /// - Parameter Feature: The feature to test for enablement.
    /// - Parameter Block: The closure to execute if the feature is enabled. If the feature is not
    ///                    enabled, control returns immediately without executing the closure.
    public static func FeatureIsEnabled(_ Feature: ManagedFeatures, Block: (() -> ())? = nil)
    {
        if FeatureEnabled(Feature)
        {
            Block?()
        }
    }
    
    /// Execute a closure if the passed feature is not enabled.
    /// - Parameter Feature: The feature to test for enablement.
    /// - Parameter Block: The closure to execute if the feature is not enabled. If the feature is
    ///                    enabled, control returns immediately without executing the closure.
    public static func FeatureIsNotEnabled(_ Feature: ManagedFeatures, Block: (() -> ())? = nil)
    {
        if !FeatureEnabled(Feature)
        {
            Block?()
        }
    }
    
    /// Determines if the passed feature is enabled. Passes the result to the closure.
    /// - Parameter Feature: The feature to test for enablement.
    /// - Parameter Block: Closure to execute. First parameter passed is the feature enabled flag.
    public static func FeatureEnabled(_ Feature: ManagedFeatures, Block: ((Bool) -> ())? = nil)
    {
        let IsEnabled = FeatureEnabled(Feature)
        Block?(IsEnabled)
    }
    
    /// Map from features to required feature levels.
    private static let FeatureMap: [ManagedFeatures: Int] =
    [
        .NASAImagery: 2,
        .QuakeBarcodes: 2,
        .CubicEarth: 2,
        .Satellites: 3,
        .NonStockCamera: 2,
        .FlatlandMouseCursor: 2
    ]
}

/// Features managed by the `Features` class.
enum ManagedFeatures: String, CaseIterable
{
    /// Download NASA imagery to create global maps.
    case NASAImagery = "NASA Imagery"
    /// Display barcodes for earthquake magnitudes.
    case QuakeBarcodes = "Earthquake Barcodes"
    /// Able to display cubical Earth.
    case CubicEarth = "Cubic Earth"
    /// Can show satellites in orbit.
    case Satellites = "Satellites"
    /// Use Flatland's own camera rather than the stock camera.
    case NonStockCamera = "Non-Stock Camera"
    /// Use Flatland's mouse cursor when the mouse is over a map.
    case FlatlandMouseCursor = "Flatland Mouse Cursor"
}
