//
//  Browse.swift
//  RandomHighwaySign
//
//  Created by Zachary Maillard on 9/28/16.
//  Copyright © 2016 SagebrushGIS. All rights reserved.
//

import Foundation
import Alamofire

enum SubdivisionType : String{
    case country = "Country"
    case state = "State"
    case county = "County"
    

}

final class Browse : ResponseCollectionSerializable, ResponseObjectSerializable {
    var Name:String = ""
    var Slug:String = ""
    var BrowseType:SubdivisionType = .country
    
    required init(response: HTTPURLResponse, representation: AnyObject){
        
        self.Name = representation.value(forKeyPath: "Name") as! String
        self.Slug = representation.value(forKeyPath: "Slug") as! String
        
    }
    
    static func collection(response: HTTPURLResponse, representation: AnyObject) -> [Browse]{
        var browseResults = [Browse]()
        
        for browse in representation.value(forKeyPath: "results") as! [NSDictionary]{
            browseResults.append(Browse(response: response, representation: browse))
        }
        
        return browseResults
    }
    

    
    func HasSubdivisions() -> Bool {
        return BrowseType != .country
    }
    
    func GetSubdivisions(byType: SubdivisionType, completion: @escaping([Browse]) -> Void){
        
        var url:URLRequestConvertible
        
        switch byType {
        case .country:
            url = BrowseRequestRouter.countries()
        case .state:
            url = BrowseRequestRouter.states( country: self.Slug)
        case .county:
            url = BrowseRequestRouter.counties(state: self.Slug )
        }
        
        let _ = Alamofire.request(url)
            .responseCollection { (response: DataResponse<[Browse]>) in
                let res = response.result.value!;
                completion(res)
        }
        
    }
    
    static func GetCountrySubdivisions(completion: @escaping([Browse]) -> Void){
    

        let _ = Alamofire.request(BrowseRequestRouter.countries())
            .responseCollection { (response: DataResponse<[Browse]>) in
                    let res = response.result.value!;
                completion(res)
        }
    
    }
    
    
}

enum BrowseRequestRouter : URLRequestConvertible{
    
    case countries()
    case states(country:String)
    case counties(state:String)
    
    static let baseUrl = "http://www.sagebrushgis.com/"
    
    func asURLRequest() throws -> URLRequest {
        let result: (path:String, parameters: Parameters)  = {
            switch self{
            case .countries():
                return ("/api/list/countries/",["format":"json" as AnyObject])
            case .states(let country):
                return ("/api/list/states/" + country,["format":"json" as AnyObject])
            case .counties(let state):
                return ("/api/list/county/" + state,["format":"json" as AnyObject])
            }
        }()
        
        let url = try BrowseRequestRouter.baseUrl.asURL()
        
        let urlRequest = Foundation.URLRequest(url: url.appendingPathComponent(result.path))
        
        return try URLEncoding.default.encode(urlRequest, with: result.parameters)
        
    }
    
    
}


