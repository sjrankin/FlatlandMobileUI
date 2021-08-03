//
//  LowLevel.swift
//  LowLevel
//
//  Created by Stuart Rankin on 7/18/21. Adapted from Flatland View.
//

import Foundation
import UIKit
import Metal

/// Class to return various pieces of low-level information.
class LowLevel
{
    /// Query the system and return a string result.
    /// - Parameter For: The key to use to query the system.
    /// - Returns: String value based on the key.
    public static func StringQuery(For Key: SysKeys) -> String
    {
        var Size: Int = 0
        sysctlbyname(Key.rawValue, nil, &Size, nil, 0)
        var Query = [CChar](repeating: 0, count: Size)
        sysctlbyname(Key.rawValue, &Query, &Size, nil, 0)
        return String(cString: Query)
    }
    
    /// Query the system and return a numeric result.
    /// - Parameter For: The key to use to query the system.
    /// - Returns: `UInt64` value based on the key.
    public static func NumericQuery(For Key: SysKeys) -> UInt64
    {
        var Size: Int = 0
        sysctlbyname(Key.rawValue, nil, &Size, nil, 0)
        var Results = [UInt64](repeating: 0, count: Size)
        sysctlbyname(Key.rawValue, &Results, &Size, nil, 0)
        return Results[0]
    }
    
    /// Query the system with the specified key.
    /// - Parameter Key: The key to use to query the system.
    /// - Returns: Value of the key. If the key returns a numeric value, it is returned as a string.
    public static func QueryFor(_ Key: SysKeys) -> String
    {
        if NumericKeys.contains(Key)
        {
            return "\(NumericQuery(For: Key))"
        }
        else
        {
            return StringQuery(For: Key)
        }
    }
    
    /// Holds the set of keys that return numeric values.
    static let NumericKeys: [SysKeys] = [.HWCPUCount, .HWMemSize, .HWCacheLineSize, .CPUCoreCount,
                                         .CPUThreadCount, .KernelBootTime, .KernelClockRate,
                                         .HWCPU64Bit, .CPUByteOrder, .CPUModel, .CPUExtModel,
                                         .CPUFamily, .CPUExtFamily, .CPUStepping, .CPUCacheSize,
                                         .KernelRevision, .KernelSafeBoot, .IOThermalLevel,
                                         .GPUThermalLevel, .CPUThermalLevel]
    
    public static func ThermalState() -> ProcessInfo.ThermalState
    {
        let PI = ProcessInfo()
        return PI.thermalState
    }
    
    #if false
    /// Return an array of strings that describes each Metal GPU.
    /// - Returns: Arry of strings that describes each Metal GPU.
    public static func MetalGPUs() -> [String]
    {
        var DeviceNames = [String]()
        let Devices = MTLCopyAllDevices()
        for Device in Devices
        {
            DeviceNames.append(Device.name)
        }
        return DeviceNames
    }
    #endif
    
    /// Return a string that describes the Metal device name.
    ///
    /// - Returns: Metal device name.
    public static func MetalDeviceName() -> String
    {
        let MetalDevice = MTLCreateSystemDefaultDevice()
        return (MetalDevice?.name)!
    }
    
    /// Returns the user's name for the device.
    /// - Note: This returns the same value as calling `Query(.KernelHostName)` but without the `.local` suffix.
    /// - Returns: Name of the device as given by the user.
    public static func SystemName() -> String
    {
        var SysInfo = utsname()
        uname(&SysInfo)
        let Name = withUnsafePointer(to: &SysInfo.nodename.0)
        {
            ptr in
            return String(cString: ptr)
        }
        let Parts = Name.split(separator: ".")
        return String(Parts[0])
    }
    
