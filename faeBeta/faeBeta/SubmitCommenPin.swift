//
//  SubmitCommenPin.swift
//  faeBeta
//
//  Created by Yue on 9/12/16.
//  Copyright © 2016 fae. All rights reserved.
//

import UIKit
import GoogleMaps
import SwiftyJSON

extension FaeMapViewController {
    func actionSelectLocation(sender: UIButton!) {
        self.blurViewMap.hidden = true
        self.blurViewMap.alpha = 0.0
        self.faeMapView.addSubview(imagePinOnMap)
        self.buttonToNorth.hidden = true
        self.buttonChatOnMap.hidden = true
        self.buttonPinOnMap.hidden = true
        self.buttonPinOnMapInside.hidden = true
        self.buttonSetLocationOnMap.hidden = false
        self.imagePinOnMap.hidden = false
        self.navigationController?.navigationBar.hidden = true
        self.searchBarSubview.alpha = 1.0
        self.searchBarSubview.hidden = false
        self.tblSearchResults.hidden = false
        self.uiviewTableSubview.hidden = false
        self.customSearchController.customSearchBar.text = ""
        self.buttonSelfPosition.hidden = false
        self.buttonCancelSelectLocation.hidden = false
        self.isInPinLocationSelect = true
        self.myPositionIcon.hidden = true
        self.myPositionOutsideMarker_1.hidden = true
        self.myPositionOutsideMarker_2.hidden = true
        self.myPositionOutsideMarker_3.hidden = true
        self.view.addConstraintsWithFormat("H:[v0(59)]-16-|", options: [], views: buttonSelfPosition)
        self.view.addConstraintsWithFormat("V:[v0(59)]-81-|", options: [], views: buttonSelfPosition)
    }
    
    func actionCancelSelectLocation(sender: UIButton!) {
        self.isInPinLocationSelect = false
        self.searchBarSubview.hidden = true
        self.tblSearchResults.hidden = true
        self.uiviewTableSubview.hidden = true
        self.imagePinOnMap.hidden = true
        self.buttonSetLocationOnMap.hidden = true
        self.buttonSelfPosition.hidden = true
        self.buttonSelfPosition.center.x = 362.5
        self.buttonSelfPosition.center.y = 611.5
        self.buttonCancelSelectLocation.hidden = true
        self.blurViewMap.hidden = false
        self.blurViewMap.alpha = 1.0
        self.myPositionIcon.hidden = false
        self.myPositionOutsideMarker_1.hidden = false
        self.myPositionOutsideMarker_2.hidden = false
        self.myPositionOutsideMarker_3.hidden = false
        self.view.addConstraintsWithFormat("H:[v0(59)]-22-|", options: [], views: buttonSelfPosition)
        self.view.addConstraintsWithFormat("V:[v0(59)]-95-|", options: [], views: buttonSelfPosition)
    }
    
    func actionCreateCommentPin(sender: UIButton!) {
        UIView.animateWithDuration(0.4, delay: 0, options: .TransitionFlipFromBottom, animations: ({
            self.uiviewPinSelections.alpha = 0.0
            self.uiviewCreateCommentPin.alpha = 1.0
        }), completion: nil)
        labelSelectLocationContent.text = "Current Location"
    }
    
    func actionBackToPinSelections(sender: UIButton!) {
        UIView.animateWithDuration(0.4, delay: 0, options: .TransitionFlipFromBottom, animations: ({
            self.uiviewPinSelections.alpha = 1.0
            self.uiviewCreateCommentPin.alpha = 0.0
        }), completion: nil)
        self.textViewForCommentPin.endEditing(true)
        if self.textViewForCommentPin.text == "" {
            self.buttonCommentSubmit.backgroundColor = UIColor.lightGrayColor()
            self.buttonCommentSubmit.enabled = false
        }
    }
    
    func actionCloseSubmitPins(sender: UIButton!) {
        self.submitPinsHideAnimation()
        self.buttonToNorth.hidden = false
        self.buttonSelfPosition.hidden = false
        self.buttonChatOnMap.hidden = false
        self.buttonPinOnMap.hidden = false
        self.buttonPinOnMapInside.hidden = false
        self.buttonSetLocationOnMap.hidden = true
        self.imagePinOnMap.hidden = true
        self.navigationController?.navigationBar.hidden = false
        self.searchBarSubview.hidden = true
        self.tblSearchResults.hidden = true
        self.uiviewTableSubview.hidden = true
        self.textViewForCommentPin.text = ""
        self.textViewForCommentPin.endEditing(true)
        self.lableTextViewPlaceholder.hidden = false
        self.buttonCommentSubmit.backgroundColor = UIColor.lightGrayColor()
        self.buttonCommentSubmit.enabled = false
    }
    
