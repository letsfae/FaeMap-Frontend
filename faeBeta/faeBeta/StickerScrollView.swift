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
    private(set) var arrStickerAlbums : [StickerAlbum]!
    var currentAlbum : StickerAlbum!
    private var intCumulativePage = 0
    
    // MARK: init
    override init(frame : CGRect) {
        super.init(frame: frame)
        self.backgroundColor = UIColor(red: 246 / 255, green: 246 / 255, blue: 246 / 255, alpha: 1.0)
        self.isPagingEnabled = true
        self.showsHorizontalScrollIndicator = false
        arrStickerAlbums = [StickerAlbum]()
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
    func createNewAlbums(name: String, row: Int, col: Int) {
        intCumulativePage += arrStickerAlbums.last != nil ? max(arrStickerAlbums.last!.intPageNumber, 1) : 0
        let album = StickerAlbum(name: name, row: row, col: col, basePage: intCumulativePage)
        arrStickerAlbums.append(album)
        
    }
    
    func appendNewImage(_ name : String) {
        assert(arrStickerAlbums.count > 0, "You must create an album before append new images!")
        arrStickerAlbums.last?.appendNewImage(name)
    }
    
    func attachButton() {
        let totalPages = StickerInfoStrcut.pageNumDictionary.reduce(0, {$0 + $1.value})
        
        self.contentSize = CGSize(width: self.frame.size.width * max(1, CGFloat(totalPages)), height: self.frame.size.height)

        /*for stickerAlbum in arrStickerAlbums {
            DispatchQueue.main.async {
                stickerAlbum.attachStickerButton(self)
            }
        }*/
        for (index, StickerAlbum) in arrStickerAlbums.enumerated() {
            DispatchQueue.main.asyncAfter(deadline: DispatchTime.now() + 0.1 * Double(index), execute: {
                StickerAlbum.attachStickerButton(self)
            })
            
        }
    }
    
    func clearButton() {
        for stickerAlbum in arrStickerAlbums {
            stickerAlbum.clearAll()
        }
        arrStickerAlbums.removeAll()
        intCumulativePage = 0
    }
    
    /// get the album with the specific name
    ///
    /// - Parameter name: the name of the album
    /// - Returns: a StickerAlbum
    func getAlbum(withName name:String) -> StickerAlbum?
    {
        for stickerAlbum in arrStickerAlbums {
            if stickerAlbum.strAlbumName == name {
                return stickerAlbum
            }
        }
        return nil
    }
}
