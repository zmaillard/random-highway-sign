//
//  SignDetailsViewController.swift
//  RandomHighwaySign
//
//  Created by Zachary Maillard on 4/29/15.
//  Copyright (c) 2015 SagebrushGIS. All rights reserved.
//

import UIKit

class SignDetailsViewController: UIViewController {
    var signTitle : String!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.title = signTitle
    }

}
