//
//  SCNNode2.swift
//  SCNNode2
//
//  Created by Stuart Rankin on 7/18/21. Adapted from Flatland View.
//

import Foundation
import UIKit
import SceneKit

/// Thin wrapper around `SCNNode` that provides a few auxiliary properties for carrying data and ID information.
class SCNNode2: SCNNode
{
    // MARK: - Initialization and deinitialization.
    
    /// Default initializer.
    override init()
    {
        super.init()
        Initialize()
    }
    
    /// Initializer.
    /// - Parameter Tag: The tag value.
    init(Tag: Any?)
    {
        super.init()
        self.Tag = Tag
        Initialize()
    }
    
    /// Initializer.
    /// - Parameter Tag: The tag value.
    /// - Parameter NodeID: The node's ID. Assumed to be unique.
    /// - Parameter NodeClass: The node class ID. Assumed to be non-unique.
    /// - Parameter Usage: Intended usage of the node.
    init(Tag: Any? = nil, NodeID: UUID, NodeClass: UUID, Usage: NodeUsages = .Generic)
    {
        super.init()
        self.Tag = Tag
        self.NodeID = NodeID
        self.NodeClass = NodeClass
        self.NodeUsage = Usage
        Initialize()
    }
    
    /// Initializer.
    /// - Parameter geometry: The geometry of the node.
    init(geometry: SCNGeometry?)
    {
        super.init()
        self.geometry = geometry
        Initialize()
    }
    
    /// Initializer.
    /// - Parameter geometry: The geometry of the node.
    /// - Parameter Tag: The tag value.
    /// - Parameter SubComponent: The sub-component ID.
    init(geometry: SCNGeometry?, Tag: Any?, SubComponent: UUID? = nil)
    {
        super.init()
        self.geometry = geometry
        self.Tag = Tag
        Initialize()
    }
    
    /// Initializer.
    /// - Parameter geometry: The geometry of the node.
    /// - Parameter Tag: The tag value.
    /// - Parameter NodeID: The node's ID. Assumed to be unique.
    /// - Parameter NodeClass: The node class ID. Assumed to be non-unique.
    /// - Parameter Usage: Intended usage of the node.
    init(geometry: SCNGeometry?, Tag: Any? = nil, NodeID: UUID, NodeClass: UUID, Usage: NodeUsages = .Generic)
    {
        super.init()
        self.geometry = geometry
        self.Tag = Tag
        self.NodeID = NodeID
        self.NodeClass = NodeClass
        self.NodeUsage = Usage
        Initialize()
    }
    
    /// Initializer.
    /// - Parameter CanChange: Sets the node can change state flag.
    /// - Parameter Latitude: The real-world latitude of the node.
    /// - Parameter Longitude: The real-word longitude of the node.
    init(CanChange: Bool, _ Latitude: Double, _ Longitude: Double)
    {
        super.init()
        CanSwitchState = CanChange
        SetLocation(Latitude, Longitude)
        Initialize()
    }
    
    /// Initializer.
    /// - Parameter coder: See Apple documentation.
    required init?(coder: NSCoder)
    {
        super.init(coder: coder)
        Initialize()
    }
    
    /// Initializer.
    /// - Parameter From: The `SCNNode` whose data is used to initialize the `SCNNode2`
    ///                   instance.
    init(From: SCNNode)
    {
        super.init()
        self.geometry = From.geometry
        self.scale = From.scale
        self.position = From.position
        self.eulerAngles = From.eulerAngles
        self.categoryBitMask = From.categoryBitMask
        Initialize()
    }
    
    /// Initializer.
    /// - Parameter AsChild: `SCNNode` instance that will be added as a child to the
    ///             `SCNNode2` instance.
    init(AsChild: SCNNode)
    {
        super.init()
        self.addChildNode(AsChild)
        Initialize()
    }
    
    /// Common initialization.
    private func Initialize()
    {
        //StartDynamicUpdates()
    }
    
    /// Clears a node of its contents. Removes it from the parent. Prepares node to be deleted.
    public func Clear()
    {
        self.removeAllAnimations()
        self.removeAllActions()
        self.removeFromParentNode()
        self.geometry?.firstMaterial?.diffuse.contents = nil
        self.geometry?.firstMaterial?.specular.contents = nil
        self.geometry?.firstMaterial?.emission.contents = nil
        self.geometry?.firstMaterial?.selfIllumination.contents = nil
        self.geometry = nil
    }
    
