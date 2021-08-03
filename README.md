# Flatland (Mobile)

## **Legal**

For now, Flatland is copyrighted.

Copyright © 2020, 2021 Stuart Rankin
 
## **Introduction**

This is a mobile-only version of Flatland. Originally, Flatland was written to be on iPads only. Difficultly in debug led me to rewrite it for the desktop. That led to many changes but facilitated debugging significantly. 

Later, I decided to rewrite the desktop version and port it back to mobile, this time including iPhones. Originally, I used SwiftUI but ran into the typical beta software issues and replaced the SwiftUI code with UIKit and storyboards (which took only a few hours - I significantly simplified the mobile interface compared to the desktop interface).

Converting the code consisted of mostly removing code that didn't make sense on a mobile platform, a great deal of global string replacements (eg, `NSColor` to `UIColor`), and changing Core Graphics API calls that were different from the desktop version (which uses AppKit).

(I didn't write the desktop version with Catalyst given the current limitations and difficulty in use of native desktop facilities. If I had used Catalyst, there would have been minimal if no porting required but Flatland on the desktop would look not as good as it does now.)

(Flatland was started in early 2020, far earlier than the M1-based Macs and so no testing was done to see how the initial (and now abandoned) mobile version would look running on a Mac.)

## **Purpose**

There are two reasons I wrote Flatland: 
1. As an exercise for me to better learn SceneKit and 3D scenes in general with macOS/iOS. As a way to learn a little about making remote API calls. A way to learn more about graphics processing on Macs and iPhones.
1. The initial reason was to have a simple to use but nice to look at tool that let me know the relative times for my friends in various parts of the world.

## **High Level Description**

The primary funcationality of Flatland is dedicated to showing day and night on various types of maps of the Earth. Currently, these types of maps are supported:

1. Equirectangular (a standard-looking global map).
1. Circular (essentially warping an equirectangular map into a circle) maps, one for north at the center and one for south at the center.
1. 3D globe, which is the most realisitic and makes heavy use of SceneKit capabilities with lighting and the light.
1. Cube, which is included for novelty's sake.

On each map type (including the cube, but the cubical map isn't to be taken too seriously) day and night are shown (along with other features, discussed below). For the 2D maps (actually rendered in 3D but seen by the user as 2D), a pre-generated night mask is used - Flatland has a night mask for each day of the year. for the 3D views, day and night are implemented using lighting effects (with the night-side of the Earth being illuminated by "moonlight").

## **Locations**

While the visual aspect of day and night are critical, equally critical is knowing where people and locations are. Flatland supports the following types of locations:

1. User-defined locations, such as the user's home, friends' locations, and other user-defined POIs.
1. Cities - Flatland includes a database from the UN of the 500 most populous cities on the Earth. Usually, Flatland just displays the 100-most populous cities as the map can get too cluttered with 500 citites.
1. Eventually Flatland will support a set of POIs (once I identify an open-source list of reasonable POIs and add them to a database).
1. UNESCO World Heritage Sites are included in a database that can be plotted. There are currently over 1000 World Heritage Sites so the user can filter them to reduce the graphics load on the mobile device.
1. Earthquakes - Flatland queries the USGS periodically for earthquakes and plots them on the map (whether 2D or 3D). Earthquakes are stored in a separate database due to a large amount of transactions. Earthquakes are limited to how long they are displayed.

## **Maps**

Flatland supports as many maps (provided they are equirectangular, eg, 2:1 aspect ratio) as can be stored on the device and comes with many built-in to the bundle. (Probably too many.) Flatland assumes 180°E is at the right (or left - it doesn't matter) edge of the map image.

If the user zooms in too much to the map, the rasterization of the map image will be readily apparent. On the desktop version, the user can specify a high-resolution map (only one supplied right now) that helps ameliorate this issue. I have not yet tried this with the mobile version yet. (The issue is high resolution images tend to be huge.)

In addition to static maps, Flatland support dynamic maps - specifically maps assembled from NASA imagery of the Earth (near real-time). This (like earthquakes) requires a live internet connection to download the images.

## **Labeling**

Flatland uses two methods to label items:

1. 3D extruded text: Using SceneKit's extruded text geometry, Flatland draws labels that float over the surface of the earth. The standard method for creating this text places the horizontal center perpindicular to the tangent of the Earth where the label is placed. Another method (which is slower) creates curved text to match the surface of the Earth depending on the latitude of the text.
1. Stenciling/decaling the map: Flatland can also draw text directly onto the surface of the image of the map. This has the advantage in performace when the labels don't change often (eg, city names versus earthquake magnitudes) but has the disadvantage of drawing text on images takes a huge amount of time so there is a noticable delay when changing maps.

#### Latitude and Longitude Lines

Stenciling is the default method for drawing latitude and longitude lines on the map. An alternative method exists: Flatland can also create a transparent sphere and draw visible lines on it. This, unfortunately, does not always work as expected given blending mode issues within SceneKit.

> In general, floating, extruded text is used.

## **Shadows**

Flatland has shadows enabled. Unfortunately, either there is a bug in SceneKit or I haven't figured out how to properly enable shadows becuase shadows don't appear correctly until the camera zooms into the Earth very closely.

## **Shapes**

To indicate locations, Flatland uses a variety of user-selectable shapes. Default values are:

1. Cities are shown as a tethered-balloon like shape, with the size of the balloon dependent on the metropolitan population of the city.
2. Earthquakes are shown with a bouncing arrow pointing to the epicenters. Recent (within the last 24 hours) earthquakes are shown with an animation of some type, such as a radially expanding ring.
3. Points of interest are shown as cones on the surface of the Earth.
4. UNESCO World Heritage Sites are shown as small, colored triangles (the color indicating what type of site each is).
5. Poles (the north and south poles) are shown as barber poles (or a flag if the user desires).
6. The user's home location is shown as a special, composite, animated shape.

## **Future Plans**
1. Reach feature level 1, test then submit to the app store.

