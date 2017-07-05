//
//  CreateCommentPinViewController.swift
//  faeBeta
//
//  Created by Yue on 11/15/16.
//  Copyright © 2016 fae. All rights reserved.
//

import UIKit

class CreateCommentPinViewController: CreatePinBaseViewController {
    
    override func viewDidLoad() {
        pinType = .comment
        super.viewDidLoad()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        UIView.animate(withDuration: 0.2, delay: 0, options: .curveEaseOut, animations: {
            self.view.alpha = 1.0
        }, completion: {(complete) in
            self.textviewDescrip.becomeFirstResponder()
        })
    }
    
    override func setupBaseUI() {
        super.setupBaseUI()
        
        imgTitle.image = #imageLiteral(resourceName: "commentPinTitleImage")
        lblTitle.text = "Create Comment Pin"
        btnSubmit.backgroundColor = UIColor(red: 182/255, green: 159/255, blue: 202/255, alpha: 0.65)
        switchAnony.onTintColor = UIColor(red: 182/255, green: 159/255, blue: 202/255, alpha: 1)

        textviewDescrip.placeHolder = "Type a comment..."
        textviewDescrip.alpha = 1
    }
    
    override func loadTable() {
        super.loadTable()
        self.tblPinOptions.frame = CGRect(x: 0, y: screenHeight - CreatePinOptionsTableView.cellHeight * 2 - CGFloat(120), width: screenWidth, height: CreatePinOptionsTableView.cellHeight * 2)
    }

    override func switchToMoreOptions() {
        super.switchToMoreOptions()
        UIView.animate(withDuration: 0.4, animations: {
            Void in
            self.textviewDescrip.alpha = 0
            self.tblPinOptions.alpha = 0
            self.tblMoreOptions.alpha = 1
            self.lblTitle.text = "More Options"
            self.setSubmitButton(withTitle: "Back", isEnabled: true)
        }) { (_) in
            self.showAlert(title: "This feature is coming soon in the next version!", message: "")
            self.setSubmitButton(withTitle: "Back", isEnabled: true)
        }
    }
    
    override func leaveMoreOptions() {
        super.leaveMoreOptions()
        UIView.animate(withDuration: 0.4, animations: {
            Void in
            self.textviewDescrip.alpha = 1
            self.tblPinOptions.alpha = 1
            self.lblTitle.text = "Create Comment Pin"
            self.tblMoreOptions.alpha = 0
            self.setSubmitButton(withTitle: "Submit!", isEnabled: self.boolBtnSubmitEnabled)
        })
    }
    
//    func textViewDidEndEditing(_ textView: UITextView) {
//        print("textViewDidEndEditing")
//        updateSubmitButton()
//    }
//    
//    fileprivate func updateSubmitButton() {
//        boolBtnSubmitEnabled = (textviewDescrip.text?.characters.count)! > 0
//        setSubmitButton(withTitle: btnSubmit.currentTitle!, isEnabled: boolBtnSubmitEnabled)
//    }
    
    override func actionSubmit() {
        let postSingleComment = FaeMap()
        
        var submitLatitude = selectedLatitude
        var submitLongitude = selectedLongitude
        
        let commentContent = textviewDescrip.text
        
        if strSelectedLocation == nil || strSelectedLocation == "" {
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
