//
//  Enums.swift
//  Enums
//
//  Created by Stuart Rankin on 7/18/21. Adapted from Flatland View.
//

import Foundation

/// Types of views.
enum ViewTypes: String, CaseIterable
{
    /// Flat view with the north at the center.
    case FlatNorthCenter = "FlatNorthCenter"
    /// Flat view with the south at the center.
    case FlatSouthCenter = "FlatSouthCenter"
    /// 3D globe view.
    case Globe3D = "3DGlobe"
    /// 3D cube view. Mostly for silliness.
    case CubicWorld = "Cubic"
    /// Equirectangular map.
    case Rectangular = "Rectangular"
}

/// Types of earthquake notifications.
enum EarthquakeNotifications: String, CaseIterable
{
    /// No asynchronous notification.
    case None = "None"
    /// Play a sound.
    case Sound = "Sound"
    /// Display a pop-up.
    case Popup = "Popup"
    /// Play a sound and display a pop-up.
    case Both = "Both"
}

/// Notification sounds.
enum NotificationSounds: String, CaseIterable
{
    /// No sound.
    case None = "None"
}

/// Types of hour labels.
enum HourTypes: String, CaseIterable
{
    /// No hour labels.
    case None = "NoHours"
    /// Noon always at solar noon.
    case Solar = "RelativeToSolar"
    /// Hours relative to noon (eg, + or - hours away from solar noon).
    case RelativeToNoon = "RelativeToNoon"
    /// Hours relative to set location. Not used if the user does not set a
    /// location.
    case RelativeToLocation = "RelativeToLocation"
    /// Time is the wall clock time at every 15°.
    case WallClock = "WallClock"
}

/// The available time label types.
enum TimeLabels: String, CaseIterable
{
    /// Do not display the time.
    case None = "None"
    /// Time is in UTC.
    case UTC = "UTC"
    /// Time is in current local timezone.
    case Local = "Local"
}

/// Determines the location of the sun graphic (and by implication, the time label as well).
/// - Note: Used in 2D mode only.
enum SunLocations: String, CaseIterable
{
    /// Do not display the sun.
    case Hidden = "NoSun"
    /// Sun is at the top.
    case Top = "Top"
    /// Sun is at the bottom.
    case Bottom = "Bottom"
}

/// City color overrides. Used to return non-continental colors from `ColorForCity`.
enum CityColorOverrides: String, CaseIterable
{
    /// No override - use the continental color specified by the city's continent.
    case None = "None"
    /// Return the world cities color.
    case WorldCities = "WorldCities"
    /// Return the captial cities color.
    case CapitalCities = "CapitalCities"
    /// Additional, user-specified cities.
    case AdditionalCities = "AdditionalCities"
}

/// Continents for the city database.
enum Continents: String, CaseIterable
{
    /// No continental name supplied.
    case NoName = "NoName"
    /// African cities.
    case Africa = "Africa"
    /// Asian cities.
    case Asia = "Asia"
    /// European cities.
    case Europe = "Europe"
    /// North American cities.
    case NorthAmerica = "North America"
    /// South American cities.
    case SouthAmerica = "South America"
}

/// City groups.
enum CityGroups: String, CaseIterable
{
    /// World cities.
    case WorldCities = "World Cities"
    /// National capital cities.
    case CapitalCities = "Capital Cities"
    /// African cities.
    case AfricanCities = "African Cities"
    /// Asian cities.
    case AsianCities = "Asian Cities"
    /// European cities.
    case EuropeanCities = "European Cities"
    /// North American cities.
    case NorthAmericanCities = "North American Cities"
    /// South American cities.
    case SouthAmericanCities = "South American Cities"
}

/// Filter used for World Heritage Site year inclusion.
enum YearFilters: String, CaseIterable
{
    /// All years.
    case All = "All"
    /// Only a specific year.
    case Only = "Only"
    /// All years up to a given year.
    case UpTo = "Up To"
    /// All years after a given year.
    case After = "After"
}

/// World heritage site types.
enum WorldHeritageSiteTypes: String, CaseIterable
{
    /// Cultural site.
    case Cultural = "Cultural"
    /// Natural site.
    case Natural = "Natural"
    /// Mixed natural/cultural site.
    case Mixed = "Mixed"
    /// Any type of site.
    case AllSites = "All"
}