    /// Clears a node of its contents. Does the same for all child nodes. Prepares the node to be deleted.
    /// - Note: Only child nodes of type `SCNNode2` are cleared.
    public func ClearAll()
    {
        for Child in ChildNodes2()
        {
            Child.ClearAll()
            Child.Clear()
        }
        Clear()
    }
    
    // MARK: - Additional fields.
    
    /// Tag value. Defaults to `nil`.
    var Tag: Any? = nil
    
    /// Name of the node.
    var Name: String = ""
    
    /// Sub-component ID. Defaults to `nil`.
    var SubComponent: UUID? = nil
    
    /// Node class ID. Defaults to `nil`.
    var NodeClass: UUID? = nil
    
    /// Node ID. Defaults to `nil`.
    var NodeID: UUID? = nil
    
    /// ID to use for editing the edit. Defaults to `nil`.
    var EditID: UUID? = nil
    
    /// Intended node usage. Defaults to `nil`.
    var NodeUsage: NodeUsages? = nil
    
    /// Initial angle of the node. Usage is context sensitive. Defaults to `nil`.
    var InitialAngle: Double? = nil
    
    /// The caller should set this to true if the node is showing SCNText geometry. Defaults to `false`.
    var IsTextNode: Bool = false
    
    /// Convenience property to hold hour angles.
    var HourAngle: Double? = nil
    
    /// Propagate the parent's `NodeUsage` value to its children.
    func PropagateUsage()
    {
        for Child in self.childNodes
        {
            if let TheChild = Child as? SCNNode2
            {
                TheChild.NodeUsage = NodeUsage
            }
        }
    }
    
    /// Propagate the parent's IDs to its children.
    func PropagateIDs()
    {
        for Child in self.childNodes
        {
            if let TheChild = Child as? SCNNode2
            {
                TheChild.NodeClass = NodeClass
                TheChild.NodeID = NodeID
            }
        }
    }
    
    /// Convenience value.
    var SourceAngle: Double = 0.0
    
    /// Auxiliary string tag.
    var AuxiliaryTag: String? = nil
    
    /// Returns all child nodes that are of type `SCNNode2`.
    /// - Returns: Array of child nodes that are of type `SCNNode2`.
    func ChildNodes2() -> [SCNNode2]
    {
        var Results = [SCNNode2]()
        for SomeNode in childNodes
        {
            if let TheNode = SomeNode as? SCNNode2
            {
                Results.append(TheNode)
            }
        }
        return Results
    }
    
    /// Iterate over all child nodes in the instance node and execute the close against it. If a child node
    /// cannot be converted to an `SCNNode2`, nil is passed to the closure.
    /// - Parameter Closure: The closure block to execute against each child node in turn.
    func ForEachChild(_ Closure: ((SCNNode2?) -> ())?)
    {
        for SomeNode in childNodes
        {
            Closure?((SomeNode as? SCNNode2))
        }
    }
    
    /// Iterate over all child nodes in the instance node and execute the close against it. Only child nodes
    /// that are of type `SCNNode2` are iterated here.
    /// - Note: All nodes of type `SCNNode2` are passed to the closure (as non-nil references). If there are
    ///         no nodes of type `SCNNode2`, nothing is passed.
    /// - Parameter Closure: The closure block to execute against each child node in turn.
    func ForEachChild2(_ Closure: ((SCNNode2) -> ())?)
    {
        for SomeNode in ChildNodes2()
        {
            Closure?(SomeNode)
        }
    }
    
    // MARK: - Text handling
    
    /// Change the text geometry to the passed string.
    /// - Note:
    ///   - If `IsTextNode` is false, no action is taken.
    ///   - If `geometry` hasn't been set, no action is taken.
    /// - Parameter To: The new text to use for the text geometry.
    func ChangeText(To NewText: String)
    {
        if !IsTextNode
        {
            return
        }
        if geometry == nil
        {
            return
        }
        (geometry as? SCNText)?.string = NewText
    }
    
    // MARK: - Bounding shape variables.
    
