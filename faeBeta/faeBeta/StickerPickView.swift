//
//  StickerPickView.swift
//  quickChat
//
//  Created by User on 7/21/16.
//  Copyright © 2016 User. All rights reserved.
//

import Foundation

// this delegate is used to tell chatVC the name of sticker being send.

protocol SendStickerDelegate {
    func sendStickerWithImageName(_ name : String)
}

// this class is used to show all content in sticker part. It has tab view to switch set of sticker,
// scroll view to show set of sticker, page controller to show current page.

class StickerPickView: UIView, SwitchStickerDelegate, UIScrollViewDelegate, findStickerFromDictDelegate {
    
    var pageControl : UIPageControl!
    var stickerTabView : StickerTabView!
    //a tab view to controll the stickerScrollView and the stickerFixView
    var currentScrollView : StickerScrollView!
    //a pointer to point which view we need to display.
    
    var sendStickerDelegate : SendStickerDelegate!
    
    var historyDict : [String : Int]!
    //most recently stick sorted by frequently and show in the second stickTabView
    override init(frame : CGRect) {
        super.init(frame: frame)
        self.backgroundColor = UIColor(red: 246 / 255, green: 246 / 255, blue: 246 / 255, alpha: 1.0)//gray color
        configureHistoryPage()
        configureScrollView()
        configurePageController()
        configureTabView()
        stickerTabView.switcher = self
        currentScrollView.delegate = self

        switchSticker(3)
        
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    
    func configureScrollView() {
        var index = 0
        let view = StickerScrollView(frame: CGRect(x: 0, y: 0, width: self.frame.width, height: 195)) //fixed high for every screen

        for stickerName in stickerIndex {
            index += 1
            prepareAlbum(view, name: stickerName)
        }
        attachButton(view)
        currentScrollView = view
        self.addSubview(view)
    }
    
    func configureHistoryPage() {
        loadHistoryFromStorage()
//        print("the images is \(stickerDictionary["history"])")
//        print("the dict is \(historyDict)")
    }
    
    func configurePageController() {
        self.pageControl = UIPageControl(frame: CGRect(x: 0, y: 209, width: self.frame.width, height: 8))
        self.pageControl.numberOfPages = currentScrollView.currentAlbum.pageNumber
        self.pageControl.currentPage = 0
        self.pageControl.pageIndicatorTintColor = UIColor(red: 182 / 255, green: 182 / 255, blue: 182 / 255, alpha: 1.0)
        self.pageControl.currentPageIndicatorTintColor = UIColor(red: 249 / 255, green: 90 / 255, blue: 90 / 255, alpha: 1.0)
        self.pageControl.backgroundColor = UIColor(red: 246 / 255, green: 246 / 255, blue: 246 / 255, alpha: 1.0)
        self.pageControl.addTarget(self, action: #selector(StickerPickView.changePage(_:)), for: UIControlEvents.valueChanged)
        self.addSubview(pageControl)
    }
    
    func configureTabView() {
        stickerTabView = StickerTabView(frame: CGRect(x: 0, y: 231, width: self.frame.width, height: 40))
        self.addSubview(stickerTabView)
    }
    
    func prepareAlbum(_ view : StickerScrollView, name : String) {
        if(name != "faeEmoji"){
            view.createNewAlbums(name: name, row: 2, col: 4)
        }else{
            view.createNewAlbums(name: name, row: 4, col: 7)
            view.currentAlbum = view.currentAlbum ?? view.stickerAlbums.last!
        }
        if let images = stickerDictionary[name] {
            for image in images {
                view.appendNewImage(image)
            }
        }
        pageNumDictionary[name] = max(view.stickerAlbums.last!.pageNumber , 1)
        view.stickerAlbums.last!.findStickerDelegate = self
    }
    
    func attachButton(_ view : StickerScrollView) {
        view.attachButton()
    }
    
    // MARK : TO CHANGE WHILE CLICKING ON PAGE CONTROL
    func changePage(_ sender: AnyObject) -> () {
        let x = CGFloat(pageControl.currentPage) * currentScrollView.frame.size.width
        currentScrollView.setContentOffset(CGPoint(x: x, y: 0), animated: true)
    }
    
    func switchSticker(_ index: Int) {
        if(index > 0 && index <= currentScrollView.stickerAlbums.count){
            scrollToPage(currentScrollView.stickerAlbums[index - 1].basePages )
            currentScrollView.currentAlbum = currentScrollView.stickerAlbums[index - 1]
            updatePageControl()
        }
    }
    
    func switchToHeader(_ index: Int) {
//        currentScrollView.removeFromSuperview()
//        currentScrollView = stickerScrollViews[index]
//        self.addSubview(currentScrollView)
//        pageControl.removeFromSuperview()
//        pageControl = nil
//        configurePageController()
//        pageControl.currentPage = Int(round(currentScrollView.contentOffset.x / currentScrollView.frame.size.width))
    }
    
    func scrollToPage(_ index: Int)
    {
        currentScrollView.contentOffset.x = screenWidth * CGFloat(index)
    }
    
    func scrollViewDidEndDecelerating(_ scrollView: UIScrollView) {
        let pages = currentScrollView.currentAlbum.basePages
        let baseOffset = CGFloat(pages) * screenWidth
        let page = Int(round((currentScrollView.contentOffset.x - baseOffset) / currentScrollView.frame.size.width))
        if(page < 0){
            let currentName = currentScrollView.currentAlbum.albumName
            self.currentScrollView.currentAlbum = self.currentScrollView.stickerAlbums[stickerIndex.index(of: currentName)! - 1]
            updatePageControl()
            stickerTabView.updateTabIndicator(stickerTabView.tabButtons[stickerIndex.index(of: currentName)!])
        }else if (page >= pageControl.numberOfPages){
            let currentName = currentScrollView.currentAlbum.albumName
            self.currentScrollView.currentAlbum = self.currentScrollView.stickerAlbums[stickerIndex.index(of: currentName)! + 1]
            updatePageControl()
            stickerTabView.updateTabIndicator(stickerTabView.tabButtons[stickerIndex.index(of: currentName)! + 2])
        }else{
            pageControl.currentPage = page
        }
    }
    
    func sendSticker(album: String, index : Int) {
        if let albumSet = stickerDictionary[album] {
            print("the name of sticker is : \(albumSet[index])")
            sendStickerDelegate.sendStickerWithImageName(albumSet[index])
        } else {
            print("cannot find that image")
        }
    }
    
    //make local storage to record history in map, to count the frequency.
    
    func loadHistoryFromStorage() {
        let defaults = UserDefaults.standard
        if defaults.object(forKey: "stickerHistory") == nil {
            defaults.set([String : Int](), forKey: "stickerHistory")
            print("set a empty dictionary")
        }
        let stickerHistory = defaults.dictionary(forKey: "stickerHistory") as! [String : Int]
        historyDict = stickerHistory
        stickerDictionary["stickerHistory"] = historyDict.keysSortedByValue(>)
    }
    
    func updateStickerHistory(_ imageName : String) {
        if (historyDict[imageName] != nil) {
            historyDict[imageName] = historyDict[imageName]! + 1
        } else {
            historyDict[imageName] = 1
        }
        let defaults = UserDefaults.standard
        defaults.set(historyDict, forKey: "stickerHistory")
        stickerDictionary["stickerHistory"] = historyDict.keysSortedByValue(>)
        reloadHistory()
    }
    
    func reloadHistory() {
        let currentSize = currentScrollView.contentSize
        let currentName = currentScrollView.currentAlbum.albumName
        currentScrollView.clearButton()
        for stickerName in stickerIndex {
            prepareAlbum(currentScrollView, name: stickerName)
        }
        currentScrollView.currentAlbum = currentScrollView.getAlbum(withName: currentName)
        attachButton(currentScrollView)
        if(currentScrollView.contentSize != currentSize){
            currentScrollView.contentOffset.x += screenWidth
        }
    }
    
    func updatePageControl()
    {
        if(pageControl != nil){
            pageControl.removeFromSuperview()
        }
        pageControl = nil
        configurePageController()
        let pages = currentScrollView.currentAlbum.basePages
        let baseOffset = CGFloat(pages) * screenWidth
        pageControl.currentPage = Int(round((currentScrollView.contentOffset.x - baseOffset) / currentScrollView.frame.size.width))
    }
}


//this extention is used to sort key value pair by value
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

