//
//  QuickPhotoPickerCollectionViewCell.swift
//  faeBeta
//
//  Created by Jichao Zhong on 8/10/17.
//  Copyright © 2017 fae. All rights reserved.
//

import UIKit
import Photos
// this cell is for collection view in CustomCollectionViewController, it has two image view, one shows image,
// the other shows chosen frame.

class QuickPhotoPickerCollectionViewCell: UICollectionViewCell {
    
    //MARK: - properties
    fileprivate(set) var photoSelected = false
    var imgPhoto: UIImageView!
    var imgChosenIndicator: UIImageView!
    var uiviewVideoIndicator: UIView!
    var lblVideoDuration: UILabel!
    var imgCameraIcon: UIImageView!
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        imgPhoto = UIImageView(frame: CGRect(x: 0, y: 0, width: frame.width, height: frame.height))
        imgPhoto.contentMode = .scaleAspectFill
        imgPhoto.clipsToBounds = true
        addSubview(imgPhoto)
        
        imgChosenIndicator = UIImageView(frame: CGRect(x: 183, y: 7, width: 31, height: 31))
        addSubview(imgChosenIndicator)
        
        uiviewVideoIndicator = UIView(frame: CGRect(x: 10, y: 10, width: 82, height: 26))
        uiviewVideoIndicator.backgroundColor = UIColor._585151()
        uiviewVideoIndicator.layer.cornerRadius = 15
        addSubview(uiviewVideoIndicator)
        
        imgCameraIcon = UIImageView(frame: CGRect(x: 12, y: 7, width: 18, height: 12))
        imgCameraIcon.image = UIImage(named: "cameraIconFilled_white")
        uiviewVideoIndicator.addSubview(imgCameraIcon)
        
        lblVideoDuration = UILabel(frame: CGRect(x: 38, y: 5, width: 40, height: 18))
        lblVideoDuration.text = ""
        lblVideoDuration.textAlignment = .left
        lblVideoDuration.textColor = .white
        lblVideoDuration.font = UIFont(name: "AvenirNext-DemiBold", size: 13)
        uiviewVideoIndicator.addSubview(lblVideoDuration)
        uiviewVideoIndicator.isHidden = true
        
        deselectCell()
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func prepareForReuse() {
        imgPhoto.image = nil
        deselectCell()
        uiviewVideoIndicator.isHidden = true
        imgCameraIcon.isHidden = true
    }
    
    //MARK: - select & deselect cell
    /// Select this cell
    ///
    /// - Parameter indicatorNum: the number that appear's on the top right minus 1 (0 - 9)
    func selectCell(_ indicatorNum: Int) {
        assert(indicatorNum >= 0 && indicatorNum <= 9, "Invalid indicator number! The number should be between 0 - 9")
        let imageName = "chosenIndicatorIcon_selected\(indicatorNum+1)"
        imgChosenIndicator.image = UIImage(named:imageName)
        self.photoSelected = true
    }
    
    /// hide the indicator number and
    func deselectCell() {
        imgChosenIndicator.image = UIImage(named:"chosenIndicatorIcon_unselected")
        photoSelected = false
    }
    
    //MARK: - image related
    fileprivate func setImage(_ thumbnailImage : UIImage) {
        imgPhoto.image = thumbnailImage
    }
    
    func setVideoDurationLabel(withDuration duration: Int)
    {
        let secondString = (duration % 60) < 9 ? "0\(duration % 60)" : "\(duration % 60)"
        let minString = (duration / 60) < 9 ? "0\(duration / 60)" : "\(duration / 60)"
        uiviewVideoIndicator.isHidden = false
        imgCameraIcon.isHidden = false
        lblVideoDuration.text =  "\(minString):\(secondString)"
        self.setNeedsUpdateConstraints()
        
        self.layoutSubviews()
    }
    
    func setGifLabel() {
        uiviewVideoIndicator.isHidden = false
        imgCameraIcon.isHidden = true
        lblVideoDuration.text = "GIF"
        
        uiviewVideoIndicator.frame = CGRect(x: 10, y: 10, width: 48, height: 26 )
        lblVideoDuration.frame = CGRect(x: 13, y: 5, width: 22, height: 18)
        self.layoutSubviews()
        
    }
    
    // given a PHAsset, request the image and populate the cell with the image
    func loadImage(_ asset: PHAsset,requestOption option: PHImageRequestOptions){
        PHCachingImageManager.default().requestImage(for: asset, targetSize: CGSize(width: self.frame.width - 1 / 3, height: self.frame.width - 1 / 3), contentMode: .aspectFill, options: option) { (result, info) in
            self.setImage(result!)
        }
    }
    
}