    var _CanShowBoundingShape: Bool = true
    {
        didSet
        {
            if !_CanShowBoundingShape
            {
                HideBoundingSphere()
                HideBoundingBox()
            }
        }
    }
    
    /// Holds the bounding box.
    var BoxNode = SCNNode()
    
    /// Holds the rotate on X axis flag.
    private var _RotateOnX: Bool = true
    /// Get or set the rotate bounding shape on X axis flag.
    public var RotateOnX: Bool
    {
        get
        {
            return _RotateOnX
        }
        set
        {
            _RotateOnX = newValue
        }
    }
    
    /// Holds the rotate on Y axis flag.
    private var _RotateOnY: Bool = true
    /// Get or set the rotate bounding shape on Y axis flag.
    public var RotateOnY: Bool
    {
        get
        {
            return _RotateOnY
        }
        set
        {
            _RotateOnY = newValue
        }
    }
    
    /// Holds the rotate on Z axis flag.
    private var _RotateOnZ: Bool = true
    /// Get or set the rotate bounding shape on Z axis flag.
    public var RotateOnZ: Bool
    {
        get
        {
            return _RotateOnZ
        }
        set
        {
            _RotateOnZ = newValue
        }
    }
    
    var _ShowingBoundingShape: Bool = false
    /// Gets the current state of the bounding shape.
    public var ShowingBoundingShape: Bool
    {
        get
        {
            return _ShowingBoundingShape
        }
    }
    
    /// The bounding sphere node.
    var BoundingSphereNode: SCNNode? = nil
    
    /// The current bounding shape.
    public var CurrentBoundingShape: NodeBoundingShapes = .Box
    
    /// Array of bounding box lines.
    var BoundingBoxLines = [SCNNode]()
    
    // MARK: - Day/night settings.
    
    /// Propagates the current daylight state to all child nodes.
    /// - Parameter InDay: True indicates daylight, false indicates nighttime.
    private func PropagateState(InDay: Bool)
    {
        for Child in ChildNodes2()
        {
            Child.IsInDaylight = InDay
        }
    }
    
    /// Sets the day or night state for nodes that have diffuse materials made up of one or more
    /// materials (usually images).
    /// - Parameter For: Determines day or night state.
    private func SetStateWithImages(For DayTime: Bool)
    {
        if DayTime
        {
            self.geometry?.firstMaterial?.lightingModel = DayState!.LightModel
            let EmissionColor = DayState?.Emission ?? UIColor.clear
            for Material in self.geometry!.materials
            {
                Material.emission.contents = EmissionColor
            }
            if DayState?.Metalness != nil
            {
                for Material in self.geometry!.materials
                {
                    Material.metalness.contents = DayState!.Metalness
                }
            }
            if DayState?.Roughness != nil
            {
                for Material in self.geometry!.materials
                {
                    Material.roughness.contents = DayState!.Roughness
                }
            }
        }
        else
        {
            self.geometry?.firstMaterial?.lightingModel = NightState!.LightModel
            let EmissionColor = NightState?.Emission ?? UIColor.clear
            for Material in self.geometry!.materials
            {
                Material.emission.contents = EmissionColor
            }
            if NightState?.Metalness != nil
            {
                for Material in self.geometry!.materials
                {
                    Material.metalness.contents = NightState!.Metalness
                }
            }
            if NightState?.Roughness != nil
            {
                for Material in self.geometry!.materials
                {
                    Material.roughness.contents = NightState!.Roughness
                }
            }
        }
    }
    
