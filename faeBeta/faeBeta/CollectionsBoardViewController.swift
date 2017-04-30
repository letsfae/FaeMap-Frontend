//
//  CollectionsBoardViewController.swift
//  faeBeta
//
//  Created by Shiqi Wei on 3/22/17.
//  Copyright © 2017 fae. All rights reserved.
//

import UIKit
import SwiftyJSON

class CollectionsBoardViewController: UIViewController {
    var firstAppear = true
    
    //background view
    var viewBackground: UIView!
    var savedPinsCount : UILabel!
    var createdPinsCount : UILabel!
    var savedLocationsCount : UILabel!
    var savedPlacesCount : UILabel!
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        viewBackground = UIView(frame: CGRect(x: 0,y: 0,width: screenWidth,height: screenHeight))
        self.view.addSubview(viewBackground)
        viewBackground.center.x = 1.5 * screenWidth
        // Do any additional setup after loading the view.
        loadColBoard()
        loadNavBar()
        
        
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        if firstAppear {
            super.viewDidAppear(animated)
            UIView.animate(withDuration: 0.3, animations: ({
                self.viewBackground.center.x = screenWidth/2
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
            self.viewBackground.center.x = 1.5 * screenWidth
        }), completion: { (done: Bool) in
            if done {
                self.dismiss(animated: false, completion: nil)
            }
        })
        
    }
    
