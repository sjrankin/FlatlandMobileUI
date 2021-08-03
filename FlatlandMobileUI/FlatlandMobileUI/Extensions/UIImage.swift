//
//  UIImage.swift
//  UIImage
//
//  Created by Stuart Rankin on 7/18/21. Based on code from Flatland View.
//

import Foundation
import UIKit
import CoreImage
import CoreImage.CIFilterBuiltins
import MetalKit
import Metal

// MARK: - UIImage extensions.

/// Extension methods for UIImage.
extension UIImage
{
    /// Initializer that creates a solid color image of the passed size.
    /// - Note: Do *not* use the draw swatch function as it incorrectly draws transparent colors.
    /// - Parameter Color: The color to use to create the image.
    /// - Parameter Size: The size of the image.
    convenience init(Color: UIColor, Size: CGSize)
    {
        self.init(size: Size, color:Color)
    }
    
    convenience init(size: CGSize, color: UIColor = UIColor.white)
    {
        let rect = CGRect(origin: .zero, size: size)
        UIGraphicsBeginImageContextWithOptions(rect.size, false, 0.0)
        color.setFill()
        UIRectFill(rect)
        let image = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        
        guard let cgImage = image?.cgImage else
        {
            Debug.FatalError("Error converting imate to cgImage.")
        }
        self.init(cgImage: cgImage)
    }
    
#if true
    /// Rotate the instance image to the number of passed radians.
    /// - Note: See [Rotating UIImage in Swift](https://stackoverflow.com/questions/27092354/rotating-uiimage-in-swift/47402811#47402811)
    /// - Parameter Radians: Number of radians to rotate the image to.
    /// - Returns: Rotated image.
    func Rotate(Radians: CGFloat) -> UIImage
    {
        var NewSize = CGRect(origin: CGPoint.zero, size: self.size).applying(CGAffineTransform(rotationAngle: Radians)).size
        NewSize.width = floor(NewSize.width)
        NewSize.height = floor(NewSize.height)
        UIGraphicsBeginImageContextWithOptions(NewSize, false, self.scale)
        let Context = UIGraphicsGetCurrentContext()
        Context?.translateBy(x: NewSize.width / 2, y: NewSize.height / 2)
        Context?.rotate(by: Radians)
        self.draw(in: CGRect(x: -self.size.width / 2, y: -self.size.height / 2,
                             width: self.size.width, height: self.size.height))
        let Rotated = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        return Rotated!
    }
#else
    //https://stackoverflow.com/questions/31699235/rotate-UIImage-in-swift-cocoa-mac-osx
    func Rotate(Radians: CGFloat) -> UIImage
    {
        let SinDegrees = abs(Radians)
        let CosDegrees = abs(Radians)
        let newSize = CGSize(width: size.height * SinDegrees + size.width * CosDegrees,
                             height: size.width * SinDegrees + size.height * CosDegrees)
        
        let imageBounds = CGRect(x: (newSize.width - size.width) / 2,
                                 y: (newSize.height - size.height) / 2,
                                 width: size.width, height: size.height)
        
        let otherTransform = CGAffineTransform()
        otherTransform.translatedBy(x: newSize.width / 2, y: newSize.height / 2)
        otherTransform.rotated(by: Radians)
        otherTransform.translatedBy(x: -newSize.width / 2, y: -newSize.height / 2)
        
        let rotatedImage = UIImage(size: newSize)
        rotatedImage.lockFocus()
        otherTransform.concat()
        draw(in: imageBounds, from: CGRect.zero, operation: CompositingOperation.copy, fraction: 1.0)
        rotatedImage.unlockFocus()
        
        return rotatedImage
    }
#endif
    
    /// Rotate the instance image of the number of passed degrees.
    /// - Note: See [Rotating UIImage in Swift](https://stackoverflow.com/questions/27092354/rotating-uiimage-in-swift/47402811#47402811)
    /// - Parameter Degrees: Number of degrees to rotate the image to.
    /// - Returns: Rotated image.
    func Rotate(Degrees: CGFloat) -> UIImage
    {
        return Rotate(Radians: Degrees.Radians)
    }
    
