//
//  Network.swift
//  RandomHighwaySign
//
//  Created by Zachary Maillard on 4/19/17.
//  Copyright © 2017 SagebrushGIS. All rights reserved.
//

import Foundation
import Alamofire
import ReactiveSwift

public final class Network : Networking{
    private let queue = dispatch_queue_create("com.sagebrushgis.randomhighwaysign.Network.Queue", DISPATCH_QUEUE_SERIAL)
    
    public init(){
        
    }
    
    public func requestJSON(url: String, parameters: [String : AnyObject]?) -> SignalProducer<AnyObject, NetworkError> {
        return SignalProducer {observer, disposable in
            let serializer = Alamofire.Request.Json
    }
    
}
