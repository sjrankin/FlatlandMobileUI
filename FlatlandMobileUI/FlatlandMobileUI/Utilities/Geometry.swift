//
//  Geometry.swift
//  Geometry
//
//  Created by Stuart Rankin on 7/18/21.
//

import Foundation
import UIKit
import SceneKit

class Geometry
{
    // MARK: - Geometry-related functions.
    
    /// Convert the passed latitude and longitude values into a 3D coordinate that can be plotted
    /// on a sphere.
    /// - Note: See [How to map latitude and logitude to a 3D sphere](https://stackoverflow.com/questions/36369734/how-to-map-latitude-and-longitude-to-a-3d-sphere)
    /// - Parameter Latitude: The latitude portion of the 2D coordinate.
    /// - Parameter Longitude: The longitude portion of the 2D coordinate.
    /// - Parameter LatitudeOffset: Offset added to the latitude. Defaults to `0.0`.
    /// - Parameter LongitudeOffset: Offset added to the longitude. Defaults to `0.0`.
    /// - Parameter Radius: The radius of the sphere.
    /// - Parameter RadiusOffset: Offset added to the radius. Defaults to `0.0`.
    /// - Returns: Tuple with the X, Y, and Z coordinates for the location on the sphere.
    public static func ToECEF(_ Latitude: Double, _ Longitude: Double,
                              LatitudeOffset: Double = 0.0, LongitudeOffset: Double = 0.0,
                              Radius: Double, RadiusOffset: Double = 0.0) -> (Double, Double, Double)
    {
        let Lat = (90 - (Latitude + LatitudeOffset)).Radians
        let Lon = (90 + (Longitude + LongitudeOffset)).Radians
        let X = -((Radius + RadiusOffset) * sin(Lat) * cos(Lon))
        let Z = ((Radius + RadiusOffset) * sin(Lat) * sin(Lon))
        let Y = ((Radius + RadiusOffset) * cos(Lat))
        return (X, Y, Z)
    }
    
    /// Converts the passed point on a sphere (assumed to be the 3D globe) into a latitude and longitude
    /// coordinate.
    /// - Warning: If the number of values in `SomePoint` is not 3, a fatal error is thrown.
    /// - Note: The caller should probably use alterative functions to this one.
    /// - Note: Algorithm from Geodetic Coordinate Conversions by James R. Clynch, Naval Postgraduate School, 2002
    /// - Note: This function assumes the order of coordinate values in `SomePoint` is in X, Y, Z order.
    /// - Parameter SomePoint: Native X, Y, Z mouse coordinates. **Must be in X, Y, Z order.** It is assumed that
    ///                        these values are the ones returned by SceneKit when the mouse moves over the
    ///                        3D globe node.
    /// - Returns: Tuple with the converted latitude and longitude values.
    public static func FromECEF(_ SomePoint: [Double]) -> (Latitude: Double, Longitude: Double)
    {
        if SomePoint.count != 3
        {
            Debug.FatalError("Incorrect number (\(SomePoint.count)) of values in SomePoint. Must be 3.")
        }
        var Point = SomePoint
        //Swap the Y and Z points to conform to the algorithm from the SceneKit coordinate system.
        Point.swapAt(1, 2)
        var Longitude = atan2(Point[1], -Point[0]).Degrees
        Longitude = Longitude - 90.0
        if Longitude < -180.0
        {
            let Delta = Longitude + 180.0
            Longitude = 180.0 + Delta
        }
        let P = sqrt(Point[0].Squared + Point[1].Squared)
        let Latitude = atan2(P, Point[1]).Degrees
        return (Latitude, Longitude)
    }
    
    /// Converts the passed point on a sphere (assumed to be the 3D globe) into a latitude and longitude
    /// coordinate.
    /// - Note: Algorithm from Geodetic Coordinate Conversions by James R. Clynch, Naval Postgraduate School, 2002
    /// - Parameter Point: Native X, Y, Z mouse coordinates.
    /// - Returns: Tuple with the converted latitude and longitude values.
    public static func FromECEF(_ Point: SCNVector3) -> (Latitude: Double, Longitude: Double)
    {
        return FromECEF([Double(Point.x), Double(Point.y), Double(Point.z)])
    }
    
    /// Converts the passed point on a sphere (assumed to be the 3D globe) into a latitude and longitude
    /// coordinate.
    /// - Note: Algorithm from Geodetic Coordinate Conversions by James R. Clynch, Naval Postgraduate School, 2002
    /// - Parameter X: X mouse coordinate.
    /// - Parameter Y: Y mouse coordinate.
    /// - Parameter Z: Z mouse coordinate.
    /// - Returns: Tuple with the converted latitude and longitude values.
    public static func FromECEF(_ X: Double, _ Y: Double, _ Z: Double) -> (Latitude: Double, Longitude: Double)
    {
        return FromECEF([X, Y, Z])
    }
    
