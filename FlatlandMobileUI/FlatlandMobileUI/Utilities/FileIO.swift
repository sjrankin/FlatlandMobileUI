//
//  FileIO.swift
//  FileIO
//
//  Created by Stuart Rankin on 7/18/21. Adapted from Flatland View.
//

import Foundation
import UIKit
import ImageIO

/// Class to help with file I/O operations.
class FileIO
{
    /// Initialize needed file structures and databases.
    /// - Warning: This function *must* be called prior to using external maps, the earthquake history database,
    ///            and World Heritage Sites. If any is used prior to calling this function, Flatland will be in
    ///            an undefined state.
    public static func Initialize()
    {
        InitializeFileStructure()
    }
    
    /// Install databases if not already installed.
    public static func InstallDatabases()
    {
        InstallDatabase(Name: FileIONames.QuakeHistoryDatabaseS.rawValue)
        InstallDatabase(Name: FileIONames.MappableDatabaseS.rawValue)
        InstallDatabase(Name: FileIONames.Settings.rawValue)
        InstallDatabase(Name: FileIONames.CachedLocations.rawValue)
    }
    
    public static func InstallDatabase(Name: String)
    {
        Debug.Print("Checking existence of the database \(Name)")
        var DBPath: URL!
        if !DirectoryExists(DatabaseDirectory)
        {
            do
            {
                DBPath = GetDocumentDirectory()?.appendingPathComponent(DatabaseDirectory)
                try FileManager.default.createDirectory(atPath: DBPath!.path, withIntermediateDirectories: true,
                                                        attributes: nil)
                Debug.Print("Created database directory \(DBPath!.path)")
            }
            catch
            {
                Debug.FatalError("Error creating database directory \"\(DatabaseDirectory)\"")
            }
        }
        let PathComponent = DatabaseDirectory + "/" + Name
        let LookForExisting = GetDocumentDirectory()!.appendingPathComponent(PathComponent)
        if FileManager.default.fileExists(atPath: LookForExisting.path)
        {
            //Debug.Print("\"\(Name)\" exists at \(LookForExisting.path)")
            return
        }
        let Parts = Name.split(separator: ".", omittingEmptySubsequences: true)
        if Parts.count != 2
        {
            Debug.FatalError("Invalid name: \(Name). Must have name part and extension part.")
        }
        let FileName = String(Parts[0])
        let ExtensionName = String(Parts[1])
        if let Source = Bundle.main.path(forResource: FileName,
                                         ofType: ExtensionName)
        {
            let SourceURL = URL(fileURLWithPath: Source)
            let DestDir = GetDocumentDirectory()!.appendingPathComponent(PathComponent)
            do
            {
                try FileManager.default.copyItem(at: SourceURL, to: DestDir)
                Debug.Print("Installed \(FileName) database.")
            }
            catch
            {
                Debug.FatalError("Error copying database. \(error.localizedDescription)")
            }
        }
        else
        {
            Debug.FatalError("Did not find \(Name) in bundle.")
        }
    }
    
    public static let AppDirectory = FileIONames.AppDirectory.rawValue
    public static let MapDirectory = FileIONames.MapDirectory.rawValue
    public static let SoundDirectory = FileIONames.SoundDirectory.rawValue
    public static let PictureDirectory = FileIONames.PictureDirectory.rawValue
    #if DEBUG
    public static let ExCmdDirectory = FileIONames.CommandDirectory.rawValue
    #endif
    
