//
//  StickerKeyboardCell.swift
//  faeBeta
//
//  Created by Jichao on 2018/1/21.
//  Copyright © 2018年 fae. All rights reserved.
//

import UIKit

// MARK: - StickerCell
class StickerCell: UICollectionViewCell {
    var imgSticker: UIImageView!
    var lblIndex: UILabel!
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        imgSticker = UIImageView(frame: CGRect(x: 0, y: 0, width: frame.width, height: frame.height))
        imgSticker.contentMode = .center
        addSubview(imgSticker)
        //addLongPress()
    }
    
    func addDeleteButton() {
        let btnDelete = UIButton(frame: CGRect(x: 0, y: 0, width: 15, height: 15))
        btnDelete.setImage(UIImage(named: "btn_close"), for: .normal)
        addSubview(btnDelete)
        btnDelete.addTarget(self, action: #selector(deleteAction), for: .touchUpInside)
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
    
    override func prepareForReuse() {
        super.prepareForReuse()
        imgSticker.image = nil
    }
    
    @objc
    func deleteAction() {
        let collectionView = self.superview as! UICollectionView
        let delegate = collectionView.delegate
        delegate?.collectionView!(collectionView, performAction: NSSelectorFromString("deleteFavorite"), forItemAt: collectionView.indexPath(for: self)!, withSender: self)
    }
    
    /*override func responds(to aSelector: Selector!) -> Bool {
        return true
    }*/
    
    /*override var canBecomeFirstResponder: Bool { return true }

    override func canPerformAction(_ action: Selector, withSender sender: Any?) -> Bool {
        if action.description == "deleteFavorite" { return true }
        //if action == #selector(delete(_:)) { return true }
        return false
    }
    
    @objc func deleteFavorite() {
        //felixprint("cell delete")
        let collectionView = self.superview as! UICollectionView
        let delegate = collectionView.delegate
        delegate?.collectionView!(collectionView, performAction: NSSelectorFromString("deleteFavorite"), forItemAt: collectionView.indexPath(for: self)!, withSender: self)
    }*/
}

// MARK: - StickerTabCell
class StickerTabCell: UICollectionViewCell {
    var imgBtn: UIImageView!
    var line: UIView!
    var separator: UIView!
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        imgBtn = UIImageView(frame: CGRect(x: 0, y: 6, width: 28, height: 28))
        imgBtn.center.x = (frame.width - 1) / 2
        addSubview(imgBtn)
        
        line = UIView(frame: CGRect(x: 0, y: frame.height - 3, width: frame.width - 1, height: 3))
        line.backgroundColor = UIColor._2499090()
        addSubview(line)
        line.isHidden = true
        
        separator = UIView(frame: CGRect(x: frame.width - 1, y: 0, width: 1, height: 27))
        separator.center.y = frame.height / 2
        separator.backgroundColor = UIColor._210210210()
        addSubview(separator)
        
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
}
