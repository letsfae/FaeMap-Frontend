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



    private(set) var photoSelected = false
    
    @IBOutlet weak private var photoImageView: UIImageView!
    
    @IBOutlet weak private var chosenIndicatorImageView: UIImageView!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
        self.photoImageView.contentMode = .ScaleAspectFill
        self.photoImageView.layer.zPosition = 1
        self.chosenIndicatorImageView.layer.zPosition = 2

        deselectCell()
    }
    
    func selectCell(indicatorNum: Int)
    {
        assert(indicatorNum >= 0 && indicatorNum <= 9, "Invalid indicator number! The number should be between 0 - 9")
        let imageName = "chosenIndicatorIcon_selected\(indicatorNum+1)"
        self.chosenIndicatorImageView.image = UIImage(named:imageName)
        self.photoSelected = true
    }
    
    func deselectCell()
    {
        self.chosenIndicatorImageView.image = UIImage(named:"chosenIndicatorIcon_unselected")
        self.photoSelected = false
    }
    
    private func setImage(thumbnailImage : UIImage) {
        self.photoImageView.image = thumbnailImage
    }
    func loadImage(asset: PHAsset,requestOption option: PHImageRequestOptions){

        PHCachingImageManager.defaultManager().requestImageForAsset(asset, targetSize: CGSizeMake(self.frame.width - 1 / 3, self.frame.width - 1 / 3), contentMode: .AspectFill, options: option) { (result, info) in
            self.setImage(result!)
        }
    }

    override func prepareForReuse() {
        photoImageView.image = nil
        deselectCell()
    }
}
