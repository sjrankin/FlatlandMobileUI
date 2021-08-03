//
//  +POIDatabase.swift
//  Flatland
//
//  Created by Stuart Rankin on 10/18/20. Adapted from Flatland View.
//  Copyright © 2020, 2021 Stuart Rankin. All rights reserved.
//

import Foundation
import UIKit
import SQLite3

extension MainController
{
    /// Returns the number of items in the specified database.
    /// - Parameter For: The specified database.
    /// - Returns: Result with the number of items on success, a database error on failure.
    public static func ItemCount(For: POITableNames) -> Result<Int, DatabaseErrors>
    {
        var TableName = ""
        switch For
        {
            case .Home:
                return .failure(.InvalidTable)
                
            case .POI:
                TableName = For.rawValue
                
            case .UserPOI:
                TableName = For.rawValue
        }
        let GetCount = "SELECT COUNT(*) FROM \(TableName)"
        var CountQuery: OpaquePointer? = nil
        if sqlite3_prepare(MainController.POIHandle, GetCount, -1, &CountQuery, nil) == SQLITE_OK
        {
            while sqlite3_step(CountQuery) == SQLITE_ROW
            {
                let Count = sqlite3_column_int(CountQuery, 0)
                return .success(Int(Count))
            }
        }
        return .failure(.QueryPreparationError)
    }
    
    public static func GetAllHomes() -> [POI2]
    {
        var Results = [POI2]()
        let GetQuery = "SELECT * FROM \(POITableNames.Home.rawValue)"
        let QueryHandle = SetupQuery(DB: POIHandle, Query: GetQuery)
        while (sqlite3_step(QueryHandle) == SQLITE_ROW)
        {
            let PKID = ReadIntColumn(Handle: QueryHandle, Index: HomeColumns.ID.rawValue)!
            let HomeID = ReadUUIDColumn(Handle: QueryHandle, Index: HomeColumns.HomeID.rawValue)!
            let Name = ReadStringColumn(Handle: QueryHandle, Index: HomeColumns.Name.rawValue)!
            let Description = ReadStringColumn(Handle: QueryHandle, Index: HomeColumns.Description.rawValue)!
            let Latitude = ReadDoubleColumn(Handle: QueryHandle, Index: HomeColumns.Latitude.rawValue)!
            let Longitude = ReadDoubleColumn(Handle: QueryHandle, Index: HomeColumns.Longitude.rawValue)!
            let HomeColor = ReadColorColumn(Handle: QueryHandle, Index: HomeColumns.Color.rawValue)!
            let Shape = ReadStringColumn(Handle: QueryHandle, Index: HomeColumns.Shape.rawValue)!
            let HomeType = ReadIntColumn(Handle: QueryHandle, Index: HomeColumns.HomeType.rawValue)!
            let Numeric = ReadDoubleColumn(Handle: QueryHandle, Index: HomeColumns.Numeric.rawValue)!
            let Added = ReadDateColumn(Handle: QueryHandle, Index: HomeColumns.Added.rawValue)!
            let Modified = ReadDateColumn(Handle: QueryHandle, Index: HomeColumns.Added.rawValue)!
            let ShowHome = ReadBoolColumn(Handle: QueryHandle, Index: HomeColumns.Show.rawValue)!
            let HPOI = POI2(Meta: .User, PKID, HomeID, Name, Description, Latitude, Longitude,
                            HomeColor, Shape, HomeType, Numeric, nil, nil, Added, Modified,
                            ShowHome)
            Results.append(HPOI)
        }
        return Results
    }
    
    public static func POIExistsIn(Table: String, PK: Int) -> Bool
    {
        var CountQuery: OpaquePointer? = nil
        let QueryString = "SELECT COUNT(*) FROM \(Table) WHERE ID=\(PK)"
        if sqlite3_prepare(MainController.POIHandle, QueryString, -1, &CountQuery, nil) == SQLITE_OK
        {
            while sqlite3_step(CountQuery) == SQLITE_ROW
            {
                let Count = sqlite3_column_int(CountQuery, 0)
                return Int(Count) == 1 ? true : false
            }
        }
        return false
    }
    
    public static func SaveHomes(_ Homes: [POI2])
    {
        
    }
    
