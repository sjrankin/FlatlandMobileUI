//
//  +Layers.swift
//  Flatland
//
//  Created by Stuart Rankin on 9/5/20.
//  Copyright © 2020 Stuart Rankin. All rights reserved.
//

import Foundation
import UIKit
import SceneKit

extension GlobeView
{
    // MARK: - Globe layer handling
    
    /// Remove a layer from the globe view.
    /// - Parameter Layer: The layer to remove. If not present, no action is taken.
    func RemoveLayer(_ Layer: GlobeLayers)
    {
        if let LayerToRemove = StencilLayers[Layer]
        {
            LayerToRemove.removeFromParentNode()
            LayerToRemove.geometry = nil
            StencilLayers.removeValue(forKey: Layer)
        }
    }
    
    /// Remove all layers from the globe view.
    func RemoveAllLayers()
    {
        for (_, LayerNode) in StencilLayers
        {
            LayerNode.removeFromParentNode()
            LayerNode.geometry = nil
        }
        StencilLayers.removeAll()
    }
    
    /// Add a layer to the globe view. If it is already present, it is removed before the new one is
    /// added.
    /// - Note: This function may be called on the main UI thread or on a background thread.
    /// - Parameter Layer: The type of layer to add.
    /// - Parameter Node: The associated `SCNNode` with the layer.
    func AddLayer(_ Layer: GlobeLayers, Node: SCNNode)
    {
        OperationQueue.main.addOperation
        {
            self.RemoveLayer(Layer)
            self.prepare([Node])
            {
                Success in
                if Success
                {
                    Node.name = Layer.rawValue
                    self.StencilLayers[Layer] = Node
                    self.SystemNode?.addChildNode(Node)
                }
            }
        }
    }
    
    /// Make a new layer for the globe view.
    /// - Parameter Layer: The type of layer. If this layer already exists, it is removed.
    /// - Parameter Image: The image to use as the layer.
    func MakeLayer(_ Layer: GlobeLayers, Image: UIImage)
    {
        objc_sync_enter(MakeLayerLock)
        defer{objc_sync_exit(MakeLayerLock)}
        var Radius: CGFloat = 10.02
        switch Layer
        {
            case .CityNames:
                Radius = GlobeRadius.CityNames.rawValue
                
            case .GridLines:
                Radius = GlobeRadius.GridLayer.rawValue
                
            case .Lines:
                Radius = GlobeRadius.LineLayer.rawValue
                
            case .Magnitudes:
                Radius = GlobeRadius.MagnitudeLayer.rawValue
                
            case .Regions:
                Radius = GlobeRadius.RegionLayer.rawValue
                
            case .WorldHeritageSites:
                Radius = GlobeRadius.UnescoLayer.rawValue
                
                #if true
            case .Test:
                Radius = GlobeRadius.TestLayer.rawValue
                #endif
        }
        let LayerSphere = SCNSphere(radius: Radius)
        LayerSphere.segmentCount = Settings.GetInt(.SphereSegmentCount, IfZero: .SphereSegmentCount)
        let LayerNode = SCNNode2(geometry: LayerSphere)
        LayerNode.position = SCNVector3(0.0, 0.0, 0.0)
        LayerNode.geometry?.firstMaterial?.diffuse.contents = Image
        LayerNode.geometry?.firstMaterial?.specular.contents = UIColor.white
        LayerNode.geometry?.firstMaterial?.lightingModel = .phong
        AddLayer(Layer, Node: LayerNode)
    }
    
    /// Make the layers for the globe view. This function is intended for use for setting up the intial
    /// view with all required layers.
    /// - Note: This function will create the specified set of layers in a background thread and the layers
    ///         will appear to the user asynchronously depending on how fast they are created.
    /// - Parameter Layers: The list of layers to create. If this array is empty, all layers will be removed.
    func MakeLayers(_ Layers: [GlobeLayers])
    {
        if Layers.count == 0
        {
            RemoveAllLayers()
            return
        }
        for Layer in Layers
        {
            UpdateLayer(Layer)
        }
    }
    
    /// Update the specified layer. This function is intended for use when a single layer changes for
    /// whatever reason.
    /// - Note: This function will create the specified layer in a background thread and the layer
    ///         will appear to the user asynchronously depending on how fast it is created.
    /// - Parameter Layer: The layer to create.
    func UpdateLayer(_ Layer: GlobeLayers)
    {
        print("**** At \(#function)")
        #if false
        Stenciler.AddStencils2(Layer)
        {
            Image, LayerType in
            if let FinalImage = Image
            {
                self.MakeLayer(LayerType, Image: FinalImage)
            }
        }
        #endif
    }
}
