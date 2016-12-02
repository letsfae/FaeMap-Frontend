//
//  CreateMomentPinViewController.swift
//  faeBeta
//
//  Created by Yue on 11/24/16.
//  Copyright © 2016 fae. All rights reserved.
//

import UIKit
import CoreLocation

protocol CreateMediaPinDelegate: class {
    func sendMediaGeoInfo(mediaID: String, latitude: CLLocationDegrees, longitude: CLLocationDegrees)
    func backFromCMP(back: Bool)
    func closePinMenuCMP(close: Bool)
}

class CreateMomentPinViewController: UIViewController, UIScrollViewDelegate {
    
    weak var delegate: CreateMediaPinDelegate?
    
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
    
    // MARK: -- Buttons
    var buttonMediaSubmit: UIButton!
    
    // MARK: -- Keyboard Tool Bar
    var uiviewToolBar: UIView!
    var buttonOpenFaceGesPanel: UIButton!
    var buttonFinishEdit: UIButton!
    
    // MARK: -- Count Number of Characters
    var labelCountChars: UILabel!
    
    // MARK: -- uiview containers to hold two toolbars
    var uiviewSelectLocation: UIView!
    var uiviewMoreOptions: UIView!
    var uiviewAddDescription: UIView!
    
    var labelCreateMediaPinTitle: UILabel! // Create Media pin title
    var labelMediaPinMoreOptions: UILabel! // Title of Media pin options when creating
    var labelMediaPinAddDes: UILabel! // Title of Media pin options when creating
    var buttonAnonymous: UIButton!
    
    var uiviewDuration: UIView!
    var uiviewInterRadius: UIView!
    var uiviewPinPromot: UIView!
    var imagePicker: UIImagePickerController!
    var buttonBack: UIButton!
    var selectedMediaArray = [UIImage]()
    var collectionViewMedia: UICollectionView!
    var anonymous = false
    var activityIndicator: UIActivityIndicatorView!
    
    enum MediaEditMode {
        case delete
        case tap
    }
    var mediaEditMode: MediaEditMode = .tap
    var tappedCellTag = -999
    
    override func viewDidLoad() {
        super.viewDidLoad()
        loadCreateMediaPinView()
        loadKeyboardToolBar()
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
        let info = notification.userInfo!
        let keyboardFrame: CGRect = (info[UIKeyboardFrameEndUserInfoKey] as! NSValue).cgRectValue
        
        UIView.animate(withDuration: 0.3, animations: { () -> Void in
            self.uiviewToolBar.frame.origin.y = screenHeight - keyboardFrame.height - 50
            self.labelCountChars.frame.origin.y = screenHeight - keyboardFrame.height - 81
        })
    }
    
    func keyboardWillHide(_ notification:Notification) {
        UIView.animate(withDuration: 0.3, animations: { () -> Void in
            self.uiviewToolBar.frame.origin.y = screenHeight
            self.labelCountChars.frame.origin.y = screenHeight
        })
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        if scrollView == collectionViewMedia {
            print(collectionViewMedia.contentOffset.x)
        }
    }
    
}
