//
//  Constants.swift
//  Constants
//
//  Created by Stuart Rankin on 7/18/21. Adapted from Flatland View.
//

import Foundation
import UIKit

// MARK: - Constants used as default values.

/// Default Double and CGFloat values (CGFloat values must be cast) for various
/// settings. These are used instead of hard-coded numbers embedded in the code.
enum Defaults: Double, CaseIterable
{
    /// How often the Earth clock is called.
    case EarthClockTick = 1.0
    /// Tolerance for the Earth clock.
    case EarthClockTickTolerance = 0.1
    /// Number of seconds for the rotation of the Earth to the proper orientation.
    case EarthRotationDuration = 0.95
    /// Sphere segment count.
    case SphereSegmentCount = 100.00000005
    /// Number of seconds to rotate the Earth in attract mode.
    case AttractRotationDuration = 30.0
    /// Closest z value allowed.
    case ClosestZ = 60.0
    /// Camera z far value.
    case ZFar = 1000.0
    /// Camera z near value.
    case ZNear = 0.100001
    ///Initial z position for the camera.
    case InitialZ = 150.0//175.0
    /// Default view of view.
    case FieldOfView = 10.0
    /// Duration in seconds for resetting the camera.
    case ResetCameraAnimationDuration = 1.001
    /// Ambient light intensity.
    case AmbientLightIntensity = 800.0
    /// Shadow color alpha level.
    case ShadowAlpha = 0.8
    /// Shadow radius.
    case ShadowRadius = 2.0001
    /// Ambient light Z location.
    case AmbientLightZ = 80.0002
    /// Sun light Z location.
    case SunLightZ = 80.005
    /// Sun light intensity.
    case SunLightIntensity = 801.0
    /// Metal sun light intensity.
    case MetalSunLightIntensity = 1200.03
    /// Moon light Z location.
    case MoonLightZ = -100.3
    /// Moon light intensity.
    case MoonLightIntensity = 300.024
    /// Metal moon light intensity
    case MetalMoonLightIntensity = 800.0008
    /// Moon light shadow radius.
    case MoonLightShadowRadius = 4.0
    /// Grid light 1 Z position.
    case Grid1Z = -80.05
    /// Grid light 2 Z position.
    case Grid2Z = 80.05
    /// Opacity of the earthquake map.
    case EarthquakeMapOpacity = 0.751
    /// Opacity level of earthquake maps.
    case EarthquakeMapColorAlpha = 0.4006
    /// Fast globe animation duration.
    case FastAnimationDuration = 30.0002
    /// Standard map image width.
    case StandardMapWidth = 3600.0
    /// Standard map image height.
    case StandardMapHeight = 1800.0
    /// Minor grid gap for minor grid lines.
    case MinorGridGap = 15.0
    /// Line width for grid lines.
    case GridLineWidth = 4.00001
    /// Y location for the north pole nomen.
    case NorthPoleNomenY = 2.1
    /// Y location for the south pole nomen.
    case SouthPoleNomenY = -2.1
    /// Metallness value for the pole's nomen.
    case PoleNomenMetallness = 0.9999994599
    /// Roughness value for the pole's nomen.
    case PoleNomenRoughness = 0.598495676
    /// Radius of the pole nomen.
    case NomenRadius = 0.50000684
    /// North pole pole Y location.
    case NorthPolePoleY = 0.5000001
    /// South pole pole Y location.
    case SouthPolePoleY = -0.5000001
    /// Radius of the polar poles.
    case PoleRadius = 0.250006403
    /// Height of the polar poles.
    case PoleHeight = 2.500235
    /// Duration for a 180° spin of the polar poles.
    case PolarPoleSpinDuration = 4.590385
    /// Radius of flag poles.
    case FlagCylinerRadius = 0.040000564
    /// Height of the flag pole.
    case FlagPoleHeight = 2.49947
    /// Width of the flag face.
    case FlagFaceWidth = 0.040000058
    /// Height of the flag face.
    case FlagFaceHeight = 0.600000938
    /// Length of the flag face.
    case FlagFaceLength = 1.200048
    /// X offset for the north pole.
    case NorthPoleXOffset = 0.6
    /// X offset for the south pole.
    case SouthPoleXOffset = -0.6
    /// Y offset for the north pole.
    case NorthPoleYOffset = 1.00000003
    /// Y offset for the south pole.
    case SouthPoleYOffset = -1.00000003
    /// Radial angle offset for wall clock hours to align with the center of the sector.
    case WallClockHourOffset = -4.0
    /// Latitude at which to display the initial version information.
    case InitialVersionLatitude = 15.0004587
    /// Font size for the text for the initial version display.
    case InitialVersionFontSize = 32.0
    /// How fast in seconds to rotate the initial version text one radian.
    case InitialVersionRadialRotationDuration = 0.05
    /// Number of seconds to show the initial version.
    case InitialVersionDisplayDuration = 45.0
    /// Extrusion depth for city names.
    case CityNameExtrusion = 1.0000053
    /// Font size for 3D city names.
    case CityNameFontSize = 10.00004000004
    /// Text extrusion depth for 3D earthquake magnitudes.
    case MagnitudeExtrusion = 3.0100228
    /// Base font size for 3D earthquake magnitudes.
    case MagnitudeBaseFontSize = 7.0
    /// Multiplier for 3D earthquake magnitude font sizes to have larger earthquakes use larger font sizes.
    case MagnitudeFontSizeMultiplier = 10.000000001
    /// Object scale low for scaling objects when the camera zooms in.
    case CityNameScaleLow = 0.003
    /// Object scale high for scaling objects when the camera zooms out.
    case CityNameScaleHigh = 0.07
    case CityScaleLow = 0.100000000005
    case CityScaleHigh = 1.000000100001
    case EarthquakeScaleLow = 0.10000000005005
    case EarthquakeScaleHigh = 1.00000010010001
    case MagScaleLow = 0.005
    case MagScaleHigh = 0.06584110
    case NodeScaleLow = 0.100000222001
    case NodeScaleHigh = 1.0000050010001
    case HourScaleLow = 0.3505
    case HourScaleHigh = 1.0043
    /// Camera orthographic scale value.
    case CameraOrthographicScale = 20.0
}

