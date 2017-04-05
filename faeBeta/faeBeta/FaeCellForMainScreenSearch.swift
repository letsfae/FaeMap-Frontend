//
//  FaeCellForMainScreenSearch.swift
//  FaeMap
//
//  Created by Yue on 11/3/16.
//  Copyright © 2016 Yue. All rights reserved.
//

import UIKit

class FaeCellForMainScreenSearch: UITableViewCell {
    
    var labelTitle: UILabel!
    var labelSubTitle: UILabel!
    
    override init(style: UITableViewCellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        loadCellLabel()
        separatorInset = UIEdgeInsets.zero
        layoutMargins = UIEdgeInsets.zero
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    fileprivate func loadCellLabel() {
        let fontSize_18 = 18 * screenWidthFactor
        let fontSize_13 = 13 * screenWidthFactor
        let labelWidth = 362 * screenWidthFactor
        let labelHeight = 21 * screenWidthFactor
        let labelX = fontSize_18
        let labelTitleY = 13 * screenWidthFactor
        let labelSubTitleY = 33 * screenWidthFactor
        
        labelTitle = UILabel(frame: CGRect(x: labelX, y: labelTitleY, width: labelWidth, height: labelHeight))
        labelTitle.text = ""
        labelTitle.font = UIFont(name: "AvenirNext-Medium", size: fontSize_18)
        labelTitle.textAlignment = .left
        labelTitle.textColor = UIColor.faeAppInputTextGrayColor()
        self.addSubview(labelTitle)
        
        labelSubTitle = UILabel(frame: CGRect(x: labelX, y: labelSubTitleY, width: labelWidth, height: labelHeight))
        labelSubTitle.text = ""
        labelSubTitle.font = UIFont(name: "AvenirNext-Medium", size: fontSize_13)
        labelSubTitle.textAlignment = .left
        labelSubTitle.textColor = UIColor.faeAppTimeTextBlackColor()
        self.addSubview(labelSubTitle)
    }
}
