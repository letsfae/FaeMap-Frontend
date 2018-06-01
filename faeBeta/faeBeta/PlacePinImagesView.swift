//
//  PlacePinImagesView.swift
//  faeBeta
//
//  Created by Yue Shen on 5/31/18.
//  Copyright © 2018 fae. All rights reserved.
//

import UIKit

class PlacePinImagesView: UIScrollView, UIScrollViewDelegate {
    
    var viewObjects = [UIView]()
    var numPages: Int = 0
    var pageControl: UIPageControl?
    var currentPage = 0
    public var arrURLs = [String]()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        isPagingEnabled = true
        showsVerticalScrollIndicator = false
        showsHorizontalScrollIndicator = false
        delegate = self
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
    
    public func loadContent() {
        
        guard arrURLs.count > 0 else {
            let subView = UIImageView(frame: frame)
            subView.image = #imageLiteral(resourceName: "default_place")
            subView.contentMode = .scaleAspectFill
            subView.clipsToBounds = true
            viewObjects.append(subView)
            return
        }
        
        for index in 0..<arrURLs.count {
            let subView = UIImageView(frame: frame)
            subView.contentMode = .scaleAspectFill
            subView.clipsToBounds = true
            viewObjects.append(subView)
            General.shared.downloadImageForView(url: arrURLs[index], imgPic: subView) {
                
            }
        }
    }
    
    public func setup() {
        guard let parent = superview else { return }
        guard arrURLs.count > 0 else {
            numPages = 1
            loadScrollViewWithPage(0)
            return
        }
        
        contentSize = CGSize(width: (frame.size.width * (CGFloat(numPages) + 2)), height: frame.size.height)
        
        pageControl = UIPageControl(frame: CGRect(x: 0, y: frame.size.height-25, width: frame.size.width, height: 25))
        pageControl?.numberOfPages = numPages
        pageControl?.currentPage = 0
//        pageControl?.addTarget(self, action: Selector(("changePage:")), for: .touchDown)
        pageControl?.isUserInteractionEnabled = false
        parent.addSubview(pageControl!)
        
        loadScrollViewWithPage(0)
        loadScrollViewWithPage(1)
        loadScrollViewWithPage(2)
        
        var newFrame = frame
        newFrame.origin.x = newFrame.size.width
        newFrame.origin.y = 0
        scrollRectToVisible(newFrame, animated: false)
        
        layoutIfNeeded()
    }

    private func loadScrollViewWithPage(_ page: Int) {
        if page < 0 { return }
        if page >= numPages + 2 { return }
        
        var index = 0
        
        if page == 0 {
            index = numPages - 1
        } else if page == numPages + 1 {
            index = 0
        } else {
            index = page - 1
        }
        
        let view = viewObjects[index]
        
        var newFrame = frame
        newFrame.origin.x = frame.size.width * CGFloat(page)
        newFrame.origin.y = 0
        view.frame = newFrame
        
        if view.superview == nil {
            addSubview(view)
        }
        
        layoutIfNeeded()
    }
    
    // MARK: - UIScrollView Delegate
    
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        let pageWidth = frame.size.width
        let page = floor((contentOffset.x - (pageWidth/2)) / pageWidth) + 1
        pageControl?.currentPage = Int(page - 1)
        currentPage = Int(page - 1)
        loadScrollViewWithPage(Int(page - 1))
        loadScrollViewWithPage(Int(page))
        loadScrollViewWithPage(Int(page + 1))
    }
    
    func scrollViewDidEndDecelerating(_ scrollView: UIScrollView) {
        let pageWidth = frame.size.width
        let page : Int = Int(floor((contentOffset.x - (pageWidth/2)) / pageWidth) + 1)
        
        if page == 0 {
            contentOffset = CGPoint(x: pageWidth*(CGFloat(numPages)), y: 0)
        } else if page == numPages+1 {
            contentOffset = CGPoint(x: pageWidth, y: 0)
        }
    }
}