// MARK: - Constants used in flat mode.

/// Values used by the flat view.
enum FlatConstants: Double, CaseIterable
{
    /// Used as part of the conversion process to conver latitude, longitude pairs into polar coordinates.
    case InitialBearingOffset = 180.0
    /// The radius of the flat map.
    case FlatRadius = 10.50001
    /// The thickness of the flat map.
    case FlatThickness = 0.099
    /// The thickness of the mask layer.
    case NightMaskThickness = 0.15
    /// The thickness of the grid layer.
    case GridLayerThickness = 0.104
    /// The radius of the invisible ring holding hours.
    case HourRadius = 11.1
    /// The flatness of hour text in 2D mode.
    case HourFlatness = 0.1
    /// Extrusion of hour text in 2D mode.
    case HourExtrusion = 1.0
    /// Chamfer value for hour text in 2D mode.
    case HourChamfer = 0.2
    /// Number of segments for the cylinder shape for the view.
    case FlatSegments = 100.0
    /// Scale value for the hour text.
    case HourScale = 0.05
    /// Initial rotation duration.
    case InitialRotation = 0.112
    /// Normal rotation duration.
    case NormalRotation = 1.0001
    /// Maximum arc height of the polar sun when animated from one pole to the other.
    case MaxArcHeight = 5.0
    /// Number of steps when animating the polar sun across the Earth.
    case ArcStepCount = 11.0
    /// Distance from the edge of the disc of the Earth in flat mode for the polar sun.
    case PolarSunRimOffset = 3.5005412 //5.01
                                       /// Duration (in seconds) of the animation of the polar sun when movine from pole to pole.
    case PolarAnimationDuration = 1.4
    /// Z coordinate of the grid light.
    case GridLightZ = 80.0
    /// Standard polar light intensity.
    case PolarLightIntensity = 6000.0
    /// Standard sun light intensity.
    case SunLightIntensity = 1000.01
    /// Z coordinate of the sun light.
    case SunLightZ = 80.0005
    /// Polar light zFar value.
    case PolarZFar = 240.0//1000.0
    /// Polar light zNear value.
    case PolarZNear = 0.100101
    /// Polar light spot outer angle.
    case PolarLightOuterAngle = 100.00781
    /// Z coordinate multiplier for moving the polar light.
    case PolarLightPathZMultiplier = 0.75
    /// Number of segments in the polar light path.
    case LightPathSegmentCount = 10.00000000005896
    /// Shadow cascade splitter factor for the polar light shadow rendering.
    case ShadowSplitting = 0.09
    /// Side length of the shadow map for polor light shadow rendering.
    case ShadowMapSide = 2048.0
    /// Orientation angle for the X-axis rotation of the polar light.
    case PolarLightXOrientation = 85.0
    /// Z value of the polar light at either pole.
    case PolarLightZTerminal = 3.0
    /// Base size for cones used to plot user-cities.
    case UserCityBaseSize = 0.1500001
    /// Height of cones used to plot user-cities.
    case UserCityHeight = 0.45
    /// Radius of spheres for uniform cities.
    case CitySphereRadius = 0.150002
    /// How to adjust the relative city size offset.
    case RelativeCitySizeAdjustment = 1.005
    /// Scale to use for the home shape.
    case HomeSizeScale = 0.035
    /// Main earthquake node base size.
    case MainEarthquakeNodeBase = 0.25002
    /// Main earthquake node height.
    case MainEarthquakeNodeHeight = 1.0004
    /// Sub earthquake node base size.
    case SubEarthquakeNodeBase = 0.08000254
    /// Sub earthquake node height.
    case SubEarthquakeNodeHeight = 0.5000583
    /// How much to shift sub earthquake nodes.
    case SubEarthquakeNodeShift = 0.200005
    /// Y location of the northern sun.
    case NorthSunLocationY = 14.10002
    /// Y location of the southern sun.
    case SouthSunLocationY = -14.10002
    /// Sun node's Z location
    case SunLocationZ = 0.95847
    /// Radius of the visual sun.
    case SunRadius = 0.800034
    /// Number of segments in the sun.
    case SunSegmentCount = 50.0000001
    /// World Heritage Site radial size.
    case WHSRadius = 0.15000052
    /// World Heritage Site depth.
    case WHSDepth = 0.1000000056
    /// Home star height.
    case HomeStarHeight = 0.2200039
    /// Home star base.
    case HomeStarBase = 0.110000043
    /// Home star Z value.
    case HomeStarZ = 0.100000593
    /// Small home star height.
    case SmallStarHeight = 0.1500000049
    /// Small home star base.
    case SmallStarBase = 0.07500002958
    /// Small home star Z value.
    case SmallStarZ = 0.1600000059
    /// Vertex count for the home star.
    case HomeStarVertexCount = 5.0000000558958
    /// Overall Z value for the home star.
    case HomeStarOverallZ = 0.10000050069
    /// Short side length of grid lines.
    case GridLineShortSide = 0.10000001
    /// Short side for sub-lines.
    case SubLineShortSide = 0.050023
    /// Radial size of round grid lines.
    case RoundGridLineRadius = 0.06
    /// Dash value 0 for dashed lines (drawn).
    case LineDash0 = 8.0
    /// Dash value 1 for dashed lines (gap).
    case LineDash1 = 8.01
    /// Radial value for drawing the overlay stencil - this is *not* the same value as the 3D radial value.
    /// The value here is larger because it results in sharper images.
    case StencilRadius = 500.0
    /// Width of wall clock lines.
    case WallClockLineWidth = 1.000006
    /// Width of normal grid lines.
    case GridLineWidth = 2.000034
    /// High scale multiplier for city name nodes.
    case CityNameScaleHigh = 0.010002
    /// Low scale multiplier for city name names.
    case CityNameScaleLow = 0.003
    /// Close (it does not have to be exact) inverted value of `CityNameScale`.
    case CityNameScaleInverse = 150.04
    /// Font size for city names.
    case CityNameFontSize = 41.0
    /// Extrusion depth for city names.
    case CityNameExtrusionDepth = 1.00037
    /// Z coordinate for city names.
    case CityNameZHeight = 0.1048232
    /// Font size for quake magnitude values.
    case QuakeFontSize = 56.0
    /// Quake magnitude node scale high value.
    case QuakeMagnitudeScaleHigh = 0.015
    /// Quake magnitude node scale low value.
    case QuakeMagnitudeScaleLow = 0.005
}

