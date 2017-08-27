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
    private(set) var albumName : String!
    private(set) var albumCount : Int!
    private(set) var albumContent : PHFetchResult<PHAsset>!
    
    init(albumName : String, albumCount: Int, albumContent : PHFetchResult<PHAsset>) {
        self.albumName = albumName
        self.albumCount = albumCount
        self.albumContent = albumContent
    }
}