    /// Given a latitude and longitude, return the equivalent 2D point on a surface with the passed size.
    /// - Parameter Latitude: The latitude.
    /// - Parameter Longitude: The longitude.
    /// - Parameter Width: The width of the surface.
    /// - Parameter Height: The height of the surface.
    /// - Parameter OriginInCenter: If true, the point is adjusted such that the origin of the surface is
    ///                             in the center.
    /// - Returns: Tuple with the (X, Y) value of the point of the latitude, longitude mapped to the surface.
    public static func PointFromGeo(Latitude: Double, Longitude: Double, Width: Double, Height: Double,
                                    OriginInCenter: Bool = true) -> (X: Double, Y: Double)
    {
        let AdjustedLat = 90.0 + Latitude
        let AdjustedLon = 180.0 + Longitude
        let LatPercent = AdjustedLat / 180.0
        let LonPercent = AdjustedLon / 360.0
        var Horizontal = Width * LonPercent
        var Vertical = Height * LatPercent
        if OriginInCenter
        {
            Horizontal = (Width / 2.0) - Horizontal
            Vertical = (Height / 2.0) - Vertical
        }
        //On Mac OSes, the coordinates are reversed so we have to return the value multiplied by -1 for each.
        return (X: -Horizontal, Y: -Vertical)
    }
    
    /// Calculate the bearing between two geographic points on the Earth using the forward azimuth formula (great circle).
    /// - Parameters:
    ///   - Start: Starting point.
    ///   - End: Destination point.
    /// - Returns: Bearing from the Start point to the End point. (Bearing will change over the arc.)
    public static func Bearing(Start: GeoPoint, End: GeoPoint) -> Double
    {
        let StartLat = Start.Latitude.ToRadians()
        let StartLon = Start.Longitude.ToRadians()
        let EndLat = End.Latitude.ToRadians()
        let EndLon = End.Longitude.ToRadians()
        
        if cos(EndLat) * sin(EndLon - StartLon) == 0
        {
            if EndLat > StartLat
            {
                return 0
            }
            else
            {
                return 180
            }
        }
        var Angle = atan2(cos(EndLat) * sin(EndLon - StartLon),
                          sin(EndLat) * cos(StartLat) - sin(StartLat) * cos(EndLat) * cos(EndLon - StartLon))
        Angle = Angle.ToDegrees()
        Angle = Angle * 1000.0
        let IAngle = Int(Angle)
        Angle = Double(IAngle) / 1000.0
        return Angle
    }
    
    /// Calculate the bearing between two geographic points on the Earth using the forward azimuth formula (great circle).
    /// - Parameters:
    ///   - Start: Starting point.
    ///   - End: Destination point.
    /// - Returns: Bearing from the Start point to the End point. (Bearing will change over the arc.)
    public static func Bearing2I(Start: GeoPoint, End: GeoPoint) -> Int
    {
        let StartLat = Start.Latitude.Radians //ToRadians(Start.Latitude)
        let StartLon = Start.Longitude.Radians //ToRadians(Start.Longitude)
        let EndLat = End.Latitude.Radians //ToRadians(End.Latitude)
        let EndLon = End.Longitude.Radians //ToRadians(End.Longitude)
        
        if cos(EndLat) * sin(EndLon - StartLon) == 0
        {
            if EndLat > StartLat
            {
                return 0
            }
            else
            {
                return 180
            }
        }
        var Angle = atan2(cos(EndLat) * sin(EndLon - StartLon),
                          sin(EndLat) * cos(StartLat) - sin(StartLat) * cos(EndLat) * cos(EndLon - StartLon))
        Angle = Angle.Degrees //ToDegrees(Angle)
        var IAngle = Int(Angle)
        IAngle = IAngle + 360
        IAngle = IAngle % 360
        return IAngle
    }
    
    /// Mean radius of the Earth in meters.
    public static let EarthRadius: Double = 6367444.7
    
