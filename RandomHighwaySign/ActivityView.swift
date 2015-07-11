//
//  ActivityView.swift
//  RandomHighwaySign
//
//  Created by Zachary Maillard on 7/11/15.
//  Copyright (c) 2015 SagebrushGIS. All rights reserved.
//


import Foundation
import UIKit

public class ActivityView : UIView{

    var view:UIView!
    
    @IBOutlet weak var imageView: UIImageView!
    
    @IBOutlet weak var statusText: UILabel!

    
    func xibSetup(){
        view = loadViewFromNib()
    }
    
    
}