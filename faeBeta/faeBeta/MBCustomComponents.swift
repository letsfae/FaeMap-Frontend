//
//  MBCustomComponents.swift
//  faeBeta
//
//  Created by Faevorite 2 on 2017-08-11.
//  Copyright © 2017 fae. All rights reserved.
//

import UIKit

protocol MapBoardPlaceTabDelegate: class {
    func jumpToRecommendedPlaces()
    func jumpToSearchPlaces()
}

class PlaceTabView: UIView {
    weak var delegate: MapBoardPlaceTabDelegate?
    var btnPlaceTabLeft: UIButton!
    var btnPlaceTabRight: UIButton!
    
    override init(frame: CGRect = CGRect.zero) {
        super.init(frame: CGRect(x: 0, y: screenHeight - 49, width: screenWidth, height: 49))
        backgroundColor = UIColor._248248248()
        setupUI()
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    func setupUI() {
        let tabLine = UIView()
        tabLine.backgroundColor = UIColor._200199204()
        addSubview(tabLine)
        addConstraintsWithFormat("H:|-0-[v0]-0-|", options: [], views: tabLine)
        addConstraintsWithFormat("V:|-0-[v0(1)]", options: [], views: tabLine)
        
        // add two buttons - btnPlaceTabLeft & btnPlaceTabRight
        btnPlaceTabLeft = UIButton(frame: CGRect(x: screenWidth / 2 - 138, y: 1, width: 138, height: 48))
        btnPlaceTabLeft.setImage(#imageLiteral(resourceName: "mb_activeRecommend"), for: .selected)
        btnPlaceTabLeft.setImage(#imageLiteral(resourceName: "mb_inactiveRecommend"), for: .normal)
        btnPlaceTabLeft.tag = 0
        btnPlaceTabLeft.addTarget(self, action: #selector(switchBetweenRecommendAndSearch(_:)), for: .touchUpInside)
        addSubview(btnPlaceTabLeft)
        
        btnPlaceTabRight = UIButton(frame: CGRect(x: screenWidth / 2, y: 1, width: 138, height: 48))
        btnPlaceTabRight.setImage(#imageLiteral(resourceName: "mb_activeExplore"), for: .selected)
        btnPlaceTabRight.setImage(#imageLiteral(resourceName: "mb_inactiveExplore"), for: .normal)
        btnPlaceTabRight.tag = 1
        btnPlaceTabRight.addTarget(self, action: #selector(switchBetweenRecommendAndSearch(_:)), for: .touchUpInside)
        addSubview(btnPlaceTabRight)
        
        btnPlaceTabLeft.isSelected = true
    }
    
    func switchBetweenRecommendAndSearch(_ sender: UIButton) {
        if sender.tag == 0 {  // Recommended place
            btnPlaceTabLeft.isSelected = true
            btnPlaceTabRight.isSelected = false
            delegate?.jumpToRecommendedPlaces()
        } else {   // Search place
            btnPlaceTabLeft.isSelected = false
            btnPlaceTabRight.isSelected = true
            delegate?.jumpToSearchPlaces()
        }
    }
}
