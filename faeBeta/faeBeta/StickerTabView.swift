//
//  StickerTabView.swift
//  quickChat
//
//  Created by User on 7/19/16.
//  Copyright © 2016 User. All rights reserved.
//

import Foundation

// this delegate is used to switch between scroll views
protocol SwitchStickerDelegate: class {
    func switchSticker(_ index : Int)
}

class StickerTabView: UIView {
    
    //MARK: - properties
    private var cellWidth : CGFloat = 44.5
    private var buttonLength : CGFloat = 28
//    var headGroupImageName = ["stickerMore", "stickerRecent", "stickerLike"]
    private var headGroupImageName = [String]()
    private var headView : UIView!
    private var scrollView : UIScrollView!
    private var tabIndicator : UIView!
    private var tabframe: CGRect!
    
    private(set) var tabButtons = [UIButton]()
    
    weak var switcher : SwitchStickerDelegate!
    
    //MARK: - init
    override init(frame : CGRect) {
        super.init(frame: frame)
        tabframe = frame
        self.backgroundColor = UIColor.white
        configureTabIndicator()
        configureHeadGroupView()
        configureScrollView()
        headView.addSubview(tabIndicator)
    }
    
    init (frame : CGRect, emojiOnly: Bool)
    {
        super.init(frame : frame)
        if(!emojiOnly){
            tabframe = frame
            self.backgroundColor = UIColor.white
            configureTabIndicator()
            configureHeadGroupView()
            configureScrollView()
            headView.addSubview(tabIndicator)
        }else{
            tabframe = frame
            self.backgroundColor = UIColor.white
            configureTabIndicator()
            configureHeadGroupView()
            configureScrollViewLite()
            headView.addSubview(tabIndicator)
        }
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    //MARK: - Setup
    private func configureHeadGroupView() {
        headView = UIView(frame: CGRect(x: 0, y: 0, width: 135, height: tabframe.height))
        var x : CGFloat = 8
        let y : CGFloat = 6
        for name in headGroupImageName {
            let imageView = UIImageView(frame: CGRect(x: x, y: y, width: buttonLength, height: buttonLength))
            imageView.image = UIImage(named: name)
            imageView.contentMode = .scaleAspectFit
            let button = UIButton(frame: CGRect(x: x, y: y, width: buttonLength, height: buttonLength))
            button.setTitle("", for: UIControlState())
//            button.addTarget(self, action: #selector(groupButtonClicked), for: .touchUpInside)
            headView.addSubview(imageView)
            headView.addSubview(button)
            x += cellWidth - 8
            let line = UIView(frame: CGRect(x: x, y: y, width: 1, height: buttonLength))
            line.backgroundColor = UIColor(red: 230 / 255, green: 230 / 255, blue: 230 / 255, alpha: 1.0)
            headView.addSubview(line)
            x += (cellWidth - buttonLength) / 2
        }
        self.addSubview(headView)
    }
    
    //Emoji Only
    private func configureScrollViewLite()
    {
        scrollView = UIScrollView(frame: CGRect(x: 0, y: 0, width: 375, height: tabframe.height))
        var x : CGFloat = 8
        let y : CGFloat = 6
        var newStickerIndex = [String]()
        newStickerIndex.insert("faeEmoji", at: 0)
        for name in newStickerIndex {
            let imageView = UIImageView(frame: CGRect(x: x, y: y, width: buttonLength, height: buttonLength))
            imageView.image = UIImage(named: name)
            imageView.contentMode = .scaleAspectFit
            let button = UIButton(frame: CGRect(x: x, y: y, width: buttonLength, height: buttonLength))
            button.setTitle("", for: UIControlState())
            button.addTarget(self, action: #selector(scrollGroupClicked), for: .touchUpInside)
            scrollView.addSubview(imageView)
            scrollView.addSubview(button)
            tabButtons.append(button)
            x += cellWidth - 8
            let line = UIView(frame: CGRect(x: x, y: y, width: 1, height: buttonLength))
            line.backgroundColor = UIColor(red: 230 / 255, green: 230 / 255, blue: 230 / 255, alpha: 1.0)
            scrollView.addSubview(line)
            x += (cellWidth - buttonLength) / 2
        }
        scrollView.contentSize = CGSize(width: CGFloat(45 * StickerInfoStrcut.stickerIndex.count), height: scrollView.frame.height)
        scrollView.addSubview(tabIndicator)
        self.addSubview(scrollView)
    }
    
    private func configureScrollView()
    {
        scrollView = UIScrollView(frame: CGRect(x: 0, y: 0, width: 375, height: tabframe.height))
        var x : CGFloat = 8
        let y : CGFloat = 6
        var newStickerIndex = StickerInfoStrcut.stickerIndex
        newStickerIndex.insert("stickerMore", at: 0)
        
        for name in newStickerIndex {
            let imageView = UIImageView(frame: CGRect(x: x, y: y, width: buttonLength, height: buttonLength))
            imageView.image = UIImage(named: name)
            imageView.contentMode = .scaleAspectFit
            let button = UIButton(frame: CGRect(x: x, y: y, width: buttonLength, height: buttonLength))
            button.setTitle("", for: UIControlState())
            button.addTarget(self, action: #selector(scrollGroupClicked), for: .touchUpInside)
            scrollView.addSubview(imageView)
            scrollView.addSubview(button)
            tabButtons.append(button)
            x += cellWidth - 8
            let line = UIView(frame: CGRect(x: x, y: y, width: 1, height: buttonLength))
            line.backgroundColor = UIColor(red: 230 / 255, green: 230 / 255, blue: 230 / 255, alpha: 1.0)
            scrollView.addSubview(line)
            x += (cellWidth - buttonLength) / 2
        }
        scrollView.contentSize = CGSize(width: CGFloat(45 * StickerInfoStrcut.stickerIndex.count), height: scrollView.frame.height)
        scrollView.addSubview(tabIndicator)
        self.addSubview(scrollView)
    }
    
    private func configureTabIndicator() {
        tabIndicator = UIView(frame: CGRect(x: 0, y: 37, width: 44, height: 3))
        tabIndicator.backgroundColor = UIColor(red: 249 / 255, green: 90 / 255, blue: 90 / 255, alpha: 1.0)
    }
    
    // MARK: - helper
    /// When the tab button is clicked
    ///
    /// - Parameter sender: the tab clicked
    @objc private func scrollGroupClicked(_ sender : UIButton) {
        updateTabIndicator(sender)
        let xOffset = tabIndicator.frame.origin.x
        switcher?.switchSticker(Int(xOffset / cellWidth))
    }
    
    func updateTabIndicator(_ sender: UIButton)
    {
        tabIndicator.removeFromSuperview()
        tabIndicator.frame.origin = CGPoint(x: sender.frame.origin.x - (cellWidth - buttonLength) / 2, y: 37)
        tabIndicator.isHidden = false
        scrollView.addSubview(tabIndicator)
    }
    
}
