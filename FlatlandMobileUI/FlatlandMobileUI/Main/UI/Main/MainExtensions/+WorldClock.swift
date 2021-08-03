//
//  +WorldClock.swift
//  Flatland
//
//  Created by Stuart Rankin on 12/18/20.
//  Copyright © 2020 - 2021 Stuart Rankin. All rights reserved.
//

import Foundation
import UIKit
import SceneKit

extension MainController
{
    /// Initialize the world clock.
    func InitializeWorldClock()
    {
        WorldClockStartTime = Date()
        CurrentWorldTime = 0.0//CACurrentMediaTime()
        //Debug.Print("Starting World Time: \(CurrentWorldTime)")
        WorldClockTimer = Timer.scheduledTimer(timeInterval: 1.0,
                                               target: self,
                                               selector: #selector(HandleWorldClockTick),
                                               userInfo: nil,
                                               repeats: true)
        WorldClockTimer?.tolerance = 0.01
        //RunLoop.current.add(WorldClockTimer!, forMode: .common)
        //RunLoop.current.run()
        HandleWorldClockTick()
    }
    
    /// Update the world clock.
    @objc func HandleWorldClockTick()
    {
        #if false
        let Adder = 1.0 * WorldClockTimeMultiplier
        CurrentWorldTime = CurrentWorldTime + Adder
        let NewTime = Date(timeInterval: CurrentWorldTime, since: WorldClockStartTime!)
        Rect2DView.NewWorldClockTime(WorldDate: NewTime)
        Main2DView.NewWorldClockTime(WorldDate: NewTime)
        Main3DView.NewWorldClockTime(WorldDate: NewTime)
        #if DEBUG
        OperationQueue.main.addOperation
        {
            if let StartTime = self.WorldClockStartTime
            {
            let DateSeconds = Date().timeIntervalSince(StartTime)
            self.MemoryUsedOut.stringValue = "\(DateSeconds)"
//            self.WorldClockTickCount.stringValue = "\(Int(self.CurrentWorldTime))"
            }
        }
        #endif
        #endif
    }
    
    @objc func HandleMemoryInUseDisplay()
    {
        #if DEBUG
        if let InUse = LowLevel.MemoryStatistics(.PhysicalFootprint)
        {
            let DisplayMe = InUse.WithSuffix()
            if PreviousMemoryUsed == nil
            {
                PreviousMemoryUsed = InUse
                ChangeDelta = CACurrentMediaTime()
            }
            else
            {
                let NicePrevious = PreviousMemoryUsed!.WithSuffix()
                #if false
                if NicePrevious != DisplayMe
                {
                    let ChangeTime = CACurrentMediaTime() - ChangeDelta
                    let MemDelta = Int64(InUse) - Int64(PreviousMemoryUsed!)
                    ChangeDelta = CACurrentMediaTime()
                    PreviousMemoryUsed = InUse
                }
                #endif
            }
            //MemoryUsedOut.stringValue = DisplayMe
        }
        else
        {
            //MemoryUsedOut.stringValue = "?"
        }
        #endif
    }
}