    /// Calculates the haversine distance (two points on the surface of a sphere).
    /// - Note: [Swift Algorithm Club - HaversineDistance](https://github.com/raywenderlich/swift-algorithm-club/blob/master/HaversineDistance/HaversineDistance.playground/Contents.swift)
    /// - Parameter Point1: First point.
    /// - Parameter Point2: Second point.
    /// - Returns: Distance between the two points, in meters.
    public static func HaversineDistance(Point1: GeoPoint, Point2: GeoPoint) -> Double
    {
        let Haversine =
        {
            (Angle: Double) -> Double in
            return (1.0 - cos(Angle)) / 2.0
        }
        let AHaversine =
        {
            (Angle: Double) -> Double in
            return 2.0 * asin(sqrt(Angle))
        }
        let Lat1 = Point1.Latitude.Radians
        let Lon1 = Point1.Longitude.Radians
        let Lat2 = Point2.Latitude.Radians
        let Lon2 = Point2.Longitude.Radians
        
        let Distance = EarthRadius * AHaversine(Haversine(Lat2 - Lat1) + cos(Lat1) * cos(Lat2) * Haversine(Lon2 - Lon1))
        return Distance
    }
    
    /// Calculates the distance between the two passed earthquakes. Assumes both earthquakes are at the
    /// surface of the Earth.
    /// - Parameter Quake1: First earthquake.
    /// - Parameter Quake2: Second earthquake.
    /// - Returns: Distance between the two earthquakes, in meters.
    public static func HaversineDistance(Quake1: Earthquake, Quake2: Earthquake) -> Double
    {
        return HaversineDistance(Point1: GeoPoint(Quake1.Latitude, Quake1.Longitude),
                                 Point2: GeoPoint(Quake2.Latitude, Quake2.Longitude))
    }
    
    /// Calculates the distance between the two coordinates.
    /// - Parameter Latitude1: Latitude of first location.
    /// - Parameter Longitude1: Longitude of first location.
    /// - Parameter Latitude2: Latitude of second location.
    /// - Parameter Longitude2: Longitude of second location.
    /// - Returns: Distance between the two locations, in meters.
    public static func HaversineDistance(Latitude1: Double, Longitude1: Double,
                                         Latitude2: Double, Longitude2: Double) -> Double
    {
        return HaversineDistance(Point1: GeoPoint(Latitude1, Longitude1),
                                 Point2: GeoPoint(Latitude2, Longitude2))
    }
    
    /// Calculated the distance between two three dimensional points.
    /// - Parameter X1: First X coordinate.
    /// - Parameter Y1: First Y coordinate.
    /// - Parameter Z1: First Z coordinate.
    /// - Parameter X2: Second X coordinate.
    /// - Parameter Y2: Second Y coordinate.
    /// - Parameter Z2: Second Z coordinate.
    /// - Returns: Distance (unitless) between the two points.
    public static func Distance3D(X1: Double, Y1: Double, Z1: Double,
                                  X2: Double, Y2: Double, Z2: Double) -> Double
    {
        let XSq = (X2 - X1) * (X2 - X1)
        let YSq = (Y2 - Y1) * (Y2 - Y1)
        let ZSq = (Z2 - Z1) * (Z2 - Z1)
        return sqrt(XSq + YSq + ZSq)
    }
    
    /// Implementation of the Spherical Law of Cosines. Used to calculate a distance between two
    /// points on a sphere, in our case, the surface of the Earth.
    /// - Parameter Point1: First location.
    /// - Parameter Point2: Second location.
    /// - Returns: Distance from `Point1` to `Point2` in kilometers.
    public static func LawOfCosines(Point1: GeoPoint, Point2: GeoPoint) -> Double
    {
        let Term1 = sin(Point1.Latitude.ToRadians()) * sin(Point2.Latitude.ToRadians())
        let Term2 = cos(Point1.Latitude.ToRadians()) * cos(Point2.Latitude.ToRadians())
        let Term3 = cos(Point2.Longitude.ToRadians() - Point1.Longitude.ToRadians())
        var V = acos(Term1 + (Term2 * Term3))
        V = V * 6367.4447
        return V
    }
    
    /// Returns the distance from the passed location to the North Pole.
    /// - Returns: Distance (in kilometers) from `To` to the North Pole.
    public static func DistanceFromNorthPole(To: GeoPoint) -> Double
    {
        return LawOfCosines(Point1: GeoPoint(90.0, 0.0), Point2: To)
    }
    
    /// Returns the distance from the passed location to the South Pole.
    /// - Returns: Distance (in kilometers) from `To` to the South Pole.
    public static func DistanceFromSouthPole(To: GeoPoint) -> Double
    {
        return LawOfCosines(Point1: GeoPoint(-90.0, 0.0), Point2: To)
    }
    
