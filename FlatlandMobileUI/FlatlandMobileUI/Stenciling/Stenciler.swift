//
//  Stenciler.swift
//  Flatland
//
//  Created by Stuart Rankin on 8/11/20. Adapted from Flatland View.
//  Copyright © 2020, 2021 Stuart Rankin. All rights reserved.
//

import Foundation
import UIKit
import simd
import CoreImage
import CoreImage.CIFilterBuiltins

/// Class that stencils text and shapes onto images.
class Stenciler
{
    static var StencilingQueue: OperationQueue? = nil
    
    /// Run the stencil pipeline on the supplied map.
    /// - Note: Pipeline is in the order:
    ///   - 1: Regions.
    ///   - 2: Grid lines.
    ///   - 3: UNESCO sites.
    ///   - 4: City names.
    ///   - 5: Earthquake magnitudes.
    /// - Note: The subscriber closure is called after each pipeline stage has completed.
    /// - Warning: If the caller has not subscribed to pipeline notifications, control will return immediately
    ///            with no changes to the image.
    /// - Parameter To: The image to draw stencils on.
    /// - Parameter Quakes: List of earthquakes to plot. If this array is empty or nil, no earthquakes will
    ///                     be plotted even if `Stages` contains `.Earthquakes`.
    /// - Parameter Stages: Array of pipeline stages to perform. If this array is empty, no action is taken
    ///                     and the image is returned unchanged.
    /// - Parameter Caller: The caller. Must implement `StencilPipelineProtocol`.
    public static func RunStencilPipeline(To Image: UIImage,
                                          Quakes: [Earthquake]? = nil,
                                          Stages: [StencilStages],
                                          Caller: StencilPipelineProtocol)
    {
        objc_sync_enter(StencilLock)
        MemoryDebug.Open("RunStencilPipeLine")
        defer
        {
            MemoryDebug.Close("RunStencilPipeLine")
            objc_sync_exit(StencilLock)
        }
        Debug.Print("RunStencilPipeline: \(Stages)")
        if Quakes == nil && Stages.count < 1
        {
            //Nothing to do - return the image unaltered.
            Caller.StageCompleted(nil, nil, nil)
            Caller.StencilPipelineCompleted(Time: 0, Final: nil)
            return
        }
        let MapRatio: Double = Double(Image.size.width) / 3600.0
        let LocalQuakes = Quakes
        StencilingQueue = OperationQueue()
        StencilingQueue?.qualityOfService = .background
        StencilingQueue?.name = "Stencil Queue"
        StencilingQueue?.addOperation
        {
            Caller.StencilPipelineStarted(Time: CACurrentMediaTime())
            var Working = Image
            if Stages.contains(.GridLines)
            {
                Working = AddGridLines(To: Working, Ratio: MapRatio)
                Caller.StageCompleted(Working, .GridLines, CACurrentMediaTime())
            }
#if true
            Caller.StencilPipelineCompleted(Time: CACurrentMediaTime(), Final: Working)
#else
            if Stages.contains(.UNESCOSites)
            {
                Working = AddWorldHeritageDecals(To: Working, Ratio: MapRatio)
                Caller.StageCompleted(Working, .UNESCOSites, CACurrentMediaTime())
            }
            var Rep = GetImageRep(From: Working)
            if Stages.contains(.CityNames)
            {
                Rep = AddCityNames(To: Rep, Ratio: MapRatio)
                Caller.StageCompleted(GetImage(From: Rep), .CityNames, CACurrentMediaTime())
            }
            if Stages.contains(.Earthquakes)
            {
                if let QuakeList = LocalQuakes
                {
                    if QuakeList.count > 0
                    {
                        Rep = AddMagnitudeValues(To: Rep, With: QuakeList, Ratio: MapRatio)
                        Caller.StageCompleted(GetImage(From: Rep), .Earthquakes, CACurrentMediaTime())
                    }
                }
            }
            Caller.StencilPipelineCompleted(Time: CACurrentMediaTime(), Final: GetImage(From: Rep))
#endif
        }
    }
    
