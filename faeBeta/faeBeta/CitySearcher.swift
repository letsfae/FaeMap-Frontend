//
//  CitySearcher.swift
//  faeBeta
//
//  Created by Yue Shen on 6/3/18.
//  Copyright © 2018 fae. All rights reserved.
//

import Foundation
import Alamofire
import SwiftyJSON

class CitySearcher: NSObject {
    
    static let shared = CitySearcher()
    
    @discardableResult
    func cityAutoComplete(_ query: String, _ completion: @escaping (Int, Any?) -> Void) -> DataRequest? {
        
        let urlAutoComp = "http://gd.geobytes.com/AutoCompleteCity?&sort=size&q=" + query
        guard let urlString = urlAutoComp.addingPercentEncoding(withAllowedCharacters: CharacterSet.urlQueryAllowed) else {
            completion(-503, "Invalid URL")
            return nil
        }
        let request = Alamofire.request(urlString, method: .get).responseJSON { (message) in
            guard let response = message.response else {
                completion(-501, "No Response")
                return
            }
            guard let value = message.result.value else {
                completion(-502, "No Value")
                return
            }
            completion(response.statusCode, value)
        }
        return request
    }
    
    @discardableResult
    func cityDetail(_ query: String, _ completion: @escaping (Int, Any?) -> Void) -> DataRequest? {
        
        let urlAutoComp = "http://gd.geobytes.com/GetCityDetails?fqcn=" + query
        guard let urlString = urlAutoComp.addingPercentEncoding(withAllowedCharacters: CharacterSet.urlQueryAllowed) else {
            completion(-503, "Invalid URL")
            return nil
        }
        let request = Alamofire.request(urlString, method: .get).responseJSON { (message) in
            guard let response = message.response else {
                completion(-501, "No Response")
                return
            }
            guard let value = message.result.value else {
                completion(-502, "No Value")
                return
            }
            if response.statusCode / 100 == 2 {
                let result = JSON(value)
                let lat = result["geobyteslatitude"].doubleValue
                let lon = result["geobyteslongitude"].doubleValue
                completion(response.statusCode, CLLocation(latitude: lat, longitude: lon))
            } else {
                completion(response.statusCode, value)
            }
        }
        
        return request
    }
    
}
