//
//  MetalGradient.swift
//  MetalGradient
//
//  Created by Stuart Rankin on 7/19/21. Adapted from Flatland View.
//

import Foundation
import UIKit
import simd
import Metal
import MetalKit

/// Wrapper around a Metal kernel to generate gradients.
class MetalGradient
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
    
    /// Create a radial gradient.
    /// - Warning: If the count of `Colors` is not identical to the count of `Locations`, a fatal error
    ///            is thrown.
    /// - Parameter Size: The size of the image upon which the radial gradient is drawn.
    /// - Parameter Colors: Array of colors to used to draw the radial gradient.
    /// - Parameter TerminalColors: Array of colors used the terminal color.
    /// - Parameter Locations: Array of locations that correspond to the colors in `Colors` for the gradient
    ///                        stops.
    /// - Returns: Image of with the gradient on success, nil on error.
    func CreateRadial(Size: CGSize, Colors: [UIColor], TerminalColors: [UIColor], Locations: [CGPoint]) -> UIImage?
    {
        if Colors.count != Locations.count || Colors.count != TerminalColors.count
        {
            fatalError("Number of colors and locations must match. \(#function)")
        }
        var Stops = [MetalGradientStop]()
        for Index in 0 ..< Colors.count
        {
            let GradientStop = MetalGradientStop()
            GradientStop.StopColor = Colors[Index]
            GradientStop.StopX = Double(Locations[Index].x)
            GradientStop.StopY = Double(Locations[Index].y)
            GradientStop.TerminalColor = TerminalColors[Index]
            Stops.append(GradientStop)
        }
        return Create(Size: Size, GradientType: .Radial, GradientStops: Stops)
    }
    
    /// Create a horizontal gradient.
    /// - Warning: If the count of `Colors` is not identical to the count of `Locations`, a fatal error
    ///            is thrown.
    /// - Parameter Size: The size of the image upon which the radial gradient is drawn.
    /// - Parameter Colors: Array of colors to used to draw the radial gradient.
    /// - Parameter TerminalColors: Array of colors to use as the terminal color for the repsective gradient
    ///                             stop. If nil is passed, black is used.
    /// - Parameter Locations: Array of locations that correspond to the colors in `Colors` for the gradient
    ///                        stops.
    /// - Returns: Image of with the gradient on success, nil on error.
    func CreateHorizontal(Size: CGSize, Colors: [UIColor], TerminalColors: [UIColor]? = nil, Locations: [CGPoint]) -> UIImage?
    {
        if Colors.count != Locations.count
        {
            fatalError("Number of colors and locations must match. \(#function)")
        }
        var TColors = [UIColor]()
        if let Terminal = TerminalColors
        {
            if Terminal.count != Colors.count
            {
                fatalError("Number of terminal colors does not match number of colors. \(#function)")
            }
            for Color in Terminal
            {
                TColors.append(Color)
            }
        }
        else
        {
            for _ in 0 ..< Colors.count
            {
                TColors.append(UIColor(red: 0.0, green: 0.0, blue: 0.0, alpha: 1.0))
            }
        }
        var Stops = [MetalGradientStop]()
        for Index in 0 ..< Colors.count
        {
            let GradientStop = MetalGradientStop()
            GradientStop.StopColor = Colors[Index]
            GradientStop.StopX = Double(Locations[Index].x)
            GradientStop.StopY = Double(Locations[Index].y)
            GradientStop.TerminalColor = TColors[Index]
            Stops.append(GradientStop)
        }
        return Create(Size: Size, GradientType: .LinearHorizontal, GradientStops: Stops)
    }
    
    /// Create a vertical gradient.
    /// - Warning: If the count of `Colors` is not identical to the count of `Locations`, a fatal error
    ///            is thrown.
    /// - Parameter Size: The size of the image upon which the radial gradient is drawn.
    /// - Parameter Colors: Array of colors to used to draw the radial gradient.
    /// - Parameter TerminalColors: Array of colors to use as the terminal color for the repsective gradient
    ///                             stop. If nil is passed, black is used.
    /// - Parameter Locations: Array of locations that correspond to the colors in `Colors` for the gradient
    ///                        stops.
    /// - Returns: Image of with the gradient on success, nil on error.
    func CreateVertical(Size: CGSize, Colors: [UIColor], TerminalColors: [UIColor]? = nil,  Locations: [CGPoint]) -> UIImage?
    {
        if Colors.count != Locations.count
        {
            fatalError("Number of colors and locations must match. \(#function)")
        }
        var TColors = [UIColor]()
        if let Terminal = TerminalColors
        {
            if Terminal.count != Colors.count
            {
                fatalError("Number of terminal colors does not match number of colors. \(#function)")
            }
            for Color in Terminal
            {
                TColors.append(Color)
            }
        }
        else
        {
            for _ in 0 ..< Colors.count
            {
                TColors.append(UIColor(red: 0.0, green: 0.0, blue: 0.0, alpha: 1.0))
            }
        }
        var Stops = [MetalGradientStop]()
        for Index in 0 ..< Colors.count
        {
            let GradientStop = MetalGradientStop()
            GradientStop.StopColor = Colors[Index]
            GradientStop.StopX = Double(Locations[Index].x)
            GradientStop.StopY = Double(Locations[Index].y)
            GradientStop.TerminalColor = TColors[Index]
            Stops.append(GradientStop)
        }
        return Create(Size: Size, GradientType: .LinearVertical, GradientStops: Stops)
    }
    
    /// Create a gradient.
    /// - Warning: If the count of `Colors` is not identical to the count of `Locations`, a fatal error
    ///            is thrown.
    /// - Parameter Size: The size of the image upon which the radial gradient is drawn.
    /// - Parameter GradientType: The type of gradient to create. See `MetalGradientTypes`.
    /// - Parameter GradientStops: Array of `MetalGradientStop` classes that define the stops to send to the
    ///                            kernel to create the gradient.
    /// - Returns: Image of with the gradient on success, nil on error.
    func Create(Size: CGSize, GradientType: MetalGradientTypes, GradientStops: [MetalGradientStop]) -> UIImage?
    {
        var KernelName = ""
        switch GradientStops.count
        {
            case 1:
                KernelName = "MetalGradientKernel1P"
                
            case 2:
                KernelName = "MetalGradientKernel2P"
                
            case 3:
                KernelName = "MetalGradientKernel3P"
                
            case 4:
                KernelName = "MetalGradientKernel4P"
                
            case 5:
                KernelName = "MetalGradientKernel5P"
                
            default:
                fatalError("Invalid number of parameters: \(GradientStops.count): Must be in the range 1...5")
        }
        switch GradientType
        {
            case .LinearHorizontal:
                KernelName.append("H")
                
            case .LinearVertical:
                KernelName.append("V")
                
            case .Radial:
                KernelName.append("R")
        }
        
        let DefaultLibrary = ImageDevice?.makeDefaultLibrary()
        let KernelFunction = DefaultLibrary?.makeFunction(name: KernelName)
        do
        {
            ImageComputePipelineState = try ImageDevice?.makeComputePipelineState(function: KernelFunction!)
        }
        catch
        {
            print("Error creating pipeline state: \(error.localizedDescription)")
        }
        return DoCreate(Size: Size, GradientType: GradientType, GradientStops: GradientStops)
    }
    
    private func DistanceBetween(Point1: CGPoint, Point2: CGPoint) -> Int
    {
        var XDelta = Double(Point1.x - Point2.x)
        var YDelta = Double(Point1.y - Point2.y)
        XDelta = XDelta * XDelta
        YDelta = YDelta * YDelta
        return Int(sqrt(XDelta + YDelta))
    }
    
    private func GreatestDistance(Size: CGSize, PointX: Int, PointY: Int) -> Int
    {
        let Point = CGPoint(x: PointX, y: PointY)
        let ULDistance = DistanceBetween(Point1: Point, Point2: CGPoint(x: 0, y: 0))
        let URDistance = DistanceBetween(Point1: Point, Point2: CGPoint(x: Size.width, y: 0))
        let LLDistance = DistanceBetween(Point1: Point, Point2: CGPoint(x: 0, y: Size.height))
        let LRDistance = DistanceBetween(Point1: Point, Point2: CGPoint(x: Size.width, y: Size.height))
        return max(ULDistance, max(URDistance, max(LLDistance, LRDistance)))
    }
    
    private func DoCreate(Size: CGSize, GradientType: MetalGradientTypes, GradientStops: [MetalGradientStop]) -> UIImage?
    {
        var ParameterBuffer: MTLBuffer!
        switch GradientStops.count
        {
            case 1:
                let Stop1X = Int(Size.width * CGFloat(GradientStops[0].StopX))
                //Given macOS insists on having the origin in the lower left (and not upper left), we need to
                //invert Y coordinates to have them seem reasonable to users.
                let Stop1Y = Int(Size.height) - Int(Size.height * CGFloat(GradientStops[0].StopY))
                var MaxDistance = Int(max(Size.width, Size.height))
                if GradientType == .Radial
                {
                    MaxDistance = GreatestDistance(Size: Size, PointX: Stop1X, PointY: Stop1Y)
                }
                let Parameter = GradientParameters1P(Stop1Color: MetalLibrary.ToFloat4(GradientStops[0].StopColor),
                                                     Stop1X: simd_uint1(Stop1X),
                                                     Stop1Y: simd_uint1(Stop1Y),
                                                     MaxDistance1: simd_uint1(MaxDistance),
                                                     RadialTerminal1: MetalLibrary.ToFloat4(GradientStops[0].TerminalColor))
                let Parameters = [Parameter]
                ParameterBuffer = ImageDevice!.makeBuffer(length: MemoryLayout<GradientParameters1P>.stride, options: [])
                memcpy(ParameterBuffer!.contents(), Parameters, MemoryLayout<GradientParameters1P>.stride)
                
            case 2:
                let Stop1X = Int(Size.width * CGFloat(GradientStops[0].StopX))
                let Stop1Y = Int(Size.height) - Int(Size.height * CGFloat(GradientStops[0].StopY))
                var MaxDistance1 = Int(max(Size.width, Size.height))
                if GradientType == .Radial
                {
                    MaxDistance1 = GreatestDistance(Size: Size, PointX: Stop1X, PointY: Stop1Y)
                }
                let Stop2X = Int(Size.width * CGFloat(GradientStops[1].StopX))
                let Stop2Y = Int(Size.height) - Int(Size.height * CGFloat(GradientStops[1].StopY))
                var MaxDistance2 = Int(max(Size.width, Size.height))
                if GradientType == .Radial
                {
                    MaxDistance2 = GreatestDistance(Size: Size, PointX: Stop2X, PointY: Stop2Y)
                }
                let Parameter = GradientParameters2P(Stop1Color: MetalLibrary.ToFloat4(GradientStops[0].StopColor),
                                                     Stop1X: simd_uint1(Stop1X),
                                                     Stop1Y: simd_uint1(Stop1Y),
                                                     MaxDistance1: simd_uint1(MaxDistance1),
                                                     RadialTerminal1: MetalLibrary.ToFloat4(GradientStops[0].TerminalColor),
                                                     Stop2Color: MetalLibrary.ToFloat4(GradientStops[1].StopColor),
                                                     Stop2X: simd_uint1(Stop2X),
                                                     Stop2Y: simd_uint1(Stop2Y),
                                                     MaxDistance2: simd_uint1(MaxDistance2),
                                                     RadialTerminal2: MetalLibrary.ToFloat4(GradientStops[1].TerminalColor))
                let Parameters = [Parameter]
                ParameterBuffer = ImageDevice!.makeBuffer(length: MemoryLayout<GradientParameters2P>.stride, options: [])
                memcpy(ParameterBuffer!.contents(), Parameters, MemoryLayout<GradientParameters2P>.stride)
                
            case 3:
                let Stop1X = Int(Size.width * CGFloat(GradientStops[0].StopX))
                let Stop1Y = Int(Size.height) - Int(Size.height * CGFloat(GradientStops[0].StopY))
                var MaxDistance1 = Int(max(Size.width, Size.height))
                if GradientType == .Radial
                {
                    MaxDistance1 = GreatestDistance(Size: Size, PointX: Stop1X, PointY: Stop1Y)
                }
                let Stop2X = Int(Size.width * CGFloat(GradientStops[1].StopX))
                let Stop2Y = Int(Size.height) - Int(Size.height * CGFloat(GradientStops[1].StopY))
                var MaxDistance2 = Int(max(Size.width, Size.height))
                if GradientType == .Radial
                {
                    MaxDistance2 = GreatestDistance(Size: Size, PointX: Stop2X, PointY: Stop2Y)
                }
                let Stop3X = Int(Size.width * CGFloat(GradientStops[2].StopX))
                let Stop3Y = Int(Size.height) - Int(Size.height * CGFloat(GradientStops[2].StopY))
                var MaxDistance3 = Int(max(Size.width, Size.height))
                if GradientType == .Radial
                {
                    MaxDistance3 = GreatestDistance(Size: Size, PointX: Stop3X, PointY: Stop3Y)
                }
                let Parameter = GradientParameters3P(Stop1Color: MetalLibrary.ToFloat4(GradientStops[0].StopColor),
                                                     Stop1X: simd_uint1(Stop1X),
                                                     Stop1Y: simd_uint1(Stop1Y),
                                                     MaxDistance1: simd_uint1(MaxDistance1),
                                                     RadialTerminal1: MetalLibrary.ToFloat4(GradientStops[0].TerminalColor),
                                                     Stop2Color: MetalLibrary.ToFloat4(GradientStops[1].StopColor),
                                                     Stop2X: simd_uint1(Stop2X),
                                                     Stop2Y: simd_uint1(Stop2Y),
                                                     MaxDistance2: simd_uint1(MaxDistance2),
                                                     RadialTerminal2: MetalLibrary.ToFloat4(GradientStops[1].TerminalColor),
                                                     Stop3Color: MetalLibrary.ToFloat4(GradientStops[2].StopColor),
                                                     Stop3X: simd_uint1(Stop3X),
                                                     Stop3Y: simd_uint1(Stop3Y),
                                                     MaxDistance3: simd_uint1(MaxDistance3),
                                                     RadialTerminal3: MetalLibrary.ToFloat4(GradientStops[2].TerminalColor))
                let Parameters = [Parameter]
                ParameterBuffer = ImageDevice!.makeBuffer(length: MemoryLayout<GradientParameters3P>.stride, options: [])
                memcpy(ParameterBuffer!.contents(), Parameters, MemoryLayout<GradientParameters3P>.stride)
                
            case 4:
                break
                
            case 5:
                break
                
            default:
                fatalError("Invalid number of gradient stops (\(GradientStops.count)) in \(#function)")
        }
        
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

/// Types of gradients the metal gradient generator supports.
enum MetalGradientTypes: Int
{
    /// Linear horizontal gradients.
    case LinearHorizontal = 0
    
    /// Linear vertical gradients.
    case LinearVertical = 1
    
    /// Radial gradients.
    case Radial = 2
}

/// Contains one gradient stop for use with `MetalGradient`.
class MetalGradientStop
{
    /// Default initializer.
    init()
    {
    }
    
    /// Initializer.
    /// - Parameter Stop: The color of the gradient stop.
    /// - Parameter X: The horizontal coordinate of the gradient stop.
    /// - Parameter Y: The vertical coordinate of the gradient stop.
    init(Stop Color: UIColor, X: Double, Y: Double)
    {
        StopColor = Color
        StopX = X
        StopY = Y
    }
    
    /// Horizontal stop location for the color. Normalized value.
    var StopX: Double = 0
    
    /// Vertical stop location for the color. Normalized value.
    var StopY: Double = 0
    
    /// Stop color.
    var StopColor: UIColor = UIColor.white
    
    /// Terminal color.
    var TerminalColor: UIColor = UIColor.black
    
    /// Maximum distance.
    var MaxDistance: Int = 0
}
