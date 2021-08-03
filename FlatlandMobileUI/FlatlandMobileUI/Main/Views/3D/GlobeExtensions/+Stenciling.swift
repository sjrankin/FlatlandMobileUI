//
//  +Stenciling.swift
//  Flatland
//
//  Created by Stuart Rankin on 9/21/20.
//  Copyright © 2020 Stuart Rankin. All rights reserved.
//

import Foundation
import UIKit
import SceneKit

extension GlobeView
{
    // MARK: - Surface stenciling
    
    /// Apply stencils to `GlobalBaseMap` as needed. Stenciled images returned via the `StencilPipelineProtocol`.
    /// - Notes:
    ///    - Control returns almost immediately.
    ///    - The user can change settings such that no stenciling is applied. In that case,
    ///      the non-stenciled map will be available very quickly.
    ///    - All stencils are applied here (assuming they are enabled by the user).
    /// - Parameter Caller: Name of the caller.
    func ApplyAllStencils(Caller: String)
    {
        #if true
        Debug.Print("ApplyAllStencils(\(Caller))")
        if let Map = GlobalBaseMap
        {
            let NewMap = Stenciler.AddGridLines(To: Map, Ratio: 1.0)
            InitialStenciledMap = NewMap
            OperationQueue.main.addOperation
            {
                self.EarthNode?.geometry?.firstMaterial?.diffuse.contents = NewMap
            }
        }
        else
        {
            Debug.Print("No global base map available.")
        }
        #else
        if let Map = GlobalBaseMap
        {
            var Quakes: [Earthquake]? = nil
            var Stages = [StencilStages]()
            if Settings.GetBool(.MagnitudeValuesDrawnOnMap)
            {
                Stages.append(.Earthquakes)
                Quakes = EarthquakeList
            }
            if Settings.GetBool(.ShowWorldHeritageSites) && Settings.GetBool(.PlotSitesAs2D)
            {
                Stages.append(.UNESCOSites)
            }
            if Settings.GetBool(.CityNamesDrawnOnMap)
            {
                Stages.append(.CityNames)
            }
            if Settings.GetBool(.GridLinesDrawnOnMap)
            {
                Stages.append(.GridLines)
            }
            Stenciler.RunStencilPipeline(To: Map, Quakes: Quakes, Stages: Stages, Caller: self)
        }
        else
        {
            Debug.Print("No global base map available.")
        }
        #endif
    }
    
    /// Apply stencils to `GlobalBaseMap` as needed. Stenciled images returned via the `StencilPipelineProtocol`.
    /// - Notes:
    ///    - Control returns almost immediately.
    ///    - The user can change settings such that no stenciling is applied. In that case,
    ///      the non-stenciled map will be available very quickly.
    ///    - All stencils are applied here (assuming they are enabled by the user).
    /// - Parameter Except: Array of exceptions to stenciling stages - if a stage is in this array, it will
    ///                     *not* be stenciled.
    /// - Parameter Caller: Name of the caller.
    func ApplyAllStencils(Except: [StencilStages], Caller: String? = nil)
    {
        #if true
        if let Map = GlobalBaseMap
        {
            let NewMap = Stenciler.AddGridLines(To: Map, Ratio: 1.0)
            InitialStenciledMap = NewMap
            OperationQueue.main.addOperation
            {
                self.EarthNode?.geometry?.firstMaterial?.diffuse.contents = NewMap
            }
        }
        #else
        if let Map = GlobalBaseMap
        {
            var Quakes: [Earthquake]? = nil
            var Stages = [StencilStages]()
            if !Except.contains(.Earthquakes)
            {
                if Settings.GetBool(.MagnitudeValuesDrawnOnMap)
                {
                    Stages.append(.Earthquakes)
                    Quakes = EarthquakeList
                }
            }
            if !Except.contains(.UNESCOSites)
            {
                if Settings.GetBool(.ShowWorldHeritageSites) && Settings.GetBool(.PlotSitesAs2D)
                {
                    Stages.append(.UNESCOSites)
                }
            }
            if !Except.contains(.CityNames)
            {
                if Settings.GetBool(.CityNamesDrawnOnMap)
                {
                    Stages.append(.CityNames)
                }
            }
            if !Except.contains(.GridLines)
            {
                if Settings.GetBool(.GridLinesDrawnOnMap)
                {
                    Stages.append(.GridLines)
                }
            }
            Stenciler.RunStencilPipeline(To: Map, Quakes: Quakes, Stages: Stages, Caller: self)
        }
        else
        {
            Debug.Print("No global base map available.")
        }
        #endif
    }
    
    /// Apply stencils to `InitialMap` as needed. Stenciled images returned via the `StencilPipelineProtocol`.
    /// - Notes: This function only applies earthquake-related stencils. All stenciling is done to the
    ///          passed image.
    /// - Parameter Caller: Name of the caller.
    func ApplyEarthquakeStencils(InitialMap: UIImage, Caller: String? = nil)
    {
        #if false
        var Quakes: [Earthquake]? = nil
        Quakes = EarthquakeList
        Stenciler.RunStencilPipeline(To: InitialMap, Quakes: Quakes, Stages: [.Earthquakes], Caller: self)
        #endif
    }
    
    /// Apply initial stencils to `GlobalBaseMap`. Initial stencils are those stencils whose visibility flags
    /// are known at start-up and do not need remote data. Stenciled images returned via the
    /// `StencilPipelineProtocol`.
    /// - Note: Earthquake stenciling is not done in this function - see `ApplyEarthquakeStencils` and
    ///         `ApplyAllStencils`.
    /// - Parameter Caller: Name of the caller.
    func ApplyInitialStencils(Caller: String? = nil)
    {
        #if true
        if let Map = GlobalBaseMap
        {
            let NewMap = Stenciler.AddGridLines(To: Map, Ratio: 1.0)
            InitialStenciledMap = NewMap
            OperationQueue.main.addOperation
            {
                self.EarthNode?.geometry?.firstMaterial?.diffuse.contents = NewMap
            }
        }
        #else
        if let Map = GlobalBaseMap
        {
            InitialStenciledMap = nil
            var Stages = [StencilStages]()
            if Settings.GetBool(.ShowWorldHeritageSites) && Settings.GetBool(.PlotSitesAs2D)
            {
                Stages.append(.UNESCOSites)
            }
            if Settings.GetBool(.CityNamesDrawnOnMap)
            {
                Stages.append(.CityNames)
            }
            if Settings.GetBool(.GridLinesDrawnOnMap)
            {
                Stages.append(.GridLines)
            }
            Stenciler.RunStencilPipeline(To: Map, Quakes: nil, Stages: Stages, Caller: self)
        }
        #endif
    }
}
