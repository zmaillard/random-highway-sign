//
//  HighwayTableViewCell.swift
//  RandomHighwaySign
//
//  Created by Zachary Maillard on 6/21/15.
//  Copyright (c) 2015 SagebrushGIS. All rights reserved.
//

import UIKit
import Alamofire

class HighwayTableViewCell: UITableViewCell {

    @IBOutlet weak var highwayText: UILabel!
    @IBOutlet weak var highwayImage: UIImageView!
    
    var highway:Highway?
    var request: Alamofire.Request?
    
    
    func assignHighway(highway : Highway){
        self.highway = highway
        self.highwayImage!.image = nil
        self.request?.cancel()
        
        self.highwayText?.text = highway.highway
        self.highwayText?.sizeToFit()
        
        self.request = Alamofire.request(.GET, highway.url).responseImage() {
            (request, _, image, error) in
            if error == nil && image != nil {
                self.highwayImage!.image = image
            }
        }
        
    }

}