    /// Provides a lock from too many callers at once.
    private static let StencilLock = NSObject()
    
#if false
    /// Create a stencil layer.
    /// - Parameter Layer: Determines the contents of the image of the stencil layer.
    /// - Parameter LayerData: Data a given layer may need.
    /// - Parameter Completion: Closure that takes the final image and layer type.
    public static func AddStencils2(_ Layer: GlobeLayers,
                                    _ LayerData: Any? = nil,
                                    Completion: ((UIImage?, GlobeLayers) -> ())? = nil)
    {
        let Queue = OperationQueue()
        Queue.qualityOfService = .background
        Queue.name = "Thread for \(Layer.rawValue)"
        let MapRatio: Double = 1.0
        Queue.addOperation
        {
            var LayerImage: UIImage? = nil
            switch Layer
            {
                case .CityNames:
                    break
                    
                case .GridLines:
                    LayerImage = AddGridLines()//ApplyGridLines()
                    
                case .Lines:
                    break
                    
                case .Magnitudes:
                    if let Quakes = LayerData as? [Earthquake]
                    {
                        LayerImage = ApplyMagnitudes(Earthquakes: Quakes)
                    }
                    
#if false
                case .Regions:
                    let Regions = Settings.GetEarthquakeRegions()
                    LayerImage = ApplyRectangles(Regions: Regions)
#endif
                    
                case .WorldHeritageSites:
                    break
                    
#if true
                case .Test:
                    let RandomCircles = MakeRandomCircles()
                    LayerImage = ApplyCircles(Circles: RandomCircles)
#endif
                    
                default:
                    break
            }
            Completion?(LayerImage, Layer)
        }
    }
#endif
    
    /// Create an array of random circles.
    /// - Returns: Attay of circle records.
    private static func MakeRandomCircles() -> [CircleRecord]
    {
        var CircleList = [CircleRecord]()
        let Count = Int.random(in: 10 ... 20)
        for _ in 0 ..< Count
        {
            let RandomX = Int.random(in: 0 ... 3600)
            let RandomY = Int.random(in: 0 ... 1800)
            let Where = CGPoint(x: RandomX, y: RandomY)
            let RandomRadius = CGFloat.random(in: 50 ... 200)
            let RandomBorderWidth = CGFloat.random(in: 5 ... 15)
            let RandomColor = Utility.RandomColor()
            let RandomBorder = Utility.RandomColor()
            let SomeCircle = CircleRecord(Location: Where, Radius: RandomRadius,
                                          Color: RandomColor,
                                          OutlineColor: RandomBorder,
                                          OutlineWidth: RandomBorderWidth)
            CircleList.append(SomeCircle)
        }
        return CircleList
    }
    
    /// Add city names to the passed image representation.
    /// - Note: Determining the font size is dependent on several factors.
    /// - Parameter To: The image where city names will be added.
    /// - Parameter Ratio: Ratio between the standard sized map and the passed map.
    /// - Returns: Image representation with city names.
    private static func AddCityNames(To Image: UIImage, Ratio: Double) -> UIImage
    {
        var FontMultiplier: CGFloat = 1.0
        let ScaleFactor = UIScreen.main.scale
        var Working = Image
        var CitiesToPlot = CityManager.FilteredCities()
        if let UserCities = CityManager.OtherCities
        {
            CitiesToPlot.append(contentsOf: UserCities)
        }
        var PlotMe = [TextRecord]()
        let BaseFontSize = ScaleFactor >= 2.0 ? 32.0 : 16.0
        if Image.size.width / 2.0 < 3600.0
        {
            FontMultiplier = 2.0
        }
        let MapType = Settings.GetEnum(ForKey: .MapType, EnumType: MapTypes.self, Default: .Simple)
        if MapManager.CategoryFor(Map: MapType) == .Satellite
        {
            FontMultiplier = 0.8
        }
        let FontSize = CGFloat(BaseFontSize) * ScaleFactor * CGFloat(Ratio) * FontMultiplier
        
        for City in CitiesToPlot
        {
            let CityPoint = GeoPoint(City.Latitude, City.Longitude)
            let CityPointLocation = CityPoint.ToEquirectangular(Width: Int(Image.size.width),
                                                                Height: Int(Image.size.height))
            let Location = CGPoint(x: CityPointLocation.X + Int(Constants.StencilCityTextOffset.rawValue),
                                   y: CityPointLocation.Y)
            let CityColor = CityManager.ColorForCity(City)
            var LatitudeFontOffset = CGFloat(abs(City.Latitude) / 90.0)
            LatitudeFontOffset = CGFloat(Constants.StencilCitySize.rawValue) * LatitudeFontOffset
            let CityFont = UIFont.GetFont(InOrder: ["SFProText-Bold", "HelveticaNeue-Bold", "Avenir-Black", "ArialMT"],
                                          Size: FontSize + LatitudeFontOffset)
            let Record = TextRecord(Text: City.Name, Location: Location, Font: CityFont, Color: CityColor,
                                    OutlineColor: UIColor.black, QRCode: nil, Quake: nil)
            PlotMe.append(Record)
        }
        
        Working = DrawOn(Image: Image, Messages: PlotMe, ForQuakes: false)
        return Working
    }
    
