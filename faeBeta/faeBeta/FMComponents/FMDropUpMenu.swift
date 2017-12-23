//
//  FMDropUpMenu.swift
//  faeBeta
//
//  Created by Yue Shen on 12/21/17.
//  Copyright © 2017 fae. All rights reserved.
//

import UIKit

class FMDropUpMenu: UIView, UIScrollViewDelegate {

    var imgBackground_sm: UIImageView!
    var imgBackground_lg: UIImageView!
    
    override init(frame: CGRect = CGRect.zero) {
        super.init(frame: frame)
        self.frame = CGRect(x: 0, y: screenHeight, width: screenWidth, height: 170)
        loadContent()
//        loadCollectionData()
//        observeOnCollectionChange()
//        fullLoaded = true
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    fileprivate func loadContent() {
        imgBackground_sm = UIImageView(frame: CGRect(x: 0, y: 0, width: screenWidth, height: 170))
        imgBackground_sm.contentMode = .scaleAspectFit
        imgBackground_sm.image = #imageLiteral(resourceName: "main_drop_up_backg_sm")
        addSubview(imgBackground_sm)
        
        let lblMapOptions = UILabel(frame: CGRect(x: (screenWidth-250)/2, y: 28, width: 250, height: 27 * screenHeightFactor))
        lblMapOptions.text = "Map Actions"
        lblMapOptions.textAlignment = .center
        lblMapOptions.font = UIFont(name: "AvenirNext-Medium", size: 20 * screenHeightFactor)
        lblMapOptions.textColor = UIColor._898989()
        addSubview(lblMapOptions)
    }
    
    func show() {
        UIView.animate(withDuration: 0.3, delay: 0, options: .curveEaseOut, animations: {
            self.frame.origin.y = screenHeight - 170 - device_offset_bot_main
        }) { _ in
            
        }
    }
    
    func hide() {
        UIView.animate(withDuration: 0.3, delay: 0, options: .curveEaseOut, animations: {
            self.frame.origin.y = screenHeight
        }) { _ in
            
        }
    }
    
}
