//
//  CountryCodeCell.swift
//  faeBeta
//
//  Created by Faevorite 2 on 2017-09-16.
//  Copyright © 2017 fae. All rights reserved.
//

import UIKit

class CountryCodeCell: UITableViewCell {
    var lblCountry: UILabel!
    var lblCode: UILabel!
    
    override init(style: UITableViewCellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        selectionStyle = .none
        loadCellContent()
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    fileprivate func loadCellContent() {
        lblCountry = UILabel(frame: CGRect(x: 10, y: 9.5, width: screenWidth * 0.7, height: 25))
        lblCountry.textColor = UIColor._898989()
        lblCountry.font = UIFont(name: "AvenirNext-Medium", size: 18)
        addSubview(lblCountry)
        
        lblCode = UILabel()
        lblCode.textColor = UIColor._146146146()
        lblCode.font = UIFont(name: "AvenirNext-Medium", size: 18)
        lblCode.textAlignment = .right
        addSubview(lblCode)
        addConstraintsWithFormat("H:[v0(60)]-10-|", options: [], views: lblCode)
        addConstraintsWithFormat("V:|-9.5-[v0(25)]", options: [], views: lblCode)
    }
    
    func setValueForCell(country: CountryCodeStruct) {
        lblCountry.text = country.countryName
        lblCode.text = "+" + country.phoneCode
    }
}
