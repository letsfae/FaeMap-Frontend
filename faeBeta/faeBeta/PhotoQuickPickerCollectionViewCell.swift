//
//  PhotoQuickPickerCollectionViewCell.swift
//  quickChat
//
//  Created by User on 7/25/16.
//  Copyright © 2016 User. All rights reserved.
//

import UIKit

class PhotoQuickPickerCollectionViewCell: UICollectionViewCell {

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
    
    override func prepareForReuse() {
        photoImageView.image = nil
        chosenFrameImageView.hidden = true
    }
    
}
