//
//  StickerPickView.swift
//  quickChat
//
//  Created by User on 7/21/16.
//  Copyright © 2016 User. All rights reserved.
//

import Foundation

// this delegate is used to tell chatVC the name of sticker being send.
protocol SendStickerDelegate: class {
    func sendStickerWithImageName(_ name : String)
    func appendEmojiWithImageName(_ name: String)
    func deleteEmoji()
}

// this class is used to show all content in sticker part. It has tab view to switch set of sticker,
// scroll view to show set of sticker, page controller to show current page.
class StickerPickView: UIView, SwitchStickerDelegate, UIScrollViewDelegate, findStickerFromDictDelegate {
    
    private var pageControl : UIPageControl!
    private var stickerTabView : StickerTabView!
    //a tab view to controll the stickerScrollView and the stickerFixView
    
    private var currentScrollView : StickerScrollView!
    //a pointer to point which view we need to display.
    
    weak var sendStickerDelegate : SendStickerDelegate!
    
    private var dictHistory: [String : Int]!
    //most recently stick sorted by frequently and show in the second stickTabView
    
    private var boolInEmojiOnlyMode: Bool = false
    
    // MARK: init
    override init(frame : CGRect) {
        super.init(frame: frame)
        self.backgroundColor = UIColor(red: 246 / 255, green: 246 / 255, blue: 246 / 255, alpha: 1.0)//gray color
        configureHistoryPage()
        configureScrollView()
        configurePageController()
        configureTabView(emojiOnly: false)
        stickerTabView.switcher = self
        currentScrollView.delegate = self

        switchSticker(3)
        stickerTabView.updateTabIndicator(stickerTabView.tabButtons[3])
    }
    
