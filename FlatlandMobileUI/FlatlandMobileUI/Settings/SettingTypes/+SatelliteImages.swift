//
//  +SatelliteImages.swift
//  +SatelliteImages
//
//  Created by Stuart Rankin on 7/19/21. Adapted from Flatland View.
//

import Foundation
import UIKit

extension Settings
{
    /// Retrieves a cached satellite image from the proper sub-directory. All file management is handled
    /// in `FileIO`.
    /// - Warning: If `For` does not resolve to a satellite map (see `MapManager.IsSatelliteMap`), a fatal
    ///            error is generated.
    /// - Parameter For: The type of cached satellite map to return. See Warning.
    /// - Returns: The cached satellite map on success, nil if not found.
    public static func GetCachedImage(For SatelliteMap: MapTypes) -> UIImage?
    {
        if !MapManager.IsSatelliteMap(SatelliteMap)
        {
            Debug.FatalError("Invalid map type \(SatelliteMap) to get from cached directory.")
        }
        let CachedImage = FileIO.GetCachedImage(In: SatelliteMap)
        return CachedImage
    }
    
    /// Saves a satellite map in the proper sub-directory. All file management is handled in `FileIO`.
    /// - Warning: If `SatelliteType` does not resolve to a satellite map (see `MapManager.IsSatelliteMap`),
    ///            a fatal error is generated.
    /// - Parameter Image: The image to save.
    /// - Parameter SatelliteType: The type of satellite image to save. See Warning.
    public static func SetCachedImage(_ Image: UIImage, SatelliteType: MapTypes)
    {
        if !MapManager.IsSatelliteMap(SatelliteType)
        {
            Debug.FatalError("Invalid map type \(SatelliteType) to save in cached directory.")
        }
        FileIO.SetCachedImage(In: SatelliteType, Map: Image)
    }
}