/// Shapes used to render the North Pole and South Pole.
/// - Note: Used only in 3D mode.
enum PolarShapes: String, CaseIterable
{
    /// Do not show a shape.
    case None = "None"
    /// Flag with the appropriate symbol.
    case Flag = "Flag"
    /// A literal pole with red stripes and a gold sphere on top.
    case Pole = "Barber Pole"
}

/// Scripts to use for some visual elements. This does not control the user interface
/// language.
enum Scripts: String, CaseIterable
{
    /// Use English (eg, Latin) scripts and Arabic numerals.
    case English = "English"
    /// Use Japanese scripts and numerals.
    case Japanese = "日本語"
}

/// Ways to display cities.
/// - Note: Used only in 3D mode.
enum CityDisplayTypes: String, CaseIterable
{
    /// Each city is a uniform size and embedded in the parent surface.
    case UniformEmbedded = "Uniform Flush Spheres"
    /// Each city is sized relative to its population and is embedded in the parent surface.
    case RelativeEmbedded = "Relative Flush Spheres"
    /// Each city is a sphere that floats above the parent surface and is sized relative to its population.
    case RelativeFloatingSpheres = "Floating Spheres"
    /// Each city is a box that floats above the parent surface and is sized relative to its population.
    case RelativeFloatingBoxes = "Floating Boxes"
    /// Each city is a box with height determined by relative population.
    case RelativeHeight = "Boxes"
    /// Each city is a cylinder with the height (and radius, slightly) determined by
    /// relative population.
    case Cylinders = "Cylinders"
    /// Each city is a pyramid with the height (and base) determined by the relative population.
    case Pyramids = "Pyramids"
    /// City names displayed with a variation in the size of the text indicating population.
    case Names = "Names"
    /// Each city is a thin cylinder.
    case Sticks = "Sticks"
}

/// City population types.
/// - Note: Not all cities in the database have both types of populations.
enum PopulationTypes: String, CaseIterable
{
    /// City population only.
    case City = "City"
    /// Metropolitan population.
    case Metropolitan = "Metropolitan"
}

/// Shapes for rendering the home location.
/// - Note: Used in 3D mode only.
enum HomeShapes: String, CaseIterable
{
    /// Do not show the home location.
    case Hide = "Hide"
    /// 3D arrow pointing down (radially) towards the home location.
    case Arrow = "Arrow"
    /// Flag at the home location.
    case Flag = "Flag"
    /// Pulsating sphere at the home location.
    case Pulsate = "Pulsate"
    /// 3D pin-shape.
    case Pin = "Pin"
    /// 3D bouncing arrow.
    case BouncingArrow = "Bouncing Arrow"
    /// 3D star-shape.
    case Star = "Star"
    /// Pedestal with a base.
    case PedestalWithBase = "Pedestal and Base"
}

/// Suns that can be displayed in 2D mode.
enum SunNames: String, CaseIterable
{
    /// No sun.
    case None = "None"
    /// Simple sun.
    case Simple = "Simple"
    /// Generic sun.
    case Generic = "Generic"
    /// Static, shining sun.
    case Shining = "Shining"
    /// Naomi's sun picture.
    case NaomisSun = "Naomi's Sun"
    /// Durer's sun sketch.
    case Durer = "Durer's Sun"
    /// Vintage sun picture 1.
    case Classic1 = "Old Sun 1"
    /// Vintage sun picture 2.
    case Classic2 = "Old Sun 2"
    /// Placeholder sun.
    case PlaceHolder = "Placeholder Sun"
}

/// Relative levels of darkness (implemented as alpha levels) of the night layer mask
/// in 2D mode. Actual levels determined at run-time.
/// - Note: Used in 2D mode only.
enum NightDarknesses: String, CaseIterable
{
    /// Very light (meaning a low alpha level).
    case VeryLight = "VeryLight"
    /// Not as light as `.VeryLight`.
    case Light = "Light"
    /// Not as dark as `.VeryDark`.
    case Dark = "Dark"
    /// Very dark (meaking a high alpha level).
    case VeryDark = "VeryDark"
}

/// How to filter cities by populations.
enum PopulationFilterTypes: String, CaseIterable
{
    /// By rank of city population.
    case ByRank = "ByRank"
    /// By comparison of population to user-defined constant.
    case ByPopulation = "ByPopulation"
}

