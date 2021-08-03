//
//  PhotoLibrary.swift
//  PhotoLibrary
//
//  Created by Stuart Rankin on 8/1/21.
//

import Foundation
import UIKit
import Photos

class PhotoLibrary
{
    private static var HavePhotoLibraryAccess = false
    public static var HaveCapturePermission = false
    
    public static func Initialize()
    {
        HavePhotoLibraryAccess = false
        switch PHPhotoLibrary.authorizationStatus()
        {
            case .authorized:
                HavePhotoLibraryAccess = true
                
            case .denied:
                //User denied access.
                break
                
            case .notDetermined:
                PHPhotoLibrary.requestAuthorization
                {
                    Status in
                    switch Status
                    {
                        case .authorized:
                            HavePhotoLibraryAccess = true
                            
                        case .denied:
                            break
                            
                        case .restricted:
                            break
                            
                        case .notDetermined:
                            break
                            
                        case .limited:
                        HaveCapturePermission = true
                            
                        @unknown default:
                            break
                    }
                }
                
            case .restricted:
                //Cannot access and the user cannot grant access.
                break
                
            case .limited:
                HavePhotoLibraryAccess = true
                
            @unknown default:
                Debug.FatalError("Unknown photo library authorization status in \(#file)")
        }
    }
}
