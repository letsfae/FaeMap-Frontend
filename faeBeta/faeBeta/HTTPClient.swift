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
import SwiftyJSON

func postImageToURL(_ className: String, parameter: [String: Any]? , authentication:[String: Any]?, completion: @escaping (Int, Any?) -> Void) {
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
        }
    }
    
    if parameter != nil{
        let imageData = parameter!["avatar"]as! Data

        Alamofire.upload(multipartFormData: {
            (MultipartFormData) in
            MultipartFormData.append(imageData, withName: "avatar", fileName: "avatar.jpg", mimeType: "image/jpeg")
        }, usingThreshold: 100, to: URL, method: .post, headers: headers, encodingCompletion: { (encodingResult) in
                switch encodingResult {
                case .success(let upload, _, _):
                    upload.responseJSON { response in
                        print(response.response.debugDescription)
                        if response.response != nil {
                            if let resMess = response.result.value {
                                completion(response.response!.statusCode, resMess)
                            } else {
                                // bug here
                                completion(response.response!.statusCode, "no Json body")
                            }
                        } else{
                            completion(-500, "Internet error")
                        }
                        
                    }
                case .failure(let encodingError):
                    completion(-400, "failure")
                    print(encodingError)
                }
        })
        
    }

}

func postCoverImageToURL(_ className: String,parameter: [String: AnyObject]? , authentication: [String: AnyObject]?, completion:@escaping (Int, Any?) -> Void){
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
        }
    }
    
    if parameter != nil{
        let imageData = parameter!["name_card_cover"]as! Data

        Alamofire.upload( multipartFormData:
            { (MultipartFormData) in
            MultipartFormData.append(imageData, withName: "name_card_cover", fileName: "name_card_cover", mimeType: "image/jpeg")
        },usingThreshold: 100, to: URL,  method: .post, headers: headers, encodingCompletion: { encodingResult in
                switch encodingResult {
                case .success(let upload, _, _):
                    upload.responseJSON { response in
                        if response.response != nil{
                            if let resMess = response.result.value {
                                completion(response.response!.statusCode,resMess)
                            } else{
                                // bug here
                                completion(response.response!.statusCode,"no Json body")
                            }
                        } else {
                            completion(-500,"Internet error")
                        }

                    }
                case .failure(let encodingError):
                    completion(-400,"failure")
                    print(encodingError)
                }
        })
    }
}

func postToURL(_ className:String, parameter:[String:Any]?, authentication:[String: Any]?, completion:@escaping (Int, Any?) -> Void){
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
    
    if parameter != nil{
        Alamofire.request(URL, method: .post, parameters: parameter!, headers: headers)
            .responseJSON{response in
                
                if response.response != nil{
                    if(response.response!.statusCode != 0) {
                        
                    }
                    if let _ = response.response?.allHeaderFields {
                        
                    }
                    if let resMess = response.result.value {
                        completion(response.response!.statusCode, resMess)
                    }
                    else{
                        // MARK: bug here
                        completion(response.response!.statusCode, "no Json body")
                    }
                }
                else{
                    completion(-500, "Internet error")
                }
        }
    }
}

func getFromURL(_ className:String,parameter:[String:Any]?, authentication:[String : Any]?, completion:@escaping (Int,Any?)->Void){
    
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
    
    if parameter == nil {
        Alamofire.request(URL, headers: headers)
            .responseJSON{ response in
                //print(response.response!.statusCode)
                if response.response != nil {
                    completion(response.response!.statusCode, response.result.value)
                } else {
                    completion(-500, "Internet error")
                }
        }
    } else {
        Alamofire.request(URL, parameters: parameter!, headers: headers)
            .responseJSON{ response in
                if response.response != nil {
                    completion(response.response!.statusCode, response.result.value)
                } else {
                    completion(-500, "Internet error")
                }
        }
    }

}

func deleteFromURL(_ className: String, parameter: [String: Any] , authentication: [String: Any]?, completion:@escaping (Int, Any?) -> Void){
    let URL = baseURL + "/" + className
    var headers = [
        "Accept": headerAccept,
        "User-Agent" : headerUserAgent,
        "Fae-Client-Version" : headerClientVersion,
        "Device-ID" : headerDeviceID,
        ]
    if authentication == nil {
        completion(500,"we must get the authentication number" as AnyObject?)
    }
    if authentication != nil {
        for(key, value) in authentication! {
            headers[key] = value as? String
        }
    }

    Alamofire.request(URL, method: .delete, headers:headers)
        .responseJSON{response in
            if response.response != nil{
                completion(response.response!.statusCode,"nothing here")
            } else {
                completion(-500,"Internet error")
            }
    }
}

