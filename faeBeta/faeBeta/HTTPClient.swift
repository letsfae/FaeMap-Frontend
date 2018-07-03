//
//  HTTPClient.swift
//  faeBeta
//
//  Created by blesssecret on 5/18/16.
//  Copyright © 2016 fae. All rights reserved.
//

import UIKit
import Alamofire
import SwiftyJSON
import RealmSwift

enum PostMethod: String {
    case avatar = "files/users/avatar"
    case cover = "files/users/name_card_cover"
    case search = "search"
    case bulkSearch = "search/bulk"
    case chat = "chats_v2"
    case chat_read = "chats/read"
    case sign_up = "users"
    case log_in = "authentication"
    case reset_login_email = "reset_login/code"
    case reset_login_email_verify = "reset_login/code/verify"
    case reset_password = "reset_login/password"
    case update_account = "users/account"
}

let configuration = { () -> URLSessionConfiguration in
    let con = URLSessionConfiguration.default
//    con.timeoutIntervalForRequest = 4 // seconds
//    con.timeoutIntervalForResource = 4
    return con
}()

let alamoFireManager = Alamofire.SessionManager(configuration: configuration)

func postImage(_ method: PostMethod, imageData: Data, completion: @escaping (Int, Any?) -> Void) {
    
    let fullURL = Key.shared.baseURL + "/" + method.rawValue
    let headers = Key.shared.header(auth: true, type: .data)
    let name = method == .avatar ? "avatar" : "name_card_cover"
    
    alamoFireManager.upload(multipartFormData: {
        MultipartFormData in
        MultipartFormData.append(imageData, withName: name, fileName: name + ".jpg", mimeType: "image/jpeg")
    }, usingThreshold: 100, to: fullURL, method: .post, headers: headers, encodingCompletion: { encodingResult in
        switch encodingResult {
        case .success(let upload, _, _):
            upload.responseJSON { response in
                print(response.response.debugDescription)
                guard let resMess = response.result.value else {
                    completion(response.response!.statusCode, "no Json body")
                    return
                }
                completion(response.response!.statusCode, resMess)
            }
        case .failure(let encodingError):
            completion(-400, "failure")
            networkErrorHandling(error: encodingError, method: "[postImage]", subUrl: method.rawValue)
        }
    })
}

@discardableResult
func searchToURL(_ method: PostMethod, parameter: [String: Any], completion: @escaping (Int, Any?) -> Void) -> DataRequest {
    
    let fullURL = Key.shared.baseURL + "/" + method.rawValue
    let headers = Key.shared.header(auth: true, type: .json)
    
    let request = alamoFireManager.request(fullURL, method: .post, parameters: parameter, encoding: JSONEncoding.default, headers: headers)
        .responseJSON { response in
            if case let .success(value) = response.result {
                guard let statusCode = response.response?.statusCode else {
                    completion(-401, "success, but status code not found")
                    return
                }
                completion(statusCode, value)
            }
            else
            if case let .failure(error) = response.result {
                guard let statusCode = response.response?.statusCode else {
                    completion(-402, "failure, and status code not found")
                    networkErrorHandling(error: error, method: "[searchToURL]", subUrl: method.rawValue)
                    return
                }
                completion(statusCode, "failure")
                networkErrorHandling(error: error, method: "[searchToURL]", subUrl: method.rawValue)
            }
            /*
            guard response.response != nil else {
                completion(-500, "Internet error")
                return
            }
            if response.response!.statusCode != 0 {
                
            }
            if let _ = response.response?.allHeaderFields {
                
            }
            if let resMess = response.result.value {
                completion(response.response!.statusCode, resMess)
            } else {
                completion(response.response!.statusCode, "no Json body")
            }
             */
    }
    
    return request
}

