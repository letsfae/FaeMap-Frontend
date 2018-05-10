//
//  FaePHAssetCollection.swift
//  faeBeta
//
//  Created by Jichao on 2018/2/2.
//  Copyright © 2018 fae. All rights reserved.
//

import Foundation
import Photos
import PhotosUI

// MARK: - FaePHAsset to hold PHAsset
struct FaePHAsset {
    enum CloudDownloadState {
        case ready, progress, complete, failed
    }
    
    enum AssetType {
        case photo, video, livePhoto
    }
    
    enum ImageFileFormat: String {
        case png, jpg, gif, heic
    }
    
    var state: CloudDownloadState = .ready
    var phAsset: PHAsset? = nil
    var selectedOrder: Int = 0
    var assetType: AssetType {
        get {
            guard let phAsset = self.phAsset else { return .photo }
            if phAsset.mediaSubtypes.contains(.photoLive) {
                return .livePhoto
            } else if phAsset.mediaType == .video {
                return .video
            } else {
                return .photo
            }
        }
    }
    
    var originalFileName: String? {
        get {
            guard let phAsset = self.phAsset, let fileName = phAsset.value(forKey: "filename") as? String else { return nil }
            return fileName
        }
    }
    
    var localURL: URL? = nil
    
    var thumbnailImage: UIImage? {
        get {
            guard let phAsset = self.phAsset else { return nil }
            let options = PHImageRequestOptions()
            options.isSynchronous = false
            options.deliveryMode = .opportunistic
            options.isNetworkAccessAllowed = true
            let targetSize = CGSize(width: 244, height: 94)
            var img: UIImage? = nil
            _ = PHImageManager().requestImage(for: phAsset, targetSize: targetSize, contentMode: .aspectFill, options: options) { (image, info) in
                if let image = image {
                    img = image
                }
            }
            return img
        }
    }
    
    var fullResolutionImageData: Data? {
        get {
            guard let phAsset = self.phAsset else { return nil }
            let options = PHImageRequestOptions()
            options.isSynchronous = true
            options.resizeMode = .none
            options.isNetworkAccessAllowed = false
            options.version = .current
            var imgData: Data? = nil
            _ = PHCachingImageManager().requestImageData(for: phAsset, options: options, resultHandler: { (imageData, dataUTI, orientation, info) in
                if let data = imageData {
                    imgData = data
                }
            })
            return imgData
        }
    }
    
    func fileFormat() -> ImageFileFormat {
        var format: ImageFileFormat = .png
        if let fileName = self.originalFileName, let pathExtension = URL(string: fileName)?.pathExtension.lowercased() {
            format = ImageFileFormat(rawValue: pathExtension) ?? .png
        }
        return format
    }
    
    func cloudImageDownload(progress: @escaping (Double) -> Void, completion: @escaping (Data?) -> Void) -> PHImageRequestID? {
        guard let phAsset = self.phAsset else { return nil }
        let options = PHImageRequestOptions()
        options.isSynchronous = false
        options.isNetworkAccessAllowed = true
        options.deliveryMode = .highQualityFormat
        options.version = .original
        options.resizeMode = .none
        options.progressHandler = { (progressValue, error, stop, info) in
            progress(progressValue)
        }
        
        var requestId: PHImageRequestID?
        if self.fileFormat() == .gif {
            requestId = PHCachingImageManager().requestImageData(for: phAsset, options: options) { (imageData, dataUTI, orientation, info) in
                if let data = imageData,let _ = info {
                    completion(data)
                }else{
                    completion(nil)//error
                }
            }
        } else {
            requestId = PHCachingImageManager().requestImage(for: phAsset, targetSize: CGSize(width: phAsset.pixelWidth, height: phAsset.pixelHeight), contentMode: .aspectFill, options: options) { (image, info) in
                if let image = image, let _ = info {
                    var imageData = UIImageJPEGRepresentation(image, 1)
                    let factor = min(5000000.0 / CGFloat(imageData!.count), 1.0)
                    imageData = UIImageJPEGRepresentation(image, factor)
                    completion(imageData)
                } else {
                    completion(nil) // error
                }
            }
        }
        return requestId
    }
    
