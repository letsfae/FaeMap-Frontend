//
//  CustomCellForAddressSearch.swift
//  FaeMap
//
//  Created by Yue on 6/13/16.
//  Copyright © 2016 Yue. All rights reserved.
//

import UIKit

class CustomCellForAddressSearch: UITableViewCell {
    
    let screenWidth = UIScreen.mainScreen().bounds.width
    let screenHeight = UIScreen.mainScreen().bounds.height
    
    override init(style: UITableViewCellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        loadCellLabel()
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    var labelCellContent: UILabel!
    
    func loadCellLabel() {
        let fontSize_18 = screenWidth*0.04348
        labelCellContent = UILabel(frame: CGRectMake(10, 0, screenWidth-40, screenHeight*0.06))
        labelCellContent.center.y = 24
        labelCellContent.text = "Testing"
        labelCellContent.font = UIFont(name: "AvenirNext-Medium", size: fontSize_18)
        labelCellContent.textAlignment = .Left
        labelCellContent.textColor = UIColor(red: 249/255, green: 90/255, blue: 90/255, alpha: 1.0)
        self.addSubview(labelCellContent)
    }
}
