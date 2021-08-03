//
//  +DBArray.swift
//  +DBArray
//
//  Created by Stuart Rankin on 7/19/21. Adapted from Flatland View.
//

import Foundation
import UIKit

extension Settings
{
    // MARK: - Array functions.
    
    public static func GetTable<T: RawRepresentable>(_ Setting: SettingKeys, _ ElementType: T.Type) -> [T]
    {
        if !TypeIsValid(Setting, Type: ElementType)
        {
            Debug.FatalError("\(Setting) is not valid for GetTable.")
        }
        switch Setting
        {
            case .DB_Cities:
                break
            case .DB_UserCities:
                break
            case .DB_BuiltInPOIs:
                break
            case .DB_UserPOIs:
                break
            case .DB_Homes:
                break
            case .DB_WorldHeritageSites:
                break
            default:
                Debug.FatalError("Encountered setting \(Setting) when not expected in GetTable in \(#function).")
        }
        return [T]()
    }
    
    public static func SetTable<T: RawRepresentable>(_ Setting: SettingKeys, _ ElementType: T.Type, _ Value: T)
    {
        if !TypeIsValid(Setting, Type: ElementType)
        {
            Debug.FatalError("\(Setting) is not valid for SetTable.")
        }
        switch Setting
        {
            case .DB_Cities:
                break
            case .DB_UserCities:
                break
            case .DB_BuiltInPOIs:
                break
            case .DB_UserPOIs:
                break
            case .DB_Homes:
                break
            case .DB_WorldHeritageSites:
                break
            default:
                Debug.FatalError("Encountered setting \(Setting) when not expected in \(#function).")
        }
        NotifySubscribers(Setting: Setting, OldValue: nil, NewValue: nil)
    }
    
    public static func DeleteRow<T: RawRepresentable>(_ Setting: SettingKeys, _ ElementType: T.Type, _ RowPK: Int)
    {
        if !TypeIsValid(Setting, Type: ElementType)
        {
            Debug.FatalError("\(Setting) is not valid for DeleteRow.")
        }
        switch Setting
        {
            case .DB_Cities:
                Debug.Print("Deleting rows in built-in city list not supported.")
                return
                
            case .DB_UserCities:
                break
                
            case .DB_BuiltInPOIs:
                Debug.Print("Deleting rows in built-in POI list not supported.")
                return
                
            case .DB_UserPOIs:
                break
                
            case .DB_Homes:
                break
                
            case .DB_WorldHeritageSites:
                Debug.Print("Deleting rows in built-in World Heritage Site list not supported.")
                return
                
            default:
                Debug.FatalError("Encountered setting \(Setting) when not expected in \(#function).")
        }
    }
    
    public static func AddRow<T: RawRepresentable>(_ Setting: SettingKeys, _ ElementType: T.Type, _ Value: T)
    {
        if !TypeIsValid(Setting, Type: ElementType)
        {
            Debug.FatalError("\(Setting) is not valid for AddRow.")
        }
        switch Setting
        {
            case .DB_Cities:
                Debug.Print("Adding rows in built-in city list not supported.")
                return
                
            case .DB_UserCities:
                break
                
            case .DB_BuiltInPOIs:
                Debug.Print("Adding rows in built-in POI list not supported.")
                return
                
            case .DB_UserPOIs:
                break
                
            case .DB_Homes:
                break
                
            case .DB_WorldHeritageSites:
                Debug.Print("Adding rows in built-in World Heritage Site list not supported.")
                return
                
            default:
                Debug.FatalError("Encountered setting \(Setting) when not expected in \(#function).")
        }
    }
    
    public static func AddRows<T: RawRepresentable>(_ Setting: SettingKeys, _ ElementType: T.Type, _ Values: [T])
    {
        if !TypeIsValid(Setting, Type: ElementType)
        {
            Debug.FatalError("\(Setting) is not valid for AddRows.")
        }
        switch Setting
        {
            case .DB_Cities:
                Debug.Print("Adding rows in built-in city list not supported.")
                return
                
            case .DB_UserCities:
                break
                
            case .DB_BuiltInPOIs:
                Debug.Print("Adding rows in built-in POI list not supported.")
                return
                
            case .DB_UserPOIs:
                break
                
            case .DB_Homes:
                break
                
            case .DB_WorldHeritageSites:
                Debug.Print("Adding rows in built-in World Heritage Site list not supported.")
                return
                
            default:
                Debug.FatalError("Encountered setting \(Setting) when not expected in \(#function).")
        }
    }
}