    /// Return the amount of RAM (used and unused) on the system.
    /// - Note: [Determining the Available Amount of RAM on an iOS Device](https://stackoverflow.com/questions/5012886/determining-the-available-amount-of-ram-on-an-ios-device)
    /// - Returns: Tuple with the values (Used memory, free memory).
    public static func RAMSize() -> (Int64, Int64)
    {
        var PageSize: vm_size_t = 0
        let HostPort: mach_port_t = mach_host_self()
        var HostSize: mach_msg_type_number_t = mach_msg_type_number_t(MemoryLayout<vm_statistics_data_t>.stride / MemoryLayout<integer_t>.stride)
        host_page_size(HostPort, &PageSize)
        var vm_stat: vm_statistics = vm_statistics_data_t()
        withUnsafeMutablePointer(to: &vm_stat)
        {
            (vmStatPointer) -> Void in
            vmStatPointer.withMemoryRebound(to: integer_t.self, capacity: Int(HostSize))
            {
                if host_statistics(HostPort, HOST_VM_INFO, $0, &HostSize) != KERN_SUCCESS
                {
                    print("Error: failed to get vm statistics")
                }
            }
        }
        let MemUsed: Int64 = Int64(vm_stat.active_count + vm_stat.inactive_count + vm_stat.wire_count) * Int64(PageSize)
        let MemFree: Int64 = Int64(vm_stat.free_count) * Int64(PageSize)
        return (MemUsed, MemFree)
    }
    
    /// Return the amount of used memory by Flatland.
    /// - Note: See [Programmatically retrieve memory usage](https://stackoverflow.com/questions/787160/programmatically-retrieve-memory-usage-on-iphone)
    /// - Returns: Number of bytes of used memory. Nil if unable to retrieve.
    public static func UsedMemory() -> UInt64?
    {
        return MemoryStatistics(.PhysicalFootprint)
    }
    
    /// Return memory information.
    /// - Parameter For: Determines the field from the `task_vm_info_data_t` structure to return.
    /// - Returns: Value found in the specified field on success, nil on failure. All non-nil values returned
    ///            are `UInt64`s, even the fields that are natively integers.
    public static func MemoryStatistics(_ For: MemoryFields) -> UInt64?
    {
        let Task_VM_Info_Count = mach_msg_type_number_t(MemoryLayout<task_vm_info_data_t>.size / MemoryLayout<integer_t>.size)
        let Task_VM_Info_Rev1_Count = mach_msg_type_number_t(MemoryLayout.offset(of: \task_vm_info_data_t.min_address)! / MemoryLayout<integer_t>.size)
        var info = task_vm_info_data_t()
        var count = Task_VM_Info_Count
        let kr = withUnsafeMutablePointer(to: &info)
        {
            infoPtr in
            infoPtr.withMemoryRebound(to: integer_t.self, capacity: Int(count))
            {
                intPtr in
                task_info(mach_task_self_, task_flavor_t(TASK_VM_INFO), intPtr, &count)
            }
        }
        guard kr == KERN_SUCCESS, count >= Task_VM_Info_Rev1_Count else
        {
            return nil
            
        }
        switch For
        {
            case .VirtualSize:
                return info.virtual_size
                
            case .RegionCount:
                return UInt64(info.region_count)
                
            case .PageSize:
                return UInt64(info.page_size)
                
            case .ResidentSize:
                return info.resident_size
                
            case .ResidentPeakSize:
                return info.resident_size_peak
                
            case .Reusable:
                return info.reusable
                
            case .ReusablePeak:
                return info.reusable_peak
                
            case .PhysicalFootprint:
                return info.phys_footprint
        }
    }
    
    /// Return a string of the amount of space currently allocated by Metal.
    /// - Returns: Number of bytes (in string format) allocated by Metal.
    public static func MetalAllocatedSpace() -> String
    {
        let MetalDevice = MTLCreateSystemDefaultDevice()
        let Allocated = MetalDevice?.currentAllocatedSize
        let Final = Allocated?.Delimited()
        return Final!
    }
    
