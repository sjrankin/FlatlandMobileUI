//
//  MapManager.swift
//  MapManager
//
//  Created by Stuart Rankin on 7/19/21. Adapted from Flatland View.
//

import Foundation
import UIKit
import SceneKit

/// High-level map image manager for the maps displayed by Flatland.
class MapManager
{
    /// Returns an image for the specified map type and view type.
    /// - Note: Map images are cached upon use.
    /// - Note: `.Rectangular` view type maps return the same image as `.Globe3D` view type maps. It is up
    ///         to the caller to use them differently.
    /// - Parameter MapType: The type (style) of map image to return. See `MapTypes` for available map types.
    /// - Parameter ViewType: The general view type (flat or global) of the program.
    /// - Parameter ImageCenter: For `.FlatMap` `ViewType`s only. Determines which pole is in the
    ///                          center of the map.
    /// - Returns: Map image for the specified map type. Nil if not found.
    public static func ImageFor(MapType: MapTypes, ViewType: ViewTypes, ImageCenter: ImageCenters = .NorthPole) -> UIImage?
    {
        let MapCategory = CategoryFor(Map: MapType)!
        if let SomeMap = MapList.Map(For: MapType)
        {
            switch ViewType
            {
                case .FlatNorthCenter:
                    return SomeMap.GetMapImage(For: .North)
                    
                case .FlatSouthCenter:
                    return SomeMap.GetMapImage(For: .South)
                    
                case .Globe3D:
                    if MapCategory == .Satellite
                    {
                        
                    }
                    else
                    {
                        return SomeMap.GetMapImage(For: .Global)
                    }
                    
                case .Rectangular:
                    return SomeMap.GetMapImage(For: .Global)
                    
                default:
                    return nil
            }
        }
        return nil
    }
    
    /// Returns the light intensity multiplier for the specified map type.
    /// - Parameter MapType: The map type whose light intensity multiplier is returned. If `MapType`
    ///                      is not found, `1.0` is returned.
    /// - Returns: The map's light intensity multiplier value.
    public static func GetLightMulitplier(MapType: MapTypes) -> Double
    {
        if let Map = MapList.Map(For: MapType)
        {
            return Map.LightMultiplier2D
        }
        return 1.0
    }
    
    /// Returns an image of the side of a cubic world.
    /// - Parameter CubicImage: Determines which side to return.
    /// - Returns: Image for the specified side. Nil if not found.
    public static func CubicImageSide(_ CubicImage: CubicMapTypes) -> UIImage?
    {
        return UIImage(named: CubicImage.rawValue)
    }
    
    /// Returns a material for the side of a cubic world.
    /// - Parameter CubicImage: Determines which side to return.
    /// - Parameter Rotated: Value (in degrees) to rotate the image before returning it as a material.
    ///                      Defaults to 0.0° (no rotation).
    /// - Returns: `SCNMaterial` with the diffuse contents populated with the specified image on
    ///            success, nil on error.
    public static func CubicImageMaterial(_ CubicImage: CubicMapTypes, Rotated: CGFloat = 0.0) -> SCNMaterial?
    {
        if let Image = CubicImageSide(CubicImage)
        {
            var FinalImage = Image
            if Rotated != 0.0
            {
                FinalImage = Image.Rotate(Degrees: Rotated)
            }
            let Material = SCNMaterial()
            Material.diffuse.contents = FinalImage
            return Material
        }
        else
        {
            return nil
        }
    }
    
    /// Returns a list of map category names
    /// - Returns: List of map category names.
    public static func GetMapCategoryNames() -> [String]
    {
        var Results = [String]()
        for Category in MapCategories.allCases
        {
            Results.append(Category.rawValue)
        }
        return Results
    }
    
    /// Returns a list of map categories.
    /// - Returns: List of map categories.
    public static func GetMapCategories() -> [MapCategories]
    {
        var Results = [MapCategories]()
        for Category in MapCategories.allCases
        {
            Results.append(Category)
        }
        return Results
    }
    
    /// Convenience function to determine if the passed map type is a satellite map.
    /// - Returns:
    public static func IsSatelliteMap(_ MapType: MapTypes) -> Bool
    {
        return GetMapsInCategory(.Satellite).contains(MapType)
    }
    