    /// Initialize the file structure we need in the user's Documents directory.
    public static func InitializeFileStructure()
    {
        let DocDirURL = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first!
        let ImageDirURL = DocDirURL.appendingPathComponent(PictureDirectory)
        Debug.Print("Verifying \(PictureDirectory)")
        if !DirectoryExists(ImageDirURL.path)
        {
            do
            {
                try FileManager.default.createDirectory(atPath: ImageDirURL.path, withIntermediateDirectories: true, attributes: nil)
            }
            catch
            {
                Debug.Print("Error creating \(PictureDirectory) in Documents: \(error.localizedDescription)")
                return
            }
        }
        let AppDirURL = DocDirURL.appendingPathComponent(AppDirectory)
        Debug.Print("Verifying \(AppDirectory)")
        if !DirectoryExists(AppDirURL.path)
        {
            do
            {
                try FileManager.default.createDirectory(atPath: AppDirURL.path, withIntermediateDirectories: true, attributes: nil)
            }
            catch
            {
                Debug.Print("Error creating \(AppDirectory) in Documents: \(error.localizedDescription)")
                return
            }
        }
        let MapsURL = DocDirURL.appendingPathComponent(MapDirectory)
        Debug.Print("Verifying \(MapDirectory)")
        if !DirectoryExists(MapsURL.path)
        {
            do
            {
                try FileManager.default.createDirectory(atPath: MapsURL.path, withIntermediateDirectories: true, attributes: nil)
                let SatelliteList = MapManager.GetMapsInCategory(.Satellite)
                let SatNames = SatelliteList.map({"\($0)"})
                AddSubDirectories(To: MapsURL, SubDirectory: SatNames)
            }
            catch
            {
                Debug.Print("Error creating \(MapDirectory) in Documents: \(error.localizedDescription)")
                return
            }
        }
        #if DEBUG
        let ECmdURL = DocDirURL.appendingPathComponent(ExCmdDirectory)
        Debug.Print("Verifying \(ExCmdDirectory)")
        if !DirectoryExists(ECmdURL.path)
        {
            do
            {
                try FileManager.default.createDirectory(atPath: ECmdURL.path, withIntermediateDirectories: true, attributes: nil)
            }
            catch
            {
                Debug.Print("Error creating \(ExCmdDirectory) in Documents: \(error.localizedDescription)")
                return
            }
        }
        #endif
#if false
        let SoundsURL = DocDirURL.appendingPathComponent(SoundDirectory)
        Debug.Print("Verifying \(SoundDirectory)")
        if !DirectoryExists(SoundsURL.path)
        {
            do
            {
                try FileManager.default.createDirectory(atPath: SoundsURL.path, withIntermediateDirectories: true, attributes: nil)
            }
            catch
            {
                Debug.Print("Error creating \(SoundDirectory) in Documents: \(error.localizedDescription)")
                return
            }
        }
#endif
    }
    
    /// Get the contents of the external commands directory.
    /// - Notes:
    ///   - Once the contents are read, the directory is cleared of all contents.
    ///   - This function only provides values if running with `#DEBUG` as true.
    /// - Returns: Array of commands found in the external command directory. If no recognized commands
    ///            found, nil is returned. **If run in release mode, nil is always returned.**
    public static func GetExCommands() -> [ExCommands]?
    {
        #if DEBUG
        let DocDirURL = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first!
        let ECmdURL = DocDirURL.appendingPathComponent(ExCmdDirectory)
        let FilesFound = FilesIn(Directory: ECmdURL)
        var CommandsFound = [ExCommands]()
        for FileURL in FilesFound
        {
            let FileName = FileURL.lastPathComponent
            if let TestValue = ExCommands(rawValue: FileName)
            {
                if ExCommands.allCases.contains(TestValue)
                {
                    CommandsFound.append(TestValue)
                }
            }
        }
        DeleteContentsOf(Directory: ECmdURL)
        if CommandsFound.isEmpty
        {
            return nil
        }
        return CommandsFound
        #else
        return nil
        #endif
    }
    
    /// Get a cached satellite image in the specified directory.
    /// - Parameter In: The type of satellite image to return. Each satellite map type has its own sub-directory
    ///                 keyed against the `MapTypes` enum. There should be only one file in each sub-directory.
    /// - Parameter PerformRemedial: If true, sub-directories that have more than one image are cleared. Sub-
    ///                              directories that have invalid contents are cleared. Defaults to `true`.
    /// - Returns: The cached satellite image on success, nil if not found or on error.
    public static func GetCachedImage(In Directory: MapTypes, PerformRemedial: Bool = true) -> UIImage?
    {
        let DocDirURL = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first!
        let ImageDirURL = DocDirURL.appendingPathComponent(MapDirectory)
        if !FileManager.default.fileExists(atPath: ImageDirURL.path)
        {
            Debug.Print("\(#function): The directory \(ImageDirURL.path) does not exist.")
            return nil
        }
        let SubDirName = "\(Directory)"
        let SubDir = ImageDirURL.appendingPathComponent(SubDirName)
        if !FileManager.default.fileExists(atPath: SubDir.path)
        {
            Debug.Print("\(#function): The directory \(SubDir.path) does not exist.")
            return nil
        }
        //There should be only one file in the sub-directory...
        let Contents = FilesIn(Directory: SubDir)
        if Contents.isEmpty
        {
            return nil
        }
        if Contents.count > 1 && PerformRemedial
        {
            Debug.Print("\(#function): Too many items in \(SubDir.path) - deleting contents.")
            DeleteContentsOf(Directory: SubDir)
            return nil
        }
        if Contents[0].pathExtension.lowercased() == "png"
        {
            #if true
            let url = Contents[0]
            let data = try? Data(contentsOf: url)
            let Image = UIImage(data: data!)
            #else
            let Image = UIImage(contentsOf: Contents[0])
            #endif
            return Image
        }
        else
        {
            if PerformRemedial
            {
                Debug.Print("\(#function): Unrecognized file type for \(Contents[0].path): deleting contents.")
                DeleteContentsOf(Directory: SubDir)
            }
            return nil
        }
    }
    