    #if true
    func Alpha(_ Value: CGFloat) -> UIImage
    {
        UIGraphicsBeginImageContextWithOptions(size, false, scale)
        draw(at: CGPoint.zero, blendMode: .normal, alpha: Value)
        let NewImage = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        return NewImage!
    }
    #else
    /// Set's the instance image's alpha value (for all pixels).
    /// - Notes: See [Set alpha of image programmatically](https://stackoverflow.com/questions/28517866/how-to-set-the-alpha-of-an-uiimage-in-swift-programmatically).
    /// - Parameter Value: The new alpha value.
    /// - Returns: New image with all pixels set to the passed alpha value.
    func Alpha(_ Value: CGFloat) -> UIImage
    {
        let ImageRect = CGRect(x: 0, y: 0, width: self.size.width, height: self.size.height)
        guard let ImageRep = self.bestRepresentation(for: ImageRect, context: nil, hints: nil) else
        {
            fatalError("Error creating image representation.")
        }
        let Image = UIImage(size: self.size, flipped: false, drawingHandler:
                                {
            _ in
            return ImageRep.draw(in: CGRect(origin: CGPoint.zero, size: self.size),
                                 from: CGRect(origin: CGPoint.zero, size: self.size),
                                 operation: .copy,
                                 fraction: Value,
                                 respectFlipped: false,
                                 hints: nil)
        }
        )
        return Image
    }
    #endif
    
    /// Write the instance image to a file.
    /// - Note: See [How to save an UIImage as a file.](https://stackoverflow.com/questions/3038820/how-to-save-a-UIImage-as-a-new-file)
    /// - Parameter ToURL: The URL where to save the image.
    /// - Returns: True on success, false if the image cannot be saved.
    @discardableResult public func WritePNG(ToURL: URL) -> Bool
    {
        #if true
        if let data = self.pngData()
        {
            try? data.write(to: ToURL)
        }
        #else
        guard let Data = self.tiffRepresentation,
              let Rep = NSBitmapImageRep(data: Data),
              let ImgData = Rep.representation(using: .png,
                                               properties: [.compressionFactor: NSNumber(floatLiteral: 1.0)]) else
              {
                  print("Error getting data for image to save.")
                  return false
              }
        do
        {
            try ImgData.write(to: ToURL)
        }
        catch
        {
            print("Error writing data: \(error.localizedDescription)")
            return false
        }
        #endif
        return true
    }
    
    /// Write the instance image as a .png to the specified URL.
    /// - Parameter ToURL: Where to write the instance image.
    /// - Parameter With: The color of the background.
    /// - Returns: True on success, false on failure.
    public func WritePNG(ToURL: URL, With BackgroundColor: UIColor) -> Bool
    {
        let BlackImage = UIImage(Color: UIColor.black, Size: self.size)
        #if true
        UIGraphicsBeginImageContext(BlackImage.size)
        self.draw(at: .zero)
        let FinalImage = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        return BlackImage.WritePNG(ToURL: ToURL)
        #else
        BlackImage.lockFocus()
        let SelfRect = CGRect(origin: CGPoint.zero, size: self.size)
        self.draw(at: CGPoint.zero, from: SelfRect, operation: .overlay, fraction: 1.0)
        BlackImage.unlockFocus()
        return BlackImage.WritePNG(ToURL: ToURL)
        #endif
    }
    
    /// Returns an image based on the instance with a new brightness level.
    /// - Parameter To: The new brightness level.
    /// - Returns: New image with the adjusted brightness. Same image is returned on error.
    public func SetImageBrightness(To NewLevel: Double) -> UIImage
    {
        #if true
        let Source = CIImage(cgImage: self.cgImage!)
        let ColorControl = CIFilter.colorControls()
        ColorControl.inputImage = Source
        ColorControl.brightness = Float(NewLevel)
        if let Changed = ColorControl.outputImage
        {
            let Final = UIImage(ciImage: Changed)
            return Final
        }
        else
        {
            print("Error changing brightness level to \(NewLevel) - unchanged image returned")
            return self
        }
        #else
        let SourceData = self.tiffRepresentation!
        let Source = CIImage(data: SourceData)
        let ColorControl = CIFilter.colorControls()
        ColorControl.inputImage = Source
        ColorControl.brightness = Float(NewLevel)
        if let Changed = ColorControl.outputImage
        {
            let Rep = NSCIImageRep(ciImage: Changed)
            let Final = UIImage(size: Rep.size)
            Final.addRepresentation(Rep)
            return Final
        }
        else
        {
            print("Error changing brightness level to \(NewLevel) - unchanged image returned")
            return self
        }
        #endif
    }
    
