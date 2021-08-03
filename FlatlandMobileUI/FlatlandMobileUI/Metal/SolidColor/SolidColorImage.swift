//
//  SolidColorImage.swift
//  SolidColorImage
//
//  Created by Stuart Rankin on 7/19/21. Adapted from Flatland View.
//

import Foundation
import UIKit
import simd
import Metal
import MetalKit
import CoreImage

class SolidColorImage
{
    private let ImageDevice = MTLCreateSystemDefaultDevice()
    private var ImageComputePipelineState: MTLComputePipelineState? = nil
    private lazy var ImageCommandQueue: MTLCommandQueue? =
    {
        return self.ImageDevice?.makeCommandQueue()
    }()
    
    init()
    {
        let DefaultLibrary = ImageDevice?.makeDefaultLibrary()
        let KernelFunction = DefaultLibrary?.makeFunction(name: "SolidColorKernel")
        do
        {
            ImageComputePipelineState = try ImageDevice?.makeComputePipelineState(function: KernelFunction!)
        }
        catch
        {
            print("Error creating pipeline state: \(error.localizedDescription)")
        }
    }
    
    /// Convenience function to create and return a transparent image of the specified size.
    /// - Parameter Width: Width of the transparent image.
    /// - Parameter Height: Height of the transparent image.
    /// - Returns: Transparent image of the specified height and width on success, nil on failure.
    func TransparentImage(Width: Int, Height: Int) -> UIImage?
    {
        return Fill(Width: Width, Height: Height, With: UIColor.clear)
    }
    
    /// Returns an image of given size and color.
    /// - Note: To draw a border around the edge of the image, call `FillWithBorder`.
    /// - Parameter Width: The width of the image.
    /// - Parameter Height: The height of the image.
    /// - Parameter With: The color of the image.
    /// - Returns: Image created as specified on success, nil on error.
    func Fill(Width: Int, Height: Int, With Color: UIColor) -> UIImage?
    {
        return DoFill(With: Color, Size: CGSize(width: Width, height: Height))
    }
    
    /// Returns an image of given size and color with a border around the image.
    /// - Parameter Width: The width of the image.
    /// - Parameter Height: The height of the image.
    /// - Parameter With: The color of the image.
    /// - Parameter BorderThickness: The thickness of the border, in pixels.
    /// - Parameter BorderColor: The color of the border.
    /// - Returns: Image created as specified on success, nil on error.
    func FillWithBorder(Width: Int, Height: Int, With Color: UIColor, BorderThickness: Int,
                        BorderColor: UIColor) -> UIImage?
    {
        return DoFill(With: Color, Size: CGSize(width: Width, height: Height),
                      DrawBorder: true, BorderThickness: BorderThickness,
                      BorderColor: BorderColor)
    }
    
    /// Returns an image of given size and color with a border around the image.
    /// - Note: See [Incorrectly changing pixel colors](https://stackoverflow.com/questions/49713008/pixel-colors-change-as-i-save-mtltexture-to-cgimage)
    /// - Parameter With: The color of the image.
    /// - Parameter Size: The size of the image.
    /// - Parameter DrawBorder: If true a border will be drawn around the image. If false, no border will be
    ///                         drawn.
    /// - Parameter BorderThickness: The thickness of the border, in pixels.
    /// - Parameter BorderColor: The color of the border.
    /// - Returns: Image created as specified on success, nil on error.
    private func DoFill(With Color: UIColor, Size: CGSize, DrawBorder: Bool = false,
                        BorderThickness: Int = 0, BorderColor: UIColor = UIColor.clear) -> UIImage?
    {
        let Parameter = SolidColorParameters(DrawBorder: simd_bool(DrawBorder),
                                             BorderThickness: simd_uint1(BorderThickness),
                                             BorderColor: MetalLibrary.ToFloat4(BorderColor),
                                             Fill: MetalLibrary.ToFloat4(Color))
        let Parameters = [Parameter]
        let ParameterBuffer = ImageDevice!.makeBuffer(length: MemoryLayout<SolidColorParameters>.stride, options: [])
        memcpy(ParameterBuffer!.contents(), Parameters, MemoryLayout<SolidColorParameters>.stride)
        
        let AdjustedTexture = MetalLibrary.MakeEmptyTexture(Size: Size, ImageDevice: ImageDevice!)
        
        let CommandBuffer = ImageCommandQueue?.makeCommandBuffer()
        let CommandEncoder = CommandBuffer?.makeComputeCommandEncoder()
        CommandEncoder?.setComputePipelineState(ImageComputePipelineState!)
        CommandEncoder?.setTexture(AdjustedTexture, index: 0)
        CommandEncoder?.setBuffer(ParameterBuffer, offset: 0, index: 0)
        
        let w = ImageComputePipelineState!.threadExecutionWidth
        let h = ImageComputePipelineState!.maxTotalThreadsPerThreadgroup / w
        let ThreadGroupCount = MTLSizeMake(w, h, 1)
        let ThreadGroups = MTLSize(width: Int(Size.width), height: Int(Size.height), depth: 1)
        
        ImageCommandQueue = ImageDevice?.makeCommandQueue()
        CommandEncoder?.dispatchThreadgroups(ThreadGroups, threadsPerThreadgroup: ThreadGroupCount)
        CommandEncoder?.endEncoding()
        CommandBuffer?.commit()
        CommandBuffer?.waitUntilCompleted()
        
        let ImageSize = CGSize(width: AdjustedTexture!.width, height: AdjustedTexture!.height)
        let ImageByteCount = Int(ImageSize.width * ImageSize.height * 4)
        let BytesPerRow = Int(Size.width * 4)
        var ImageBytes = [UInt8](repeating: 0, count: ImageByteCount)
        let ORegion = MTLRegionMake2D(0, 0, Int(ImageSize.width), Int(ImageSize.height))
        AdjustedTexture!.getBytes(&ImageBytes, bytesPerRow: BytesPerRow, from: ORegion, mipmapLevel: 0)
        
        //https://stackoverflow.com/questions/49713008/pixel-colors-change-as-i-save-mtltexture-to-cgimage
        let ImgOp = [CIImageOption.colorSpace: CGColorSpaceCreateDeviceRGB(),
                     CIContextOption.outputPremultiplied: true,
                     CIContextOption.useSoftwareRenderer: false] as! [CIImageOption: Any]
        let CImage = CIImage(mtlTexture: AdjustedTexture!, options: ImgOp)
        #if true
        let Final = UIImage(ciImage: CImage!)
        #else
        let rep = NSCIImageRep(ciImage: CImage!)
        let Final = UIImage(size: ImageSize)
        Final.addRepresentation(rep)
        #endif
        return Final
    }
}

