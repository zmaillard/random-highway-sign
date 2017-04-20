//
//  Networking.swift
//  RandomHighwaySign
//
//  Created by Zachary Maillard on 4/19/17.
//  Copyright © 2017 SagebrushGIS. All rights reserved.
//

import Foundation
import ReactiveSwift

public protocol Networking {
    func requestJSON(url:String, parameters: [String:AnyObject]?)
        -> SignalProducer<AnyObject, NetworkError>
}
