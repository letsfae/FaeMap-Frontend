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
var headerAccept = "application/x.faeapp.v1+json"
var headerContentType = "application/x-www-form-urlencoded"
let headerClientVersion : String = "fae-ios-1.0.0"
var headerDeviceID : String = "0000000"
var headerUserAgent : String = "iphone5"

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
// not use anymore

func postToURL(className:String,parameter:[String:AnyObject] , authentication:[String : AnyObject]?, completion:(Int,AnyObject?)->Void){
    let URL = baseURL + "/" + className
    var headers = [
        "User-Agent" : headerUserAgent,
        "Fae-Client-Version" : headerClientVersion,
        "Device-ID" : headerDeviceID,
        "Accept": headerAccept,
        "Content-Type" : headerContentType
    ]
    if authentication != nil {
        for(key,value) in authentication!{
            headers[key] = value as? String
        }
    }
    do{
        Alamofire.request(.POST, URL, parameters: parameter,headers:headers)
            .responseJSON{response in
                print(response.response!.statusCode)
                print(response)
                
                if(response.response!.statusCode != 0){
                    print("finished")
                }
                if let JSON = response.response?.allHeaderFields{
                    print(JSON)
                    
                }
                if let resMess = response.result.value {
                    completion(response.response!.statusCode,resMess)
                }
                else{
                    //MARK: bug here
                    completion(response.response!.statusCode,"no Json body")
                }
        }
    }
    catch let error as NSError{
        print(error)
    }
}


func getFromURL(className:String, authentication:[String : AnyObject], completion:(Int,AnyObject?)->Void){
    let URL = baseURL + "/" + className
    var headers = [
        "User-Agent" : headerUserAgent,
        "Fae-Client-Version" : headerClientVersion,
        "Device-ID" : headerDeviceID,
        "Accept": headerAccept,
        "Content-Type" : headerContentType
    ]
    for(key,value) in authentication{
        headers[key] = value as? String
    }
    do{
        Alamofire.request(.GET, URL,headers:headers)
            .responseJSON{response in
                print(response.response!.statusCode)
                
                if(response.response!.statusCode != 0){
                    print("finished")
                }
                if let JSON = response.response?.allHeaderFields{
                    print(JSON)
                    
                }
                completion(response.response!.statusCode,response.description)
        }
    }
    catch let error as NSError{
        print(error)
    }
}

func deleteFromURL(className:String,parameter:[String:AnyObject] , authentication:[String : AnyObject]?, completion:(Int,AnyObject?)->Void){
    let URL = baseURL + "/" + className
    var headers = [
        "Accept": headerAccept,
        "User-Agent" : headerUserAgent,
        "Fae-Client-Version" : headerClientVersion,
        "Device-ID" : headerDeviceID,
        ]
    if authentication == nil {
        completion(500,"we must get the authentication number")
    }
    if authentication != nil {
        for(key,value) in authentication! {
            headers[key] = value as? String
        }
    }
    print(headers)
    do{
        Alamofire.request(.DELETE, URL,headers:headers)
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

func putToURL(className:String,parameter:[String:AnyObject] , authentication:[String : AnyObject]?, completion:(Int,AnyObject?)->Void){
    let URL = baseURL + "/" + className
    var headers = [
        "User-Agent" : headerUserAgent,
        "Fae-Client-Version" : headerClientVersion,
        "Device-ID" : headerDeviceID,
        "Accept": headerAccept,
        "Content-Type" : headerContentType
    ]
    if authentication != nil {
        for(key,value) in authentication!{
            headers[key] = value as? String
        }
    }
    
    do{
        Alamofire.request(.PUT, URL, parameters: parameter,headers:headers)
            .responseJSON{response in
                print(response.response!.statusCode)
                
                if(response.response!.statusCode != 0){
                    print("finished")
                }
                if let JSON = response.response?.allHeaderFields{
                    print(JSON)
                }
                if let resMess = response.result.value {
                    completion(response.response!.statusCode,resMess)
                }
                else{
                    //MARK: bug here
                    completion(response.response!.statusCode,"this filed need to modify")
                }
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

