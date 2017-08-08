//
//  LocationExtendView.swift
//  faeBeta
//
//  Created by User on 21/02/2017.
//  Copyright © 2017 fae. All rights reserved.
//

import Foundation

class LocationExtendView : UIView {
    
    private var dataDic : [String : String] = [:]
    private var imageView : UIImageView!
    var buttonCancel : UIButton!
    private var LabelLine1 : UILabel!
    private var LabelLine2 : UILabel!
    private var LabelLine3 : UILabel!
    var location : CLLocation!
    
    init() {
        super.init(frame : CGRect(x: 0, y: screenHeight - 64 - 76 - 90, width: screenWidth, height: 76));
        
        // test background color
        self.backgroundColor = UIColor.white
        
        // location avatar
        imageView = UIImageView(frame: CGRect(x: 13, y: 10, width: 66, height: 66))
        imageView.image = UIImage(named: "locationExtendViewHolder")
        imageView.contentMode = .scaleAspectFill
        imageView.clipsToBounds = true
        self.addSubview(imageView)
        
        // address label
        LabelLine1 = UILabel(frame: CGRect(x: 92, y: 17, width: 267, height: 22))
        LabelLine1.text = "2714 S. HOOVER STREET"
        LabelLine1.font = UIFont(name: "AvenirNext-Medium", size: 16)
        LabelLine1.textColor = UIColor(red: 89 / 255, green: 89 / 255, blue: 89 / 255, alpha: 1)
        self.addSubview(LabelLine1)
        
        LabelLine2 = UILabel(frame: CGRect(x: 92, y: 37, width: 267, height: 16))
        LabelLine2.text = "LOS ANGELES, CA 90007"
        
        LabelLine2.font = UIFont(name: "AvenirNext-Medium", size: 12)
        LabelLine2.textColor = UIColor._107105105()
        self.addSubview(LabelLine2)
        
        LabelLine3 = UILabel(frame: CGRect(x: 92, y: 55, width: 267, height: 16))
        LabelLine3.text = "UNITED STATES"
        LabelLine3.font = UIFont(name: "AvenirNext-Medium", size: 12)
        LabelLine3.textColor = UIColor._107105105()
        self.addSubview(LabelLine3)
        
        //cancel button
        buttonCancel = UIButton(frame: CGRect(x: screenWidth - 43, y: 17, width: 16.5, height: 16.5))
        buttonCancel.setImage(UIImage(named : "locationExtendCancel"), for: .normal)
        buttonCancel.adjustsImageWhenHighlighted = false
        //buttonCancel.addTarget(self, action: #selector(self.hiddenSelf), for: .touchUpInside);
        self.addSubview(buttonCancel)
        
        let topBorder: CALayer = CALayer()
        topBorder.frame = CGRect(x: 0, y: 0, width: screenWidth, height: 1)
        topBorder.backgroundColor = UIColor(red: 200 / 255, green: 199 / 255, blue: 204 / 255, alpha: 1).cgColor
        self.layer.addSublayer(topBorder)
        
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func setAvator(image : UIImage) {
        imageView.image = image
    }
    
    func setLabel(texts : [String]) {
        LabelLine1.text = texts[0]
        LabelLine2.text = texts[1]
        LabelLine3.text = texts[2]
    }
    
    func addKeyWithValue(key : String, value : String) {
        dataDic[key] = value
    }
    
    @objc private func hiddenSelf(sender : UIButton) {
        self.isHidden = true
    }
    
    func getImageDate() -> Data {
        return UIImageJPEGRepresentation(imageView.image!, 0.7)!
    }
}