    func tempCopyMediaFile(progress: ((Double) -> Void)? = nil, complete: @escaping ((URL) -> Void)) -> PHImageRequestID? {
        guard let phAsset = self.phAsset else { return nil }
        guard let resource = (PHAssetResource.assetResources(for: phAsset).filter{ $0.type == .video }).first else { return nil }
        let fileName = resource.originalFilename
        var writeURL: URL? = nil
        if #available(iOS 10.0, *) {
            writeURL = FileManager.default.temporaryDirectory.appendingPathComponent("\(fileName)")
        } else {
            writeURL = URL(fileURLWithPath: NSTemporaryDirectory(), isDirectory: true).appendingPathComponent("\(fileName)")
        }
        guard let localURL = writeURL else { return nil }
        let options = PHVideoRequestOptions()
        options.isNetworkAccessAllowed = true
        options.progressHandler = { (progressValue, error, stop, info) in
            DispatchQueue.main.async {
                progress?(progressValue)
            }
        }
        return PHImageManager.default().requestExportSession(forVideo: phAsset, options: options, exportPreset: AVAssetExportPresetMediumQuality, resultHandler: { (session, info) in
            session?.outputURL = localURL
            session?.outputFileType = .mov
            session?.exportAsynchronously(completionHandler: {
                DispatchQueue.main.async {
                    complete(localURL)
                }
            })
        })
    }
    
    func videoSize(options: PHVideoRequestOptions? = nil, completion: @escaping ((Int) -> Void)) {
        guard let phAsset = self.phAsset, self.assetType == .video else { completion(-1); return }
        let resource = PHAssetResource.assetResources(for: phAsset).filter { $0.type == .video }.first
        if let fileSize = resource?.value(forKey: "fileSize") as? Int {
            completion(fileSize)
        } else {
            PHImageManager.default().requestAVAsset(forVideo: phAsset, options: options) { (avasset, audioMix, info) in
                
                func fileSize(_ url: URL?) -> Int? {
                    do {
                        guard let fileSize = try url?.resourceValues(forKeys: [.fileSizeKey]).fileSize else { return nil }
                        return fileSize
                    } catch {
                        return nil
                    }
                }
                
                var url: URL? = nil
                if let urlAsset = avasset as? AVURLAsset {
                    url = urlAsset.url
                } else if let sandboxKeys = info?["PHImageFileSandboxExtensionTokenKey"] as? String, let path = sandboxKeys.components(separatedBy: ";").last {
                    url = URL(fileURLWithPath: path)
                }
                let size = fileSize(url) ?? -1
                DispatchQueue.main.async {
                    completion(size)
                }
            }
        }
    }
    
    init(asset: PHAsset?) {
        self.phAsset = asset
    }
    
}

extension FaePHAsset: Equatable {
    static func ==(lhs: FaePHAsset, rhs: FaePHAsset) -> Bool {
        guard let lPHAsset = lhs.phAsset, let rPHAsset = rhs.phAsset else { return false }
        return lPHAsset.localIdentifier == rPHAsset.localIdentifier
    }
}

// MARK: - FaePHAssetCollection to hold PHAssetCollection
struct FaePHAssetCollection {
    var phAssetCollection: PHAssetCollection? = nil
    var fetchResult: PHFetchResult<PHAsset>? = nil
    var thumbnail: UIImage? = nil
    var recentPostion: CGPoint = .zero
    var title: String
    var localIdentifier: String
    var count: Int {
        get {
            guard let count = fetchResult?.count, count > 0 else { return 0 }
            return count
        }
    }
    
    init(collection: PHAssetCollection) {
        phAssetCollection = collection
        title = collection.localizedTitle ?? ""
        localIdentifier = collection.localIdentifier
    }
    
    func getPHAsset(at index: Int) -> PHAsset? {
        guard let result = fetchResult, index < result.count else { return nil }
        let reversedIndex = count - index - 1
        return result.object(at: max(reversedIndex, 0))
    }
    
    func getFaePHAsset(at index: Int) -> FaePHAsset? {
        guard let result = fetchResult, index < result.count else { return nil }
        let reversedIndex = count - index - 1
        return FaePHAsset(asset: result.object(at: max(reversedIndex, 0)))
    }
    
    func getPHAssets(at range: CountableClosedRange<Int>) -> [PHAsset]? {
        let lowerReversed = count - range.upperBound - 1
        let upperReversed = count - range.lowerBound - 1
        return fetchResult?.objects(at: IndexSet(integersIn: max(lowerReversed, 0)...min(upperReversed, count)))
    }
    
    static func ==(lhs: FaePHAssetCollection, rhs: FaePHAssetCollection) -> Bool {
        return lhs.localIdentifier == rhs.localIdentifier
    }
}
