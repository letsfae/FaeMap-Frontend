//
//  CreateMomentPinViewController.swift
//  faeBeta
//
//  Created by Yue on 11/24/16.
//  Copyright © 2016 fae. All rights reserved.
//

import UIKit
import CoreLocation

class CreateMomentPinViewController: UIViewController {
    
    weak var delegate: CreatePinDelegate?
    
    // MARK: -- Create Media Pin
    var uiviewCreateMediaPin: UIView!
    var labelSelectLocationContent: UILabel!
    var textViewForMediaPin: UITextView!
    var lableTextViewPlaceholder: UILabel!
    var buttonTakeMedia: UIButton!
    var buttonSelectMedia: UIButton!
    
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
    var currentLocation2D = CLLocationCoordinate2DMake(34.0205378, -118.2854081)
    var zoomLevel: Float = 13.8
    var zoomLevelCallBack: Float = 13.8
    
    // MARK: -- Buttons
    var buttonMediaSubmit: UIButton!
    
    // MARK: -- Keyboard Tool Bar
    var inputToolbar: CreatePinInputToolbar!
    
    //MARK: -- Emoji View
    var emojiView: StickerPickView!
    var isShowingEmoji: Bool = false
    
    // MARK: -- uiview containers to hold two toolbars
    var uiviewSelectLocation: UIView!
    var uiviewMoreOptions: UIView!
    var uiviewAddDescription: UIView!
    
    var labelCreateMediaPinTitle: UILabel! // Create Media pin title
    var labelMediaPinMoreOptions: UILabel! // Title of Media pin options when creating
    var labelMediaPinAddDes: UILabel! // Title of Media pin options when creating
    var buttonAnonymous: UIButton!
    // MARK: -- MoreOption Table
    var tableMoreOptions: CreatePinOptionsTableView!
    enum CreatePinViewOptions {
        case moreOptionsTable
        case addTags
    }
    // MARK: -- Add Tags
    var textAddTags: CreatePinAddTagsTextView!
    var currentView: CreatePinViewOptions = .moreOptionsTable
    
    var imagePicker: UIImagePickerController!
    var buttonBack: UIButton!
    var selectedMediaArray = [UIImage]()
    var collectionViewMedia: UICollectionView!
    var anonymous = false
    var activityIndicator: UIActivityIndicatorView!
    
    var labelAddDesContent: UILabel!
    
    var btnDoAnony: UIButton!
    var switchAnony: UISwitch!
    
    enum Direction {
        case left
        case right
    }
    var direction: Direction = .right
    
    var buttonAddMedia: UIButton!
    var lastContentOffset: CGFloat = -999
    
    override func viewDidLoad() {
        super.viewDidLoad()
        loadCreateMediaPinView()
        addObservers()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        UIView.animate(withDuration: 0.2, delay: 0, options: .curveEaseOut, animations: {
            self.uiviewCreateMediaPin.alpha = 1.0
            }, completion: nil)
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
    
    func randomLocation() -> CLLocationCoordinate2D {
        let lat = currentLocation2D.latitude
        let lon = currentLocation2D.longitude
        let random_lat = Double.random(min: -0.004, max: 0.004)
        let random_lon = Double.random(min: -0.004, max: 0.004)
        return CLLocationCoordinate2DMake(lat+random_lat, lon+random_lon)
    }
}
