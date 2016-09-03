//
//  HTTPClient.swift
//  faeBeta
//
//  Created by blesssecret on 5/18/16.
//  Copyright © 2016 fae. All rights reserved.
//

import UIKit
import Alamofire
import SDWebImage

var baseURL = "https://api.letsfae.com"
var version = "x.faeapp.v1"
var headerAccept = "application/x.faeapp.v1+json"
var headerContentType = "application/x-www-form-urlencoded"
let headerClientVersion : String = "fae-ios-1.0.0"
var headerDeviceID : String = "00000001111"
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


func postImageToURL(className:String,parameter:[String:AnyObject]? , authentication:[String : AnyObject]?, completion:(Int,AnyObject?)->Void){
    let URL = baseURL + "/" + className
    var headers = [
        "User-Agent" : headerUserAgent,
        "Fae-Client-Version" : headerClientVersion,
//        "Device-ID" : headerDeviceID,
        "Accept": headerAccept,
//        "Content-Type" : "application/form-data"
    ]
    if authentication != nil{
        for(key,value) in authentication! {
            headers[key] = value as? String
            print(value)
        }
    }
    do{
        if parameter != nil{
            let imageData = parameter!["avatar"]as! NSData
            
            Alamofire.upload(.POST, URL, headers: headers, multipartFormData: { (MultipartFormData) in
//                MultipartFormData.appendBodyPart
                MultipartFormData.appendBodyPart(data: imageData, name: "avatar", fileName: "avatar.jpg", mimeType: "image/jpeg")
                }, encodingMemoryThreshold: 100, encodingCompletion: { encodingResult in
                    print(encodingResult)
                    switch encodingResult {
                    case .Success(let upload, _, _):
                        print(encodingResult)
                        upload.responseJSON { response in
                            print(response.response!.statusCode)
                            print(response)

                            if let respon = response.response{
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
                                    //                            MARK: bug here
                                    completion(response.response!.statusCode,"no Json body")
                                }
                            }
                            else{
                                completion(-500,"Internet error")
                            }

                        }
                    case .Failure(let encodingError):
                        completion(-400,"failure")
                        print(encodingError)
                    }
            })
            
        }
    }
    catch let error as NSError{
        print(error)
    }
}

func getImageFromURL(className:String, authentication:[String : AnyObject]?, completion:(Int,AnyObject?)->Void){
    let URL = baseURL + "/" + className
    var headers = [
        "User-Agent" : headerUserAgent,
        "Fae-Client-Version" : headerClientVersion,
        //        "Device-ID" : headerDeviceID,
        "Accept": headerAccept,
        //        "Content-Type" : "application/form-data"
    ]
    if authentication != nil{
        for(key,value) in authentication! {
            headers[key] = "FAE MjM6dkZ5U1QyaWhnOHRRZm9sY013b2JPWlBTYXRiS2RKOjMw" as? String
//            print(value)
        }
    }
    let manager = SDWebImageManager().imageDownloader
//    manager.setValue("User-Agent", forHTTPHeaderField: headerUserAgent)
//    manager.setValue("Fae-Client-Version", forHTTPHeaderField: headerClientVersion)
//    manager.setValue("Accept", forHTTPHeaderField: headerAccept)
    manager.setValue("Authorization", forHTTPHeaderField: "FAE MjM6dkZ5U1QyaWhnOHRRZm9sY013b2JPWlBTYXRiS2RKOjMw")
    //get function doesn't work
    manager.downloadImageWithURL(NSURL(string: URL), options: SDWebImageDownloaderOptions.AllowInvalidSSLCertificates,
        progress: {( receivedSize: Int, expectedSize: Int) in
            print(receivedSize)
        }
        , completed: { (image:UIImage!, data:NSData!, error:NSError!, finished:Bool) -> Void in
//            print(error)
            if (image != nil)
            {
                completion(201,image)
//                completion(201,data)
            }
            else {
                completion(400, error)
            }
    })
}
func postToURL(className:String,parameter:[String:AnyObject]? , authentication:[String : AnyObject]?, completion:(Int,AnyObject?)->Void){
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
        if parameter != nil{
            Alamofire.request(.POST, URL, parameters: parameter,headers:headers)
                .responseJSON{response in
                    print(response.response!.statusCode)
                    print(response)
                    if let respon = response.response{
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
//                            MARK: bug here
                            completion(response.response!.statusCode,"no Json body")
                        }
                    }
                    else{
                        completion(-500,"Internet error")
                    }
            }
        }
    }
    catch let error as NSError{
        print(error)
    }
}


func getFromURL(className:String,parameter:[String:AnyObject]?, authentication:[String : AnyObject]?, completion:(Int,AnyObject?)->Void){
    print(parameter)
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
        if parameter==nil{
            Alamofire.request(.GET, URL,headers:headers)
                .responseJSON{response in
                    //print(response.response!.statusCode)
                    if let respon = response.response{
                        if(response.response!.statusCode != 0){
                            print("finished")
                        }
                        if let JSON = response.response?.allHeaderFields{
                            print(JSON)
                            
                        }
                        completion(response.response!.statusCode,response.result.value)
                    }
                    else{
                        completion(-500,"Internet error")
                    }
            }
        }
        else{
            Alamofire.request(.GET, URL,parameters:parameter,headers:headers)
                .responseJSON{response in
                    //print(response.response!.statusCode)
                    if let respon = response.response{
                        if(response.response!.statusCode != 0){
                            print("finished")
                        }
                        if let JSON = response.response?.allHeaderFields{
                            print(JSON)
                            
                        }
                        completion(response.response!.statusCode,response.result.value)
                    }
                    else{
                        completion(-500,"Internet error")
                    }
            }
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
                //print(response.response!.statusCode)
                if let respon = response.response{
                    if(response.response!.statusCode != 0){
                        print("finished")
                    }
                    if let JSON = response.response?.allHeaderFields{
                        print(JSON)
                        
                    }
                    completion(response.response!.statusCode,"nothing here")
                }
                else{
                    completion(-500,"Internet error")
                }
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
                //print(response.response!.statusCode)
                if let respon = response.response{
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
                else{
                    completion(-500,"Internet error")
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

