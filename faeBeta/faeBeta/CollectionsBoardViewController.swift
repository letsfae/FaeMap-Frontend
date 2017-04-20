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
        viewBackground.center.x += screenWidth
        // Do any additional setup after loading the view.
        loadColBoard()
        loadNavBar()
        
        
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        if(firstAppear){
            
            super.viewDidAppear(animated)
            UIView.animate(withDuration: 0.3, animations: ({
                self.viewBackground.center.x -= screenWidth
            }))
            firstAppear = false
        }
    }
    
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    // Dismiss current View
    func actionDismissCurrentView(_ sender: UIButton) {
        UIView.animate(withDuration: 0.3, animations: ({
            self.viewBackground.center.x += screenWidth
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
        
        createdPinsCount = getitemCount(_: String(getCreatedPinsCount()))
        viewBoard.addSubview(createdPinsCount)
        
        
        
        let savedPins = UIButton()
        savedPins.setImage(#imageLiteral(resourceName: "savedpinbtnbackground"), for: UIControlState.normal)
        savedPins.addTarget(self, action: #selector(self.actionSavedPins(_:)), for: .touchUpInside)
        savedPins.adjustsImageWhenHighlighted = false
        viewBoard.addSubview(savedPins)
        
        let savedPinsAvatar = getAvatar()
        viewBoard.addSubview(savedPinsAvatar)
        
        savedPinsCount = getitemCount(_: String(getSavedPinsCount()))
        viewBoard.addSubview(savedPinsCount)
        
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
        
        savedLocationsCount = getitemCount(_: String(getSavedLocationsCount()))
        viewBoard.addSubview(savedLocationsCount)
        
        
        let savedPlaces = UIButton()
        savedPlaces.setImage(#imageLiteral(resourceName: "placebtnbackground"), for: UIControlState.normal)
        savedPlaces.addTarget(self, action: #selector(self.actionSavedPlaces(_:)), for: .touchUpInside)
        savedPlaces.adjustsImageWhenHighlighted = false
        viewBoard.addSubview(savedPlaces)
        
        let savedPlacesAvatar = getAvatar()
        viewBoard.addSubview(savedPlacesAvatar)
        
        savedPlacesCount = getitemCount(_: String(getSavedPlacesCount()))
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
    func getAvatar() -> UIImageView{
        
        let imageAvatar = UIImageView()
        
        imageAvatar.layer.cornerRadius = 18*screenWidthFactor
        imageAvatar.layer.borderColor = UIColor.white.cgColor
        imageAvatar.layer.borderWidth = 3
        imageAvatar.contentMode = .scaleAspectFill
        imageAvatar.layer.masksToBounds = true
        
        
        
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
                
            })
        }
        
        return imageAvatar
    }
    
    //生成itemslabel对象
    func getitemCount(_ content: String) -> UILabel {
        
        let Count = UILabel()
        Count.font = UIFont(name: "AvenirNext-Medium",size: 13)
        Count.textAlignment = NSTextAlignment.left
        Count.textColor = UIColor.faeAppInputPlaceholderGrayColor()
        Count.text = content+" items"
        
        return Count
        
        
    }
    
    func getCreatedPinsCount() -> Int{
        var count = 0
        let getCreatedPinsData = FaeMap()
        getCreatedPinsData.getCreatedPins() {(status: Int, message: Any?) in
            if status / 100 == 2 {
                let PinsOfCreatedPinsJSON = JSON(message!)
                count = PinsOfCreatedPinsJSON.count
                self.createdPinsCount.text = String(count)+" items"
            }
        }
        return count
    }
    
    func getSavedPinsCount() -> Int {
        var count = 0
        let getSavedPinsData = FaeMap()
        getSavedPinsData.getSavedPins() {(status: Int, message: Any?) in
            if status / 100 == 2 {
                
                let PinsOfSavedPinsJSON = JSON(message!)
                count = PinsOfSavedPinsJSON.count
                self.savedPinsCount.text = String(count)+" items"
            }
        }
        return count
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
        createdPinVC.strTableTitle = "Created Pins"
        createdPinVC.modalPresentationStyle = .overCurrentContext
        
        self.present(createdPinVC, animated: false, completion: nil)
    }
    
    func actionSavedPins(_ sender: UIButton){
        
        let savedPinVC = SavedPinsViewController()
        savedPinVC.strTableTitle = "Saved Pins"
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
