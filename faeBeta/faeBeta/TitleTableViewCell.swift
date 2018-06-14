//
//  TitleTableViewCell.swift
//  faeBeta
//
//  Created by Yash on 18/08/16.
//  Copyright © 2016 fae. All rights reserved.
//

import UIKit

class TitleTableViewCell: UITableViewCell {

    private var titleLabel: UILabel!
    
    override init(style: UITableViewCellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        loadContent()
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
    
    private func loadContent() {
        titleLabel = UILabel(frame:CGRect(x: 0, y: 0, width: screenWidth, height: 56))
        titleLabel.textAlignment = .center
        titleLabel.numberOfLines = 0
        titleLabel.textColor = UIColor._898989()
        titleLabel.font = UIFont(name: "AvenirNext-Medium", size: 18)
        addSubview(titleLabel)
    }
    
    func setTitleLabelText(_ titleText: String)  {
        titleLabel.text = titleText
    }
}
