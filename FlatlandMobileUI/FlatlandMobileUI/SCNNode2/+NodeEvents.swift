//
//  +NodeEvents.swift
//  +NodeEvents
//
//  Created by Stuart Rankin on 7/18/21. Adapted from Flatland View.
//

import Foundation
import UIKit
import SceneKit

extension SCNNode2
{
    /// Add an event and associated attributes to the node.
    func AddEventAttributes(Event: NodeEvents, Attributes: EventAttributes)
    {
        EventMap[Event] = Attributes
    }
    
    /// Trigger the passed event.
    /// - Note:
    ///   - This has the effect of change attributes of the node. Which attributes are defined in the
    ///     `Attributes` parameter when `AddEventAttributes` is called.
    ///   - The event is applied to the node and all `SCNNode2` child nodes.
    ///   - If an event is passed that has no associated attributes, no action is taken.
    /// - Parameter Event: The event to trigger.
    func TriggerEvent(_ Event: NodeEvents)
    {
        if Event == .NoEvent
        {
            return
        }
        if let Attributes = EventMap[Event]
        {
            self.geometry?.firstMaterial?.diffuse.contents = Attributes.Diffuse
            self.geometry?.firstMaterial?.specular.contents = Attributes.Specular
            self.geometry?.firstMaterial?.emission.contents = Attributes.Emission ?? UIColor.clear
            self.geometry?.firstMaterial?.lightingModel = Attributes.LightModel
            self.geometry?.firstMaterial?.metalness.contents = Attributes.Metalness
            self.geometry?.firstMaterial?.roughness.contents = Attributes.Roughness
            if let ScaleValue = Attributes.Scale
            {
                self.scale = SCNVector3(ScaleValue, ScaleValue, ScaleValue)
            }
            for Child in self.childNodes
            {
                if let ActualChild = Child as? SCNNode2
                {
                    ActualChild.TriggerEvent(Event)
                }
            }
        }
    }
}

/// Events that can potentially change `SCNNode2` attributes.
enum NodeEvents: String
{
    /// No event. Nothing will be changed.
    case NoEvent = "Nothing Happened"
    
    /// The node moved into day light.
    case SwitchToDay = "SwitchToDay"
    
    /// The node moved into night time.
    case SwitchToNight = "SwitchToNight"
    
    /// The node appeared.
    case Appear = "Appeared"
    
    /// The node disappeared.
    case Disappeared = "Disappeared"
    
    /// A magnitude associated with the node changed.
    case MagnitudeChanged = "MagnitudeChanged"
}

/// Holds Event attributes.
class EventAttributes
{
    /// Get or set the event the attribute is intended for. Used mainly for debugging.
    var ForEvent: NodeEvents? = nil
    
    /// Diffuse material color.
    var Diffuse: UIColor? = nil
    
    /// Specular material color.
    var Specular: UIColor? = nil
    
    /// Emission material color. If nil, a transparent color is applied.
    var Emission: UIColor? = nil
    
    /// Lighting mode.
    var LightModel: SCNMaterial.LightingModel = .phong
    
    /// Metalness material value.
    var Metalness: Double? = nil
    
    /// Roughness material value.
    var Roughness: Double? = nil
    
    /// Scale value.
    var Scale: Double? = nil
}
