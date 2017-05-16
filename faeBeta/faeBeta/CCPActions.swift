//
//  CCPActions.swift
//  faeBeta
//
//  Created by Yue on 11/15/16.
//  Copyright © 2016 fae. All rights reserved.
//

import UIKit
import SwiftyJSON
import CoreLocation

extension CreateCommentPinViewController {
    
    func showAlert(title: String, message: String) {
        let alertController = UIAlertController(title: title, message: message, preferredStyle: UIAlertControllerStyle.alert)
        let okAction = UIAlertAction(title: "OK", style: UIAlertActionStyle.destructive)
        alertController.addAction(okAction)
        self.present(alertController, animated: true, completion: nil)
    }
    
    func actionAnonymous(_ sender: UIButton) {
        if sender.tag == 0 {
            sender.tag = 1
            sender.setImage(UIImage(named: "anonymousClicked"), for: UIControlState())
            anonymous = true
        }
        else {
            sender.tag = 0
            sender.setImage(UIImage(named: "anonymousUnclicked"), for: UIControlState())
            anonymous = false
        }
    }
    
    func actionShowOrHideMoreOptions(_ sender: UIButton) {
        let toValue = CGFloat(sender.tag)
        let fromValue = 1.0-toValue
        
        UIView.animate(withDuration: 0.4) {
            
        }
        
        UIView.animate(withDuration: 0.4, animations: { 
            self.textViewForCommentPin.alpha = fromValue
            self.uiviewSelectLocation.alpha = fromValue
            self.uiviewMoreOptions.alpha = fromValue
            self.labelCreateCommentPinTitle.alpha = fromValue
            self.buttonCommentSubmit.alpha = fromValue
            
            self.labelCommentPinMoreOptions.alpha = toValue
            self.uiviewDuration.alpha = toValue
            self.uiviewInterRadius.alpha = toValue
            self.uiviewPinPromot.alpha = toValue
            self.buttonBack.alpha = toValue
        }) { (_) in
            if toValue == 1.0 {
                self.showAlert(title: "This feature is coming soon in the next version!", message: "")
            }
        }
    }
    
    func actionFinishEditing(_ sender: UIButton) {
        textViewForCommentPin.endEditing(true)
        textViewForCommentPin.resignFirstResponder()
    }
    
    func actionBackToPinSelections(_ sender: UIButton) {
        UIView.animate(withDuration: 0.2, delay: 0, options: .transitionFlipFromBottom, animations: ({
            self.uiviewCreateCommentPin.alpha = 0.0
        }), completion: { (done: Bool) in
            if done {
                self.dismiss(animated: false, completion: nil)
                self.delegate?.backFromPinCreating(back: true)
            }
        })
    }
    
    func actionCloseSubmitPins(_ sender: UIButton!) {
        self.dismiss(animated: false, completion: {
            self.delegate?.closePinMenu(close: true)
        })
    }
    
    func actionSubmitComment(_ sender: UIButton) {
        let postSingleComment = FaeMap()
        
        var submitLatitude = selectedLatitude
        var submitLongitude = selectedLongitude
        
        let commentContent = textViewForCommentPin.text
        
        if labelSelectLocationContent.text == "Current Map View" { //Changed by Yao cause the default text is "Current Map View"
            let defaultLoc = randomLocation()
            submitLatitude = "\(defaultLoc.latitude)"
            submitLongitude = "\(defaultLoc.longitude)"
        }
        
        if commentContent == "" {
            return
        }
        
        postSingleComment.whereKey("geo_latitude", value: submitLatitude)
        postSingleComment.whereKey("geo_longitude", value: submitLongitude)
        postSingleComment.whereKey("content", value: commentContent)
        postSingleComment.whereKey("interaction_radius", value: "99999999")
        postSingleComment.whereKey("duration", value: "180")
        postSingleComment.whereKey("anonymous", value: "\(switchAnony.isOn)")
        
        postSingleComment.postPin(type: "comment") {(status: Int, message: Any?) in
            if status / 100 != 2 {
                return
            }
            if let getMessage = message as? NSDictionary{
                print("Have Post Comment")
                if let getMessageID = getMessage["comment_id"] {
                    let getJustPostedComment = FaeMap()
                    getJustPostedComment.getPin(type: "comment", pinId: "\(getMessageID)"){(status: Int, message: Any?) in
                        print("Have got comment_id of this posted comment")
                        let latDouble = Double(submitLatitude!)
                        let longDouble = Double(submitLongitude!)
                        let lat = CLLocationDegrees(latDouble!)
                        let long = CLLocationDegrees(longDouble!)
                        self.dismiss(animated: false, completion: {
                            self.delegate?.sendGeoInfo(pinID: "\(getMessageID)", type: "comment", latitude: lat, longitude: long, zoom: self.zoomLevelCallBack)
                        })
                    }
                }
                else {
                    print("Cannot get comment_id of this posted comment")
                }
            }
            else {
                print("Post Comment Fail")
            }
        }
        
        print("sfasd")
    }
}