    /// Plot UNESCO World Heritage Sites as decals on the stencil.
    /// - Parameter To: The image upon which sites are plotted.
    /// - Parameter Ration: The ratio between the standard size map and the current image.
    /// - Returns: Update image with World Heritage Sites plotted.
    private static func AddWorldHeritageDecals(To Image: UIImage, Ratio: Double) -> UIImage
    {
#if true
        return Image
#else
        let Working = Image
        let TypeFilter = Settings.GetEnum(ForKey: .WorldHeritageSiteType, EnumType: WorldHeritageSiteTypes.self, Default: .AllSites)
        let Sites = MainController.GetAllSites()
        var FinalList = [WorldHeritageSite]()
        for Site in Sites
        {
            switch TypeFilter
            {
                case .AllSites:
                    FinalList.append(Site)
                    
                case .Mixed:
                    if Site.Category == "Mixed"
                    {
                        FinalList.append(Site)
                    }
                    
                case .Natural:
                    if Site.Category == "Natural"
                    {
                        FinalList.append(Site)
                    }
                    
                case .Cultural:
                    if Site.Category == "Cultural"
                    {
                        FinalList.append(Site)
                    }
            }
        }
        Working.lockFocus()
        for Site in FinalList
        {
            var NodeColor = UIColor.black
            switch Site.Category
            {
                case "Mixed":
                    NodeColor = UIColor.systemPurple
                    
                case "Natural":
                    NodeColor = UIColor.systemGreen
                    
                case "Cultural":
                    NodeColor = UIColor.systemRed
                    
                default:
                    NodeColor = UIColor.white
            }
            let SitePoint = GeoPoint(Site.Latitude, Site.Longitude)
            let SitePointLocation = SitePoint.ToEquirectangular(Width: Int(Image.size.width),
                                                                Height: Int(Image.size.height))
            let SiteShape = UIBezierPath()
            let YOffset: Double = Constants.WHSYOffset.rawValue
            let LeftX: Double = Constants.WHSLeftX.rawValue
            let RightX: Double = Constants.WHSRightX.rawValue
            SiteShape.move(to: CGPoint(x: SitePointLocation.X, y: SitePointLocation.Y))
            SiteShape.addLine(to: CGPoint(x: Double(SitePointLocation.X) + LeftX, y: Double(SitePointLocation.Y) - YOffset))
            SiteShape.addLine(to: CGPoint(x: Double(SitePointLocation.X) + RightX, y: Double(SitePointLocation.Y) - YOffset))
            SiteShape.addLine(to: CGPoint(x: SitePointLocation.X, y: SitePointLocation.Y))
            UIColor.black.setStroke()
            NodeColor.setFill()
            SiteShape.stroke()
            SiteShape.fill()
        }
        Working.unlockFocus()
        return Working
#endif
    }
    