    // Load the Navigation Bar
    func loadNavBar() {
        
        let viewNavBar = UIView(frame: CGRect(x: -1, y: -1, width: screenWidth+2, height: 66))
        viewNavBar.layer.borderColor = UIColor.faeAppNavBarBorderGrayColor()
        viewNavBar.layer.borderWidth = 1
        viewNavBar.backgroundColor = UIColor.white
        
        viewBackground.addSubview(viewNavBar)
        
        let title = UILabel(frame: CGRect(x: (screenWidth-103)/2, y: 28, width: 103, height: 27))
        title.font = UIFont(name: "AvenirNext-Medium",size: 20)
        title.textAlignment = NSTextAlignment.center
        title.textColor = UIColor.faeAppInputTextGrayColor()
        title.text = "Collections"
        viewNavBar.addSubview(title)
        
        
        
        
        let btnBackNavBar = UIButton(frame: CGRect(x: 0, y: 32, width: 40.5, height: 18))
        
        btnBackNavBar.setImage(#imageLiteral(resourceName: "mainScreenSearchToFaeMap"), for: UIControlState.normal)
        
        
        btnBackNavBar.addTarget(self, action: #selector(self.actionDismissCurrentView(_:)), for: .touchUpInside)
        
        
        viewNavBar.addSubview(btnBackNavBar)
        
    }
    
    
    // Load the Collection Board
    func loadColBoard() {
        
        let viewBoard = UIView(frame: CGRect(x: 0,y: 62,width: screenWidth,height: screenHeight-62))
        viewBoard.backgroundColor = UIColor.white
        viewBackground.addSubview(viewBoard)
        
        let myPins = UILabel()
        myPins.font = UIFont(name: "AvenirNext-DemiBold",size: 13)
        myPins.textAlignment = NSTextAlignment.left
        myPins.textColor = UIColor.faeAppTimeTextBlackColor()
        myPins.text = "My Pins"
        viewBoard.addSubview(myPins)
        
        let createdPins = UIButton()
        createdPins.setImage( #imageLiteral(resourceName: "createdpinbtnbackground"), for: UIControlState.normal)
        createdPins.addTarget(self, action: #selector(self.actionCreatedPins(_:)), for: .touchUpInside)
        createdPins.adjustsImageWhenHighlighted = false
        viewBoard.addSubview(createdPins)
        
        let createdPinsAvatar = getAvatar()
        viewBoard.addSubview(createdPinsAvatar)
        
        let savedPins = UIButton()
        savedPins.setImage(#imageLiteral(resourceName: "savedpinbtnbackground"), for: UIControlState.normal)
        savedPins.addTarget(self, action: #selector(self.actionSavedPins(_:)), for: .touchUpInside)
        savedPins.adjustsImageWhenHighlighted = false
        viewBoard.addSubview(savedPins)
        
        let savedPinsAvatar = getAvatar()
        viewBoard.addSubview(savedPinsAvatar)
        
        createdPinsCount = getitemCount()
        viewBoard.addSubview(createdPinsCount)
        savedPinsCount = getitemCount()
        viewBoard.addSubview(savedPinsCount)
        getPinCounts()
        
        let myLists = UILabel()
        myLists.font = UIFont(name: "AvenirNext-DemiBold",size: 13)
        myLists.textAlignment = NSTextAlignment.left
        myLists.textColor = UIColor.faeAppTimeTextBlackColor()
        myLists.text = "My Lists"
        viewBoard.addSubview(myLists)
        
        let savedLocations = UIButton()
        savedLocations.setImage(#imageLiteral(resourceName: "locationbtnbackground"), for: UIControlState.normal)
        savedLocations.addTarget(self, action: #selector(self.actionSavedLocations(_:)), for: .touchUpInside)
        savedLocations.adjustsImageWhenHighlighted = false
        viewBoard.addSubview(savedLocations)
        
        let savedLocationsAvatar = getAvatar()
        viewBoard.addSubview(savedLocationsAvatar)
        
        savedLocationsCount = getitemCount()
        viewBoard.addSubview(savedLocationsCount)
        
        
        let savedPlaces = UIButton()
        savedPlaces.setImage(#imageLiteral(resourceName: "placebtnbackground"), for: UIControlState.normal)
        savedPlaces.addTarget(self, action: #selector(self.actionSavedPlaces(_:)), for: .touchUpInside)
        savedPlaces.adjustsImageWhenHighlighted = false
        viewBoard.addSubview(savedPlaces)
        
        let savedPlacesAvatar = getAvatar()
        viewBoard.addSubview(savedPlacesAvatar)
        
        savedPlacesCount = getitemCount()
        viewBoard.addSubview(savedPlacesCount)
        
        viewBoard.addConstraintsWithFormat("V:|-22-[v0(18)]-12-[v1(176)]-20-[v2(18)]-12-[v3(176)]", options: [], views: myPins, createdPins, myLists, savedLocations)
        
        viewBoard.addConstraintsWithFormat("V:|-52-[v0(176)]-50-[v1(176)]", options: [], views: savedPins,savedPlaces)
        
        viewBoard.addConstraintsWithFormat("H:|-15-[v0(\(screenWidth/2-21))]-12-[v1(\(screenWidth/2-21))]-15-|", options: [], views: createdPins,savedPins)
        
        viewBoard.addConstraintsWithFormat("H:|-15-[v0(\(screenWidth/2-21))]-12-[v1(\(screenWidth/2-21))]-15-|", options: [], views: savedLocations, savedPlaces)
        
        viewBoard.addConstraintsWithFormat("H:|-15-[v0]", options: [], views: myPins)
        viewBoard.addConstraintsWithFormat("H:|-15-[v0]", options: [], views: myLists)
        
        
        // 给头像和itemslabel加Constraints
        viewBoard.addConstraintsWithFormat("V:|-138-[v0(36)]-28-[v1(18)]-145-[v2(36)]-28-[v3(18)]", options: [], views:createdPinsAvatar, createdPinsCount, savedLocationsAvatar, savedLocationsCount)
        viewBoard.addConstraintsWithFormat("V:|-138-[v0(36)]-28-[v1(18)]-145-[v2(36)]-28-[v3(18)]", options: [], views:savedPinsAvatar, savedPinsCount, savedPlacesAvatar, savedPlacesCount)
        viewBoard.addConstraintsWithFormat("H:|-27-[v0(36)]-\(screenWidth/2-45)-[v1(36)]", options: [], views: createdPinsAvatar, savedPinsAvatar)
        viewBoard.addConstraintsWithFormat("H:|-27-[v0(36)]-\(screenWidth/2-45)-[v1(36)]", options: [], views: savedLocationsAvatar, savedPlacesAvatar)
        viewBoard.addConstraintsWithFormat("H:|-30-[v0(100)]-\(screenWidth/2-109)-[v1]", options: [], views: createdPinsCount, savedPinsCount)
        viewBoard.addConstraintsWithFormat("H:|-30-[v0(100)]-\(screenWidth/2-109)-[v1]", options: [], views: savedLocationsCount, savedPlacesCount)
        
        
        
    }
    
    //生成头像对象
    func getAvatar() -> UIView{
        
        let imageAvatar = UIImageView(frame: CGRect(x: 0, y: 0, width: 36*screenWidthFactor, height: 36*screenWidthFactor))
        imageAvatar.layer.cornerRadius = 18*screenWidthFactor
        imageAvatar.contentMode = .scaleAspectFill
        imageAvatar.layer.masksToBounds = true
        imageAvatar.layer.borderColor = UIColor.white.cgColor
        imageAvatar.layer.borderWidth = 3*screenWidthFactor
        
        let imgShadow = UIView()
        imgShadow.layer.shadowColor = UIColor.faeAppShadowGrayColor().cgColor
        imgShadow.layer.shadowOffset = CGSize(width: 0, height: 1)
        imgShadow.layer.shadowOpacity = 0.5
        imgShadow.layer.shadowRadius = 3.0
        imgShadow.layer.cornerRadius = 18*screenWidthFactor
        imgShadow.clipsToBounds = false
        imgShadow.addSubview(imageAvatar)
        
        if let gender = userUserGender {
            if gender == "male" {
                imageAvatar.image = #imageLiteral(resourceName: "defaultMen")
            }
            else {
                imageAvatar.image = #imageLiteral(resourceName: "defaultWomen")
            }
        }
        
        if user_id != nil {
            let stringHeaderURL = "\(baseURL)/files/users/\(user_id.stringValue)/avatar"
            imageAvatar.sd_setImage(with: URL(string: stringHeaderURL), placeholderImage: Key.sharedInstance.imageDefaultMale, options: [.retryFailed, .refreshCached], completed: { (image, error, SDImageCacheType, imageURL) in
                if image != nil {

                }
            })
        }
        return imgShadow
    }
    
    //生成itemslabel对象
    func getitemCount() -> UILabel {
        
        let labelCount = UILabel()
        labelCount.font = UIFont(name: "AvenirNext-Medium",size: 13)
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
                    self.createdPinsCount.text = String(createdComment+createdmedia)+" items"
                }
                if let savedComment = pinCountsJSON["count"]["saved_comment_pin"].int, let savedmedia = pinCountsJSON["count"]["saved_media_pin"].int {
                    self.savedPinsCount.text = String(savedComment+savedmedia)+" items"
                }
            }
        }
    }
    
    func getSavedPlacesCount() -> Int {
        let count = 0
        //savedPlacesCount.text = String(count)+" items"
        return count
    }
    
    
    func getSavedLocationsCount() -> Int {
        let count = 0
        return count
    }
    
    
    
    func actionCreatedPins(_ sender: UIButton){
        
        let createdPinVC = CreatedPinsViewController()
        createdPinVC.modalPresentationStyle = .overCurrentContext
        
        self.present(createdPinVC, animated: false, completion: nil)
    }
    
    func actionSavedPins(_ sender: UIButton){
        
        let savedPinVC = SavedPinsViewController()
        savedPinVC.modalPresentationStyle = .overCurrentContext
        
        self.present(savedPinVC, animated: false, completion: nil)
    }
    
    func actionSavedPlaces(_ sender: UIButton){
        
        let savedPlaceVC = PlacesAndLocationsViewController()
        savedPlaceVC.tblTitle = "Saved Places"
        savedPlaceVC.modalPresentationStyle = .overCurrentContext
        
        self.present(savedPlaceVC, animated: false, completion: nil)
    }
    
    func actionSavedLocations(_ sender: UIButton){
        
        let savedLocationsVC = PlacesAndLocationsViewController()
        savedLocationsVC.tblTitle = "Saved Locations"
        savedLocationsVC.modalPresentationStyle = .overCurrentContext
        
        self.present(savedLocationsVC, animated: false, completion: nil)
    }
    
    
    
    
    
    
}
