//
//  ResultTableViewCell.swift
//  RandomHighwaySign
//
//  Created by Zachary Maillard on 10/9/16.
//  Copyright © 2016 SagebrushGIS. All rights reserved.
//

import UIKit
import Alamofire

class ResultTableViewCell : UITableViewCell{
    var request: Alamofire.Request?
    var sign: Sign?
    
    @IBOutlet weak var thumbnailImageView: UIImageView!
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var descLabel: UILabel!
    
    func assignSign(_ sign : Sign){
        self.sign = sign
        self.thumbnailImageView!.image = nil
        self.request?.cancel()
        
        self.titleLabel?.text = sign.title
        self.descLabel?.text = sign.imageDescription
        self.descLabel?.sizeToFit()
        
        self.request = Alamofire.request(sign.thumbnail).responseImage {
            response in
            self.thumbnailImageView!.image = response.result.value
        }
        
    }
    
}

