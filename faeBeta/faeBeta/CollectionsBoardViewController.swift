//
//  CollectionsBoardViewController.swift
//  faeBeta
//
//  Created by Shiqi Wei on 3/22/17.
//  Copyright © 2017 fae. All rights reserved.
//

import UIKit
import SwiftyJSON

class CollectionsBoardViewController: UIViewController, CollectionsBoardDelegate {
    var firstAppear = true
    //background view
    var uiviewBackground: UIView!
    var lblSavedPinsCount : UILabel!
    var lblCreatedPinsCount : UILabel!
    var lblSavedLocationsCount : UILabel!
    var lblSavedPlacesCount : UILabel!
    
    func backToBoard(Count: Int){
        getPinCounts()
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        uiviewBackground = UIView(frame: CGRect(x: 0, y: 0, width: screenWidth, height: screenHeight))
        self.view.addSubview(uiviewBackground)
        uiviewBackground.frame.origin.x = screenWidth
        // Do any additional setup after loading the view.
        loadColBoard()
        loadNavBar()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        if firstAppear {
            super.viewDidAppear(animated)
            UIView.animate(withDuration: 0.3, animations: ({
                self.uiviewBackground.frame.origin.x = 0
            }))
            firstAppear = false
        }else{
            getPinCounts()
        }
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    // Dismiss current View
    func actionDismissCurrentView(_ sender: UIButton) {
        UIView.animate(withDuration: 0.3, animations: ({
            self.uiviewBackground.frame.origin.x = screenWidth
        }), completion: { (done: Bool) in
            if done {
                self.dismiss(animated: false, completion: nil)
            }
        })
        
    }
    
    // Load the Navigation Bar
    func loadNavBar() {
        let uiviewNavBar = UIView(frame: CGRect(x: -1, y: -1, width: screenWidth+2, height: 66))
        uiviewNavBar.layer.borderColor = UIColor.faeAppNavBarBorderGrayColor()
        uiviewNavBar.layer.borderWidth = 1
        uiviewNavBar.backgroundColor = UIColor.white
        uiviewBackground.addSubview(uiviewNavBar)
    
        let lblTitle = UILabel(frame: CGRect(x: (screenWidth-103)/2, y: 28, width: 103, height: 27))
        lblTitle.font = UIFont(name: "AvenirNext-Medium",size: 20)
        lblTitle.textAlignment = NSTextAlignment.center
        lblTitle.textColor = UIColor.faeAppInputTextGrayColor()
        lblTitle.text = "Collections"
        uiviewNavBar.addSubview(lblTitle)

        let btnBackNavBar = UIButton(frame: CGRect(x: 0, y: 32, width: 40.5, height: 18))
        btnBackNavBar.setImage(#imageLiteral(resourceName: "mainScreenSearchToFaeMap"), for: UIControlState.normal)
        btnBackNavBar.addTarget(self, action: #selector(self.actionDismissCurrentView(_:)), for: .touchUpInside)
        uiviewNavBar.addSubview(btnBackNavBar)
    }
    
    // Load the Collection Board
    func loadColBoard() {
        let uiviewBoard = UIView(frame: CGRect(x: 0,y: 62,width: screenWidth,height: screenHeight-62))
        uiviewBoard.backgroundColor = UIColor.white
        uiviewBackground.addSubview(uiviewBoard)
        
        let lblMyPins = UILabel()
        lblMyPins.font = UIFont(name: "AvenirNext-DemiBold",size: 13)
        lblMyPins.textAlignment = NSTextAlignment.left
        lblMyPins.textColor = UIColor.faeAppTimeTextBlackColor()
        lblMyPins.text = "My Pins"
        uiviewBoard.addSubview(lblMyPins)
        
        let btnCreatedPins = UIButton()
        btnCreatedPins.setImage( #imageLiteral(resourceName: "createdpinbtnbackground"), for: UIControlState.normal)
        btnCreatedPins.addTarget(self, action: #selector(self.actionCreatedPins(_:)), for: .touchUpInside)
        btnCreatedPins.adjustsImageWhenHighlighted = false
        uiviewBoard.addSubview(btnCreatedPins)
        
        let createdPinsAvatar = getAvatar()
        uiviewBoard.addSubview(createdPinsAvatar)
        
        let btnSavedPins = UIButton()
        btnSavedPins.setImage(#imageLiteral(resourceName: "savedpinbtnbackground"), for: UIControlState.normal)
        btnSavedPins.addTarget(self, action: #selector(self.actionSavedPins(_:)), for: .touchUpInside)
        btnSavedPins.adjustsImageWhenHighlighted = false
        uiviewBoard.addSubview(btnSavedPins)
        
        let savedPinsAvatar = getAvatar()
        uiviewBoard.addSubview(savedPinsAvatar)
        
        lblCreatedPinsCount = getitemCount()
        uiviewBoard.addSubview(lblCreatedPinsCount)
        lblSavedPinsCount = getitemCount()
        uiviewBoard.addSubview(lblSavedPinsCount)
        getPinCounts()
        
        let lblMyLists = UILabel()
        lblMyLists.font = UIFont(name: "AvenirNext-DemiBold",size: 13)
        lblMyLists.textAlignment = NSTextAlignment.left
        lblMyLists.textColor = UIColor.faeAppTimeTextBlackColor()
        lblMyLists.text = "My Lists"
        uiviewBoard.addSubview(lblMyLists)
        
        let btnSavedLocations = UIButton()
        btnSavedLocations.setImage(#imageLiteral(resourceName: "locationbtnbackground"), for: UIControlState.normal)
        btnSavedLocations.addTarget(self, action: #selector(self.actionSavedLocations(_:)), for: .touchUpInside)
        btnSavedLocations.adjustsImageWhenHighlighted = false
        uiviewBoard.addSubview(btnSavedLocations)
        
        let savedLocationsAvatar = getAvatar()
        uiviewBoard.addSubview(savedLocationsAvatar)
        
        lblSavedLocationsCount = getitemCount()
        uiviewBoard.addSubview(lblSavedLocationsCount)
        
        let btnSavedPlaces = UIButton()
        btnSavedPlaces.setImage(#imageLiteral(resourceName: "placebtnbackground"), for: UIControlState.normal)
        btnSavedPlaces.addTarget(self, action: #selector(self.actionSavedPlaces(_:)), for: .touchUpInside)
        btnSavedPlaces.adjustsImageWhenHighlighted = false
        uiviewBoard.addSubview(btnSavedPlaces)
        
        let savedPlacesAvatar = getAvatar()
        uiviewBoard.addSubview(savedPlacesAvatar)
        
        lblSavedPlacesCount = getitemCount()
        uiviewBoard.addSubview(lblSavedPlacesCount)
        
        uiviewBoard.addConstraintsWithFormat("V:|-22-[v0(18)]-12-[v1(176)]-20-[v2(18)]-12-[v3(176)]", options: [], views: lblMyPins, btnCreatedPins, lblMyLists, btnSavedLocations)
        
        uiviewBoard.addConstraintsWithFormat("V:|-52-[v0(176)]-50-[v1(176)]", options: [], views: btnSavedPins,btnSavedPlaces)
        
        uiviewBoard.addConstraintsWithFormat("H:|-15-[v0(\(screenWidth/2-21))]-12-[v1(\(screenWidth/2-21))]-15-|", options: [], views: btnCreatedPins, btnSavedPins)
        
        uiviewBoard.addConstraintsWithFormat("H:|-15-[v0(\(screenWidth/2-21))]-12-[v1(\(screenWidth/2-21))]-15-|", options: [], views: btnSavedLocations, btnSavedPlaces)
        
        uiviewBoard.addConstraintsWithFormat("H:|-15-[v0]", options: [], views: lblMyPins)
        uiviewBoard.addConstraintsWithFormat("H:|-15-[v0]", options: [], views: lblMyLists)
        
        // 给头像和itemslabel加Constraints
        uiviewBoard.addConstraintsWithFormat("V:|-138-[v0(36)]-28-[v1(18)]-145-[v2(36)]-28-[v3(18)]", options: [], views: createdPinsAvatar, lblCreatedPinsCount, savedLocationsAvatar, lblSavedLocationsCount)
        uiviewBoard.addConstraintsWithFormat("V:|-138-[v0(36)]-28-[v1(18)]-145-[v2(36)]-28-[v3(18)]", options: [], views: savedPinsAvatar, lblSavedPinsCount, savedPlacesAvatar, lblSavedPlacesCount)
        uiviewBoard.addConstraintsWithFormat("H:|-27-[v0(36)]-\(screenWidth/2-45)-[v1(36)]", options: [], views: createdPinsAvatar, savedPinsAvatar)
        uiviewBoard.addConstraintsWithFormat("H:|-27-[v0(36)]-\(screenWidth/2-45)-[v1(36)]", options: [], views: savedLocationsAvatar, savedPlacesAvatar)
        uiviewBoard.addConstraintsWithFormat("H:|-30-[v0(100)]-\(screenWidth/2-109)-[v1]", options: [], views: lblCreatedPinsCount, lblSavedPinsCount)
        uiviewBoard.addConstraintsWithFormat("H:|-30-[v0(100)]-\(screenWidth/2-109)-[v1]", options: [], views: lblSavedLocationsCount, lblSavedPlacesCount)
    }
    
    //生成头像对象
    func getAvatar() -> UIView{
        let imgAvatar = UIImageView(frame: CGRect(x: 0, y: 0, width: 36*screenWidthFactor, height: 36*screenWidthFactor))
        imgAvatar.layer.cornerRadius = 18*screenWidthFactor
        imgAvatar.contentMode = .scaleAspectFill
        imgAvatar.layer.masksToBounds = true
        imgAvatar.layer.borderColor = UIColor.white.cgColor
        imgAvatar.layer.borderWidth = 3*screenWidthFactor
        
        let imgShadow = UIView()
        imgShadow.layer.shadowColor = UIColor.faeAppShadowGrayColor().cgColor
        imgShadow.layer.shadowOffset = CGSize(width: 0, height: 1)
        imgShadow.layer.shadowOpacity = 0.5
        imgShadow.layer.shadowRadius = 3.0
        imgShadow.layer.cornerRadius = 18*screenWidthFactor
        imgShadow.clipsToBounds = false
        imgShadow.addSubview(imgAvatar)
        
        if let gender = userUserGender {
            if gender == "male" {
                imgAvatar.image = #imageLiteral(resourceName: "defaultMen")
            }
            else {
                imgAvatar.image = #imageLiteral(resourceName: "defaultWomen")
            }
        }
        
        if user_id != nil {
            let stringHeaderURL = "\(baseURL)/files/users/\(user_id.stringValue)/avatar"
            imgAvatar.sd_setImage(with: URL(string: stringHeaderURL), placeholderImage: Key.sharedInstance.imageDefaultMale, options: [.retryFailed, .refreshCached], completed: { (image, error, SDImageCacheType, imageURL) in
                if image != nil {

                }
            })
        }
        return imgShadow
    }
    
    //生成itemslabel对象
    func getitemCount() -> UILabel {
        let labelCount = UILabel()
        labelCount.font = UIFont(name: "AvenirNext-Medium", size: 13)
        labelCount.textAlignment = NSTextAlignment.left
        labelCount.textColor = UIColor.faeAppInputPlaceholderGrayColor()
        labelCount.text = "0 items"
        return labelCount
    }
    
    func getPinCounts(){
        let getPinCounts = FaeMap()
        getPinCounts.getPinStatistics {(status: Int, message: Any?) in
            if status / 100 == 2 {
                let pinCountsJSON = JSON(message!)
                if let createdComment = pinCountsJSON["count"]["created_comment_pin"].int, let createdmedia = pinCountsJSON["count"]["created_media_pin"].int {
                    self.lblCreatedPinsCount.text = String(createdComment+createdmedia)+" items"
                }
                if let savedComment = pinCountsJSON["count"]["saved_comment_pin"].int, let savedmedia = pinCountsJSON["count"]["saved_media_pin"].int {
                    self.lblSavedPinsCount.text = String(savedComment+savedmedia)+" items"
                }
            }
        }
    }
    
    func getlblSavedPlacesCount() -> Int {
        let count = 0
        return count
    }
    
    func getlblSavedLocationsCount() -> Int {
        let count = 0
        return count
    }
    
    func actionCreatedPins(_ sender: UIButton){
        let createdPinVC = CreatedPinsViewController()
        createdPinVC.modalPresentationStyle = .overCurrentContext
        createdPinVC.backBoardDelegate = self
        self.present(createdPinVC, animated: false, completion: nil)
    }
    
    func actionSavedPins(_ sender: UIButton){
        let savedPinVC = SavedPinsViewController()
        savedPinVC.modalPresentationStyle = .overCurrentContext
        savedPinVC.backBoardDelegate = self
        self.present(savedPinVC, animated: false, completion: nil)
    }
    
    func actionSavedPlaces(_ sender: UIButton){
        let savedPlaceVC = PlacesAndLocationsViewController()
        savedPlaceVC.strTableTitle = "Saved Places"
        savedPlaceVC.modalPresentationStyle = .overCurrentContext
        self.present(savedPlaceVC, animated: false, completion: nil)
    }
    
    func actionSavedLocations(_ sender: UIButton){
        let savedLocationsVC = PlacesAndLocationsViewController()
        savedLocationsVC.strTableTitle = "Saved Locations"
        savedLocationsVC.modalPresentationStyle = .overCurrentContext
        self.present(savedLocationsVC, animated: false, completion: nil)
    }
}