    /// Returns information about the computer where Flatland is running.
    /// - Parameter From: The model name (in the form computer#,#) of the current computer.
    /// - Returns: Tuple of the computer type, screen size (in inches), and release year. Nil return if no
    ///            data is found.
    public static func MacIdentifier(From: String) -> (String, String, String)?
    {
        if let (Computer, Size, When) = MacList[From]
        {
            return (Computer, Size, When)
        }
        else
        {
            return nil
        }
    }
    
    private static let MacList: [String: (String, String, String)] =
    [
        "iMac9,1": ("iMac", "20/24", "Early 2009"),
        "iMac10,1": ("iMac", "21.5/27", "Late 2009"),
        "iMac11,2": ("iMac", "21.5", "Mid 2010"),
        "iMac11,3": ("iMac", "27", "Mid 2010"),
        "iMac12,1": ("iMac", "21.5", "Mid 2011"),
        "iMac12,2": ("iMac", "27", "Mid 2011"),
        "iMac13,1": ("iMac", "21.5", "Late 2012"),
        "iMac13,2": ("iMac", "27", "Late 2012"),
        "iMac14,1": ("iMac", "21.5", "Late 2013"),
        "iMac14,2": ("iMac", "27", "Late 2013"),
        "iMac14,4": ("iMac", "21.5", "Mid 2014"),
        "iMac15,1": ("iMac", "27", "Late 2014/Mid 2015"),
        "iMac16,1": ("iMac", "21.5", "Late 2015"),
        "iMac16,2": ("iMac", "21.5", "Late 2015"),
        "iMac17,1": ("iMac", "27", "Late 2015"),
        "iMac18,1": ("iMac", "21.5", "2017"),
        "iMac18,2": ("iMac", "21.5", "2017"),
        "iMac18,3": ("iMac", "27", "2017"),
        "iMacPro1,1": ("iMac Pro", "27", "2017"),
        "iMac19,2": ("iMac", "21.5", "2019"),
        "iMac19,1": ("iMac", "27", "2019"),
        "iMac20,1": ("iMac", "27", "2020"),
        "iMac20,2": ("iMac", "27", "2020"),
        "MacBook5,2": ("MacBook", "13", "Early 2009/Mid 2009"),
        "MacBook6,1": ("MacBook", "13", "Late 2009"),
        "MacBook7,1": ("MacBook", "13", "Mid 2010"),
        "MacBook8,1": ("MacBook", "12", "Early 2015"),
        "MacBook9,1": ("MacBook", "12", "Early 2016"),
        "MacBook10,1": ("MacBook", "12", "2017"),
        "MacBookPro4,1": ("MacBook Pro", "15/17", "Early 2008"),
        "MacBookPro5,1": ("MacBook Pro", "15", "Late 2008"),
        "MacBookPro5,5": ("MacBook Pro", "13", "Mid 2009"),
        "MacBookPro5,3": ("MacBook Pro", "15", "Mid 2009"),
        "MacBookPro5,2": ("MacBook Pro", "17", "Early 2009/Mid 2009"),
        "MacBookPro7,1": ("MacBook Pro", "13", "Mid 2010"),
        "MacBookPro6,2": ("MacBook Pro", "15", "Mid 2010"),
        "MacBookPro6,1": ("MacBook Pro", "17", "Mid 2010"),
        "MacBookPro8,1": ("MacBook Pro", "13", "Early 2011/Late 2011"),
        "MacBookPro8,2": ("MacBook Pro", "15", "Early 2011/Late 2011"),
        "MacBookPro8,3": ("MacBook Pro", "17", "Early 2011/Late 2011"),
        "MacBookPro9,2": ("MacBook Pro", "13", "Mid 2012"),
        "MacBookPro10,2": ("MacBook Pro", "13", "Late 2012/Early 2013"),
        "MacBookPro9,1": ("MacBook Pro", "15", "Mid 2012"),
        "MacBookPro10,1": ("MacBook Pro", "15", "Mid 2012/Early 2013"),
        "MacBookPro11,1": ("MacBook Pro", "13", "Late 2013/Mid 2014"),
        "MacBookPro11,3": ("MacBook Pro", "15", "Late 2013/Mid 2014"),
        "MacBookPro11,2": ("MacBook Pro", "15", "Late 2013/Mid 2014"),
        "MacBookPro12,1": ("MacBook Pro", "13", "Early 2015"),
        "MacBookPro11,5": ("MacBook Pro", "15", "Mid 2015"),
        "MacBookPro11,4": ("MacBook Pro", "15", "Mid 2015"),
        "MacBookPro13,1": ("MacBook Pro", "13", "2016"),
        "MacBookPro13,2": ("MacBook Pro", "13", "2016"),
        "MacBookPro13,3": ("MacBook Pro", "15", "2016"),
        "MacBookPro14,1": ("MacBook Pro", "13", "2017"),
        "MacBookPro14,2": ("MacBook Pro", "13", "2017"),
        "MacBookPro14,3": ("MacBook Pro", "15", "2017"),
        "MacBookPro15,2": ("MacBook Pro", "13", "2018/2019"),
        "MacBookPro15,1": ("MacBook Pro", "15", "2018/2019"),
        "MacBookPro15,4": ("MacBook Pro", "13", "2019"),
        "MacBookPro16,1": ("MacBook Pro", "16", "2019"),
        "MacBookPro16,2": ("MacBook Pro", "13", "2020"),
        "MacBookPro16,3": ("MacBook Pro", "13", "2020"),
        "MacBookPro17.1": ("MacBook Pro M1", "13", "2020"),
        "MacBookAir2,1": ("MacBook Air", "11", "2009"),
        "MacBookAir3,1": ("MacBook Air", "11", "Late 2010"),
        "MacBookAir3,2": ("MacBook Air", "13", "Late 2010"),
        "MacBookAir4,1": ("MacBook Air", "11", "Mid 2011"),
        "MacBookAir4,2": ("MacBook Air", "13", "Mid 2011"),
        "MacBookAir5,1": ("MacBook Air", "11", "Mid 2012"),
        "MacBookAir5,2": ("MacBook Air", "13", "Mid 2012"),
        "MacBookAir6,1": ("MacBook Air", "11", "Mid 2013/Early 2014"),
        "MacBookAir6,2": ("MacBook Air", "13", "Mid 2013/Early 2014"),
        "MacBookAir7,1": ("MacBook Air", "11", "Early 2015"),
        "MacBookAir7,2": ("MacBook Air", "13", "Early 2015/2017"),
        "MacBookAir8,1": ("MacBook Air", "13", "2018"),
        "MacBookAir8,2": ("MacBook Air", "13", "2019"),
        "MacBookAir9,1": ("MacBook Air", "13", "2020"),
        "MacBookAir10,1": ("MacBook Air M1", "13", "2020"),
        "MacMini3,1": ("Mac Mini", "0", "2009"),
        "MacMini4,1": ("Mac Mini", "0", "2010"),
        "MacMini5,1": ("Mac Mini", "0", "2011"),
        "MacMini5,2": ("Mac Mini", "0", "2011"),
        "MacMini6,1": ("Mac Mini", "0", "2012"),
        "MacMini6,2": ("Mac Mini", "0", "2012"),
        "MacMini7,1": ("Mac Mini", "0", "2014"),
        "MacMini8,1": ("Mac Mini", "0", "2018"),
        "MacMini,9,1": ("Mac Mini M1", "0", "2020"),
    ]
}

