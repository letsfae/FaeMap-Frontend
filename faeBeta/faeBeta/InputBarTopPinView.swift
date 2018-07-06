//
//  LocationExtendView.swift
//  faeBeta
//
//  Created by User on 21/02/2017.
//  Copyright © 2017 fae. All rights reserved.
//

import Foundation

class InputBarTopPinView : UIView {
    // MARK: - Properties
    private var imgView: UIImageView!
    var btnClose: UIButton!
    var lblLine1: UILabel!
    var lblLine2: UILabel!
    var lblLine3: UILabel!
    var activityIndicator: UIActivityIndicatorView!
    var location: CLLocation?
    var placeData: PlacePin?
    
    override var intrinsicContentSize: CGSize {
        return CGSize(width: screenWidth, height: 76.0)
    }
    
    // MARK: - init
    override init(frame: CGRect) {
        super.init(frame: frame);
        
        backgroundColor = UIColor.white
        
        imgView = UIImageView(frame: CGRect(x: 13, y: 10, width: 66, height: 66))
        //imgView.image = UIImage(named: "locationExtendViewHolder")
        imgView.contentMode = .scaleAspectFill
        imgView.clipsToBounds = true
        addSubview(imgView)
        
        activityIndicator = UIActivityIndicatorView()
        activityIndicator.activityIndicatorViewStyle = .white
        activityIndicator.center.x = imgView.frame.width / 2
        activityIndicator.center.y = imgView.frame.height / 2
        activityIndicator.hidesWhenStopped = true
        activityIndicator.color = UIColor._2499090()
        imgView.addSubview(activityIndicator)
        activityIndicator.startAnimating()
        
        lblLine1 = UILabel(frame: CGRect(x: 94, y: 17, width: 267 * screenWidthFactor, height: 22))
        lblLine1.text = "2714 S. HOOVER STREET"
        lblLine1.font = UIFont(name: "AvenirNext-Medium", size: 16)
        lblLine1.textColor = UIColor._898989()
        addSubview(lblLine1)
        
        lblLine2 = UILabel(frame: CGRect(x: 94, y: 37, width: 267 * screenWidthFactor, height: 16))
        lblLine2.text = "LOS ANGELES, CA 90007"
        lblLine2.font = UIFont(name: "AvenirNext-Medium", size: 12)
        lblLine2.textColor = UIColor._107105105()
        addSubview(lblLine2)
        
        lblLine3 = UILabel(frame: CGRect(x: 94, y: 55, width: 267 * screenWidthFactor, height: 16))
        lblLine3.text = "UNITED STATES"
        lblLine3.font = UIFont(name: "AvenirNext-Medium", size: 12)
        lblLine3.textColor = UIColor._107105105()
        addSubview(lblLine3)
        
        btnClose = UIButton(frame: CGRect(x: screenWidth - 43, y: 0, width: 43, height: 50.5))
        btnClose.setImage(UIImage(named : "locationExtendCancel"), for: .normal)
        btnClose.adjustsImageWhenHighlighted = false
        addSubview(btnClose)
        
        let topBorder: CALayer = CALayer()
        topBorder.frame = CGRect(x: 0, y: 0, width: screenWidth, height: 1)
        topBorder.backgroundColor = UIColor._200199204cg()
        layer.addSublayer(topBorder)
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK: - Helper methods
    func setThumbnail(image : UIImage) {
        imgView.image = image
        activityIndicator.stopAnimating()
    }
    
    func setLabel(texts : [String]) {
        lblLine1.text = texts[0].uppercased()
        lblLine2.text = texts[1].uppercased()
        lblLine3.text = texts[2].uppercased()
    }
    
    func getImageData() -> Data {
        return UIImageJPEGRepresentation(imgView.image!, 0.7)!
    }
    
    func setToLocation() {
        lblLine1.frame = CGRect(x: 94, y: 17, width: 267 * screenWidthFactor, height: 22)
        lblLine2.frame = CGRect(x: 94, y: 37, width: 267 * screenWidthFactor, height: 16)
        lblLine3.isHidden = false
    }
    
    func setToPlace() {
        lblLine1.frame = CGRect(x: 94, y: 25, width: 267 * screenWidthFactor, height: 22)
        lblLine2.frame = CGRect(x: 94, y: 47, width: 267 * screenWidthFactor, height: 16)
        if let place = placeData {
            lblLine1.text = place.name
            if place.address1 != "" {
                lblLine2.text = "\(place.address1), \(place.address2)"
            } else {
                General.shared.updateAddress(label: lblLine2, place: place)
            }
        }
        lblLine3.isHidden = true
    }
}
