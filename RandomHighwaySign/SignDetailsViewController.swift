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
        
        
    }

    override func tableView(tableView: UITableView, estimatedHeightForRowAtIndexPath indexPath: NSIndexPath) -> CGFloat {
        return UITableViewAutomaticDimension
    }
    
    override func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return 6
    }
    
    override func tableView(tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
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
    
    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        
        if indexPath.section == 3{
            var tableCell =  tableView.dequeueReusableCellWithIdentifier("highway", forIndexPath: indexPath) as? UITableViewCell
            let highwayTableCell = tableCell as? HighwayTableViewCell
            
            highwayTableCell?.assignHighway(sign.highways[indexPath.row])
            
            return tableCell!
        }else if indexPath.section == 5{
            var tableCell =  tableView.dequeueReusableCellWithIdentifier("map", forIndexPath: indexPath) as? MapTableViewCell
            
            tableCell!.zoomTo(self.sign.latitude,longitude:self.sign.longitude)
            
            return tableCell!
        }else{
        
            var tableCell =  tableView.dequeueReusableCellWithIdentifier("standard", forIndexPath: indexPath) as? UITableViewCell
        
            if indexPath.section == 0{
                tableCell?.textLabel?.text = sign.title
            }else if indexPath.section == 1{
                tableCell?.textLabel?.text = sign.imageDescription
            }else if indexPath.section == 2{
                tableCell?.textLabel?.text = sign.place + ", " + sign.state
            }
            else{
                tableCell?.textLabel?.text = sign.date
            }
        
            return tableCell!
        }
    }
    
    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if section == 3{
            return self.sign.highways.count
        }

        return 1
        
    }
    
    
}