/// Determines the size of plotted 2D locations.
/// - Note: Used in 2D mode only.
enum LocationShapes2D: String, CaseIterable
{
    /// Location is a square.
    case Square = "Square"
    /// Location is a circle.
    case Circle = "Circle"
    /// Location is an oval.
    case Oval = "Oval"
    /// Location is a star.
    case Star = "Star"
}

/// Speeds for the velocity of stars in the star view. Actual value determined at run-time.
enum StarSpeeds: String, CaseIterable
{
    /// Do not show moving stars.
    case Off = "Off"
    /// Slow speed.
    case Slow = "Slow"
    /// Medium speed.
    case Medium = "Medium"
    /// Fast speed.
    case Fast = "Fast"
}

/// Time units.
public enum TimeUnits: String, CaseIterable
{
    /// Represents a calendar year.
    case Year = "Year"
    /// Represents a calendar day.
    case Day = "Day"
    /// Represents an hour.
    case Hour = "Hour"
    /// Represents a minute.
    case Minute = "Minute"
}

/// Defines the types of asynchronous data that may be received.
enum AsynchronousDataCategories: String, CaseIterable
{
    /// USGS earthquakes.
    case Earthquakes = "Earthquakes"
    /// NASA Earth data.
    case EarthImageTile = "EarthImageTile"
}

/// Methods for determining colors of earthquakes.
enum EarthquakeColorMethods: String, CaseIterable
{
    /// Age of the earthquake.
    case Age = "Age"
    /// Magnitude of the earthquake.
    case Magnitude = "Magnitude"
    /// The range of the magnitude of the earthquake.
    case MagnitudeRange = "Magnitude Range"
    /// Nearest population center.
    case Population = "Population"
    /// How significant an earthquake is.
    case Significance = "Significance"
}

/// Earthquake magnitudes to display.
/// - Note: The values of the magnitudes *must* be in ascending order.
enum EarthquakeMagnitudes: Double, CaseIterable
{
    /// Display M4.0 and higher.
    case Mag4 = 4.0
    /// Display M5.0 or higher.
    case Mag5 = 5.0
    /// Display M6.0 or higher.
    case Mag6 = 6.0
    /// Display M7.0 or higher.
    case Mag7 = 7.0
    /// Display M8.0 or higher.
    case Mag8 = 8.0
    /// Display M9.0 or higher.
    case Mag9 = 9.0
}

/// Relative age for displaying earthquakes.
enum EarthquakeAges: String, CaseIterable
{
    case Age1 = "1 Day"
    case Age2 = "2 Days"
    case Age3 = "3 Days"
    case Age4 = "4 Days"
    case Age5 = "5 Days"
    case Age6 = "6 Days"
    case Age7 = "7 Days"
    case Age8 = "8 Days"
    case Age9 = "9 Days"
    case Age10 = "10 Days"
    case Age11 = "11 Days"
    case Age12 = "12 Days"
    case Age13 = "13 Days"
    case Age14 = "14 Days"
    case Age15 = "15 Days"
    case Age16 = "16 Days"
    case Age17 = "17 Days"
    case Age18 = "18 Days"
    case Age19 = "19 Days"
    case Age20 = "20 Days"
    case Age21 = "21 Days"
    case Age22 = "22 Days"
    case Age23 = "23 Days"
    case Age24 = "24 Days"
    case Age25 = "25 Days"
    case Age26 = "26 Days"
    case Age27 = "27 Days"
    case Age28 = "28 Days"
    case Age29 = "29 Days"
    case Age30 = "30 Days"
}

/// Shapes for earthquake locations.
enum EarthquakeShapes: String, CaseIterable
{
    /// Earthquake is a sphere.
    case Sphere = "Sphere"
    /// Earthquake is a pulsating sphere.
    case PulsatingSphere = "Pulsating Sphere"
    /// Earthquake is an animated arrow.
    case Arrow = "Animated Arrow"
    /// Earthquake is a static arrow.
    case StaticArrow = "Static Arrow"
    /// Earthquake is a pyramid.
    case Pyramid = "Pyramid"
    /// Earthquake is a cone.
    case Cone = "Cone"
    /// Earthquake is a box.
    case Box = "Box"
    /// Earthquake is a cylinder.
    case Cylinder = "Cylinder"
    /// Earthquake is a capsule.
    case Capsule = "Capsule"
    /// Tethered magnitude value.
    case TetheredNumber = "Tethered Magnitude"
}

