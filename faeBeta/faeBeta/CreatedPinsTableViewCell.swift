//
//  CreatedPinsTableViewCell.swift
//  faeBeta
//  Created by Shiqi Wei on 4/17/17.
//  Editted by Sophie Wang
//  Copyright © 2016 fae. All rights reserved.
//

import UIKit
import RealmSwift
import SwiftyJSON

class CreatedPinsTableViewCell: PinsTableViewCell {
    
    var lblTime: UILabel!
    var btnRemove: UIButton!
    var btnLocate: UIButton!
    var btnShare: UIButton!
    var btnEdit: UIButton!
    var btnVisible: UIButton!
    
    override func setValueForCell(_ pin: MapPinCollections) {
        super.setValueForCell(pin)
        lblTime.text = pin.date.formatLeftOnMap(durationOnMap: 3)
    }
    
    override func setUpUI() {
        super.setUpUI()
        
        // lblDate's horizontal constraint is set
        uiviewPinView.addConstraintsWithFormat("H:|-13-[v0(200)]", options: [], views: lblDate)
        
        lblTime = UILabel()
        lblTime.font = UIFont(name: "AvenirNext-Medium", size: 13)
        lblTime.textAlignment = .right
        lblTime.textColor = UIColor._155155155()
        uiviewPinView.addSubview(lblTime)
        uiviewPinView.addConstraintsWithFormat("H:[v0(160)]-13-|", options: [], views: lblTime)
        uiviewPinView.addConstraintsWithFormat("V:|-12-[v0(18)]", options: [], views: lblTime)
        
        btnRemove = UIButton()
        btnRemove.frame = CGRect(x: screenWidth - 70, y: 0, width: 50, height: 50)
        btnRemove.setImage(#imageLiteral(resourceName: "imgRemove"), for: UIControlState.normal)
        uiviewSwipedBtnsView.addSubview(btnRemove)
        
        btnEdit = UIButton()
        btnEdit.frame = CGRect(x: screenWidth - 140, y: 0, width: 50, height: 50)
        btnEdit.setImage(#imageLiteral(resourceName: "imgEdit"), for: UIControlState.normal)
        uiviewSwipedBtnsView.addSubview(btnEdit)
        
        btnShare = UIButton()
        btnShare.frame = CGRect(x: screenWidth - 210, y: 0, width: 50, height: 50)
        btnShare.setImage(#imageLiteral(resourceName: "imgShare"), for: UIControlState.normal)
        uiviewSwipedBtnsView.addSubview(btnShare)
        
        btnVisible = UIButton()
        btnVisible.frame = CGRect(x: screenWidth - 280, y: 0, width: 50, height: 50)
        btnVisible.setImage(#imageLiteral(resourceName: "imgInvisible"), for: UIControlState.normal)
        uiviewSwipedBtnsView.addSubview(btnVisible)
        
        btnLocate = UIButton()
        btnLocate.frame = CGRect(x: screenWidth - 350, y: 0, width: 50, height: 50)
        btnLocate.setImage(#imageLiteral(resourceName: "imgLocation"), for: UIControlState.normal)
        uiviewSwipedBtnsView.addSubview(btnLocate)
        
        btnRemove.addTarget(self, action: #selector(actionRemoveCurrentCell(_:)), for: .touchUpInside)
        btnEdit.addTarget(self, action: #selector(actionEditCurrentCell(_:)), for: .touchUpInside)
        btnShare.addTarget(self, action: #selector(actionShareCurrentCell(_:)), for: .touchUpInside)
        btnVisible.addTarget(self, action: #selector(actionVisibleCurrentCell(_:)), for: .touchUpInside)
        btnLocate.addTarget(self, action: #selector(actionLocateCurrentCell(_:)), for: .touchUpInside)
        
        finishedPositionX = 370.0
    }
    
    // delete current cell
    @objc func actionRemoveCurrentCell(_ sender: UIButton) {
        delegate?.toDoItemRemoved(indexCell: indexForCurrentCell, pinId: intPinId, pinType: strPinType)
    }
    
    // edit current cell
    @objc func actionEditCurrentCell(_ sender: UIButton) {
        delegate?.toDoItemEdit(indexCell: indexForCurrentCell, pinId: intPinId, pinType: strPinType)
    }
    
    // share current cell
    @objc func actionShareCurrentCell(_ sender: UIButton) {
        delegate?.toDoItemShared(indexCell: indexForCurrentCell, pinId: intPinId, pinType: strPinType)
    }
    
    // make current cell visible or invisible
    @objc func actionVisibleCurrentCell(_ sender: UIButton) {
        delegate?.toDoItemVisible(indexCell: indexForCurrentCell, pinId: intPinId, pinType: strPinType)
    }
    
    // locate current cell
    @objc func actionLocateCurrentCell(_ sender: UIButton) {
        delegate?.toDoItemLocated(indexCell: indexForCurrentCell, pinId: intPinId, pinType: strPinType)
    }
    
    override func verticalCenterButtons() {
        btnRemove.center.y = uiviewCellView.center.y
        btnLocate.center.y = uiviewCellView.center.y
        btnShare.center.y = uiviewCellView.center.y
        btnEdit.center.y = uiviewCellView.center.y
        btnVisible.center.y = uiviewCellView.center.y
    }
}
