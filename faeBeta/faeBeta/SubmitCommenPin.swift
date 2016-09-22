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
        blurViewMap.hidden = true
        blurViewMap.alpha = 0.0
        faeMapView.addSubview(imagePinOnMap)
        buttonToNorth.hidden = true
        buttonChatOnMap.hidden = true
        buttonPinOnMap.hidden = true
//        buttonPinOnMapInside.hidden = true
        buttonSetLocationOnMap.hidden = false
        imagePinOnMap.hidden = false
        navigationController?.navigationBar.hidden = true
        searchBarSubview.alpha = 1.0
        searchBarSubview.hidden = false
        tblSearchResults.hidden = false
        uiviewTableSubview.hidden = false
        customSearchController.customSearchBar.text = ""
        buttonSelfPosition.hidden = false
        buttonCancelSelectLocation.hidden = false
        isInPinLocationSelect = true
        myPositionIcon.hidden = true
        myPositionOutsideMarker_1.hidden = true
        myPositionOutsideMarker_2.hidden = true
        myPositionOutsideMarker_3.hidden = true
    }
    
    func actionCancelSelectLocation(sender: UIButton!) {
        isInPinLocationSelect = false
        searchBarSubview.hidden = true
        tblSearchResults.hidden = true
        uiviewTableSubview.hidden = true
        imagePinOnMap.hidden = true
        buttonSetLocationOnMap.hidden = true
        buttonSelfPosition.hidden = true
        buttonCancelSelectLocation.hidden = true
        blurViewMap.hidden = false
        blurViewMap.alpha = 1.0
        myPositionIcon.hidden = false
        myPositionOutsideMarker_1.hidden = false
        myPositionOutsideMarker_2.hidden = false
        myPositionOutsideMarker_3.hidden = false
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
        textViewForCommentPin.endEditing(true)
        if textViewForCommentPin.text == "" {
            buttonCommentSubmit.backgroundColor = UIColor.lightGrayColor()
            buttonCommentSubmit.enabled = false
        }
    }
    
    func actionCloseSubmitPins(sender: UIButton!) {
        submitPinsHideAnimation()
        buttonToNorth.hidden = false
        buttonSelfPosition.hidden = false
        buttonChatOnMap.hidden = false
        buttonPinOnMap.hidden = false
//        buttonPinOnMapInside.hidden = false
        buttonSetLocationOnMap.hidden = true
        imagePinOnMap.hidden = true
        navigationController?.navigationBar.hidden = false
        searchBarSubview.hidden = true
        tblSearchResults.hidden = true
        uiviewTableSubview.hidden = true
        textViewForCommentPin.text = ""
        textViewForCommentPin.endEditing(true)
        lableTextViewPlaceholder.hidden = false
        buttonCommentSubmit.backgroundColor = UIColor.lightGrayColor()
        buttonCommentSubmit.enabled = false
    }
    
    func actionSetLocationForComment(sender: UIButton!) {
        // May have bug here
        let valueInSearchBar = customSearchController.customSearchBar.text
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
            labelSelectLocationContent.text = valueInSearchBar
        }
        isInPinLocationSelect = false
        searchBarSubview.hidden = true
        tblSearchResults.hidden = true
        uiviewTableSubview.hidden = true
        imagePinOnMap.hidden = true
        buttonSetLocationOnMap.hidden = true
        buttonSelfPosition.hidden = true
        buttonCancelSelectLocation.hidden = true
        blurViewMap.hidden = false
        blurViewMap.alpha = 1.0
        myPositionIcon.hidden = false
        myPositionOutsideMarker_1.hidden = false
        myPositionOutsideMarker_2.hidden = false
        myPositionOutsideMarker_3.hidden = false
    }
    
    func actionSubmitComment(sender: UIButton) {
        
        let postSingleComment = FaeMap()
        var submitLatitude = ""
        var submitLongitude = ""
        
        if labelSelectLocationContent.text == "Current Location" {
            submitLatitude = "\(currentLatitude)"
            submitLongitude = "\(currentLongitude)"
        }
        else {
            submitLatitude = "\(latitudeForPin)"
            submitLongitude = "\(longitudeForPin)"
        }
        
        let commentContent = textViewForCommentPin.text
        
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
//                    buttonPinOnMapInside.hidden = false
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
