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

    @IBOutlet weak var details: UILabel!
    @IBOutlet weak var signTitle: UILabel!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.title = "Details"
        signTitle.text = sign.title
        details.text = sign.description
        details.lineBreakMode = .ByWordWrapping
        details.numberOfLines = 0
        details.sizeToFit()
        

        
        //var coord = CLLocationCoordinate2DMake(sign.latitude, sign.longitude)

        //var region = MKCoordinateRegionMakeWithDistance(coord, 5000, 5000)
        //map.setRegion(region, animated:true)
    }
    



}
