//
//  StickerAlbum.swift
//  quickChat
//
//  Created by User on 7/19/16.
//  Copyright © 2016 User. All rights reserved.
//

import Foundation

// delegate to find sticker image name from dictionary by the frame of sticker being clicked
protocol findStickerFromDictDelegate: class {
    func sendSticker(album: String, index: Int)
    func deleteEmoji()
}

// this class is used to figure out position of all sticker in scroll view. Now the matrix is 5 column and 2 row, you can change formation by changing
// rowPerPage and colPerPage, it will automaticly calculate number of total pages.

class StickerAlbum {
    
    private(set) var strAlbumName = ""
    private var floatRowPerPage: CGFloat = 2
    private var floatColPerPage: CGFloat = 4
    private var arr2StrStickerName = [[String]]() // a two dimentional array to store names for all the sticker, 
    // look like this: [[page1name1,page1name2,page1name3], [page2name1,page2name2,page2name3]]
    
    private var arrRectStickerPos = [CGRect]() // an array to store positions for all the sticker
    private let floatWidthPage: CGFloat = screenWidth
    private let floatHeightPage: CGFloat = 195
    
    private var stickerLength: CGFloat {
        get {
            if floatColPerPage > 4 {
                return 32
            } else {
                return 82
            }
        }
    }
    
    private(set) var intPageNumber = 0 // the number of pages for this set of stickers, will be automatically calculated
    
    private var arrBtnSet = [UIButton]() // a set to store all the sticker buttons
    private var arrImgSet = [UIImageView]() // a set to store all the sticker imageViews
    
    weak var findStickerDelegate: findStickerFromDictDelegate!
    private(set) var intBasePage = 0
    
    private var isEmojiAlbum: Bool {
        get {
            return floatColPerPage > 4
        }
    }
    
    // MARK: init
    init() {
        calculatePos()
    }
    
    init(name: String, row: Int, col: Int, basePage: Int) {
        strAlbumName = name
        floatRowPerPage = CGFloat(row)
        floatColPerPage = CGFloat(col)
        intBasePage = basePage
        calculatePos()
    }
    
    // add one emoji into this album
    func appendNewImage(_ name : String) {
        if arr2StrStickerName.count == 0
            || arr2StrStickerName.last!.count == (isEmojiAlbum ? (Int)(floatRowPerPage * floatColPerPage) - 1 : (Int)(floatRowPerPage * floatColPerPage)) {
            arr2StrStickerName.append([String]())
        }
        arr2StrStickerName[arr2StrStickerName.count - 1].append(name)
        intPageNumber = arr2StrStickerName.count
    }
    
    // Call this method after all the images for this ablum is appended
    func attachStickerButton(_ scrollView : UIScrollView) {
        for page in 0..<intPageNumber {
            for row in 0..<Int(floatRowPerPage) {
                for col in 0..<Int(floatColPerPage) {
                    let index = row * Int(floatColPerPage) + col

                    if arr2StrStickerName[page].count <= index && !isEmojiAlbum {
                        break
                    }
            
                    let newFrame = CGRect(x: arrRectStickerPos[index].origin.x + CGFloat(page + intBasePage) * floatWidthPage, y: arrRectStickerPos[index].origin.y, width: arrRectStickerPos[index].width, height: arrRectStickerPos[index].height)
                    let imageView = UIImageView(frame: newFrame)
                    imageView.contentMode = .scaleAspectFit
                    let button = UIButton(frame: newFrame)

                    scrollView.addSubview(imageView)
                    scrollView.addSubview(button)
                    arrImgSet.append(imageView)
                    arrBtnSet.append(button)
                    
                    if isEmojiAlbum && (index + 1) == Int(floatRowPerPage * floatColPerPage) {
                        imageView.image = UIImage(named: "erase")
                        button.addTarget(self, action: #selector(deleteEmoji), for: .touchUpInside)

                    } else if arr2StrStickerName[page].count > index {
                        imageView.image = UIImage(named: arr2StrStickerName[page][index])
                        button.addTarget(self, action: #selector(calculateIndex), for: .touchUpInside)
                    }
                }
            }
        }
    }
    
    /// calculate the postion for each sticker and store it in an array
    private func calculatePos() {
        let lineInterval = (floatHeightPage - floatRowPerPage * stickerLength) / (1 + floatRowPerPage)
        let inlineInterval = (floatWidthPage - floatColPerPage * stickerLength) / (1 + floatColPerPage)
        var y = lineInterval + 10
        for _ in 0..<(Int)(floatRowPerPage) {
            var x = inlineInterval
            for _ in 0..<(Int)(floatColPerPage) {
                arrRectStickerPos.append(CGRect(x: x, y: y, width: stickerLength, height: stickerLength))
                x += stickerLength + inlineInterval
            }
            y += stickerLength + lineInterval
        }
    }
    
    // clean up the scroll view, remove all stickers attached to the scroll view
    func clearAll() {
        self.arr2StrStickerName.removeAll()
        self.intPageNumber = 0
        self.intBasePage = 0
        clearButton()
    }
    
    private func clearButton() {
        if arrBtnSet.count != 0 {
            for button in arrBtnSet {
                button.removeFromSuperview()
            }
            for imageView in arrImgSet {
                imageView.removeFromSuperview()
            }
        }
    }
    
    /// calculate which sticker user pressed by it's frame and send it out
    ///
    /// - Parameter sender: the sticker button user pressed
    @objc private func calculateIndex(_ sender : UIButton) {
        
        let original = sender.frame.origin
        let currentPage = (Int)(original.x / floatWidthPage) - intBasePage
        let lineInterval = (floatHeightPage - floatRowPerPage * stickerLength) / (1 + floatRowPerPage)
        let inlineInterval = (floatWidthPage - floatColPerPage * stickerLength) / (1 + floatColPerPage)
        var index = 0
        
        // get how many rows above this sticker
        if Int(original.y / (lineInterval + stickerLength)) >= 1 {
            index += Int(floatColPerPage) * Int(original.y / (lineInterval + stickerLength))
        }
        
        // get how many col before this sticker
        let temp = original.x - (CGFloat)(currentPage + intBasePage) * floatWidthPage
        index += Int(temp / (inlineInterval + stickerLength))
        
        // add up the emoji number in previous page
        index += (Int)(CGFloat(currentPage) * (floatColPerPage * floatRowPerPage - (isEmojiAlbum ? 1 : 0)))
        
        // send the emoji out
        findStickerDelegate.sendSticker(album: strAlbumName,index: index)
    }
    
    // delete one emoji
    @objc private func deleteEmoji(_ sender: UIButton) {
        findStickerDelegate.deleteEmoji()
    }
}
