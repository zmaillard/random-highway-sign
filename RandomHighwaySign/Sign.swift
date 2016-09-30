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
    
    static let baseUrl = "http://www.sagebrushgis.com/"
    
    func asURLRequest() throws -> URLRequest {
        let result: (path:String, parameters: Parameters)  = {
            switch self{
            case .single():
                return ("/random/",["format":"json" as AnyObject])
            case .geo(let latitude, let longitude, let radius, let page) where page > 1:
                return ("/query/", ["type":"geo" as AnyObject,"lat": latitude as AnyObject, "lon":longitude as AnyObject, "radius":radius as AnyObject, "page":page as AnyObject])
            case .geo(let latitude, let longitude, let radius, _):
                return ("/query/", ["type":"geo" as AnyObject,"lat": latitude as AnyObject, "lon":longitude as AnyObject, "radius":radius as AnyObject])
            }
        }()
        
        let url = try RandomRequestRouter.baseUrl.asURL()
        
        let urlRequest = Foundation.URLRequest(url: url.appendingPathComponent(result.path))

        return try URLEncoding.default.encode(urlRequest, with: result.parameters)

    }

    
}

final class County : NSObject, ResponseObjectSerializable{
    var name : String = ""
    var slug : String = ""
    var stateName : String = ""
    var stateSlug : String = ""
    var type : String = ""
    
    
    @objc required init(response: HTTPURLResponse, representation: AnyObject){
        
        self.name = representation.value(forKeyPath: "name") as! String
        self.slug = representation.value(forKeyPath: "slug") as! String
        self.stateName = representation.value(forKeyPath: "statename") as! String
        self.stateSlug = representation.value(forKeyPath: "stateslug") as! String
        self.type = representation.value(forKeyPath: "type") as! String

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
        
        self.highway = representation.value(forKeyPath: "highway") as! String
        self.highwaySlug = representation.value(forKeyPath: "highwayslug") as! String
        self.milepost = representation.value(forKeyPath: "milepost") as! Double
        self.sort = representation.value(forKeyPath: "sort") as! Int
        self.type = representation.value(forKeyPath: "type") as! String
        self.typeSlug = representation.value(forKeyPath: "typeslug") as! String
        self.url = representation.value(forKeyPath: "url") as! String
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
        
        
        if let tempPage = representation.value(forKeyPath: "page") as? String{
            self.currentPage = Int(tempPage)!
        }else{
            self.currentPage = representation.value(forKeyPath: "page") as! Int
        }
        
    
        
        self.totalPages = representation.value(forKeyPath: "pages") as! Int


        
    }
    
}

final class Sign : ResponseObjectSerializable, ResponseCollectionSerializable{
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
    
    
    static func  getRandom(completion: @escaping(Sign) -> Void) {
        let _ = Alamofire.request(RandomRequestRouter.single())
            .responseCollection { (response: DataResponse<[Sign]>) in
                let s = response.result.value![0];
                
                completion(s);

        }

    }
    
    required init(response: HTTPURLResponse, representation: AnyObject){
        
        self.country = representation.value(forKeyPath: "title") as! String
        self.date = representation.value(forKeyPath: "date") as! String
        if let desc = representation.value(forKeyPath: "description") as? String{
            self.imageDescription =  desc
        }
        self.id = representation.value(forKeyPath: "id") as! Int
        self.largeImage = representation.value(forKeyPath: "largeimage") as! String
        self.latitude = representation.value(forKeyPath: "latitude") as! Double
        self.longitude = representation.value(forKeyPath: "longitude") as! Double
        self.mediumImage = representation.value(forKeyPath: "mediumimage") as! String
        self.place = representation.value(forKeyPath: "place") as! String
        self.smallImage = representation.value(forKeyPath: "smallimage") as! String
        self.state = representation.value(forKeyPath: "state") as! String
        self.thumbnail = representation.value(forKeyPath: "thumbnail") as! String
        self.title = representation.value(forKeyPath: "title") as! String
        
        self.county =  County(response:response, representation:representation.value(forKeyPath: "county")! as AnyObject)
        self.highways = Highway.collection(response: response, representation: representation.value(forKeyPath: "highways")! as AnyObject)
    
    }
    
    static func collection(response: HTTPURLResponse, representation: AnyObject) -> [Sign]{
        var signs = [Sign]()

        for sign in representation.value(forKeyPath: "signs") as! [NSDictionary]{
            signs.append(Sign(response: response, representation: sign))
        }
        
        return signs
    }
}
