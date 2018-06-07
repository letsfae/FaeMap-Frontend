//
//  WelcomeImageContainerViews.swift
//  faeBeta
//
//  Created by Huiyuan Ren on 16/8/17.
//  Copyright © 2016年 fae. All rights reserved.
//

import UIKit

class WelcomeContentContainerFace: UIView {
    // MARK: - Properties
    private var imgWelcome: UIImageView!
    private var lblTitle: UILabel!
    private var lblDescription: UILabel!
    
    // MARK: - init
    init() {
        super.init(frame: CGRect(x: 0, y: 100 + device_offset_top, width: 300, height: 400))
        setup()
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
    
    // MARK: - Helper methods
    private func setup() {
        imgWelcome = UIImageView(frame: CGRect(x: (screenWidth - 300 * screenWidthFactor) / 2.0, y: 0, width: 300 * screenWidthFactor, height: 300 * screenWidthFactor))
        addSubview(imgWelcome)
        
        lblTitle = UILabel(frame: CGRect(x: 0, y: 300 * screenWidthFactor + 8, width: screenWidth, height: 27))
        lblTitle.font = UIFont(name: "AvenirNext-DemiBold", size: 20)
        lblTitle.textColor = UIColor._898989()
        lblTitle.textAlignment = .center
        addSubview(lblTitle)
        
        lblDescription = UILabel(frame: CGRect(x: 0, y: 300 * screenWidthFactor + 48, width: screenWidth, height: 44))
        lblDescription.font = UIFont(name: "AvenirNext-Medium", size: 16)
        lblDescription.textColor = UIColor._138138138()
        lblDescription.textAlignment = .center
        lblDescription.numberOfLines = 2
        addSubview(lblDescription)
    }
    
    func populateContentContainer(_ imageName: String, title: String, description: String) {
        imgWelcome.image = UIImage(named: imageName)
        lblTitle.text = title
        lblDescription.text = description
    }
}