    /// Assign the passed set of state values to the node.
    /// - Parameter State: The set of state values to assign.
    private func SetVisualAttributes(_ State: NodeState)
    {
#if true
        if let DiffuseTexture = State.Diffuse
        {
            self.geometry?.firstMaterial?.diffuse.contents = DiffuseTexture
        }
        else
        {
            self.geometry?.firstMaterial?.diffuse.contents = State.Color
        }
        self.geometry?.firstMaterial?.specular.contents = State.Specular ?? UIColor.white
        self.geometry?.firstMaterial?.lightingModel = State.LightModel
        self.geometry?.firstMaterial?.emission.contents = State.Emission ?? UIColor.clear
        self.geometry?.firstMaterial?.lightingModel = State.LightModel
        self.geometry?.firstMaterial?.metalness.contents = State.Metalness
        self.geometry?.firstMaterial?.roughness.contents = State.Roughness
        if let DoesCastShadow = State.CastsShadow
        {
            self.castsShadow = DoesCastShadow
        }
#else
        if UseProtocolToSetState
        {
            if let PNode = self as? ShapeAttribute
            {
                if let DiffuseTexture = State.Diffuse
                {
                    MemoryDebug.Block("SetVisualAttributes.SetDiffuseTexture")
                    {
                        PNode.SetDiffuseTexture(DiffuseTexture)
                    }
                }
                else
                {
                    MemoryDebug.Block("SetVisualAttributes.SetMaterialColor")
                    {
                        PNode.SetMaterialColor(State.Color)
                    }
                }
                MemoryDebug.Block("SetVisualAttributes.Other")
                {
                    PNode.SetEmissionColor(State.Emission ?? UIColor.clear)
                    PNode.SetLightingModel(State.LightModel)
                    PNode.SetMetalness(State.Metalness)
                    PNode.SetRoughness(State.Roughness)
                }
            }
        }
        else
        {
            MemoryDebug.Block("SetVisualAttributes")
            {
                if let DiffuseTexture = State.Diffuse
                {
                    self.geometry?.firstMaterial?.diffuse.contents = DiffuseTexture
                }
                else
                {
                    self.geometry?.firstMaterial?.diffuse.contents = State.Color
                }
                self.geometry?.firstMaterial?.specular.contents = State.Specular ?? UIColor.white
                self.geometry?.firstMaterial?.lightingModel = State.LightModel
                self.geometry?.firstMaterial?.emission.contents = State.Emission ?? UIColor.clear
                self.geometry?.firstMaterial?.lightingModel = State.LightModel
                self.geometry?.firstMaterial?.metalness.contents = State.Metalness
                self.geometry?.firstMaterial?.roughness.contents = State.Roughness
            }
        }
#endif
    }
    
    /// Set the visual state for the node (and all child nodes) to day or night time (based on the parameter).
    /// - Note: If either `DayState` or `NightState` is nil, the state set is for the day.
    /// - Parameter For: Determines which state to show.
    public func SetState(For DayTime: Bool)
    {
        if DayState == nil || NightState == nil
        {
            for Child in self.ChildNodes2()
            {
                Child.SetState(For: DayTime)
            }
            return
        }
        if HasImageTextures
        {
            SetStateWithImages(For: DayTime)
            return
        }
        let NodeState = DayTime ? DayState! : NightState!
        SetVisualAttributes(NodeState)
        for Child in self.ChildNodes2()
        {
            Child.SetState(For: DayTime)
        }
    }
    
    /// Set to true if the contents of the diffuse material is made up of one or more images.
    public var HasImageTextures: Bool = false
    
    /// Holds the daylight state. Setting this property updates the visual state for this node and all child
    /// nodes.
    private var _IsInDaylight: Bool = true
    {
        didSet
        {
            self.PropagateState(InDay: self._IsInDaylight)
            self.SetState(For: self._IsInDaylight)
        }
    }
    /// Get or set the daylight state. Setting the same value two (or more) times in a row will not result
    /// in any changes.
    public var IsInDaylight: Bool
    {
        get
        {
            return _IsInDaylight
        }
        set
        {
            _IsInDaylight = newValue
        }
    }
    
    /// Check to see if the node is in daylight or not. Sets the value of `IsInDaylight`
    /// - Notes: If the position is not set or daylight cannot be determined, no action is taken.
    public func SetDaylightState()
    {
        guard let Latitude = Latitude, let Longitude = Longitude else
        {
            Debug.Print("SetDaylightState: Position not set.")
            return
        }
        guard let IsInDay = Solar.IsInDaylight(Latitude, Longitude) else
        {
            Debug.Print("SetDaylightState: Cannot determine sun's position.")
            return
        }
        IsInDaylight = IsInDay
    }
    
    var PreviousDayState: Bool? = nil
    