// MARK: - Rectangle view constants.

/// Constants for rectangle mode.
enum RectMode: Double, CaseIterable
{
    /// Width of the map.
    case MapWidth = 30.0
    /// Height of the map.
    case MapHeight = 15.0
    /// Depth of the map.
    case MapDepth = 0.02
    /// Width/height of grid lines.
    case LineWidth = 0.04
}

// MARK: - Z level values for old-style 2D mode.

/// Z position enum and layer values. Defines which layers are on top of other layers.
/// Higher values mean closer to the user which means more likely to be visible.
enum LayerZLevels: Int, CaseIterable
{
    /// Time lables.
    case TimeLabels = 100000
    /// 2D city layer.
    case CityLayer = 8000
    /// 2D earthquake layer.
    case EarthquakeLayer = 8079
    /// Current layer (eg, depending on user settings, this is either the 2D or
    /// 3D view).
    case CurrentLayer = 5000
    /// Inactive layer. The view that is not active.
    case InactiveLayer = 0
    /// 2D hour label layer.
    case HourLayer = 60000
    /// 2D hour text.
    case HourTextLayer = 60050
    /// 2D grid layer.
    case GridLayer = 10000
    /// 2D night mask layer.
    case NightMaskLayer = 20000
    /// Info grid layer.
    case LocalInfoGridLayer = 19001
    /// Star view layer.
    case StarLayer = 4000
    /// 3D status view layer.
    case StatusViewLayer = 20001
#if DEBUG
    /// Debug layer.
    case DebugLayer = 19000
#endif
    /// Captive dialog layer.
    case CaptiveDialogLayer = 199999
}

