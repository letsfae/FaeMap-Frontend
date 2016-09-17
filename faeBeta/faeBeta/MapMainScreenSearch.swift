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
        loadMainSearchController()
    }
    
    func loadMainSearchController() {
        mainScreenSearchBarSubview = UIView(frame: CGRectMake(0, -5, screenWidth, 64))
        UIApplication.sharedApplication().keyWindow?.addSubview(mainScreenSearchBarSubview)
        
        mainSearchController = CustomSearchController(searchResultsController: self, searchBarFrame: CGRectMake(0, 25, screenWidth, 38), searchBarFont: UIFont(name: "AvenirNext-Medium", size: 20)!, searchBarTextColor: UIColor(red: 89/255, green: 89/255, blue: 89/255, alpha: 1.0), searchBarTintColor: UIColor.whiteColor())
        mainSearchController.customSearchBar.placeholder = "Search Fae Map                             "
        mainSearchController.customDelegate = self
        mainSearchController.customSearchBar.layer.borderWidth = 2.0
        mainSearchController.customSearchBar.layer.borderColor = UIColor.whiteColor().CGColor
        mainSearchController.customSearchBar.setImage(nil, forSearchBarIcon: UISearchBarIcon.Search, state: .Normal)
        
        mainScreenSearchBarSubview.addSubview(mainSearchController.customSearchBar)
        mainScreenSearchBarSubview.backgroundColor = UIColor.whiteColor()
        
        mainScreenSearchBarSubview.layer.borderColor = UIColor.whiteColor().CGColor
        mainScreenSearchBarSubview.layer.borderWidth = 1.0
        mainScreenSearchBarSubview.layer.cornerRadius = 2.0
        
        mainScreenSearchBarSubview.hidden = true
        
        buttonClearMainSearch = UIButton(frame: CGRectMake(375, 30.44, 22, 22))
        let buttonClearSubview = UIView(frame: CGRectMake(375, 30.44, 30, 22))
        buttonClearSubview.backgroundColor = UIColor.whiteColor()
        mainScreenSearchBarSubview.addSubview(buttonClearSubview)
        buttonClearMainSearch.setImage(UIImage(named: "clearMainSearch"), forState: .Normal)
        mainScreenSearchBarSubview.addSubview(buttonClearMainSearch)
    }
    
    func animationMainScreenSearchShow(sender: UIButton!) {
        self.mainSearchController.customSearchBar.becomeFirstResponder()
        self.mainScreenSearchActive = true
        self.mainScreenSearchBarSubview.hidden = false
        self.mainScreenSearchBarSubview.alpha = 0.0
        self.middleTopActive = true
        self.mainScreenSearchSubview.hidden = false
        UIView.animateWithDuration(0.25, animations: ({
            self.blurViewMainScreenSearch.alpha = 1.0
            self.mainScreenSearchBarSubview.alpha = 1.0
        }))
    }
    
    func animationMainScreenSearchHide(sender: UIButton!) {
        self.mainSearchController.customSearchBar.endEditing(true)
        self.mainScreenSearchSubview.hidden = true
        self.middleTopActive = false
        UIView.animateWithDuration(0.25, animations: ({
            self.blurViewMainScreenSearch.alpha = 0.0
            self.mainScreenSearchBarSubview.alpha = 0.0
            
        }), completion: { (done: Bool) in
            if done {
                self.mainScreenSearchBarSubview.hidden = true
                
                self.mainScreenSearchActive = false
                self.mainSearchController.customSearchBar.text = ""
            }
        })
    }
    
}
