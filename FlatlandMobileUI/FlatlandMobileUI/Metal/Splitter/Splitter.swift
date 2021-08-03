//
//  Splitter.swift
//  Splitter
//
//  Created by Stuart Rankin on 7/19/21. Adapted from Flatland View.
//

import Foundation
import UIKit
import simd
import Metal
import MetalKit
import CoreImage

class Splitter
{
    private let ImageDevice = MTLCreateSystemDefaultDevice()
    private var ImageComputePipelineState: MTLComputePipelineState? = nil
    private lazy var ImageCommandQueue: MTLCommandQueue? =
    {
        return self.ImageDevice?.makeCommandQueue()
    }()
    
    func DoSplit(Source: UIImage) -> UIImage?
    {
        let DefaultLibrary = ImageDevice?.makeDefaultLibrary()
        let KernelFunction = DefaultLibrary?.makeFunction(name: "Splitter")
        do
        {
            ImageComputePipelineState = try ImageDevice?.makeComputePipelineState(function: KernelFunction!)
        }
        catch
        {
            print("Error creating pipeline state: \(error.localizedDescription)")
        }
        
        let Target = MetalLibrary.MakeEmptyTexture(Size: Source.size, ImageDevice: ImageDevice!,
                                                   ForWriting: true)
        var AdjustedCG: CGImage? = nil
        let AdjustedSource = MetalLibrary.MakeTexture(From: Source, ForWriting: false, ImageDevice: ImageDevice!,
                                                      AsCG: &AdjustedCG)
        
        let CommandBuffer = ImageCommandQueue?.makeCommandBuffer()
        let CommandEncoder = CommandBuffer?.makeComputeCommandEncoder()
        CommandEncoder?.setComputePipelineState(ImageComputePipelineState!)
        CommandEncoder?.setTexture(AdjustedSource, index: 0)
        CommandEncoder?.setTexture(Target, index: 1)
        
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
        let ImageByteCount = Int(ImageSize.width * ImageSize.height * 4)
        let BytesPerRow = (AdjustedCG?.bytesPerRow)!
        var ImageBytes = [UInt8](repeating: 0, count: ImageByteCount)
        let ORegion = MTLRegionMake2D(0, 0, Int(ImageSize.width), Int(ImageSize.height))
        Target!.getBytes(&ImageBytes, bytesPerRow: BytesPerRow, from: ORegion, mipmapLevel: 0)
        
        let CIOptions = [CIImageOption.colorSpace: CGColorSpaceCreateDeviceRGB(),
                         CIImageOption.applyOrientationProperty: false,
                         CIContextOption.outputPremultiplied: true,
                         CIContextOption.useSoftwareRenderer: false] as! [CIImageOption: Any]
        let CImg = CIImage(mtlTexture: Target!, options: CIOptions)
        let Final: UIImage = UIImage(ciImage: CImg!)
        #if false
        let CImgRep = NSCIImageRep(ciImage: CImg!)
        let Final = UIImage(size: ImageSize)
        Final.addRepresentation(CImgRep)
        #endif
        return Final
    }
}
