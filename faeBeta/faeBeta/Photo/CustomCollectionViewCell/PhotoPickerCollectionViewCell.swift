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

    //MARK: - properties
    private(set) var photoSelected = false
    
    @IBOutlet weak private var photoImageView: UIImageView!
    @IBOutlet weak private var chosenIndicatorImageView: UIImageView!
    
    @IBOutlet weak private var videoIndicatorView: UIView!
    @IBOutlet weak private var videoDurationLabelLength: NSLayoutConstraint!
    @IBOutlet weak private var videoDurationLabelDistanceToLeft: NSLayoutConstraint!
    
    //MARK: - life cycle
    override func awakeFromNib() {
        super.awakeFromNib()
        self.photoImageView.contentMode = .ScaleAspectFill
        deselectCell()
//        if videoIndicatorView != nil{
//            videoIndicatorView.layer.cornerRadius = CGRectGetHeight(videoIndicatorView.frame) / 2
//        }
    }
    
    override func prepareForReuse() {
        photoImageView.image = nil
        deselectCell()
    }
    
    //MARK: - select & deselect cell
    
    
    /// Select this cell
    ///
    /// - Parameter indicatorNum: the number that appear's on the top right minus 1 (0 - 9)
    func selectCell(indicatorNum: Int)
    {
        assert(indicatorNum >= 0 && indicatorNum <= 9, "Invalid indicator number! The number should be between 0 - 9")
        let imageName = "chosenIndicatorIcon_selected\(indicatorNum+1)"
        self.chosenIndicatorImageView.image = UIImage(named:imageName)
        self.photoSelected = true
    }
    
    /// hide the indicator number and
    func deselectCell()
    {
        self.chosenIndicatorImageView.image = UIImage(named:"chosenIndicatorIcon_unselected")
        self.photoSelected = false
    }
    
    //MARK: - image related
    private func setImage(thumbnailImage : UIImage) {
        self.photoImageView.image = thumbnailImage
    }
    func loadImage(asset: PHAsset,requestOption option: PHImageRequestOptions){

        PHCachingImageManager.defaultManager().requestImageForAsset(asset, targetSize: CGSizeMake(self.frame.width - 1 / 3, self.frame.width - 1 / 3), contentMode: .AspectFill, options: option) { (result, info) in
            self.setImage(result!)
        }
    }

}