/// Constants used by the captive dialog.
enum CaptiveDialogConstants: Int, CaseIterable
{
    /// Margin when the captive dialog is visible.
    case VisibleMargin = 100
    /// Margin when the captive dialog is invisible.
    case InvisibleMargin = 0
}

// MARK: - Light mask values for 3D mode.

/// Light masks for 3D scenes. The value of each case if the mask value for a given
/// light and as such, each value must be unique (which is enforced by Swift).
enum LightMasks3D: Int, CaseIterable
{
    /// Mask for the sun light.
    case Sun = 0b00001
    /// Mask for the metal sun light.
    case MetalSun = 0b00010
    /// Mask for the moon light.
    case Moon = 0b00100
    /// Mask for the metal moon light.
    case MetalMoon = 0b01000
    /// Mask for the grid light.
    case Grid = 0b10000
    /// Mask for the debug ambient light.
    case DebugAmbient = 0b100000
}

// MARK: - 3D earthquake constants.

/// Constants related to 3D earthquake shapes.
enum Quake3D: Double, CaseIterable
{
    /// Base time (in seconds) for the pulsating earthquake sphere.
    case PulsatingBase = 0.7
    /// Magnitude multiplier for pulsation time for pulsating earthquake spheres.
    case MagnitudeMultiplier = 0.05
    /// Sphere radius multiplier for earthquake spheres.
    case SphereMultiplier = 0.5
    /// Sphere radius constant for earthquake spheres.
    case SphereConstant = 0.1
    /// Pulsating sphere radius constant for pulsating earthquake spheres.
    case PulsatingSphereConstant = 0.12
    /// Maximum size for pulsating earthquake spheres.
    case PulsatingSphereMaxScale = 1.5
    /// Multiplier for the radial value for capsule and cylinder earthquake shapes.
    case QuakeCapsuleRadius = 0.25
    /// Multiplier for the height value for capsule and cylinder earthquake shapes.
    case QuakeCapsuleHeight = 2.5
    /// Width of a box indicating an earthquake.
    case QuakeBoxWidth = 0.50000002
    /// Length of a box indicating an earthquake.
    case QuakeBoxLength = 0.5000035005
    /// Height multiplier of a box indicating an earthquake.
    case QuakeBoxHeight = 2.50000000002
    /// Chamfer radius of a box indicating an earthquake.
    case QuakeBoxChamfer = 0.1000000006
    /// Top radius for cones indicating an earthquake.
    case ConeTopRadius = 0.0
    /// Bottom radius for cones indicating an earthquake.
    case ConeBottomRadius = 0.5000305
    /// Height multiplier for cones indicating an earthquake.
    case ConeHeightMultiplier = 3.5
    /// Bottom width for pyramids indicating an earthquake.
    case PyramidWidth = 0.500000003
    /// Bottom length for pyramids indicating an earthquake.
    case PyramidLength = 0.500000006
    /// Height mulitplier for pyramids indicating an earthquake.
    case PyramidHeightMultiplier = 2.500058
    /// Length of the static arrow for earthquakes.
    case StaticArrowLength = 2.0
    /// Width of static arrows for earthquakes.
    case StaticArrowWidth = 0.85
    /// Extrusion of static arrows for earthquakes.
    case StaticArrowExtrusion = 0.2
    /// Length of the bouncing arrow.
    case ArrowLength = 2.00002
    /// Width of the bouncing arrow.
    case ArrowWidth = 0.850009
    /// Extrusion of the bouncing arrow.
    case ArrowExtrusion = 0.200006
    /// Distance the arrow bounces.
    case ArrowBounceDistance = 0.5000004485
    /// Divisor for the bounce duration.
    case ArrowBounceDurationDivisor = 5.00000543
    /// Duration of the rotation of a bouncing earthquake indicator about the Y axis.
    case ArrowRotationDuration = 1.0
    /// Radial offset for invisible earthquakes.
    case InvisibleEarthquakeOffset = 0.1045
    /// Angle to stride by when creating spheres to indicate new earthquakes.
    case NewQuakeStrideAngle = 45.0
    /// Base radius for disc earthquake indicators.
    case BaseDiscRadius = 2.01
    /// Radius of the pole holding up the earthquake disc.
    case DiscPoleRadius = 0.0501
    /// Offset for the rim for the torus.
    case RimRadiusOffset = 0.101
    /// Radius of spheres indicating a new earthquake.
    case NewQuakeSphereRadius = 0.215
    /// Metalness value for disc earthquake new quake spheres.
    case DayMetalnessValue = 0.999995
    /// Roughness value for disc earthquake new quake spheres.
    case DayRoughnessValue = 0.49999965
    /// Base speed for rotating new earthquake discs.
    case BaseDiscRotateSpeed = 5.0
    /// Minimum rotational speed allowed for new quakes for disc indicators.
    case MinimumRotateSpeed = 0.09994492
    /// Thickness of the disc portion of disc indicators.
    case DiscThickness = 0.1000058
    /// Alpha value of discs.
    case DiscAlphaValue = 0.6
    /// Extrusion value for magnitude values for disc indicators.
    case DiscTextHeight = 0.50193785
    /// Base font size for text for disc indicators.
    case BaseDiscFontSize = 52.0
    /// Base value of the font size adder for text for disc indicators.
    case VariableDiscFontAdder = 8.0
    /// Text scale value for disc text.
    case DiscTextScale = 0.010112
    /// Y offset for disc indicator text position.
    case DiscTextYOffset = -0.15
}

