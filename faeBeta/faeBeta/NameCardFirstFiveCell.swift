//
//  NameCardFirstFiveCell.swift
//  faeBeta
//
//  Created by Yue on 11/11/16.
//  Copyright © 2016 fae. All rights reserved.
//

import UIKit

class NameCardFirstFiveCell: UITableViewCell {
        
    var labelDes: UILabel!
    var labelUserSet: UILabel!
    var imageGoTo: UIImageView!
    
    override init(style: UITableViewCellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        loadLabel()
        loadGoToButton()
    }
    
    func loadGoToButton() {
        imageGoTo = UIImageView(frame: CGRect(x: 14, y: 13, width: 50, height: 50))
        imageGoTo.image = UIImage(named: "nameCardRight")
        self.addSubview(imageGoTo)
        self.addConstraintsWithFormat("H:[v0(9)]-23-|", options: [], views: imageGoTo)
        self.addConstraintsWithFormat("V:|-23-[v0(17)]", options: [], views: imageGoTo)
    }
    
    func loadLabel() {
        labelDes = UILabel(frame: CGRect(x: 25, y: 19, width: 250, height: 25))
        self.addSubview(labelDes)
        labelDes.font = UIFont(name: "AvenirNext-Medium", size: 18)
        labelDes.text = ""
        labelDes.textColor = UIColor(red: 89/255, green: 89/255, blue: 89/255, alpha: 1.0)
        labelDes.textAlignment = .Left
        self.addConstraintsWithFormat("H:|-25-[v0(200)]", options: [], views: labelDes)
        self.addConstraintsWithFormat("V:|-18.5-[v0(25)]", options: [], views: labelDes)
        
        labelUserSet = UILabel(frame: CGRect(x: 25, y: 19, width: 250, height: 25))
        self.addSubview(labelUserSet)
        labelUserSet.font = UIFont(name: "AvenirNext-Medium", size: 15)
        labelUserSet.text = ""
        labelUserSet.textColor = UIColor(red: 155/255, green: 155/255, blue: 155/255, alpha: 1.0)
        labelUserSet.textAlignment = .Right
        self.addConstraintsWithFormat("H:[v0(100)]-40-|", options: [], views: labelUserSet)
        self.addConstraintsWithFormat("V:|-20-[v0(25)]", options: [], views: labelUserSet)
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
