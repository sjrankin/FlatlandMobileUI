//
//  SettingKeys.swift
//  SettingKeys
//
//  Created by Stuart Rankin on 7/19/21. Adapted from Flatland View.
//

import Foundation

/// Settings. Each case refers to a single setting and is used
/// by the settings class to access the setting.
enum SettingKeys: String, CaseIterable
{
    // MARK: - Infrastructure/initialization-related settings.
    case InitializationFlag = "InitializationFlag"
    
    // MARK: - Map-related settings.
    /// The type of map to view (the map image). This is used for both 2D and 3D modes
    /// (but not the cubic mode).
    case MapType = "MapType"
    /// Determines the view type - 2D (one of two types) or 3D (one of two types).
    case ViewType = "ViewType"
    /// Boolean: Determines if the night mask is shown in 2D mode.
    case ShowNight = "ShowNight"
    /// Double: The alpha level of the night mask. See `NightDarkness`.
    case NightMaskAlpha = "NightMaskAlpha"
    /// Darkness level that determines the actual alpha level of the night mask. See
    /// `NightMaskAlpha`.
    case NightDarkness = "NightDarkness"
    /// The type of hour to display.
    case HourType = "HourType"
    /// The type of time label to display.
    case TimeLabel = "TimeLabel"
    /// Boolean: Determines whether seconds are shown in the time label.
    case TimeLabelSeconds = "TimeLabelSeconds"
    /// Boolean: Show the sun in 2D mode.
    case ShowSun = "ShowSun"
    /// Determines the script to use for certain display elements.
    case Script = "Script"
    /// The type of sun image to display.
    case SunType = "SunType"
    /// The type of view to show in the sample map image display.
    case SampleViewType = "SampleViewType"
    /// CGSize: The size of the window.
    case WindowSize = "WindowSize"
    /// CGPoint: The origin of the window.
    case WindowOrigin = "WindowOrigin"
    /// CGSize: The size of the primary contents view.
    case PrimaryViewSize = "PrimaryViewSize"
    /// Boolean: If true, earthquake coordinates are decorated with cardinal directions.
    case DecorateEarthquakeCoordinates = "DecorateEarthquakeCoordinates"
    /// Boolean: If true, a status bar is shown.
    case ShowStatusBar = "ShowStatusBar"
    /// Integer: Number of times Flatland has been instantiated for a given version.
    case InstantiationCount = "InstantiationCount"
    /// String: Version used for current instantiation count.
    case InstantiationVersion = "InstantiationVersion"
    
    // MARK: - 2D view settings.
    /// Boolean: Display the equator in 2D mode.
    case Show2DEquator = "Show2DEquator"
    /// Boolean: Display polar circles in 2D mode.
    case Show2DPolarCircles = "Show2DPolarCircles"
    /// Boolean: Display tropic circles in 2D mode.
    case Show2DTropics = "Show2DTropics"
    /// Boolean: Display prime meridians in 2D mode.
    case Show2DPrimeMeridians = "Show2DPrimeMeridians"
    /// Boolean: Display noon meridians in 2D mode.
    case Show2DNoonMeridians = "Show2DNoonMeridians"
    /// Boolean: Display shadows for protruding objects.
    case Show2DShadows = "Show2DShadows"
    /// The shape of earthquakes on the flat map.
    case EarthquakeShape2D = "EarthquakeShape2D"
    /// Boolean: Determines if wall clock seperator shapes are displayed.
    case ShowWallClockSeparators = "ShowWallClockSeparators"
    /// UIColor: Color of primary grid lines in flat view.
    case PrimaryGridLineColor = "PrimaryGridLineColor"
    /// UIColor: Color of secondary grid lines in flat view.
    case SecondaryGridLineColor = "SecondaryGridLineColor"
    /// UIColor: Color of wall clock grid lines in flat view.
    case WallClockGridLineColor = "WallClockGridLineColor"
    
