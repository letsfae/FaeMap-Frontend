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
        super.init(coder: aDecoder)
    }
    
    override func prepareForReuse() {
        super.prepareForReuse()
        imgPlaceIcon.image = nil
    }

    fileprivate func loadCellContent() {
        imgPlaceIcon = UIImageView(frame: CGRect(x: 12, y: 12, width: 66, height: 66))
        imgPlaceIcon.layer.cornerRadius = 5
        imgPlaceIcon.contentMode = .scaleAspectFill
        imgPlaceIcon.clipsToBounds = true
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
    
    func setValueForCell(place: BoardPlaceViewModel, row: Int) {
        // if use BoardPlaceViewModel
        lblPlaceName.text = "\(row + 1). \(place.name)"
        if place.address.contains(",") {
            lblPlaceAddr.text = place.address
        } else {
            General.shared.updateAddress(label: lblPlaceAddr, place: place.place)
        }
        lblPrice.text = place.price
        lblOpeninghour.text = place.openingHour
        
        imgPlaceIcon.backgroundColor = ._210210210()
        imgPlaceIcon.image = nil
        imgPlaceIcon.sd_setImage(with: URL(string: place.imageURL), placeholderImage: nil, options: []) { [weak self] (img, err, cacheType, _) in
            if img == nil || err != nil {
                self?.imgPlaceIcon.image = Key.shared.defaultPlace
            }
        }
    }
}