    /// Add earthquake magnitude values to the map if the proper settings are true.
    /// - Note: Magnitudes are plotted in lowest-to-highest order to make sure the earhtquakes with the
    ///         greatest magnitudes are shown most prominently.
    /// - Parameter To: The map to add earthquake magnitude values.
    /// - Parameter With: List of earthquakes to add. This function assumes that all earthquakes in this
    ///                   list should be plotted.
    /// - Parameter Ratio: Ratio between the standard-sized map and the current map.
    /// - Returns: The map with earthquake magnitude values or the same image, depending on settings.
    private static func AddMagnitudeValues(To Image: UIImage, With Earthquakes: [Earthquake],
                                           Ratio: Double) -> UIImage
    {
        if Earthquakes.count < 1
        {
            return Image
        }
        let QuakeSource = Earthquakes.sorted(by: {$0.Magnitude < $1.Magnitude})
        let ScaleFactor = UIScreen.main.scale
        var PlotMe = [TextRecord]()
        var Working = Image
        let QuakeFontRecord = Settings.GetString(.EarthquakeFontName, "Avenir")
        let QuakeFontName = Settings.ExtractFontName(From: QuakeFontRecord)!
        let BaseFontSize = 24.0
        var FontMultiplier: CGFloat = 1.0
        if Image.size.width / 2.0 < 3600.0
        {
            FontMultiplier = 2.0
        }
        let MapType = Settings.GetEnum(ForKey: .MapType, EnumType: MapTypes.self, Default: .Simple)
        if MapManager.CategoryFor(Map: MapType) == .Satellite
        {
            FontMultiplier = 1.0
        }
        let FontSize = CGFloat(BaseFontSize) * CGFloat(Ratio) * ScaleFactor * FontMultiplier
        for Quake in QuakeSource
        {
            let Location = Quake.LocationAsGeoPoint().ToEquirectangular(Width: Int(Image.size.width),
                                                                        Height: Int(Image.size.height))
            var LocationPoint = CGPoint(x: Location.X, y: Location.Y)
            let Greatest = Quake.GreatestMagnitude
            let EqText = "\(Greatest.RoundedTo(3))"
            var LatitudeFontOffset = (abs(Quake.Latitude) / 90.0)
            LatitudeFontOffset = Constants.StencilFontSize.rawValue * LatitudeFontOffset
            let Mag = Quake.IsCluster ? Quake.GreatestMagnitude : Quake.Magnitude
            let FinalFontSize = FontSize + CGFloat(Mag) + CGFloat(LatitudeFontOffset)
            let QuakeFont = UIFont(name: QuakeFontName, size: FinalFontSize)!
            let MagRange = Utility.GetMagnitudeRange(For: Greatest)
            var BaseColor = UIColor.systemYellow
            let Colors = Settings.GetMagnitudeColors()
            for (Magnitude, Color) in Colors
            {
                if Magnitude == MagRange
                {
                    BaseColor = Color
                }
            }
            
            var StrokeColor = UIColor.black
            let HowRecent = Settings.GetEnum(ForKey: .RecentEarthquakeDefinition, EnumType: EarthquakeRecents.self,
                                             Default: .Day1)
            if let RecentSeconds = RecentMap[HowRecent]
            {
                if Quake.GetAge() <= RecentSeconds
                {
                    StrokeColor = UIColor.red
                }
            }
            
            //Take care of text that is very close to the International Date Line/edge of
            //the image.
            let Length = Utility.StringWidth(TheString: EqText, TheFont: QuakeFont)
            if LocationPoint.x + Length > Image.size.width
            {
                LocationPoint = CGPoint(x: Image.size.width - Length,
                                        y: LocationPoint.y)
            }
            //let QRImage: UIImage? = Barcodes.QRCode(With: Quake.EventPageURL,
            //                                        FinalSize: CGSize(width: 100, height: 100))
            let Record = TextRecord(Text: EqText, Location: LocationPoint,
                                    Font: QuakeFont, Color: BaseColor, OutlineColor: StrokeColor,
                                    QRCode: nil, Quake: Quake)
            PlotMe.append(Record)
        }
        Working = DrawOn(Image: Working, Messages: PlotMe, ForQuakes: true)
        return Working
    }
    
    public static func DrawOn(Image: UIImage, Messages: [TextRecord], ForQuakes: Bool) -> UIImage
    {
        let Scale = UIScreen.main.scale
        
        UIGraphicsBeginImageContextWithOptions(Image.size, false, Scale)
        // Put the image into a rectangle as large as the original image
        Image.draw(in: CGRect(x: 0, y: 0, width: Image.size.width, height: Image.size.height))
        
        let UsePlainText = Settings.GetBool(.StencilPlainText)
        for Message in Messages
        {
            autoreleasepool
            {
                //var MessageWidth: CGFloat = 0.0
                //var MagLocation: CGPoint = CGPoint.zero
                if UsePlainText
                {
                    let WorkingText: NSString = NSString(string: Message.Text)
                    var Attrs = [NSAttributedString.Key: Any]()
                    Attrs[NSAttributedString.Key.font] = Message.Font as Any
                    Attrs[NSAttributedString.Key.foregroundColor] = Message.Color as Any
                    WorkingText.draw(at: CGPoint(x: Message.Location.x, y: Message.Location.y),
                                     withAttributes: Attrs)
                    //MagLocation = Message.Location
                    let TextSize = WorkingText.size(withAttributes: Attrs)
                    //MessageWidth = TextSize.width
                }
                else
                {
                    var Attrs = [NSAttributedString.Key: Any]()
                    Attrs[NSAttributedString.Key.font] = Message.Font as Any
                    Attrs[NSAttributedString.Key.foregroundColor] = Message.Color as Any
                    if let Outline = Message.OutlineColor
                    {
                        Attrs[NSAttributedString.Key.strokeColor] = Outline as Any
                        Attrs[NSAttributedString.Key.strokeWidth] = Constants.StencilTextStrokeWidth.rawValue as Any
                    }
                    let AttrString = NSAttributedString(string: Message.Text, attributes: Attrs)
                    let FinalLocation = CGPoint(x: Message.Location.x, y: Message.Location.y - (AttrString.size().height / 2.0))
                    //MagLocation = FinalLocation
                    AttrString.draw(at: FinalLocation)
                    //let TextSize = AttrString.size()
                    //MessageWidth = TextSize.width
                }
            }
        }
        defer{UIGraphicsEndImageContext()}
        if let FinalImage = UIGraphicsGetImageFromCurrentImageContext()
        {
            return FinalImage
        }
        else
        {
            return UIImage()
        }
    }
    