/// Types of earthquake indicators.
enum EarthquakeIndicators: String, CaseIterable
{
    /// No indicator.
    case None = "None"
    /// Static ring of a solid color.
    case StaticRing = "Static Ring"
    /// Animated ring with a texture.
    case AnimatedRing = "Animated Ring"
    /// Rings that radiate outward from the earthquake.
    case RadiatingRings = "Radiating Rings"
    /// Glowing sphere with a solid color.
    case GlowingSphere = "Glowing Sphere"
    /// Ring of triangles. Triangles point outwards.
    case TriangleRingOut = "Triangle Ring Outward"
    /// Ring of triangles. Triangles point inwards.
    case TriangleRingIn = "Triangle Ring Inward"
}

/// Ways to view earthquake magnitudes.
enum EarthquakeMagnitudeViews: String, CaseIterable
{
    /// Do not show magnitudes.
    case No = "Not Shown"
    /// Magnitudes are roughly parallel with the surface of the Earth.
    case Horizontal = "HorizontalMagnitude"
    /// Magnitudes are perpendicular to the surface of the Earth.
    case Vertical = "VerticalMagnitude"
    /// Magnitudes are stenciled onto the surface of the map.
    case Stenciled = "Stenciled"
}

///Types of earthquake indicators for 2D mode.
enum EarthquakeIndicators2D: String, CaseIterable
{
    /// No indicator.
    case None = "None"
    /// Static ring of a solid color.
    case Ring = "Ring"
}

/// Determines how earthquakes with related earthquakes are sorted. This affects only the earthquake
/// and its related quakes, not full lists of earthquakes.
enum MultipleQuakeOrders: CaseIterable
{
    /// Earthquakes are not ordered.
    case Unordered
    /// The parent earthquake is the earliest earthquake.
    case ByEarliestDate
    /// The parent earthquake has the greatest magnitude.
    case ByGreatestMagnitude
}

/// Definitions of "recent" earthquakes.
enum EarthquakeRecents: String, CaseIterable
{
    /// Twelve hours old.
    case Day05 = "Last 12 Hours"
    /// One day old.
    case Day1 = "Last 24 Hours"
    /// Two days old.
    case Day2 = "Last 48 Hours"
    /// Three days old.
    case Day3 = "Last 72 Hours"
    /// Seven days old.
    case Day7 = "Last Week"
    /// Ten days old.
    case Day10 = "Last 10 Days"
}

/// Textures to use for earthquake indicators that use textures.
enum EarthquakeTextures: String, CaseIterable
{
    case Gradient1 = "Simple Gradient"
    case Gradient2 = "Three-color Gradient"
    case DiagonalLines = "Diagonal Lines"
    case TransparentDiagonalLines = "Transparent Diagonals"
    case Checkerboard = "Black/White Checkerboard"
    case CheckerBoardTransparent = "Black/Transparent Checkerboard"
    case RedCheckerboard = "Red/Transparent Checkerboard"
    case SolidColor = "Solid Color"
}

/// Styles of listing earthquakes.
enum EarthquakeListStyles: String, CaseIterable
{
    /// All earthquakes are listed individually.
    case Individual = "Individual"
    /// Earthquakes are clustered together.
    case Clustered = "Clustered"
}

/// Stencil type classes for the stencil layer in 3D mode.
enum StencilTypes: String, CaseIterable
{
    /// Earthquake magnitude values.
    case EarthquakeMagnitudes = "EarthquakeMagnitudes"
    /// City names.
    case CityNames = "CityNames"
    /// Earth grid lines.
    case GridLines = "GridLines"
    /// User-defined regions.
    case UserRegions = "UserRegions"
}

/// Setting groups for the main settings.
/// - Note: The order in which the cases are defined will apply to the list of setting
///         options in the settings window. In other words, the order here defines what
///         the user will see.
enum SettingGroups: String, CaseIterable
{
    /// Map selection window.
    case Maps = "Select Map"
    /// 2D map view settings.
    case Map2D = "2D Map Settings"
    /// 3D map view settings.
    case Map3D = "3D Map Settings"
    /// User location settings.
    case UserLocation = "User Location"
    /// City settings.
    case Cities = "City Settings"
    /// Other location settings.
    case OtherLocations = "Other Locations"
    /// General miscellaneous settings.
    case Other = "Other Settings"
    /// Earthquake live view settings.
    case Earthquakes = "Earthquake Settings"
    /// Settings for controlling performance.
    case PerformanceSettings = "Performance Settings"
    /// See the current environment.
    case Environment = "Environment"
#if DEBUG
    /// Settings for controlling debugging.
    case DebugSettings = "Debug Settings"
#endif
}