    /// Save a satellite image to the appropriate sub-directory.
    /// - Parameter In: Indicates which sub-directory to use to store the satellite map.
    /// - Parameter Map: The satellite map image to store.
    /// - Parameter InitialClear: If true, the sub-directory associated with the map type is cleared of
    ///                           contents before the image is cached. Defaults to `true`.
    /// - Returns: True on success, false on failure.
    @discardableResult public static func SetCachedImage(In Directory: MapTypes, Map Image: UIImage,
                                                         InitialClear: Bool = true) -> Bool
    {
        let DocDirURL = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first!
        let ImageDirURL = DocDirURL.appendingPathComponent(MapDirectory)
        if !FileManager.default.fileExists(atPath: ImageDirURL.path)
        {
            Debug.Print("\(#function): The directory \(ImageDirURL.path) does not exist.")
            return false
        }
        let SubDirName = "\(Directory)"
        let SubDir = ImageDirURL.appendingPathComponent(SubDirName)
        if !FileManager.default.fileExists(atPath: SubDir.path)
        {
            Debug.Print("\(#function): The directory \(SubDir.path) does not exist.")
            return false
        }
        if InitialClear
        {
            DeleteContentsOf(Directory: SubDir)
        }
        let FileDate = Date.PrettyDateTime(From: Date(), IncludeSeconds: false, ForFileName: true)
        let FileName = "\(Directory)-\(FileDate).png"
        let FinalURL = SubDir.appendingPathComponent(FileName)
        Image.WritePNG(ToURL: FinalURL)
        return true
    }
    
    /// Return an array of non-hidden file objects in the passed directory.
    /// - Parameter Directory: The directory whose non-hidden items are returned.
    /// - Returns: Array of file item URLs.
    public static func FilesIn(Directory: URL) -> [URL]
    {
        var FileList = [URL]()
        do
        {
            let Items = try FileManager.default.contentsOfDirectory(at: Directory, includingPropertiesForKeys: nil, options: .skipsHiddenFiles)
            for Item in Items
            {
                FileList.append(Item)
            }
        }
        catch
        {
            Debug.Print("Error getting contents of \(Directory.path): \(error.localizedDescription)")
        }
        return FileList
    }
    
    /// Deletes the contents of the passed directory. Only non-hidden items are deleted.
    /// - Parameter Directory: The URL of the directory to clear.
    public static func DeleteContentsOf(Directory: URL)
    {
        let AllFiles = FilesIn(Directory: Directory)
        if AllFiles.isEmpty
        {
            return
        }
        do
        {
            for File in AllFiles
            {
                if FileManager.default.fileExists(atPath: File.path)
                {
                    try FileManager.default.removeItem(at: File)
                }
            }
        }
        catch
        {
            Debug.Print("Error deleting files: \(error.localizedDescription)")
        }
    }
    
    /// Add a list of sub-directories to the passed parent directory.
    /// - Parameter To: The parent directory URL.
    /// - Parameter SubDirectory: Array of sub-directory names.
    public static func AddSubDirectories(To Directory: URL, SubDirectory Names: [String])
    {
        for Name in Names
        {
            let NameDirectory = Directory.appendingPathComponent(Name)
            if !DirectoryExists(NameDirectory.path)
            {
                do
                {
                    try FileManager.default.createDirectory(atPath: NameDirectory.path, withIntermediateDirectories: true,
                                                            attributes: nil)
                }
                catch
                {
                    Debug.Print("Error creating \(NameDirectory.path): \(error.localizedDescription)")
                }
            }
        }
    }
    