    /// Draw text strings on a surface.
    /// - Parameter Messages: List of strings to draw.
    /// - ImageSize: Size of the target surface to draw on
    /// - ForQuakes: Determines the context of the text.
    /// - Returns: Image with text drawn on it.
    private static func DrawText(Messages: [TextRecord],
                                 ImageSize: CGSize = CGSize(width: 3600, height: 1800),
                                 ForQuakes: Bool) -> UIImage
    {
        let Surface = MakeNewImage(Size: ImageSize)
        return DrawOn(Image: Surface, Messages: Messages, ForQuakes: ForQuakes)
    }
    
    /// Defines a line definition.
    typealias LineDefinition = (IsHorizontal: Bool, At: Int, Thickness: Int, Color: UIColor, Dashed: Bool)
    
    /// Add grid lines to the passed image.
    /// - Parameter To: The image to which to add gridlines.
    /// - Parameter Ratio: Ratio between the standard sized-map and the current map.
    /// - Return: New image with grid lines drawn.
    public static func AddGridLines(To Image: UIImage, Ratio: Double) -> UIImage
    {
        if Settings.GetBool(.GridLinesDrawnOnMap)
        {
            let ImageWidth = Int(Image.size.width)
            let ImageHeight = Int(Image.size.height)
            var LineList = [LineDefinition]()
            let LineColor = Settings.GetColor(.GridLineColor, UIColor.red)
            let MinorLineColor = Settings.GetColor(.MinorGridLineColor, UIColor.yellow)
            var LineThickness = 4
            let MapType = Settings.GetEnum(ForKey: .MapType, EnumType: MapTypes.self, Default: .Simple)
            if MapManager.CategoryFor(Map: MapType) == .Satellite
            {
                LineThickness = 1
            }
            
            if Settings.GetEnum(ForKey: .HourType, EnumType: HourTypes.self, Default: .None) == .WallClock
            {
                for Lon in stride(from: 0.0, to: 359.9, by: 15.0)
                {
                    var X = Int(Double(ImageWidth) * ((Lon + 7.5) / 360.0))
                    if X + 4 > ImageWidth
                    {
                        X = X - 4
                    }
                    let Line: LineDefinition = (IsHorizontal: false,
                                                At: X,
                                                Thickness: LineThickness / 2,
                                                Color: UIColor.systemTeal,
                                                Dashed: true)
                    LineList.append(Line)
                }
            }
            
            for Longitude in Latitudes.allCases
            {
                var Y = Int(Double(ImageHeight) * Longitude.rawValue)
                if Y + 4 > ImageHeight
                {
                    Y = Y - 4
                }
                let Line: LineDefinition = (IsHorizontal: true,
                                            At: Y,
                                            Thickness: LineThickness,
                                            Color: LineColor,
                                            Dashed: false)
                LineList.append(Line)
            }
            
            for Latitude in Longitudes.allCases
            {
                var X = Int(Double(ImageWidth) * Latitude.rawValue)
                if X + 4 > ImageWidth
                {
                    X = X - 4
                }
                let Line: LineDefinition = (IsHorizontal: false,
                                            At: X,
                                            Thickness: LineThickness,
                                            Color: LineColor,
                                            Dashed: false)
                LineList.append(Line)
            }
            
            
            var Final = Image
            let DashPattern: [CGFloat] =
            [
                CGFloat(8.0),
                CGFloat(8.0)
            ]
            
            //The code in the loop must be enclosed in an autoreleasepool to
            //stop memory outages.
            for SomeLine in LineList
            {
                autoreleasepool
                {
                    UIGraphicsBeginImageContext(Final.size)
                    Final.draw(at: .zero)
                    let _ = UIGraphicsGetCurrentContext()
                    
                    var X1 = 0
                    var Y1 = 0
                    var X2 = 0
                    var Y2 = 0
                    let Line = UIBezierPath()
                    SomeLine.Color.setFill()
                    SomeLine.Color.setStroke()
                    if SomeLine.Dashed
                    {
                        Line.lineCapStyle = .round
                        Line.setLineDash(DashPattern, count: DashPattern.count, phase: 0.0)
                    }
                    if SomeLine.IsHorizontal
                    {
                        X1 = -SomeLine.Thickness
                        Y1 = SomeLine.At
                        X2 = X1 + Int(Image.size.width)
                        Y2 = SomeLine.At
                    }
                    else
                    {
                        X1 = SomeLine.At
                        Y1 = 0
                        X2 = SomeLine.At
                        Y2 = Int(Image.size.height)
                    }
                    Line.lineWidth = CGFloat(SomeLine.Thickness)
                    Line.move(to: CGPoint(x: X1, y: Y1))
                    Line.addLine(to: CGPoint(x: X2, y: Y2))
                    Line.stroke()
                    Line.fill()
                    
                    Final = UIGraphicsGetImageFromCurrentImageContext()!
                    UIGraphicsEndImageContext()
                }
            }
            
            return Final
        }
        else
        {
            return Image
        }
    }
    
