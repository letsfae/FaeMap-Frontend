//
//  SavedPinsTableViewCell.swift
//  faeBeta
//  Created by Shiqi Wei on 1/22/17.
//  Copyright © 2016 fae. All rights reserved.
//

import UIKit


class SavedPinsTableViewCell: PinsTableViewCell {
    
    var imgAvatar : UIImageView!
    var lblUserName : UILabel!
    var btnUnSave : UIButton!
//    var btnLocate : UIButton!
    var btnShare : UIButton!
    
    // Vertical center the buttons when the cell is created
    override func verticalCenterButtons(){
        btnUnSave.center.y = uiviewCellView.center.y
//        btnLocate.center.y = uiviewCellView.center.y
        btnShare.center.y = uiviewCellView.center.y
    
    }
    
    // Setup the cell when creat it
    override func setUpUI() {
        super.setUpUI()
        // set the swiped button after swipe the cell
        btnUnSave = UIButton()
        btnUnSave.frame = CGRect(x: screenWidth-70, y: 0, width: 50, height: 50)
        btnUnSave.setImage(#imageLiteral(resourceName: "imgUnSave"), for: UIControlState.normal)
        uiviewSwipedBtnsView.addSubview(btnUnSave)
        
        btnShare = UIButton()
        btnShare.frame = CGRect(x: screenWidth-140, y: 0, width: 50, height: 50)
        btnShare.setImage(#imageLiteral(resourceName: "imgShare"), for: UIControlState.normal)
        uiviewSwipedBtnsView.addSubview(btnShare)
        
//        btnLocate = UIButton()
//        btnLocate.frame = CGRect(x: screenWidth-210, y: 0, width: 50, height: 50)
//        btnLocate.setImage(#imageLiteral(resourceName: "imgLocation"), for: UIControlState.normal)
//        uiviewSwipedBtnsView.addSubview(btnLocate)
        
        btnUnSave.addTarget(self, action: #selector(self.actionUnsaveCurrentCell(_:)), for: .touchUpInside)
        btnShare.addTarget(self, action: #selector(self.actionShareCurrentCell(_:)), for: .touchUpInside)
//        btnLocate.addTarget(self, action: #selector(self.actionLocateCurrentCell(_:)), for: .touchUpInside)
        
        imgAvatar = UIImageView()
        imgAvatar.frame = CGRect(x: 13, y:11, width: 20, height: 20)
        imgAvatar.layer.cornerRadius = 10
        imgAvatar.contentMode = .scaleAspectFill
        imgAvatar.layer.masksToBounds = true
        
        uiviewPinView.addSubview(imgAvatar)
        lblUserName = UILabel()
        lblUserName.frame = CGRect(x: 39, y:12, width: 140, height: 18)
        lblUserName.font = UIFont(name: "AvenirNext-Medium",size: 13)
        lblUserName.textAlignment = NSTextAlignment.left
        lblUserName.textColor = UIColor.faeAppInputTextGrayColor()
        lblDate.textAlignment = NSTextAlignment.right
        lblDate.textColor = UIColor.faeAppInputPlaceholderGrayColor()
        uiviewPinView.addSubview(lblUserName)
        
        finishedPositionX = 161.0 //231.0
    }
    
    // call this fuction when reuse cell, set value to the cell and rebuild the layout
    override func setValueForCell(_ pin: [String: AnyObject]) {
        super.setValueForCell(pin)
        uiviewPinView.addConstraintsWithFormat("H:[v0(200)]-13-|", options: [], views: lblDate)
        if (pin["anonymous"] as? Bool)! {
            lblUserName.text = "Anonymous"
            self.imgAvatar.image = #imageLiteral(resourceName: "defaultMen")
        } else {
            lblUserName.text = pin["nick_name"]as? String
            if let pinUserId = pin["user_id"] as? Int {
                let stringHeaderURL = "\(baseURL)/files/users/\(pinUserId)/avatar"
                self.imgAvatar.sd_setImage(with: URL(string: stringHeaderURL), placeholderImage: Key.sharedInstance.imageDefaultMale, options: [.retryFailed, .refreshCached], completed: { (image, error, SDImageCacheType, imageURL) in
                    if image == nil {
                        //RealmSwift
                    }
                })
            }
        }
    }
    
    // delete current cell
    func actionUnsaveCurrentCell(_ sender: UIButton) {
        self.delegate?.toDoItemUnsaved(indexCell: self.indexForCurrentCell, pinId: self.pinId, pinType: self.pinType)
    }
    
    // share current cell
    func actionShareCurrentCell(_ sender: UIButton) {
        self.delegate?.toDoItemShared(indexCell: self.indexForCurrentCell, pinId: self.pinId, pinType: self.pinType)
    }
    
    // locate current cell
    func actionLocateCurrentCell(_ sender: UIButton) {
        self.delegate?.toDoItemLocated(indexCell: self.indexForCurrentCell, pinId: self.pinId, pinType: self.pinType)
    }
    
}