    public static func GetAllUserPOIs() -> [POI2]
    {
        #if false
        var Results = [POI2]()
        let GetQuery = "SELECT * FROM \(POITableNames.UserPOI.rawValue)"
        let QueryHandle = SetupQuery(DB: POIHandle, Query: GetQuery)
        while (sqlite3_step(QueryHandle) == SQLITE_ROW)
        {
            let PKID = ReadIntColumn(Handle: QueryHandle, Index: POIColumns2.ID.rawValue)!
            let POIID = ReadUUIDColumn(Handle: QueryHandle, Index: POIColumns2.POIID.rawValue)!
            let Name = ReadStringColumn(Handle: QueryHandle, Index: POIColumns2.Name.rawValue)!
            let Description = ReadStringColumn(Handle: QueryHandle, Index: POIColumns2.Description.rawValue)!
            let Latitude = ReadDoubleColumn(Handle: QueryHandle, Index: POIColumns2.Latitude.rawValue)!
            let Longitude = ReadDoubleColumn(Handle: QueryHandle, Index: POIColumns2.Longitude.rawValue)!
            let Color = ReadColorColumn(Handle: QueryHandle, Index: POIColumns2.Color.rawValue, Default: NSColor.yellow)
            let Shape = ReadStringColumn(Handle: QueryHandle, Index: POIColumns2.Shape.rawValue)!
            let POIType = ReadIntColumn(Handle: QueryHandle, Index: POIColumns2.HomeType.rawValue)!
            let Numeric = ReadDoubleColumn(Handle: QueryHandle, Index: POIColumns2.Numeric.rawValue)!
            let Added = ReadDateColumn(Handle: QueryHandle, Index: POIColumns2.Added.rawValue)!
            let Modified = ReadDateColumn(Handle: QueryHandle, Index: POIColumns2.Added.rawValue)!
            let Category = ReadStringColumn(Handle: QueryHandle, Index: POIColumns2.Category.rawValue, Default: "")
            let SubCategory = ReadStringColumn(Handle: QueryHandle, Index: POIColumns2.Category.rawValue, Default: "")
            let ShowPOI = ReadBoolColumn(Handle: QueryHandle, Index: POIColumns2.Show.rawValue)!
            let UPOI = POI2(Meta: .User, PKID, POIID, Name, Description, Latitude, Longitude,
                            Color, Shape, POIType, Numeric, Category, SubCategory,
                            Added, Modified, ShowPOI)
            Results.append(UPOI)
        }
        return Results
        #else
        return [POI2]()
        #endif
    }
    
    public static func GetAllBuiltInPOIs() -> [POI2]
    {
        #if false
        var Results = [POI2]()
        let GetQuery = "SELECT * FROM \(POITableNames.POI.rawValue)"
        let QueryHandle = SetupQuery(DB: POIHandle, Query: GetQuery)
        while (sqlite3_step(QueryHandle) == SQLITE_ROW)
        {
            let PKID = ReadIntColumn(Handle: QueryHandle, Index: POIColumns2.ID.rawValue)!
            let POIID = ReadUUIDColumn(Handle: QueryHandle, Index: POIColumns2.POIID.rawValue)!
            let Name = ReadStringColumn(Handle: QueryHandle, Index: POIColumns2.Name.rawValue)!
            let Description = ReadStringColumn(Handle: QueryHandle, Index: POIColumns2.Description.rawValue)!
            let Latitude = ReadDoubleColumn(Handle: QueryHandle, Index: POIColumns2.Latitude.rawValue)!
            let Longitude = ReadDoubleColumn(Handle: QueryHandle, Index: POIColumns2.Longitude.rawValue)!
            let HomeColor = ReadColorColumn(Handle: QueryHandle, Index: POIColumns2.Color.rawValue, Default: NSColor.yellow)
            let Shape = ReadStringColumn(Handle: QueryHandle, Index: POIColumns2.Shape.rawValue)!
            let POIType = ReadIntColumn(Handle: QueryHandle, Index: POIColumns2.HomeType.rawValue)!
            let Numeric = ReadDoubleColumn(Handle: QueryHandle, Index: POIColumns2.Numeric.rawValue)!
            let Added = ReadDateColumn(Handle: QueryHandle, Index: POIColumns2.Added.rawValue)!
            let Modified = ReadDateColumn(Handle: QueryHandle, Index: POIColumns2.Added.rawValue)!
            let Category = ReadStringColumn(Handle: QueryHandle, Index: POIColumns2.Category.rawValue, Default: "")
            let SubCategory = ReadStringColumn(Handle: QueryHandle, Index: POIColumns2.Category.rawValue, Default: "")
            let ShowPOI = ReadBoolColumn(Handle: QueryHandle, Index: POIColumns2.Show.rawValue)!
            let UPOI = POI2(Meta: .User, PKID, POIID, Name, Description, Latitude, Longitude,
                            HomeColor, Shape, POIType, Numeric, Category, SubCategory,
                            Added, Modified, ShowPOI)
            Results.append(UPOI)
        }
        return Results
        #else
        return [POI2]()
        #endif
    }
    
    @discardableResult public static func DeleteRowIn(Table: String, PK: Int) -> Bool
    {
        let Delete = "DELETE FROM \(Table) WHERE ID=\(PK)"
        var DeleteCommand: OpaquePointer? = nil
        if sqlite3_prepare(MainController.POIHandle, Delete, -1, &DeleteCommand, nil) == SQLITE_OK
        {
            while sqlite3_step(DeleteCommand) == SQLITE_ROW
            {
                return true
            }
        }
        return false
    }
    