    /// Holds the can switch state flag.
    private var _CanSwitchState: Bool = false
    {
        didSet
        {
            for Child in self.childNodes
            {
                if let Node = Child as? SCNNode2
                {
                    Node.CanSwitchState = _CanSwitchState
                }
            }
        }
    }
    /// Sets the can switch state flag. If false, the node does not respond to state changes. Setting this
    /// property propagates the same value to all child nodes.
    public var CanSwitchState: Bool
    {
        get
        {
            return _CanSwitchState
        }
        set
        {
            _CanSwitchState = newValue
        }
    }
    
    public var DayState: NodeState? = nil
    public var NightState: NodeState? = nil
    
    /// Convenience function to set the state attributes.
    /// - Parameter ForDay: If true, day time attributes are set. If false, night time attributes are set.
    /// - Parameter Color: The color for the state.
    /// - Parameter Specular: The specular color for the state. Defaults to `.white`.
    /// - Parameter Emission: The color for the emmission material (eg, glowing). Defaults to `nil`.
    /// - Parameter Model: The lighting model for the state. Defaults to `.phong`.
    /// - Parameter Metalness: The metalness value of the state. If nil, not used. Defaults to `nil`.
    /// - Parameter Roughness: The roughness value of the state. If nil, not used. Defaults to `nil`.
    /// - Parameter CastsShadow: Sets the value of the `castsShadow` flat. If nil, not used. Defaults to `nil`.
    /// - Parameter ChildrenToo: If true, child nodes (only of type `SCNNode2`) will also have the passed
    ///                          state set. If false, child nodes are ignored.
    public func SetState(ForDay: Bool,
                         Color: UIColor,
                         Specular: UIColor = UIColor.white,
                         Emission: UIColor? = nil,
                         Model: SCNMaterial.LightingModel = .phong,
                         Metalness: Double? = nil,
                         Roughness: Double? = nil,
                         CastsShadow: Bool? = nil,
                         ChildrenToo: Bool = true)
    {
        if ForDay
        {
            DayState = NodeState(State: .Day, Color: Color, Diffuse: nil, Emission: Emission,
                                 Specular: Specular, LightModel: Model, Metalness: Metalness,
                                 Roughness: Roughness, CastsShadow: CastsShadow)
        }
        else
        {
            NightState = NodeState(State: .Night, Color: Color, Diffuse: nil, Emission: Emission,
                                   Specular: Specular, LightModel: Model, Metalness: Metalness,
                                   Roughness: Roughness, CastsShadow: CastsShadow)
        }
        for Child in ChildNodes2()
        {
            Child.SetState(ForDay: ForDay, Color: Color, Emission: Emission, Model: Model,
                           Metalness: Metalness, Roughness: Roughness, CastsShadow: CastsShadow,
                           ChildrenToo: ChildrenToo)
        }
    }
    
    /// Convenience function to set the state attributes.
    /// - Parameter ForDay: If true, day time attributes are set. If false, night time attributes are set.
    /// - Parameter Diffuse: The image to use as the diffuse surface texture.
    /// - Parameter Emission: The color for the emmission material (eg, glowing). Defaults to `nil`.
    /// - Parameter Model: The lighting model for the state. Defaults to `.phong`.
    /// - Parameter Metalness: The metalness value of the state. If nil, not used. Defaults to `nil`.
    /// - Parameter Roughness: The roughness value of the state. If nil, not used. Defaults to `nil`.
    /// - Parameter CastsShadow: Sets the value of the `castsShadow` flat. If nil, not used. Defaults to `nil`.
    /// - Parameter ChildrenToo: If true, child nodes (only of type `SCNNode2`) will also have the passed
    ///                          state set. If false, child nodes are ignored.
    public func SetState(ForDay: Bool,
                         Diffuse: UIImage,
                         Emission: UIColor? = nil,
                         Model: SCNMaterial.LightingModel = .phong,
                         Metalness: Double? = nil,
                         Roughness: Double? = nil,
                         CastsShadow: Bool? = nil,
                         ChildrenToo: Bool = true)
    {
        if ForDay
        {
            DayState = NodeState(State: .Day, Color: UIColor.white, Diffuse: Diffuse, Emission: Emission,
                                 Specular: UIColor.white, LightModel: Model, Metalness: Metalness,
                                 Roughness: Roughness, CastsShadow: CastsShadow)
        }
        else
        {
            NightState = NodeState(State: .Night, Color: UIColor.black, Diffuse: Diffuse, Emission: Emission,
                                   Specular: UIColor.white, LightModel: Model, Metalness: Metalness,
                                   Roughness: Roughness, CastsShadow: CastsShadow)
        }
        for Child in ChildNodes2()
        {
            Child.SetState(ForDay: ForDay, Diffuse: Diffuse, Emission: Emission, Model: Model,
                           Metalness: Metalness, Roughness: Roughness, CastsShadow: CastsShadow,
                           ChildrenToo: ChildrenToo)
        }
    }
    
