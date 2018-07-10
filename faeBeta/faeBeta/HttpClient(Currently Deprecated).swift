//
//  HttpClient(Currently Deprecated).swift
//  faeBeta
//
//  Created by Yue Shen on 7/3/18.
//  Copyright © 2018 fae. All rights reserved.
//

import Foundation

func getImage(fileID: Int, type: Int, isChatRoom: Bool, _ authentication: [String: String] = Key.shared.headerAuthentication(), completion: @escaping (Int, String, Data?) -> Void) {
    
    let URL = isChatRoom ? "\(Key.shared.baseURL)/files/chat_rooms/\(fileID)/cover_image" : "\(Key.shared.baseURL)/files/\(fileID)/data"
    var headers = [
        "User-Agent": Key.shared.headerUserAgent,
        "Fae-Client-Version": Key.shared.headerClientVersion,
        "Accept": Key.shared.headerAccept,
        ]
    for (key, value) in authentication {
        headers[key] = value
    }
    
    alamoFireManager.request(URL, headers: headers)
        .responseJSON { response in
            if let statusCode = response.response?.statusCode {
                if let JSON = response.response?.allHeaderFields {
                    guard var etag = JSON["Etag"] as? String else {
                        completion(statusCode, "", nil)
                        return
                    }
                    etag = etag.removeSpecialChars()
                    completion(statusCode, etag, response.data)
                } else {
                    completion(statusCode, "", nil)
                }
            } else {
                if case let .failure(error) = response.result {
                    completion(error._code, error.localizedDescription, nil)
                } else {
                    completion(NSURLErrorBadServerResponse, "[GET image with id-\(fileID)]", nil)
                }
            }
    }
}

func postChatRoomCoverImageToURL(_ className: String, parameter: [String: Any]?, authentication: [String: String]?, completion: @escaping (Int, Any?) -> Void) {
    let URL = Key.shared.baseURL + "/" + className
    var headers = [
        "User-Agent": Key.shared.headerUserAgent,
        "Fae-Client-Version": Key.shared.headerClientVersion,
        //        "Device-ID" : headerDeviceID,
        "Accept": Key.shared.headerAccept,
        //        "Content-Type" : "application/form-data"
    ]
    if authentication != nil {
        for (key, value) in authentication! {
            headers[key] = value
        }
    }
    
    if parameter != nil {
        let imageData = parameter!["cover_image"] as! Data
        let chatRoomId = parameter!["chat_room_id"] as! NSNumber
        alamoFireManager.upload(multipartFormData: {
            MultipartFormData in
            MultipartFormData.append(imageData, withName: "cover_image", fileName: "cover_image.jpg", mimeType: "image/jpeg")
            MultipartFormData.append(NSKeyedArchiver.archivedData(withRootObject: chatRoomId), withName: "chat_room_id")
        }, usingThreshold: 100, to: URL, method: .post, headers: headers, encodingCompletion: { encodingResult in
            switch encodingResult {
            case .success(let upload, _, _):
                upload.responseJSON { response in
                    print(response.response.debugDescription)
                    if response.response != nil {
                        if let resMess = response.result.value {
                            completion(response.response!.statusCode, resMess)
                        } else {
                            // Bug here
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
        })
        
    }
    
}
