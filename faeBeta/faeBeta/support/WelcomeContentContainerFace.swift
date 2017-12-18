//
//  WelcomeImageContainerViews.swift
//  faeBeta
//
//  Created by Huiyuan Ren on 16/8/17.
//  Copyright © 2016年 fae. All rights reserved.
//

import UIKit

class WelcomeContentContainerFace: UIView {
    
    //MARK: container view properties
    //@IBOutlet weak var imageView: UIImageView!
    //@IBOutlet weak var titleLabel: UILabel!
    //@IBOutlet weak var descriptionLabel: UILabel!
    //@IBOutlet weak var titleIcon: UIImageView!
    var uiview: UIView?
    
    var imgWelcome: UIImageView!
    var lblTitle: UILabel!
    var lblDescription: UILabel!
    
    init() {
        super.init(frame: CGRect(x: 0, y: 100 + device_offset_top, width: 300, height: 400))
        setup()
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    /*override init(frame: CGRect) {
        super.init(frame: frame)
        loadNib()
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)!
        loadNib()
    }*/
    
    //MARK: - setup
    /*fileprivate func loadNib() {
        uiview = Bundle.main.loadNibNamed("WelcomeContentContainerFace", owner: self, options: nil)![0] as? UIView
        self.insertSubview(uiview!, at: 0)
        uiview!.frame = self.bounds
        uiview!.autoresizingMask = [.flexibleWidth, .flexibleHeight]
    }*/
    
    func setup() {
        imgWelcome = UIImageView(frame: CGRect(x: (screenWidth - 300) / 2.0, y: 0, width: 300, height: 300))
        addSubview(imgWelcome)
        
        lblTitle = UILabel(frame: CGRect(x: 0, y: 308, width: screenWidth, height: 27))
        lblTitle.font = UIFont(name: "AvenirNext-DemiBold", size: 20)
        lblTitle.textColor = UIColor._898989()
        lblTitle.textAlignment = .center
        addSubview(lblTitle)
        
        lblDescription = UILabel(frame: CGRect(x: 0, y: 348, width: screenWidth, height: 44))
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
