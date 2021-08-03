//
//  MetalHelper.swift
//  MetalHelper
//
//  Created by Stuart Rankin on 7/19/21. Adapted from Flatland View.
//

import Foundation
import UIKit
import simd
import Metal
import MetalKit
import CoreImage
import CoreGraphics

class MetalHelper
{
    init()
    {
    }
    
    /// Convert an instance of a UIColor to a SIMD float4 structure.
    /// - Note: Works with grayscale colors as well as "normal" colors.
    /// - Returns: SIMD float4 equivalent of the instance color.
    public func ToFloat4(_ Color: UIColor) -> simd_float4
    {
        let CColor = CIColor(color: Color)
        var FVals = [Float]()
        FVals.append(Float(CColor.red))
        FVals.append(Float(CColor.green))
        FVals.append(Float(CColor.blue))
        FVals.append(Float(CColor.alpha))
        let Result = simd_float4(FVals)
        return Result
    }
    
    /// Adjusts the colorspace of the passed image from monochrome to device RGB. If the passed image is
    /// not grayscale, it is returned unchanged but converted to `CGImage`.
    /// - Parameter For: The image whose color space may potentially be changed.
    /// - Parameter ForceSize: If not nil, the size to force internal conversions to.
    /// - Returns: New image (in `CGImage` format). This image will *not* have a monochrome color space
    ///            (even if visually is looks monochromatic).
    public func AdjustColorSpace(For Image: UIImage, ForceSize: CGSize? = nil) -> CGImage?
    {
        #if true
        if let NewSize = ForceSize
        {
            let OldSize = Image.size
            
            let WidthRatio  = NewSize.width  / OldSize.width
            let HeightRatio = NewSize.height / OldSize.height
            
            // Figure out what our orientation is, and use that to form the rectangle
            var FinalSize: CGSize
            if WidthRatio > HeightRatio
            {
                FinalSize = CGSize(width: OldSize.width * HeightRatio, height: OldSize.height * HeightRatio)
            }
            else
            {
                FinalSize = CGSize(width: OldSize.width * WidthRatio, height: OldSize.height * WidthRatio)
            }
            
            // This is the rect that we've calculated out and this is what is actually used below
            let Rect = CGRect(origin: .zero, size: FinalSize)
            
            // Actually do the resizing to the rect using the ImageContext stuff
            UIGraphicsBeginImageContextWithOptions(FinalSize, false, 1.0)
            Image.draw(in: Rect)
            let NewImage = UIGraphicsGetImageFromCurrentImageContext()
            UIGraphicsEndImageContext()
            
            let CgImage = NewImage?.cgImage?.copy(colorSpace: CGColorSpace.sRGB as! CGColorSpace)
            return CgImage
        }
        let CgImage = Image.cgImage?.copy(colorSpace: CGColorSpace.sRGB as! CGColorSpace)
        return CgImage
        #else
        var CgImage: CGImage? = nil
        if let ImageSize = ForceSize
        {
            var Rect = CGRect(origin: .zero, size: ImageSize)
            CgImage = Image.cgImage(forProposedRect: &Rect, context: nil, hints: nil)
        }
        else
        {
            CgImage = Image.cgImage(forProposedRect: nil, context: nil, hints: nil)
        }
        if var CGI = CgImage
        {
            if CGI.colorSpace?.model == CGColorSpaceModel.monochrome
            {
                let NewColorSpace = CGColorSpaceCreateDeviceRGB()
                let NewBMInfo = CGBitmapInfo(rawValue: CGImageAlphaInfo.noneSkipLast.rawValue)
                let IWidth = Int(CGI.width)
                let IHeight = Int(CGI.height)
                var RawData = [UInt8](repeating: 0, count: Int(IWidth * IHeight * 4))
                let GContext = CGContext(data: &RawData,
                                         width: IWidth,
                                         height: IHeight,
                                         bitsPerComponent: 8,
                                         bytesPerRow: 4 * IWidth,
                                         space: NewColorSpace,
                                         bitmapInfo: NewBMInfo.rawValue)
                let ImageRect = CGRect(origin: .zero, size: CGSize(width: IWidth, height: IHeight))
                GContext!.draw(CGI, in: ImageRect)
                CGI = GContext!.makeImage()!
                return CGI
            }
            else
            {
                return CGI
            }
        }
        return nil
        #endif
    }
    
    var TextureBlock: NSObject = NSObject()
    
