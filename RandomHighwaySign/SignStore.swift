//
//  SignStore.swift
//  RandomHighwaySign
//
//  Created by Zachary Maillard on 4/20/17.
//  Copyright © 2017 SagebrushGIS. All rights reserved.
//

import Foundation
import ReactiveCocoa
import ReactiveSwift

struct SignLocationParameters{
    let latitude:Decimal
    let longitude:Decimal
    let radius:Decimal
    let page:Int
    
}

struct SignCountyParameters{
    let state:String
    let county:String
    let page:Int
    
}


protocol SignStore{
    func randomSign() -> SignalProducer<Sign, NSError>
    
    func signsAtLocation(parameters: SignLocationParameters) -> SignalProducer<[Sign], NSError>

    func signsAtCounty(parameters: SignCountyParameters) -> SignalProducer<[Sign], NSError>
    
}
