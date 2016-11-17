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
    
    private(set) var albumName = ""
    private var rowPerPage : CGFloat = 2
    private var colPerPage : CGFloat = 4
    private var stickerName = [[String]]() // a two dimentional array to store names for all the sticker, 
    // look like this: [[page1name1,page1name2,page1name3], [page2name1,page2name2,page2name3]]
    
    private var stickerPos = [CGRect]() // an array to store positions for all the sticker
    private let widthPage : CGFloat = screenWidth
    private let heightPage : CGFloat = 195
    
    private var stickerLength : CGFloat
    {
        get{
            if colPerPage > 4{
                return 32
            }else{
                return 82
            }
        }
    }
    
    private(set) var pageNumber = 0 // the number of pages for this set of stickers, will be automatically calculated
    
    private var buttonSet = [UIButton]() // a set to store all the sticker buttons
    private var imageSet = [UIImageView]() // a set to store all the sticker imageViews
    
    weak var findStickerDelegate : findStickerFromDictDelegate!
    private(set) var basePages = 0
    
    private var isEmojiAlbum: Bool{
        get{
            return colPerPage > 4
        }
    }
    
    init() {
        calculatePos()
    }
    
    init(name: String, row: Int, col: Int, basePage: Int) {
        albumName = name
        rowPerPage = CGFloat(row)
        colPerPage = CGFloat(col)
        basePages = basePage
        calculatePos()
    }
    
    // add one emoji into this album
    func appendNewImage(_ name : String) {
        if stickerName.count == 0
            || stickerName.last!.count == (isEmojiAlbum ? (Int)(rowPerPage * colPerPage) - 1 : (Int)(rowPerPage * colPerPage) ) {
            stickerName.append([String]())
        }
        stickerName[stickerName.count - 1].append(name)
        pageNumber = stickerName.count
    }
    
    // Call this method after all the images for this ablum is appended
    func attachStickerButton(_ scrollView : UIScrollView) {
        
        for page in 0..<pageNumber {
            for row in 0..<Int(rowPerPage) {
                for col in 0..<Int(colPerPage) {
                    let index = row * Int(colPerPage) + col

                    if(stickerName[page].count <= index && !isEmojiAlbum) {
                        break
                    }
            
                    let newFrame = CGRect(x: stickerPos[index].origin.x + CGFloat(page + basePages) * widthPage, y: stickerPos[index].origin.y, width: stickerPos[index].width, height: stickerPos[index].height)
                    let imageView = UIImageView(frame: newFrame)
                    imageView.contentMode = .scaleAspectFit
                    let button = UIButton(frame: newFrame)

                    scrollView.addSubview(imageView)
                    scrollView.addSubview(button)
                    imageSet.append(imageView)
                    buttonSet.append(button)
                    
                    if isEmojiAlbum && (index + 1) == Int(rowPerPage * colPerPage) {
                        imageView.image = UIImage(named: "erase")
                        button.addTarget(self, action: #selector(deleteEmoji), for: .touchUpInside)

                    }else if (stickerName[page].count > index){
                        imageView.image = UIImage(named: stickerName[page][index])
                        button.addTarget(self, action: #selector(calculateIndex), for: .touchUpInside)
                    }
                }
            }
        }
    }
    
    
    /// calculate the postion for each sticker and store it in an array
    private func calculatePos() {
        let lineInterval = (heightPage - rowPerPage * stickerLength) / (1 + rowPerPage)
        let inlineInterval = (widthPage - colPerPage * stickerLength) / (1 + colPerPage)
        var y = lineInterval + 10
        for _ in 0..<(Int)(rowPerPage) {
            var x = inlineInterval
            for _ in 0..<(Int)(colPerPage) {
                stickerPos.append(CGRect(x: x, y: y, width: stickerLength, height: stickerLength))
                x += stickerLength + inlineInterval
            }
            y += stickerLength + lineInterval
        }
    }
    
    // clean up the scroll view, remove all stickers attached to the scroll view
    func clearAll() {
        self.stickerName.removeAll()
        self.pageNumber = 0
        self.basePages = 0
        clearButton()
    }
    
    
    private func clearButton() {
        if buttonSet.count != 0 {
            for button in buttonSet {
                button.removeFromSuperview()
            }
            for imageView in imageSet {
                imageView.removeFromSuperview()
            }
        }
    }
    
    
    /// calculate which sticker user pressed by it's frame and send it out
    ///
    /// - Parameter sender: the sticker button user pressed
    @objc private func calculateIndex(_ sender : UIButton) {
        
        let original = sender.frame.origin
        let currentPage = (Int)(original.x / widthPage) - basePages
        let lineInterval = (heightPage - rowPerPage * stickerLength) / (1 + rowPerPage)
        let inlineInterval = (widthPage - colPerPage * stickerLength) / (1 + colPerPage)
        var index = 0
        
        // get how many rows above this sticker
        if Int(original.y / (lineInterval + stickerLength)) > 1 {
            index += Int(colPerPage) * Int(original.y / (lineInterval + stickerLength))
        }
        
        // get how many col before this sticker
        let temp = original.x - (CGFloat)(currentPage + basePages) * widthPage
        index += Int(temp / (inlineInterval + stickerLength))
        
        // add up the emoji number in previous page
        index += (Int)(CGFloat(currentPage) * (colPerPage * rowPerPage - (isEmojiAlbum ? 1 : 0)))
        
        // send the emoji out
        findStickerDelegate.sendSticker(album: albumName,index: index)
    }
    
    // delete one emoji
    @objc private func deleteEmoji(_ sender: UIButton){
        findStickerDelegate.deleteEmoji()
    }
}
