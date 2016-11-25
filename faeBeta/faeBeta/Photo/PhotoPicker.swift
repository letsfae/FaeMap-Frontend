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
    
    var selectedAlbum = [SmartAlbum]() // a set of albums from the phone
    var currentAlbum : SmartAlbum! = nil
    var cameraRoll : SmartAlbum! = nil // the all photos album
    
    var assetIndexDict = [PHAsset : Int]() // a dictionary storing the selected photo's PHAsset file and its index between 0-9 (max 10 pics)
    var indexAssetDict = [Int : PHAsset]() // a reverse dictionary of assetIndexDict representing the order of the photos
    var indexImageDict = [Int: UIImage]() // a dic storing all the UIImages of photo selected. This will not be updated if user's selecting video
    
    var assetDurationDict = [PHAsset : Int]()// a dic store the duration for every video
    var gifAssetDict = [PHAsset: Data]()
    
    var videoAsset: AVAsset? = nil // the selected video's AVAsset
    var videoImage: UIImage? = nil // the selected video's preview image
    
    fileprivate init() {
        getSmartAlbum()
    }
    
    func getSmartAlbum() {
        selectedAlbum.removeAll()
        let smartAlbums = PHAssetCollection.fetchAssetCollections(with: .smartAlbum, subtype: .albumRegular, options: nil)
        let allPhotosOptions = PHFetchOptions()
        allPhotosOptions.sortDescriptors = [NSSortDescriptor(key: "creationDate", ascending: false)]
        smartAlbums.enumerateObjects( {
            let assetCollection = $0.0
            let assetsFetchResult = PHAsset.fetchAssets(in: assetCollection, options: allPhotosOptions)
            let numberOfAssets = assetsFetchResult.count
            if numberOfAssets != 0 {
                self.selectedAlbum.append(SmartAlbum(albumName: assetCollection.localizedTitle!, albumCount: numberOfAssets, albumContent: assetsFetchResult as! PHFetchResult<AnyObject>))
                if assetCollection.localizedTitle! == "Camera Roll" || assetCollection.localizedTitle! == "All Photos" {
                    self.cameraRoll = SmartAlbum(albumName: assetCollection.localizedTitle!, albumCount: numberOfAssets, albumContent: assetsFetchResult as! PHFetchResult<AnyObject>)
                    self.currentAlbum = self.cameraRoll
                }
            }
            
        })
        calculateVideoDuration()
        
    }
    
    fileprivate func calculateVideoDuration(){
        if(cameraRoll != nil){
            for i in 0 ..< self.cameraRoll.albumCount {
                let asset = self.cameraRoll.albumContent[i] as! PHAsset
                if asset.mediaType == .video && assetDurationDict[asset] == nil {
                    let lowQRequestOption = PHVideoRequestOptions()
                    lowQRequestOption.deliveryMode = .fastFormat //high pixel
                    PHCachingImageManager.default().requestAVAsset(forVideo: asset, options: lowQRequestOption) { (assetTwo, audioMix, info) in
                        if(assetTwo != nil){
                            let duration = Int(Int(assetTwo!.duration.value) / Int(assetTwo!.duration.timescale))
                            self.assetDurationDict[asset] =  duration
                        }
                    }
                }
            }
        }
    }
    
    
    /// clean up every selected photo
    func cleanup(){
        videoAsset = nil
        videoImage = nil
        indexAssetDict.removeAll()
        assetIndexDict.removeAll()
        indexImageDict.removeAll()
        gifAssetDict.removeAll()
    }
}