    public static func InsertHomeData(Into Table: String, _ SomePOI: POI2)
    {
        let ColumnList = MakeColumnList(["HomeID", "Name", "Description", "Latitude", "Longitude", "Color",
                                         "Shape", "HomeType", "Numeric", "Added", "Modified"])
        var InsertCommand = "INSERT INTO \(Table) \(ColumnList) VALUES("
        InsertCommand.append("'\(SomePOI.ID.uuidString)', ")
        InsertCommand.append("'\(SomePOI.Name)', ")
        InsertCommand.append("'\(SomePOI.Description)', ")
        InsertCommand.append("'\(SomePOI.Latitude)', ")
        InsertCommand.append("'\(SomePOI.Longitude)', ")
        InsertCommand.append("'\(SomePOI.Color.Hex)', ")
        InsertCommand.append("'\(SomePOI.Shape)', ")
        InsertCommand.append("'\(SomePOI.POIType)', ")
        InsertCommand.append("'\(SomePOI.Numeric)', ")
        var AddDate = ""
        if let TheAddDate = SomePOI.Added
        {
            AddDate = TheAddDate.PrettyDate()
        }
        InsertCommand.append("'\(AddDate)', ")
        var ModDate = ""
        if let TheModDate = SomePOI.Modified
        {
            ModDate = TheModDate.PrettyDate()
        }
        InsertCommand.append("'\(ModDate)'")
        InsertCommand.append(")")
        var Insert: OpaquePointer? = nil
        if sqlite3_prepare_v2(POIHandle, InsertCommand, -1, &Insert, nil) != SQLITE_OK
        {
            let (Message, Code) = ExtendedError(From: Insert)
            fatalError("Error preparing \(InsertCommand): \(Message) [\(Code)]")
        }
        let Result = sqlite3_step(Insert)
        if Result != SQLITE_DONE
        {
            let (Message, Code) = ExtendedError(From: Insert)
            fatalError("Error inserting row for POI ID: \(SomePOI.ID.uuidString): \(Message) [\(Code)]")
        }
    }
    
    public static func InsertPOIData(Into Table: String, _ SomePOI: POI2)
    {
        let ColumnList = MakeColumnList(["POIID", "Name", "Description", "Latitude", "Longitude", "Color",
        "Shape", "POIType", "Numeric", "Category", "SubCategory", "Added", "Modified"])
        var InsertCommand = "INSERT INTO \(Table) \(ColumnList) VALUES("
        InsertCommand.append("'\(SomePOI.ID.uuidString)', ")
        InsertCommand.append("'\(SomePOI.Name)', ")
        InsertCommand.append("'\(SomePOI.Description)', ")
        InsertCommand.append("'\(SomePOI.Latitude)', ")
        InsertCommand.append("'\(SomePOI.Longitude)', ")
        InsertCommand.append("'\(SomePOI.Color.Hex)', ")
        InsertCommand.append("'\(SomePOI.Shape)', ")
        InsertCommand.append("'\(SomePOI.POIType)', ")
        InsertCommand.append("'\(SomePOI.Numeric)', ")
        var Category = ""
        if let TheCategory = SomePOI.Category
        {
            Category = TheCategory
        }
        InsertCommand.append("'\(Category)', ")
        var SubCategory = ""
        if let TheSubCategory = SomePOI.SubCategory
        {
            SubCategory = TheSubCategory
        }
        InsertCommand.append("'\(SubCategory)', ")
        var AddDate = ""
        if let TheAddDate = SomePOI.Added
        {
            AddDate = TheAddDate.PrettyDate()
        }
        InsertCommand.append("'\(AddDate)', ")
        var ModDate = ""
        if let TheModDate = SomePOI.Modified
        {
            ModDate = TheModDate.PrettyDate()
        }
        InsertCommand.append("'\(ModDate)'")
        InsertCommand.append(")")
        var Insert: OpaquePointer? = nil
        if sqlite3_prepare_v2(POIHandle, InsertCommand, -1, &Insert, nil) != SQLITE_OK
        {
            let (Message, Code) = ExtendedError(From: Insert)
            fatalError("Error preparing \(InsertCommand): \(Message) [\(Code)]")
        }
        let Result = sqlite3_step(Insert)
        if Result != SQLITE_DONE
        {
            let (Message, Code) = ExtendedError(From: Insert)
            fatalError("Error inserting row for POI ID: \(SomePOI.ID.uuidString): \(Message) [\(Code)]")
        }
    }
    
    public static func SaveUserPOIs(_ POIs: [POI2])
    {
        for UPOI in POIs
        {
            if UPOI.IsNew
            {
                InsertPOIData(Into: POITableNames.UserPOI.rawValue, UPOI)
                continue
            }
            if UPOI.DeleteMe && POIExistsIn(Table: POITableNames.UserPOI.rawValue, PK: UPOI.PKID)
            {
                DeleteRowIn(Table: POITableNames.UserPOI.rawValue, PK: UPOI.PKID)
                continue
            }
            if UPOI.IsDirty && POIExistsIn(Table: POITableNames.UserPOI.rawValue, PK: UPOI.PKID)
            {
                
            }
        }
    }
}