    // MARK: - 3D view settings.
    /// Scale to use for POI 3D objects.
    case POIScale = "POIScale"
    /// Boolean: Display grid lines in 3D mode.
    case Show3DGridLines = "Show3DGridLines"
    /// Boolean: Display the equator in 3D mode.
    case Show3DEquator = "Show3DEquator"
    /// Boolean: Display polar circles in 3D mode.
    case Show3DPolarCircles = "Show3DPolarCircles"
    /// Boolean: Display tropic circles in 3D mode.
    case Show3DTropics = "Show3DTropics"
    /// Boolean: Display prime meridians in 3D mode.
    case Show3DPrimeMeridians = "Show3DPrimeMeridians"
    /// Boolean: Display minor grid lines in 3D mode.
    case Show3DMinorGrid = "Show3DMinorGrid"
    /// Double: Grid gap for minor grid lines in 3D mode.
    case MinorGrid3DGap = "MinorGrid3DGap"
    /// Double: Alpha level for the 3D globe.
    case GlobeTransparencyLevel = "GlobeTransparencyLevel"
    /// Determines how fast stars move when visible.
    case StarSpeeds = "StarSpeeds"
    /// Boolean: Show moonlight on 3D globes for the night side.
    case ShowMoonLight = "ShowMoonLight"
    /// Determines the shape of the object marking the poles.
    case PolarShape = "PolarShape"
#if false
    /// Determines the shape of the object making locations in the user's location list.
    case UserLocationShape = "UserLocationShape"
#endif
    /// Boolean: Reset hour labels periodically. Performance debug option.
    case ResetHoursPeriodically = "ResetHoursPeriodically"
    /// Double: How often to reset hours. Performance debug option.
    case ResetHourTimeInterval = "ResetHourTimeInterval"
    /// UIColor: The color of the 3D background
    case BackgroundColor3D = "BackgroundColor3D"
    /// Boolean: If true, an ambient light (rather than sun and moon lights) is used.
    case UseAmbientLight = "UseAmbientLight"
    /// Boolean: If true, user POI locations show light emission. If false, no emission is used.
    case ShowPOIEmission = "ShowPOIEmission"
    /// Boolean: If true, the 3D view will try to attract people via animation and other effects.
    case InAttractMode = "InAttractMode"
    /// Boolean: If true, the scene's camera is set to HDR mode.
    case UseHDRCamera = "UseHDRCamera"
    /// UIColor: Color of the hours.
    case HourColor = "HourColor"
    /// UIColor: Color of the emission of hours in the night.
    case HourEmissionColor = "HourEmissionColor"
    /// String: Name of the hour font.
    case HourFontName = "HourFontName"
    /// Scale of the extruded 3D hour labels.
    case HourScale = "HourScale"
    /// UIColor: Color of major grid lines.
    case GridLineColor = "GridLineColor"
    /// UIColor: Color of minor grid lines.
    case MinorGridLineColor = "MinorGridLineColor"
    /// CGFloat: User camera field of view.
    case FieldOfView = "FieldOfView"
    /// Double: User camera orthographic scale value.
    case OrthographicScale = "OrthographicScale"
    /// Double: Camera's z-far value.
    case ZFar = "ZFar"
    /// Double: Camera's z-near value.
    case ZNear = "ZNear"
    /// CGFloat: Closest the user is allowed to zoom in.
    case ClosestZ = "ClosestZ"
    /// Integer: Number of sphere segments.
    case SphereSegmentCount = "SphereSegmentCount"
    /// Boolean: If true, grid lines are drawn on the map itself. If false, they are drawn
    /// semi-three dimensionally.
    case GridLinesDrawnOnMap = "GridLineDrawnOnMap"
    /// Boolean: If true, city names are drawn on the map itself. If false, they are drawn
    /// with 3D extruded text.
    case CityNamesDrawnOnMap = "CityNamesDrawnOnMap"
    /// Boolean: If true, earthquake magnitude values are drawn on the map itself. If false,
    /// they are drawn with 3D extruded text.
    case MagnitudeValuesDrawnOnMap = "MagnitudeValuesDrawnOnMap"
    /// UIColor: The color to use to draw earthquake region bords.
    case EarthquakeRegionBorderColor = "EarthquakeRegionBorderColor"
    /// Double: The width of earthquake borders.
    case EarthquakeRegionBorderWidth = "EarthquakeRegionBorderWidth"
    /// Relative size of the font used to stencil city names.
    case CityFontRelativeSize = "CityFontRelativeSize"
    /// Relative size of the font used to stencil magnitude values.
    case MagnitudeRelativeFontSize = "MagnitudeRelativeFontSize"
    /// Boolean: If true, standard NSStrings are used to draw stenciled text. If false,
    /// NSAttributedStrings are used. NSStrings are faster...
    case StencilPlainText = "StencilPlainText"
    /// Boolean: If true, show a barcode next to the magnitude.
    case ShowMagnitudeBarCode = "ShowMagnitudeBarCode"
    // Camera settings.
    /// SCNVector3: Initial position of the camera.
    case InitialCameraPosition = "InitialCameraPosition"
    /// Boolean: If true, `allowsCameraControl` is used to let the user control how the scene
    /// looks. If false, use the camera control implemented in Flatland.
    case UseSystemCameraControl = "UseSystemCameraControl"
    /// Boolean: It true, the user can zoom with Flatland's camera.
    case EnableZooming = "EnableZooming"
    /// Boolean: If true, the user can drag/rotate the scene with Flatland's camera.
    case EnableDragging = "EnableDragging"
    /// Boolean: If true, the user can move/translate the scene with Flatland's camera.
    case EnableMoving = "EnableMoving"
    /// Flatland's camera projection.
    case CameraProjection = "CameraProjection"
    /// CGFloat: The field of view for Flatland's camera system.
    case CameraFieldOfView = "CameraFieldOfView"
    /// Double: The orthographic scale for Flatland's camera system.
    case CameraOrthographicScale = "CameraOrthographicScale"
    /// Boolean: If true, the 3D scenes cannot be moved. If false, they can.
    case WorldIsLocked = "WorldIsLocked"
    /// Boolean: If true, 3D jittering is enabled.
    case EnableJittering = "EnableJittering"
    /// Antialias value.
    case AntialiasLevel = "AntialiasLevel"
    /// Boolean: If true, Flatland will search for what is close to the mouse pointer.
    case SearchForLocation = "SearchForLocation"
    /// Boolean: If true, the mouse will be hidden when it is over the Earth.
    case HideMouseOverEarth = "HideMouseOverEarth"
    //3D debug settings.
    /// Render 3D elements as wireframes.
    case ShowWireframes = "ShowWireframes"
    /// Boolean: Show bounding boxes around 3D elements.
    case ShowBoundingBoxes = "ShowBoundingBoxes"
    /// Boolean: Show skeletons.
    case ShowSkeletons = "ShowSkeletons"
    /// Boolean: Show node constraints.
    case ShowConstraints = "ShowConstraints"
    /// Boolean: Show light influences.
    case ShowLightInfluences = "ShowLightInfluences"
    /// Boolean: Show light extents.
    case ShowLightExtents = "ShowLightExtents"
    /// Boolean: Show rendering statistics.
    case ShowStatistics = "ShowStatistics"
    /// Boolean: Show the camera.
    case ShowCamera = "ShowCamera"
    /// Boolean: Show creases.
    case ShowCreases = "ShowCreases"
    /// Boolean: Show physics shapes.
    case ShowPhysicsShapes = "ShowPhysicsShapes"
    /// Boolean: Show physics fields.
    case ShowPhysicsFields = "ShowPhysicsFields"
    /// Boolean: Render as wireframe.
    case RenderAsWireframe = "RenderAsWireframe"
    /// Boolean: If true, the node under the mouse is highlighted.
    case HighlightNodeUnderMouse = "HighlightNodeUnderMouse"
    /// Determines which map type is affected by the 3D debug flags.
    case Debug3DMap = "Debug3DMap"
    /// Boolean: If true, 3D debugging is enabled.
    case Enable3DDebugging = "Enable3DDebugging"
    /// Boolean: If true, axis markers are shown in 3D debug.
    case ShowAxes = "ShowAxes"
    /// Boolean: If true, known locations are shown on the map.
    case ShowKnownLocations = "ShowKnownLocations"
    /// Boolean: If true, the program name and version will be shown at start-up.
    case ShowInitialVersion = "ShowInitialVersion"
    /// Double: Number of seconds to show the initial version string.
    case InitialVersionDuration = "InitialVersionDuration"
    
