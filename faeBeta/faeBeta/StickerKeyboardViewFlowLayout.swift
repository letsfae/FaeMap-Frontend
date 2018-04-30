//
//  StickerKeyboardViewFlowLayout.swift
//  faeBeta
//
//  Created by Jichao on 2018/1/21.
//  Copyright © 2018 fae. All rights reserved.
//

import UIKit

class StickerKeyboardViewFlowLayout: UICollectionViewFlowLayout {
    let screenWidth = UIScreen.main.bounds.width
    
    // MARK: - Properties
    //var intNumOfStickerCollection: Int = 0
    var intNumOfTotalCollections: Int { return collectionView!.numberOfSections }
    var cumulativePages: [Int] { return dataSource!.arrPageNumIndex }
    
    var dictEmojiPrePos: [Int: CGPoint] = [:]
    var dictCollectionPrePos: [Int: CGPoint] = [:]
    var dictPositions: [IndexPath: UICollectionViewLayoutAttributes] = [:]
    
    weak var dataSource: StickerKeyboardView?
    var datasource: [StickerCollection] { return dataSource!.arrStickerCollection }
    
    override var collectionViewContentSize: CGSize {
        return CGSize(width: screenWidth * CGFloat(cumulativePages.last!), height: collectionView!.frame.size.height)
    }
    
    // MARK: - Override
    override func prepare() {
        super.prepare()
        calculatePrePosition()
        for (section, item) in datasource.enumerated() {
            let prePos = item.isEmoji ? dictEmojiPrePos : dictCollectionPrePos
            let basePage = section == 0 ? 0 : cumulativePages[section - 1]
            for page in 0..<item.page {
                for index in 0..<item.countPerPage {
                    let row = page * item.countPerPage + index
                    if row == item.count {
                        break
                    }
                    var selected = prePos[index]!
                    if item.isEmoji && row == item.count - 1 {
                        selected = prePos[item.countPerPage - 1]!
                    }
                    let x = CGFloat(page + basePage) * screenWidth + selected.x
                    let y = selected.y
                    let attributes = UICollectionViewLayoutAttributes(forCellWith: IndexPath(row: row, section: section))
                    attributes.frame = CGRect(x: Int(x), y: Int(y), width: item.size, height: item.size)
                    dictPositions[IndexPath(row: row, section: section)] = attributes
                }
            }
        }
        
    }
    
    // Helper method
    func calculatePrePosition() {
        let spaceEmoji = (screenWidth - 26.0 * 2 - 32.0 * 7) / 6
        for index in 0..<28 {
            let x = 26.0 + CGFloat(index % 7) * (32.0 + spaceEmoji)
            let y = 18.0 + CGFloat(index / 7) * 48.0
            dictEmojiPrePos[index] = CGPoint(x: x, y: y)
        }
        let spaceCollection = (screenWidth - 10.0 * 2 - 82.0 * 4) / 3
        for index in 0..<8 {
            let x = 10.0 + CGFloat(index % 4) * (82.0 + spaceCollection)
            let y = 15.0 + CGFloat(index / 4) * 98.0
            dictCollectionPrePos[index] = CGPoint(x: x, y: y)
        }
    }
    
    override func layoutAttributesForElements(in rect: CGRect) -> [UICollectionViewLayoutAttributes]? {
        var visibleLayoutAttributes = [UICollectionViewLayoutAttributes]()
        
        // Loop through the cache and look for items in the rect
        for (_, attributes) in dictPositions {
            if attributes.frame.intersects(rect) {
                visibleLayoutAttributes.append(attributes)
            }
        }
        return visibleLayoutAttributes
    }
    
    override func layoutAttributesForItem(at indexPath: IndexPath) -> UICollectionViewLayoutAttributes? {
        return dictPositions[indexPath]
    }
}
