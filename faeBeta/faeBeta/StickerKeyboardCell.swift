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
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func prepareForReuse() {
        super.prepareForReuse()
        imgSticker.image = nil
    }
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
        fatalError("init(coder:) has not been implemented")
    }
}
