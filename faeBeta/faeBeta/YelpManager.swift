//
//  YelpManager.swift
//  GooglePicker
//
//  Created by User on 23/01/2017.
//  Copyright © 2017 User. All rights reserved.
//

import Foundation
import Alamofire
import SwiftyJSON

private let yelpAppID = "SMLJKKmPDUdXzffEzbJvfw"
private let yelpSecret = "ojH9iYiK5TSGeaQGRazxYL2oyQQd9S87gTuHgpsgbcMzZdO2aeXHB3dpL2kQKO6w"
private let yelpHeaders = ["Content-Type": "application/x-www-form-urlencoded"]
private var requestHeaders = ["Authorization": ""]

class YelpManager {
    
    class var shared:YelpManager {
        struct Singleton {
            static let instance = YelpManager()
        }
        return Singleton.instance
    }
    
    var token = ""
    
    func hasToken() -> Bool {
        return token.characters.count != 0;
    }

    init() {
        
    }
    
    func query(request : YelpQuery, completion : @escaping (_ res : [YelpResult]) -> ()) {
        var result = [YelpResult]()
        if (!hasToken()) {
            Alamofire.request("https://api.yelp.com/oauth2/token",method: .post, parameters: ["grant_type":"client_credentials","client_id":yelpAppID,"client_secret":yelpSecret],headers: yelpHeaders).responseJSON { response in
                if let val = response.result.value {
                    let json = JSON(val)
                    self.token = json["token_type"].stringValue + " " + json["access_token"].stringValue
                    Alamofire.request("https://api.yelp.com/v3/businesses/search", method: .get, parameters: request.getDict(), headers: ["Authorization" : self.token]).responseJSON { response in
                        if let data = response.result.value {
                            let json = JSON(data)["businesses"]
                            for i in 0...(json.count - 1){
                                result.append(YelpResult(url: json[i]["image_url"].stringValue, add: json[i]["location"]["address1"].stringValue, name: json[i]["name"].stringValue, lat: json[i]["coordinates"]["latitude"].stringValue, long: json[i]["coordinates"]["longitude"].stringValue))
                            }
                            completion(result)
                        }
                    }
                }
            }
        } else {
            Alamofire.request("https://api.yelp.com/v3/businesses/search", method: .get, parameters: request.getDict(), headers: ["Authorization" : self.token]).responseJSON { response in
                if let data = response.result.value {
                    let json = JSON(data)["businesses"]
                    for i in 0...(json.count - 1){
                        result.append(YelpResult(url: json[i]["image_url"].stringValue, add: json[i]["location"]["address1"].stringValue, name: json[i]["name"].stringValue, lat: json[i]["coordinates"]["latitude"].stringValue, long: json[i]["coordinates"]["longitude"].stringValue))
                    }
                    completion(result)
                }
            }
        }
    }
    
}