    /// Crop the instance image to the passed rectangle.
    /// - Parameter To: The rectangle in the image to return.
    /// - Returns: Cropped image from the instance image. Nil on error.
    public func Crop(To: CGRect) -> UIImage?
    {
        #if true
        let Source = CIImage(cgImage: self.cgImage!)
        let Cropped = Source.cropped(to: To)
            let Final = UIImage(ciImage: Cropped)
            return Final
        #else
        let SourceData = self.tiffRepresentation!
        let Source = CIImage(data: SourceData)
        if let Cropped = Source?.cropped(to: To)
        {
            let Rep = NSCIImageRep(ciImage: Cropped)
            let Final = UIImage(size: Rep.size)
            Final.addRepresentation(Rep)
            return Final
        }
        else
        {
            return nil
        }
        #endif
    }
    
    /// Split the instance image into two horizontal pieces.
    /// - Parameter At: The X coordinate where the split will take place. If this value
    ///                 is invalid, nil will be returned.
    /// - Returns: Tuple of the left image and the right image. Nil on error.
    public func SplitHorizontally(At: Int) -> (Left: UIImage, Right: UIImage)?
    {
        if At < 0
        {
            return nil
        }
        if At > Int(self.size.width - 1)
        {
            return nil
        }
        let LeftWidth = CGFloat(At - 1)
        let RightWidth = self.size.width - LeftWidth
        let LeftRect = CGRect(x: 0, y: 0,
                              width: LeftWidth,
                              height: self.size.height)
        let RightRect = CGRect(x: CGFloat(At), y: 0,
                               width: RightWidth,
                               height: self.size.height)
        let LeftImage = self.Crop(To: LeftRect)!
        let RightImage = self.Crop(To: RightRect)!
        return (LeftImage, RightImage)
    }
    
    /// Split the instance image into two vertical pieces.
    /// - Parameter At: The Y coordinate where the split will take place. If this value
    ///                 is invalid, nil will be returned.
    /// - Returns: Tuple of the top image and the bottom image. Nil on error.
    public func SplitVertically(At: Int) -> (Top: UIImage, Bottom: UIImage)?
    {
        if At < 0
        {
            return nil
        }
        if At > Int(self.size.height - 1)
        {
            return nil
        }
        let TopHeight = CGFloat(At - 1)
        let BottomHeight = self.size.height - TopHeight
        let TopRect = CGRect(x: 0, y: 0,
                             width: self.size.width,
                             height: TopHeight)
        let BottomRect = CGRect(x: 0, y: CGFloat(At),
                                width: self.size.width,
                                height: BottomHeight)
        let TopImage = self.Crop(To: TopRect)!
        let BottomImage = self.Crop(To: BottomRect)!
        return (TopImage, BottomImage)
    }
    