    #if false
    /// Read the contents of the map structure file.
    /// - Note: The name of the file is defined in `FileIONames.MapStructure`.
    /// - Returns: The contents of the map structure file. Nil on error.
    public static func GetMapStructure() -> String?
    {
        let DocDirURL = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first!
        let AppDirURL = DocDirURL.appendingPathComponent(AppDirectory)
        let FileURL = AppDirURL.appendingPathComponent(FileIONames.MapStructure.rawValue)
        do
        {
            let Raw = try String(contentsOf: FileURL, encoding: .utf8)
            return Raw
        }
        catch
        {
            print("Error reading contents of \(FileURL.path): \(error.localizedDescription)")
        }
        return nil
    }
    
    /// Write the contents of the passed string to the map structure file.
    /// - Note: The name of the file is defined in `FileIONames.MapStructure`.
    /// - Parameter SaveMe: The string to save to the map structure file.
    public static func SetMapStructure(_ SaveMe: String)
    {
        let DocDirURL = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first!
        let AppDirURL = DocDirURL.appendingPathComponent(AppDirectory)
        let FileURL = AppDirURL.appendingPathComponent(FileIONames.MapStructure.rawValue)
        do
        {
            try SaveMe.write(to: FileURL, atomically: false, encoding: .utf8)
        }
        catch
        {
            print("Error writing to \(FileIONames.MapStructure.rawValue): \(error.localizedDescription)")
        }
    }
    #endif
    
    public static let DatabaseDirectory = FileIONames.DatabaseDirectory.rawValue
    
    /// Make sure the mappable site database is installed.
    /// - Warning: Fatal errors will be generated on file errors.
    public static func InstallMappableDatabase()
    {
        var DBPath: URL!
        if !DirectoryExists(DatabaseDirectory)
        {
            do
            {
                DBPath = GetDocumentDirectory()?.appendingPathComponent(DatabaseDirectory)
                try FileManager.default.createDirectory(atPath: DBPath!.path, withIntermediateDirectories: true,
                                                        attributes: nil)
                Debug.Print("Created database directory \(DBPath!.path)")
            }
            catch
            {
                fatalError("Error creating database directory \"\(DatabaseDirectory)\"")
            }
        }
        let PathComponent = DatabaseDirectory + "/" + FileIONames.MappableDatabase.rawValue
        let LookForExisting = GetDocumentDirectory()!.appendingPathComponent(PathComponent)
        if FileManager.default.fileExists(atPath: LookForExisting.path)
        {
            //Debug.Print("\"\(FileIONames.MappableDatabase.rawValue)\" exists at \(LookForExisting.path)")
            return
        }
        if let Source = Bundle.main.path(forResource: FileIONames.MappableName.rawValue,
                                         ofType: FileIONames.DatabaseExtension.rawValue)
        {
            let SourceURL = URL(fileURLWithPath: Source)
            let DestDir = GetDocumentDirectory()!.appendingPathComponent(PathComponent)
            do
            {
                try FileManager.default.copyItem(at: SourceURL, to: DestDir)
                Debug.Print("Installed \(FileIONames.MappableName) database.")
            }
            catch
            {
                fatalError("Error copying database. \(error.localizedDescription)")
            }
        }
        else
        {
            fatalError("Did not find \(FileIONames.MappableDatabase.rawValue) in bundle.")
        }
    }
    
