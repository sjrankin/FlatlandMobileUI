//
//  TimeZoneTable.swift
//  TimeZoneTable
//
//  Created by Stuart Rankin on 7/19/21. Adapted from Flatland View
//

import Foundation

class TimeZoneTable
{
    /// Given a time zone offset, return time zone information.
    /// - Parameter For: Number of hours away from GMT (negative for western hemisphere and positive
    ///                  for eastern hemisphere). Supports fractional time zone offsets.
    /// - Returns: Array of time zone information. Nil returned if no time zone information was found.
    public static func GetTimeZoneInfo(For Offset: Double) -> [(Abbreviation: String, Name: String)]?
    {
        if let Zone = Raw[Offset]
        {
            return Zone
        }
        return nil
    }
    
    /// Get the time zone offset exteme values.
    /// - Returns: Tuple with the lowest offset and the highest offset.
    public static func GetTimeZoneOffsetRange() -> (Low: Double, High: Double)
    {
        var Lowest = Double.greatestFiniteMagnitude
        var Highest = -Double.greatestFiniteMagnitude
        for (Offset, _) in Raw
        {
            if Offset < Lowest
            {
                Lowest = Offset
            }
            if Offset > Highest
            {
                Highest = Offset
            }
        }
        return (Lowest, Highest)
    }
    
