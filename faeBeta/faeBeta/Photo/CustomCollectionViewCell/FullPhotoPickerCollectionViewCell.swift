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

class FullPhotoPickerCollectionViewCell: UICollectionViewCell {

    //MARK: - properties
    fileprivate(set) var photoSelected = false
    
//    @IBOutlet weak fileprivate var photoImageView: UIImageView!
//    @IBOutlet weak fileprivate var chosenIndicatorImageView: UIImageView!
//    
//    @IBOutlet weak private var videoDurationLabel: UILabel!
//    @IBOutlet weak fileprivate var videoIndicatorView: UIView!
//    @IBOutlet weak private var cameraIconImageView: UIImageView!
//    @IBOutlet weak fileprivate var videoDurationLabelLength: NSLayoutConstraint!
//    @IBOutlet weak fileprivate var videoDurationLabelDistanceToLeft: NSLayoutConstraint!
    
    // Felix 
    var imgPhoto: UIImageView!
    var imgChosenIndicator: UIImageView!
    var uiviewVideoIndicator: UIView!
    var lblVideoDuration: UILabel!
    var imgCameraIcon: UIImageView!
    // Felix - end
    
    
    //MARK: - life cycle
    /*override func awakeFromNib() {
        super.awakeFromNib()
        self.photoImageView.contentMode = .scaleAspectFill
        deselectCell()
        videoIndicatorView.alpha = 0
    }*/
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        imgPhoto = UIImageView(frame: CGRect(x: 0, y: 0, width: frame.width, height: frame.height))
        imgPhoto.contentMode = .scaleToFill
        addSubview(imgPhoto)
        
        imgChosenIndicator = UIImageView(frame: CGRect(x: 100, y: 5, w: 31, h: 31))
        addSubview(imgChosenIndicator)
        
        uiviewVideoIndicator = UIView(frame: CGRect(x: 0, y: 111, w: frame.width / screenWidthFactor, h: 25))
        uiviewVideoIndicator.backgroundColor = UIColor._585151()
        
        imgCameraIcon = UIImageView(frame: CGRect(x: 8, y: 6, w: 18, h: 12))
        imgCameraIcon.image = UIImage(named: "cameraIconFilled_white")
        uiviewVideoIndicator.addSubview(imgCameraIcon)
        
        lblVideoDuration = UILabel(frame: CGRect(x: 34, y: 2, w: 40, h: 21))
        lblVideoDuration.text = ""
        lblVideoDuration.textAlignment = .left
        lblVideoDuration.textColor = .white
        lblVideoDuration.font = UIFont(name: "AvenirNext-DemiBold", size: 13)
        uiviewVideoIndicator.addSubview(lblVideoDuration)
        
        addSubview(uiviewVideoIndicator)
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
    func selectCell(_ indicatorNum: Int)
    {
        assert(indicatorNum >= 0 && indicatorNum <= 9, "Invalid indicator number! The number should be between 0 - 9")
        let imageName = "chosenIndicatorIcon_selected\(indicatorNum+1)"
        imgChosenIndicator.image = UIImage(named:imageName)
        self.photoSelected = true
    }
    
    /// hide the indicator number and
    func deselectCell()
    {
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
//        if(minString / 10 == 0){
//            videoDurationLabelLength.constant = 35
//        }else{
//            videoDurationLabelLength.constant = 40
//        }
//        if let constraint = self.videoDurationLabelDistanceToLeft{
//            constraint.constant = 38
//        }
        self.setNeedsUpdateConstraints()

        self.layoutSubviews()
    }
    
    func setGifLabel()
    {
        uiviewVideoIndicator.isHidden = false
        imgCameraIcon.isHidden = true
        lblVideoDuration.text = "GIF"
        
        //uiviewVideoIndicator.frame = CGRect(x: 10, y: 10, width: 48, height: 26 )
        lblVideoDuration.frame = CGRect(x: 12, y: 3.5, width: 22, height: 18)
        //uiviewVideoIndicator.addConstraintsWithFormat("H:|-8-[v0(22)]", options: [], views: lblVideoDuration)
//        if let constraint = self.videoDurationLabelDistanceToLeft{
//            constraint.constant = 8
//        }
        self.layoutSubviews()

    }
    
    // given a PHAsset, request the image and populate the cell with the image
    func loadImage(_ asset: PHAsset,requestOption option: PHImageRequestOptions){
        PHCachingImageManager.default().requestImage(for: asset, targetSize: CGSize(width: self.frame.width - 1 / 3, height: self.frame.width - 1 / 3), contentMode: .aspectFill, options: option) { (result, info) in
            self.setImage(result!)
        }
    }

}