    /// Make sure the POI site database is installed.
    /// - Warning: Fatal errors will be generated on file errors.
    public static func InstallPOIDatabase()
    {
        var DBPath: URL!
        if !DirectoryExists(DatabaseDirectory)
        {
            do
            {
                DBPath = GetDocumentDirectory()?.appendingPathComponent(DatabaseDirectory)
                try FileManager.default.createDirectory(atPath: DBPath!.path, withIntermediateDirectories: true,
                                                        attributes: nil)
                Debug.Print("Created database directory \(DBPath!.path)")
            }
            catch
            {
                fatalError("Error creating database directory \"\(DatabaseDirectory)\"")
            }
        }
        let PathComponent = DatabaseDirectory + "/" + FileIONames.POIDatabase.rawValue
        let LookForExisting = GetDocumentDirectory()!.appendingPathComponent(PathComponent)
        if FileManager.default.fileExists(atPath: LookForExisting.path)
        {
            //Debug.Print("\"\(FileIONames.POIDatabase.rawValue)\" exists at \(LookForExisting.path)")
            return
        }
        if let Source = Bundle.main.path(forResource: FileIONames.POIName.rawValue,
                                         ofType: FileIONames.DatabaseExtension.rawValue)
        {
            let SourceURL = URL(fileURLWithPath: Source)
            let DestDir = GetDocumentDirectory()!.appendingPathComponent(PathComponent)
            do
            {
                try FileManager.default.copyItem(at: SourceURL, to: DestDir)
                Debug.Print("Installed \(FileIONames.POIName) database.")
            }
            catch
            {
                fatalError("Error copying database. \(error.localizedDescription)")
            }
        }
        else
        {
            fatalError("Did not find \(FileIONames.POIDatabase.rawValue) in bundle.")
        }
    }
    
    /// Make sure the earthquake history database is installed. If not installed, an empty database will be
    /// installed.
    /// - Warning: Fatal errors will be generated on file errors.
    public static func InstallEarthquakeHistoryDatabase()
    {
        var DBPath: URL!
        if !DirectoryExists(DatabaseDirectory)
        {
            do
            {
                DBPath = GetDocumentDirectory()?.appendingPathComponent(DatabaseDirectory)
                try FileManager.default.createDirectory(atPath: DBPath!.path, withIntermediateDirectories: true,
                                                        attributes: nil)
            }
            catch
            {
                Debug.FatalError("Error creating database directory \"\(DatabaseDirectory)\"")
            }
        }
        let PathComponent = DatabaseDirectory + "/" + FileIONames.QuakeHistoryDatabase.rawValue
        let LookForExisting = GetDocumentDirectory()!.appendingPathComponent(PathComponent)
        if FileManager.default.fileExists(atPath: LookForExisting.path)
        {
            return
        }
        if let Source = Bundle.main.path(forResource: FileIONames.QuakeName.rawValue,
                                         ofType: FileIONames.DatabaseExtension.rawValue)
        {
            let SourceURL = URL(fileURLWithPath: Source)
            let DestDir = GetDocumentDirectory()!.appendingPathComponent(PathComponent)
            do
            {
                try FileManager.default.copyItem(at: SourceURL, to: DestDir)
            }
            catch
            {
                Debug.FatalError("Error copying database. \(error.localizedDescription)")
            }
        }
        else
        {
            Debug.FatalError("Did not find \(FileIONames.QuakeHistoryDatabase.rawValue) in bundle.")
        }
    }
    
    /// Returns the URL for the mappable database.
    /// - Returns: URL of the mappable database on success, nil if not found.
    public static func GetMappableDatabaseURL() -> URL?
    {
        let PathComponent = DatabaseDirectory + "/" + FileIONames.MappableDatabase.rawValue
        let DBURL = GetDocumentDirectory()!.appendingPathComponent(PathComponent)
        return DBURL
    }
    
    public static func GetMappableDatabaseSURL() -> URL?
    {
        let PathComponent = DatabaseDirectory + "/" + FileIONames.MappableDatabaseS.rawValue
        let DBURL = GetDocumentDirectory()!.appendingPathComponent(PathComponent)
        return DBURL
    }
    
    public static func GetReverseGeocodingCacheURL() -> URL?
    {
        let PathComponent = DatabaseDirectory + "/" + FileIONames.CachedLocations.rawValue
        let DBURL = GetDocumentDirectory()!.appendingPathComponent(PathComponent)
        return DBURL
    }
    
    /// Returns the URL for the POI database.
    /// - Returns: URL of the POI database on success, nil if not found.
    public static func GetPOIDatabaseURL() -> URL?
    {
        let PathComponent = DatabaseDirectory + "/" + FileIONames.POIDatabase.rawValue
        let DBURL = GetDocumentDirectory()!.appendingPathComponent(PathComponent)
        return DBURL
    }
    