    /// If true, the ShapeAttribute protocol will be used to set attributes. This is provided for
    /// nodes that have hard to reach child nodes. This lets such nodes handle setting state for
    /// themselves. Defaults to `false`.
    public var UseProtocolToSetState: Bool = false
    
    // MARK: - Map location data.
    
    /// Sets the geographic location of the node in terms of latitude, longitude. All child nodes
    /// are also set with the same values.
    /// - Parameter Latitude: The latitude of the node.
    /// - Parameter Longitude: The longitude of the node.
    public func SetLocation(_ Latitude: Double, _ Longitude: Double)
    {
        self.Latitude = Latitude
        self.Longitude = Longitude
        for Child in self.childNodes
        {
            if let Node = Child as? SCNNode2
            {
                Node.SetLocation(Latitude, Longitude)
            }
        }
    }
    
    /// Clears the geographic location of the node. All child nodes are also cleared.
    public func ClearLocation()
    {
        self.Latitude = nil
        self.Longitude = nil
        for Child in self.childNodes
        {
            if let Node = Child as? SCNNode2
            {
                Node.ClearLocation()
            }
        }
    }
    
    /// Determines if the node has a geographic location.
    /// - Returns: True if the node has both latitude and longitude set, false if not.
    func HasLocation() -> Bool
    {
        return Latitude != nil && Longitude != nil
    }
    
    /// If provided, the latitude of the node.
    public var Latitude: Double? = nil
    /// If provided, the longitude of the node.
    public var Longitude: Double? = nil
    
    // MARK: - Dynamic updating.
    
    /*
     func StartDynamicUpdates()
     {
     DynamicTimer = Timer.scheduledTimer(timeInterval: 1.0,
     target: self,
     selector: #selector(TestDaylight),
     userInfo: nil, repeats: true)
     }
     */
    
    weak var DynamicTimer: Timer? = nil
    
    func StopDynamicUpdates()
    {
        DynamicTimer?.invalidate()
        DynamicTimer = nil
    }
    
    /// Test to see if it is daylight.
    @objc func TestDaylight()
    {
        DoTestDaylight()
    }
    
    /// See if the node is in day light or nighttime and change it appropriately.
    func DoTestDaylight(_ Caller: String? = nil)
    {
        if HasLocation()
        {
            if let IsInDay = Solar.IsInDaylight(Latitude!, Longitude!)
            {
                _IsInDaylight = IsInDay
                let SomeEvent = IsInDay ? NodeEvents.SwitchToDay : NodeEvents.SwitchToNight
                TriggerEvent(SomeEvent)
                for Child in ChildNodes2()
                {
                    Child.IsInDaylight = _IsInDaylight
                }
            }
        }
    }
    
    /// Holds events and associated attributes.
    var EventMap = [NodeEvents: EventAttributes]()
    
    /// Sets the opacity of the node to the passed value.
    /// - Note: All child nodes have their opacity set to the same level.
    /// - Note: The opacity stack is cleared when this function is called.
    /// - Parameter To: New opacity value.
    func SetOpacity(To NewValue: Double)
    {
        OpacityStack.Clear()
        self.opacity = CGFloat(NewValue)
        for Child in self.childNodes
        {
            if let ActualChild = Child as? SCNNode2
            {
                ActualChild.SetOpacity(To: NewValue)
            }
            else
            {
                Child.opacity = CGFloat(NewValue)
            }
        }
    }
    
