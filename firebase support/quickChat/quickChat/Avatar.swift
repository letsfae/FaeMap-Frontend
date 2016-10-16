//
//  Avatar.swift
//  quickChat
//
//  Created by User on 6/8/16.
//  Copyright © 2016 User. All rights reserved.
//

import Foundation

func uploadAvatar(image : UIImage, result : (imageLink : String?) -> Void) {
    
    let imageData = UIImageJPEGRepresentation(image, 1.0)
    
    let dateString = dateFormatter().stringFromDate(NSDate())
    
    let fileName = "Img/" + dateString + ".jpeg"
    
    backendless.fileService.upload(fileName, content: imageData, response: { (file) in
        //success
        result(imageLink: file.fileURL)
        
    }) { (fault : Fault!) in
        print("error uploading avatar image : \(fault)")
    }
}

func getImageFromURL(url: String, result : (image : UIImage?) -> Void) {
    
    let URL = NSURL(string: url)
    
    let downloadQue = dispatch_queue_create("imageDownloadQue", nil)
    
    dispatch_async(downloadQue) { 
        let data = NSData(contentsOfURL: URL!)
        
        let image : UIImage!
        
        if data != nil {
            image = UIImage(data:data!)
            
            dispatch_async(dispatch_get_main_queue(), { 
                result(image : image)
            })
            
        }
    }
}
