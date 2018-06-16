//
//  LocationListCell.swift
//  FaeContacts
//
//  Created by Wenjia on 7/19/17.
//  Copyright © 2017 Yue. All rights reserved.
//

import UIKit

class LocationListCell: UITableViewCell {
    
    private var imgIcon: UIImageView!
    private var lblLocationName: UILabel!
    private var bottomLine: UIView!
    
    override init(style: UITableViewCellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        separatorInset = UIEdgeInsets.zero
        layoutMargins = UIEdgeInsets.zero
        selectionStyle = .none
        loadRecommendedCellContent()
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
    
    /*
    func setValueForLocationPrediction(_ pred: GMSAutocompletePrediction, last: Bool) {
        lblLocationName.attributedText = pred.faeSearchBarAttributedText()
        bottomLine.isHidden = last
    }
     */
    
    func configureCell(_ location: String, last: Bool) {
        lblLocationName.attributedText = location.faeSearchBarAttributedText()
        bottomLine.isHidden = last
    }
    
    func configureCellOption(_ option: String, last: Bool) {
        lblLocationName.attributedText = nil
        lblLocationName.text = option
        bottomLine.isHidden = last
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

/*
extension GMSAutocompletePrediction {
    func faeSearchBarAttributedText() -> NSAttributedString {
        let fullText: NSMutableAttributedString = NSMutableAttributedString()
        var attribute = [NSAttributedStringKey.font: UIFont(name: "AvenirNext-Medium", size: 18)!, NSAttributedStringKey.foregroundColor: UIColor._898989()]
        let primaryText = NSAttributedString(string: self.attributedPrimaryText.string + " ", attributes: attribute)
        fullText.append(primaryText)
        attribute = [NSAttributedStringKey.font: UIFont(name: "AvenirNext-Medium", size: 16)!, NSAttributedStringKey.foregroundColor: UIColor._138138138()]
        if let secondary = self.attributedSecondaryText?.string {
            let secondaryText = NSAttributedString(string: secondary, attributes: attribute)
            fullText.append(secondaryText)
        }
        return fullText
    }
}
*/
