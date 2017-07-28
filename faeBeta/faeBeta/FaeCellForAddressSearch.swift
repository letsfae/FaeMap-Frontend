//
//  FaeCellForAddressSearch.swift
//  FaeMap
//
//  Created by Yue on 6/13/16.
//  Copyright © 2016 Yue. All rights reserved.
//

import UIKit

class FaeCellForAddressSearch: UITableViewCell {
    
    var lblName: UILabel!
    var lblAddr: UILabel!
    
    override init(style: UITableViewCellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        loadCellLabel()
        separatorInset = UIEdgeInsets.zero
        layoutMargins = UIEdgeInsets.zero
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    
    
    func loadCellLabel() {
        lblName = UILabel()
        lblName.font = UIFont(name: "AvenirNext-Medium", size: 18)
        lblName.textAlignment = .left
        lblName.textColor = UIColor._898989()
        self.addSubview(lblName)
    }
}
