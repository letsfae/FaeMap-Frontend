//
//  AllPlacesCell.swift
//  faeBeta
//
//  Created by Faevorite 2 on 2017-08-11.
//  Copyright © 2017 fae. All rights reserved.
//

import UIKit

class AllPlacesCell: UITableViewCell {
    var imgPlaceIcon: UIImageView!
    var lblPlaceName: UILabel!
    var lblPlaceAddr: UILabel!
    var lblOpeninghour: UILabel!
    var lblPrice: UILabel!

    override init(style: UITableViewCellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        let separatorView = UIView(frame: CGRect(x: 89, y: 89, width: screenWidth - 89, height: 1))
        separatorView.backgroundColor = UIColor._206203203()
        addSubview(separatorView)
        selectionStyle = .none
        loadCellContent()
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    fileprivate func loadCellContent() {
        imgPlaceIcon = UIImageView(frame: CGRect(x: 12, y: 12, width: 66, height: 66))
        imgPlaceIcon.layer.cornerRadius = 5
        imgPlaceIcon.clipsToBounds = true
//        imgPlaceIcon.backgroundColor = .red
        addSubview(imgPlaceIcon)
        
        lblPlaceName = UILabel(frame: CGRect(x: 93, y: 17, width: screenWidth - 93 - 50, height: 20))
        lblPlaceName.textColor = UIColor._898989()
        lblPlaceName.font = UIFont(name: "AvenirNext-Medium", size: 15)
        addSubview(lblPlaceName)
        
        lblPlaceAddr = UILabel(frame: CGRect(x: 93, y: 40, width: screenWidth - 93 - 50, height: 16))
        lblPlaceAddr.textColor = UIColor._107105105()
        lblPlaceAddr.font = UIFont(name: "AvenirNext-Medium", size: 12)
        addSubview(lblPlaceAddr)
        
        lblOpeninghour = UILabel(frame: CGRect(x: 93, y: 57, width: screenWidth - 93 - 50, height: 16))
        lblOpeninghour.textColor = UIColor._107105105()
        lblOpeninghour.font = UIFont(name: "AvenirNext-Medium", size: 12)
        addSubview(lblOpeninghour)
        
        lblPrice = UILabel()
        lblPrice.textColor = UIColor._107105105()
        lblPrice.font = UIFont(name: "AvenirNext-Medium", size: 13)
        lblPrice.textAlignment = .right
        addSubview(lblPrice)
        addConstraintsWithFormat("H:[v0(35)]-12-|", options: [], views: lblPrice)
        addConstraintsWithFormat("V:[v0(18)]-9-|", options: [], views: lblPrice)
    }
    
    func setValueForCell(place: PlacePin) {
        imgPlaceIcon.image = place.icon
        lblPlaceName.text = place.name
        lblPlaceAddr.text = place.address1 + ", " + place.address2
        lblOpeninghour.text = place.class_1
        lblPrice.text = place.price
        imgPlaceIcon.backgroundColor = .white
        
        if place.imageURL == "" {
            imgPlaceIcon.image = UIImage(named: "place_result_\(place.class_2_icon_id)") ?? UIImage(named: "place_result_48")
            imgPlaceIcon.backgroundColor = .white
        } else {
            if let placeImgFromCache = placeInfoBarImageCache.object(forKey: place.imageURL as AnyObject) as? UIImage {
                self.imgPlaceIcon.image = placeImgFromCache
                self.imgPlaceIcon.backgroundColor = UIColor._2499090()
            } else {
                downloadImage(URL: place.imageURL) { (rawData) in
                    guard let data = rawData else { return }
                    DispatchQueue.global(qos: .userInitiated).async {
                        guard let placeImg = UIImage(data: data) else { return }
                        DispatchQueue.main.async {
                            self.imgPlaceIcon.image = placeImg
                            self.imgPlaceIcon.backgroundColor = UIColor._2499090()
                            placeInfoBarImageCache.setObject(placeImg, forKey: place.imageURL as AnyObject)
                        }
                    }
                }
            }
        }
    }
}
