//
//  CreatePinOptionsTableViewCell.swift
//  faeBeta
//
//  Created by YAYUAN SHI on 11/29/16.
//  Copyright © 2016 fae. All rights reserved.
//

import UIKit

class CreatePinOptionsTableViewCell: UITableViewCell {
    
    var lblTitle: UILabel!
    var imgLeadingIcon: UIImageView!
    var lblTrailing: UILabel!
    var imgTrailingIcon: UIImageView!
    
    override init(style: UITableViewCellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        self.backgroundColor = UIColor.clear
        selectionStyle = .none
        loadCellContent()
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    fileprivate func loadCellContent() {
        imgLeadingIcon = UIImageView(frame: CGRect(x: 60 * screenWidthFactor, y: 20, width: 29, height: 29))
        addSubview(imgLeadingIcon)
        imgLeadingIcon.contentMode = .center
        
        lblTitle = UILabel(frame: CGRect(x: 104 * screenWidthFactor, y: 22, width: 160, height: 25))
        lblTitle.textAlignment = .left
        lblTitle.font = UIFont(name: "AvenirNext-Medium", size: 18)
        lblTitle.textColor = UIColor.white
        addSubview(lblTitle)
        
        imgTrailingIcon = UIImageView()
        imgTrailingIcon.contentMode = .center
        addSubview(imgTrailingIcon)
        addConstraintsWithFormat("H:[v0(16)]-(\(60*screenWidthFactor))-|", options: [], views: imgTrailingIcon)
        addConstraintsWithFormat("V:|-26.5-[v0(16)]", options: [], views: imgTrailingIcon)
        
        lblTrailing = UILabel()
        addSubview(lblTrailing)
        lblTrailing.textAlignment = .right
        lblTrailing.font = UIFont(name: "AvenirNext-DemiBold", size: 18)
        lblTrailing.textColor = UIColor.white
        addConstraintsWithFormat("H:[v0(60)]-(\(60*screenWidthFactor))-|", options: [], views: lblTrailing)
        addConstraintsWithFormat("V:|-22-[v0(25)]", options: [], views: lblTrailing)
        
//        imgLeadingIcon.backgroundColor = .red
//        lblTitle.backgroundColor = .red
//        lblTrailing.backgroundColor = .red
//        imgTrailingIcon.backgroundColor = .red
    }

    func setupCell(withTitle title: String?, leadingIcon: UIImage?, trailingText: String?, trailingIcon: UIImage?)
    {
        lblTitle.text = title
        imgLeadingIcon.image = leadingIcon
        lblTrailing.text = trailingText
        imgTrailingIcon.image = trailingIcon
    }
}
