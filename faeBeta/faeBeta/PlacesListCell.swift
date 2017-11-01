//
//  PlacesListCell.swift
//  FaeContacts
//
//  Created by Wenjia on 7/15/17.
//  Copyright © 2017 Yue. All rights reserved.
//

import UIKit

class PlacesListCell: UITableViewCell {
    
    var imgPic: UIImageView!
    var lblPlaceName: UILabel!
    var lblAddress: UILabel!
    var bottomLine: UIView!
    
    
    override init(style: UITableViewCellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        separatorInset = UIEdgeInsets.zero
        layoutMargins = UIEdgeInsets.zero
        selectionStyle = .none
        loadRecommendedCellContent()
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func setValueForPlace(_ placeInfo: PlacePin) {
        lblPlaceName.text = placeInfo.name
        lblAddress.text = placeInfo.address1 + ", " + placeInfo.address2
        imgPic.backgroundColor = .white
        General.shared.downloadImageForView(place: placeInfo, url: placeInfo.imageURL, imgPic: imgPic)
    }
    
    fileprivate func loadRecommendedCellContent() {
        imgPic = UIImageView()
        imgPic.frame = CGRect(x: 15 * screenWidthFactor, y: 11, width: 46, height: 46)
        imgPic.contentMode = .scaleAspectFill
        imgPic.clipsToBounds = true
        addSubview(imgPic)
        
        lblPlaceName = UILabel()
        lblPlaceName.textAlignment = .left
        lblPlaceName.lineBreakMode = .byTruncatingTail
        lblPlaceName.textColor = UIColor._898989()
        lblPlaceName.font = UIFont(name: "AvenirNext-Medium", size: 15)
        addSubview(lblPlaceName)
        addConstraintsWithFormat("H:|-\(73*screenWidthFactor)-[v0]-\(20*screenWidthFactor)-|", options: [], views: lblPlaceName)
        
        lblAddress = UILabel()
        lblAddress.textAlignment = .left
        lblAddress.lineBreakMode = .byTruncatingTail
        lblAddress.textColor = UIColor._107107107()
        lblAddress.font = UIFont(name: "AvenirNext-Medium", size: 12)
        addSubview(lblAddress)
        addConstraintsWithFormat("H:|-\(73*screenWidthFactor)-[v0]-\(20*screenWidthFactor)-|", options: [], views: lblAddress)
        addConstraintsWithFormat("V:|-16-[v0(20)]-0-[v1(16)]", options: [], views: lblPlaceName, lblAddress)
        
        bottomLine = UIView()
        bottomLine.backgroundColor = UIColor._200199204()
        addSubview(bottomLine)
        addConstraintsWithFormat("H:|-\(62*screenWidthFactor)-[v0]-0-|", options: [], views: bottomLine)
        addConstraintsWithFormat("V:[v0(1)]-0-|", options: [], views: bottomLine)
    }
}
