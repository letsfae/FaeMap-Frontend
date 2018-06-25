//
//  FaeSearch.swift
//  faeBeta
//
//  Created by Yue Shen on 10/25/17.
//  Copyright © 2017 fae. All rights reserved.
//

import UIKit
import SwiftyJSON
import Alamofire

class FaeSearch {
    
    static let shared = FaeSearch()
    
    var keyValue = [String: Any]()
    func whereKey(_ key: String, value: Any) {
        keyValue[key] = value
    }
    
    func clearKeyValue() {
        keyValue = [String: Any]()
    }
    
    func search(_ completion: @escaping (Int, Any?) -> Void) {
        searchToURL(.search, parameter: keyValue) { (status: Int, message: Any?) in
            self.clearKeyValue()
            completion(status, message)
        }
    }
    
    var searchContent = [[String : Any]]()
    func searchBulk(_ completion: @escaping (Int, Any?) -> Void) {
        searchBulkToURL(.bulkSearch, parameter: searchContent) { (status: Int, message: Any?) in
            self.searchContent = [[String : Any]]()
            completion(status, message)
        }
    }
    
    func searchBulkToURL(_ method: PostMethod, parameter: Array<Any>, completion: @escaping (Int, Any?) -> Void) {
        let fullURL = Key.shared.baseURL + "/" + method.rawValue
        let headers = Key.shared.header(auth: true, type: .json)
        
        // Use structs for requests
        alamoFireManager.request(fullURL, method: .post, parameters: parameter.asParameters(), encoding: ArrayEncoding(), headers: headers)
            .responseJSON { response in
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
        }
    }
}

/// Convert the parameters into a json array, and it is added as the request body.
/// The array must be sent as parameters using its `asParameters` method.
struct ArrayEncoding: ParameterEncoding {
    
    /// The options for writing the parameters as JSON data.
    public let options: JSONSerialization.WritingOptions
    
    /// Creates a new instance of the encoding using the given options
    ///
    /// - parameter options: The options used to encode the json. Default is `[]`
    ///
    /// - returns: The new instance
    public init(options: JSONSerialization.WritingOptions = []) {
        self.options = options
    }
    
    public func encode(_ urlRequest: URLRequestConvertible, with parameters: Parameters?) throws -> URLRequest {
        var urlRequest = try urlRequest.asURLRequest()
        
        guard let parameters = parameters,
            let array = parameters[arrayParametersKey] else {
                return urlRequest
        }
        
        do {
            let data = try JSONSerialization.data(withJSONObject: array, options: options)
            
            if urlRequest.value(forHTTPHeaderField: "Content-Type") == nil {
                urlRequest.setValue("application/json", forHTTPHeaderField: "Content-Type")
            }
            
            urlRequest.httpBody = data
            
        } catch {
            throw AFError.parameterEncodingFailed(reason: .jsonEncodingFailed(error: error))
        }
        
        return urlRequest
    }
}

private let arrayParametersKey = "arrayParametersKey"

extension Array {
    func asParameters() -> Parameters {
        return [arrayParametersKey: self]
    }
}