/// Keys and values for querying the system for certain pieces of information. These values are fed into
/// a call to `sysctlbyname`.
enum SysKeys: String, CaseIterable
{
    /// String: Returns the CPU type.
    case HWCPUType = "hw.machine"
    /// String: Returns the model name.
    case HWModel = "hw.model"
    /// Numeric: Returns the number of CPUs.
    case HWCPUCount = "hw.ncpu"
    /// Numeric: Returns the number of logical CPUs.
    case HWLogicalCPUCount = "hw.logicalcpu"
    /// Numeric: Returns the size of memory.
    case HWMemSize = "hw.memsize"
    /// Numeric: Returns 1 if the CPU is 64-bit capable, 0 if not.
    case HWCPU64Bit = "hw.cpu64bit_capable"
    /// Numeric: Returns the cache line size.
    case HWCacheLineSize = "hw.cachelinesize"
    /// String: Returns the CPU vendor.
    case CPUVendor = "machdep.cpu.vendor"
    /// String: Returns the CPU branding string.
    case CPUBrandString = "machdep.cpu.brand_string"
    /// Numeric: Returns the CPU core count.
    case CPUCoreCount = "machdep.cpu.core_count"
    /// Numeric: Returns the CPU thread count.
    case CPUThreadCount = "machdep.cpu.thread_count"
    /// Numeric: Cache size of the CPU.
    case CPUCacheSize = "machdep.cpu.cache.size"
    /// Numeric: Byte order of the CPU.
    case CPUByteOrder = "hw.byteorder"
    /// Numeric: CPU family.
    case CPUFamily = "machdep.cpu.family"
    /// Numeric: CPU model.
    case CPUModel = "machdep.cpu.model"
    /// Numeric: CPU extended model.
    case CPUExtModel = "machdep.cpu.extmodel"
    /// Numeric: CPU extended family.
    case CPUExtFamily = "machdep.cpu.extfamily"
    /// Numeric: Processor stepping.
    case CPUStepping = "machdep.cpu.stepping"
    /// String: Returns the OS version number.
    case KernelOSVersion = "kern.osproductversion"
    /// String: Returns the iOS version supported on the OS.
    case KerneliOSSupported = "kern.iossupportversion"
    /// String: Returns the host name in the form {name}.{local}.
    case KernelHostName = "kern.hostname"
    /// Numeric: Returns the number of seconds since 1970 for the most recent boot time.
    case KernelBootTime = "kern.boottime"
    /// Numeric: Returns the CPU clock rate.
    case KernelClockRate = "kern.clockrate"
    /// String: The kernel version number.
    case KernelVersion = "kern.osrelease"
    /// Numeric: The kernel revision.
    case KernelRevision = "kern.osrevision"
    /// String: The kernel name.
    case KernelName = "kern.ostype"
    /// String: The long kernel name.
    case KernelVersionName = "kern.version"
    /// String: Another kernel OS version.
    case KernelOSVersion2 = "kern.osversion"
    /// Numeric: Safe boot flag.
    case KernelSafeBoot = "kern.safeboot"
    /// Numeric: GPU thermal level.
    case GPUThermalLevel = "machdep.xcpm.gpu_thermal_level"
    /// Numeric: CPU thermal level.
    case CPUThermalLevel = "machdep.xcpm.cpu_thermal_level"
    /// Numeric: I/O thermal level.
    case IOThermalLevel = "machdep.xcpm.io_thermal_level"
}

/// Fields `MemoryStatistics` returns.
enum MemoryFields: String, CaseIterable
{
    /// Virtual memory size.
    case VirtualSize = "VirtualSize"
    /// Region count.
    case RegionCount = "RegionCount"
    /// Page size.
    case PageSize = "PageSize"
    /// Resident size.
    case ResidentSize = "ResidentSize"
    /// Resident peak size.
    case ResidentPeakSize = "ResidentPeakSize"
    /// Reusable size.
    case Reusable = "Resuable"
    /// Reusable peak size.
    case ReusablePeak = "ReusablePeak"
    /// Physical footprint.
    case PhysicalFootprint = "PhysicalFootprint"
}