    /// Table of common time zones supported by Flatland.
    /// - Note: See [Complete table of time zones with variable length notation](https://www.ibm.com/support/knowledgecenter/SSGSPN_8.6.0/com.ibm.tivoli.itws.doc_8.6/awsrgcompletetzt.htm)
    static let Raw: [Double: [(Abbreviation: String, Name: String)]] =
    [
        //Eastern hemisphere.
        0.0: [("GMT", "Greenwich Mean Time"),
              ("UTC", "Universal Time Coordinated"),
              ("UT", "Universal Time"),
              ("WET", "Western European Time")],
        1.0: [("CET", "Central European Time"),
              ("MET", "Middle European Time"),
              ("WAT", "Western African Time")],
        2.0: [("EET", "Eastern European Time"),
              ("CAT", "Central African Time"),
              ("SAST", "South Africa Standard Time"),
              ("IST", "Israel Standard Time")],
        3.0: [("MSK", "Moscow Standard Time"),
              ("EAT", "East African Time"),
              ("SYOT", "Syowa Time"),
              ("AST", "Arabia Standard Time"),
              ("VOLT", "Volgograd Time")],
        3.5: [("IRST", "Iran Standard Time")],
        4.0: [("GST", "Gulf Standard Time"),
              ("AZT", "Azerbaijan Time"),
              ("AMT", "Armenia Time"),
              ("SCT", "Seychelles Time"),
              ("SAMT", "Samara Time"),
              ("RET", "Reunion Time")],
        4.5: [("AFT", "Afghanistan Time")],
        5.0: [("PKT", "Pakistan Time"),
              ("AQTT", "Aqtau Time"),
              ("TMT", "Turkmenistan Time"),
              ("TJT", "Takikistan Time"),
              ("ORAT", "Oral Time"),
              ("UZT", "Uzbekistan Time"),
              ("YEKT", "Yekaterinburg time"),
              ("TFT", "French Southern and Antarctic Lands Time"),
              ("MVT", "Maldives Time")],
        5.5: [("IST", "India Standard Time")],
        5.75: [("NPT", "Nepal Time")],
        6.0: [("BDT", "Bangladesh Time"),
              ("MAWT", "Mawson Time"),
              ("VOST", "Vostok Time"),
              ("ALMT", "Alma-Ata Time"),
              ("NOVT", "Novosibirsk Time"),
              ("OMST", "Omsk Time"),
              ("BTT", "Bhutan Time"),
              ("BDT", "Bangladesh Time"),
              ("IOT", "Indian Ocean Territory Time")],
        6.5: [("MMT", "Myanmar Time"),
              ("CCT", "Cocos Islands Time")],
        7.0: [("WIT", "West Indonesia Time"),
              ("DAVT", "Davis Time"),
              ("ICT", "Indochina Time"),
              ("HOVT", "Hovd Time"),
              ("KRAT", "Krasnoyarsk Time"),
              ("CXT", "Christmas Island Time")],
        8.0: [("CST", "China Standard Time"),
              ("WST", "Western Standard Time (Australia)"),
              ("BNT", "Brunei Time"),
              ("CHOT", "Choibalsan Time"),
              ("HKT", "Hong Kong Time"),
              ("IRKT", "Irkutsk Time"),
              ("MYT", "Malaysia Time"),
              ("CIT", "Central Indonesia Time"),
              ("SGT", "Singapore Time"),
              ("ULAT", "Ulaanbaatar Time")],
        8.75: [("CWST", "Central Western Standard Time (Australia)")],
        9.0: [("JST", "Japan Standard Time"),
              ("TLT", "Timor-Leste Time"),
              ("EIT", "East Indonesia Time"),
              ("KST", "Korea Standard Time"),
              ("YAKT", "Yakutsk Time"),
              ("PWT", "Palau Time")],
        9.5: [("CST", "Central Standard Time (Northern Territory)")],
        10.0: [("VLAT", "Vladivostok Time"),
               ("EST", "Eastern Standard Time (New South Wales)"),
               ("DDUT", "Dumont-d'Urville Time"),
               ("SAKT", "Sakhalin Time"),
               ("ChST", "Chamorro Standard Time"),
               ("PGT", "Papua New Guinea Time"),
               ("TRUT", "Truk Time")],
        10.5: [("LHST", "Lord Howe Standard Time")],
        11.0: [("VUT", "Vanuatu Time"),
               ("MAGT", "Magadan Time"),
               ("SBT", "Solomon Islands Time"),
               ("KOST", "Kosrae Time"),
               ("NCT", "New Caledonia Time"),
               ("PONT", "Ponape Time")],
        11.5: [("NFT", "Norfolk Time")],
        12.0: [("NZST", "New Zealand Standard Time"),
               ("ANAT", "Anadyr Time"),
               ("PETT", "Petropavlovsk-Kamchatski Time"),
               ("MHT", "Marshall Islands Time"),
               ("FJT", "Fiji Time"),
               ("TVT", "Tuvalu Time"),
               ("NRT", "Nauru Time"),
               ("WAKT", "Wake Time"),
               ("GILT", "Gilbert Islands Time"),
               ("WFT", "Wallis & Futuna Time")],
        12.75: [("CHAST", "Chatham Standard Time")],
        13.0: [("PHOT", "Phoenix Island Time"),
               ("TOT", "Tonga Time")],
        14.0: [("LINT", "Line Island Time")],
        
        //Western hemisphere.
        -1.0: [("AZOT", "Azores Time"),
               ("EGT", "Eastern Greenland Time"),
               ("CVT", "Cape Verde Time")],
        -2.0: [("GST", "South Georgia Time"),
               ("FNT", "Fernando de Noronha Time")],
        -3.0: [("ART", "Argentine Time"),
               ("BRT", "Brasilia Time"),
               ("GFT", "French Guiana Time"),
               ("WGT", "Western Greenland Time"),
               ("PMST", "Pierra & Miquelon Standard Time"),
               ("ROTT", "Rothera Time"),
               ("UYT", "Uruguay Time")],
        -3.5: [("NST", "Newfoundland Standard Time")],
        -4.0: [("CLT", "Chile Time"),
               ("AST", "Atlantic Standard Time"),
               ("WART", "Western Argentine Time"),
               ("PYT", "Paraguay Time"),
               ("AMT", "Amazon Time"),
               ("FKT", "Falkland Islands Time"),
               ("BOT", "Bolivia Time"),
               ("GYT", "Guyana Time")],
        -4.5: [("VET", "Venezuela Time")],
        -5.0: [("EST", "Eastern Standard Time"),
               ("COT", "Colombia Time"),
               ("ECT", "Ecuador Time"),
               ("CST", "Cuba Standard Time"),
               ("PET", "Peru Time")],
        -6.0: [("CST", "Central Standard Time"),
               ("EAST", "Easter Island Time"),
               ("GALT", "Galapagos Time")],
        -7.0: [("MST", "Mountain Standard Time")],
        -8.0: [("PST", "Pacific Standard Time")],
        -9.0: [("AKST", "Alaska Standard Time"),
               ("GAMT", "Gambier Time")],
        -9.5: [("MART", "Marqueasas Time")],
        -10.0: [("HST", "Hawaii Standard Time"),
                ("HAST", "Hawaii-Aleutian Standard Time"),
                ("TKT", "Tokelau Time"),
                ("CKT", "Cook Island Time"),
                ("TAHT", "Tahiti Time")],
        -11.0: [("WST", "West Samoa Time"),
                ("SST", "Somoa Standard Time"),
                ("NUT", "Niue Time")],
        -12.0: [("UTC-12", "UTC-12")]
    ]
}