    init(frame : CGRect, emojiOnly : Bool) {
        super.init(frame: frame)
        self.backgroundColor = UIColor(red: 246 / 255, green: 246 / 255, blue: 246 / 255, alpha: 1.0)//gray color
        if !emojiOnly {
            boolInEmojiOnlyMode = false
            configureHistoryPage()
            configureScrollView()
            configurePageController()
            configureTabView(emojiOnly: false)
            stickerTabView.switcher = self
            currentScrollView.delegate = self
            
            switchSticker(3)
            stickerTabView.updateTabIndicator(stickerTabView.tabButtons[3])
        } else {
            boolInEmojiOnlyMode = true
            configureScrollViewLite()
            configurePageController()
            configureTabView(emojiOnly: true)
//            stickerTabView.switcher = self
            currentScrollView.delegate = self
        }
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK: setup
    private func configureScrollView() {
        var index = 0
        let view = StickerScrollView(frame: CGRect(x: 0, y: 0, width: self.frame.width, height: 195)) //fixed high for every screen

        for stickerName in StickerInfoStrcut.stickerIndex {
            index += 1
            prepareAlbum(view, name: stickerName)
        }
        attachButton(view)
        currentScrollView = view
        self.addSubview(view)
    }
    
    private func configureScrollViewLite() {
        let view = StickerScrollView(frame: CGRect(x: 0, y: 0, width: self.frame.width, height: 195)) //fixed high for every screen
        prepareAlbum(view, name: "faeEmoji")
        attachButton(view)
        currentScrollView = view
        self.addSubview(view)
    }
    
    private func configureHistoryPage() {
        loadHistoryFromStorage()
    }
    
    private func configurePageController() {
        self.pageControl = UIPageControl(frame: CGRect(x: 0, y: 209, width: self.frame.width, height: 8))
        self.pageControl.numberOfPages = currentScrollView.currentAlbum.intPageNumber
        self.pageControl.currentPage = 0
        self.pageControl.pageIndicatorTintColor = UIColor._182182182()
        self.pageControl.currentPageIndicatorTintColor = UIColor._2499090()
        self.pageControl.backgroundColor = UIColor(red: 246 / 255, green: 246 / 255, blue: 246 / 255, alpha: 1.0)
        self.pageControl.addTarget(self, action: #selector(StickerPickView.changePage(_:)), for: UIControlEvents.valueChanged)
        self.addSubview(pageControl)
    }
    
    private func configureTabView(emojiOnly: Bool) {
        stickerTabView = StickerTabView(frame: CGRect(x: 0, y: 231, width: self.frame.width, height: 40), emojiOnly: emojiOnly)
        let border = UIView(frame: CGRect(x: 0, y: 230, width: self.frame.width, height: 1))
        border.backgroundColor = UIColor._210210210()
        self.addSubview(border)
        self.addSubview(stickerTabView)
    }
    
    // create an ablum with the name and add images into it
    private func prepareAlbum(_ view : StickerScrollView, name : String) {
        if name != "faeEmoji" {
            view.createNewAlbums(name: name, row: 2, col: 4)
        } else {
            view.createNewAlbums(name: name, row: 4, col: 7)
            view.currentAlbum = view.currentAlbum ?? view.arrStickerAlbums.last!
        }
        if let images = StickerInfoStrcut.stickerDictionary[name] {
            for image in images {
                view.appendNewImage(image)
            }
        }
        StickerInfoStrcut.pageNumDictionary[name] = max(view.arrStickerAlbums.last!.intPageNumber , 1)
        view.arrStickerAlbums.last!.findStickerDelegate = self
    }
    
    // call this method after all the album is created and populated
    private func attachButton(_ view : StickerScrollView) {
        assert(view.arrStickerAlbums.count > 0, "call this method after all the album is created and populated")
        view.attachButton()
    }
    
    // MARK: SwitchStickerDelegate
    /// switch to specific sticker
    ///
    /// - Parameter index: the index of the tab in all tabs
    func switchSticker(_ index: Int) {
        if index > 0 && index <= currentScrollView.arrStickerAlbums.count {
            scrollToPage(currentScrollView.arrStickerAlbums[index - 1].intBasePage )
            currentScrollView.currentAlbum = currentScrollView.arrStickerAlbums[index - 1]
            updatePageControl()
        }
    }

    // MARK: findStickerFromDictDelegate
    /// send the sticker selected out
    ///
    /// - Parameters:
    ///   - album: the name of the album
    ///   - index: the index of the sticker in the album
    func sendSticker(album: String, index : Int) {
        if let albumSet = StickerInfoStrcut.stickerDictionary[album] {
            if album == "faeEmoji" {
                sendStickerDelegate?.appendEmojiWithImageName(albumSet[index])
            } else {
                print("the name of sticker is : \(albumSet[index])")
                sendStickerDelegate?.sendStickerWithImageName(albumSet[index])
            }
        } else {
            print("cannot find that image")
        }
    }
    
    func deleteEmoji() {
        sendStickerDelegate.deleteEmoji()
    }
    
    // MARK: scroll
    private func scrollToPage(_ index: Int) {
        currentScrollView.contentOffset.x = screenWidth * CGFloat(index)
    }
    
    // use this to check when the scrolling stop then adjust pagecontrol and tab
    func scrollViewDidEndDecelerating(_ scrollView: UIScrollView) {
        let pages = currentScrollView.currentAlbum.intBasePage
        let baseOffset = CGFloat(pages) * screenWidth
        let page = Int(round((currentScrollView.contentOffset.x - baseOffset) / currentScrollView.frame.size.width))
        if page < 0 {
            if !boolInEmojiOnlyMode {
                let currentName = currentScrollView.currentAlbum.strAlbumName
                self.currentScrollView.currentAlbum = self.currentScrollView.arrStickerAlbums[StickerInfoStrcut.stickerIndex.index(of: currentName)! - 1]
                updatePageControl()
                stickerTabView.updateTabIndicator(stickerTabView.tabButtons[StickerInfoStrcut.stickerIndex.index(of: currentName)!])
            } else {
                pageControl.currentPage = 0
            }
        } else if page >= pageControl.numberOfPages {
            if !boolInEmojiOnlyMode {
                let currentName = currentScrollView.currentAlbum.strAlbumName
                self.currentScrollView.currentAlbum = self.currentScrollView.arrStickerAlbums[StickerInfoStrcut.stickerIndex.index(of: currentName)! + 1]
                updatePageControl()
                stickerTabView.updateTabIndicator(stickerTabView.tabButtons[StickerInfoStrcut.stickerIndex.index(of: currentName)! + 2])
            } else {
                pageControl.currentPage = pageControl.numberOfPages - 1
            }
        } else {
            pageControl.currentPage = page
        }
    }
    
    // MARK: sticker usage history related
    // make local storage to record history in map, to count the frequency.
    private func loadHistoryFromStorage() {
        let defaults = UserDefaults.standard
        if defaults.object(forKey: "stickerHistory") == nil {
            defaults.set([String : Int](), forKey: "stickerHistory")
            print("set a empty dictionary")
        }
        let stickerHistory = defaults.dictionary(forKey: "stickerHistory") as! [String : Int]
        dictHistory = stickerHistory
        StickerInfoStrcut.stickerDictionary["stickerHistory"] = dictHistory.keysSortedByValue(>)
    }
    
    func updateStickerHistory(_ imageName : String) {
        if dictHistory[imageName] != nil {
            dictHistory[imageName] = dictHistory[imageName]! + 1
        } else {
            dictHistory[imageName] = 1
        }
        let defaults = UserDefaults.standard
        defaults.set(dictHistory, forKey: "stickerHistory")
        StickerInfoStrcut.stickerDictionary["stickerHistory"] = dictHistory.keysSortedByValue(>)
        reloadHistory()
    }
    
    private func reloadHistory() {
        let currentSize = currentScrollView.contentSize
        let currentName = currentScrollView.currentAlbum.strAlbumName
        currentScrollView.clearButton()
        for stickerName in StickerInfoStrcut.stickerIndex {
            prepareAlbum(currentScrollView, name: stickerName)
        }
        currentScrollView.currentAlbum = currentScrollView.getAlbum(withName: currentName)
        attachButton(currentScrollView)
        if currentScrollView.contentSize != currentSize {
            currentScrollView.contentOffset.x += screenWidth
        }
    }
    
    //MARK: page control
    private func updatePageControl() {
        if pageControl != nil {
            pageControl.removeFromSuperview()
        }
        pageControl = nil
        configurePageController()
        let pages = currentScrollView.currentAlbum.intBasePage
        let baseOffset = CGFloat(pages) * screenWidth
        pageControl.currentPage = Int(round((currentScrollView.contentOffset.x - baseOffset) / currentScrollView.frame.size.width))
    }
    
    // TO CHANGE the page WHILE CLICKING ON PAGE CONTROL
    @objc private func changePage(_ sender: AnyObject) -> () {
        let x = pageControl.currentPage + currentScrollView.currentAlbum.intBasePage
        scrollToPage(_: x)
    }
}

// this extention is used to sort key value pair by value
extension Dictionary {
    func sortedKeys(_ isOrderedBefore:(Key,Key) -> Bool) -> [Key] {
        return Array(self.keys).sorted(by: isOrderedBefore)
    }
    // Faster because of no lookups, may take more memory because of duplicating contents
    func keysSortedByValue(_ isOrderedBefore:(Value, Value) -> Bool) -> [Key] {
        return Array(self)
            .sorted() {
                let (_, lv) = $0
                let (_, rv) = $1
                return isOrderedBefore(lv, rv)
            }
            .map {
                let (k, _) = $0
                return k
            }
    }
}
