//
//  LaunchLoadingController.swift
//  faeBeta
//
//  Created by Yue Shen on 1/22/18.
//  Copyright © 2018 fae. All rights reserved.
//

import UIKit

class LaunchLoadingController: UIViewController {

    var activityIndicator: UIActivityIndicatorView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        loadContent()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        activityIndicator.startAnimating()
    }
    
    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)
        activityIndicator.stopAnimating()
    }

    fileprivate func loadContent() {
        
        view.backgroundColor = .white
        
        var length_y: CGFloat = 0
        switch screenHeight {
        case 812:
            length_y = 5
        case 667:
            length_y = 10
        case 568:
            length_y = 13
        default:
            break
        }
        
        var factor: CGFloat = 1
        switch screenHeight {
        case 568:
            factor = 0.99
        default:
            break
        }
        
        let imgView = UIImageView(frame: CGRect(x: screenWidth*(1-factor)/2, y: length_y, width: screenWidth * factor, height: screenHeight * factor))
        imgView.image = #imageLiteral(resourceName: "launchScreenNew")
        imgView.contentMode = .scaleAspectFit
        view.addSubview(imgView)
        
        var length_offset: CGFloat = 555
        switch screenHeight {
        case 736, 667:
            length_offset = 530 * screenHeightFactor
        case 568:
            length_offset = 420
        default:
            break
        }
        
        activityIndicator = UIActivityIndicatorView()
        activityIndicator.activityIndicatorViewStyle = .whiteLarge
        activityIndicator.center.x = screenWidth / 2
        activityIndicator.center.y = length_offset
        activityIndicator.hidesWhenStopped = true
        activityIndicator.color = UIColor._2499090()
        view.addSubview(activityIndicator)
    }
    
}
