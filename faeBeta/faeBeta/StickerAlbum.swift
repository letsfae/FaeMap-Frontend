//
//  StickerAlbum.swift
//  quickChat
//
//  Created by User on 7/19/16.
//  Copyright © 2016 User. All rights reserved.
//

import Foundation

// delegate to find sticker image name from dictionary by the frame of sticker being clicked

protocol findStickerFromDictDelegate {
    func sendSticker(album: String, index: Int)
}

// this class is used to figure out position of all sticker in scroll view. Now the matrix is 5 column and 2 row, you can change formation by changing
// rowPerPage and colPerPage, it will automaticly calculate number of total pages.

class StickerAlbum {
    
    var albumName = ""
    var currentSelectedIndex = -1
    var rowPerPage : CGFloat = 2
    var colPerPage : CGFloat = 4
    var stickerName = [[String]]()
    var stickerPos = [CGRect]()
    let widthPage : CGFloat = UIScreen.main.bounds.width
    let heightPage : CGFloat = 195
    let length : CGFloat = 82
    var pageNumber = 0
    var buttonSet = [UIButton]()
    var imageSet = [UIImageView]()
    var findStickerDelegate : findStickerFromDictDelegate!
    var basePages = 0
    
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
    
    func appendNewImage(_ name : String) {
        if stickerName.count == 0
            || stickerName[stickerName.count - 1].count == (Int)(rowPerPage * colPerPage) {
            stickerName.append([String]())
        }
        stickerName[stickerName.count - 1].append(name)
        pageNumber = stickerName.count
    }
    
    func attachStickerButton(_ scrollView : UIScrollView) {
        for page in 0..<pageNumber {
            for row in 0..<Int(rowPerPage) {
                for col in 0..<Int(colPerPage) {
                    let index = row * Int(colPerPage) + col
//                    print(index)
                    if(stickerName[page].count <= index) {
                        break
                    }
                    let newFrame = CGRect(x: stickerPos[index].origin.x + CGFloat(page + basePages) * widthPage, y: stickerPos[index].origin.y, width: stickerPos[index].width, height: stickerPos[index].height)
                    let imageView = UIImageView(frame: newFrame)
                    imageView.image = UIImage(named: stickerName[page][index])
                    imageView.contentMode = .scaleAspectFit
                    let button = UIButton(frame: newFrame)
                    //add function
                    button.addTarget(self, action: #selector(calculateIndex), for: .touchUpInside)
                    scrollView.addSubview(imageView)
                    scrollView.addSubview(button)
                    imageSet.append(imageView)
                    buttonSet.append(button)
                }
            }
        }
    }
    
    func calculatePos() {
        let lineInterval = (heightPage - rowPerPage * length) / (1 + rowPerPage)
        let inlineInterval = (widthPage - colPerPage * length) / (1 + colPerPage)
        var y = lineInterval + 10
        for _ in 0..<(Int)(rowPerPage) {
            var x = inlineInterval
            for _ in 0..<(Int)(colPerPage) {
                stickerPos.append(CGRect(x: x, y: y, width: length, height: length))
                x += length + inlineInterval
            }
            y += length + lineInterval
        }
    }
    
    func clearAll() {
        self.stickerName.removeAll()
        self.pageNumber = 0
        self.basePages = 0
        clearButton()
    }
    
    func clearButton() {
        if buttonSet.count != 0 {
            for button in buttonSet {
                button.removeFromSuperview()
            }
            for imageView in imageSet {
                imageView.removeFromSuperview()
            }
        }
    }
    
    @objc func calculateIndex(_ sender : UIButton) {
        let original = sender.frame.origin
        let currentPage = (Int)(original.x / widthPage) - basePages
        let lineInterval = (heightPage - rowPerPage * length) / (1 + rowPerPage)
        let inlineInterval = (widthPage - colPerPage * length) / (1 + colPerPage)
        var index = 0
        // check value
        print(original)
        print(currentPage)
        print(lineInterval)
        print(inlineInterval)
        print(colPerPage)
        print((Int)(original.y / lineInterval))
        if ((Int)(original.y / lineInterval) > 1) {
            index += (Int)(colPerPage)
            print(index)
        }
        let temp = original.x - (CGFloat)(currentPage + basePages) * widthPage
        index += Int(temp / (inlineInterval + length))
        index += (Int)(CGFloat(currentPage) * colPerPage * rowPerPage)
        self.currentSelectedIndex = index
        print("the index is: \(index)")
        findStickerDelegate.sendSticker(album: albumName,index: index)
    }
}
