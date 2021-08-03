//
//  Settings.swift
//  Settings
//
//  Created by Stuart Rankin on 7/19/21. Adapted from Flatland View.
//

import Foundation
import UIKit
import SceneKit

/// This class encapsulates settings into a set of functions that rely on enums to select the
/// value rather than strings. This class also allows other classes to "subscribe" to changed
/// value events. Most code to set values for specific types can be found in various extentions.
class Settings
{
    // MARK: - Initialization.
    
    /// Initialize settings. Run only if the initialization flag hasn't been set, or the force
    /// reinitialize flag is true.
    /// - Note: This function also loads databases with data managed by this class.
    /// - Parameter ForceReinitialize: If true, settings will be reset to their default values. In
    ///                                this case, no messages will be returned to subscribers indicating
    ///                                changes have been made.
    public static func Initialize(_ ForceReinitialize: Bool = false)
    {
        DBIF.Initialize(LoadToo: true)
        
        if WasInitialized()
        {
            if !ForceReinitialize
            {
                return
            }
        }
        
        Debug.Print("Initializing settings.")
        InitializeBool(.InitializationFlag, true)
        InitializeBool(.ShowInitialVersion, true)
        InitializeDouble(.InitialVersionDuration, 45.0)
        InitializeEnum(.FlatNorthCenter, EnumType: ViewTypes.self, ForKey: .MapType)
        InitializeBool(.ShowNight, true)
        InitializeEnum(.RelativeToNoon, EnumType: HourTypes.self, ForKey: .HourType)
        InitializeEnum(.UTC, EnumType: TimeLabels.self, ForKey: .TimeLabel)
        InitializeDouble(.NightMaskAlpha, 0.4)
        InitializeColor(.GridLineColor, UIColor.PrussianBlue)
        
        InitializeBool(.ShowUserLocations, false)
        InitializeString(.UserLocations, "")
        
        InitializeBool(.Show2DEquator, true)
        InitializeBool(.Show2DPolarCircles, true)
        InitializeBool(.Show2DTropics, true)
        InitializeBool(.Show2DPrimeMeridians, true)
        InitializeBool(.Show2DNoonMeridians, true)
        
        InitializeBool(.ShowCities, true)
        InitializeColor(.AfricanCityColor, UIColor.blue)
        InitializeColor(.AsianCityColor, UIColor.brown)
        InitializeColor(.EuropeanCityColor, UIColor.magenta)
        InitializeColor(.NorthAmericanCityColor, UIColor.green)
        InitializeColor(.SouthAmericanCityColor, UIColor.cyan)
        InitializeColor(.CapitalCityColor, UIColor.yellow)
        InitializeColor(.WorldCityColor, UIColor.red)
        InitializeBool(.ExtrudedCitiesCastShadows, false)
        
        InitializeBool(.EnableSounds, true)
        
        InitializeDouble(.FieldOfView, 90.0)
        InitializeDouble(.OrthographicScale, 14.0)
        InitializeBool(.UseHDRCamera, false)
        
        InitializeBool(.EnableEarthquakes, false)
        InitializeDouble(.EarthquakeFetchInterval, 60.0 * 5.0)
        InitializeEnum(.RadiatingRings, EnumType: EarthquakeIndicators.self,
                       ForKey: .EarthquakeStyles)
        
        InitializeString(.CityFontName, "SFProText-Bold")
    }
    
    /// Determines if settings were initialized.
    /// - Returns: True if settings were initialized, false if not.
    public static func WasInitialized() -> Bool
    {
        return GetBool(.InitializationFlag)
    }
    
    /// Override settings depending on feature availability.
    public static func UpdateForFeatureLevel()
    {
        Features.FeatureEnabled(.NASAImagery)
        {
            IsEnabled in
            if !IsEnabled
            {
                Settings.SetBool(.EnableNASATiles, false)
            }
        }
        Features.FeatureEnabled(.QuakeBarcodes)
        {
            IsEnabled in
            if !IsEnabled
            {
                Settings.SetBool(.ShowMagnitudeBarCode, false)
            }
        }
    }
    
    // MARK: - Subscriber management.
    
    /// List of subscribers we send change notices to.
    static var Subscribers = [SettingChangedProtocol]()
    
    /// Add a subscriber. Subscribers receive change notices for most changes. (Initialization
    /// events are not sent.)
    /// - Parameter NewSubscriber: A new subscriber to receive change notices. Must implement
    ///                            the `SettingChangedProtocol`.
    public static func AddSubscriber(_ NewSubscriber: SettingChangedProtocol)
    {
        for Subscriber in Subscribers
        {
            if Subscriber.SubscriberID() == NewSubscriber.SubscriberID()
            {
                return
            }
        }
        Subscribers.append(NewSubscriber)
    }
    
    /// Remove a subscriber. Should be called when a class/subscriber goes out of scope.
    /// - Parameter OldSubscriber: The subscriber to remove. If not present, no action is taken.
    public static func RemoveSubscriber(_ OldSubscriber: SettingChangedProtocol)
    {
        Subscribers.removeAll(where: {$0.SubscriberID() == OldSubscriber.SubscriberID()})
    }
    
    /// Called when a change to a setting value is made. The old value and new value and setting
    /// that changed is sent to the subscriber.
    /// - Note:
    ///   - Changes made via an initialization function are *not* reported to subscribers.
    ///   - Subscribers are notified even if `NewValue` has the same value as `OldValue`.
    /// - Parameter Setting: The setting that was changed.
    /// - Parameter OldValue: The value before the change.
    /// - Parameter Newvalue: The value after the change.
    public static func NotifySubscribers(Setting: SettingKeys, OldValue: Any?, NewValue: Any?)
    {
        for Subscriber in Subscribers
        {
            Subscriber.SettingChanged(Setting: Setting, OldValue: OldValue, NewValue: NewValue)
        }
    }
    
    // MARK: - Validation functions.
    
    /// Determines if the passed type is valid for the passed setting type/key.
    /// - Parameter For: The setting key show type will be tested against `Type`.
    /// - Parameter Type: The type to test against the type in `SettingKeyTypes`.
    /// - Returns: True if the passed type matches the type in the `SettingKeyTypes` table, false otherwise.
    public static func TypeIsValid(_ For: SettingKeys, Type: Any) -> Bool
    {
        let TypeName = "\(Type)"
        if let BaseType = SettingKeyTypes[For]
        {
            let BaseName = "\(BaseType)"
            return TypeName == BaseName
        }
        return false
    }
}

/// Setting errors that may occur.
enum SettingErrors: String, CaseIterable, Error
{
    /// No error - operation was a success.
    case Success = "Success"
    /// Bad type specified.
    case BadType = "BadType"
    /// No type found for setting key.
    case NoType = "NoType"
    /// Error converting from one type to another.
    case ConversionError = "ConversionError"
}