@discardableResult
func postToURL(_ className: String, parameter: [String: String], authentication: [String: String]?, completion: @escaping (Int, Any?) -> Void) -> DataRequest {
    
    let fullURL = Key.shared.baseURL + "/" + className
    let headers = Key.shared.header(auth: authentication != nil, type: .normal)
    
    let request = alamoFireManager.request(fullURL, method: .post, parameters: parameter, headers: headers)
        .responseJSON { response in
            
            if case let .success(value) = response.result {
                guard let statusCode = response.response?.statusCode else {
                    completion(-401, "success, but status code not found")
                    return
                }
                completion(statusCode, value)
            }
            else
                if case let .failure(error) = response.result {
                    guard let statusCode = response.response?.statusCode else {
                        completion(-402, "failure, and status code not found")
                        networkErrorHandling(error: error, method: "[postToURL]", subUrl: className)
                        return
                    }
                    completion(statusCode, "failure")
                    networkErrorHandling(error: error, method: "[postToURL]", subUrl: className)
            }
            
            /*
            guard response.response != nil else {
                print("POST NO RESPONSE")
                print(response.debugDescription)
                print(response.description)
                print(response.error as Any)
                print("POST NO RESPONSE END")
                completion(-500, "Internet error")
                return
            }
            if response.response!.statusCode != 0 {
                
            }
            if let _ = response.response?.allHeaderFields {
                
            }
            if let resMess = response.result.value {
                completion(response.response!.statusCode, resMess)
            } else {
                completion(response.response!.statusCode, "no Json body")
            }
             */
    }
    
    return request
}

@discardableResult
func getFromURL(_ className: String, parameter: [String: Any]?, authentication: [String: String]?, completion: @escaping (Int, Any?) -> Void) -> DataRequest {
    
    let fullURL = Key.shared.baseURL + "/" + className
    let headers = Key.shared.header(auth: authentication != nil, type: .normal)
    
    var request: DataRequest!
    
    if parameter == nil {
        request = alamoFireManager.request(fullURL, method: .get, headers: headers)
            .responseJSON { response in
                
                if case let .success(value) = response.result {
                    guard let statusCode = response.response?.statusCode else {
                        completion(-401, "success, but status code not found")
                        return
                    }
                    completion(statusCode, value)
                }
                else
                    if case let .failure(error) = response.result {
                        guard let statusCode = response.response?.statusCode else {
                            completion(-402, "failure, and status code not found")
                            networkErrorHandling(error: error, method: "[getFromURL w/o para]", subUrl: className)
                            return
                        }
                        completion(statusCode, "failure")
                        networkErrorHandling(error: error, method: "[getFromURL w/0 para]", subUrl: className)
                }
                
                /*
                if response.response != nil {
                    completion(response.response!.statusCode, response.result.value)
                } else {
                    completion(-500, "Internet error")
                }
                 */
            }
    } else {
        request = alamoFireManager.request(fullURL, method: .get, parameters: parameter!, headers: headers)
            .responseJSON { response in
                
                if case let .success(value) = response.result {
                    guard let statusCode = response.response?.statusCode else {
                        completion(-401, "success, but status code not found")
                        return
                    }
                    completion(statusCode, value)
                }
                else
                    if case let .failure(error) = response.result {
                        guard let statusCode = response.response?.statusCode else {
                            completion(-402, "failure, and status code not found")
                            networkErrorHandling(error: error, method: "[getFromURL w/ para]", subUrl: className)
                            return
                        }
                        completion(statusCode, "failure")
                        networkErrorHandling(error: error, method: "[getFromURL w/ para]", subUrl: className)
                }
                /*
                if response.response != nil {
                    completion(response.response!.statusCode, response.result.value)
                } else {
                    completion(-500, "Internet error")
                }
                 */
            }
    }
    
    return request
}

