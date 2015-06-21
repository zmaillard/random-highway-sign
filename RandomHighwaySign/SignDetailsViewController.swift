//
//  SignDetailsViewController.swift
//  RandomHighwaySign
//
//  Created by Zachary Maillard on 4/29/15.
//  Copyright (c) 2015 SagebrushGIS. All rights reserved.
//

import UIKit
import MapKit

class SignDetailsViewController: UITableViewController {
    var sign : Sign!
    
    @IBOutlet weak var signTItle: UILabel!
    @IBOutlet weak var signDescription: UILabel!
    
    override func viewDidLoad() {
        super.viewDidLoad()
    
        self.title = "Sign Details"
        
        
        signTItle.text = sign.title
        signDescription.text = sign.imageDescription
        
        signDescription.sizeToFit()
    }

    override func tableView(tableView: UITableView, estimatedHeightForRowAtIndexPath indexPath: NSIndexPath) -> CGFloat {
        return UITableViewAutomaticDimension
    }
    

    
}
