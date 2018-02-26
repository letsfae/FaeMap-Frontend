//
//  FaePhotoLibrary.swift
//  faeBeta
//
//  Created by Jichao on 2018/2/2.
//  Copyright © 2018 fae. All rights reserved.
//

import Foundation
import Photos

protocol FaePhotoLibraryDelegate: class {
    func loadCameraRollCollection(collection: FaePHAssetCollection)
    func loadCompleteAllCollection(collections: [FaePHAssetCollection])
    func changeCollection(collection: FaePHAssetCollection)
}

class FaePhotoLibrary {
    
    weak var delegate: FaePhotoLibraryDelegate? = nil
    
    lazy var imageManager: PHCachingImageManager = {
        return PHCachingImageManager()
    }()
    
    @discardableResult
    func imageAsset(asset: PHAsset, size: CGSize = CGSize(width: 160, height: 160), options: PHImageRequestOptions? = nil, completion: @escaping (UIImage, Bool) -> Void) -> PHImageRequestID {
        var options = options
        if options == nil {
            options = PHImageRequestOptions()
            options?.isSynchronous = false
            options?.deliveryMode = .opportunistic
            options?.isNetworkAccessAllowed = true
        }
        let scale = min(UIScreen.main.scale, 2)
        let targetSize = CGSize(width: size.width * scale, height: size.height * scale)
        let requestId = imageManager.requestImage(for: asset, targetSize: targetSize, contentMode: .aspectFill, options: options) { (image, info) in
            let completeHandler = (info?["PHImageResultIsDegradedKey"] as? Bool) == false
            if let image = image {
                completion(image, completeHandler)
            }
        }
        return requestId
    }
    
    func cancelPHImageRequest(requestId: PHImageRequestID) {
        imageManager.cancelImageRequest(requestId)
    }
}

// MARK: - load collection
extension FaePhotoLibrary {
    func getOption() -> PHFetchOptions {
        let options = PHFetchOptions()
        //let sortOrder = [NSSortDescriptor(key: "creationDate", ascending: false)]
        //let sortOrder = [NSSortDescriptor(key: "modificationDate", ascending: false)]
        //options.sortDescriptors = sortOrder
        return options
    }
    
    func fetchResult(collection: FaePHAssetCollection?) -> PHFetchResult<PHAsset>? {
        guard let phAssetCollection = collection?.phAssetCollection else { return nil}
        return PHAsset.fetchAssets(in: phAssetCollection, options: getOption())
    }
    
    func fetchCollection(with configure: FaePhotoPickerConfigure) {
        let options = getOption()
        let boolAllowedVideo = configure.boolAllowdVideo
        let boolFullPicker = configure.boolFullPicker
        
        func getAlbum(subType: PHAssetCollectionSubtype, result: inout [FaePHAssetCollection]) {
            let fetchCollection = PHAssetCollection.fetchAssetCollections(with: .album, subtype: subType, options: nil)
            var collections = [PHAssetCollection]()
            fetchCollection.enumerateObjects { (collection, index, _) in
                if collection.assetCollectionSubtype != .albumCloudShared {
                    collections.append(collection)
                }
            }
            for collection in collections {
                if !result.contains(where: { $0.localIdentifier == collection.localIdentifier }) {
                    var faeCollection = FaePHAssetCollection(collection: collection)
                    faeCollection.fetchResult = PHAsset.fetchAssets(in: collection, options: options)
                    if faeCollection.count > 0 {
                        result.append(faeCollection)
                    }
                }
            }
        }
        
        @discardableResult
        func getSmartAlbum(subType: PHAssetCollectionSubtype, result: inout [FaePHAssetCollection]) -> FaePHAssetCollection? {
            let fetchCollection = PHAssetCollection.fetchAssetCollections(with: .smartAlbum, subtype: subType, options: nil)
            if let collection = fetchCollection.firstObject, !result.contains(where: { $0.localIdentifier == collection.localIdentifier }) {
                var faeCollection = FaePHAssetCollection(collection: collection)
                faeCollection.fetchResult = PHAsset.fetchAssets(in: collection, options: options)
                if faeCollection.count > 0 {
                    result.append(faeCollection)
                    return faeCollection
                }
            }
            return nil
        }
        
        if !boolAllowedVideo {
            options.predicate = NSPredicate(format: "mediaType = %i", PHAssetMediaType.image.rawValue)
        }
        
        DispatchQueue.global(qos: .userInteractive).sync { [weak self] in
            var faeCollections = [FaePHAssetCollection]()
            if !(boolFullPicker && boolAllowedVideo) {
                let cemaraRllCollection = getSmartAlbum(subType: .smartAlbumUserLibrary, result: &faeCollections)
                if let camera = cemaraRllCollection {
                    faeCollections[0] = camera
                    DispatchQueue.main.async {
                        self?.delegate?.loadCameraRollCollection(collection: camera)
                        self?.delegate?.changeCollection(collection: camera)
                    }
                }
            }
            if !boolFullPicker { return }
            
            let allAlbums = PHAssetCollection.fetchAssetCollections(with: .smartAlbum, subtype: .any, options: nil)
            allAlbums.enumerateObjects({ (albumCollection, index, _) in
                //print(albumCollection.localizedTitle)
                if !faeCollections.contains(where: { $0.localIdentifier == albumCollection.localIdentifier }) {
                    var faeCollection = FaePHAssetCollection(collection: albumCollection)
                    faeCollection.fetchResult = PHAsset.fetchAssets(in: albumCollection, options: options)
                    if faeCollection.count > 0 {
                        faeCollections.append(faeCollection)
                    }
                }
            })
            
            /*
             getSmartAlbum(subType: .smartAlbumSelfPortraits, result: &faeCollections)
             getSmartAlbum(subType: .smartAlbumPanoramas, result: &faeCollections)
             getSmartAlbum(subType: .smartAlbumFavorites, result: &faeCollections)
             getSmartAlbum(subType: .smartAlbumVideos, result: &faeCollections)*/
            getAlbum(subType: .any, result: &faeCollections)
            let albumsResult = PHCollectionList.fetchTopLevelUserCollections(with: nil)
            albumsResult.enumerateObjects({ (collection, index, stop) in
                guard let collection = collection as? PHAssetCollection else { return }
                var faeCollection = FaePHAssetCollection(collection: collection)
                faeCollection.fetchResult = PHAsset.fetchAssets(in: collection, options: options)
                if faeCollection.count > 0, !faeCollections.contains(where: { $0.localIdentifier == collection.localIdentifier }) {
                    faeCollections.append(faeCollection)
                }
            })
            
            DispatchQueue.main.async {
                self?.delegate?.loadCompleteAllCollection(collections: faeCollections)
            }
        }
        
    }
}


