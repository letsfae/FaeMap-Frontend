//
//  StickerKeyboardView.swift
//  faeBeta
//
//  Created by Jichao on 2018/1/21.
//  Copyright © 2018 fae. All rights reserved.
//

import UIKit

class StickerKeyboardView: UIView {
    var cllcSticker: UICollectionView!
    var pageControl: UIPageControl!
    var buttons: UICollectionView!
    var arrPageNumIndex: [Int] = []
    var arrCollectionIndetifiers: [String] = ["stickerHistory", "stickerLike", "faeEmoji", "faeSticker", "faeGuy", "steamBun"]
    var arrStickerCollection: [StickerCollection] = [] {
        didSet {
            arrPageNumIndex.removeAll()
            configurePageIndex()
        }
    }
    
    var intCurrentSection: Int = 0 {
        didSet {
            let numPerPage = intCurrentSection == 2 ? 28 : 8
            let totalPages = Int(ceil(CGFloat(cllcSticker.numberOfItems(inSection: intCurrentSection)) / CGFloat(numPerPage)))
            pageControl.numberOfPages = totalPages
        }
    }
    
    var intPageInSection: Int = 0 {
        didSet {
            pageControl.currentPage = intPageInSection
        }
    }
    
    weak var delegate: SendStickerDelegate?
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        backgroundColor = .white
        
        setupCollections()
        // Do any additional setup after loading the view, typically from a nib.
        
        let layout = StickerKeyboardViewFlowLayout()
        layout.scrollDirection = .horizontal
        layout.dataSource = self
        
        cllcSticker = UICollectionView(frame: CGRect(x: 0, y: 0, width: screenWidth, height: 231), collectionViewLayout: layout)
        cllcSticker.isPagingEnabled = true
        cllcSticker.showsHorizontalScrollIndicator = false
        cllcSticker.showsVerticalScrollIndicator = false
        cllcSticker.contentInset = UIEdgeInsetsMake(0, 0, 0, 0)
        cllcSticker.backgroundColor = UIColor._246246246()
        cllcSticker.dataSource = self
        cllcSticker.delegate = self
        cllcSticker.register(StickerCell.self, forCellWithReuseIdentifier: "sticker")
        addSubview(cllcSticker)
        
        pageControl = UIPageControl(frame: CGRect(x: 0, y: 209, width: screenWidth, height: 8))
        pageControl.pageIndicatorTintColor = UIColor._182182182()
        pageControl.currentPageIndicatorTintColor = UIColor._2499090()
        pageControl.backgroundColor = UIColor._246246246()
        addSubview(pageControl)
        
        
        let layout2 = UICollectionViewFlowLayout()
        layout2.scrollDirection = .horizontal
        layout2.minimumLineSpacing = 0
        buttons = UICollectionView(frame: CGRect(x: 0, y: 231, width: screenWidth, height: 40), collectionViewLayout: layout2)
        buttons.backgroundColor = .white
        buttons.alwaysBounceHorizontal = true
        buttons.register(StickerTabCell.self, forCellWithReuseIdentifier: "tabButton")
        buttons.dataSource = self
        buttons.delegate = self
        addSubview(buttons)
        
        //intCurrentSection = 2
        cllcSticker.setContentOffset(CGPoint(x: screenWidth * CGFloat(arrPageNumIndex[1]), y: 0), animated: false)
        cllcSticker.setNeedsLayout()
        cllcSticker.layoutIfNeeded()
        intCurrentSection = 2
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func setupCollections() {
        for identifier in arrCollectionIndetifiers {
            let stickerList = StickerInfoStrcut.stickerDictionary[identifier]
            let stickerCollection = StickerCollection(name: identifier, count: stickerList!.count, isEmoji: identifier == "faeEmoji")
            arrStickerCollection.append(stickerCollection)
            stickerCollection.setupList(stickerList!)
        }
    }
    
    func configurePageIndex() {
        for (index, collection) in arrStickerCollection.enumerated() {
            let page: Int = index == 0 ? collection.page : collection.page + arrPageNumIndex[index - 1]
            arrPageNumIndex.append(page)
        }
    }
}

extension StickerKeyboardView: UICollectionViewDataSource {
    func numberOfSections(in collectionView: UICollectionView) -> Int {
        if collectionView == cllcSticker {
            return arrStickerCollection.count
        } else {
            return 1
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        if collectionView == cllcSticker {
            return arrStickerCollection[section].count
        } else {
            return cllcSticker.numberOfSections
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        if collectionView == cllcSticker {
            let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "sticker", for: indexPath) as! StickerCell
            cell.imgSticker.image = UIImage(named: arrStickerCollection[indexPath.section].list[indexPath.item])
            if indexPath.section == 2 {
                cell.imgSticker.frame = CGRect(x: 0, y: 0, width: 32, height: 32)
            } else {
                cell.imgSticker.frame = CGRect(x: 0, y: 0, width: 82, height: 82)
            }
            //cell.lblIndex.text = String(indexPath.row)
            return cell
        } else {
            let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "tabButton", for: indexPath) as! StickerTabCell
            cell.imgBtn.image = UIImage(named: arrCollectionIndetifiers[indexPath.item])
            if indexPath.row == intCurrentSection {
                cell.line.isHidden = false
            } else {
                cell.line.isHidden = true
            }
            return cell
        }
    }
    
}

extension StickerKeyboardView: UICollectionViewDelegate {
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        if collectionView == cllcSticker {
            print(arrStickerCollection[indexPath.section].list[indexPath.item])
            let name = arrStickerCollection[indexPath.section].list[indexPath.item]
            if arrStickerCollection[indexPath.section].isEmoji {
                if name == "erase" {
                    delegate?.deleteEmoji()
                } else {
                    delegate?.appendEmojiWithImageName(name)
                }
            } else {
                delegate?.sendStickerWithImageName(name)
            }
        } else {
            let targetPage = indexPath.row == 0 ? 0 : arrPageNumIndex[indexPath.row - 1]
            intPageInSection = 0
            intCurrentSection = indexPath.row == 0 ? 0 : arrPageNumIndex.index(of: targetPage)! + 1
            let offset = CGFloat(targetPage) * screenWidth
            cllcSticker.setContentOffset(CGPoint(x: offset, y: 0), animated: false)
            collectionView.reloadData()
        }
    }
}

extension StickerKeyboardView: UICollectionViewDelegateFlowLayout {
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        if collectionView == cllcSticker {
            if indexPath.section == 2 {
                return CGSize(width: 32, height: 32)
            } else {
                return CGSize(width: 82, height: 82)
            }
        } else {
            return CGSize(width: 44, height: 40)
        }
    }
    
}

extension StickerKeyboardView: UIScrollViewDelegate {
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        //print("scroll")
        if let collectionView = scrollView as? UICollectionView, collectionView == cllcSticker {
            let x = min(scrollView.contentOffset.x, screenWidth * CGFloat(arrPageNumIndex.last! - 1))
            buttons.reloadData()
            (intCurrentSection, intPageInSection) = findOutCurrentSection(x)
        }
    }
    
    func findOutCurrentSection(_ current: CGFloat) -> (Int, Int) {
        let currentPage = Int(ceil(current / screenWidth)) + 1
        for (index, page) in arrPageNumIndex.enumerated() {
            if page >= currentPage {
                if index == 0 {
                    return (0, arrPageNumIndex[0] - 1)
                }
                return (index, currentPage - arrPageNumIndex[index-1] - 1)
            }
        }
        return (0, 0)
    }
}