func getAvatar(userID: Int, type: Int, completion:@escaping (Int, String, Data?) -> Void) {
    
    let URL = "\(baseURL)/files/users/\(userID)/avatar/\(type)"
    let headers = [
        "User-Agent" : headerUserAgent,
        "Fae-Client-Version" : headerClientVersion,
        "Accept": headerAccept,
        ]
    
    Alamofire.request(URL, headers: headers)
        .responseJSON{ response in
            if response.response != nil {
                guard let statusCode = response.response?.statusCode else {
                    completion(-500, "", nil)
                    return
                }
                if let JSON = response.response?.allHeaderFields {
                    guard let etag = JSON["Etag"] as? String else {
                        completion(statusCode, "", nil)
                        return
                    }
                    completion(statusCode, etag, response.data)
                } else {
                    completion(statusCode, "", nil)
                }
            } else {
                completion(-500, "", nil)
            }
    }
}

func getImage(fileID: Int, type: Int, completion:@escaping (Int, String, Data?) -> Void) {
    
    let URL = "\(baseURL)/files/\(fileID)/data"
    let headers = [
        "User-Agent" : headerUserAgent,
        "Fae-Client-Version" : headerClientVersion,
        "Accept": headerAccept,
        ]
    
    Alamofire.request(URL, headers: headers)
        .responseJSON{ response in
            if response.response != nil {
                guard let statusCode = response.response?.statusCode else {
                    completion(-500, "", nil)
                    return
                }
                if let JSON = response.response?.allHeaderFields {
                    guard let etag = JSON["Etag"] as? String else {
                        completion(statusCode, "", nil)
                        return
                    }
                    completion(statusCode, etag, response.data)
                } else {
                    completion(statusCode, "", nil)
                }
            } else {
                completion(-500, "", nil)
            }
    }
}

func postFileToURL(_ className: String, parameter:[String: Any]?, authentication:[String: Any]?, completion: @escaping (Int, Any?) -> Void) {
    let URL = baseURL + "/" + className
    
    var headers = [
        "User-Agent" : headerUserAgent,
        "Fae-Client-Version" : headerClientVersion,
        "Accept": headerAccept,
        ]
    
    if authentication != nil {
        for(key,value) in authentication! {
            headers[key] = value as? String
        }
    }
    
    if parameter != nil {
        let imageData = parameter!["file"] as! Data
        let mediaType = parameter!["type"] as! String
        Alamofire.upload(
            multipartFormData: { (multipartFormData) in
                multipartFormData.append(imageData, withName: "file", fileName: "momentImage.jpg", mimeType: "image/jpeg")
                multipartFormData.append((mediaType.data(using: .utf8))!, withName: "type")
        },
            usingThreshold: 100,
            to: URL,
            method: .post,
            headers: headers,
            encodingCompletion: { (encodingResult) in
                switch encodingResult {
                case .success(let upload, _, _):
                    upload.responseJSON { response in
                        print(response.response.debugDescription)
                        if response.response != nil {
                            if let resMess = response.result.value {
                                completion(response.response!.statusCode, resMess)
                            } else {
                                completion(response.response!.statusCode, "no Json body")
                            }
                        } else {
                            completion(-500, "Internet error")
                        }
                    }
                case .failure(let encodingError):
                    completion(-400, "failure")
                    print(encodingError)
                }
        })}
}

func postChatRoomCoverImageToURL(_ className:String,parameter:[String:Any]? , authentication:[String : Any]?, completion: @escaping (Int,Any?)->Void){
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
        }
    }
    
    if parameter != nil{
        let imageData = parameter!["cover_image"] as! Data
        let chatRoomId = parameter!["chat_room_id"] as! NSNumber
        Alamofire.upload(multipartFormData: {
            (MultipartFormData) in
            MultipartFormData.append(imageData, withName: "cover_image", fileName: "cover_image.jpg", mimeType: "image/jpeg")
            MultipartFormData.append(NSKeyedArchiver.archivedData(withRootObject: chatRoomId) , withName: "chat_room_id")
        }, usingThreshold: 100, to: URL, method: .post, headers: headers, encodingCompletion: { (encodingResult) in
            switch encodingResult {
            case .success(let upload, _, _):
                upload.responseJSON { response in
                    print(response.response.debugDescription)
                    if response.response != nil{
                        if let resMess = response.result.value {
                            completion(response.response!.statusCode, resMess)
                        } else {
                            // Bug here
                            completion(response.response!.statusCode, "no Json body")
                        }
                    }
                    else{
                        completion(-500, "Internet error")
                    }
                    
                }
            case .failure(let encodingError):
                completion(-400,"failure")
                print(encodingError)
            }
        })
        
    }
    
}

//utf-8 encode
func utf8Encode(_ inputString:String)->String{
    //MARK: REN tempory change it here, test if anything's wrong
    let encodedString = inputString.addingPercentEncoding(withAllowedCharacters: .urlHostAllowed)
 //   let encodedString = inputString.stringByAddingPercentEscapesUsingEncoding(NSUTF8StringEncoding)
    return encodedString!
}

//utf-8 decode
func utf8Decode(_ inputString:String)->String{
    //MARK: REN tempory change it here, test if anything's wrong
    let decodeString = inputString.removingPercentEncoding!
    //let decodeString = inputString.stringByReplacingPercentEscapesUsingEncoding(NSUTF8StringEncoding)!
    return decodeString
}

