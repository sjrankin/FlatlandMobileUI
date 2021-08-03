//
//  +MainTimeAndSun.swift
//  Flatland
//
//  Created by Stuart Rankin on 9/18/20.
//  Copyright © 2020 - 2021 Stuart Rankin. All rights reserved.
//

import Foundation
import UIKit

extension MainController
{
    /// Update the location of the sun. The sun can be on top or on the bottom and swaps places
    /// with the time label.
    func UpdateSunLocations()
    {
        if Settings.GetEnum(ForKey: .ViewType, EnumType: ViewTypes.self, Default: .FlatSouthCenter) == .Globe3D ||
            Settings.GetEnum(ForKey: .ViewType, EnumType: ViewTypes.self, Default: .FlatSouthCenter) == .CubicWorld
        {
            return
        }
        
        if Settings.GetEnum(ForKey: .ViewType, EnumType: ViewTypes.self, Default: .FlatSouthCenter) == .FlatNorthCenter
        {
            if Settings.GetEnum(ForKey: .TimeLabel, EnumType: TimeLabels.self, Default: TimeLabels.None) == .None
            {
                MainTimeLabelTop.isHidden = true
                MainTimeLabelBottom.isHidden = true
            }
            else
            {
                MainTimeLabelTop.isHidden = false
                MainTimeLabelBottom.isHidden = true
            }
        }
        else
        {
            if Settings.GetEnum(ForKey: .TimeLabel, EnumType: TimeLabels.self, Default: TimeLabels.UTC) == .None
            {
                MainTimeLabelTop.isHidden = true
                MainTimeLabelBottom.isHidden = true
            }
            else
            {
                MainTimeLabelBottom.isHidden = false
                MainTimeLabelTop.isHidden = true
            }
        }
    }
    
    /// Update certain text on the main view with the passed color.
    /// - Note: This is used to ensure the text is visible regardless of the background color. Callers should
    ///         pass a high-contrast variant of the background color to this function.
    func UpdateScreenText(With Color: UIColor)
    {
        MainTimeLabelTop.textColor = Color
        MainTimeLabelBottom.textColor = Color
    }
}
