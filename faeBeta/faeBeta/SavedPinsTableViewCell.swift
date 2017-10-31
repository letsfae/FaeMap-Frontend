//
//  SavedPinsTableViewCell.swift
//  faeBeta
//  Created by Shiqi Wei on 1/22/17.
//  Edited by Sophie Wang
//  Copyright © 2016 fae. All rights reserved.
//

import UIKit

class SavedPinsTableViewCell: PinsTableViewCell {
    
    var imgAvatar: UIImageView!
    var lblNickName: UILabel!
    
    var btnUnSave: UIButton!
    //    var btnLocate : UIButton!
    var btnShare: UIButton!
    
    // Setup the cell when creat it
    override func setUpUI() {
        super.setUpUI()
        
        // lblDate's horizontal constraint is set
        uiviewPinView.addConstraintsWithFormat("H:[v0(200)]-13-|", options: [], views: lblDate)
        lblDate.textAlignment = .right
        
        imgAvatar = UIImageView(frame: CGRect(x: 13, y: 11, width: 20, height: 20))
        imgAvatar.layer.cornerRadius = 10
        imgAvatar.contentMode = .scaleAspectFill
        imgAvatar.layer.masksToBounds = true
        uiviewPinView.addSubview(imgAvatar)
        
        lblNickName = UILabel()
        lblNickName.frame = CGRect(x: 39, y: 12, width: 140, height: 18)
        lblNickName.font = UIFont(name: "AvenirNext-Medium", size: 13)
        lblNickName.textAlignment = .left
        lblNickName.textColor = UIColor._898989()
        uiviewPinView.addSubview(lblNickName)
        
        // set the swiped button after swipe the cell
        btnUnSave = UIButton()
        btnUnSave.frame = CGRect(x: screenWidth - 70, y: 0, width: 50, height: 50)
        btnUnSave.setImage(#imageLiteral(resourceName: "imgUnSave"), for: .normal)
        uiviewSwipedBtnsView.addSubview(btnUnSave)
        
        btnShare = UIButton()
        btnShare.frame = CGRect(x: screenWidth - 140, y: 0, width: 50, height: 50)
        btnShare.setImage(#imageLiteral(resourceName: "imgShare"), for: UIControlState.normal)
        uiviewSwipedBtnsView.addSubview(btnShare)
        
        //        btnLocate = UIButton()
        //        btnLocate.frame = CGRect(x: screenWidth-210, y: 0, width: 50, height: 50)
        //        btnLocate.setImage(#imageLiteral(resourceName: "imgLocation"), for: UIControlState.normal)
        //        uiviewSwipedBtnsView.addSubview(btnLocate)
        
        btnUnSave.addTarget(self, action: #selector(actionUnsaveCurrentCell(_:)), for: .touchUpInside)
        btnShare.addTarget(self, action: #selector(actionShareCurrentCell(_:)), for: .touchUpInside)
        //        btnLocate.addTarget(self, action: #selector(self.actionLocateCurrentCell(_:)), for: .touchUpInside)
        
        finishedPositionX = 161.0 // 231.0
    }
    
    // call this fuction when reuse cell, set value to the cell and rebuild the layout
    override func setValueForCell(_ pin: MapPinCollections) {
        super.setValueForCell(pin)
        
        lblNickName.text = pin.nickName
        
        General.shared.avatar(userid: pin.userId, completion: { (avatarImage) in
            self.imgAvatar.image = avatarImage
        })
    }
    
    // delete current cell
    @objc func actionUnsaveCurrentCell(_ sender: UIButton) {
        delegate?.toDoItemUnsaved(indexCell: indexForCurrentCell, pinId: intPinId, pinType: strPinType)
    }
    
    // share current cell
    @objc func actionShareCurrentCell(_ sender: UIButton) {
        delegate?.toDoItemShared(indexCell: indexForCurrentCell, pinId: intPinId, pinType: strPinType)
    }
    
    // locate current cell
    func actionLocateCurrentCell(_ sender: UIButton) {
        delegate?.toDoItemLocated(indexCell: indexForCurrentCell, pinId: intPinId, pinType: strPinType)
    }
    
    // Vertical center the buttons when the cell is created
    override func verticalCenterButtons() {
        btnUnSave.center.y = uiviewCellView.center.y
        //        btnLocate.center.y = uiviewCellView.center.y
        btnShare.center.y = uiviewCellView.center.y
    }
}
