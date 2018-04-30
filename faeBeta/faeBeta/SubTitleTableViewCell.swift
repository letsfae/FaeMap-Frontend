//
//  SubTitleTableViewCell.swift
//  faeBeta
//
//  Created by Yash on 22/08/16.
//  Copyright © 2016 fae. All rights reserved.
//

import UIKit

class SubTitleTableViewCell: UITableViewCell {

    private var subTitleLabel: UILabel!
    
    override init(style: UITableViewCellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        loadContent()
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func loadContent() {
        subTitleLabel = UILabel(frame:CGRect(x: 0, y: 20, width: screenWidth, height: 24))
        subTitleLabel.textAlignment = .center
        subTitleLabel.numberOfLines = 0
        subTitleLabel.textColor = UIColor._138138138()
        subTitleLabel.font = UIFont(name: "AvenirNext-Medium", size: 16)
        addSubview(subTitleLabel)
    }

    func setSubTitleLabelText(_ subTitleLabelText: String)  {
        subTitleLabel.text = subTitleLabelText
    }
}
