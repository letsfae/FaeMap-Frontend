//
//  HTTPClient.swift
//  faeBeta
//
//  Created by blesssecret on 5/18/16.
//  Copyright © 2016 fae. All rights reserved.
//

import UIKit
import Alamofire

    var baseURL = "https://api.letsfae.com/"
    var version = "x.faeapp.v1"
    var headerAuth : String = "null"
    let headerClientVersion : String = "fae-ios-1.0.0"
    var headerDeviceID : String = "0000000"
    var headerUserAgent : String = "iphone5"
//    var headerClientVersion : String = "null"
    var headerAuthorization : String = "null"
/*
do {
    let jsonData = try NSJSONSerialization.dataWithJSONObject(dic, options: NSJSONWritingOptions.PrettyPrinted)
    // here "jsonData" is the dictionary encoded in JSON data
} catch let error as NSError {
    print(error)
}

do {
    let decoded = try NSJSONSerialization.JSONObjectWithData(jsonData, options: []) as? [String:String]
    // here "decoded" is the dictionary decoded from JSON data
} catch let error as NSError {
    print(error)
}*/
func postToURL(className:String,keyValue:[String:AnyObject] ,completion:(Int?,String)->Void){
    let URL = baseURL + "/" + className
    let headers = [
        "User-Agent" : headerUserAgent,
        "Fae-Client-Version" : headerClientVersion,
        "Device-ID" : headerDeviceID,
        "Accept": "application/x.faeapp.v1+json",
        "Content-Type" : "application/x-www-form-urlencoded"
    ]
    do{
//        let parameters = try! NSJSONSerialization.dataWithJSONObject(keyValue, options: NSJSONWritingOptions.PrettyPrinted)
//        let parameters2 = ["password":"asdfsa","email":"asdfsa", "first_name":"asdfsa","last_name":"asdfsa","birthday":"asdfsa","gender":"asdfsa"]
        Alamofire.request(.POST, URL, parameters: keyValue,headers:headers)
            .responseJSON{response in
            print(response.response!.statusCode)
            
            if(response.response!.statusCode != 0){
                print("finished")
            }
            if let JSON = response.response?.allHeaderFields{
                print(JSON)
                
            }
            completion(response.response!.statusCode,"nothing here")
        }
    }
    catch let error as NSError{
        print(error)
    }
    

}

    //utf-5 encode
    func utf8Encode(inputString:String)->String{
        var encodedString = inputString.stringByAddingPercentEscapesUsingEncoding(NSUTF8StringEncoding)
        return encodedString!
    }
    
    //utf-8 decode
    func utf8Decode(inputString:String)->String{
        var decodeString = inputString.stringByReplacingPercentEscapesUsingEncoding(NSUTF8StringEncoding)!
        return decodeString
    }

