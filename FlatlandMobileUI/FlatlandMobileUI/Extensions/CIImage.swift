//
//  CIImage.swift
//  Flatland Mobile.
//
//  Created by Stuart Rankin on 4/14/21. Adapted from BlockCam2.
//

import Foundation
import UIKit

extension CIImage
{
    // MARK: - CIImage extensions.
    
    /// Convert the instance `CIImage` to a `UIImage`.
    /// - Returns: `UIImage` equivalent of the instance `CIImage` Nil return on error.
    func AsUIImage() -> UIImage?
    {
        let Context: CIContext = CIContext(options: nil)
        if let CGImg: CGImage = Context.createCGImage(self, from: self.extent)
        {
            let Final: UIImage = UIImage(cgImage: CGImg)
            return Final
        }
        return nil
    }
    
    /// Rotate the instance image by 90° left.
    /// - Parameter AndMirror: If true, the image is mirrored with `.upMirrored` before
    ///                        rotating it leftwards.
    /// - Returns: Rotated and potentially mirrored image.
    func RotateLeft(AndMirror: Bool = false) -> CIImage
    {
        if AndMirror
        {
            var Rotated = self.oriented(.upMirrored)
            Rotated = Rotated.oriented(.left)
            return Rotated
        }
        return self.oriented(.left)
    }
    
    /// Mirror the image left.
    /// - Returns: Image mirrored left.
    func MirrorLeft() -> CIImage
    {
        let Mirrored = self.oriented(.leftMirrored)
        return Mirrored
    }
    
    /// Rotate the instance image by 90° right.
    /// - Parameter AndMirror: If true, the image is mirrored with `.downMirrored` before
    ///                        rotating it rightwards.
    /// - Returns: Rotated and potentially mirrored image.
    func RotateRight(AndMirror: Bool = false) -> CIImage
    {
        if AndMirror
        {
            var Rotated = self.oriented(.downMirrored)
            Rotated = Rotated.oriented(.right)
            return Rotated
        }
        return self.oriented(.right)
    }
    
    /// Mirror the image right.
    /// - Returns: Image mirrored right.
    func MirrorRight() -> CIImage
    {
        let Mirrored = self.oriented(.rightMirrored)
        return Mirrored
    }
    
    /// Mirror the image up.
    /// - Returns: Image mirrored up.
    func MirrorUp() -> CIImage
    {
        let Mirrored = self.oriented(.upMirrored)
        return Mirrored
    }
    
    /// Mirror the image down.
    /// - Returns: Image mirrored down.
    func MirrorDown() -> CIImage
    {
        let Mirrored = self.oriented(.downMirrored)
        return Mirrored
    }
    
    /// Rotate the instance image by 180°.
    /// - Parameter AndMirror: If true, the image is mirrored with `.leftMirrored` before
    ///                        being rotated 180°.
    /// - Returns: Rotated image.
    func Rotate180(AndMirror: Bool = false) -> CIImage
    {
        if AndMirror
        {
            //var Rotated = self.oriented(.leftMirrored)
            let Rotated = self.oriented(.downMirrored)
            return Rotated
        }
        let Rotated = self.oriented(.down)
        return Rotated
    }
}
