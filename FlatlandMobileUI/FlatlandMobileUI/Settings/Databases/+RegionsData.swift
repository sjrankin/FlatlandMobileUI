//
//  +RegionsData.swift
//  +RegionsData
//
//  Created by Stuart Rankin on 7/19/21. Adapted from Flatland View.
//

import Foundation
import UIKit
import SQLite3

extension DBIF
{
    // MARK: - Region table handling.
    
    /// Reads all of the regions in the table and returns them.
    /// - Returns: Array of regions in the region table.
    public static func GetRegions() -> [UserRegion]
    {
        var Results = [UserRegion]()
        
        let GetQuery = "SELECT * FROM \(MappableTableNames.Regions.rawValue)"
        let QuerySetupResult = SQL.SetupQuery(For: DBIF.MappableHandle, Query: GetQuery)
        var QueryHandle: OpaquePointer? = nil
        switch QuerySetupResult
        {
            case .success(let Handle):
                QueryHandle = Handle
                
            case .failure(let Why):
                Debug.Print("Failure creating query for user regions: \(Why)")
                let (Message, Value) = SQL.ExtendedError(From: DBIF.MappableHandle)
                Debug.Print("  \(Message) [\(Value)]")
                return [UserRegion]()
        }
        
        while (sqlite3_step(QueryHandle) == SQLITE_ROW)
        {
            let RegionPK = SQL.ReadIntColumn(Handle: QueryHandle, Index: RegionColumns.RegionPK.rawValue)!
            let RegionName = SQL.ReadStringColumn(Handle: QueryHandle, Index: RegionColumns.RegionName.rawValue)!
            let RegionColor = SQL.ReadColorColumn(Handle: QueryHandle, Index: RegionColumns.RegionColor.rawValue)!
            let BorderWidth = SQL.ReadDoubleColumn(Handle: QueryHandle, Index: RegionColumns.BorderWidth.rawValue)!
            let ULLat = SQL.ReadDoubleColumn(Handle: QueryHandle, Index: RegionColumns.UpperLeftLatitude.rawValue)!
            let ULLon = SQL.ReadDoubleColumn(Handle: QuakeHandle, Index: RegionColumns.UpperLeftLongitude.rawValue)!
            let UpperLeft = GeoPoint(ULLat, ULLon)
            let LRLat = SQL.ReadDoubleColumn(Handle: QueryHandle, Index: RegionColumns.LowerRightLatitude.rawValue)!
            let LRLon = SQL.ReadDoubleColumn(Handle: QueryHandle, Index: RegionColumns.LowerRightLongitude.rawValue)!
            let LowerRight = GeoPoint(LRLat, LRLon)
            let MinMag = SQL.ReadDoubleColumn(Handle: QueryHandle, Index: RegionColumns.MinimumMagnitude.rawValue)!
            let MaxMag = SQL.ReadDoubleColumn(Handle: QueryHandle, Index: RegionColumns.MaximumMagnitude.rawValue)!
            let Age = SQL.ReadIntColumn(Handle: QueryHandle, Index: RegionColumns.Age.rawValue)!
            let Notification = SQL.ReadStringColumn(Handle: QueryHandle, Index: RegionColumns.Notification.rawValue)!
            let SoundName = SQL.ReadStringColumn(Handle: QueryHandle, Index: RegionColumns.SoundName.rawValue)!
            let IsFallback = SQL.ReadBoolColumn(Handle: QueryHandle, Index: RegionColumns.IsFallback.rawValue)!
            let IsEnabled = SQL.ReadBoolColumn(Handle: QueryHandle, Index: RegionColumns.IsEnabled.rawValue)!
            let NotifyOnNewQuakes = SQL.ReadBoolColumn(Handle: QuakeHandle, Index: RegionColumns.IsEnabled.rawValue)!
            let IsRectangular = SQL.ReadBoolColumn(Handle: QuakeHandle, Index: RegionColumns.IsRectangular.rawValue)!
            let CLat = SQL.ReadDoubleColumn(Handle: QuakeHandle, Index: RegionColumns.CenterLatitude.rawValue)!
            let CLon = SQL.ReadDoubleColumn(Handle: QuakeHandle, Index: RegionColumns.CenterLongitude.rawValue)!
            let Center = GeoPoint(CLat, CLon)
            let Radius = SQL.ReadDoubleColumn(Handle: QuakeHandle, Index: RegionColumns.Radius.rawValue)!
            let RegionID = SQL.ReadUUIDColumn(Handle: QuakeHandle, Index: RegionColumns.RegionID.rawValue)!
            
            let Region = UserRegion()
            Region.RegionPK = RegionPK
            Region.RegionName = RegionName
            Region.RegionColor = RegionColor
            Region.BorderWidth = BorderWidth
            Region.UpperLeft = UpperLeft
            Region.LowerRight = LowerRight
            Region.MinimumMagnitude = MinMag
            Region.MaximumMagnitude = MaxMag
            Region.Age = Age
            if let Notice = EarthquakeNotifications(rawValue: Notification)
            {
                Region.Notification = Notice
            }
            else
            {
                Region.Notification = .None
            }
            if let Sound = NotificationSounds(rawValue: SoundName)
            {
                Region.SoundName = Sound
            }
            else
            {
                Region.SoundName = .None
            }
            Region.IsFallback = IsFallback
            Region.IsEnabled = IsEnabled
            Region.NotifyOnNewEarthquakes = NotifyOnNewQuakes
            Region.IsRectangular = IsRectangular
            Region.Center = Center
            Region.Radius = Radius
            Region.ID = RegionID
            
            Results.append(Region)
        }
        
        return Results
    }
}
