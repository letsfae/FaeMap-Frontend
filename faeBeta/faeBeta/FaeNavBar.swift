//
//  FaeNavBar.swift
//  faeBeta
//
//  Created by Yue on 5/1/17.
//  Copyright © 2017 fae. All rights reserved.
//

import UIKit

class FaeNavBar: UIView {

    var leftBtn = UIButton()
    var rightBtn = UIButton()
    var lblTitle = UILabel()
    
    override init(frame: CGRect) {
        let newFrame = CGRect(origin: CGPoint.zero, size: CGSize(width: screenWidth, height: 65))
        super.init(frame: newFrame)
        
        backgroundColor = .white
        
        // Line at y = 64
        let bottomLine = UIView(frame: CGRect(x: 0, y: 64, width: screenWidth, height: 1))
        bottomLine.layer.borderWidth = screenWidth
        bottomLine.layer.borderColor = UIColor.faeAppNavBarBorderGrayColor()
        addSubview(bottomLine)
        
        leftBtn.setImage(#imageLiteral(resourceName: "pinDetailFullToHalf"), for: .normal)
        addSubview(leftBtn)
        addConstraintsWithFormat("H:|-(-24)-[v0(101)]", options: [], views: leftBtn)
        addConstraintsWithFormat("V:|-22-[v0(38)]", options: [], views: leftBtn)
        
        rightBtn.setImage(#imageLiteral(resourceName: "pinDetailMoreOptions"), for: UIControlState())
        addSubview(rightBtn)
        addConstraintsWithFormat("H:[v0(101)]-(-22)-|", options: [], views: rightBtn)
        addConstraintsWithFormat("V:|-22-[v0(38)]", options: [], views: rightBtn)
        
        lblTitle.text = ""
        lblTitle.font = UIFont(name: "AvenirNext-Medium", size: 20)
        lblTitle.textColor = UIColor.faeAppInputTextGrayColor()
        lblTitle.textAlignment = .center
        addSubview(lblTitle)
        addConstraintsWithFormat("H:|-100-[v0]-100-|", options: [], views: lblTitle)
        addConstraintsWithFormat("V:|-28-[v0(27)]", options: [], views: lblTitle)
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
 

}
