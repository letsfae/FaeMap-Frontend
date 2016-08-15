//
//  MapMainScreenSearch.swift
//  faeBeta
//
//  Created by Yue on 8/9/16.
//  Copyright © 2016 fae. All rights reserved.
//

import UIKit

//MARK: main screen search
extension FaeMapViewController {
    
    func loadMainScreenSearch() {
        let blurEffect = UIBlurEffect(style: UIBlurEffectStyle.Light)
        blurViewMainScreenSearch = UIVisualEffectView(effect: blurEffect)
        blurViewMainScreenSearch.frame = CGRectMake(0, 0, screenWidth, screenHeight)
        blurViewMainScreenSearch.alpha = 0.0
        UIApplication.sharedApplication().keyWindow?.addSubview(blurViewMainScreenSearch)
        mainScreenSearchSubview = UIButton(frame: blurViewMainScreenSearch.frame)
        UIApplication.sharedApplication().keyWindow?.addSubview(mainScreenSearchSubview)
        mainScreenSearchSubview.hidden = true
        mainScreenSearchSubview.addTarget(self, action: #selector(FaeMapViewController.animationMainScreenSearchHide(_:)), forControlEvents: UIControlEvents.TouchUpInside)
        self.blurViewMainScreenSearch.alpha = 0.0
    }
    
    func animationMainScreenSearchShow(sender: UIButton!) {
        self.mainScreenSearchActive = true
        self.searchBarSubview.hidden = false
        self.tblSearchResults.hidden = false
        self.uiviewTableSubview.hidden = false
        self.searchBarSubview.alpha = 0.0
        self.tblSearchResults.alpha = 0.0
        self.uiviewTableSubview.alpha = 0.0
        self.middleTopActive = true
        self.mainScreenSearchSubview.hidden = false
        UIView.animateWithDuration(0.25, animations: ({
            self.searchBarSubview.alpha = 1.0
            self.tblSearchResults.alpha = 1.0
            self.uiviewTableSubview.alpha = 1.0
        }))
    }
    
    func animationMainScreenSearchHide(sender: UIButton!) {
        self.customSearchController.customSearchBar.endEditing(true)
        self.mainScreenSearchSubview.hidden = true
        self.middleTopActive = false
        UIView.animateWithDuration(0.25, animations: ({
            self.blurViewMainScreenSearch.alpha = 0.0
            self.searchBarSubview.alpha = 0.0
            self.tblSearchResults.alpha = 0.0
            self.uiviewTableSubview.alpha = 0.0
        }), completion: { (done: Bool) in
            if done {
                self.searchBarSubview.hidden = true
                self.tblSearchResults.hidden = true
                self.uiviewTableSubview.hidden = true
                self.mainScreenSearchActive = false
                self.customSearchController.customSearchBar.text = ""
            }
        })
    }
    
}
