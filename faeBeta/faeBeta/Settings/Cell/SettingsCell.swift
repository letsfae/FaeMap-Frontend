//
//  SettingsCell.swift
//  FaeSettings
//
//  Created by 子不语 on 2017/8/28.
//  Copyright © 2017年 子不语. All rights reserved.
//

import UIKit
// Vicky 09/17/17 所有cell的selectionStyle = .none 避免点击cell出现灰色背景问题
class SettingsCell: UITableViewCell {
    var icon: UIImageView!
    var lblSetting: UILabel!
    var btnNext: UIButton!
    
    override init(style: UITableViewCellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        selectionStyle = .none
        
        icon = UIImageView()
        icon.contentMode = .scaleAspectFill
        addSubview(icon)
        
        lblSetting = UILabel()
        addSubview(lblSetting)
        lblSetting.font = UIFont(name: "AvenirNext-Medium", size: 18)
        lblSetting.textColor = UIColor._898989()
        lblSetting.textAlignment = .left
        
        btnNext = UIButton()
        addSubview(btnNext)
        btnNext.setImage(#imageLiteral(resourceName: "Settings_next"), for: .normal)
        
        addConstraintsWithFormat("H:|-20-[v0(28)]", options: [], views: icon)
        addConstraintsWithFormat("V:|-18-[v0(28)]", options: [], views: icon)
        addConstraintsWithFormat("H:|-65-[v0]-29-|", options: [], views: lblSetting)
        addConstraintsWithFormat("V:|-19-[v0(25)]", options: [], views: lblSetting)
        addConstraintsWithFormat("H:[v0(9)]-29-|", options: [], views: btnNext)
        addConstraintsWithFormat("V:|-19-[v0(17)]", options: [], views: btnNext)
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