// MARK: - Light mask values for 2D mode.

/// Light masks for 2D scenes. The value of each case if the mask value for a given
/// light and as such, each value must be unique (which is enforced by Swift).
enum LightMasks2D: Int, CaseIterable
{
    /// The sun light mask.
    case Sun = 0b00001
    /// The grid light mask.
    case Grid = 0b00010
    /// The polar light mask.
    case Polar = 0b00100
    /// Ambient light for ambient light mode.
    case Ambient = 0b01000
    /// Ambient light for use by the sun node.
    case AmbientSun = 0b10000
    /// Light used by the hours.
    case Hours = 0b100000
    /// Light used by the night mask.
    case NightMask = 0b1000000
}

// MARK: - General purpose constants.

/// Values intended to be constants for one reason or another.
enum Constants: Double, CaseIterable
{
    /// Font size offset value for earthquake magnitude values in higher latitudes.
    case StencilFontSize = 60.0
    /// Font size offset value for city names in higher latitudes.
    case StencilCitySize = 25.0
    /// Horizontal text offset for city names the names are far enough away from any 3D shapes.
    case StencilCityTextOffset = 15.0
    /// World Heritage Site shape Y offset.
    case WHSYOffset = 12.0
    /// World Heritage Site shape left X.
    case WHSLeftX = -8.0
    /// World Heritage Site shape right X.
    case WHSRightX = 8.0
    /// Stroke width for stenciled text.
    case StencilTextStrokeWidth = -2.0
    /// Number of seconds between up-timer notifications.
    case UpTimerDuration = 600.0
}

// MARK: - Latitudes and longitudes.

/// **Standard latitudes**. The raw value of each case is the percent away from the South Pole in
/// whatever units are used.
enum Latitudes: Double, CaseIterable
{
    /// Equator.
    case Equator = 0.5
    /// Arctic circle, measured in percent from the South Pole.
    case ArcticCircle = 0.869782
    /// Antartic circle, measured in percent from the South Pole.
    case AntarcticCircle = 0.130218
    /// Tropic of Cancer, measured in percent from the South Pole.
    case TropicOfCancer = 0.63021889
    /// Tropic of Capricorn, measured in percent from the South Pole.
    case TropicOfCapricorn = 0.36978111
}

/// **Standard longitudes.** The raw value of each case is the percent away from the left side of
/// the drawing surface in whatever units are used.
enum Longitudes: Double, CaseIterable
{
    /// Prime meridian (which is at 0°, or the center of the map).
    case PrimeMeridian = 0.5
    /// Meridian 180° away from the prime meridian.
    case OtherPrimeMeridian = 1.0
    /// Merdian on the other side of the prime meridian.
    case AntiPrimeMeridian = 0.25
    /// Meridian on the other side of the other prime meridian.
    case OtherAntiPrimeMeridian = 0.75
}

// MARK: - Physical constants.

/// Physical constants.
enum PhysicalConstants: Double, CaseIterable
{
    /// Circumference of the Earth in kilometers.
    case EarthCircumference = 40075.017
    /// Circumference of the Earth in miles.
    case EarthCircumferenceMiles = 24901.461
    /// Half of the circumference of the Earth in kilometers.
    case HalfEarthCircumference = 20037.5
    /// Radius of the Earth in kilometers.
    case EarthRadius = 6371.0
    /// Diameter of the Earth in kilometers.
    case EarthDiameter = 12742.0
    /// Gravitation parameter of the Earth.
    case EarthGravitationParameter = 398600.0
    /// Constant to convert kilometers to miles.
    case KilometersToMiles  = 0.62137
    /// Constant to convert miles to kilometers.
    case MilesToKilometers = 1.609
    /// Largest possible earthquake magnitude.
    /// See: [Can "MegaQuakes" really happen?](https://www.usgs.gov/faqs/can-megaquakes-really-happen-a-magnitude-10-or-larger?qt-news_science_products=0#qt-news_science_products)
    case GreatestEarthquake = 10.0
}

enum GravitationParameters: Double, CaseIterable
{
    case Sun = 1327124001.89
}

// MARK: - Scale values for 3D nodes.