    // MARK: - Performance and optimization settings.
    /// Boolean: If true, hours have a chamfer value set.
    case UseHourChamfer = "UseHourChamfer"
    /// Boolean: If true, live data labels have a chamfer value set.
    case UseLiveDataChamfer = "UseLiveDataChamfer"
    /// CGFloat: Determines text smoothness.
    case TextSmoothness = "TextSmoothness"
    
    // MARK: - Local and home locations.
    /// Boolean: Show user locations.
    case ShowUserLocations = "ShowUserLocations"
    /// Integer: Time zone offset for the user's home location.
    case LocalTimeZoneOffset = "LocalTimeZoneOffset"
    /// Determines the shape of the object marking the user's home location.
    case HomeShape = "HomeShape"
    /// String: List of locations created by the user.
    case UserLocations = "UserLocations"
    /// Boolean: Determines if the user's location is shown, regardless if it is available.
    case ShowHomeLocation = "ShowHomeLocation"
    /// UIColor: Color of the home location for shapes that use it.
    case HomeColor = "HomeColor"
    /// String: Name of the location for the Today window for non-home locations.
    case DailyLocationName = "DailyLocationName"
    /// Double?: Latitude of the location for the Today window for non-home locations.
    case DailyLocationLatitude = "DailyLocationLatitude"
    /// Double?: Longitude of the location for the Today window for non-home locations.
    case DailyLocationLongitude = "DailyLocationLongitude"
    /// Boolean: Determines if user POIs are shown.
    case ShowUserPOIs = "ShowUserPOIs"
    /// Secure string: User's home latitude. Will generate a fatal error if used with normal string functions.
    case UserHomeLatitude = "UserHomeLatitude"
    /// Secure string: User's home longitude. Will generate a fatal error if used with normal string functions.
    case UserHomeLongitude = "UserHomeLongitude"
    /// Secure string: Name of user's home. Will generate a fatal error if used with normal string functions.
    case UserHomeName = "UserHomeName"
    /// Boolean: Show or hide built-in POIs.
    case ShowBuiltInPOIs = "ShowBuiltInPOIs"
    
