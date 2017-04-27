//
//  PinFullViewController.swift
//  faeBeta
//
//  Created by Shiqi Wei on 4/24/17.
//  Copyright © 2017 fae. All rights reserved.
//

import UIKit

class PinFullViewController: UIViewController {

    var uiviewBackground : UIView!
    override func viewDidLoad() {
        super.viewDidLoad()
        viewLoad()
        // Do any additional setup after loading the view.
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func viewLoad(){
        uiviewBackground = UIView(frame: CGRect(x: 0, y: 0, width: screenWidth, height: screenHeight))
        self.view.addSubview(uiviewBackground)
        uiviewBackground.center.x = 1.5 * screenWidth
        uiviewBackground.backgroundColor = UIColor.faeAppTextViewPlaceHolderGrayColor()
        loadPinDetailWindow()

//        checkPinStatus()
//        addObservers()
//        
//        if self.pinIDPinDetailView != "-999" {
//            getSeveralInfo()
//        }
//        self.delegate?.disableSelfMarker(yes: true)
    }
    
    func loadPinDetailWindow() {
        loadNavBar()
//        if PinDetailViewController.pinTypeEnum != .place {
//            loadFeelingBar()
//        }
//        loadingOtherParts()
//        loadTableHeader()
//        loadAnotherToolbar()
//        loadInputToolBar()

//        tableCommentsForPin.tableHeaderView = uiviewPinDetail
    }
    
    override func viewDidAppear(_ animated: Bool) {
            super.viewDidAppear(animated)
            UIView.animate(withDuration: 0.3, animations: ({
                self.uiviewBackground.center.x = screenWidth/2
            }))
    }
    
    func loadNavBar(){

        let subviewNavigation = UIView(frame: CGRect(x: -1, y: -1, width: screenWidth+2, height: 66))
        subviewNavigation.layer.borderColor = UIColor.faeAppNavBarBorderGrayColor()
        subviewNavigation.layer.borderWidth = 1
        subviewNavigation.backgroundColor = UIColor.white
        subviewNavigation.layer.zPosition = 101
        uiviewBackground.addSubview(subviewNavigation)
        
        let btnBack = UIButton(frame: CGRect(x: 0, y: 32, width: 40.5, height: 18))
        btnBack.setImage(#imageLiteral(resourceName: "mainScreenSearchToFaeMap"), for: UIControlState.normal)
        btnBack.addTarget(self, action: #selector(self.actionDismissCurrentView(_:)), for: .touchUpInside)
        subviewNavigation.addSubview(btnBack)
        let labelNavBarTitle = UILabel(frame: CGRect(x: screenWidth/2-100, y: 28, width: 200, height: 27))
        labelNavBarTitle.font = UIFont(name: "AvenirNext-Medium",size: 20)
        labelNavBarTitle.textAlignment = NSTextAlignment.center
        labelNavBarTitle.textColor = UIColor.faeAppTimeTextBlackColor()
//        labelNavBarTitle.text = ""
        subviewNavigation.addSubview(labelNavBarTitle)
    }
    
    // Dismiss current View
    func actionDismissCurrentView(_ sender: UIButton) {
        UIView.animate(withDuration: 0.3, animations: ({
            self.uiviewBackground.center.x = 1.5 * screenWidth
        }), completion: { (done: Bool) in
            if done {
                self.dismiss(animated: false, completion: nil)
            }
        })
    }


    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

}
