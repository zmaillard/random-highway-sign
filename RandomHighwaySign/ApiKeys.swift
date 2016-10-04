//
//  ApiKeys.swift
//  RandomHighwaySign
//
//  http://dev.iachieved.it/iachievedit/using-property-lists-for-api-keys-in-swift-applications/

import Foundation

func valueForApiKey(keyName:String) -> String{
    let filePath = Bundle.main.path(forResource: "ApiKeys", ofType: "plist")
    let plist = NSDictionary(contentsOfFile: filePath!)
    
    let value:String = plist?.object(forKey: keyName) as! String
    return value
}
