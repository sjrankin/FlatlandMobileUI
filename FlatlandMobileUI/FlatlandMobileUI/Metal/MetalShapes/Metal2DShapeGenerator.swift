//
//  Metal2DShapeGenerator.swift
//  Metal2DShapeGenerator
//
//  Created by Stuart Rankin on 7/19/21. Adapted from Flatland View.
//

import Foundation
import UIKit
import simd
import Metal
import MetalKit
import CoreImage

class Metal2DShapeGenerator
{
    private let ImageDevice = MTLCreateSystemDefaultDevice()
    private var ImageComputePipelineState: MTLComputePipelineState? = nil
    private lazy var ImageCommandQueue: MTLCommandQueue? =
    {
        return self.ImageDevice?.makeCommandQueue()
    }()
    
    init()
    {
        
    }
    
    func CreateLibrary(With Name: String)
    {
        let DefaultLibrary = ImageDevice?.makeDefaultLibrary()
        let KernelFunction = DefaultLibrary?.makeFunction(name: Name)
        do
        {
            ImageComputePipelineState = try ImageDevice?.makeComputePipelineState(function: KernelFunction!)
        }
        catch
        {
            print("Error creating pipeline state for \(Name): \(error.localizedDescription)")
        }
    }
    
    func DrawCircle(BaseSize: CGSize, Radius: Int, Interior: UIColor, Background: UIColor,
                    BorderColor: UIColor, BorderWidth: Int) -> UIImage?
    {
        if BorderWidth > 0
        {
            print("Creating circle with border")
            CreateLibrary(With: "DrawCircleWithBorder")
        }
        else
        {
            print("Creating circle without border")
            CreateLibrary(With: "DrawCircle")
        }
        return DoDraw(.Circle, Size: BaseSize, Radius: Radius, InteriorColor: Interior, BorderColor: BorderColor,
                      BorderWidth: BorderWidth, BackgroundColor: Background)
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
    private func DoDraw(_ Shape: MetalShapes, Size: CGSize, Radius: Int, InteriorColor: UIColor, BorderColor: UIColor,
                        BorderWidth: Int, BackgroundColor: UIColor) -> UIImage?
    {
        print("BorderWidth: \(BorderWidth), Radius: \(Radius)")
        let Parameter = ShapeParameters(CircleRadius: simd_uint1(Radius),
                                        BackgroundColor: MetalLibrary.ToFloat4(BackgroundColor),
                                        InteriorColor: MetalLibrary.ToFloat4(InteriorColor),
                                        BorderWidth: simd_uint1(BorderWidth),
                                        BorderColor: MetalLibrary.ToFloat4(BorderColor))
        let Parameters = [Parameter]
        let ParameterBuffer = ImageDevice!.makeBuffer(length: MemoryLayout<ShapeParameters>.stride, options: [])
        memcpy(ParameterBuffer!.contents(), Parameters, MemoryLayout<ShapeParameters>.stride)
        
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

enum MetalShapes: String, CaseIterable
{
    case Circle = "Circle"
}