    /// Draw lines on the passed image.
    /// - Parameter Image: The image upon which lines will be drawn.
    /// - Parameter Lines: The set of lines to draw.
    /// - Parameter Kernel: The Metal kernel to use to draw lines.
    /// - Returns: New image with lines drawn on it.
    private static func DrawLine(Image: UIImage, Lines: [LineDefinition], Kernel: LinesDraw) -> UIImage
    {
        var Final = Image
        var LinesToDraw = [LineDrawParameters]()
        for Line in Lines
        {
            let LineToDraw = LineDrawParameters(IsHorizontal: simd_bool(Line.IsHorizontal),
                                                HorizontalAt: simd_uint1(Line.At),
                                                VerticalAt: simd_uint1(Line.At),
                                                Thickness: simd_uint1(Line.Thickness),
                                                LineColor: MetalLibrary.ToFloat4(Line.Color))
            LinesToDraw.append(LineToDraw)
        }
        Final = Kernel.DrawLines(Background: Image, Lines: LinesToDraw)
        return Final
    }
    
    
    //Synchronization locks.
    static var DrawRectangleLock = NSObject()
    static var DrawCircularLock = NSObject()
    static var DrawLinesLock = NSObject()
    static var DrawTextLock = NSObject()
    
    /// Draw earthquake magnitudes to the map.
    /// - Parameter Earthquakes: Array of earthquakes whose magnitudes will be drawn.
    /// - Parameter Size: Size of the target surface. Defaults to 3600 x 1800.
    /// - Returns: Image with earthquake magnitudes drawn on it. Nil if no earthquakes supplied.
    public static func ApplyMagnitudes(Earthquakes: [Earthquake],
                                       Size: CGSize = CGSize(width: 3600, height: 1800)) -> UIImage?
    {
        if Earthquakes.count < 1
        {
            return nil
        }
        let Ratio = Size.width / 3600.0
        let ScaleFactor = UIScreen.main.scale
        var PlotMe = [TextRecord]()
        let QuakeFontRecord = Settings.GetString(.EarthquakeFontName, "Avenir")
        let QuakeFontName = Settings.ExtractFontName(From: QuakeFontRecord)!
        let BaseFontSize = Settings.ExtractFontSize(From: QuakeFontRecord)!
        var FontMultiplier: CGFloat = 1.0
        if Size.width / 2.0 < 3600.0
        {
            FontMultiplier = 2.0
        }
        FontMultiplier = 1.0
        let QuakeSize = Settings.GetEnum(ForKey: .QuakeScales, EnumType: MapNodeScales.self, Default: .Normal)
        var UserScale: CGFloat = 1.0
        switch QuakeSize
        {
            case .Small:
                UserScale = 0.5
                
            case .Normal:
                UserScale = 1.0
                
            case .Large:
                UserScale = 1.3
        }
        let FontSize = BaseFontSize * CGFloat(Ratio) * ScaleFactor * FontMultiplier * UserScale
        for Quake in Earthquakes
        {
            let Location = Quake.LocationAsGeoPoint().ToEquirectangular(Width: Int(Size.width),
                                                                        Height: Int(Size.height))
            var LocationPoint = CGPoint(x: Location.X, y: Location.Y)
            let Greatest = Quake.GreatestMagnitude
            let EqText = "\(Greatest.RoundedTo(3))"
            var LatitudeFontOffset = abs(Quake.Latitude) / 90.0
            LatitudeFontOffset = Constants.StencilFontSize.rawValue * LatitudeFontOffset
            let Mag = Quake.IsCluster ? Quake.GreatestMagnitude : Quake.Magnitude
            let FinalFontSize = FontSize + CGFloat(Mag) + CGFloat(LatitudeFontOffset)
            let QuakeFont = UIFont(name: QuakeFontName, size: FinalFontSize)!
            let MagRange = Utility.GetMagnitudeRange(For: Greatest)// Quake.GreatestMagnitude)
            var BaseColor = UIColor.systemYellow
            let Colors = Settings.GetMagnitudeColors()
            for (Magnitude, Color) in Colors
            {
                if Magnitude == MagRange
                {
                    BaseColor = Color
                }
            }
            //Take care of text that is very close to the International Date Line/edge of
            //the image.
            let Length = Utility.StringWidth(TheString: EqText, TheFont: QuakeFont)
            if LocationPoint.x + Length > Size.width
            {
                LocationPoint = CGPoint(x: Size.width - Length,
                                        y: LocationPoint.y)
            }
            
            var StrokeColor = UIColor.black
            let HowRecent = Settings.GetEnum(ForKey: .RecentEarthquakeDefinition, EnumType: EarthquakeRecents.self,
                                             Default: .Day1)
            if let RecentSeconds = RecentMap[HowRecent]
            {
                if Quake.GetAge() <= RecentSeconds
                {
                    StrokeColor = UIColor.red
                }
            }
            
#if true
            let QRImage: UIImage? = nil
#else
            let QRImage: UIImage? = Barcodes.QRCode(With: Quake.EventPageURL,
                                                    FinalSize: CGSize(width: 100, height: 100),
                                                    Digit: Quake.Magnitude)
#endif
            let Record = TextRecord(Text: EqText, Location: LocationPoint,
                                    Font: QuakeFont, Color: BaseColor, OutlineColor: StrokeColor,
                                    QRCode: QRImage, Quake: Quake)
            PlotMe.append(Record)
        }
        let Final = DrawText(Messages: PlotMe, ImageSize: Size, ForQuakes: true)
        return Final
    }
    
