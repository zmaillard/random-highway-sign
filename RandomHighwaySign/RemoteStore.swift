//
//  RemoteStore.swift
//  RandomHighwaySign
//
//  Created by Zachary Maillard on 4/20/17.
//  Copyright © 2017 SagebrushGIS. All rights reserved.
//

import Foundation
import ReactiveCocoa
import ReactiveSwift

class RemoteStore : SignStore{
    
    private let baseUrl:NSURL
    
    init(baseUrl:NSURL) {
        self.baseUrl = baseUrl
    }

    func randomSign() -> SignalProducer<Sign, NSError>{
        return nil
    }
    
    func signsAtLocation(parameters: SignLocationParameters) -> SignalProducer<[Sign], NSError>{
            return nil
    }
    
    func signsAtCounty(parameters: SignCountyParameters) -> SignalProducer<[Sign], NSError>{
        return nil
    }
    
    
    
}
