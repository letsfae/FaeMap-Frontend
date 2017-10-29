//
//  LocationListCell.swift
//  FaeContacts
//
//  Created by Wenjia on 7/19/17.
//  Copyright © 2017 Yue. All rights reserved.
//

import UIKit

import GooglePlaces

class LocationListCell: UITableViewCell {
    
    var imgIcon: UIImageView!
    var lblLocationName: UILabel!
    var bottomLine: UIView!
    var prediction: GMSAutocompletePrediction!
    
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
    
    func setValueForLocationPrediction(_ pred: GMSAutocompletePrediction) {
        prediction = pred
        lblLocationName.attributedText = pred.attributedFullText
    }
    
    fileprivate func loadRecommendedCellContent() {
        imgIcon = UIImageView()
        imgIcon.contentMode = .scaleAspectFill
        imgIcon.clipsToBounds = true
        imgIcon.image = #imageLiteral(resourceName: "mapSearchCurrentLocation")
        addSubview(imgIcon)
        addConstraintsWithFormat("V:|-16.5-[v0(15)]", options: [], views: imgIcon)
        
        lblLocationName = UILabel()
        lblLocationName.textAlignment = .left
        lblLocationName.lineBreakMode = .byTruncatingTail
        lblLocationName.textColor = UIColor._898989()
        lblLocationName.font = UIFont(name: "AvenirNext-Medium", size: 18)
        addSubview(lblLocationName)
        addConstraintsWithFormat("V:|-11.5-[v0]-11.5-|", options: [], views: lblLocationName)
        
        addConstraintsWithFormat("H:|-48-[v0(15)]-9-[v1]-20-|", options: [], views: imgIcon, lblLocationName)
        
        bottomLine = UIView()
        bottomLine.backgroundColor = UIColor._200199204()
        addSubview(bottomLine)
        addConstraintsWithFormat("H:|-39-[v0]-39-|", options: [], views: bottomLine)
        addConstraintsWithFormat("V:[v0(1)]-0-|", options: [], views: bottomLine)
    }
    
}
