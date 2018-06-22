//
//  MBCustomComponents.swift
//  faeBeta
//
//  Created by Faevorite 2 on 2017-08-11.
//  Copyright © 2017 fae. All rights reserved.
//

import UIKit

protocol MapBoardPlaceTabDelegate: class {
    func jumpToLeftTab()
    func jumpToRightTab()
}

class PlaceTabView: UIView {
    weak var delegate: MapBoardPlaceTabDelegate?
    var btnPlaceTabLeft: UIButton!
    var btnPlaceTabRight: UIButton!
    
    override init(frame: CGRect = CGRect.zero) {
        super.init(frame: CGRect(x: 0, y: screenHeight - 51 - device_offset_bot, width: screenWidth, height: 51 + device_offset_bot))
        backgroundColor = UIColor._248248248()
        setupUI()
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }

    func setupUI() {
        let tabLine = UIView()
        tabLine.backgroundColor = UIColor._200199204()
        addSubview(tabLine)
        addConstraintsWithFormat("H:|-0-[v0]-0-|", options: [], views: tabLine)
        addConstraintsWithFormat("V:|-0-[v0(1)]", options: [], views: tabLine)
        
        // add two buttons - btnPlaceTabLeft & btnPlaceTabRight
        btnPlaceTabLeft = UIButton(frame: CGRect(x: screenWidth / 2 - 138, y: 1, width: 138, height: 50))
        btnPlaceTabLeft.setImage(#imageLiteral(resourceName: "mb_activeRecommend"), for: .selected)
        btnPlaceTabLeft.setImage(#imageLiteral(resourceName: "mb_inactiveRecommend"), for: .normal)
        btnPlaceTabLeft.tag = 0
        btnPlaceTabLeft.addTarget(self, action: #selector(switchBetweenLeftAndRightTab(_:)), for: .touchUpInside)
        addSubview(btnPlaceTabLeft)
        
        btnPlaceTabRight = UIButton(frame: CGRect(x: screenWidth / 2, y: 1, width: 138, height: 50))
        btnPlaceTabRight.setImage(#imageLiteral(resourceName: "mb_activeExplore"), for: .selected)
        btnPlaceTabRight.setImage(#imageLiteral(resourceName: "mb_inactiveExplore"), for: .normal)
        btnPlaceTabRight.tag = 1
        btnPlaceTabRight.addTarget(self, action: #selector(switchBetweenLeftAndRightTab(_:)), for: .touchUpInside)
        addSubview(btnPlaceTabRight)
        
        btnPlaceTabLeft.isSelected = true
    }
    
    @objc func switchBetweenLeftAndRightTab(_ sender: UIButton) {
        if sender.tag == 0 {  // Recommended place
            btnPlaceTabLeft.isSelected = true
            btnPlaceTabRight.isSelected = false
            delegate?.jumpToLeftTab()
        } else {   // Search place
            btnPlaceTabLeft.isSelected = false
            btnPlaceTabRight.isSelected = true
            delegate?.jumpToRightTab()
        }
    }
}
