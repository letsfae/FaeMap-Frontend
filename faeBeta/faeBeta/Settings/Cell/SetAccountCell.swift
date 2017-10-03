//
//  SetAccountCell.swift
//  FaeSettings
//
//  Created by 子不语 on 2017/9/11.
//  Copyright © 2017年 子不语. All rights reserved.
//

import UIKit

class SetAccountCell: UITableViewCell {
    
    var lblTitle: UILabel!
    var lblContent: UILabel!
    var imgviewNext: UIImageView!
    
    override init(style: UITableViewCellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        // Vicky 09/17/17
        selectionStyle = .none
        // Vicky 09/17/17 End
        
        lblTitle = UILabel()
        addSubview(lblTitle)
        lblTitle.textAlignment = .left
        lblTitle.textColor = UIColor._898989()
        lblTitle.font = UIFont(name: "AvenirNext-Medium", size: 18)
        addConstraintsWithFormat("H:|-20-[v0(180)]", options: [], views: lblTitle)
        addConstraintsWithFormat("V:|-21-[v0(25)]", options: [], views: lblTitle)
        
        lblContent = UILabel()
        addSubview(lblContent)
        lblContent.textAlignment = .right
        lblContent.textColor = UIColor._155155155()
        lblContent.font = UIFont(name: "AvenirNext-Medium", size: 15)
        addConstraintsWithFormat("V:|-23-[v0(20)]", options: [], views: lblContent)
        
        imgviewNext = UIImageView()
        addSubview(imgviewNext)
        imgviewNext.image = #imageLiteral(resourceName: "Settings_next")
        addConstraintsWithFormat("H:[v0(150)]-9-[v1(9)]-20-|", options: [], views: lblContent, imgviewNext)
        addConstraintsWithFormat("V:|-25-[v0(17)]", options: [], views: imgviewNext)
    }
    
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
