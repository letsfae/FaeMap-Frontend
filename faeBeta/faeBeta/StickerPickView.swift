//
//  StickerPickView.swift
//  quickChat
//
//  Created by User on 7/21/16.
//  Copyright © 2016 User. All rights reserved.
//

import Foundation

protocol SendStickerDelegate {
    func sendStickerWithImageName(name : String)
}

class StickerPickView: UIView, SwitchStickerDelegate, UIScrollViewDelegate, findStickerFromDictDelegate {
    
    var stickerScrollViews = [StickerScrollView]()
    var stickerFixView = [StickerScrollView]()
    
    var pageControl : UIPageControl!
    var stickerTabView : StickerTabView!
    var currentScrollView : StickerScrollView!
    
    var sendStickerDelegate : SendStickerDelegate!
    
    var historyDict : [String : Int]!
    
    override init(frame : CGRect) {
        super.init(frame: frame)
        self.backgroundColor = UIColor(red: 246 / 255, green: 246 / 255, blue: 246 / 255, alpha: 1.0)
        configureHistoryPage()
        configureScrollView()
        configurePageController()
        configureTabView()
        stickerTabView.switcher = self
        for stickerView in stickerScrollViews {
            stickerView.delegate = self
            stickerView.stickerAlbum.findStickerDelegate = self
        }
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    
    func configureScrollView() {
        for stickerName in stickerIndex {
            let view = StickerScrollView(frame: CGRect(x: 0, y: 0, width: self.frame.width, height: 195))
            prepareAlbum(view, name: stickerName)
            attachButton(view)
            stickerScrollViews.append(view)
        }
        currentScrollView = stickerScrollViews[3]
        self.addSubview(currentScrollView)
    }
    
    func configureHistoryPage() {
        loadHistoryFromStorage()
        print("the images is \(stickerDictionary["history"])")
        print("the dict is \(historyDict)")
    }
    
    func configurePageController() {
        self.pageControl = UIPageControl(frame: CGRect(x: 0, y: 209, width: self.frame.width, height: 8))
        self.pageControl.numberOfPages = currentScrollView.stickerAlbum.pageNumber
        self.pageControl.currentPage = 0
        self.pageControl.pageIndicatorTintColor = UIColor(red: 182 / 255, green: 182 / 255, blue: 182 / 255, alpha: 1.0)
        self.pageControl.currentPageIndicatorTintColor = UIColor(red: 249 / 255, green: 90 / 255, blue: 90 / 255, alpha: 1.0)
        self.pageControl.backgroundColor = UIColor(red: 246 / 255, green: 246 / 255, blue: 246 / 255, alpha: 1.0)
        self.pageControl.addTarget(self, action: Selector("changePage:"), forControlEvents: UIControlEvents.ValueChanged)
        self.addSubview(pageControl)
    }
    
    func configureTabView() {
        stickerTabView = StickerTabView(frame: CGRect(x: 0, y: 231, width: self.frame.width, height: 40))
        self.addSubview(stickerTabView)
    }
    
    func prepareAlbum(view : StickerScrollView, name : String) {
        if let images = stickerDictionary[name] {
            for image in images {
                view.appendNewImage(image)
            }
        }
    }
    
    func attachButton(view : StickerScrollView) {
        view.attachButton()
    }
    
    // MARK : TO CHANGE WHILE CLICKING ON PAGE CONTROL
    func changePage(sender: AnyObject) -> () {
        let x = CGFloat(pageControl.currentPage) * currentScrollView.frame.size.width
        currentScrollView.setContentOffset(CGPointMake(x, 0), animated: true)
    }
    
    func switchSticker(index: Int) {
        currentScrollView.removeFromSuperview()
        currentScrollView = stickerScrollViews[index]
        self.addSubview(currentScrollView)
        pageControl.removeFromSuperview()
        pageControl = nil
        configurePageController()
        pageControl.currentPage = Int(round(currentScrollView.contentOffset.x / currentScrollView.frame.size.width))
    }
    
    func switchToHeader(index: Int) {
        currentScrollView.removeFromSuperview()
        currentScrollView = stickerFixView[index]
        self.addSubview(currentScrollView)
        pageControl.removeFromSuperview()
        pageControl = nil
        configurePageController()
        pageControl.currentPage = Int(round(currentScrollView.contentOffset.x / currentScrollView.frame.size.width))
    }
    
    func scrollViewDidEndDecelerating(scrollView: UIScrollView) {
        let pageNumber = round(scrollView.contentOffset.x / scrollView.frame.size.width)
        pageControl.currentPage = Int(pageNumber)
    }
    
    func findAlbumName() -> String {
        for i in 0..<stickerScrollViews.count {
            if stickerScrollViews[i] == currentScrollView {
                print("the name of album is : \(stickerIndex[i])")
                return stickerIndex[i]
            }
        }
        return ""
    }
    
    func findStickerName(index : Int) {
        let albumName = findAlbumName()
        if let albumSet = stickerDictionary[albumName] {
            print("the name of sticker is : \(albumSet[index])")
            sendStickerDelegate.sendStickerWithImageName(albumSet[index])
        } else {
            print("cannot find that image")
        }
    }
    
    func loadHistoryFromStorage() {
        let defaults = NSUserDefaults.standardUserDefaults()
        if defaults.objectForKey("stickerHistory") == nil {
            defaults.setObject([String : Int](), forKey: "stickerHistory")
            print("set a empty dictionary")
        }
        let stickerHistory = defaults.dictionaryForKey("stickerHistory") as! [String : Int]
        historyDict = stickerHistory
        stickerDictionary["stickerHistory"] = historyDict.keysSortedByValue(>)
    }
    
    func updateStickerHistory(imageName : String) {
        if (historyDict[imageName] != nil) {
            historyDict[imageName] = historyDict[imageName]! + 1
        } else {
            historyDict[imageName] = 1
        }
        let defaults = NSUserDefaults.standardUserDefaults()
        defaults.setObject(historyDict, forKey: "stickerHistory")
        stickerDictionary["stickerHistory"] = historyDict.keysSortedByValue(>)
    }
    
    func reloadHistory() {
        let historyView = stickerFixView[1]
        historyView.stickerAlbum.clearAll()
        prepareAlbum(historyView, name: "stickerHistory")
        attachButton(historyView)
    }
}

extension Dictionary {
    func sortedKeys(isOrderedBefore:(Key,Key) -> Bool) -> [Key] {
        return Array(self.keys).sort(isOrderedBefore)
    }
    // Faster because of no lookups, may take more memory because of duplicating contents
    func keysSortedByValue(isOrderedBefore:(Value, Value) -> Bool) -> [Key] {
        return Array(self)
            .sort() {
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

