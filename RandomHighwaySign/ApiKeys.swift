//
//  ApiKeys.swift
//  RandomHighwaySign
//
//  http://dev.iachieved.it/iachievedit/using-property-lists-for-api-keys-in-swift-applications/

import Foundation

func valueForApiKey(#keyName:String) -> String{
    let filePath = NSBundle.mainBundle().pathForResource("ApiKeys", ofType: "plist")
    let plist = NSDictionary(contentsOfFile: filePath!)
    
    let value:String = plist?.objectForKey(keyName) as! String
    return value
}