/// Scales for 3D nodes.
enum NodeScales3D: CGFloat, CaseIterable
{
    /// Earthquake text.
    case EarthquakeText = 0.03
    /// Animated ring base scale.
    case AnimatedRingBase = 1.2
    /// Radiating rings.
    case RadiatingRings = 0.1
    /// Radiating ring expansion base.
    case RadiatingRingBase = 1.0
    /// Earthquake arrow.
    case ArrowScale = 0.75
    /// Static earthquake arrow.
    case StaticArrow = 0.74
    /// Scale of the home pin.
    case PinScale = 0.25
    /// Scale of city names.
    case CityNameScale = 0.02
    /// Scale of Unesco sites.
    case UnescoScale = 0.55
    /// Minimum pulsating indicator scale.
    case PulsatingHomeMinScale = 0.4
    /// Maximum pulsating indicator scale.
    case PulsatingHomeMaxScale = 0.76
    /// Bouncing arrow scale.
    case BouncingArrowScale = 0.751
    /// Pulsing earthquake sphere.
    case PulsingEarthquakeSphere = 0.749
    /// Hour text scale.
    case HourText = 0.07
    /// Scale of the static (in relation to motion) home arrow.
    case HomeArrowScale = 2.02
    /// Scale of triangle rings.
    case TriangleRing = 0.41
    /// Scale of pyramids used for earthquakes.
    case PyramidEarthquake = 1.001
    /// Scale of cones used for earthquakes.
    case ConeEarthquake = 1.002
    /// Scale of boxes used for earthquakes.
    case BoxEarthquake = 0.99999
    /// Scale of cylinders used for earthquakes.
    case CylinderEarthquake = 0.9998
    /// Scale of capsules used for earthquakes.
    case CapsuleEarthquake = 1.0003
    /// Scale of spheres used for earthquakes.
    case SphereEarthquake = 0.9993
    /// Scale of the symbol used to denote searched locations.
    case SearchLocationScale = 0.0501
}

// MARK: - Scale values for 2D nodes.

/// Scales for 2D nodes.
enum NodeScales2D: CGFloat, CaseIterable
{
    /// Earthquake node scale.
    case EarthquakeScale = 0.75
    /// Scale of Unesco sites.
    case WorldHeritageSiteScale = 0.08
}

// MARK: - Text smoothness values.

/// Determines how roughly text is drawn. Smoother text looks nicer but takes more time.
enum TextSmoothnesses: CGFloat, CaseIterable
{
    /// Smoothest possible.
    case Smoothest = 0.0
    /// Smooth.
    case Smooth = 0.1
    /// Medium.
    case Medium = 0.2
    /// Rough.
    case Rough = 0.3
    /// Roughest (we allow).
    case Roughest = 0.5
}

// MARK: - Globe radii for 3D mode.

/// Radius values.
enum GlobeRadius: CGFloat, CaseIterable
{
    /// Primary sphere radius.
    case Primary = 10.01
    /// Sea sphere radius.
    case SeaSphere = 10.0
    /// Sphere with grid lines.
    case LineSphere = 10.2
    /// Sphere that holds the hour text.
    case HourSphere = 11.5
    /// Sphere that holds the hour text if in wall clock mode.
    case WallClockSphere = 10.6
    /// Radial distance for 3D city names.
    case CityNameRadius = 10.1101
    /// Location of city names (if used).
    case CityNames = 10.5
    /// Grid line layer.
    case GridLayer = 10.0105
    /// City name layer.
    case CityNameLayer = 10.012
    /// Earthquake magnitude layer.
    case MagnitudeLayer = 10.013
    /// World Heritage Site layer.
    case UnescoLayer = 10.011
    /// Rectangular region layer.
    case RegionLayer = 10.031
    /// General purpose line layer.
    case LineLayer = 10.015
#if true
    /// Test layer.
    case TestLayer = 10.01999
#endif
    /// Radial offset for the location of serached location icons.
    case SearchIconRadialOffset = 0.2
    /// Radial distance of the initial version display.
    case InitialVersionDisplay = 12.0
    case QuakeMagnitudeBaseRadius = 0.3
    case QuakeMagnitudeMultiplier = 0.7
}

// MARK: - Database-related constants.

