//
//  EditPinCollectionViewCell.swift
//  faeBeta
//
//  Created by Jacky on 1/7/17.
//  Copyright © 2017 fae. All rights reserved.
//

import UIKit

protocol EditMediaCollectionCellDelegate: class {
    func deleteMedia(cell: EditPinCollectionViewCell)
}

class EditPinCollectionViewCell: UICollectionViewCell {
    
    var media: UIImageView!
    var fullView: UIView!
    var circleLayer: CAShapeLayer!
    var buttonCancel: UIButton!
    
    weak var delegate: EditMediaCollectionCellDelegate?
    
    override init(frame: CGRect){
        super.init(frame: frame)
        loadItems()
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    func loadItems() {
        fullView = UIView(frame: CGRect(x: 0, y: 0, width: 100, height: 100))
        self.addSubview(fullView)
        
        media = UIImageView(frame: CGRect(x: 0, y: 5, width: 95, height: 95))
        media.clipsToBounds = true
        media.layer.cornerRadius = 13.5
        media.contentMode = .scaleAspectFill
        fullView.addSubview(media)
        
        buttonCancel = UIButton(frame: CGRect(x: 74, y: 0, width: 26, height: 26))
        buttonCancel.setImage(#imageLiteral(resourceName: "Cancel"), for: UIControlState())
        buttonCancel.addTarget(self, action: #selector(self.deletePinMedia(_ :)), for: .touchUpInside)
        fullView.addSubview(buttonCancel)
    }
    
    func deletePinMedia(_ sender: UIButton){
        self.delegate?.deleteMedia(cell: self)
    }
    
}
