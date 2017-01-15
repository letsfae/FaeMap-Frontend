//
//  CreateCommentPinViewController.swift
//  faeBeta
//
//  Created by Yue on 11/15/16.
//  Copyright © 2016 fae. All rights reserved.
//

import UIKit
import CoreLocation

protocol CreateCommentPinDelegate: class {
    func sendCommentGeoInfo(pinID: String, latitude: CLLocationDegrees, longitude: CLLocationDegrees)
    func backFromCCP(back: Bool)
    func closePinMenu(close: Bool)
}

class CreateCommentPinViewController: UIViewController {
    
    weak var delegate: CreateCommentPinDelegate?

    // MARK: -- Create Comment Pin
    var uiviewCreateCommentPin: UIView!
    var labelSelectLocationContent: UILabel!
    var textViewForCommentPin: UITextView!
    var lableTextViewPlaceholder: UILabel!
    
    // MARK: -- Create Pin
    let colorPlaceHolder = UIColor(red: 234/255, green: 234/255, blue: 234/255, alpha: 1.0)
    
    // MARK: -- Geo Information Sent to Server
    var selectedLatitude: String!
    var selectedLongitude: String!
    
    // MARK: -- location manager
    var currentLocation: CLLocation!
    let locManager = CLLocationManager()
    var currentLatitude: CLLocationDegrees = 34.0205378
    var currentLongitude: CLLocationDegrees = -118.2854081
    
    // MARK: -- Buttons
    var buttonCommentSubmit: UIButton!
    
    // MARK: -- Keyboard Tool Bar
    var inputToolbar: CreatePinInputToolbar!
    
    //MARK: -- Emoji View
    var emojiView: StickerPickView!
    var isShowingEmoji: Bool = false
    
    // MARK: -- uiview containers to hold two toolbars
    var uiviewSelectLocation: UIView!
    var uiviewMoreOptions: UIView!
    
    var labelCreateCommentPinTitle: UILabel! // Create comment pin title
    var labelCommentPinMoreOptions: UILabel! // Title of comment pin options when creating
    
    var buttonAnonymous: UIButton!
    var anonymous = false
    
    var uiviewDuration: UIView!
    var uiviewInterRadius: UIView!
    var uiviewPinPromot: UIView!
    
    var buttonBack: UIButton!
    

    
    override func viewDidLoad() {
        super.viewDidLoad()
        loadCreateCommentPinView()
        loadKeyboardToolBar()
        loadEmojiView()
        addObservers()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        UIView.animate(withDuration: 0.2, delay: 0, options: .curveEaseOut, animations: {
            self.uiviewCreateCommentPin.alpha = 1.0
        }, completion: {(complete) in
            self.textViewForCommentPin.becomeFirstResponder()
        })
    }
    
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        currentLocation = locManager.location
        currentLatitude = currentLocation.coordinate.latitude
        currentLongitude = currentLocation.coordinate.longitude
    }
    
    func addObservers() {
        NotificationCenter.default.addObserver(self, selector: #selector(self.keyboardWillShow(_:)), name:NSNotification.Name.UIKeyboardWillShow, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(self.keyboardWillHide(_:)), name:NSNotification.Name.UIKeyboardWillHide, object: nil)
    }
    
    func keyboardWillShow(_ notification:Notification) {
        let userInfo:NSDictionary = notification.userInfo! as NSDictionary
        let keyboardFrame:NSValue = userInfo.value(forKey: UIKeyboardFrameEndUserInfoKey) as! NSValue
        let keyboardRectangle = keyboardFrame.cgRectValue
        let keyboardHeight = keyboardRectangle.height
        inputToolbar.alpha = 1
        UIView.animate(withDuration: 0.3,delay: 0, options: .curveLinear, animations:{
            Void in
            self.inputToolbar.frame.origin.y = screenHeight - keyboardHeight - 100
        }, completion: nil)
    }
    
    func keyboardWillHide(_ notification:Notification) {
        if(!isShowingEmoji){
            UIView.animate(withDuration: 0.3,delay: 0, options: .curveLinear, animations:{
                Void in
                self.inputToolbar.frame.origin.y = screenHeight - 100
                self.inputToolbar.alpha = 0
                self.view.layoutIfNeeded()
            }, completion: nil)
        }
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }

}
