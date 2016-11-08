//
//  PhotoPicker.swift
//  quickChat
//
//  Created by User on 7/25/16.
//  Copyright © 2016 User. All rights reserved.
//

import Foundation
import Photos
// this class uses Photo framework that Apple provide to load all media item in user album
// the result is grouped by smart album feature in iOS.
// you can check the groups by switching album in choose photo screen
class PhotoPicker {
    
    class var shared:PhotoPicker {
        struct Singleton {
            static let instance = PhotoPicker()
        }
        return Singleton.instance
    }
    
    var selectedAlbum = [SmartAlbum]()
    var currentAlbum : SmartAlbum! = nil
    var cameraRoll : SmartAlbum! = nil
    var currentAlbumIndex : Int = 0
    
    var assetIndexDict = [PHAsset : Int]()
    var indexAssetDict = [Int : PHAsset]()
    var indexImageDict = [Int: UIImage]()
    
    var assetDurationDict = [PHAsset : Int]()
    
    var videoAsset: AVAsset? = nil
    var videoImage: UIImage? = nil
    
    private init() {
        getSmartAlbum()
    }
    
    func getSmartAlbum() {
        selectedAlbum.removeAll()
        let smartAlbums = PHAssetCollection.fetchAssetCollectionsWithType(.SmartAlbum, subtype: .AlbumRegular, options: nil)
        let allPhotosOptions = PHFetchOptions()
        allPhotosOptions.sortDescriptors = [NSSortDescriptor(key: "creationDate", ascending: false)]
        smartAlbums.enumerateObjectsUsingBlock( {
            if let assetCollection = $0.0 as? PHAssetCollection {
                let assetsFetchResult = PHAsset.fetchAssetsInAssetCollection(assetCollection, options: allPhotosOptions)
                let numberOfAssets = assetsFetchResult.count
                if numberOfAssets != 0 {
                    self.selectedAlbum.append(SmartAlbum(albumName: assetCollection.localizedTitle!, albumCount: numberOfAssets, albumContent: assetsFetchResult))
                    if assetCollection.localizedTitle! == "Camera Roll" || assetCollection.localizedTitle! == "All Photos" {
                        self.cameraRoll = SmartAlbum(albumName: assetCollection.localizedTitle!, albumCount: numberOfAssets, albumContent: assetsFetchResult)
                        self.currentAlbum = self.cameraRoll
                    }
                }
            }
        })
        calculateVideoDuration()

    }
    
    private func calculateVideoDuration(){
        for i in 0 ..< self.cameraRoll.albumCount {
            let asset = self.cameraRoll.albumContent[i] as! PHAsset
            if asset.mediaType == .Video && assetDurationDict[asset] == nil {
            let lowQRequestOption = PHVideoRequestOptions()
            lowQRequestOption.deliveryMode = .FastFormat //high pixel
                PHCachingImageManager.defaultManager().requestAVAssetForVideo(asset, options: lowQRequestOption) { (assetTwo, audioMix, info) in
                    let duration = Int(Int(assetTwo!.duration.value) / Int(assetTwo!.duration.timescale))
                    self.assetDurationDict[asset] =  duration
                }
            }
        }
    }
}