    /// Returns the distance from the passed location to the pole that is at the center of the image.
    /// - Parameter To: The point whose distance to the pole at the center of the image is returned.
    /// - Returns: The distance (in kilometers) from `To` to the pole at the center of the image.
    public static func DistanceFromContextPole(To: GeoPoint) -> Double
    {
        if Settings.GetEnum(ForKey: .ViewType, EnumType: ViewTypes.self, Default: .FlatSouthCenter) == .FlatNorthCenter
        {
            return DistanceFromNorthPole(To: To)
        }
        else
        {
            return DistanceFromSouthPole(To: To)
        }
    }
    
    /// Returns a set of points along an arc, equally spaced.
    /// - Note: Returned points all have a `z` value of 0.0
    /// - Parameter Radius: The radius of the arc.
    /// - Parameter Count: The number of points returned.
    /// - Returns: Array of points along the arc, equally spaced.
    public static func PointsOnArc(Radius: Double, Count: Int) -> [SCNVector3]
    {
        var Results = [SCNVector3]()
        let Stride = 180.0 / Double(Count)
        for Angle in stride(from: 0.0, to: 180.01, by: Stride)
        {
            let Radian = Angle.Radians
            let X = Radius * cos(Radian)
            let Y = Radius * sin(Radian)
            let NewPoint = SCNVector3(X, Y, 0.0)
            Results.append(NewPoint)
        }
        return Results
    }
    
    /// Transform a set of 3D points to be suitable for moving lights in flat mode.
    /// - Note: For each point in `Points`, `x` is assigned `XValue`, `y` is assigned the source point's `x`
    ///         value, and `z` is assigned the source point's `y` value with `ZOffset` added.
    /// - Parameter Points: The source points used to create the results.
    /// - Parameter XValue: The value to assign to each resultant point's `x` field.
    /// - Parameter ZOffset: The offset value to add to the resultant point's `z` field.
    /// - Parameter ZMultiplier: Mutlipier for the Z value - applied before summing the offset with the original
    ///                          point.
    /// - Returns: Array of transformed points suitable for moving lights in flat mode.
    public static func AdjustPointsOnArc(_ Points: [SCNVector3], XValue: Double, ZOffset: Double,
                                         ZMultiplier: Double = 1.0) -> [SCNVector3]
    {
        var Result = [SCNVector3]()
        for Point in Points
        {
            let FinalZ = (Float(Point.y) * Float(ZMultiplier)) + Float(ZOffset)
            let NewPoint = SCNVector3(Float(XValue), Float(Point.x), Float(FinalZ))
            Result.append(NewPoint)
        }
        return Result
    }
    
    /// Converts polar coordintes into Cartesian coordinates, optionally adding an offset value.
    /// - Parameter Theta: The angle of the polar coordinate.
    /// - Parameter Radius: The radial value of the polar coordinate.
    /// - Parameter HOffset: Value added to the returned `x` value. Defaults to 0.0.
    /// - Parameter VOffset: Value added to the returned `y` value. Defaults to 0.0.
    /// - Returns: `CGPoint` with the converted polar coorindate.
    public static func PolarToCartesian(Theta: Double, Radius: Double, HOffset: Double = 0.0, VOffset: Double = 0.0) -> CGPoint
    {
        let Radial = Theta * Double.pi / 180.0
        let X = Radius * cos(Radial) + HOffset
        let Y = Radius * sin(Radial) + VOffset
        return CGPoint(x: X, y: Y)
    }
    
    /// Converts Cartesian coordinates into polar coordinates.
    /// - Parameter X: The horizontal Cartesian coordinate.
    /// - Parameter Y: The vertical Cartesian coordinate.
    /// - Returns: Tuple in the form (Radius, Angle) where `Angle` is in degrees.
    public static func CartesianToPolar(X: Double, Y: Double) -> (Radius: Double, Angle: Double)
    {
        let Radius = sqrt((X * X) + (Y * Y))
        let Theta = atan2(Y, X)
        return (Radius: Radius, Angle: Theta.Degrees)
    }
    
    /// Converts a point on a rectangle in an `SCNView` to a geographical coordinate.
    /// - Parameter Point: The point to convert. Assumes `x` is the horizontal coordinate and
    ///                    `z` is the vertical coordinate. Furthermore, this function assumes
    ///                    `z` is negated - negative values are towards the top. This function
    ///                    corrects for that.
    /// - Parameter Width: Width of the rectangle.
    /// - Parameter Height: Height of the rectangle.
    /// - Returns: Tuple in the form (Latitude, Longitude).
    public static func ConvertRectangleToGeo(Point: SCNVector3, Width: Double,
                                             Height: Double) -> (Latitude: Double, Longitude: Double)
    {
        let X = Double(Point.x)
        let Y = Double(-Point.z)
        let HalfWidth = Width / 2.0
        let HalfHeight = Height / 2.0
        let XPercent = X / HalfWidth
        let YPercent = Y / HalfHeight
        let Longitude = 180.0 * XPercent * -1.0
        let Latitude = 90.0 * YPercent
        return (Latitude, Longitude)
    }
    