    /// Returns the set of maps associated with the passed map category.
    /// - Parameter Category: The category whose list of maps is returned.
    /// - Returns: List of maps for the passed category.
    public static func GetMapsInCategory(_ Category: MapCategories) -> [MapTypes]
    {
        switch Category
        {
            case .Standard:
                return [.Standard, .Simple, .SimpleBorders1, .SimpleBorders2, .Continents,
                        .StandardSea]
                
            case .Physical:
                return [.BlueMarble, .MODIS, .DarkBlueMarble, .USGS,
                        .Topographical1, .Topographical2, .SurrealTopographic, .EarthquakeMap,
                        .OnlyTectonic, .TectonicOverlay, .StaticAerosol, .Normalized]
                
            case .Satellite:
                return [.GIBS_MODIS_Terra_CorrectedReflectance_TrueColor,
                        .GIBS_MODIS_Terra_CorrectedReflectance_721,
                        .GIBS_MODIS_Terra_CorrectedReflectance_367,
                        .GIBS_MODIS_Aqua_CorrectedReflectance_TrueColor,
                        .GIBS_MODIS_Aqua_CorrectedReflectance_721,
                        .GIBS_SNPP_VIIRS_CorrectedReflectance_TrueColor,
                        .GIBS_SNPP_VIIRS_CorrectedReflectance_M11I2I1,
                        .GIBS_SNPP_VIIRS_CorrectedReflectance_M3I3M11,
                        .GIBS_SNPP_VIIRS_DayNightBand_At_Sensor_Radiance,
                        .GIBS_SNPP_Brightness_Temp_BandI5_Day,
                        .GIBS_SNPP_Brightness_Temp_BandI5_Night,
                        .GIBS_NOAA20_VIIRS_CorrectedReflectance_TrueColor,
                        .GIBS_NOAA20_VIIRS_CorrectedReflectance_M3I3I11]
                
            case .TimeZone:
                return [.TimeZoneMap1, .ColorfulTimeZones, .TimeZone4, .HatchedTimeZones, .PaperTimeZones,
                        .SurrealTimeZone, .TimeZoneOverlay]
                
            case .Political:
                return [.SimplePoliticalMap1, .SimplePoliticalMap1Big, .TransparentOcean, .CitiesAtNight]
                
            case .Astronomical:
                return [.MarsViking, .MarsMariner9, .MOLAVerticalRoughness, .LROMap, .LunarGeoMap,
                        .Jupiter, .GaiaSky, .TychoSky, .TychoConstellations, .NASAStarsInverted]
                
            case .Artistic:
                return [.OilPainting1, .WaterColor1, .WaterColor2, .Cartoon, .SwirlyLines, .RoundSplotches,
                        .ColorInk, .Warhol, .Ukiyoe1, .ASCIIArt1]
                
            case .Colorful:
                return [.Pink, .Bronze, .Blueprint, .BlackWhite, .BlackWhiteShiny, .WhiteBlack,
                        .SpotColor, .LevelWorld]
                
            case .Abstract:
                return [.Dots, .Crosshatched, .Textured, .PaperWorld, .SquareWorld, .Abstract1,
                        .Abstract2, .Abstract3, .Surreal1, .Skeleton, .GlowingCoasts, .Voronoi,
                        .Polygons, .Extruded, .BubbleWorld, .StainedGlass]
                
            case .Dithered:
                return [.HalftoneLine, .HalftoneVerticalLine, .HalftoneDot, .Dithered]
                
            case .Silly:
                return [.House, .Tigger]
                
            case .Stylized:
                return [.StylizedSea1]
                
#if DEBUG
            case .Debug:
                return [.Debug1, .Debug3, .Debug2, .Debug4, .Debug5, .Debug6, .Debug7]
#endif
        }
    }
    
    /// Returns the map category for the specified map type.
    /// - Parameter Map: The map type for which the related map category is returned.
    /// - Returns: The map category for the passed map type. Nil if not found.
    public static func CategoryFor(Map: MapTypes) -> MapCategories?
    {
        for MapCategory in MapCategories.allCases
        {
            if GetMapsInCategory(MapCategory).contains(Map)
            {
                return MapCategory
            }
        }
        return nil
    }
    
#if false
    /// Save the passed image in the local pictures directory.
    /// - Note: This image will be used while new images are downloaded from NASA.
    /// - Parameter Name: The name of the image.
    /// - Parameter Image: The image to save in the pictures directory.
    public static func SaveMapInCache(Name: String, _ Image: UIImage)
    {
        let DocDirURL = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first!
        let ScratchURL = DocDirURL.appendingPathComponent(FileIO.PictureDirectory)
        let ImageDate = Date.PrettyDateTime(From: Date(), IncludeSeconds: false, ForFileName: true)
        let FinalURL = ScratchURL.appendingPathComponent("\(Name)-\(ImageDate).png")
        Image.WritePNG(ToURL: FinalURL)
    }
    