/// Time states for debugging
enum TimeControls: String, CaseIterable
{
    case Run = "Run"
    case Pause = "Pause"
}

/// Layer names for 2D mode.
enum LayerNames: String, CaseIterable
{
    /// Earthquake display layer.
    case Earthquakes = "Earthquake Layer"
    /// Single, plotted earthquake.
    case Earthquake = "Plotted Earthquake"
    /// Grid layer.
    case Grid = "View Grid"
    /// Prime meridian layer.
    case PrimeMeridian = "Prime Meridian"
    /// User-defined locations.
    case UserLocation = "User Location"
    /// Plotted city layer.
    case PlottedCity = "Plotted City"
    /// Layer that holds plotted cities.
    case CityLayer = "City Layer"
}

/// Projection modes for Flatland's camera system.
enum CameraProjections: String, CaseIterable
{
    /// Perspective projection.
    case Perspective = "Perspective"
    /// Orthographic projection.
    case Orthographic = "Orthographic"
}

/// 3D view node names.
enum GlobeNodeNames: String, CaseIterable
{
    /// Nodes related to earthquakes.
    case EarthquakeNodes = "EarthquakeNodes"
    /// Node that marks the home location.
    case HomeNode = "HomeNode"
    /// Node used to draw an hour.
    case HourNode = "HourNode"
    /// Node used to indicate recent earthquakes.
    case IndicatorNode = "IndicatorNode"
    /// Built-in camera node.
    case BuiltInCameraNode = "BuiltInCameraNode"
    /// Flatland camera node.
    case FlatlandCameraNode = "FlatlandCameraNode"
    /// City nodes.
    case CityNode = "CityNode"
    /// Known location nodes.
    case KnownLocation = "KnownLocation"
    /// Mouse indicator node.
    case MouseIndicator = "MouseIndicator"
    /// Node used to show a region.
    case RegionNode = "RegionNode"
    /// Node used to show a transient region.
    case TransientRegionNode = "TransientRegionNode"
    /// Node used to show a pinned location.
    case PinnedLocationNode = "PinnedLocationNode"
    /// Node used to indicate a previously searched location.
    case SearchedLocationNode = "SearchedLocationNode"
    /// Info node.
    case InfoNode = "InfoNode"
    /// Node for city names.
    case CityNameNode = "CityNameNode"
    /// Node for earthquake magnitude nodes.
    case MagnitudeNode = "MagnitudeNode"
    /// Nodes that represent points of interest.
    case POI = "POI"
}

/// 2D view node names.
enum NodeNames2D: String, CaseIterable
{
    /// Hour text nodes.
    case HourNodes = "HourNode"
    /// Nodes in the grid.
    case GridNodes = "GridNode"
    /// The hour plane.
    case HourPlane = "HourPlane"
    /// Location (cities, etc) plane.
    case LocationPlane = "LocationPlane"
    /// A city on the location plane.
    case CityNode = "CityNode"
    /// Earthquake plane.
    case EarthquakePlane = "EarthquakePlane"
    /// World heritage site plane.
    case UnescoPlane = "UnescoPlane"
    /// World heritage site node.
    case WorldHeritageSite = "WorldHeritageSite"
    /// Home location node.
    case HomeNode = "HomeNode"
    /// User points of interest locations.
    case UserPOI = "UserPOI"
    /// Earthquake nodes.
    case Earthquake = "Earthquake"
    /// The sun node.
    case Sun = "Sun"
    /// The mouse follow plane.
    case FollowPlane = "FollowPlane"
    /// The grid layer.
    case GridLayer = "GridLayer"
}

/// Shapes for earthquakes in 2D mode.
enum QuakeShapes2D: String, CaseIterable
{
    /// Non-inverted cone
    case Cone = "Cone"
    /// Inverted cone.
    case InvertedCone = "Inverted Cone"
    /// Spiky cone.
    case SpikyCone = "Spiky Cone"
    /// Flat circle.
    case Circle = "Circle"
    /// Flat star.
    case Star = "Star"
    /// Pyramid.
    case Pyramid = "Pyramid"
}