    /// Returns the URL for the earthquake history database.
    /// - Returns: URL of the earthquake history database on success, nil if not found.
    public static func GetEarthquakeHistoryDatabaseURL() -> URL?
    {
        let PathComponent = DatabaseDirectory + "/" + FileIONames.QuakeHistoryDatabase.rawValue
        let DBURL = GetDocumentDirectory()!.appendingPathComponent(PathComponent)
        return DBURL
    }
    
    /// Returns the URL for the earthquake history database.
    /// - Returns: URL of the earthquake history database on success, nil if not found.
    public static func GetEarthquakeHistoryDatabaseSURL() -> URL?
    {
        let PathComponent = DatabaseDirectory + "/" + FileIONames.QuakeHistoryDatabaseS.rawValue
        let DBURL = GetDocumentDirectory()!.appendingPathComponent(PathComponent)
        return DBURL
    }
    
    /// Returns the URL for the settings database.
    /// - Returns: URL of the settings database on success, nil if not found.
    public static func GetSettingsDatabaseURL() -> URL?
    {
        let PathComponent = DatabaseDirectory + "/" + FileIONames.Settings.rawValue
        let DBURL = GetDocumentDirectory()!.appendingPathComponent(PathComponent)
        return DBURL
    }
    
    /// Determines if the settings exists at its expected location.
    /// - Returns: True if the database is where it is expected to be, false if not.
    public static func SettingsDatabaseExists() -> Bool
    {
        if DirectoryExists(DatabaseDirectory)
        {
            let PathComponent = DatabaseDirectory + "/" + FileIONames.Settings.rawValue
            let LookForExisting = GetDocumentDirectory()!.appendingPathComponent(PathComponent)
            if FileManager.default.fileExists(atPath: LookForExisting.path)
            {
                return true
            }
        }
        return false
    }
    
    /// Determines if the mappable database exists at its expected location.
    /// - Returns: True if the database is where it is expected to be, false if not.
    public static func MappableDatabaseExists() -> Bool
    {
        if DirectoryExists(DatabaseDirectory)
        {
            let PathComponent = DatabaseDirectory + "/" + FileIONames.MappableDatabase.rawValue
            let LookForExisting = GetDocumentDirectory()!.appendingPathComponent(PathComponent)
            if FileManager.default.fileExists(atPath: LookForExisting.path)
            {
                return true
            }
        }
        return false
    }
    
    /// Determines if the POI database exists at its expected location.
    /// - Returns: True if the database is where it is expected to be, false if not.
    public static func POIDatabaseExists() -> Bool
    {
        if DirectoryExists(DatabaseDirectory)
        {
            let PathComponent = DatabaseDirectory + "/" + FileIONames.POIDatabase.rawValue
            let LookForExisting = GetDocumentDirectory()!.appendingPathComponent(PathComponent)
            if FileManager.default.fileExists(atPath: LookForExisting.path)
            {
                return true
            }
        }
        return false
    }
    
    /// Initialize the directory structure. If the structure already exists, remove any existing files that are no longer needed.
    public static func InitializeDirectory()
    {
        
    }
    