    /// Convert an `UIImage` to a `MTLTexture` for use with Metal compute shaders.
    /// - Parameter From: The image to convert.
    /// - Parameter ForWriting: If true, the returned Metal texture will allow writing. Otherwise, it will
    ///                         only allow reading. Defaults to `false`.
    /// - Parameter ImageDevice: The `MTLDevice` where the Metal texture will be used.
    /// - Parameter AsCG: Upon exit, will contain the `CGImage` version of `From`.
    /// - Returns: Metal texture conversion of `From` on success, nil on failure.
    public func MakeTexture(From: UIImage, ForWriting: Bool = false, ImageDevice: MTLDevice,
                            AsCG: inout CGImage?) -> MTLTexture?
    {
        objc_sync_enter(TextureBlock)
        defer{objc_sync_exit(TextureBlock)}
        let ImageSize = From.size
        if let Adjusted = MetalLibrary.AdjustColorSpace(For: From, ForceSize: ImageSize)
        {
            AsCG = Adjusted
            let MTK = MTKTextureLoader(device: ImageDevice)
            do
            {
                let Result = try MTK.newTexture(cgImage: Adjusted, options: nil)
                return Result
            }
            catch
            {
                return nil
            }
            /*
             let ImageWidth: Int = Adjusted.width
             let ImageHeight: Int = Adjusted.height
             var RawData = [UInt8](repeating: 0, count: Int(ImageWidth * ImageHeight * 4))
             let RGBColorSpace = CGColorSpaceCreateDeviceRGB()
             #if false
             let BitmapInfo = CGBitmapInfo(rawValue: CGBitmapInfo.byteOrder32Big.rawValue | CGImageAlphaInfo.premultipliedLast.rawValue)
             #else
             //let BitmapInfo = CGBitmapInfo(rawValue: CGImageAlphaInfo.premultipliedLast.rawValue)
             let BitmapInfo = Adjusted.bitmapInfo
             #endif
             let BitsPerComponent = Adjusted.bitsPerComponent
             let BytesPerRow = Adjusted.bytesPerRow
             let Context = CGContext(data: &RawData,
             width: ImageWidth,
             height: ImageHeight,
             bitsPerComponent: BitsPerComponent,
             bytesPerRow: BytesPerRow,
             space: RGBColorSpace,
             bitmapInfo: BitmapInfo.rawValue)
             if Context == nil
             {
             fatalError("Error creating CGContext in \(#function)")
             }
             //let Frames = Debug.StackFrameContents(20)
             //print(Debug.PrettyStackTrace(Frames))
             Context!.draw(Adjusted, in: CGRect(x: 0, y: 0, width: ImageWidth, height: ImageHeight))
             let TextureDescriptor = MTLTextureDescriptor.texture2DDescriptor(pixelFormat: .rgba8Unorm,
             width: Int(ImageWidth),
             height: Int(ImageHeight),
             mipmapped: true)
             if ForWriting
             {
             TextureDescriptor.usage = [.shaderWrite, .shaderRead]
             }
             guard let TileTexture = ImageDevice.makeTexture(descriptor: TextureDescriptor) else
             {
             RawData.removeAll()
             return nil
             }
             let Region = MTLRegionMake2D(0, 0, Int(ImageWidth), Int(ImageHeight))
             TileTexture.replace(region: Region, mipmapLevel: 0, withBytes: &RawData,
             bytesPerRow: BytesPerRow)
             //            RawData.removeAll()
             return TileTexture
             */
        }
        return nil
    }
    
    /// Creates an empty Metal texture intended to be used as a target for Metal compute shaders.
    /// - Parameter Size: The size of the Metal texture to return.
    /// - Parameter ImageDevice: The MTLDevice where the Metal texture will be used.
    /// - Parameter ForWriting: If true, the returned Metal texture will allow writing. Otherwise, it will
    ///                         only allow reading. Defaults to `false`.
    /// - Returns: Empty (all pixel values set to 0x0) Metal texture on success, nil on failure.
    public func MakeEmptyTexture(Size: CGSize, ImageDevice: MTLDevice, ForWriting: Bool = false) -> MTLTexture?
    {
        let ImageWidth: Int = Int(Size.width)
        let ImageHeight: Int = Int(Size.height)
        var RawData = [UInt8](repeating: 0, count: Int(ImageWidth * ImageHeight * 4))
        let BytesPerRow = Int(Size.width * 4)
        let TextureDescriptor = MTLTextureDescriptor.texture2DDescriptor(pixelFormat: .rgba8Unorm,
                                                                         width: Int(ImageWidth),
                                                                         height: Int(ImageHeight),
                                                                         mipmapped: true)
        TextureDescriptor.usage = [.shaderRead, .shaderWrite]
        
        guard let TileTexture = ImageDevice.makeTexture(descriptor: TextureDescriptor) else
        {
            RawData.removeAll()
            print("Error creating texture.")
            return nil
        }
        let Region = MTLRegionMake2D(0, 0, Int(ImageWidth), Int(ImageHeight))
        TileTexture.replace(region: Region, mipmapLevel: 0, withBytes: &RawData,
                            bytesPerRow: BytesPerRow)
        RawData.removeAll()
        return TileTexture
    }
}
