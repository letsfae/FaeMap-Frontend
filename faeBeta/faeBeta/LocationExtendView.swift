//
//  LocationExtendView.swift
//  faeBeta
//
//  Created by User on 21/02/2017.
//  Copyright © 2017 fae. All rights reserved.
//

import Foundation

class LocationExtendView : UIView {
    // MARK: - Properties
    var imageView : UIImageView!
    var buttonCancel : UIButton!
    var LabelLine1 : UILabel!
    var LabelLine2 : UILabel!
    var LabelLine3 : UILabel!
    var location : CLLocation!
    var placeData: PlacePin?
    
    var strType: String = "Location"
    
    // MARK: - init
    init() {
        super.init(frame : CGRect(x: 0, y: screenHeight - 76 - 90, width: screenWidth, height: 76));
        
        backgroundColor = UIColor.white
        
        imageView = UIImageView(frame: CGRect(x: 13, y: 10, width: 66, height: 66))
        imageView.image = UIImage(named: "locationExtendViewHolder")
        imageView.contentMode = .scaleAspectFill
        imageView.clipsToBounds = true
        addSubview(imageView)
        
        LabelLine1 = UILabel(frame: CGRect(x: 94, y: 17, width: 267 * screenWidthFactor, height: 22))
        LabelLine1.text = "2714 S. HOOVER STREET"
        LabelLine1.font = UIFont(name: "AvenirNext-Medium", size: 16)
        LabelLine1.textColor = UIColor._898989()
        addSubview(LabelLine1)
        
        LabelLine2 = UILabel(frame: CGRect(x: 94, y: 37, width: 267 * screenWidthFactor, height: 16))
        LabelLine2.text = "LOS ANGELES, CA 90007"
        LabelLine2.font = UIFont(name: "AvenirNext-Medium", size: 12)
        LabelLine2.textColor = UIColor._107105105()
        addSubview(LabelLine2)
        
        LabelLine3 = UILabel(frame: CGRect(x: 94, y: 55, width: 267 * screenWidthFactor, height: 16))
        LabelLine3.text = "UNITED STATES"
        LabelLine3.font = UIFont(name: "AvenirNext-Medium", size: 12)
        LabelLine3.textColor = UIColor._107105105()
        addSubview(LabelLine3)
        
        buttonCancel = UIButton(frame: CGRect(x: screenWidth - 43, y: 17, width: 16.5, height: 16.5))
        buttonCancel.setImage(UIImage(named : "locationExtendCancel"), for: .normal)
        buttonCancel.adjustsImageWhenHighlighted = false
        addSubview(buttonCancel)
        
        let topBorder: CALayer = CALayer()
        topBorder.frame = CGRect(x: 0, y: 0, width: screenWidth, height: 1)
        topBorder.backgroundColor = UIColor(red: 200 / 255, green: 199 / 255, blue: 204 / 255, alpha: 1).cgColor
        layer.addSublayer(topBorder)
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
    
    // MARK: - Helper methods
    func setThumbnail(image : UIImage) {
        imageView.image = image
    }
    
    func setLabel(texts : [String]) {
        LabelLine1.text = texts[0].uppercased()
        LabelLine2.text = texts[1].uppercased()
        LabelLine3.text = texts[2].uppercased()
    }
    
    func getImageData() -> Data {
        return UIImageJPEGRepresentation(imageView.image!, 0.7)!
    }
    
    func setToLocation() {
        LabelLine1.frame = CGRect(x: 94, y: 17, width: 267 * screenWidthFactor, height: 22)
        LabelLine2.frame = CGRect(x: 94, y: 37, width: 267 * screenWidthFactor, height: 16)
        LabelLine3.isHidden = false
        strType = "Location"
    }
    
    func setToPlace() {
        LabelLine1.frame = CGRect(x: 94, y: 25, width: 267 * screenWidthFactor, height: 22)
        LabelLine2.frame = CGRect(x: 94, y: 47, width: 267 * screenWidthFactor, height: 16)
        if let place = placeData {
            LabelLine1.text = place.name
            var addr = place.address1 == "" ? "" : place.address1 + ", "
            addr += place.address2
            LabelLine2.text = addr
        }
        LabelLine3.isHidden = true
        strType = "Place"
    }
}