    // MARK: - City-related settings.
    /// Boolean: Show cities on the map. This is a filter boolean meaning if it is false,
    /// no cities will be shown regardless of their settings.
    case ShowCities = "ShowCities"
    /// Boolean: Show custom cities.
    case ShowCustomCities = "ShowCustomCities"
    /// Boolean: Show African cities.
    case ShowAfricanCities = "ShowAfricanCities"
    /// Boolean: Show Asian cities.
    case ShowAsianCities = "ShowAsianCities"
    /// Boolean: Show European cities.
    case ShowEuropeanCities = "ShowEuropeanCities"
    /// Boolean: Show North American cities.
    case ShowNorthAmericanCities = "ShowNorthAmericanCities"
    /// Boolean: Show South American cities.
    case ShowSouthAmericanCities = "ShowSouthAmericanCities"
    /// Boolean: Show national capital cities.
    case ShowCapitalCities = "ShowCapitalCities"
    /// Boolean: Show all cities (very slow).
    case ShowAllCities = "ShowAllCities"
    /// Boolean: Show world cities.
    case ShowWorldCities = "ShowWorldCities"
    /// UIColor: Color to use for African cities.
    case AfricanCityColor = "AfricanCityColor"
    /// UIColor: Color to use for Asian cities.
    case AsianCityColor = "AsianCityColor"
    /// UIColor: Color to use for European cities.
    case EuropeanCityColor = "EuropeanCityColor"
    /// UIColor: Color to use for North American cities.
    case NorthAmericanCityColor = "NorthAmericanCityColor"
    /// UIColor: Color to use for South American cities.
    case SouthAmericanCityColor = "SouthAmericanCityColor"
    /// UIColor: Color to use for capital cities.
    case CapitalCityColor = "CapitalCityColors"
    /// UIColor: Color to use for world cities.
    case WorldCityColor = "WorldCityColors"
    /// UIColor: Color to use for custom cities.
    case CustomCityListColor = "CustomCityListColor"
    /// UIColor: Determines the shape of cities.
    case CityShapes = "CityShapes"
    /// Determines how the relative size of cities is calculated.
    case PopulationType = "PopulationType"
    /// The font to use for city names.
    case CityFontName = "CityFontName"
    /// List of user-customized cities.
    case CustomCityList = "CustomCityList"
    /// Boolean: City nodes glow if applicable.
    case CityNodesGlow = "CityNodesGlow"
    /// Boolean: Cities by population rank.
    case ShowCitiesByPopulation = "ShowCitiesByPopulation"
    /// Integer: Population rank count.
    case PopulationRank = "PopulationRank"
    /// Boolean: Use metropolitan population for ranking cities.
    case PopulationRankIsMetro = "PopulationRankIsMetro"
    /// Int: Population value to compare against the city list.
    case PopulationFilterValue = "PopulationFilterValue"
    /// Boolean: Determines how `PopulationFilterValue` is used.
    case PopulationFilterGreater = "PopulationFilterGreater"
    /// UIColor: The color for population-filtered cities.
    case PopulationColor = "PopulationColor"
    /// How to filter by city population.
    case PopulationFilterType = "PopulationFilterType"
    /// Table of cities from the mappable database.
    case CityList = "CityList"
    /// Table of user cities from the mappable database.
    case UserCityList = "UserCityList"
    /// Boolean: If true, 3D city names cast shadows.
    case ExtrudedCitiesCastShadows = "ExtrudedCitiesCastShadows"
    /// Boolean: If true, 3D floating hours cast shadows.
    case HoursCastShadows = "HoursCastShadows"
    
