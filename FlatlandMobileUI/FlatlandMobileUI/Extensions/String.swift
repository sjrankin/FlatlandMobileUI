//
//  String.swift
//  String
//
//  Created by Stuart Rankin on 8/7/21.
//

import Foundation
import UIKit
import AVFAudio
import AVFoundation

extension String
{
    /// String extensions.
    
    /// Use the instance value as a file name for an embedded .mp3 sound and play it.
    /// - Notes: No sound is played if the instance string is empty or if the value of
    ///          the instance string does not resolve to the name of an embedded resource.
    public func Play()
    {
        if self.isEmpty
        {
            return
        }
        if let path = Bundle.main.path(forResource: self, ofType: "mp3")
        {
            let url = URL(fileURLWithPath: path) as CFURL
            var soundID: SystemSoundID = 0
            AudioServicesCreateSystemSoundID(url, &soundID)
            AudioServicesPlaySystemSound(soundID)
        }
        else
        {
            Debug.Print("\(self).mp3 not found.")
        }
    }
}
