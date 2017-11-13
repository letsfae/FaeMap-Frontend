//
//  SettingsCell.swift
//  FaeSettings
//
//  Created by 子不语 on 2017/8/28.
//  Copyright © 2017年 子不语. All rights reserved.
//

import UIKit

class SettingsCell: UITableViewCell {
    var imgIcon: UIImageView!
    var lblSetting: UILabel!
    var btnNext: UIButton!
    
    override init(style: UITableViewCellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        selectionStyle = .none
        
        imgIcon = UIImageView(frame: CGRect(x: 22, y: 20, width: 26, height: 26))
        imgIcon.contentMode = .scaleAspectFill
        addSubview(imgIcon)
        
        lblSetting = UILabel(frame: CGRect(x: 65, y: 0, width: screenWidth - 65 - 29, height: 24))
        addSubview(lblSetting)
        lblSetting.font = UIFont(name: "AvenirNext-Medium", size: 18)
        lblSetting.textColor = UIColor._898989()
        lblSetting.textAlignment = .left
        lblSetting.center.y = imgIcon.center.y
        
        btnNext = UIButton(frame: CGRect(x: screenWidth - 29, y: 0, width: 9, height: 17))
        addSubview(btnNext)
        btnNext.setImage(#imageLiteral(resourceName: "Settings_next"), for: .normal)
        btnNext.center.y = imgIcon.center.y
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
