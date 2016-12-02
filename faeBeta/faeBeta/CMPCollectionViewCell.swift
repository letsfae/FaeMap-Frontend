//
//  CMPCollectionViewCell.swift
//  faeBeta
//
//  Created by Yue on 11/26/16.
//  Copyright © 2016 fae. All rights reserved.
//

import UIKit

protocol CMPCellDelegate: class {
    func hideOtherCellOptions(tag: Int)
}

class CMPCollectionViewCell: UICollectionViewCell {
    
    weak var delegate: CMPCellDelegate?
    
    var media: UIImageView!
    var uiviewOptions: UIView!
    var buttonShowOptions: UIButton!
    var buttonHideOptions: UIButton!
    var buttonShowFullImage: UIButton!
    var buttonDeleteImage: UIButton!
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        loadCellItems()
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func loadCellItems() {
        media = UIImageView(frame: CGRect(x: 0, y: 0, width: 200, height: 200))
        media.clipsToBounds = true
        media.layer.cornerRadius = 20
        media.contentMode = .scaleAspectFill
        self.addSubview(media)
        
        buttonShowOptions = UIButton(frame: CGRect(x: 0, y: 0, width: 200, height: 200))
        buttonShowOptions.clipsToBounds = true
        self.addSubview(buttonShowOptions)
        buttonShowOptions.addTarget(self, action: #selector(self.showOptions(_:)), for: .touchUpInside)
        
        uiviewOptions = UIView(frame: CGRect(x: 0, y: 0, width: 200, height: 200))
        uiviewOptions.clipsToBounds = true
        uiviewOptions.layer.cornerRadius = 20
        uiviewOptions.backgroundColor = UIColor(red: 50/255, green: 50/255, blue: 50/255, alpha: 0.7)
        self.addSubview(uiviewOptions)
        uiviewOptions.isHidden = true
        
        buttonHideOptions = UIButton(frame: CGRect(x: 0, y: 0, width: 200, height: 200))
        buttonHideOptions.clipsToBounds = true
        uiviewOptions.addSubview(buttonHideOptions)
        buttonHideOptions.addTarget(self, action: #selector(self.hideOptions(_:)), for: .touchUpInside)
        
        buttonShowFullImage = UIButton(frame: CGRect(x: 35, y: 68, width: 64, height: 64))
        buttonShowFullImage.setImage(UIImage(named: "momentFullImage"), for: UIControlState())
        uiviewOptions.addSubview(buttonShowFullImage)
        
        buttonDeleteImage = UIButton(frame: CGRect(x: 100, y: 66, width: 66, height: 68))
        buttonDeleteImage.setImage(UIImage(named: "momentDeleteImage"), for: UIControlState())
        uiviewOptions.addSubview(buttonDeleteImage)
    }
    
    func showOptions(_ sender: UIButton) {
        self.delegate?.hideOtherCellOptions(tag: sender.tag)
        uiviewOptions.isHidden = false
    }
    
    func hideOptions(_ sender: UIButton) {
        uiviewOptions.isHidden = true
    }
}
