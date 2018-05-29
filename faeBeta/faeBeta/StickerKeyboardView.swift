//
//  StickerKeyboardView.swift
//  faeBeta
//
//  Created by Jichao on 2018/1/21.
//  Copyright © 2018 fae. All rights reserved.
//

import UIKit

protocol SendStickerDelegate: class {
    func sendStickerWithImageName(_ name : String)
    func appendEmojiWithImageName(_ name: String)
    func deleteEmoji()
}

class StickerKeyboardView: UIView {
    // MARK: - Properties
    private var cllcSticker: UICollectionView!
    private var pageControl: UIPageControl!
    private var buttons: UICollectionView!
    private var arrCollectionIndetifiers: [String] = ["stickerHistory", "stickerLike", "faeEmoji", "faeSticker", "faeGuy", "steamBun"]
    var arrPageNumIndex: [Int] = []
    var arrStickerCollection: [StickerCollection] = [] {
        didSet {
            arrPageNumIndex.removeAll()
            configurePageIndex()
        }
    }
    
    private var intCurrentSection: Int = 0 {
        didSet {
            let numPerPage = intCurrentSection == 2 ? 28 : 8
            let totalPages = Int(ceil(CGFloat(cllcSticker.numberOfItems(inSection: intCurrentSection)) / CGFloat(numPerPage)))
            pageControl.numberOfPages = totalPages
        }
    }
    
    private var intPageInSection: Int = 0 {
        didSet {
            pageControl.currentPage = intPageInSection
        }
    }
    
    weak var delegate: SendStickerDelegate?
    
    // MARK: - init
    override init(frame: CGRect) {
        super.init(frame: frame)
        backgroundColor = .white
        
        setupCollections()
        
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
        
        NotificationCenter.default.addObserver(self, selector: #selector(updateStickerInFavorite), name: Notification.Name(rawValue: "favoriteSticker"), object: nil)
        
        let menuItem = UIMenuItem(title: "Delete", action: NSSelectorFromString("deleteFavorite"))
        UIMenuController.shared.menuItems?.append(menuItem)
    }
    
    @objc private func updateStickerInFavorite() {
        setupCollections()
        cllcSticker.reloadSections([1])
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func setupCollections() {
        for identifier in ["stickerHistory", "stickerLike"] {
            if let stickerHistory = FaeCoreData.shared.readByKey("\(identifier)_\(Key.shared.user_id)") as? [String] {
                StickerInfoStrcut.stickerDictionary[identifier]?.removeAll()
                StickerInfoStrcut.stickerDictionary[identifier]?.append(contentsOf: stickerHistory)
            }
        }
        arrStickerCollection.removeAll()
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

// MARK: - UICollectionViewDataSource
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

// MARK: - UICollectionViewDelegate
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
                updateStickerInHistory(name)
                setupCollections()
                collectionView.reloadSections([0])
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
    
    private func updateStickerInHistory(_ latestName: String) {
        var stickerHistory: [String] = []
        if let current = FaeCoreData.shared.readByKey("stickerHistory_\(Key.shared.user_id)") as? [String]{
            stickerHistory = current
        }
        if let existIndex = stickerHistory.index(of: latestName) {
            stickerHistory.remove(at: existIndex)
        }
        stickerHistory.insert(latestName, at: 0)
        if stickerHistory.count > 16 {
            stickerHistory.removeLast()
        }
        FaeCoreData.shared.save("stickerHistory_\(Key.shared.user_id)", value:stickerHistory)
    }
    
    func collectionView(_ collectionView: UICollectionView, shouldShowMenuForItemAt indexPath: IndexPath) -> Bool {
        if indexPath.section == 1 { return true }
        return false
    }
    
    func collectionView(_ collectionView: UICollectionView, canPerformAction action: Selector, forItemAt indexPath: IndexPath, withSender sender: Any?) -> Bool {
        if action.description == "deleteFavorite:" { return true }
        return false
    }
    
    func collectionView(_ collectionView: UICollectionView, performAction action: Selector, forItemAt indexPath: IndexPath, withSender sender: Any?) {
        //felixprint("sticker menu")
        let deletedName = arrStickerCollection[indexPath.section].list[indexPath.item]
        var stickerLike: [String] = []
        if let current = FaeCoreData.shared.readByKey("stickerLike_\(Key.shared.user_id)") as? [String]{
            stickerLike = current
        }
        if let existIndex = stickerLike.index(of: deletedName) {
            stickerLike.remove(at: existIndex)
        }
        FaeCoreData.shared.save("stickerLike_\(Key.shared.user_id)", value: stickerLike)
        setupCollections()
        collectionView.collectionViewLayout.invalidateLayout()
        collectionView.reloadSections([1])
    }
}

// MARK: - UICollectionViewDelegateFlowLayout
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

// MARK: - UIScrollViewDelegate
extension StickerKeyboardView: UIScrollViewDelegate {
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
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

