//
//  CollectionsBoardViewController.swift
//  faeBeta
//
//  Created by Shiqi Wei on 3/22/17.
//  Edited by Sophie Wang
//  Edited by Yue Shen on 6/3/17
//  Copyright © 2017 fae. All rights reserved.
//

import UIKit
import SwiftyJSON

class CollectionsBoardViewController: UIViewController, CollectionsBoardDelegate {
    
    var boolFirstAppear = true
    var lblSavedPinsCount: UILabel!
    var lblCreatedPinsCount: UILabel!
    var lblSavedLocationsCount: UILabel!
    var lblSavedPlacesCount: UILabel!
    var arrImgView = [UIImageView]()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        loadColBoard()
        loadNavBar()
        getAvatar()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        if boolFirstAppear {
            boolFirstAppear = false
        } else {
            getPinCounts()
        }
    }
    
    func backToBoard(count: Int) {
        getPinCounts()
    }
    
    func actionDismissCurrentView(_ sender: UIButton) {
        navigationController?.popViewController(animated: true)
    }
    
    func loadNavBar() {
        let uiviewNavBar = FaeNavBar(frame: .zero)
        view.addSubview(uiviewNavBar)
        uiviewNavBar.loadBtnConstraints()
        
        uiviewNavBar.leftBtn.addTarget(self, action: #selector(actionDismissCurrentView(_:)), for: .touchUpInside)
        uiviewNavBar.rightBtn.isHidden = true
        
        uiviewNavBar.lblTitle.text = "Collections"
    }
    
    // Load the Collection Board
    func loadColBoard() {
        view.backgroundColor = UIColor.white
        
        let lblMyPins = UILabel()
        lblMyPins.font = UIFont(name: "AvenirNext-DemiBold", size: 13)
        lblMyPins.textAlignment = .left
        lblMyPins.textColor = UIColor._107107107()
        lblMyPins.text = "My Pins"
        view.addSubview(lblMyPins)
        
        let btnCreatedPins = UIButton()
        btnCreatedPins.setImage(#imageLiteral(resourceName: "createdpinbtnbackground"), for: .normal)
        btnCreatedPins.addTarget(self, action: #selector(self.actionCreatedPins(_:)), for: .touchUpInside)
        btnCreatedPins.adjustsImageWhenHighlighted = false
        view.addSubview(btnCreatedPins)
        
        let avatarCreatedPinsAvatar = loadAvatarViewFrame()
        view.addSubview(avatarCreatedPinsAvatar)
        
        let btnSavedPins = UIButton()
        btnSavedPins.setImage(#imageLiteral(resourceName: "savedpinbtnbackground"), for: .normal)
        btnSavedPins.addTarget(self, action: #selector(self.actionSavedPins(_:)), for: .touchUpInside)
        btnSavedPins.adjustsImageWhenHighlighted = false
        view.addSubview(btnSavedPins)
        
        let avatarSavedPins = loadAvatarViewFrame()
        view.addSubview(avatarSavedPins)
        
        lblCreatedPinsCount = getitemCount()
        view.addSubview(lblCreatedPinsCount)
        lblSavedPinsCount = getitemCount()
        view.addSubview(lblSavedPinsCount)
        getPinCounts()
        
        let lblMyLists = UILabel()
        lblMyLists.font = UIFont(name: "AvenirNext-DemiBold", size: 13)
        lblMyLists.textAlignment = .left
        lblMyLists.textColor = UIColor._107107107()
        lblMyLists.text = "My Lists"
        view.addSubview(lblMyLists)
        
        let btnSavedLocations = UIButton()
        btnSavedLocations.setImage(#imageLiteral(resourceName: "locationbtnbackground"), for: UIControlState.normal)
        btnSavedLocations.addTarget(self, action: #selector(self.actionSavedLocations(_:)), for: .touchUpInside)
        btnSavedLocations.adjustsImageWhenHighlighted = false
        view.addSubview(btnSavedLocations)
        
        let avatarSavedLocations = loadAvatarViewFrame()
        view.addSubview(avatarSavedLocations)
        
        lblSavedLocationsCount = getitemCount()
        view.addSubview(lblSavedLocationsCount)
        
        let btnSavedPlaces = UIButton()
        btnSavedPlaces.setImage(#imageLiteral(resourceName: "placebtnbackground"), for: UIControlState.normal)
        btnSavedPlaces.addTarget(self, action: #selector(self.actionSavedPlaces(_:)), for: .touchUpInside)
        btnSavedPlaces.adjustsImageWhenHighlighted = false
        view.addSubview(btnSavedPlaces)
        
        let avatarSavedPlaces = loadAvatarViewFrame()
        view.addSubview(avatarSavedPlaces)
        
        lblSavedPlacesCount = getitemCount()
        view.addSubview(lblSavedPlacesCount)
        
        view.addConstraintsWithFormat("V:|-84-[v0(18)]-12-[v1(176)]-20-[v2(18)]-12-[v3(176)]", options: [], views: lblMyPins, btnCreatedPins, lblMyLists, btnSavedLocations)
        
        view.addConstraintsWithFormat("V:|-114-[v0(176)]-50-[v1(176)]", options: [], views: btnSavedPins, btnSavedPlaces)
        
        view.addConstraintsWithFormat("H:|-15-[v0(\(screenWidth / 2 - 21))]-12-[v1(\(screenWidth / 2 - 21))]-15-|", options: [], views: btnCreatedPins, btnSavedPins)
        
        view.addConstraintsWithFormat("H:|-15-[v0(\(screenWidth / 2 - 21))]-12-[v1(\(screenWidth / 2 - 21))]-15-|", options: [], views: btnSavedLocations, btnSavedPlaces)
        
        view.addConstraintsWithFormat("H:|-15-[v0]", options: [], views: lblMyPins)
        view.addConstraintsWithFormat("H:|-15-[v0]", options: [], views: lblMyLists)
        
        // 给头像和itemslabel加Constraints
        view.addConstraintsWithFormat("V:|-200-[v0(36)]-28-[v1(18)]-145-[v2(36)]-28-[v3(18)]", options: [], views: avatarCreatedPinsAvatar, lblCreatedPinsCount, avatarSavedLocations, lblSavedLocationsCount)
        view.addConstraintsWithFormat("V:|-200-[v0(36)]-28-[v1(18)]-145-[v2(36)]-28-[v3(18)]", options: [], views: avatarSavedPins, lblSavedPinsCount, avatarSavedPlaces, lblSavedPlacesCount)
        view.addConstraintsWithFormat("H:|-27-[v0(36)]-\(screenWidth / 2 - 45)-[v1(36)]", options: [], views: avatarCreatedPinsAvatar, avatarSavedPins)
        view.addConstraintsWithFormat("H:|-27-[v0(36)]-\(screenWidth / 2 - 45)-[v1(36)]", options: [], views: avatarSavedLocations, avatarSavedPlaces)
        view.addConstraintsWithFormat("H:|-30-[v0(100)]-\(screenWidth / 2 - 109)-[v1]", options: [], views: lblCreatedPinsCount, lblSavedPinsCount)
        view.addConstraintsWithFormat("H:|-30-[v0(100)]-\(screenWidth / 2 - 109)-[v1]", options: [], views: lblSavedLocationsCount, lblSavedPlacesCount)
    }
    
    func loadAvatarViewFrame() -> UIView {
        let imgAvatar = UIImageView(frame: CGRect(x: 0, y: 0, width: 36 * screenWidthFactor, height: 36 * screenWidthFactor))
        imgAvatar.layer.cornerRadius = 18 * screenWidthFactor
        imgAvatar.contentMode = .scaleAspectFill
        imgAvatar.layer.masksToBounds = true
        imgAvatar.layer.borderColor = UIColor.white.cgColor
        imgAvatar.layer.borderWidth = 3 * screenWidthFactor
        arrImgView.append(imgAvatar)
        
        let imgShadow = UIView()
        imgShadow.layer.shadowColor = UIColor._210210210().cgColor
        imgShadow.layer.shadowOffset = CGSize(width: 0, height: 1)
        imgShadow.layer.shadowOpacity = 0.5
        imgShadow.layer.shadowRadius = 3.0
        imgShadow.layer.cornerRadius = 18 * screenWidthFactor
        imgShadow.clipsToBounds = false
        imgShadow.addSubview(imgAvatar)
        
        imgAvatar.image = Key.shared.gender  == "male" ? #imageLiteral(resourceName: "defaultMen") : #imageLiteral(resourceName: "defaultWomen")
        
        return imgShadow
    }
    
    func getAvatar() {
        guard Key.shared.user_id != -1 else { return }
        General.shared.avatar(userid: Key.shared.user_id, completion: { image in
            for imgView in self.arrImgView {
                imgView.image = image
            }
        })
    }
    
    // 生成itemslabel对象
    func getitemCount() -> UILabel {
        let lblCount = UILabel()
        lblCount.font = UIFont(name: "AvenirNext-Medium", size: 13)
        lblCount.textAlignment = .left
        lblCount.textColor = UIColor._155155155()
        lblCount.text = "0 items"
        return lblCount
    }
    
    func getPinCounts() {
        let getPinCounts = FaeMap()
        getPinCounts.getPinStatistics { (status: Int, message: Any?) in
            guard status / 100 == 2 else { return }
            let pinCountsJSON = JSON(message!)
            if let createdComment = pinCountsJSON["count"]["created_comment_pin"].int, let createdmedia = pinCountsJSON["count"]["created_media_pin"].int {
                self.lblCreatedPinsCount.text = String(createdComment + createdmedia) + " items"
            }
            if let savedComment = pinCountsJSON["count"]["saved_comment_pin"].int, let savedmedia = pinCountsJSON["count"]["saved_media_pin"].int {
                self.lblSavedPinsCount.text = String(savedComment + savedmedia) + " items"
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
    
    func actionCreatedPins(_ sender: UIButton) {
        let vcCreatedPin = CreatedPinsViewController()
        vcCreatedPin.delegateBackBoard = self
        navigationController?.pushViewController(vcCreatedPin, animated: true)
    }
    
    func actionSavedPins(_ sender: UIButton) {
        let vcSavedPin = SavedPinsViewController()
        vcSavedPin.delegateBackBoard = self
        navigationController?.pushViewController(vcSavedPin, animated: true)
    }
    
    func actionSavedPlaces(_ sender: UIButton) {
        let vcSavedPlace = PlacesAndLocationsViewController()
        vcSavedPlace.strTableTitle = "Saved Places"
        navigationController?.pushViewController(vcSavedPlace, animated: true)
    }
    
    func actionSavedLocations(_ sender: UIButton) {
        let vcSavedLocations = PlacesAndLocationsViewController()
        vcSavedLocations.strTableTitle = "Saved Locations"
        navigationController?.pushViewController(vcSavedLocations, animated: true)
    }
}
