//
//  PhotoPickerCollectionViewCell.swift
//  quickChat
//
//  Created by User on 7/14/16.
//  Copyright © 2016 User. All rights reserved.
//

import UIKit
import Photos
// this cell is for collection view in CustomCollectionViewController, it has two image view, one shows image,
// the other shows chosen frame.

class PhotoPickerCollectionViewCell: UICollectionViewCell {

    @IBOutlet weak var photoImageView: UIImageView!
    
    @IBOutlet weak var chosenFrameImageView: UIImageView!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
        photoImageView.layer.zPosition = 1
        photoImageView.contentMode = .ScaleAspectFill
        chosenFrameImageView.layer.zPosition = 10
        chosenFrameImageView.hidden = true
    }
    
    func setImage(thumbnailImage : UIImage) {
        photoImageView.image = thumbnailImage
    }
    func loadImage(asset: PHAsset,requestOption option: PHImageRequestOptions){

        PHCachingImageManager.defaultManager().requestImageForAsset(asset, targetSize: CGSizeMake(self.frame.width - 1 / 3, self.frame.width - 1 / 3), contentMode: .AspectFill, options: option) { (result, info) in
            self.setImage(result!)
        }
    }

    override func prepareForReuse() {
        photoImageView.image = nil
        chosenFrameImageView.hidden = true
    }
}
