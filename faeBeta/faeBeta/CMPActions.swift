//
//  CMPActions.swift
//  faeBeta
//
//  Created by Yue on 11/24/16.
//  Copyright © 2016 fae. All rights reserved.
//

import UIKit
import SwiftyJSON
import CoreLocation

extension CreateMomentPinViewController {
    
    func actionTakeMedia(_ sender: UIButton) {
        let nav = UIStoryboard(name: "Chat", bundle: nil).instantiateViewController(withIdentifier: "FullAlbumNavigationController")
        let imagePicker = nav.childViewControllers.first as! FullAlbumCollectionViewController
        imagePicker.imageDelegate = self

        self.present(nav, animated: true, completion: nil)
    }
    
    func actionShowMoreOptions(_ sender: UIButton) {
        UIView.animate(withDuration: 0.4) {
            self.uiviewSelectLocation.alpha = 0
            self.uiviewMoreOptions.alpha = 0
            self.uiviewAddDescription.alpha = 0
            self.labelCreateMediaPinTitle.alpha = 0
            self.buttonMediaSubmit.alpha = 0
            
            self.labelMediaPinMoreOptions.alpha = 1
            self.uiviewDuration.alpha = 1
            self.uiviewInterRadius.alpha = 1
            self.uiviewPinPromot.alpha = 1
            self.buttonBack.alpha = 1
        }
    }
    
    func actionShowAddDes(_ sender: UIButton) {
        UIView.animate(withDuration: 0.4) {
            self.uiviewSelectLocation.alpha = 0
            self.uiviewMoreOptions.alpha = 0
            self.uiviewAddDescription.alpha = 0
            self.labelCreateMediaPinTitle.alpha = 0
            self.buttonMediaSubmit.alpha = 0
            
            self.labelMediaPinAddDes.alpha = 1
            self.buttonBack.alpha = 1
            self.textViewForMediaPin.alpha = 1
        }
    }
    
    func actionBack(_ sender: UIButton) {
        UIView.animate(withDuration: 0.4) {
            self.uiviewSelectLocation.alpha = 1
            self.uiviewMoreOptions.alpha = 1
            self.uiviewAddDescription.alpha = 1
            self.labelCreateMediaPinTitle.alpha = 1
            self.buttonMediaSubmit.alpha = 1
            
            self.labelMediaPinMoreOptions.alpha = 0
            self.uiviewDuration.alpha = 0
            self.uiviewInterRadius.alpha = 0
            self.uiviewPinPromot.alpha = 0
            self.buttonBack.alpha = 0
            self.textViewForMediaPin.alpha = 0
            self.labelMediaPinAddDes.alpha = 0
        }
    }
    
    func actionFinishEditing(_ sender: UIButton) {
        textViewForMediaPin.endEditing(true)
        textViewForMediaPin.resignFirstResponder()
    }
    
    func actionBackToPinSelections(_ sender: UIButton) {
        UIView.animate(withDuration: 0.2, delay: 0, options: .transitionFlipFromBottom, animations: ({
            self.uiviewCreateMediaPin.alpha = 0.0
        }), completion: { (done: Bool) in
            if done {
                self.dismiss(animated: false, completion: nil)
                self.delegate?.backFromCMP(back: true)
            }
        })
    }
    
    func actionCloseSubmitPins(_ sender: UIButton!) {
        self.dismiss(animated: false, completion: {
            self.delegate?.closePinMenuCMP(close: true)
        })
    }
    
    func actionSubmitMedia(_ sender: UIButton) {
        let postSingleMedia = FaeMap()
        
        var submitLatitude = selectedLatitude
        var submitLongitude = selectedLongitude
        
        let mediaContent = textViewForMediaPin.text
        
        if labelSelectLocationContent.text == "Current Location" {
            submitLatitude = "\(currentLatitude)"
            submitLongitude = "\(currentLongitude)"
        }
        
        if mediaContent == "" {
            return
        }
        
        postSingleMedia.whereKey("geo_latitude", value: submitLatitude)
        postSingleMedia.whereKey("geo_longitude", value: submitLongitude)
        postSingleMedia.whereKey("content", value: mediaContent)
        postSingleMedia.whereKey("interaction_radius", value: "99999999")
        postSingleMedia.whereKey("duration", value: "180")
        
        postSingleMedia.postComment{(status: Int, message: Any?) in
            if let getMessage = message as? NSDictionary{
                print("Have Post Media")
                if let getMessageID = getMessage["comment_id"] {
                    let getJustPostedMedia = FaeMap()
                    getJustPostedMedia.getComment("\(getMessageID)"){(status: Int, message: Any?) in
                        print("Have got comment_id of this posted comment")
                        let latDouble = Double(submitLatitude!)
                        let longDouble = Double(submitLongitude!)
                        let lat = CLLocationDegrees(latDouble!)
                        let long = CLLocationDegrees(longDouble!)
                        self.dismiss(animated: false, completion: {
                            self.delegate?.sendMediaGeoInfo(mediaID: "\(getMessageID)", latitude: lat, longitude: long)
                        })
                    }
                }
                else {
                    print("Cannot get media_id of this posted media")
                }
            }
            else {
                print("Post Media Fail")
            }
        }
    }
}