func deleteFromURL(_ className: String, parameter: [String: Any], completion: @escaping (Int, Any?) -> Void) {
    
    let fullURL = Key.shared.baseURL + "/" + className
    let headers = Key.shared.header(auth: true, type: .normal)
    
    alamoFireManager.request(fullURL, method: .delete, headers: headers)
        .responseJSON { response in
            
            if case let .success(value) = response.result {
                guard let statusCode = response.response?.statusCode else {
                    completion(-401, "success, but status code not found")
                    return
                }
                completion(statusCode, value)
            }
            else
                if case let .failure(error) = response.result {
                    guard let statusCode = response.response?.statusCode else {
                        completion(-402, "failure, and status code not found")
                        networkErrorHandling(error: error, method: "[deleteFromURL]", subUrl: className)
                        return
                    }
                    completion(statusCode, "failure")
                    networkErrorHandling(error: error, method: "[deleteFromURL]", subUrl: className)
            }
            /*
            if response.response != nil {
                completion(response.response!.statusCode, "nothing here")
            } else {
                completion(-500, "Internet error")
            }
             */
        }
}

func getAvatar(userID: Int, type: Int, _ authentication: [String: String] = Key.shared.headerAuthentication(), completion: @escaping (Int, String, Data?) -> Void) {
    
    guard let url = URL(string: "\(Key.shared.baseURL)/files/users/\(userID)/avatar/\(type)") else { return }
    var urlRequest = URLRequest(url: url)
    urlRequest.httpMethod = "GET"
    urlRequest.cachePolicy = .reloadIgnoringLocalAndRemoteCacheData
    urlRequest.setValue(Key.shared.headerUserAgent, forHTTPHeaderField: "User-Agent")
    urlRequest.setValue(Key.shared.headerClientVersion, forHTTPHeaderField: "Fae-Client-Version")
    urlRequest.setValue(Key.shared.headerAccept, forHTTPHeaderField: "Accept")
    for (key, value) in authentication {
        urlRequest.setValue(value, forHTTPHeaderField: key)
    }
    
    var avatarInRealm: Data?
    
    let realm = try! Realm()
    if let avatarRealm = realm.objects(UserImage.self).filter("user_id == %@", "\(userID)").first {
        if let etag = type == 2 ? avatarRealm.smallAvatarEtag : avatarRealm.largeAvatarEtag {
            urlRequest.setValue(etag, forHTTPHeaderField: "If-None-Match")
            //joshprint("[getAvatar - \(userID)] If-None-Match ", etag)
        }
        avatarInRealm = type == 2 ? avatarRealm.userSmallAvatar as Data? : avatarRealm.userLargeAvatar as Data?
    }
    
    alamoFireManager.request(urlRequest)
        .responseJSON { response in
            guard response.response != nil else {
                completion(-500, "", nil)
                return
            }
            guard let statusCode = response.response?.statusCode else {
                completion(-500, "", nil)
                return
            }
            if let JSON = response.response?.allHeaderFields {
                guard var etag = JSON["Etag"] as? String else {
                    completion(statusCode, "", nil)
                    return
                }
                //joshprint("[getAvatar - \(userID)] before", etag)
                etag = etag.removeSpecialChars()
                //joshprint("[getAvatar - \(userID)] after ", etag)
                if statusCode / 100 == 3 {
                    completion(304, etag, avatarInRealm)
                    //joshprint("[getAvatar - \(userID)] 304")
                    return
                }
                //joshprint("[getAvatar - \(userID)] check statusCode", statusCode)
                if let realmUser = realm.objects(UserImage.self).filter("user_id == %@", "\(userID)").first {
                    try! realm.write {
                        if type == 0 {
                            realmUser.largeAvatarEtag = etag
                            realmUser.userLargeAvatar = response.data as NSData?
                        } else {
                            realmUser.smallAvatarEtag = etag
                            realmUser.userSmallAvatar = response.data as NSData?
                        }
                        completion(statusCode, etag, response.data)
                    }
                } else {
                    let realmUser = UserImage()
                    realmUser.user_id = "\(userID)"
                    if type == 0 {
                        realmUser.largeAvatarEtag = etag
                        realmUser.userLargeAvatar = response.data as NSData?
                    } else {
                        realmUser.smallAvatarEtag = etag
                        realmUser.userSmallAvatar = response.data as NSData?
                    }
                    try! realm.write {
                        realm.add(realmUser)
                        completion(statusCode, etag, response.data)
                    }
                }
            } else {
                completion(statusCode, "", nil)
            }
        }
}

