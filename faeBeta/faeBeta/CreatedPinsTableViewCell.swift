//
//  CreatedPinsTableViewCell.swift
//  faeBeta
//  Created by Shiqi Wei on 4/17/17.
//  Copyright © 2016 fae. All rights reserved.
//

import UIKit

class CreatedPinsTableViewCell: PinsTableViewCell {
    
    var labelTime : UILabel!
    var btnRemove : UIButton!
    var btnLocate : UIButton!
    var btnShare : UIButton!
    var btnEdit : UIButton!
    var btnVisible : UIButton!
    
    // Vertical center the buttons when the cell is created
    override func verticalCenterButtons(){
        btnRemove.center.y = uiviewCellView.center.y
        btnLocate.center.y = uiviewCellView.center.y
        btnShare.center.y = uiviewCellView.center.y
        btnEdit.center.y = uiviewCellView.center.y
        btnVisible.center.y = uiviewCellView.center.y
    }

    // Setup the cell when creat it
    override func setUpUI() {
        super.setUpUI()
        // set the swiped button after swipe the cell
        btnRemove = UIButton()
        btnRemove.frame = CGRect(x: screenWidth-70, y: 0, width: 50, height: 50)
        btnRemove.setImage(#imageLiteral(resourceName: "imgRemove"), for: UIControlState.normal)
        uiviewSwipedBtnsView.addSubview(btnRemove)
        
        btnEdit = UIButton()
        btnEdit.frame = CGRect(x: screenWidth-140, y: 0, width: 50, height: 50)
        btnEdit.setImage(#imageLiteral(resourceName: "imgEdit"), for: UIControlState.normal)
        uiviewSwipedBtnsView.addSubview(btnEdit)
        
        btnShare = UIButton()
        btnShare.frame = CGRect(x: screenWidth-210, y: 0, width: 50, height: 50)
        btnShare.setImage(#imageLiteral(resourceName: "imgShare"), for: UIControlState.normal)
        uiviewSwipedBtnsView.addSubview(btnShare)
        
        btnVisible = UIButton()
        btnVisible.frame = CGRect(x: screenWidth-280, y: 0, width: 50, height: 50)
        btnVisible.setImage(#imageLiteral(resourceName: "imgInvisible"), for: UIControlState.normal)
        uiviewSwipedBtnsView.addSubview(btnVisible)

        btnLocate = UIButton()
        btnLocate.frame = CGRect(x: screenWidth-350, y: 0, width: 50, height: 50)
        btnLocate.setImage(#imageLiteral(resourceName: "imgLocation"), for: UIControlState.normal)
        uiviewSwipedBtnsView.addSubview(btnLocate)
        
        btnRemove.addTarget(self, action: #selector(self.actionRemoveCurrentCell(_:)), for: .touchUpInside)
        btnEdit.addTarget(self, action: #selector(self.actionEditCurrentCell(_:)), for: .touchUpInside)
        btnShare.addTarget(self, action: #selector(self.actionShareCurrentCell(_:)), for: .touchUpInside)
        btnVisible.addTarget(self, action: #selector(self.actionVisibleCurrentCell(_:)), for: .touchUpInside)
        btnLocate.addTarget(self, action: #selector(self.actionLocateCurrentCell(_:)), for: .touchUpInside)

        //set the time
        labelTime = UILabel()
        labelTime.font = UIFont(name: "AvenirNext-Medium",size: 13)
        labelTime.textAlignment = NSTextAlignment.right
        labelTime.textColor = UIColor.faeAppInputPlaceholderGrayColor()
        uiviewPinView.addSubview(labelTime)
        
        lblDate.textAlignment = NSTextAlignment.left
        lblDate.textColor = UIColor.faeAppTimeTextBlackColor()
        
        finishedPositionX = 370.0
        
    }
    
    // call this fuction when reuse cell, set value to the cell and rebuild the layout
    override func setValueForCell(_ pin: [String: AnyObject]) {
        super.setValueForCell(pin)
        if let createat = pin["created_at"]{
            labelTime.text = ((createat as! String).formatLeftOnMap(DurationOnMap : 3))
        }
        
    //Add the constraints in uiviewPinView
        uiviewPinView.addConstraintsWithFormat("H:|-13-[v0(200)]", options: [], views: lblDate)
        uiviewPinView.addConstraintsWithFormat("H:[v0(160)]-13-|", options: [], views: labelTime)
        uiviewPinView.addConstraintsWithFormat("V:|-12-[v0(18)]", options: [], views: labelTime)
        
    }
    
    // delete current cell
    func actionRemoveCurrentCell(_ sender: UIButton) {
        self.delegate?.toDoItemRemoved(indexCell: self.indexForCurrentCell, pinId: self.pinId, pinType: self.pinType)
    }
    
    // edit current cell
    func actionEditCurrentCell(_ sender: UIButton) {
        self.delegate?.toDoItemEdit(indexCell: self.indexForCurrentCell, pinId: self.pinId, pinType: self.pinType)
    }
    
    // share current cell
    func actionShareCurrentCell(_ sender: UIButton) {
        self.delegate?.toDoItemShared(indexCell: self.indexForCurrentCell, pinId: self.pinId, pinType: self.pinType)
    }
    
    // make current cell visible or invisible
    func actionVisibleCurrentCell(_ sender: UIButton) {
        self.delegate?.toDoItemVisible(indexCell: self.indexForCurrentCell, pinId: self.pinId, pinType: self.pinType)
    }
    
    // locate current cell
    func actionLocateCurrentCell(_ sender: UIButton) {
        self.delegate?.toDoItemLocated(indexCell: self.indexForCurrentCell, pinId: self.pinId, pinType: self.pinType)
    }
    
}