    // MARK: - World Heritage Site settings
    /// Boolean: Determines whether World Heritage Sites are shown.
    case ShowWorldHeritageSites = "ShowWorldHeritageSites"
    /// Determines the type of site to display.
    case WorldHeritageSiteType = "WorldHeritageSiteType"
    /// County filter for World Heritage Sites.
    case SiteCountry = "SiteCountry"
    /// Inclusion year for sites.
    case SiteYear = "SiteYear"
    /// Inclusion year filter for sites.
    case SiteYearFilter = "SiteYearFilter"
    /// Boolean: If true, sites are plotted on the stencil layer. If false, sites are plotted as 3D objects.
    case PlotSitesAs2D = "PlotSitesAs2D"
    
    // MARK: - Earthquake settings.
    //Earthquake asynchronous settings.
    /// Double: How often, in seconds, to fetch earthquake data.
    case EarthquakeFetchInterval = "EarthquakeFetchInterval"
    /// Boolean: Determines if remote earthquake data is fetched.
    case EnableEarthquakes = "EnableEarthquakes"
    /// How to modify the base color on a per-earthquake basis.
    case ColorDetermination = "ColorDetermination"
    /// UIColor: The base earthquake color.
    case BaseEarthquakeColor = "BaseEarthquakeColor"
    /// How to draw the earthquake.
    case EarthquakeShapes = "EarthquakeShapes"
    /// Boolean: Display only the largest earthquake in a region.
    case DisplayLargestOnly = "DisplayLargestOnly"
    /// Double: Radius for earthquake regions to determine when to suppress smaller
    /// earthquakes when `DisplayLargestOnly` is true.
    case EarthquakeRegionRadius = "EarthquakeRegionRadius"
    /// String: List of colors for various earthquake magnitudes.
    case EarthquakeMagnitudeColors = "EarthquakeMagnitudeColors"
    /// Determines how to list earthquakes.
    case EarthquakeListStyle = "EarthquakeListStyle"
    /// Boolean: Highlight recent earthquakes.
    case HighlightRecentEarthquakes = "HighlightRecentEarthquakes"
    /// The age an earthquake must be to be considered "recent."
    case RecentEarthquakeDefinition = "RecentEarthquakeDefinition"
    /// Texture to use for earthquake indicators that use textures.
    case EarthquakeTextures = "EarthquakeTextures"
    /// Earthquake indicator style.
    case EarthquakeStyles = "EarthquakeStyles"
    /// Earthquake indicator style for 2D earthquakes.
    case Earthquake2DStyles = "Earthquake2DStyles"
    /// Earthquake indicator color for indicators that use colors.
    case EarthquakeColor = "EarthquakeColor"
    /// String: Name of the font to use to display earthquake magnitudes.
    case EarthquakeFontName = "EarthquakeFontName"
    /// Age of earthquakes to view in the earthquake list dialog.
    case EarthquakeListAge = "EarthquakeListAge"
    /// Integer: Minimum magnitude earthquake to display in the earthquake list dialog.
    case EarthquakeDisplayMagnitude = "EarthquakeDisplayMagnitude"
    /// Age of earthquakes to view in the earthquake list dialog. Intended for the group view.
    case GroupEarthquakeListAge = "GroupEarthquakeListAge"
    /// Integer: Minimum magnitude earthquake to display in the earthquake list dialog. Intended
    /// for the group view.
    case GroupEarthquakeDisplayMagnitude = "GroupEarthquakeDisplayMagnitude"
    /// String: List of cached earthquakes.
    case CachedEarthquakes = "CachedEarthquakes"
    /// Determines the scale of 3D nodes used as earthquake indicators.
    case QuakeScales = "QuakeScales"
#if false
    /// Maximum distance (in kilometers) that earthquakes must be to be combined.
    case CombineDistance = "CombineDistance"
#endif
    /// How (or if) to display earthquake magnitude values.
    case EarthquakeMagnitudeViews = "EarthquakeMagnitudeViews"
    /// UIColor: The color of the bars that indicate a combined earthquake.
    case CombinedEarthquakeColor = "CombinedEarthquakeColor"
    /// String: Contains all regions monitored for a set of earthquake parameters.
    /// - Warning: Do not access this setting directly.
    /// - Note: See also `GetEarthquakeRegions` and `SetEarthquakeRegions`.
    case EarthquakeRegions = "EarthquakeRegions"
    /// Boolean: Enables the visibility of 2D earthquake regions.
    case ShowEarthquakeRegions = "ShowEarthquakeRegions"
    /// Double: Minimum value that earthquakes must be to be included in any list.
    case GeneralMinimumMagnitude = "GeneralMinimumMagnitude"
    /// Double: Use for earthquake table for regions. Radius of the region from which
    ///         quakes are reported.
    case QuakeRegionRadius = "QuakeRegionRadius"
    /// Double: Latitude of the center of the quake region for earthquake tables.
    case QuakeRegionLatitude = "QuakeRegionLatitude"
    /// Double: Longitude of the center of the quake region for earthquake tables.
    case QuakeRegionLongitude = "QuakeRegionLongitude"
    /// Bool: Enable quake regions in the earthquake table.
    case QuakeRegionEnable = "QuakeRegionEnable"
    /// Bool: If true all quakes will be shown in the regional set. Otherwise the current
    ///       filter will be used.
    case QuakeSetAll = "QuakeSetAll"
    /// Boolean: If true, tiles from NASA servers are preloaded. Otherwise, they are not
    ///          loaded until the user requires them.
    case PreloadNASATiles = "PreloadNASATiles"
    /// List of earthquakes the use was notified about. Used to prevent excessive notifications.
    case NotifiedEarthquakes = "NotifiedEarthquakes"
    /// Where notifications appear.
    case NotifyLocation = "NotifyLocation"
    