func getCoverPhoto(userID: Int, type: Int, _ authentication: [String: String] = Key.shared.headerAuthentication(), completion: @escaping (Int, String, Data?) -> Void) {
    
    guard let url = URL(string: "\(Key.shared.baseURL)/files/users/\(userID)/name_card_cover") else { return }
    var urlRequest = URLRequest(url: url)
    urlRequest.httpMethod = "GET"
    urlRequest.cachePolicy = .reloadIgnoringLocalAndRemoteCacheData
    urlRequest.setValue(Key.shared.headerUserAgent, forHTTPHeaderField: "User-Agent")
    urlRequest.setValue(Key.shared.headerClientVersion, forHTTPHeaderField: "Fae-Client-Version")
    urlRequest.setValue(Key.shared.headerAccept, forHTTPHeaderField: "Accept")
    for (key, value) in authentication {
        urlRequest.setValue(value, forHTTPHeaderField: key)
    }
    
    var coverPhotoInRealm: Data?
    
    let realm = try! Realm()
    if let coverPhotoRealm = realm.objects(UserImage.self).filter("user_id == %@", "\(userID)").first {
        if let etag = coverPhotoRealm.coverPhotoEtag {
            urlRequest.setValue(etag, forHTTPHeaderField: "If-None-Match")
            //joshprint("[getAvatar - \(userID)] If-None-Match ", etag)
        }
        coverPhotoInRealm = coverPhotoRealm.userCoverPhoto as Data?
    }
    
    alamoFireManager.request(urlRequest)
        .responseJSON { response in
            guard response.response != nil else {
                completion(-500, "", nil)
                return
            }
            guard let statusCode = response.response?.statusCode else {
                completion(-500, "", nil)
                return
            }
            if let JSON = response.response?.allHeaderFields {
                guard var etag = JSON["Etag"] as? String else {
                    completion(statusCode, "", nil)
                    return
                }
                //joshprint("[getAvatar - \(userID)] before", etag)
                etag = etag.removeSpecialChars()
                //joshprint("[getAvatar - \(userID)] after ", etag)
                if statusCode / 100 == 3 {
                    completion(304, etag, coverPhotoInRealm)
                    //joshprint("[getAvatar - \(userID)] 304")
                    return
                }
                if statusCode == 404 {
                    completion(404, "", nil)
                }
                //joshprint("[getAvatar - \(userID)] check statusCode", statusCode)
                if let realmUser = realm.objects(UserImage.self).filter("user_id == %@", "\(userID)").first {
                    try! realm.write {
                        realmUser.coverPhotoEtag = etag
                        realmUser.userCoverPhoto = response.data as NSData?
                        completion(statusCode, etag, response.data)
                    }
                } else {
                    let realmUser = UserImage()
                    realmUser.user_id = "\(userID)"
                    realmUser.coverPhotoEtag = etag
                    realmUser.userCoverPhoto = response.data as NSData?
                    try! realm.write {
                        realm.add(realmUser)
                        completion(statusCode, etag, response.data)
                    }
                }
            } else {
                completion(statusCode, "", nil)
            }
    }
}

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
            if response.response != nil {
                guard let statusCode = response.response?.statusCode else {
                    completion(-500, "", nil)
                    return
                }
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
                completion(-500, "", nil)
            }
        }
}

func downloadImage(URL: String, completion: @escaping (Data?) -> Void) {
    
    alamoFireManager.request(URL).responseJSON { response in
        if response.response != nil {
            guard (response.response?.statusCode) != nil else {
                completion(nil)
                return
            }
            completion(response.data)
        } else {
            completion(nil)
        }
    }
}

