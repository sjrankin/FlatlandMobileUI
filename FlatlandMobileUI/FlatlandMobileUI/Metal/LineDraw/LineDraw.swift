//
//  LineDraw.swift
//  LineDraw
//
//  Created by Stuart Rankin on 7/19/21. Adapted from Flatland View.
//

import Foundation
import UIKit
import simd
import Metal
import MetalKit
import CoreImage

/// Wrapper class around the `LineDraw` metal kernel to draw a line on an image.
class LineDraw
{
    private let ImageDevice = MTLCreateSystemDefaultDevice()
    private var ImageComputePipelineState: MTLComputePipelineState? = nil
    private lazy var ImageCommandQueue: MTLCommandQueue? =
    {
        return self.ImageDevice?.makeCommandQueue()
    }()
    
    /// Initializer.
    init()
    {
        let DefaultLibrary = ImageDevice?.makeDefaultLibrary()
        let KernelFunction = DefaultLibrary?.makeFunction(name: "DrawLine")
        do
        {
            ImageComputePipelineState = try ImageDevice?.makeComputePipelineState(function: KernelFunction!)
        }
        catch
        {
            print("Error creating pipeline state: \(error.localizedDescription)")
        }
    }
    
    func DrawLine(Background: UIImage, IsHorizontal: Bool, Thickness: Int, At: Int,
                  WithColor: UIColor) -> UIImage
    {
        let Parameter = LineDrawParameters(IsHorizontal: simd_bool(IsHorizontal),
                                           HorizontalAt: simd_uint1(At),
                                           VerticalAt: simd_uint1(At),
                                           Thickness: simd_uint1(Thickness),
                                           LineColor: MetalLibrary.ToFloat4(WithColor))
        return DoDrawLine(Background: Background, Line: Parameter)
    }
    
    /// Draw a line (vertical or horizontal) on the passed image.
    /// - Parameters:
    ///   - Background: The image upon which a line will be drawn.
    ///   - IsHorizontal: If true, a horizontal line will be drawn at the Y value in `At`. If false, a vertical
    ///                   line will be drawn at the X value in `At`.
    ///   - Thickness: Thickness of the line. Values of `0` will generate a fatal error.
    ///   - At: The location where the line will be drawn. Whether this is vertical or horizontal depends on
    ///         the value of `IsHorizontal`.
    ///   - WithColor: The color of the line. Alpha blending is supported.
    /// - Returns: Image with a line drawn on it.
    private func DoDrawLine(Background: UIImage, Line: LineDrawParameters) -> UIImage
    {
        //Validate parameters.
        if Line.Thickness == 0
        {
            fatalError("Invalid thickness for line in DrawLine.")
        }
        if Line.IsHorizontal
        {
            if Line.HorizontalAt < 0
            {
                fatalError("Horizontal location \(Line.HorizontalAt) is less than 0.")
            }
            if Line.HorizontalAt + Line.Thickness > Int(Background.size.height)
            {
                fatalError("Horizontal line position plus thickness is out of bounds.")
            }
        }
        else
        {
            if Line.VerticalAt < 0
            {
                fatalError("Vertical location \(Line.VerticalAt) is less than 0.")
            }
            if Line.VerticalAt + Line.Thickness > Int(Background.size.width)
            {
                fatalError("Vertical line position plus thickness is out of bounds.")
            }
        }
        
        var AdjustedBG: CGImage? = nil
        let BGTexture = MetalLibrary.MakeTexture(From: Background, ForWriting: true,
                                                 ImageDevice: ImageDevice!, AsCG: &AdjustedBG)
        
        let Parameters = [Line]
        let BufferLength = MemoryLayout<LineDrawParameters>.stride
        let ParameterBuffer = ImageDevice!.makeBuffer(length: BufferLength, options: [])
        memcpy(ParameterBuffer!.contents(), Parameters, BufferLength)
        
        let CommandBuffer = ImageCommandQueue?.makeCommandBuffer()
        let CommandEncoder = CommandBuffer?.makeComputeCommandEncoder()
        
        CommandEncoder?.setComputePipelineState(ImageComputePipelineState!)
        CommandEncoder?.setTexture(BGTexture, index: 0)
        CommandEncoder?.setBuffer(ParameterBuffer, offset: 0, index: 0)
        
        let w = ImageComputePipelineState!.threadExecutionWidth
        let h = ImageComputePipelineState!.maxTotalThreadsPerThreadgroup / w
        let ThreadGroupCount = MTLSizeMake(w, h, 1)
        let ThreadGroups = MTLSize(width: BGTexture!.width, height: BGTexture!.height, depth: 1)
        
        ImageCommandQueue = ImageDevice?.makeCommandQueue()
        CommandEncoder?.dispatchThreadgroups(ThreadGroups, threadsPerThreadgroup: ThreadGroupCount)
        CommandEncoder?.endEncoding()
        CommandBuffer?.commit()
        CommandBuffer?.waitUntilCompleted()
        
        let ImageSize = CGSize(width: BGTexture!.width, height: BGTexture!.height)
        let ImageByteCount = Int(BGTexture!.width * BGTexture!.height * 4)
        let BytesPerRow = AdjustedBG!.bytesPerRow
        var ImageBytes = [UInt8](repeating: 0, count: ImageByteCount)
        let ORegion = MTLRegionMake2D(0, 0, BGTexture!.width, BGTexture!.height)
        BGTexture!.getBytes(&ImageBytes, bytesPerRow: BytesPerRow, from: ORegion, mipmapLevel: 0)
        
        //https://stackoverflow.com/questions/49713008/pixel-colors-change-as-i-save-mtltexture-to-cgimage
        let CIOptions = [CIImageOption.colorSpace: CGColorSpaceCreateDeviceRGB(),
                         CIContextOption.outputPremultiplied: true,
                         CIContextOption.useSoftwareRenderer: false] as! [CIImageOption: Any]
        let CImg = CIImage(mtlTexture: BGTexture!, options: CIOptions)
        #if true
        var Final = UIImage(ciImage: CImg!)
        #else
        let CImgRep = NSCIImageRep(ciImage: CImg!)
        var Final = UIImage(size: ImageSize)
        Final.addRepresentation(CImgRep)
        #endif
        let Flipper = ImageFlipper()
        Final = Flipper.FlipVertically(Source: Final)!
        
        return Final
    }
}