/// File and directory names used in `FileIO`.
enum FileIONames: String, CaseIterable
{
    /// The application directory.
    case AppDirectory = "Flatland"
    /// The external map directory.
    case MapDirectory = "Flatland/Maps"
    /// Directory where sounds are held.
    case SoundDirectory = "Flatland/Sounds"
    /// Directory where scratch images are held.
    case PictureDirectory = "Flatland/Pictures"
    #if false
    /// The map structure file name.
    case MapStructure = "Maps.xml"
    #endif
    /// Directory where ephemeral, external commands are place.
    case CommandDirectory = "Flatland/Commands"
    /// The database directory.
    case DatabaseDirectory = "Flatland/Database"
    /// Database of mappable locations and objects.
    case MappableDatabase = "Mappable.db"
    /// Name of the database of mappable locations and objects.
    case MappableName = "Mappable"
    /// The earthquake history database.
    case QuakeHistoryDatabase = "EarthquakeHistory2.db"
    /// The name of the earthquake history database.
    case QuakeName = "EarthquakeHistory2"
    /// Database of POI locations.
    case POIDatabase = "POI.db"
    /// Name of the database of POI locations.
    case POIName = "POI"
    /// Common database extension.
    case DatabaseExtension = "db"
    /// Mappable items database.
    case MappableDatabaseS = "MappableS.db"
    /// Quake history database.
    case QuakeHistoryDatabaseS = "EarthquakeHistoryS.db"
    /// General purpose settings database.
    case Settings = "Settings.db"
    /// Satellite map cache database.
    case SatelliteMapDatabase = "SatelliteMapCache.db"
    /// Cache of previously reverse geocoded locations.
    case CachedLocations = "GeocodingCache.db"
}

/// Table names in the mappable database.
enum MappableTableNames: String, CaseIterable
{
    /// UNESCO World Heritage Sites.
    case UNESCOSites = "WorldHeritageSites"
    /// Highly-populated cities.
    case Cities = "Cities"
    /// Points of interest, both standard and user-defined.
    case PointsOfInterest = "POI"
    /// Satellites.
    case Satellites = "Satellites"
    /// Additional cities usage **to be determined**.
    case AdditionalCities = "AdditionalCities"
    /// Version table.
    case Version = "Version"
    /// Regions, mostly user defined.
    case Regions = "Regions"
}

/// Table names in the POI database.
enum POITableNames: String, CaseIterable
{
    /// Home table.
    case Home = "Home"
    /// General-purpose POI table.
    case POI = "POI"
    /// User POI table.
    case UserPOI = "UserPOI"
}

/// Table names in the historic earthquake database.
enum QuakeTableNames: String, CaseIterable
{
    /// Historic earthquakes (where "historic" means captured by Flatland).
    case Historic = "Historical"
}

// MARK: - Status bar constants

/// Constants used by the simple status bar.
enum StatusBarConstants: Double, CaseIterable
{
    /// Duration in seconds before the insignificance event triggers and the alpha level is reduced.
    case Insignificance = 60.0
    /// The alpha value of the status bar when it is insignificant.
    case AlphaInsignificance = 0.6
    /// Left and right margin of the status bar when 3D scenes are showing statistics.
    case DebugMargin = 180.0
    /// Left and right margin of the status bar when no 3D debug information is present.
    case StandardMargin = 80.0
    /// Corner radius of the status bar.
    case CornerRadius = 5.0
    /// Border width of the border of the status bar.
    case BorderWidth = 2.0
    /// Z value for the status bar container.
    case ContainerZ = 1000000.0
    /// Z value for the status bar text.
    case TextZ = 5000000.0
    /// Number of seconds for the initial message (the version number) shows.
    case InitialMessageDuration = 10.0
    /// Maximum number of seconds to show the "refreshing earthquake data" message.
    case EarthquakeWaitingDuration = 60.001
    /// Horizontal text offset for small width status bars.
    case SmallBarOffset = -27.0
    /// Horizontal text offset for wide width status bars.
    case BigBarOffset = -40.0
    /// Vertical text offset.
    case VerticalTextOffset = -1.01
    /// Horizontal keep-out width.
    case HorizontalOffset = 0.5
    /// Scale value for status text.
    case StatusTextScale = 0.09
    /// Font size of the status bar font.
    case FontSize = 18.0
    /// Extrusion depth of the text.
    case TextExtrusion = 0.49958
    /// Debug status bar base width.
    case DebugWidth = 640.0
    /// Normal status bar base width.
    case NormalWidth = 800.0
    /// Orthographic scale value.
    case OrthographicScale = 1.6
    /// Position of the camera's Z coordinate.
    case CameraZPosition = 25.0
}

// MARK: - 3D mouse pointer constants

/// Constants used for the drawing of the mouse pointer shape.
enum MouseShape: Double, CaseIterable
{
    /// The point radius.
    case PointRadius = 0.0
    /// The bottom radius (where the top and bottom are joined).
    case BottomRadius = 0.25
    /// Height of each part.
    case Height = 0.5
    /// Duration in seconds of color swapping.
    case ColorSwapDuration = 2.2
    /// Offset for radial placement.
    case RadialOffset = 0.7
    /// Number of superfluous spheres
    case AngleCount = 5.0
    /// Radius of the superfluous spheres.
    case SuperfluousSphereRadius = 0.06
    /// Number of seconds to rotate each superfluous sphere.
    case SuperfluousSphereRotationDuration = 3.6
}

