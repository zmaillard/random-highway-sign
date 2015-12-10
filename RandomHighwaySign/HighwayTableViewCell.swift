//
//  HighwayTableViewCell.swift
//  RandomHighwaySign
//
//  Created by Zachary Maillard on 6/21/15.
//  Copyright (c) 2015 SagebrushGIS. All rights reserved.
//

import UIKit
import Alamofire
import AlamofireImage

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
        
        //HACK
        let newUrl = highway.url.stringByReplacingOccurrencesOfString("/20x", withString: "")
        
        
        self.request = Alamofire.request(.GET, newUrl)
            .responseImage {
                response  in
                dispatch_async(dispatch_get_main_queue(), {
                    self.highwayImage!.image = response.result.value
                    self.setNeedsLayout()
                })
            }
        
    }

}