func postFileToURL(_ className: String, parameter: [String: Any]?, authentication: [String: String]?, completion: @escaping (Int, Any?) -> Void) {
    let URL = Key.shared.baseURL + "/" + className
    
    var headers = [
        "User-Agent": Key.shared.headerUserAgent,
        "Fae-Client-Version": Key.shared.headerClientVersion,
        "Accept": Key.shared.headerAccept,
    ]
    
    if authentication != nil {
        for (key, value) in authentication! {
            headers[key] = value
        }
    }
    
    if parameter != nil {
        let imageData = parameter!["file"] as! Data
        let mediaType = parameter!["type"] as! String
        alamoFireManager.upload(
            multipartFormData: { multipartFormData in
                multipartFormData.append(imageData, withName: "file", fileName: "momentImage.jpg", mimeType: "image/jpeg")
                multipartFormData.append((mediaType.data(using: .utf8))!, withName: "type")
            },
            usingThreshold: 100,
            to: URL,
            method: .post,
            headers: headers,
            encodingCompletion: { encodingResult in
                switch encodingResult {
                case .success(let upload, _, _):
                    upload.responseJSON { response in
                        //print(response.response.debugDescription)
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
                    upload.uploadProgress { progress in
                        print("[upload progress ", progress.fractionCompleted, "]")
                    }
                case .failure(let encodingError):
                    completion(-400, "failure")
                    print(encodingError)
                }
    }) }
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

func showTimeOutAlert() {
    guard let current = UIApplication.shared.keyWindow?.visibleViewController else { return }
    showAlert(title: "Time out!", message: "Please try again!", viewCtrler: current)
}

// utf-8 encode
func utf8Encode(_ inputString: String) -> String {
    // MARK: REN tempory change it here, test if anything's wrong
    let encodedString = inputString.addingPercentEncoding(withAllowedCharacters: .urlHostAllowed)
    //   let encodedString = inputString.stringByAddingPercentEscapesUsingEncoding(NSUTF8StringEncoding)
    return encodedString!
}

// utf-8 decode
func utf8Decode(_ inputString: String) -> String {
    // MARK: REN tempory change it here, test if anything's wrong
    let decodeString = inputString.removingPercentEncoding!
    // let decodeString = inputString.stringByReplacingPercentEscapesUsingEncoding(NSUTF8StringEncoding)!
    return decodeString
}

func networkErrorHandling(error: Error, method: String, subUrl: String) {
    let urlWithSpaces = " " + subUrl + " "
    if let error = error as? AFError {
        switch error {
        case .invalidURL(let url):
            print(method + urlWithSpaces + "Invalid URL: \(url) - \(error.localizedDescription)")
        case .parameterEncodingFailed(let reason):
            print(method + urlWithSpaces + "Parameter encoding failed: \(error.localizedDescription)")
            print(method + urlWithSpaces + "Failure Reason: \(reason)")
        case .multipartEncodingFailed(let reason):
            print(method + urlWithSpaces + "Multipart encoding failed: \(error.localizedDescription)")
            print(method + urlWithSpaces + "Failure Reason: \(reason)")
        case .responseValidationFailed(let reason):
            print(method + urlWithSpaces + "Response validation failed: \(error.localizedDescription)")
            print(method + urlWithSpaces + "Failure Reason: \(reason)")
            
            switch reason {
            case .dataFileNil, .dataFileReadFailed:
                print(method + urlWithSpaces + "Downloaded file could not be read")
            case .missingContentType(let acceptableContentTypes):
                print(method + urlWithSpaces + "Content Type Missing: \(acceptableContentTypes)")
            case .unacceptableContentType(let acceptableContentTypes, let responseContentType):
                print(method + urlWithSpaces + "Response content type: \(responseContentType) was unacceptable: \(acceptableContentTypes)")
            case .unacceptableStatusCode(let code):
                print(method + urlWithSpaces + "Response status code was unacceptable: \(code)")
            }
        case .responseSerializationFailed(let reason):
            print(method + urlWithSpaces + "Response serialization failed: \(error.localizedDescription)")
            print(method + urlWithSpaces + "Failure Reason: \(reason)")
        }
        
        print(method + urlWithSpaces + "Underlying error: \(error.underlyingError)")
    } else if let error = error as? URLError {
        print(method + urlWithSpaces + "URLError occurred: \(error)")
    } else {
        print(method + urlWithSpaces + "Unknown error: \(error)")
    }
}
