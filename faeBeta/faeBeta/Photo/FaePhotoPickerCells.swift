//
//  FaePhotoPickerCells.swift
//  faeBeta
//
//  Created by Jichao on 2018/2/2.
//  Copyright © 2018 fae. All rights reserved.
//

import UIKit

// MARK: - PhotoCollectionViewCell
class PhotoCollectionViewCell: UICollectionViewCell {
    
    static let identifier = "PhotoCollectionViewCell"
    
    var imgPhoto: UIImageView!
    var imgChosenIndicator: UIImageView!
    private var uiviewVideoIndicator: UIView!
    private var lblVideoDuration: UILabel!
    private var imgCameraIcon: UIImageView!
    
    var boolIsSelected: Bool = false {
        willSet(newValue) {
            if !newValue {
                imgChosenIndicator.image = UIImage(named:"chosenIndicatorIcon_unselected")
            }
        }
    }
    var intSelectedOrder: Int = 0 {
        willSet(newValue) {
            if newValue != 0 {
                imgChosenIndicator.image = UIImage(named:"chosenIndicatorIcon_selected\(newValue)")
            }
        }
    }
    
    private var duration: TimeInterval? {
        didSet {
            guard let duration = self.duration else { return }
            lblVideoDuration.text = timeFormatted(timeInterval: duration)
        }
    }
    
    var boolFullPicker: Bool = true {
        didSet {
            boolFullPicker ? setupForFullPicker() : setupForQuickPicker()
        }
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        imgPhoto = UIImageView(frame: CGRect(x: 0, y: 0, width: frame.width, height: frame.height))
        imgPhoto.contentMode = .scaleAspectFill
        imgPhoto.clipsToBounds = true
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
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
    
    override func prepareForReuse() {
        imgPhoto.image = nil
        uiviewVideoIndicator.isHidden = true
        imgCameraIcon.isHidden = true
        boolIsSelected = false
        intSelectedOrder = 0
    }
    
    func setupForQuickPicker() {
        imgChosenIndicator.frame = CGRect(x: 183, y: 7, width: 31, height: 31)
        uiviewVideoIndicator.frame = CGRect(x: 10, y: 10, width: 82, height: 26)
        uiviewVideoIndicator.layer.cornerRadius = 13
        imgCameraIcon.frame = CGRect(x: 12, y: 7, width: 18, height: 12)
        lblVideoDuration.frame = CGRect(x: 38, y: 5, width: 40, height: 18)
    }
    
    func setupForFullPicker() {
        imgChosenIndicator.frame = CGRect(x: 100, y: 5, w: 31, h: 31)
        uiviewVideoIndicator.frame = CGRect(x: 0, y: 111, w: frame.width / screenWidthFactor, h: 25)
        uiviewVideoIndicator.layer.cornerRadius = 0
        imgCameraIcon.frame = CGRect(x: 8, y: 6, w: 18, h: 12)
        lblVideoDuration.frame = CGRect(x: 34, y: 2, w: 40, h: 21)
    }
    
    func setupVideo(with duration: TimeInterval) {
        self.duration = duration
        uiviewVideoIndicator.isHidden = false
        imgCameraIcon.isHidden = false
    }
    
    func setupGifLabel() {
        uiviewVideoIndicator.isHidden = false
        imgCameraIcon.isHidden = true
        lblVideoDuration.text = "GIF"
        if boolFullPicker {
            lblVideoDuration.frame = CGRect(x: 12, y: 3.5, width: 22, height: 18)
        } else {
            uiviewVideoIndicator.frame = CGRect(x: 10, y: 10, width: 48, height: 26)
            lblVideoDuration.frame = CGRect(x: 13, y: 5, width: 22, height: 18)
        }
    }
    
    fileprivate func timeFormatted(timeInterval: TimeInterval) -> String {
        let seconds: Int = lround(timeInterval)
        var hour: Int = 0
        var minute: Int = Int(seconds/60)
        let second: Int = seconds % 60
        if minute > 59 {
            hour = minute / 60
            minute = minute % 60
            if !boolFullPicker {
                uiviewVideoIndicator.frame = CGRect(x: 10, y: 10, width: 94, height: 26)
            }
            return String(format: "%d:%02d:%02d", hour, minute, second)
        } else {
            if !boolFullPicker {
                uiviewVideoIndicator.frame = CGRect(x: 10, y: 10, width: 82, height: 26)
            }
            return String(format: "%02d:%02d", minute, second)
        }
    }
}

// MARK: - AlbumsTableViewCell
class AlbumsTableViewCell: UITableViewCell {
    
    static let identifier = "AlbumsTableCell"
    
    var imgTitle: UIImageView!
    var lblAlbumTitle: UILabel!
    var lblAlbumNumber: UILabel!
    var imgCheckMark: UIImageView!
    
    override init(style: UITableViewCellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        
        imgTitle = UIImageView(frame: CGRect(x: 10, y: 10, width: 60, height: 60))
        imgTitle.contentMode = .scaleAspectFill
        imgTitle.clipsToBounds = true
        addSubview(imgTitle)
        
        lblAlbumTitle = UILabel(frame: CGRect(x: 89, y: 19, w: 260, h: 22))
        lblAlbumTitle.textAlignment = .left
        lblAlbumTitle.textColor = UIColor._898989()
        lblAlbumTitle.font = UIFont(name: "AvenirNext-Medium", size: 18)
        addSubview(lblAlbumTitle)
        
        lblAlbumNumber = UILabel(frame: CGRect(x: 89, y: 41, w: 100, h: 20))
        lblAlbumNumber.textAlignment = .left
        lblAlbumNumber.textColor = UIColor._146146146()
        lblAlbumNumber.font = UIFont(name: "AvenirNext-Medium", size: 15)
        addSubview(lblAlbumNumber)
        
        imgCheckMark = UIImageView()
        imgCheckMark.image = UIImage(named: "albumTableCheckMark")
        addSubview(imgCheckMark)
        addConstraintsWithFormat("H:[v0(19)]-10-|", options: [], views: imgCheckMark)
        addConstraintsWithFormat("V:|-34-[v0(15)]", options: [], views: imgCheckMark)
        imgCheckMark.isHidden = true
        
        selectionStyle = .none
        
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
    
    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
        // Configure the view for the selected state
    }
    
    func setCheckMark(_ bool : Bool) {
        imgCheckMark.isHidden = !bool
    }
    
}
