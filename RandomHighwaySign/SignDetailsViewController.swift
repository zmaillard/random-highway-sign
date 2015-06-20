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
    
        self.tableView.estimatedRowHeight = 100.0;
        self.tableView.rowHeight = UITableViewAutomaticDimension;
        self.title = "Sign Details"
        signTItle.text = sign.title
        signDescription.text = sign.imageDescription
    }
    
    override func tableView(tableView: UITableView, heightForRowAtIndexPath indexPath: NSIndexPath) -> CGFloat {
        var cell = tableView.cellForRowAtIndexPath(indexPath)
        
        if cell?.contentView.subviews.count > 0{
            if let labelVal =  cell?.contentView.subviews[0] as? UILabel{
                return 200
                
            }
        }
        
        return 50
    }
    
    
    
}