    public static func ImageFromFile(WithName: String) -> UIImage?
    {
        if let DocDir = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).last
        {
                        let Image = UIImage(named: WithName, in: Bundle(for: self), compatibleWith: nil)
            //let Image = UIImage(contentsOf: DocDir.appendingPathComponent(WithName))
            return Image
        }
        return nil
    }
    
    public static func ResourceFileList() -> [String]
    {
        var FileList = [String]()
        do
        {
            FileList = try FileManager.default.contentsOfDirectory(atPath: Bundle.main.bundlePath)
            return FileList
        }
        catch
        {
            print("ResourceFileList error: \(error)")
            return []
        }
    }
    
    /// Determines if the passed file exists.
    /// - Parameter FinalURL: The URL of the file.
    /// - Returns: True if the file exists, false if not.
    public static func FileExists(_ FinalURL: URL) -> Bool
    {
        return FileManager.default.fileExists(atPath: FinalURL.path)
    }
    
    /// Determines if a given directory exists.
    /// - Parameter DirectoryName: The name of the directory to check for existence.
    /// - Returns: True if the directory exists, false if not.
    public static func DirectoryExists(_ DirectoryName: String) -> Bool
    {
        let CPath = GetDocumentDirectory()?.appendingPathComponent(DirectoryName)
        if CPath == nil
        {
            return false
        }
        return FileManager.default.fileExists(atPath: CPath!.path)
    }
    
    /// Create a directory in the document directory.
    /// - Parameter DirectoryName: Name of the directory to create.
    /// - Returns: URL of the newly created directory on success, nil on error.
    @discardableResult public static func CreateDirectory(DirectoryName: String) -> URL?
    {
        var CPath: URL!
        do
        {
            CPath = GetDocumentDirectory()?.appendingPathComponent(DirectoryName)
            try FileManager.default.createDirectory(atPath: CPath!.path, withIntermediateDirectories: true, attributes: nil)
        }
        catch
        {
            return nil
        }
        return CPath
    }
    
    /// Returns the URL of the passed directory. The directory is assumed to be a sub-directory of the
    /// document directory.
    /// - Parameter DirectoryName: Name of the directory whose URL is returned.
    /// - Returns: URL of the directory on success, nil if not found.
    public static func GetDirectoryURL(DirectoryName: String) -> URL?
    {
        if !DirectoryExists(DirectoryName)
        {
            return nil
        }
        let CPath = GetDocumentDirectory()?.appendingPathComponent(DirectoryName)
        return CPath
    }
    
    /// Returns BlockCam's document directory.
    /// - Returns: The URL of the app's document directory.
    public static func GetDocumentDirectory() -> URL?
    {
        return FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first
    }
    
    /// Delete the specified file.
    /// - Parameter FileURL: The URL of the file to delete.
    public static func DeleteFile(_ FileURL: URL)
    {
        do
        {
            try FileManager.default.removeItem(at: FileURL)
        }
        catch
        {
            return
        }
    }
    
    /// Delete the specified file. If the file does not exist, return without any errors being issued.
    /// - Parameter FileURL: The URL of the file to delete.
    public static func DeleteIfPresent(_ FileURL: URL)
    {
        if FileManager.default.fileExists(atPath: FileURL.path)
        {
            DeleteFile(FileURL)
        }
    }
    
    /// Loads an image from the file system. This is not intended for images from the photo album (and probably
    /// wouldn't work) but for images in our local directory tree.
    /// - Parameter Name: The name of the image to load.
    /// - Parameter InDirectory: Name of the directory where the file resides.
    /// - Returns: The image if found, nil if not found.
    public static func LoadImage(_ Name: String, InDirectory: String) -> UIImage?
    {
        if !DirectoryExists(InDirectory)
        {
            return nil
        }
        let DirURL = GetDirectoryURL(DirectoryName: InDirectory)
        return UIImage(contentsOfFile: (DirURL?.appendingPathComponent(Name).path)!)
    }
    
    /// Returns a listing of the contents of the specified directory.
    /// - Parameter Directory: The directory whose contents will be returned.
    /// - Returns: Array of strings representing the contents of the specified directory on success, nil on error.
    public static func ContentsOfDirectory(_ Directory: String) -> [String]?
    {
        do
        {
            let Results = try FileManager.default.contentsOfDirectory(atPath: Directory)
            return Results
        }
        catch
        {
            return nil
        }
    }
    
    @discardableResult public static func WriteString(_ WriteMe: String, To Filename: String) -> Bool
    {
        let DocDirURL = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first!
        let Intermediate = DocDirURL.appendingPathComponent(AppDirectory)
        let FileURL = Intermediate.appendingPathComponent(Filename)
        do
        {
            try WriteMe.write(to: FileURL, atomically: true, encoding: .utf8)
        }
        catch
        {
            Debug.Print("Error writing string to \(Filename): \(error.localizedDescription)")
            return false
        }
        return true
    }
}

/// External commands. An external command is an empty file (or full - it doesn't matter) whose name
/// is recognized as a command to execute early in the initialization process. Commands are executed
/// in the order they are found.
enum ExCommands: String, CaseIterable
{
    /// No operation command. Ignored.
    case NOP = "NOP"
    #if DEBUG
    /// Reset settings to default values.
    case SettingsReset = "SettingsReset"
    /// Reset filter settings to default values. Useful for after a crash.
    case FilterReset = "FilterReset"
    /// Dump settings to a text file.
    case DumpSettings = "DumpSettings"
    /// Exit Flatland.
    case Exit = "Exit"
    #endif
}
