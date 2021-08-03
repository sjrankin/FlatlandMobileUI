//
//  AboutDetails.swift
//  AboutDetails
//
//  Created by Stuart Rankin on 7/30/21.
//

import Foundation
import UIKit

class AboutDetails: UIViewController, UITableViewDelegate, UITableViewDataSource
{
    override func viewDidLoad()
    {
        super.viewDidLoad()
        MakeVersionTableData()
        DetailTable.layer.borderColor = UIColor.gray.cgColor
        DetailTable.layer.borderWidth = 0.5
        DetailTable.layer.cornerRadius = 5
        DetailTable.reloadData()
    }
    
    var VersionTable = [(String, String)]()
    
    func MakeVersionTableData()
    {
        VersionTable.append(("Version", Versioning.MakeVersionString()))
        VersionTable.append(("Build", Versioning.MakeBuildString()))
        VersionTable.append(("Copyright", Versioning.CopyrightText(ExcludeCopyrightString: true)))
        VersionTable.append(("Feature level", "\(Versioning.FeatureLevel)"))
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int
    {
            return VersionTable.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell
    {
            let CellView = UITableViewCell(style: UITableViewCell.CellStyle.subtitle, reuseIdentifier: "VersionDetails")
        var CellContent = CellView.defaultContentConfiguration()
        CellContent.text = VersionTable[indexPath.row].0
        CellContent.secondaryText = VersionTable[indexPath.row].1
        CellView.contentConfiguration = CellContent
        return CellView
    }
    
    @IBOutlet weak var DetailTable: UITableView!
}
