//
//  SignDetailsViewController.swift
//  RandomHighwaySign
//
//  Created by Zachary Maillard on 4/29/15.
//  Copyright (c) 2015 SagebrushGIS. All rights reserved.
//

import UIKit
import MapKit

class SignDetailsViewController: UIViewController {
    var sign : Sign!
    @IBOutlet weak var map: MKMapView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.title = sign.title
        
        var coord = CLLocationCoordinate2DMake(sign.latitude, sign.longitude)

        var region = MKCoordinateRegionMakeWithDistance(coord, 5000, 5000)
        map.setRegion(region, animated:true)
    }

}
