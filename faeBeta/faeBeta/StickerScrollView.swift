//
//  StickerScrollView.swift
//  quickChat
//
//  Created by User on 7/19/16.
//  Copyright © 2016 User. All rights reserved.
//

import Foundation

// this is a class that work with stickerAlbum class. 
// it is used to create a scroll view, size is based on the calculation of its StickerAlbum

class StickerScrollView : UIScrollView {
    var stickerAlbum : StickerAlbum!
    override init(frame : CGRect) {
        super.init(frame: frame)
        self.backgroundColor = UIColor(red: 246 / 255, green: 246 / 255, blue: 246 / 255, alpha: 1.0)
        self.isPagingEnabled = true
        self.showsHorizontalScrollIndicator = false
        stickerAlbum = StickerAlbum()
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func appendNewImage(_ name : String) {
        stickerAlbum.appendNewImage(name)
    }
    
    func attachButton() {
        self.contentSize = CGSize(width: self.frame.size.width * CGFloat(stickerAlbum.pageNumber), height: self.frame.size.height)
        stickerAlbum.attachStickerButton(self)
    }
    
    func clearButton() {
        stickerAlbum.clearButton()
    }
    
}