    private static let RecentMap: [EarthquakeRecents: Double] =
    [
        .Day05: 12.0 * 60.0 * 60.0,
        .Day1: 24.0 * 60.0 * 60.0,
        .Day2: 2.0 * 24.0 * 60.0 * 60.0,
        .Day3: 3.0 * 24.0 * 60.0 * 60.0,
        .Day7: 7.0 * 24.0 * 60.0 * 60.0,
        .Day10: 10.0 * 24.0 * 60.0 * 60.0,
    ]
    
    /// Draw circles on the map.
    /// - Note: Since the map is rectangular, circles will appear distorted if the map is applied to a globe.
    /// - Parameter Size: Size of the map on which to draw circles. Defaults to 3600 x 1800.
    /// - Parameter Circles: Array of circles to draw.
    /// - Returns: Image with circles drawn on it.
    public static func ApplyCircles(Size: CGSize = CGSize(width: 3600, height: 1800),
                                    Circles: [CircleRecord]) -> UIImage
    {
        objc_sync_enter(DrawCircularLock)
        defer{objc_sync_exit(DrawCircularLock)}
        var Image = MakeNewImage(Size: Size)
        let MetalShape = Metal2DShapeGenerator()
        var DrawnCircles = [(CircleRecord, UIImage)]()
        for Circle in Circles
        {
            autoreleasepool
            {
                let CircleSize = CGSize(width: Circle.Radius * 2, height: Circle.Radius * 2)
                var BorderWidth = 0
                if let Border = Circle.OutlineWidth
                {
                    BorderWidth = Int(Border)
                }
                let CircleImage = MetalShape.DrawCircle(BaseSize: CircleSize,
                                                        Radius: Int(Circle.Radius) - BorderWidth - 1,
                                                        Interior: Circle.Color,
                                                        Background: UIColor.clear,
                                                        BorderColor: UIColor.black,
                                                        BorderWidth: BorderWidth)
                DrawnCircles.append((Circle, CircleImage!))
            }
        }
        let B = ImageBlender()
        Image = B.MergeImages(Background: Image, Sprite: DrawnCircles[0].1,
                              SpriteX: Int(DrawnCircles[0].0.Location.x),
                              SpriteY: Int(DrawnCircles[0].0.Location.y))!
        return Image
    }
    
