//
//  Sign.swift
//  NearbySignFinder
//
//  Created by Zachary Maillard on 5/8/15.
//  Copyright (c) 2015 SagebrushGIS. All rights reserved.
//

import Foundation
import SwiftyJSON

class County{
    var name : String = ""
    var slug : String = ""
    var stateName : String = ""
    var stateSlug : String = ""
    var type : String = ""
    
    static func fromJson(json:JSON) -> County{
        var c : County = County()
        
        if let name = json["name"].string{
            c.name = name
        }
        
        if let slug = json["slug"].string{
            c.slug = slug
        }
        
        if let statename = json["statename"].string{
            c.stateName = statename
        }
        
        if let stateslug = json["stateslug"].string{
            c.stateSlug = stateslug
        }
        
        if let type = json["type"].string{
            c.type = type
        }
        
        return c
    }
}

class Highway{
    var highway : String = ""
    var highwaySlug : String = ""
    var milepost : Double = 0.0
    var sort : Int = 0
    var type : String = ""
    var typeSlug : String = ""
    var url : String = ""
    
    static func fromJson(json:JSON) -> Highway{
        var h : Highway = Highway()
        
        if let highway = json["highway"].string{
            h.highway = highway
        }
        
        if let highwayslug = json["highwayslug"].string{
            h.highwaySlug = highwayslug
        }
        
        if let milepost = json["milepost"].double{
            h.milepost = milepost
        }
        
        if let sort = json["sort"].int{
            h.sort = sort
        }
        
        if let type = json["type"].string{
            h.type = type
        }
        
        if let typeSlug = json["typeslug"].string{
            h.typeSlug = typeSlug
        }
        
        if let url = json["url"].string{
            h.url = url
        }
        
        return h
    }
    
    
    
}

class Sign{
    var country : String = ""
    var county : County?
    var date : String = ""
    var description : String = ""
    var highways : Array<Highway> = [Highway]()
    var id : Int64 = 0
    var largeImage : String = ""
    var latitude : Double = 0.0
    var longitude : Double = 0.0
    var mediumImage : String = ""
    var place : String = ""
    var smallImage : String = ""
    var state : String = ""
    var thumbnail : String = ""
    var title : String = ""
    
    static func fromJson(json:JSON) -> Sign{
        var s : Sign = Sign()
        
        if let country = json["country"].string{
            s.country = country
        }
        
        s.county = County.fromJson(json["county"])
        
        if let date = json["date"].string{
            s.date = date
        }
        
        if let description = json["description"].string{
            s.description = description
        }
        
        for (index: String, subJson: JSON) in json["highways"] {
            s.highways.append(Highway.fromJson(subJson))
        }
        
        if let id = json["id"].int64{
            s.id = id
        }
        
        if let largeimage = json["largeimage"].string{
            s.largeImage = largeimage
        }
        
        if let latitude = json["latitude"].double{
            s.latitude = latitude
        }
        
        if let longitude = json["longitude"].double{
            s.longitude = longitude
        }
        
        if let mediumimage = json["mediumimage"].string{
            s.mediumImage = mediumimage
        }
        
        if let place = json["place"].string{
            s.place = place
        }
        
        if let smallimage = json["smallimage"].string{
            s.smallImage = smallimage
        }
        
        if let state = json["state"].string{
            s.state = state
        }
        
        if let thumbnail = json["thumbnail"].string{
            s.thumbnail = thumbnail
        }
        
        if let title = json["title"].string{
            s.title = title
        }
        return s
    }
}
