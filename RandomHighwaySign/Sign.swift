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

enum BackendError: Error {
    case network(error: Error) // Capture any underlying Error from the URLSession API
    case dataSerialization(error: Error)
    case jsonSerialization(error: Error)
    case xmlSerialization(error: Error)
    case objectSerialization(reason: String)
}

public protocol ResponseObjectSerializable {
    init?(response: HTTPURLResponse, representation: AnyObject)
}

public protocol ResponseCollectionSerializable {
    static func collection(response: HTTPURLResponse, representation: AnyObject) -> [Self]
}


extension DataRequest {
    public func responseObject<T: ResponseObjectSerializable>(queue: DispatchQueue? = nil, completionHandler: @escaping(DataResponse<T>) -> Void) ->Self {
        
        let responseSerializer = DataResponseSerializer<T> { request, response, data, error in
            guard error == nil else { return .failure(error!) }
            
            let JSONResponseSerializer = DataRequest.jsonResponseSerializer(options: .allowFragments)
            let result = JSONResponseSerializer.serializeResponse(request, response, data, error)
            
            switch result {
            case .success(let value):
                if let
                    response = response,
                    let responseObject = T(response: response, representation: value as AnyObject)
                {
                    return .success(responseObject)
                } else {
                    let failureReason = "JSON could not be serialized into response object: \(value)"
                    
                    return .failure(BackendError.objectSerialization(reason: failureReason));
                }
            case .failure(let error):
                return .failure(error)
            }
        }
        
        return response(responseSerializer: responseSerializer, completionHandler: completionHandler)
    }
}



extension DataRequest {
    public func responseCollection<T: ResponseCollectionSerializable>(queue: DispatchQueue? = nil, completionHandler: @escaping(DataResponse<[T]>) -> Void) -> Self {
        let responseSerializer = DataResponseSerializer<[T]> { request, response, data, error in
            guard error == nil else { return .failure(error!) }
            
            let JSONSerializer = DataRequest.jsonResponseSerializer(options: .allowFragments)
            let result = JSONSerializer.serializeResponse(request, response, data, error)
            
            switch result {
            case .success(let value):
                if let response = response {
                    return .success(T.collection(response: response, representation: value as AnyObject))
                } else {
                    let failureReason = "Response collection could not be serialized due to nil response"
                    return .failure(BackendError.objectSerialization(reason: failureReason));
                }
            case .failure(let error):
                return .failure(error)
            }
        }
        
        return response(responseSerializer: responseSerializer, completionHandler: completionHandler)
    }
}



enum RandomRequestRouter : URLRequestConvertible{
    
    case single()
    case geo(latitude:Double, longitude:Double, radius:Int, page:Int)
    case county(state:String, county:String, page:Int)
    
    static let baseUrl = "http://www.sagebrushgis.com/"
    
    func asURLRequest() throws -> URLRequest {
        let result: (path:String, parameters: Parameters)  = {
            switch self{
            case .single():
                return ("/api/list/random/",["format":"json" as AnyObject])
            case .geo(let latitude, let longitude, let radius, let page) where page > 1:
                return ("/api/list/location/", ["lat": latitude as AnyObject, "lon":longitude as AnyObject, "radius":radius as AnyObject, "page":page as AnyObject])
            case .geo(let latitude, let longitude, let radius, _):
                return ("/api/list/location/", ["lat": latitude as AnyObject, "lon":longitude as AnyObject, "radius":radius as AnyObject])
            case .county(let state, let county, _):
                return ("/api/list/countysign/" + state + "/" + county + "/",["format":"json" as AnyObject])
            } 
        }()
        
        let url = try RandomRequestRouter.baseUrl.asURL()
        
        let urlRequest = Foundation.URLRequest(url: url.appendingPathComponent(result.path))

        return try URLEncoding.default.encode(urlRequest, with: result.parameters)

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

    
    @objc required init(response: HTTPURLResponse, representation: AnyObject){
        
        self.highway = representation.value(forKeyPath: "Highway") as! String
        self.highwaySlug = representation.value(forKeyPath: "HighwaySlug") as! String
        self.milepost = representation.value(forKeyPath: "Milepost") as! Double
        self.sort = representation.value(forKeyPath: "StateSort") as! Int
        self.type = representation.value(forKeyPath: "Type") as! String
        self.typeSlug = representation.value(forKeyPath: "TypeSlug") as! String
        self.url = representation.value(forKeyPath: "Url") as! String
    }

 
    @objc static func collection(response: HTTPURLResponse, representation: AnyObject) -> [Highway]{
        let highwayArray = representation as! [AnyObject]
 
        return highwayArray.map({Highway(response: response, representation: $0)})
    }
    
    
}

final class SignCollectionResult : NSObject, ResponseObjectSerializable{
    var signs : Array<Sign> = [Sign]()
    var currentPage : Int = 0;
    var totalPages : Int = 0;
    
    @objc required init(response: HTTPURLResponse, representation: AnyObject){

        self.signs = Sign.collection(response: response, representation: representation)
        
        /*
        if let tempPage = representation.value(forKeyPath: "page") as? String{
            self.currentPage = Int(tempPage)!
        }else{
            self.currentPage = representation.value(forKeyPath: "page") as! Int
        }
        
    
        
        self.totalPages = representation.value(forKeyPath: "pages") as! Int
 */


        
    }
    
}

final class Sign : ResponseObjectSerializable, ResponseCollectionSerializable{
    var country : String = ""
    //var county : County?
    var date : String = ""
    var imageDescription : String = ""
    var highways : Array<Highway> = [Highway]()
    var id : String = ""
    var largeImage : String = ""
    var latitude : Double = 0.0
    var longitude : Double = 0.0
    var mediumImage : String = ""
    var place : String = ""
    var smallImage : String = ""
    var state : String = ""
    var thumbnail : String = ""
    var title : String = ""
    
    
    static func  getRandom(completion: @escaping(Sign) -> Void) {
        let _ = Alamofire.request(RandomRequestRouter.single())
            .responseCollection { (response: DataResponse<[Sign]>) in
                let s = response.result.value![0];
                
                completion(s);

        }

    }
    
    required init(response: HTTPURLResponse, representation: AnyObject){
        
        self.country = representation.value(forKeyPath: "Title") as! String
        self.date = representation.value(forKeyPath: "DateTaken") as! String
        if let desc = representation.value(forKeyPath: "Description") as? String{
            self.imageDescription =  desc
        }
        self.id = representation.value(forKeyPath: "ImageID") as! String
        self.largeImage = representation.value(forKeyPath: "large") as! String
        self.mediumImage = representation.value(forKeyPath: "medium") as! String
        self.place = representation.value(forKeyPath: "Place") as! String
        self.smallImage = representation.value(forKeyPath: "small") as! String
        self.state = representation.value(forKeyPath: "State") as! String
        self.thumbnail = representation.value(forKeyPath: "thumbnail") as! String
        self.title = representation.value(forKeyPath: "Title") as! String
        
        
        self.latitude = representation.value(forKeyPath: "Latitude") as! Double
        self.longitude = representation.value(forKeyPath: "Longitude") as! Double
 
        self.highways = Highway.collection(response: response, representation: representation.value(forKeyPath: "HighwaySorting")! as AnyObject)
    
    }
    
    static func collection(response: HTTPURLResponse, representation: AnyObject) -> [Sign]{
        var signs = [Sign]()

        for sign in representation.value(forKeyPath: "results") as! [NSDictionary]{
            signs.append(Sign(response: response, representation: sign))
        }
        
        return signs
    }
}
