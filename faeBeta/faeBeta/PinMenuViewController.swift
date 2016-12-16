//
//  PinMenuViewController.swift
//  faeBeta
//
//  Created by Yue on 10/19/16.
//  Copyright © 2016 fae. All rights reserved.
//

import UIKit

protocol PinMenuDelegate: class {
    func sendPinGeoInfo(pinID: String, type: String, latitude: CLLocationDegrees, longitude: CLLocationDegrees)
}

class PinMenuViewController: UIViewController {
    
    weak var delegate: PinMenuDelegate?
    
    // MARK: -- Blur View Pin Buttons and Labels
    var uiviewPinSelections: UIView!
    var blurViewMap: UIVisualEffectView!
    var buttonMedia: UIButton!
    var buttonChats: UIButton!
    var buttonComment: UIButton!
    var buttonEvent: UIButton!
    var buttonFaevor: UIButton!
    var buttonNow: UIButton!
    var buttonJoinMe: UIButton!
    var buttonSell: UIButton!
    var buttonLive: UIButton!
    
    var labelMenuTitle: UILabel!
    var labelMenuMedia: UILabel!
    var labelMenuChats: UILabel!
    var labelMenuComment: UILabel!
    var labelMenuEvent: UILabel!
    var labelMenuFaevor: UILabel!
    var labelMenuNow: UILabel!
    var labelMenuJoinMe: UILabel!
    var labelMenuSell: UILabel!
    var labelMenuLive: UILabel!
    
    var buttonClosePinBlurView: UIButton!
    
    // MARK: Geo Info pass to create pin view controller
    var currentLatitude: CLLocationDegrees = 34.0205378
    var currentLongitude: CLLocationDegrees = -118.2854081
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.view.backgroundColor = UIColor.clear
        loadBlurAndPinSelection()
        UIApplication.shared.statusBarStyle = .lightContent
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        UIView.animate(withDuration: 0.35, delay: 0, options: .curveEaseOut, animations: {
            self.blurViewMap.effect = UIBlurEffect(style: .dark)
            }, completion: nil)
        pinSelectionShowAnimation()
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        UIApplication.shared.statusBarStyle = .default
    }
    
    override var preferredStatusBarStyle : UIStatusBarStyle {
        return UIStatusBarStyle.lightContent
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
}
