//
//  FaeImage.swift
//  faeBeta
//
//  Created by blesssecret on 6/13/16.
//  Copyright © 2016 fae. All rights reserved.
//

import UIKit
import Alamofire

typealias ImageView = UIImageView

public typealias IndicatorView = UIActivityIndicatorView

func compressImage(_ image: UIImage, max_image_bytes: Int = 1024) -> Data {
    //    let max_image_bytes = 1024    // 0.1 MB for the image
    let dates = UIImageJPEGRepresentation(image, 1)
    let formatted_datas = Int((dates?.count)!) // 4752033
    if formatted_datas > max_image_bytes {
        let image_before_compression = image
        let compress_ratio = CGFloat(max_image_bytes / formatted_datas)

        let compressed_img = UIImageJPEGRepresentation(image_before_compression, compress_ratio)

        return compressed_img!
    } else {
        return dates!
    }
}
class FaeImage: NSObject {

    static let shared = FaeImage()
    
    var image: UIImage!
    var type: String!
    
    func downloadImage(url: String, _ completion: @escaping (UIImage?) -> Void) {
        Alamofire.download(url).responseData { response in
            if let data = response.result.value {
                let image = UIImage(data: data)
                completion(image)
            }
        }
    }
    
    func faeUploadFile(_ completion: @escaping (Int, Any?) -> Void) {
        if image == nil {
            completion(-400, "Error: Need to save image first" as AnyObject?)
        } else if type == nil {
            completion(-400, "Error: Need to specify file type first" as AnyObject?)
        } else {
            let file = compressImage(image)
            let seconds = 1.0
            let delay = seconds * Double(NSEC_PER_SEC) // nanoseconds per seconds
            let dispatchTime = DispatchTime.now() + Double(Int64(delay)) / Double(NSEC_PER_SEC)

            DispatchQueue.main.asyncAfter(deadline: dispatchTime, execute: {
                postFileToURL("files", parameter: ["file": file as AnyObject, "type": self.type as AnyObject], authentication: Key.shared.headerAuthentication(), completion: { (code: Int, message: Any?) in
                    completion(code, message)
                })
            })
        }
    }

    func faeUploadProfilePic(_ completion: @escaping (Int, Any?) -> Void) {
        if image == nil {
            completion(-400, "you need to save image first" as AnyObject?)
        } else {
            let file = compressImage(image)
            postImage(.avatar, imageData: file, completion: { (status, message) in
                completion(status, message)
            })
        }
    }

    func faeUploadCoverPhoto(_ completion: @escaping (Int, Any?) -> Void) {
        if image == nil {
            completion(-400, "you need to save image first" as AnyObject?)
        } else {
            let file = compressImage(image)
            postImage(.cover, imageData: file, completion: { (status, message) in
                completion(status, message)
            })
        }
    }
}
