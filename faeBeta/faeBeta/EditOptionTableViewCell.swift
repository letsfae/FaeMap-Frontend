//
//  EditOptionTableViewCell.swift
//  faeBeta
//
//  Created by Jacky on 1/8/17.
//  Copyright © 2017 fae. All rights reserved.
//

import UIKit

class EditOptionTableViewCell: UITableViewCell {
    
    var imageLeft: UIImageView!
    var labelMiddle: UILabel!
    var imageRight01: UIImageView!
    var imageRight02: UIImageView!
    var labelRight: UILabel!

    override init(style: UITableViewCellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        loadCellContent()
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func loadCellContent() {
        imageLeft = UIImageView()
        self.addSubview(imageLeft)
        self.addConstraintsWithFormat("H:|-0-[v0(29)]", options: [], views: imageLeft)
        self.addConstraintsWithFormat("V:|-13-[v0(29)]", options: [], views: imageLeft)
        
        labelMiddle = UILabel()
        labelMiddle.textColor = UIColor(red: 107/255, green: 105/255, blue: 105/255, alpha: 1)
        labelMiddle.font = UIFont(name: "AvenirNext-Medium", size: 18)
        self.addSubview(labelMiddle)
        self.addConstraintsWithFormat("H:|-44-[v0(209)]", options: [], views: labelMiddle)
        self.addConstraintsWithFormat("V:|-17-[v0(25)]", options: [], views: labelMiddle)
        
        imageRight01 = UIImageView()
        imageRight01.isHidden = true
        imageRight01.image = #imageLiteral(resourceName: "EditOptionRight")
        self.addSubview(imageRight01)
        self.addConstraintsWithFormat("H:[v0(7.5)]-0-|", options: [], views: imageRight01)
        self.addConstraintsWithFormat("V:|-22-[v0(15)]", options: [], views: imageRight01)
        
        imageRight02 = UIImageView()
        imageRight02.isHidden = true
        imageRight02.image = #imageLiteral(resourceName: "EditOptionPlus")
        self.addSubview(imageRight02)
        self.addConstraintsWithFormat("H:[v0(16)]-0-|", options: [], views: imageRight02)
        self.addConstraintsWithFormat("V:|-21-[v0(16)]", options: [], views: imageRight02)
        
        labelRight = UILabel(frame: CGRect(x: 0, y: 0, width: 50, height: 25))
        labelRight.isHidden = true
        labelRight.font = UIFont(name: "AvenirNext-DemiBold", size: 18)
        labelRight.textColor = UIColor(red: 182/255, green: 182/255, blue: 182/255, alpha: 1)
        self.addSubview(labelRight)
        self.addConstraintsWithFormat("H:[v0]-0-|", options: [], views: labelRight)
        self.addConstraintsWithFormat("V:|-18-[v0(25)]", options: [], views: labelRight)
    }
}