    // MARK: - NASA tiles settings.
    /// Boolean: Set according to the environment variable "enable_nasa_tiles". Not user
    ///          accessible. If "enable_nasa_tiles" is not present, true is put into this
    ///          settings.
    case EnableNASATiles = "EnableNASATiles"
    /// Int: Hours between tile fetching.
    case NASATilesFetchInterval = "NASATilesFetchInterval"
    /// Double?: Last time tiles were fetched from NASA.
    case LastNASAFetchTime = "LastNASAFetchTime"
    
    // MARK: - General settings.
    /// The last settings viewed by the user.
    case LastSettingsViewed = "LastSettingsViewed"
    /// Boolean: Determines if the splash screen is shown on start-up.
    case ShowSplashScreen = "ShowSplashScreen"
    /// Double: Amount of time the splash screen is shown, in seconds.
    case SplashScreenDuration = "SplashScreenDuration"
    /// Boolean: If true, details of geographic nodes are shown. If false, nothing is shown.
    case ShowDetailedInformation = "ShowDetailedInformation"
    /// Boolean: If true, the mouse is tracked in map views.
    case FollowMouse = "FollowMouse"
    
    // MARK: - Time debug settings.
    /// Boolean: Enables debugging of time.
    case DebugTime = "DebugTime"
    /// Controls whether time is running or paused.
    case TimeControl = "TimeControl"
    /// Starting time one time resumes.
    case TestTime = "TestTime"
    /// Time will stop advancing once this time is reached.
    case StopTimeAt = "StopTimeAt"
    /// Double: Value to multipy time by.
    case TimeMultiplier = "TimeMultiplier"
    /// Boolean: Enables or disables the stop time.
    case EnableStopTime = "EnableStopTime"
    
