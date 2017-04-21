//
//  RoadSign.swift
//  RandomHighwaySign
//
//  Created by Zachary Maillard on 4/21/17.
//  Copyright © 2017 SagebrushGIS. All rights reserved.
//

import Foundation
import Argo
import Curry
import Runes

struct RoadSign{
    let country : String
    let date : String
    let imageDescription : String
    let highways : [HighwaySorting]
    let id : String
    let largeImage : String
    let latitude : Double
    let longitude : Double
    let mediumImage : String
    let place : String
    let smallImage : String
    let state : String
    let thumbnail : String
    let title : String
}



extension RoadSign : Decodable{
    static func decode(_ json:JSON) -> Decoded<RoadSign> {
        return curry(RoadSign.init){
            
        }
    }
}