    /// Apply rectangular decals for earthquake regions onto a transparent image.
    /// - Parameter Size: The size of the image. Defaults to 3600x1800. The size should always have the ratio
    ///                   2:1 for width to hight.
    /// - Parameter Regions: List of earthquake regions to plot.
    /// - Returns: Image of the earthquake regions.
    public static func ApplyRectangles(Size: CGSize = CGSize(width: 3600, height: 1800),
                                       Regions: [UserRegion]) -> UIImage
    {
        objc_sync_enter(DrawRectangleLock)
        defer{objc_sync_exit(DrawRectangleLock)}
        let Blender = ImageBlender()
        let MapRatio: Double = Double(Size.width) / 3600.0
        var Surface = MakeNewImage(Size: Size)
        
        for Region in Regions
        {
            if Region.IsFallback
            {
                continue
            }
            var RegionWidth = GeoPoint.HorizontalDistance(Longitude1: Region.UpperLeft.Longitude,
                                                          Longitude2: Region.LowerRight.Longitude,
                                                          Latitude: Region.UpperLeft.Latitude,
                                                          Width: Int(Size.width), Height: Int(Size.height))
            RegionWidth = RegionWidth * MapRatio
            var RegionHeight = GeoPoint.VerticalDistance(Latitude1: Region.UpperLeft.Latitude,
                                                         Latitude2: Region.LowerRight.Latitude,
                                                         Longitude: Region.UpperLeft.Longitude,
                                                         Width: Int(Size.width), Height: Int(Size.height))
            RegionHeight = RegionHeight * MapRatio
            var XPercent: Double = 0.0
            var YPercent: Double = 0.0
            var (FinalX, FinalY) = GeoPoint.TransformToImageCoordinates(Latitude: Region.UpperLeft.Latitude,
                                                                        Longitude: Region.UpperLeft.Longitude,
                                                                        Width: Int(Size.width),
                                                                        Height: Int(Size.height),
                                                                        XPercent: &XPercent,
                                                                        YPercent: &YPercent)
            FinalX = Int(Double(FinalX) * MapRatio)
            FinalY = Int(Double(FinalY) * MapRatio)
            Surface = Blender.MergeImages(Background: Surface, Sprite: Region.RegionColor.withAlphaComponent(0.5),
                                          SpriteSize: CGSize(width: RegionWidth, height: RegionHeight),
                                          SpriteX: FinalX, SpriteY: FinalY)
        }
        
        return Surface
    }
    
    /// Creates and returns a transparent image of the given size.
    /// - Parameter Size: The size of the image to return.
    /// - Returns: Transparent image of the given size.
    private static func MakeNewImage(Size: CGSize) -> UIImage
    {
        let SolidColor = SolidColorImage()
        let Transparent = SolidColor.Fill(Width: Int(Size.width), Height: Int(Size.height), With: UIColor.clear)!
        return Transparent
    }
}

/// Defines a rectangle to draw.
struct RectangleRecord
{
    /// Upper left point of the rectangle.
    let UpperLeft: CGPoint
    /// Lower right point of the rectangle.
    let LowerRight: CGPoint
    /// Fill color of the rectangle.
    let FillColor: UIColor
    /// If present, the border color of the rectangle. If not present, no border is drawn.
    let BorderColor: UIColor?
    /// If present, the border width of the rectangle. If not present, no border is drawn.
    let BorderWidth: CGFloat?
}

/// Used to define a line to draw.
struct LineRecord
{
    /// Starting point.
    let Start: CGPoint
    /// Ending point.
    let End: CGPoint
    /// Width of the line.
    let Width: CGFloat
    /// Color of the line.
    let Color: UIColor
    /// If present, the outline color of the line. If not present, no outline drawn.
    let OutlineColor: UIColor?
}

/// Used to send information to the text plotter for drawing text on images.
struct TextRecord
{
    /// The text to draw.
    let Text: String
    /// The location of the text to draw.
    let Location: CGPoint
    /// The font to use to draw the text.
    let Font: UIFont
    /// The color of the text.
    let Color: UIColor
    /// If present, the outline color of the text. If not present, no outline is drawn.
    let OutlineColor: UIColor?
    /// If present, an image of a QR code to display.
    let QRCode: UIImage?
    /// If present, an earthquake associated with the text.
    let Quake: Earthquake?
}

/// Used to define a circle.
struct CircleRecord
{
    /// Location of the center of the circle.
    let Location: CGPoint
    /// Radius of the circle.
    let Radius: CGFloat
    /// Fill color of the circle.
    let Color: UIColor
    /// Color of the outline. If nil, no outline is drawn.
    let OutlineColor: UIColor?
    /// Width of the outline. If nil, no outline is drawn.
    let OutlineWidth: CGFloat?
}
