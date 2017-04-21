//
//  HighwaySorting.swift
//  RandomHighwaySign
//
//  Created by Zachary Maillard on 4/21/17.
//  Copyright © 2017 SagebrushGIS. All rights reserved.
//

import Foundation
import Argo
import Curry
import Runes

struct HighwaySorting {
    let highway : String
    let highwaySlug : String
    let milepost : Double
    let sort : String
    let type : String
    let typeSlug : String
    let url : String
}

extension HighwaySorting : Decodable{
    static func decode(_ json:JSON) -> Decoded<HighwaySorting> {
        return curry(HighwaySorting.init)    }
}
