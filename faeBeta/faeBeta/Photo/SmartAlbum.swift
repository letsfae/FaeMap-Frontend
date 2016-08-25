//
//  File.swift
//  quickChat
//
//  Created by User on 7/17/16.
//  Copyright © 2016 User. All rights reserved.
//

import Foundation
import Photos
// class to store information of one album.
class SmartAlbum {
    var albumName : String!
    var albumCount : Int!
    var albumContent : PHFetchResult!
    init(albumName : String, albumCount: Int, albumContent : PHFetchResult) {
        self.albumName = albumName
        self.albumCount = albumCount
        self.albumContent = albumContent
    }
    
    func getNumberOfAssets() -> Int {
        return albumCount
    }
    
    func getAlbumName() -> String {
        return albumName
    }
    
    func getAlbumContent() -> PHFetchResult {
        return albumContent
    }
}