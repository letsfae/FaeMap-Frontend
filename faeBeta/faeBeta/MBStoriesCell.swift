////
////  MBStoriesCell.swift
////  FaeMapBoard
////
////  Created by vicky on 4/12/17.
////  Copyright © 2017 Yue. All rights reserved.
////
//
//import UIKit
//
//class MBStoriesCell: MBComtsStoriesCell, UIScrollViewDelegate {
//
//    var scrollViewMedia: UIScrollView!
//    var imgMediaArr = [UIImageView]()
//    
//    override func loadCellContent() {
//        super.loadCellContent()
//        
//        scrollViewMedia = UIScrollView()
//        scrollViewMedia.delegate = self
//        scrollViewMedia.isScrollEnabled = true
//        scrollViewMedia.backgroundColor = .clear
//        scrollViewMedia.showsHorizontalScrollIndicator = false
//        addSubview(scrollViewMedia)
//        var insets = scrollViewMedia.contentInset
//        insets.left = 15
//        insets.right = 15
//        scrollViewMedia.contentInset = insets
//        scrollViewMedia.scrollToLeft(animated: false)
//        //        scrollViewMedia.backgroundColor = UIColor.blue
//        
//        addConstraintsWithFormat("H:|-0-[v0]-0-|", options: [], views: scrollViewMedia)
//        addConstraintsWithFormat("V:|-15-[v0(50)]-10-[v1]-12-[v2(95)]-12-[v3(32)]-17-[v4(27)]-10-|", options: [], views: imgAvatar, lblContent, scrollViewMedia, btnLoc, uiviewCellFooter)
//    }
//    
//}