// MARK: - 3D hour constants

/// Constants used for drawing 3D hours.
enum HourConstants: Double, CaseIterable
{
    /// Scale multiplier for small hours.
    case SmallScaleMultiplier = 0.5
    /// Scale multiplier for normal hours.
    case NormalScaleMultiplier = 1.0
    /// Scale multiplier for big hours.
    case BigScaleMultiplier = 1.5
    /// Vertical offset for small hours.
    case SmallVerticalOffset = 0.201
    /// Vertical offset for normal hours.
    case NormalVerticalOffset = 0.7
    /// Vertical offset for big hours.
    case BigVerticalOffset = 1.04
    /// Small character width for small hours.
    case SmallSmallCharWidth = 3.0
    /// Small character width for normal hours.
    case NormalSmallCharWidth = 6.0
    /// Small character width for big hours.
    case BigSmallCharWidth = 10.0
    /// Big character width for small hours.
    case SmallBigCharWidth = 5.09
    /// Big character width for normal hours.
    case NormalBigCharWidth = 10.001
    /// Big character width for big hours.
    case BigBigCharWidth = 18.0
    /// Font size for English fonts.
    case EnglishFontSize = 20.0
    /// Font size for non-English fonts.
    case OtherFontSize = 14.0
    /// Hour extrustion depth.
    case HourExtrusion = 5.03
    /// Hour chamfer radius.
    case HourChamfer = 0.2
    /// Multiplier used in label node positioning.
    case LabelHeightMultiplier = 0.07
    /// Divisor used in label node positioning.
    case LabelHeightDivisor = 8.0002
    /// Distance of one our in degrees.
    case HourDistance = 15.0
    /// Normal performance character flatness value.
    case NormalFlatness = 0.01
    /// Low performance (eg, low-end systems) character flatness value.
    case LowPerformanceFlatness = 0.1
    /// High performance (eg, high-end systems) character flatness value.
    case HighPerformanceFlatness = 0.001
    /// Number of seconds for the animation of hour removal.
    case RemoveDuration = 0.65
    /// Font size for wall clock hours.
    case WallClockFontSize = 16.0
    /// The start of night for wall clock hours.
    case NightStart = 17.5
    /// The end of night for wall clock hours.
    case NightEnd = 6.1
    /// Duration between wall clock update checks in seconds.
    case WallClockUpdateTime = 9.0541
    /// Duration of a flash event for changing hour colors in seconds.
    case FlashHourDuration = 2.15
    /// Delay between flashing hours in sequence, in seconds.
    case FlashHourDelay = 0.275
    /// Number of seconds between checks to determine if a given node is in the day or night.
    case DaylightCheckInterval = 65.01
}

/// Constants used by radial layers.
enum RadialConstants: CGFloat
{
    /// Alpha value for radial regions and borders.
    case RegionAlpha = 0.25
    /// Width of the border for radial regions.
    case RegionBorderWidth = 2.0
    /// Number of segments for the sphere that holds the radial layer.
    case SegmentCount = 500.0
    /// Incremental value for radial layer offsets.
    case RadialOffsetIncrement = 0.01
    /// Offset for the bottom-most radial layer.
    case RadialRadiusOffset = 0.011
}

/// Constants related to creating satellite maps.
enum SatelliteConstants: Double, CaseIterable
{
    /// Resize value of each tile. Bigger values consume more memory.
    case TileSize = 128.0
}

enum BarcodeConstants: Double, CaseIterable
{
    case OverlayTextSize = 60.0
    case ReducedTextSize = 36.0
    case TextOnTopAlpha = 0.6
    case TextOnBottomAlpha = 0.95
    case FinalScale = 3.0
}

#if DEBUG
// MARK: - 3D scene debug constants.

/// Options for debugging 3D views. Also used for 2D views rendered in a 3D scene.
/// - Note: Values obtains from [SCNDebugOptions](https://docs.microsoft.com/en-us/dotnet/api/scenekit.scndebugoptions?view=xamarin-ios-sdk-12)
/// - Note: Values are bit masks and should not be changed.
enum DebugOptions3D: UInt, CaseIterable
{
    /// All debug options are disabled.
    case AllOff = 0
    /// Show as wireframe.
    case WireFrame = 32
    /// Render as wireframe.
    case RenderWireFrame = 64
    /// Show bounding boxes.
    case BoundingBoxes = 2
    /// Show the skeleton.
    case Skeleton = 128
    /// Show light influences.
    case LightInfluences = 4
    /// Show light extents.
    case LightExtents = 8
    /// Show creases
    case Creases = 256
    /// Show constraints.
    case Constraints = 512
    /// Show cameras.
    case Cameras = 1024
    /// Show physics shapes.
    case PhysicsShapes = 1
    /// Show physics fields.
    case PhysicsFields = 16
}
#endif