    /// Delete the file contents of the pictures directory. All files will be unconditionally deleted.
    public static func ClearCachedMaps()
    {
        let AllFiles = GetFilesInDirectory(FileIO.PictureDirectory)
        if AllFiles.isEmpty
        {
            return
        }
        do
        {
            for File in AllFiles
            {
                if FileManager.default.fileExists(atPath: File.path)
                {
                    try FileManager.default.removeItem(atPath: File.path)
                }
            }
        }
        catch
        {
            Debug.Print("Error deleting files: \(error.localizedDescription)")
        }
    }
    
    /// Returns a list of all files in a given directory.
    /// - Parameter DirectoryName: Name of the directory. Must be a directory in the document directory of
    ///                            the running application.
    /// - Returns: List of all files found in the passed directory.
    public static func GetFilesInDirectory(_ DirectoryName: String) -> [URL]
    {
        let DocDirURL = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first!
        let ScratchURL = DocDirURL.appendingPathComponent(DirectoryName)
        var FileList = [URL]()
        do
        {
            let DirectoryItems = try FileManager.default.contentsOfDirectory(at: ScratchURL,
                                                                             includingPropertiesForKeys: nil,
                                                                             options: .skipsHiddenFiles)
            for Item in DirectoryItems
            {
                FileList.append(Item)
            }
        }
        catch
        {
            Debug.Print("Error getting contents of \(ScratchURL.path): \(error.localizedDescription)")
        }
        return FileList
    }
    
    /// Returns the most recent cached image from the pictures directory.
    /// - Note: This function assumes all images stored in the picture sub-directory are generated by Flatland
    ///         and are of the proper format.
    /// - Returns: Image to be used as a map for the globe on success, nil if none found.
    public static func MostRecentCachedMap() -> UIImage?
    {
        let DocDirURL = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first!
        let ScratchURL = DocDirURL.appendingPathComponent(FileIO.PictureDirectory)
        var FileList = [(CreationDate: Date, FileLocation: URL)]()
        do
        {
            let DirectoryItems = try FileManager.default.contentsOfDirectory(at: ScratchURL,
                                                                             includingPropertiesForKeys: [.creationDateKey, .nameKey],
                                                                             options: .skipsHiddenFiles)
            for Item in DirectoryItems
            {
                do
                {
                    let Values = try Item.resourceValues(forKeys: [.creationDateKey])
                    if let CreateDate = Values.creationDate
                    {
                        FileList.append((CreateDate, Item))
                    }
                }
                catch
                {
                    Debug.Print("Error getting resource values: \(error.localizedDescription)")
                }
            }
        }
        catch
        {
            Debug.Print("Error getting contents of \(ScratchURL.path): \(error.localizedDescription)")
        }
        if FileList.isEmpty
        {
            return nil
        }
        FileList.sort(by: {$0.CreationDate > $1.CreationDate})
        let Image = UIImage(contentsOf: FileList[0].FileLocation)
        return Image
    }
#endif
}

/// Map categories.
enum MapCategories: String, CaseIterable
{
    /// Standard maps.
    case Standard = "Standard"
    /// Physically-based maps.
    case Physical = "Physical"
    /// Maps made of satellite images.
    case Satellite = "Satellite"
    /// Maps with time zones marked on them.
    case TimeZone = "Time Zone"
    /// Political maps (other than what are in `.Standard` maps).
    case Political = "Political"
    /// Extraterrestrial maps.
    case Astronomical = "Astronomical"
    /// Artistic maps.
    case Artistic = "Artistic"
    /// Colorful (or black and white) maps.
    case Colorful = "Colorful"
    /// Abstract (but marginally useful) maps.
    case Abstract = "Abstract"
    /// Dithered maps.
    case Dithered = "Dithered"
    /// Silly maps.
    case Silly = "Silly"
    /// Stylized maps.
    case Stylized = "Stylized"
#if DEBUG
    /// Debug maps.
    case Debug = "Debug"
#endif
}

/// Determines whether the north pole or the south pole is at the center of the world image.
enum ImageCenters: String, CaseIterable
{
    /// North pole is in the center.
    case NorthPole = "NorthPole"
    /// South pole is in the center.
    case SouthPole = "SouthPole"
}

/// Specifies the sides of a cubic map.
enum CubicMapTypes: String, CaseIterable
{
    case nx = "nx"
    case ny = "ny"
    case nz = "nz"
    case px = "px"
    case py = "py"
    case pz = "pz"
    case ny270 = "ny270"
    case ny90 = "ny90"
    case py90 = "py90"
    case pym90 = "py-90"
}
