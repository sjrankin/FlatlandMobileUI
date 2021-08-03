//
//  ImageShifter.swift
//  ImageShifter
//
//  Created by Stuart Rankin on 7/19/21. Adapted from Flatland View.
//

import Foundation
import UIKit
import simd
import Metal
import MetalKit
import CoreImage

/// Wrapper around a Metal kernel to shift images horizontally or vertically.
class ImageShifter
{
    var Helper = MetalHelper()
    
    private let ImageDevice = MTLCreateSystemDefaultDevice()
    private var ImageComputePipelineState: MTLComputePipelineState? = nil
    private lazy var ImageCommandQueue: MTLCommandQueue? =
    {
        return self.ImageDevice?.makeCommandQueue()
    }()
    
    /// Initializer.
    init()
    {
        DefaultLibrary = ImageDevice?.makeDefaultLibrary()
    }
    
    var DefaultLibrary: MTLLibrary? = nil
    
    /// Create the specified kernel.
    /// - Parameter With: The name of the kernel to create.
    func MakeKernel(With Name: String)
    {
        let KernelFunction = DefaultLibrary?.makeFunction(name: Name)
        do
        {
            ImageComputePipelineState = try ImageDevice?.makeComputePipelineState(function: KernelFunction!)
        }
        catch
        {
            print("Error creating pipeline state: \(error.localizedDescription)")
        }
    }
    
    /// Shift an image either vertically or horizontally.
    /// - Note: If `HorizontalPercent` and `VerticalPercent` are both `0`, the image is returned unchanged. If both
    ///         `HorizontalPercent` and `VerticalPercent` have a non-zero value, the original image is returned unchanged.
    /// - Parameter HorizontalPercent: Percent value (normalized) the image will be shifted to the right.
    ///                                Defaults to `0.0`.
    /// - Parameter VerticalPercent: Percent value (normalized) the image will be shifted down. Defaults
    ///                              to `0.0`.
    /// - Returns: Imaged shifted by the specified percent either vertically or horizontally.
    func ShiftImage(Source: UIImage, HorizontalPercent: Double = 0.0, VerticalPercent: Double = 0.0) -> UIImage
    {
        if HorizontalPercent < 0.0 || HorizontalPercent > 1.0
        {
            return Source
        }
        if VerticalPercent < 0.0 || VerticalPercent > 1.0
        {
            return Source
        }
        let Width = Double(Source.size.width)
        let Height = Double(Source.size.height)
        let WidthAmount = Int(Width * HorizontalPercent)
        let HeightAmount = Int(Height * VerticalPercent)
        return ShiftImage(Source: Source, Horizontally: WidthAmount, Vertically: HeightAmount)
    }
    
    func ShiftImage(Source: UIImage, Horizontally: Int = 0, Vertically: Int = 0) -> UIImage
    {
        objc_sync_enter(Blocked)
        defer{objc_sync_exit(Blocked)}
        
        let Image = DoShiftImage(Source: Source, Horizontally: Horizontally, Vertically: Vertically)
        return Image
    }
    
    var Blocked: NSObject = NSObject()
    
