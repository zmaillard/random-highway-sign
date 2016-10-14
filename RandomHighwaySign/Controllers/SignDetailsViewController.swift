//
//  SignDetailsViewController.swift
//  RandomHighwaySign
//
//  Created by Zachary Maillard on 4/29/15.
//  Copyright (c) 2015 SagebrushGIS. All rights reserved.
//

import UIKit
import CoreLocation

class SignDetailsViewController: UITableViewController {
    var sign : Sign!
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
    
        self.title = "Sign Details"
        
        self.navigationItem.backBarButtonItem = UIBarButtonItem(title:"", style:.plain, target:nil, action:nil)
        
        
    }

    override func tableView(_ tableView: UITableView, estimatedHeightForRowAt indexPath: IndexPath) -> CGFloat {
            return UITableViewAutomaticDimension
    }


    
    override func numberOfSections(in tableView: UITableView) -> Int {
        return 6
    }
    
    override func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        if section == 0{
            return "Title"
        }else if section == 1{
            return "Description"
        }else if section == 2{
            return "Location"
        }else if section == 3{
            return "Highways"
        }else if section == 4{
            return "Date Taken"
        }else if section == 5{
            return "Map"
        }else
        {
            return ""
        }
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        if (indexPath as NSIndexPath).section == 3{
            let tableCell =  tableView.dequeueReusableCell(withIdentifier: "highway", for: indexPath) as UITableViewCell
            let highwayTableCell = tableCell as? HighwayTableViewCell
            
            highwayTableCell?.assignHighway(sign.highways[(indexPath as NSIndexPath).row])
            tableCell.layoutSubviews()
            
            return tableCell
        }else if (indexPath as NSIndexPath).section == 1{
            let tableCell =  tableView.dequeueReusableCell(withIdentifier: "desc", for: indexPath) as UITableViewCell
            let descTableCell = tableCell as? DescriptionTableViewCell
            
            descTableCell?.descriptionLabel.text = sign.imageDescription
            
            return tableCell
        }else if (indexPath as NSIndexPath).section == 5{
            let tableCell =  tableView.dequeueReusableCell(withIdentifier: "map", for: indexPath) as? MapTableViewCell
            
            tableCell!.zoomTo(self.sign.latitude,longitude:self.sign.longitude)
            
            return tableCell!
        }else{
        
            let tableCell =  tableView.dequeueReusableCell(withIdentifier: "standard", for: indexPath) as UITableViewCell
        
            if (indexPath as NSIndexPath).section == 0{
                tableCell.textLabel?.text = sign.title
            }else if (indexPath as NSIndexPath).section == 2{
                tableCell.textLabel?.text = sign.place + ", " + sign.state
            }
            else{
                tableCell.textLabel?.text = sign.date
            }
        
            return tableCell
        }
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if section == 3{
            return self.sign.highways.count
        }

        return 1
        
    }
    
    
}
