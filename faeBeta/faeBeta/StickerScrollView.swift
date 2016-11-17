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
    private(set) var stickerAlbums : [StickerAlbum]!
    var currentAlbum : StickerAlbum!
    private var cumulativePage = 0
    
    override init(frame : CGRect) {
        super.init(frame: frame)
        self.backgroundColor = UIColor(red: 246 / 255, green: 246 / 255, blue: 246 / 255, alpha: 1.0)
        self.isPagingEnabled = true
        self.showsHorizontalScrollIndicator = false
        stickerAlbums = [StickerAlbum]()
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    
    /// create a new album
    ///
    /// - Parameters:
    ///   - name: the name of the album
    ///   - row: number of rows per page
    ///   - col: number of cols per page
    func createNewAlbums(name: String, row: Int, col: Int)
    {
        cumulativePage += stickerAlbums.last != nil ? max(stickerAlbums.last!.pageNumber ,1) : 0
        let album = StickerAlbum(name: name, row: row, col: col, basePage: cumulativePage)
        stickerAlbums.append(album)
        
    }
    
    func appendNewImage(_ name : String) {
        assert(stickerAlbums.count > 0, "You must create an album before append new images!")
        stickerAlbums.last?.appendNewImage(name)
    }
    
    func attachButton() {
        let totalPages = StickerInfoStrcut.pageNumDictionary.reduce(0,{$0 + $1.value})
        
        self.contentSize = CGSize(width: self.frame.size.width * max(1, CGFloat(totalPages)), height: self.frame.size.height)

        for stickerAlbum in stickerAlbums {
            stickerAlbum.attachStickerButton(self)
        }
    }
    
    func clearButton() {
        for stickerAlbum in stickerAlbums {
            stickerAlbum.clearAll()
        }
        stickerAlbums.removeAll()
        cumulativePage = 0
    }
    
    
    /// get the album with the specific name
    ///
    /// - Parameter name: the name of the album
    /// - Returns: a StickerAlbum
    func getAlbum(withName name:String) -> StickerAlbum?
    {
        for stickerAlbum in stickerAlbums {
            if stickerAlbum.albumName == name{
                return stickerAlbum
            }
        }
        return nil
    }
}
