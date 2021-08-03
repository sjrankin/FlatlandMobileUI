//
//  AdjustTransparency.swift
//  AdjustTransparency
//
//  Created by Stuart Rankin on 7/19/21. Adapted from Flatland View.
//

import Foundation
import UIKit
import simd
import Metal
import MetalKit
import CoreImage

/// Adjusts the transparent of an image such that each pixel is either fully transparent or fully opaque.
class AdjustTransparency
{
    private let ImageDevice = MTLCreateSystemDefaultDevice()
    private var ImageComputePipelineState: MTLComputePipelineState? = nil
    private lazy var ImageCommandQueue: MTLCommandQueue? =
    {
        return self.ImageDevice?.makeCommandQueue()
    }()
    
    func Adjust(Source: UIImage, Threshold: Double = 0.5) -> UIImage?
    {
        let DefaultLibrary = ImageDevice?.makeDefaultLibrary()
        let KernelFunction = DefaultLibrary?.makeFunction(name: "AdjustTransparency0")
        do
        {
            ImageComputePipelineState = try ImageDevice?.makeComputePipelineState(function: KernelFunction!)
        }
        catch
        {
            print("Error creating pipeline state: \(error.localizedDescription)")
        }
        
        let SourceSize = Source.size
        let Target = MetalLibrary.MakeEmptyTexture(Size: SourceSize, ImageDevice: ImageDevice!,
                                                   ForWriting: true)
        var AdjustedCG: CGImage? = nil
        let AdjustedSource = MetalLibrary.MakeTexture(From: Source, ForWriting: false, ImageDevice: ImageDevice!,
                                                      AsCG: &AdjustedCG)
        
        let Parameter = TransparencyParameters(Threshold: simd_float1(Threshold))
        let Parameters = [Parameter]
        let ParameterBuffer = ImageDevice!.makeBuffer(length: MemoryLayout<TransparencyParameters>.stride, options: [])
        memcpy(ParameterBuffer!.contents(), Parameters, MemoryLayout<TransparencyParameters>.stride)
        
        let CommandBuffer = ImageCommandQueue?.makeCommandBuffer()
        let CommandEncoder = CommandBuffer?.makeComputeCommandEncoder()
        CommandEncoder?.setComputePipelineState(ImageComputePipelineState!)
        CommandEncoder?.setTexture(AdjustedSource, index: 0)
        CommandEncoder?.setTexture(Target, index: 1)
        CommandEncoder?.setBuffer(ParameterBuffer, offset: 0, index: 0)
        
        let ThreadGroupCount = MTLSizeMake(8, 8, 1)
        let ThreadGroups = MTLSizeMake(AdjustedSource!.width / ThreadGroupCount.width,
                                       AdjustedSource!.height / ThreadGroupCount.height,
                                       1)
        ImageCommandQueue = ImageDevice?.makeCommandQueue()
        CommandEncoder?.dispatchThreadgroups(ThreadGroups, threadsPerThreadgroup: ThreadGroupCount)
        CommandEncoder?.endEncoding()
        CommandBuffer?.commit()
        CommandBuffer?.waitUntilCompleted()
        
        let ImageSize = CGSize(width: Target!.width, height: Target!.height)
        if ImageSize != SourceSize
        {
            fatalError("Size mismatch in \(#function)")
        }
        let ImageByteCount = Int(ImageSize.width * ImageSize.height * 4)
        let BytesPerRow = (AdjustedCG?.bytesPerRow)!
        print("BytesPerRow=\(BytesPerRow), calculated=\((ImageByteCount / Int(ImageSize.height)) * 4)")
        var ImageBytes = [UInt8](repeating: 0, count: ImageByteCount)
        let ORegion = MTLRegionMake2D(0, 0, Int(ImageSize.width), Int(ImageSize.height))
        //let OSize = ORegion.size
        if ORegion.size.width != Int(ImageSize.width) && ORegion.size.height != Int(ImageSize.height)
        {
            fatalError("ORegion.size != ImageSize in \(#function)")
        }
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