    /// Push the current opacity value of the node onto a stack then set the opacity to the passed value.
    /// - Note: This function is provided as a way to retain opacity levels over the course of changing
    ///         opacity levels on a temporary basis. Each node has its own opacity stack and by using this
    ///         function and `PopOpacity` opacity levels are restored correctly.
    /// - Note: All child nodes have their opacities pushed. If a child node is of type `SCNNode`, the opacity
    ///         level is assigned but no pushing operation takes place since `SCNNode` does not support it.
    /// - Parameter NewValue: The new opacity level.
    /// - Parameter Animate: If true, the opacity level change is animated. Otherwise, it happens immediately.
    ///                      Defaults to true.
    func PushOpacity(_ NewValue: Double, Animate: Bool = true)
    {
        OpacityStack.Push(self.opacity)
        if Animate
        {
            let OpacityAnimation = SCNAction.fadeOpacity(to: CGFloat(NewValue), duration: 0.5)
            self.runAction(OpacityAnimation)
        }
        else
        {
            self.opacity = CGFloat(NewValue)
        }
        for Child in self.childNodes
        {
            if let ActualChild = Child as? SCNNode2
            {
                ActualChild.PushOpacity(NewValue)
            }
            else
            {
                if Animate
                {
                    let OpacityAnimation = SCNAction.fadeOpacity(to: CGFloat(NewValue), duration: 0.5)
                    self.runAction(OpacityAnimation)
                }
                else
                {
                    Child.opacity = CGFloat(NewValue)
                }
            }
        }
    }
    
    /// Pop the opacity from the stack and set the node's opacity to that value.
    /// - Note: All child nodes have their opacity popped as well. If a child node is of type `SCNNode`,
    ///         its opacity value is set to `IsEmpty`.
    /// - Parameter IfEmpty: Value to use for the opacity if the opacity stack is empty.
    /// - Parameter Animate: If true, the opacity level change is animated. Otherwise, it happens immediately.
    ///                      Defaults to true.
    func PopOpacity(_ IfEmpty: Double = 1.0, Animate: Bool = true)
    {
        if OpacityStack.IsEmpty
        {
            if Animate
            {
                let OpacityAnimation = SCNAction.fadeOpacity(to: CGFloat(IfEmpty), duration: 0.5)
                self.runAction(OpacityAnimation)
            }
            else
            {
                self.opacity = CGFloat(IfEmpty)
            }
        }
        else
        {
            if let OldValue = OpacityStack.Pop()
            {
                if Animate
                {
                    let OpacityAnimation = SCNAction.fadeOpacity(to: CGFloat(OldValue), duration: 0.5)
                    self.runAction(OpacityAnimation)
                }
                else
                {
                    self.opacity = OldValue
                }
            }
            else
            {
                if Animate
                {
                    let OpacityAnimation = SCNAction.fadeOpacity(to: CGFloat(IfEmpty), duration: 0.5)
                    self.runAction(OpacityAnimation)
                }
                else
                {
                    self.opacity = CGFloat(IfEmpty)
                }
            }
        }
        for Child in self.childNodes
        {
            if let ActualChild = Child as? SCNNode2
            {
                ActualChild.PopOpacity(IfEmpty, Animate: Animate)
            }
            else
            {
                if Animate
                {
                    let OpacityAnimation = SCNAction.fadeOpacity(to: CGFloat(IfEmpty), duration: 0.5)
                    Child.runAction(OpacityAnimation)
                }
                else
                {
                    Child.opacity = CGFloat(IfEmpty)
                }
            }
        }
    }
    
    /// Remove all entries in the opacity stack.
    func ClearOpacityStack()
    {
        OpacityStack = Stack<CGFloat>()
    }
    
    var OpacityStack = Stack<CGFloat>()
    
    // MARK: - Child management
    
    /// Returns the total number of child nodes (must be of type `SCNNode2`) of the instance node.
    func ChildCount() -> Int
    {
        var Count = 0
        //Add grandchilden and lower.
        for Child in childNodes
        {
            if let Child2 = Child as? SCNNode2
            {
                Count = Count + Child2.ChildCount()
            }
        }
        //Add children.
        Count = Count + childNodes.count
        return Count
    }
}

// MARK: - Bounding shapes.

/// Set of shapes for indicators for `SCNNode2` objects.
enum NodeBoundingShapes: String, CaseIterable
{
    /// Indicator is a box.
    case Box = "Box"
    /// Indicator is a sphere.
    case Sphere = "Sphere"
}