/// Where notifications appear.
enum NotificationLocations: String, CaseIterable
{
    /// Notifications appear in the system's notification center. On Macs, if Flatland has
    /// focus, no notification will appear on the system (but will be logged).
    case NotificationCenter = "System"
    /// Use Flatland's notification system.
    case Flatland = "Flatland"
    /// Use both Flatland's and the system's notification center.
    case Both = "Both"
}

enum StartupTasks: String, CaseIterable
{
    case Initialize = "Initialization"
    case UIInitialize = "UI Iniatilization"
    case LoadNASATiles = "Fetching Image Tiles"
    case LoadUSGSQuakes = "Fetching USGS Earthquakes"
}

/// Constants for environmental variables.
enum EnvironmentVars: String, CaseIterable
{
    /// Value that determines whether to enable or disable downloading images from NASA.
    case SatelliteMaps = "enable_nasa_tiles"
    /// Value that determines whether to enable or disable barcode generation for earthquakes.
    case QuakeBarcodes = "enable_earthquake_barcodes"
}

/// Small set of relative sizes.
enum RelativeSizes: String, CaseIterable
{
    /// Something is small.
    case Small = "Small"
    /// Something is medium.
    case Medium = "Medium"
    /// Something is large.
    case Large = "Large"
}

/// Layers for the globe view.
enum GlobeLayers: String, CaseIterable
{
    /// Grid lines.
    case GridLines = "GridLines"
    /// City names.
    case CityNames = "CityNames"
    /// Earthquake magnitudes.
    case Magnitudes = "Magnitudes"
    /// World heritage sites.
    case WorldHeritageSites = "WorldHeritageSites"
    /// General purpose lines.
    case Lines = "Lines"
    /// Rectangular regions.
    case Regions = "Regions"
#if true
    /// Test layer.
    case Test = "Test"
#endif
}

/// Names for lights.
enum LightNames: String, CaseIterable
{
    /// Ambient light for the 3D globe scene.
    case Ambient3D = "Ambient 3D"
    /// Sun node for the 3D globe scene.
    case Sun3D = "Sun 3D"
    /// Metallic sun node for the 3D globe scene.
    case SunMetallic3D = "Sun Metallic 3D"
    /// Moon node for the 3D globe scene.
    case Moon3D = "Moon 3D"
    /// Metallic moon node for the 3D globe scene.
    case MoonMetallic3D = "Moon Metallic 3D"
    /// Grid 1 light for the 3D globe scene.
    case Grid13D = "Grid 1 3D"
    /// Grid 2 light for the 3D globe scene.
    case Grid23D = "Grid 2 3D"
    /// Ambient light for the 2D scene.
    case Ambient2D = "Ambient 2D"
    /// Ambient light for the sun in the 2D scene.
    case AmbientSun2D = "Ambient Sun 2D"
    /// Sun light for the 2D scene.
    case Sun2D = "Sun 2D"
    /// Hour light for the 2D scene.
    case Hour2D = "Hour 2D"
    /// Polar light for the 2D scene.
    case Polar2D = "Polar"
}

/// Debug map types.
enum Debug_MapTypes: String, CaseIterable
{
    /// The rectangular map.
    case Rectangular = "Rectangular"
    /// The flat round map (either orientation).
    case Round = "Round"
    /// The globe map.
    case Globe = "Globe"
}

/// Used to display (or hide) debug axes.
enum DebugAxes: String, CaseIterable
{
    /// The X axis display.
    case X = "X"
    /// The Y axis display.
    case Y = "Y"
    /// The Z axis display.
    case Z = "Z"
}

/// Pipeline stages for stenciling.
enum StencilStages: String, CaseIterable
{
    /// Earthquake magnitude stencils.
    case Earthquakes = "Earthquakes"
    /// Earthquake region stencils.
    //case EarthquakeRegions = "EarthquakeRegions"
    /// City name stencils.
    case CityNames = "CityNames"
    /// Grid line stencils.
    case GridLines = "GridLines"
    /// UNESCO site stencils.
    case UNESCOSites = "UNESCOSites"
}

