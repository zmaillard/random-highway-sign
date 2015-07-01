//
//  ApiKeys.swift
//  RandomHighwaySign
//
//  Created by Zachary Maillard on 7/1/15.
//  Copyright (c) 2015 SagebrushGIS. All rights reserved.
//

import Foundation

func valueForApiKey(#keyName:String) -> String{
    let filePath = NSBundle.mainBundle().pathForResource("ApiKeys", ofType: "plist")
    let plist = NSDictionary(contentsOfFile: filePath!)
    
    let value:String = plist?.objectForKey(keyName) as! String
    return value
}