    /// Adjusts the colorspace of the passed image from monochrome to device RGB. If the passed image is
    /// not grayscale, it is returned unchanged but converted to `CGImage`.
    /// - Parameter For: The image whose color space may potentially be changed.
    /// - Parameter ForceSize: If not nil, the size to force internal conversions to.
    /// - Returns: New image (in `CGImage` format). This image will *not* have a monochrome color space
    ///            (even if visually is looks monochromatic).
    public static func AdjustColorSpace(For Image: UIImage, ForceSize: CGSize? = nil) -> CGImage?
    {
        #if true
        return MetalLibrary.AdjustColorSpace(For: Image, ForceSize: ForceSize)
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
                let GContext = CGContext(data: &RawData, width: IWidth, height: IHeight,
                                         bitsPerComponent: 8, bytesPerRow: 4 * IWidth,
                                         space: NewColorSpace, bitmapInfo: NewBMInfo.rawValue)
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
    
    #if false
    /// Create a Metal texture from the instance image.
    /// - Note: See [UIImage to CGImage](https://stackoverflow.com/questions/24595908/swift-UIImage-to-cgimage#27759114)
    /// - Parameter ForWriting: If true, the texture is marked for writing. Otherwise, it is marked for reading
    ///                         only.
    /// - Parameter ImageDevice: The Metal device where the texture will be used.
    /// - Parameter AsCG: The Core Graphics version of the image returned on success.
    /// - Returns: The Metal texture equivalent of the instance image.
    public func MakeTextureY(ForWriting: Bool = false, ImageDevice: MTLDevice,
                             AsCG: inout CGImage?) -> MTLTexture?
    {
        let ImageData = self.tiffRepresentation!
        let Source = CGImageSourceCreateWithData(ImageData as CFData, nil).unsafelyUnwrapped
        let MaskRef = CGImageSourceCreateImageAtIndex(Source, Int(0), nil)
        let Adjusted = MaskRef.unsafelyUnwrapped
        AsCG = Adjusted
        let MTK = MTKTextureLoader(device: ImageDevice)
        do
        {
            var Usage = [MTKTextureLoader.Option: Any]()
            Usage[.textureUsage] = MTLTextureUsage.shaderRead.rawValue
            if ForWriting
            {
                Usage[.textureUsage] = MTLTextureUsage.shaderRead.rawValue | MTLTextureUsage.shaderWrite.rawValue
            }
            do
            {
                let Result = try MTK.newTexture(cgImage: Adjusted, options: Usage)
                return Result
            }
            catch
            {
                Debug.Print(".newTexture returned nil. {ForWriting: \(ForWriting)}: \(error.localizedDescription)")
                return nil
            }
        }
    }
    #endif
    
    /// Convert an `UIImage` to a `MTLTexture` for use with Metal compute shaders.
    /// - Parameter ForWriting: If true, the returned Metal texture will allow writing. Otherwise, it will
    ///                         only allow reading. Defaults to `false`.
    /// - Parameter ImageDevice: The `MTLDevice` where the Metal texture will be used.
    /// - Parameter AsCG: Upon exit, will contain the `CGImage` version of `From`.
    /// - Returns: Metal texture conversion of `From` on success, nil on failure.
    public  func MakeTextureX(ForWriting: Bool = false, ImageDevice: MTLDevice,
                              AsCG: inout CGImage?) -> MTLTexture?
    {
        let ImageSize = self.size
        if let Adjusted = MetalLibrary.AdjustColorSpace(For: self, ForceSize: ImageSize)
        {
            AsCG = Adjusted
            let MTK = MTKTextureLoader(device: ImageDevice)
            do
            {
                var Usage = [MTKTextureLoader.Option: Any]()
                Usage[.textureUsage] = MTLTextureUsage.shaderRead.rawValue
                if ForWriting
                {
                    Usage[.textureUsage] = [MTLTextureUsage.shaderRead.rawValue, MTLTextureUsage.shaderWrite.rawValue]
                }
                let Result = try MTK.newTexture(cgImage: Adjusted, options: Usage)
                return Result
            }
            catch
            {
                Debug.Print(".newTexture returned nil. {ForWriting: \(ForWriting)}: \(error.localizedDescription)")
                return nil
            }
        }
        Debug.Print("Error adjusting color space.")
        return nil
    }
    
    public func MakeTextureZ(ForWriting: Bool = false, ImageDevice: MTLDevice,
                             AsCG: inout CGImage?) -> MTLTexture?
    {
        Debug.Print("At start of MakeTexture")
        defer{Debug.Print("At exit of MakeTexture")}
        let ImageSize = self.size
        if let Adjusted = UIImage.AdjustColorSpace(For: self, ForceSize: ImageSize)
        {
            AsCG = Adjusted
            let ImageWidth: Int = Adjusted.width
            let ImageHeight: Int = Adjusted.height
            var RawData = [UInt8](repeating: 0, count: Int(ImageWidth * ImageHeight * 4))
            let RGBColorSpace = CGColorSpaceCreateDeviceRGB()
            let BitmapInfo = Adjusted.bitmapInfo
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
            return TileTexture
        }
        return nil
    }
    
    /// Create a Metal texture from the instance image.
    /// - Parameter ForWriting: If true, the resultant texture can be written to, if false, the texture is
    ///                         read-only.
    /// - Paramater ImageDevice: The device where Metal runs.
    /// - Paramater AsCG: On success, contains the instance image as a `CGImage`.
    /// - Returns: A `MTLTexture` on success, nil on failure.
    public func MakeTexture(ForWriting: Bool = false, ImageDevice: MTLDevice,
                            AsCG: inout CGImage?) -> MTLTexture?
    {
        if let Adjusted = self.ToCGImage()
        {
            AsCG = Adjusted
            let ImageWidth: Int = Adjusted.width
            let ImageHeight: Int = Adjusted.height
            var RawData = [UInt8](repeating: 0, count: Int(ImageWidth * ImageHeight * 4))
            let RGBColorSpace = CGColorSpaceCreateDeviceRGB()
            let BitmapInfo = Adjusted.bitmapInfo
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
            return TileTexture
        }
        return nil
    }
    
    func ToCGImage() -> CGImage?
    {
        #if true
        let Step1 = CIImage(image: self)
        let Context = CIContext(options: nil)
        return Context.createCGImage(Step1!, from: Step1!.extent)
        #else
        guard let ImageData = self.tiffRepresentation else
        {
            return nil
        }
        guard let SourceData = CGImageSourceCreateWithData(ImageData as CFData, nil) else
        {
            return nil
        }
        let Final = CGImageSourceCreateImageAtIndex(SourceData, 0, nil)
        return Final
        #endif
    }
    
    func ToCGImage(_ Source: CIImage) -> CGImage?
    {
        let Context = CIContext(options: nil)
        if let CG = Context.createCGImage(Source, from: Source.extent)
        {
            return CG
        }
        return nil
    }
    
    func ShiftImageRight(By Horizontal: Int) -> UIImage
    {
        if Horizontal <= 0
        {
            return self
        }
        
        let Size = self.size
        let Filter = CIFilter(name: "CICrop")
        //let SourceData = self.tiffRepresentation
        //let CISource = CIImage(data: SourceData!)
        let CISource = CIImage(image: self)
        
        let RightWidth = CGFloat(Horizontal)
        let LeftWidth = Size.width - RightWidth
        
        Filter?.setDefaults()
        Filter?.setValue(CISource, forKey: "inputImage")
        let LeftRegion = CIVector(x: 0, y: 0, z: LeftWidth, w: Size.height)
        Filter?.setValue(LeftRegion, forKey: "inputRectangle")
        let LeftImage = Filter?.outputImage
        let CGLeft = ToCGImage(LeftImage!)
        let NSLeft = UIImage(cgImage: CGLeft!)
        
        Filter?.setDefaults()
        Filter?.setValue(CISource, forKey: "inputImage")
        let RightRegion = CIVector(x: Size.width - CGFloat(Horizontal), y: 0, z: RightWidth, w: Size.height)
        Filter?.setValue(RightRegion, forKey: "inputRectangle")
        let RightImage = Filter?.outputImage
        let CGRight = ToCGImage(RightImage!)
        let NSRight = UIImage(cgImage: CGRight!)
        
        let FinalSize = Size
        let Final = BlitImages(FinalSize: FinalSize, Images: [NSRight, NSLeft])
        
        return Final
    }
    
    func ShiftImageLeft(By Horizontal: Int) -> UIImage
    {
        let ShiftBy = abs(Horizontal)
        
        let Size = self.size
        let Filter = CIFilter(name: "CICrop")
        let CISource = CIImage(image: self)
        //let SourceData = self.tiffRepresentation
        //let CISource = CIImage(data: SourceData!)
        
        Filter?.setDefaults()
        Filter?.setValue(CISource, forKey: "inputImage")
        let LeftRegion = CIVector(x: 0, y: 0, z: CGFloat(ShiftBy), w: Size.height)
        Filter?.setValue(LeftRegion, forKey: "inputRectangle")
        let LeftImage = Filter?.outputImage
        let CGLeft = ToCGImage(LeftImage!)
        let NSLeft = UIImage(cgImage: CGLeft!)
        
        Filter?.setDefaults()
        Filter?.setValue(CISource, forKey: "inputImage")
        let RightRegion = CIVector(x: CGFloat(ShiftBy), y: 0, z: Size.width - CGFloat(ShiftBy), w: Size.height)
        Filter?.setValue(RightRegion, forKey: "inputRectangle")
        let RightImage = Filter?.outputImage
        let CGRight = ToCGImage(RightImage!)
        let NSRight = UIImage(cgImage: CGRight!)
        
        let FinalSize = Size
        let Final = BlitImages(FinalSize: FinalSize, Images: [NSRight, NSLeft])
        
        return Final
    }
    
    func HorizontalShift(By Amount: Int) -> UIImage
    {
        if Amount >= 0
        {
            return ShiftImageRight(By: Amount)
        }
        else
        {
            return ShiftImageLeft(By: Amount)
        }
    }
    
    //https://bluelemonbits.com/2019/12/30/creating-a-collage-by-combining-an-array-of-images-macos-ios/
    func BlitImages(FinalSize: CGSize, Images: [UIImage]) -> UIImage
    {
        #if true
        if Images.count == 0
        {
            Debug.FatalError("Too few images (0) passed to BlitImages.")
        }
        if Images.count == 1
        {
            return Images.first!
        }
        let Target = UIImage(size: CGSize(width: FinalSize.width, height: FinalSize.height))
        var Left: CGFloat = 0.0
        for Index in 0 ..< Images.count
        {
            let DrawRect = CGRect(x: Left, y: 0,
                                  width: Images[Index].size.width, height: Images[Index].size.height)
            Left = Left + Images[Index].size.width
            Images[Index].draw(in: DrawRect)
        }
        return Target
        #else
        if Images.count == 1
        {
            return Images.first!
        }
        let Target = UIImage(size: CGSize(width: FinalSize.width, height: FinalSize.height))
        Target.lockFocus()
        var Left: CGFloat = 0.0
        for Index in 0 ..< Images.count
        {
            let DrawRect = CGRect(x: Left, y: 0,
                                  width: Images[Index].size.width, height: Images[Index].size.height)
            Left = Left + Images[Index].size.width
            Images[Index].draw(in: DrawRect)
        }
        Target.unlockFocus()
        return Target
        #endif
    }
    
    func HorizontalFlip() -> UIImage
    {
        #if true
        var Flipped = UIImage(size: self.size)
        UIGraphicsBeginImageContextWithOptions(Flipped.size, false, self.scale)
        let Context = UIGraphicsGetCurrentContext()
        let Transform = CGAffineTransform()
        Transform.translatedBy(x: self.size.width, y: 0.0)
        Transform.scaledBy(x: -1, y: 1)
        self.draw(in: CGRect(x: -self.size.width / 2, y: -self.size.height / 2,
                             width: self.size.width, height: self.size.height))
        Flipped = UIGraphicsGetImageFromCurrentImageContext()!
        UIGraphicsEndImageContext()
        return Flipped
        #else
        let Flipped = UIImage(size: self.size)
        Flipped.lockFocus()
        NSGraphicsContext.current?.imageInterpolation = .high
        let Transform = NSAffineTransform()
        Transform.translateX(by: self.size.width, yBy: 0.0)
        Transform.scaleX(by: -1, yBy: 1)
        Transform.concat()
        self.draw(at: .zero, from: CGRect(origin: .zero, size: self.size), operation: .sourceOver, fraction: 1.0)
        Flipped.unlockFocus()
        return Flipped
        #endif
    }
}

