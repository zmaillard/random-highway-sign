//
//  MapTableViewCell.swift
//  RandomHighwaySign
//
//  Created by Zachary Maillard on 6/21/15.
//  Copyright (c) 2015 SagebrushGIS. All rights reserved.
//

import UIKit
import MapKit

class MapTableViewCell: UITableViewCell {
    @IBOutlet weak var mapView: MKMapView!
    
    func zoomTo(latitude:Double, longitude:Double){
        let coord = CLLocationCoordinate2D(latitude: latitude, longitude: longitude)
        let mapRect = MKCoordinateRegionMakeWithDistance(coord, 5000, 5000)

        let point = MKPointAnnotation()
        point.coordinate = coord;
        
        mapView.addAnnotation(point)
        
        mapView.setRegion(mapRect, animated: false)

    }
}