    /// Converts a point on a circular, flat `SCNView` map to a geographical coordinate.
    /// - Parameter Point: The point to convert. Assumes `x` is the horizontal coordinate and
    ///                    `z` is the vertical coordinate. Furthermore, this function assumes
    ///                    `z` is negated - negative values are towards the top. This function
    ///                    corrects for that.
    /// - Parameter Radius: The length of the radius of the circular map.
    /// - Parameter Angle: The angle offset of the circular map (which may correspond to rotational
    ///                    values associated with time).
    /// - Parameter NorthCenter: For maps with the north in the center.
    /// - Parameter ThetaValue: Returned theta value.
    /// - Returns: Tuple with the latitude and longitude.
    public static func ConvertCircleToGeo(Point: SCNVector3, Radius: Double,
                                          Angle: Double, NorthCenter: Bool,
                                          ThetaValue: inout Double) -> (Latitude: Double, Longitude: Double)
    {
        let (R, Theta) = CartesianToPolar(X: Double(Point.x), Y: Double(Point.z))
        ThetaValue = Theta
        let RadialPercent = R / Radius
        let FinalRadial = 180.0 * RadialPercent
        var Latitude = FinalRadial - 90.0
        if NorthCenter
        {
            Latitude = Latitude * -1.0
        }
        let Longitude = Theta + Angle
        return (Latitude, Longitude)
    }
    
    /// Rotate a point around the origin.
    /// - Parameter Point: The point to rotate.
    /// - Parameter By: The number of degrees (will be converted internally to radians) to
    ///                 rotate `Point` by.
    /// - Returns: A new point based on the rotation of the passed point.
    public static func RotatePoint(_ Point: CGPoint, By Degrees: Double) -> CGPoint
    {
        let Radians = Degrees.Radians
        let SinRadians = sin(Radians)
        let CosRadians = cos(Radians)
        let X = Double(Point.x) * CosRadians - Double(Point.y) * SinRadians
        let Y = Double(Point.x) * SinRadians + Double(Point.y) * CosRadians
        return CGPoint(x: X, y: Y)
    }
    
    //https://stackoverflow.com/questions/34050929/3d-point-rotation-algorithm/34060479
    public static func Rotate3D(Point: SCNVector3, Pitch: Double, Roll: Double, Yaw: Double, ConvertToRadians: Bool = true) -> SCNVector3
    {
        let X = ConvertToRadians ? Pitch.Radians : Pitch
        let Y = ConvertToRadians ? Roll.Radians : Roll
        let Z = ConvertToRadians ? Yaw.Radians : Yaw
        let CosA: Double = cos(Z)
        let SinA: Double = sin(Z)
        let CosB: Double = cos(X)
        let SinB: Double = sin(X)
        let CosC: Double = cos(Y)
        let SinC: Double = cos(Y)
        let Axx: Double = CosA * CosB
        let Axy: Double = CosA * SinB * SinC - (SinA * CosC)
        let Axz: Double = CosA * SinB * CosC + (SinA * SinC)
        let Ayx: Double = SinA * CosB
        let Ayy: Double = SinA * SinB * SinC + (CosA * CosC)
        let Ayz: Double = SinA * SinB * CosC - (CosA * SinC)
        let Azx: Double = -SinB
        let Azy: Double = CosB * SinC
        let Azz: Double = CosB * CosC
        let FinalX: Double = Double(Axx * Double(Point.x)) + Double(Axy * Double(Point.y)) + Double(Axz * Double(Point.z))
        let FinalY: Double = Double(Ayx * Double(Point.x)) + Double(Ayy * Double(Point.y)) + Double(Ayz * Double(Point.z))
        let FinalZ: Double = Double(Azx * Double(Point.x)) + Double(Azy * Double(Point.y)) + Double(Azz * Double(Point.z))
        return SCNVector3(FinalX, FinalY, FinalZ)
    }
    
    public static func Rotate3D(_ X: Double, _ Y: Double, _ Z: Double, Pitch: Double, Roll: Double, Yaw: Double,
                                ConvertToRadians: Bool = true) -> SCNVector3
    {
        return Rotate3D(Point: SCNVector3(X, Y, Z), Pitch: Pitch, Roll: Roll, Yaw: Yaw,
                        ConvertToRadians: ConvertToRadians)
    }
}