    /// Shift an image either vertically or horizontally.
    /// - Note: If `Horizontally` and `Vertically` are both `0`, the image is returned unchanged. If both
    ///         `Horizontally` and `Vertically` have a non-zero value, the original image is returned unchanged.
    /// - Note: The proper functioning of this function is highly dependent on the thread group count. The
    ///         width and height must both be set to `1` in order for all pixels to be processed correctly.
    /// - Parameter Source: The image to shift.
    /// - Parameter Horizontally: Number of pixels to shift the image to the right. Defaults to `0`.
    /// - Parameter Vertically: Number of pixels to shift the image down. Defaults to `0`.
    /// - Returns: Image shifted as determined by the parameters.
    func DoShiftImage(Source: UIImage, Horizontally: Int = 0, Vertically: Int = 0) -> UIImage
    {
        Debug.Print("Shifting by \(Horizontally)x\(Vertically)")
        
        switch (Horizontally, Vertically)
        {
            case (0, 0):
                return Source
                
            case (0, _):
                MakeKernel(With: "VerticalImageShift")
                
            case (_, 0):
                MakeKernel(With: "HorizontalImageShift")
                
            default:
                return Source
        }
        
        let Parameter = ImageShiftParameters(XOffset: simd_int1(Horizontally),
                                             YOffset: simd_int1(Vertically),
                                             ImageWidth: simd_uint1(Source.size.width),
                                             ImageHeight: simd_uint1(Source.size.height))
        let Parameters = [Parameter]
        let ParameterBuffer = ImageDevice!.makeBuffer(length: MemoryLayout<ImageShiftParameters>.stride, options: [])
        memcpy(ParameterBuffer!.contents(), Parameters, MemoryLayout<ImageShiftParameters>.stride)
        
        let Target = Helper.MakeEmptyTexture(Size: Source.size, ImageDevice: ImageDevice!,
                                             ForWriting: true)
        var AdjustedCG: CGImage? = nil
#if true
        let AdjustedSource = Source.MakeTexture(ForWriting: false, ImageDevice: ImageDevice!, AsCG: &AdjustedCG)
#else
        let AdjustedSource = Helper.MakeTexture(From: Source, ForWriting: false, ImageDevice: ImageDevice!,
                                                AsCG: &AdjustedCG)
#endif
        
        let CommandBuffer = ImageCommandQueue?.makeCommandBuffer()
        let CommandEncoder = CommandBuffer?.makeComputeCommandEncoder()
        CommandEncoder?.setComputePipelineState(ImageComputePipelineState!)
        CommandEncoder?.setTexture(AdjustedSource, index: 0)
        CommandEncoder?.setTexture(Target, index: 1)
        CommandEncoder?.setBuffer(ParameterBuffer, offset: 0, index: 0)
        
        //MTLSizeMake must have the parameters "1, 1, 1" to ensure there are no gaps when the image is shifted.
        let ThreadGroupCount = MTLSizeMake(1, 1, 1)
        let ThreadGroups = MTLSizeMake(AdjustedSource!.width / ThreadGroupCount.width,
                                       AdjustedSource!.height / ThreadGroupCount.height,
                                       1)
        ImageCommandQueue = ImageDevice?.makeCommandQueue()
        CommandEncoder?.dispatchThreadgroups(ThreadGroups, threadsPerThreadgroup: ThreadGroupCount)
        CommandEncoder?.endEncoding()
        CommandBuffer?.addCompletedHandler
        {
            MetalLog in
            if MetalLog.error != nil
            {
                print("Command buffer finished with error: \(MetalLog.error!)")
            }
            else
            {
                Debug.Print("Command buffer finished.")
            }
        }
        CommandBuffer?.commit()
        CommandBuffer?.waitUntilCompleted()
        
        let ImageSize = CGSize(width: Target!.width, height: Target!.height)
        let ImageByteCount = Int(ImageSize.width * ImageSize.height * 4)
        let BytesPerRow = (AdjustedCG?.bytesPerRow)!
        var ImageBytes = [UInt8](repeating: 0, count: ImageByteCount)
        let ORegion = MTLRegionMake2D(0, 0, Int(ImageSize.width), Int(ImageSize.height))
        Debug.Print("Just before getBytes call.")
        Target!.getBytes(&ImageBytes, bytesPerRow: BytesPerRow, from: ORegion, mipmapLevel: 0)
        
        let CIOptions = [CIImageOption.colorSpace: CGColorSpaceCreateDeviceRGB(),
                         CIImageOption.applyOrientationProperty: false,
                         CIContextOption.outputPremultiplied: true,
                         CIContextOption.useSoftwareRenderer: false] as! [CIImageOption: Any]
        let CImg = CIImage(mtlTexture: Target!, options: CIOptions)
        #if true
        let Final = UIImage(ciImage: CImg!)
        #else
        let CImgRep = NSCIImageRep(ciImage: CImg!)
        let Final = UIImage(size: ImageSize)
        Final.addRepresentation(CImgRep)
        #endif
        return Final
    }
}