/// Defines the node usage for 3D shapes on maps.
enum NodeUsages: String, CaseIterable
{
    /// Generic, unspecified node.
    case Generic = "Generic"
    /// Nodes used to display 3D hour text.
    case HourText = "HourText"
    /// Non-hour 3D text nodes.
    case TextNodes = "TextNodes"
    /// 3D grid lines.
    case GridLines = "GridLines"
    /// Earthquake nodes.
    case Earthquake = "Earthquake"
    /// New earthquake indicator nodes.
    case EarthquakeIndicator = "EarthquakeIndicator"
    /// UNESCO site nodes.
    case UNESCOSite = "UNESCOSite"
    /// City nodes.
    case City = "City"
    /// Points of interest nodes.
    case POI = "POI"
    /// User-defined points of interest nodes.
    case UserPOI = "UserPOI"
    /// Home nodes.
    case Home = "Home"
    /// Satellite nodes.
    case Satellite = "Satellite"
}

/// Scene jittering types.
enum SceneJitters: String, CaseIterable
{
    /// No scene jittering.
    case None = "None"
    /// 2x scene jittering.
    case Jitter2X = "Jitter2X"
    /// 4x scene jittering.
    case Jitter4X = "Jitter4X"
    /// 8x scene jittering.
    case Jitter8X = "Jitter8X"
    /// 16x scene jittering.
    case Jitter16X = "Jitter16X"
}

/// Valid and known input units.
enum InputUnits: String, CaseIterable
{
    /// Units are kilometers.
    case Kilometers = "Kilometers"
    /// Units are miles.
    case Miles = "Miles"
}

/// Interface style levels.
enum InterfaceStyles: String, CaseIterable
{
    /// Minimal for low-powered systems.
    case Minimal = "Minimal"
    /// Normal for most systems.
    case Normal = "Normal"
    /// Maximum for over-powered systems.
    case Maximum = "Maximum"
}

/// Relative sizes for 3D map nodes.
enum MapNodeScales: String, CaseIterable
{
    /// Small-sized nodes.
    case Small = "Small"
    /// Normal-sized nodes.
    case Normal = "Normal"
    /// Large-sized nodes.
    case Large = "Large"
}

/// Pointer types for the mouse over maps.
enum MousePointerTypes: String, CaseIterable
{
    /// Normal pointer (a 3D shape, not an arrow).
    case Normal = "Normal"
    /// Starting pin for creating regions.
    case StartPin = "StartPin"
    /// Ending pin for ending region creation.
    case EndPin = "EndPin"
}

/// Time period units.
enum TimePeriodUnits: String, CaseIterable
{
    /// Seconds.
    case Seconds = "Seconds"
    /// Minutes.
    case Minutes = "Minutes"
    /// Hours
    case Hours = "Hours"
}

/// Pre-defined camera locations intended to be used only for debugging.
enum CameraLocations: String, CaseIterable
{
    /// Noon longitude.
    case Noon = "Noon"
    /// User's home location.
    case Home = "Home"
    /// North pole.
    case NorthPole = "North Pole"
    /// South pole.
    case SouthPole = "South Pole"
    /// 0N, 0E
    case L00 = "0,0"
    /// 0N, 90E
    case L090 = "0,90"
    /// 0N, 180E
    case L0180 = "0,180"
    /// 0N, -90W
    case L0270 = "0,-90"
}

enum POITypes2: Int, CaseIterable
{
    case GeographicalPoint = 0
    case Mountain = 1
    case Lake = 2
    case Miscellaneous = 3
    case Valley = 4
    case River = 5
    case Forest = 6
    case Island = 7
    case Volcano = 8
    case Desert = 9
    case Plain = 10
    case Plateau = 11
    case Park = 1000
    case AmusementPark = 1001
    case Capitol = 1002
    case Historical = 1003
}

/// Color picker channels supported.
enum PickerColorChannels: String, CaseIterable
{
    case Red = "Red"
    case Green = "Green"
    case Blue = "Blue"
    case Hue = "Hue"
    case Saturation = "Saturation"
    case Brightness = "Brightness"
    case Cyan = "Cyan"
    case Magenta = "Magenta"
    case Yellow = "Yellow"
    case Black = "Black"
    case Alpha = "Alpha"
}
/*
/// Types of hour labels.
enum HourValueTypes: String, CaseIterable
{
    /// No hour labels.
    case None = "NoHours"
    /// Noon always at solar noon.
    case Solar = "RelativeToSolar"
    /// Hours relative to noon (eg, + or - hours away from solar noon).
    case RelativeToNoon = "RelativeToNoon"
    /// Hours relative to set location. Not used if the user does not set a
    /// location.
    case RelativeToLocation = "RelativeToLocation"
    /// Time is the wall clock time at every 15°.
    case WallClock = "WallClock"
}
*/