    // MARK: - General debug settings
    /// Boolean: Enable clock control
    case Debug_EnableClockControl = "Debug_EnableClockControl"
    /// Determines which map type is affected by the debug.
    case Debug_ClockDebugMap = "Debug_ClockDebugMap"
    /// Boolean: Freeze the clock.
    case Debug_ClockActionFreeze = "Debug_ClockActionFreeze"
    /// Boolean: Freeze the clock at the specified time.
    case Debug_ClockActionFreezeAtTime = "Debug_ClockActionFreezeAtTime"
    /// Date: When to freeze the clock (only the time component is used).
    case Debug_ClockActionFreezeTime = "Debug_ClockActionFreezeTime"
    /// Boolean: Set the clock angle.
    case Debug_ClockActionSetClockAngle = "Debug_ClockActionSetAngle"
    /// Double: New clock angle.
    case Debug_ClockActionClockAngle = "Debug_ClockActionClockAngle"
    /// Boolean: Use clock multiplier.
    case Debug_ClockUseTimeMultiplier = "Debug_ClockUseTimeMultiplier"
    /// Double: Clock time multiplier.
    case Debug_ClockActionClockMultiplier = "Debug_ClockActionClockMultiplier"
    
    // MARK: - Input/local settings.
    /// Determines the default input unit.
    case InputUnit = "InputUnit"
    
    // MARK: - Interface settings.
    /// Determines how fancy the interface is.
    case InterfaceStyle = "InterfaceStyle"
    #if false
    /// Determines the numeric input type for color channels.
    case ColorInputType = "ColorInputType"
    /// The last selected colorspace for the color picker.
    case ColorPickerColorspace = "ColorPickerColorspace"
    #endif
    /// Boolean: Show or hide UI help buttons ("􀁝").
    case ShowUIHelp = "ShowUIHelp"
    
    // MARK: - Event and sound settings
    /// Boolean: Determines if sounds are globally enabled.
    case EnableSounds = "EnableSounds"
    /// Boolean: Determines if hour chiming is enable.
    case EnableHourEvent = "EnableHourEvent"
    /// Boolean: If true, a mute period is observed every day.
    case EnableMutePeriod = "EnableMutePeriod"
    /// Integer: Start of mute period in seconds since midnight.
    case MutePeriodStart = "MutePeriodStart"
    /// Integer: Duration of mute period in seconds since start of period.
    case MutePeriodDuration = "MutePeriodDuration"
    /// Time units for period duration.
    case MutePeriodTimeUnits = "MutePeriodTimeUnits"
    
    // MARK: - Settings that interface with the database.
    /// [City2]: List of built-in cities.
    case DB_Cities = "DB_Cities"
    /// [City2]: List of user cities.
    case DB_UserCities = "DB_UserCities"
    /// [POI2]: List of built-in POIs.
    case DB_BuiltInPOIs = "DB_BuiltInPOIs"
    /// [POI2]: List of user POIs.
    case DB_UserPOIs = "DB_UserPOIs"
    /// [POI2]: List of homes specified by the user.
    case DB_Homes = "DB_Homes"
    /// [WorldHeritageSite]: List of UNESCO world heritage sites.
    case DB_WorldHeritageSites = "DB_WorldHeritageSites"
    
    // MARK: - Settings used to trigger events.
    /// Integer: New memory measurement available.
    case Trigger_MemoryMeasured = "Tigger_MemoryMeasured"
    
    // MARK: - Settings used in areas outside of the Settings system.
    /// Live data viewer.
    case LiveViewWindowFrame = "LiveViewWindowFrame"
    /// Earthquake data viewer.
    case EarthquakeViewWindowFrame = "EarthquakeViewWindowFrame"
}
