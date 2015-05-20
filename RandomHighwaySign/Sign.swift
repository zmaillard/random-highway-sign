//
//  Sign.swift
//  NearbySignFinder
//
//  Created by Zachary Maillard on 5/8/15.
//  Copyright (c) 2015 SagebrushGIS. All rights reserved.
//

import Foundation
import SwiftyJSON
import Alamofire

@objc public protocol ResponseObjectSerializable{
    init(response:NSHTTPURLResponse, representation:AnyObject)
}

@objc public protocol ResponseCollectionSerializable {
    static func collection(#response: NSHTTPURLResponse, representation: AnyObject) -> [Self]
}

extension Alamofire.Request{
    public func responseObject<T: ResponseObjectSerializable>(completionHandler: (NSURLRequest, NSHTTPURLResponse?, T?, NSError?) -> Void) -> Self {
        let serializer: Serializer = { (request, response, data) in
            let JSONSerializer = Request.JSONResponseSerializer(options: .AllowFragments)
            let (JSON: AnyObject?, serializationError) = JSONSerializer(request, response, data)
            if response != nil && JSON != nil {
                return (T(response: response!, representation: JSON!), nil)
            } else {
                return (nil, serializationError)
            }
        }
        
        return response(serializer: serializer, completionHandler: { (request, response, object, error) in
            completionHandler(request, response, object as? T, error)
        })
    }
}



extension Alamofire.Request {
    public func responseCollection<T: ResponseCollectionSerializable>(completionHandler: (NSURLRequest, NSHTTPURLResponse?, [T]?, NSError?) -> Void) -> Self {
        let serializer: Serializer = { (request, response, data) in
            let JSONSerializer = Request.JSONResponseSerializer(options: .AllowFragments)
            let (JSON: AnyObject?, serializationError) = JSONSerializer(request, response, data)
            if response != nil && JSON != nil {
                return (T.collection(response: response!, representation: JSON!), nil)
            } else {
                return (nil, serializationError)
            }
        }
        
        return response(serializer: serializer, completionHandler: { (request, response, object, error) in
            completionHandler(request, response, object as? [T], error)
        })
    }
}

enum RandomRequestRouter : URLRequestConvertible{
    static let baseUrl = "http://www.sagebrushgis.com/"
    
    case Single()
    case Geo(latitude:Double, longitude:Double, radius:Int, page:Int)
    
    var URLRequest: NSURLRequest{
        let (path:String, parameters:[String: AnyObject]?) = {
            switch self{
            case .Single():
                return ("/random/",["format":"json"])
            case .Geo(let latitude, let longitude, let radius, let page) where page > 1:
                return ("/query/", ["type":"geo","lat": latitude, "lon":longitude, "radius":radius, "page":page])
            case .Geo(let latitude, let longitude, let radius, _):
                return ("/query/", ["type":"geo","lat": latitude, "lon":longitude, "radius":radius])
        }
        }()
        
        let URL =   NSURL(string: RandomRequestRouter.baseUrl)
        let URLRequest = NSURLRequest(URL: URL!.URLByAppendingPathComponent(path))
        let encoding = Alamofire.ParameterEncoding.URL
        
        return encoding.encode(URLRequest, parameters: parameters).0
        
    }
    
}

final class County : NSObject, ResponseObjectSerializable{
    var name : String = ""
    var slug : String = ""
    var stateName : String = ""
    var stateSlug : String = ""
    var type : String = ""
    
    
    @objc required init(response: NSHTTPURLResponse, representation: AnyObject){
        
        self.name = representation.valueForKeyPath("name") as! String
        self.slug = representation.valueForKeyPath("slug") as! String
        self.stateName = representation.valueForKeyPath("statename") as! String
        self.stateSlug = representation.valueForKeyPath("stateslug") as! String
        self.type = representation.valueForKeyPath("type") as! String

    }

}

final class Highway : NSObject, ResponseObjectSerializable, ResponseCollectionSerializable{
    var highway : String = ""
    var highwaySlug : String = ""
    var milepost : Double = 0.0
    var sort : Int = 0
    var type : String = ""
    var typeSlug : String = ""
    var url : String = ""

    
    @objc required init(response: NSHTTPURLResponse, representation: AnyObject){
        
        self.highway = representation.valueForKeyPath("highway") as! String
        self.highwaySlug = representation.valueForKeyPath("highwayslug") as! String
        self.milepost = representation.valueForKeyPath("milepost") as! Double
        self.sort = representation.valueForKeyPath("sort") as! Int
        self.type = representation.valueForKeyPath("type") as! String
        self.typeSlug = representation.valueForKeyPath("typeSlug") as! String
        self.url = representation.valueForKeyPath("url") as! String
    }
    
    @objc static func collection(#response: NSHTTPURLResponse, representation: AnyObject) -> [Highway]{
        var highwayArray = representation as! [AnyObject]
        
        return highwayArray.map({Highway(response: response, representation: $0)})
    }
    
    
}

final class Sign : NSObject, ResponseObjectSerializable, ResponseCollectionSerializable{
    var country : String = ""
    var county : County?
    var date : String = ""
    var imageDescription : String = ""
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
    
    @objc required init(response: NSHTTPURLResponse, representation: AnyObject){
        
        self.country = representation.valueForKeyPath("title") as! String
        self.date = representation.valueForKeyPath("date") as! String
        self.imageDescription = representation.valueForKeyPath("description") as! String
        self.id = representation.valueForKeyPath("id") as! Int64
        self.largeImage = representation.valueForKeyPath("largeimage") as! String
        self.latitude = representation.valueForKeyPath("latitude") as! Double
        self.longitude = representation.valueForKeyPath("longitude") as! Double
        self.mediumImage = representation.valueForKeyPath("mediumimage") as! String
        self.place = representation.valueForKeyPath("place") as! String
        self.smallImage = representation.valueForKeyPath("smallimage") as! String
        self.state = representation.valueForKeyPath("state") as! String
        self.thumbnail = representation.valueForKeyPath("thumbnail") as! String
        self.title = representation.valueForKeyPath("title") as! String
        
        self.county =  County(response:response, representation:representation.valueForKeyPath("county")!)
        self.highways = Highway.collection(response: response, representation: representation.valueForKeyPath("highways")!)
    
    }
    
    @objc static func collection(#response: NSHTTPURLResponse, representation: AnyObject) -> [Sign]{
        var signArray = representation as! [AnyObject]
        
        return signArray.map({Sign(response: response, representation: $0)})
    }
}
