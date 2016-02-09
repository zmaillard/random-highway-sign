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
import AlamofireImage

public protocol ResponseObjectSerializable {
    init?(response: NSHTTPURLResponse, representation: AnyObject)
}

public protocol ResponseCollectionSerializable {
    static func collection(response response: NSHTTPURLResponse, representation: AnyObject) -> [Self]
}


extension Alamofire.Request{
    public func responseObject<T: ResponseObjectSerializable>(completionHandler: Response<T, NSError> -> Void) -> Self {
        let responseSerializer = ResponseSerializer<T, NSError> { request, response, data, error in
            guard error == nil else { return .Failure(error!) }
            
            let JSONResponseSerializer = Request.JSONResponseSerializer(options: .AllowFragments)
            let result = JSONResponseSerializer.serializeResponse(request, response, data, error)
            
            switch result {
            case .Success(let value):
                if let
                    response = response,
                    responseObject = T(response: response, representation: value)
                {
                    return .Success(responseObject)
                } else {
                    let failureReason = "JSON could not be serialized into response object: \(value)"
                    let error = Error.errorWithCode(.JSONSerializationFailed, failureReason: failureReason)
                    return .Failure(error)
                }
            case .Failure(let error):
                return .Failure(error)
            }
        }
        
        return response(responseSerializer: responseSerializer, completionHandler: completionHandler)
    }
}



extension Alamofire.Request {
    public func responseCollection<T: ResponseCollectionSerializable>(completionHandler: Response<[T], NSError> -> Void) -> Self {
        let responseSerializer = ResponseSerializer<[T], NSError> { request, response, data, error in
            guard error == nil else { return .Failure(error!) }
            
            let JSONSerializer = Request.JSONResponseSerializer(options: .AllowFragments)
            let result = JSONSerializer.serializeResponse(request, response, data, error)
            
            switch result {
            case .Success(let value):
                if let response = response {
                    return .Success(T.collection(response: response, representation: value))
                } else {
                    let failureReason = "Response collection could not be serialized due to nil response"
                    let error = Error.errorWithCode(.JSONSerializationFailed, failureReason: failureReason)
                    return .Failure(error)
                }
            case .Failure(let error):
                return .Failure(error)
            }
        }
        
        return response(responseSerializer: responseSerializer, completionHandler: completionHandler)
    }
}



enum RandomRequestRouter : URLRequestConvertible{
    static let baseUrl = "http://www.sagebrushgis.com/"
    
    case Single()
    case Geo(latitude:Double, longitude:Double, radius:Int, page:Int)
    
    var URLRequest: NSMutableURLRequest{
        let (path, parameters): (String, [String: AnyObject]?) = {
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
        
        let resp =  encoding.encode(URLRequest, parameters: parameters).0
        print(resp)
        return resp
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
        self.typeSlug = representation.valueForKeyPath("typeslug") as! String
        self.url = representation.valueForKeyPath("url") as! String
    }
    
    @objc static func collection(response response: NSHTTPURLResponse, representation: AnyObject) -> [Highway]{
        let highwayArray = representation as! [AnyObject]
        
        return highwayArray.map({Highway(response: response, representation: $0)})
    }
    
    
}

final class SignCollectionResult : NSObject, ResponseObjectSerializable{
    var signs : Array<Sign> = [Sign]()
    var currentPage : Int = 0;
    var totalPages : Int = 0;
    
    @objc required init(response: NSHTTPURLResponse, representation: AnyObject){

        self.signs = Sign.collection(response: response, representation: representation)
        
        
        if let tempPage = representation.valueForKeyPath("page") as? String{
            self.currentPage = Int(tempPage)!
        }else{
            self.currentPage = representation.valueForKeyPath("page") as! Int
        }
        
    
        
        self.totalPages = representation.valueForKeyPath("pages") as! Int


        
    }
    
}

final class Sign : NSObject, ResponseObjectSerializable, ResponseCollectionSerializable{
    var country : String = ""
    var county : County?
    var date : String = ""
    var imageDescription : String = ""
    var highways : Array<Highway> = [Highway]()
    var id : Int = 0
    var largeImage : String = ""
    var latitude : Double = 0.0
    var longitude : Double = 0.0
    var mediumImage : String = ""
    var place : String = ""
    var smallImage : String = ""
    var state : String = ""
    var thumbnail : String = ""
    var title : String = ""
    
    static func  getRandom(callback:(sign:Sign) -> Void ) {
        Alamofire.request(RandomRequestRouter.Single())
            .responseCollection{(response: Response<[Sign], NSError>)in
                
                callback( sign:response.result.value![0])
        }
    }
    
    @objc required init(response: NSHTTPURLResponse, representation: AnyObject){
        
        self.country = representation.valueForKeyPath("title") as! String
        self.date = representation.valueForKeyPath("date") as! String
        if let desc = representation.valueForKeyPath("description") as? String{
            self.imageDescription =  desc
        }
        self.id = representation.valueForKeyPath("id") as! Int
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
    
    @objc static func collection(response response: NSHTTPURLResponse, representation: AnyObject) -> [Sign]{
        var signs = [Sign]()

        for sign in representation.valueForKeyPath("signs") as! [NSDictionary]{
            signs.append(Sign(response: response, representation: sign))
        }
        
        return signs
    }
}