    func actionSetLocationForComment(sender: UIButton!) {
        // May have bug here
        let valueInSearchBar = self.customSearchController.customSearchBar.text
        if valueInSearchBar == "" {
            let mapCenter = CGPointMake(screenWidth/2, screenHeight/2)
            let mapCenterCoordinate = faeMapView.projection.coordinateForPoint(mapCenter)
            GMSGeocoder().reverseGeocodeCoordinate(mapCenterCoordinate, completionHandler: {
                (response, error) -> Void in
                if let fullAddress = response?.firstResult()?.lines {
                    var addressToSearchBar = ""
                    for line in fullAddress {
                        if line == "" {
                            continue
                        }
                        else if fullAddress.indexOf(line) == fullAddress.count-1 {
                            addressToSearchBar += line + ""
                        }
                        else {
                            addressToSearchBar += line + ", "
                        }
                    }
                    self.labelSelectLocationContent.text = addressToSearchBar
                }
            })
        }
        else {
            self.labelSelectLocationContent.text = valueInSearchBar
        }
        self.isInPinLocationSelect = false
        self.searchBarSubview.hidden = true
        self.tblSearchResults.hidden = true
        self.uiviewTableSubview.hidden = true
        self.imagePinOnMap.hidden = true
        self.buttonSetLocationOnMap.hidden = true
        self.buttonSelfPosition.hidden = true
        self.buttonSelfPosition.center.x = 362.5
        self.buttonSelfPosition.center.y = 611.5
        self.buttonCancelSelectLocation.hidden = true
        self.blurViewMap.hidden = false
        self.blurViewMap.alpha = 1.0
        self.myPositionIcon.hidden = false
        self.myPositionOutsideMarker_1.hidden = false
        self.myPositionOutsideMarker_2.hidden = false
        self.myPositionOutsideMarker_3.hidden = false
        self.view.addConstraintsWithFormat("H:[v0(59)]-22-|", options: [], views: buttonSelfPosition)
        self.view.addConstraintsWithFormat("V:[v0(59)]-95-|", options: [], views: buttonSelfPosition)
    }
    
    func actionSubmitComment(sender: UIButton) {
        
        let postSingleComment = FaeMap()
        var submitLatitude = ""
        var submitLongitude = ""
        
        if self.labelSelectLocationContent.text == "Current Location" {
            submitLatitude = "\(self.currentLatitude)"
            submitLongitude = "\(self.currentLongitude)"
        }
        else {
            submitLatitude = "\(self.latitudeForPin)"
            submitLongitude = "\(self.longitudeForPin)"
        }
        
        let commentContent = self.textViewForCommentPin.text
        
        print(commentContent)
        
        if commentContent == "" {
            return
        }
        
        postSingleComment.whereKey("geo_latitude", value: submitLatitude)
        postSingleComment.whereKey("geo_longitude", value: submitLongitude)
        postSingleComment.whereKey("content", value: commentContent)
        
        
        postSingleComment.postComment{(status:Int,message:AnyObject?) in
            if let getMessage = message {
                if let getMessageID = getMessage["comment_id"] {
                    self.submitPinsHideAnimation()
                    let commentMarker = GMSMarker()
                    commentMarker.zIndex = 1
                    var mapCenter = self.faeMapView.center
                    // Attention: the actual location of this marker is 6 points different from the displayed one
                    mapCenter.y = mapCenter.y + 6.0
                    let mapCenterCoordinate = self.faeMapView.projection.coordinateForPoint(mapCenter)
                    commentMarker.icon = UIImage(named: "comment_pin_marker")
                    commentMarker.position = mapCenterCoordinate
                    commentMarker.appearAnimation = kGMSMarkerAnimationPop
                    commentMarker.map = self.faeMapView
                    self.buttonToNorth.hidden = false
                    self.buttonSelfPosition.hidden = false
                    self.buttonChatOnMap.hidden = false
                    self.buttonPinOnMap.hidden = false
                    self.buttonPinOnMapInside.hidden = false
                    self.buttonSetLocationOnMap.hidden = true
                    self.imagePinOnMap.hidden = true
                    self.navigationController?.navigationBar.hidden = false
                    
                    let getJustPostedComment = FaeMap()
                    
                    getJustPostedComment.getComment("\(getMessageID!)"){(status:Int,message:AnyObject?) in
                        let mapInfoJSON = JSON(message!)
                        var pinData = [String: AnyObject]()
                        
                        pinData["comment_id"] = getMessageID!
                        pinData["type"] = "comment"
                        
                        if let userIDInfo = mapInfoJSON["user_id"].int {
                            pinData["user_id"] = userIDInfo
                        }
                        if let createdTimeInfo = mapInfoJSON["created_at"].string {
                            pinData["created_at"] = createdTimeInfo
                        }
                        if let contentInfo = mapInfoJSON["content"].string {
                            pinData["content"] = contentInfo
                        }
                        if let latitudeInfo = mapInfoJSON["geolocation"]["latitude"].double {
                            pinData["latitude"] = latitudeInfo
                        }
                        if let longitudeInfo = mapInfoJSON["geolocation"]["longitude"].double {
                            pinData["longitude"] = longitudeInfo
                        }
                        commentMarker.userData = pinData
                    }
                    self.textViewForCommentPin.text = ""
                    self.lableTextViewPlaceholder.hidden = false
                }
                else {
                    print("Cannot get comment_id of this posted comment")
                }
            }
            else {
                print("Post Comment Fail")
            }
        }
    }
}