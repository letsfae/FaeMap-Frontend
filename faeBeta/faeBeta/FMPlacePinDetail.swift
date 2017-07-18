//
//  FMPlacePinDetail.swift
//  faeBeta
//
//  Created by Yue on 7/17/17.
//  Copyright © 2017 fae. All rights reserved.
//

import UIKit

extension FaeMapViewController {
    func loadPlaceDetail() {
        uiviewPlaceDetail = UIView(frame: CGRect(x: 0, y: -320, width: screenWidth, height: 320))
        uiviewPlaceDetail.backgroundColor = UIColor.white
        view.addSubview(uiviewPlaceDetail)
        uiviewPlaceDetail.layer.shadowColor = UIColor(red: 107 / 255, green: 105 / 255, blue: 105 / 255, alpha: 1.0).cgColor
        uiviewPlaceDetail.layer.shadowOffset = CGSize(width: 0.0, height: 10.0)
        uiviewPlaceDetail.layer.shadowOpacity = 0.3
        uiviewPlaceDetail.layer.shadowRadius = 10.0
        uiviewPlaceDetail.layer.zPosition = 999
        
        uiviewPlacePinBottomLine = UIView(frame: CGRect(x: 0, y: 292, width: screenWidth, height: 1))
        uiviewPlacePinBottomLine.backgroundColor = UIColor(r: 200, g: 199, b: 204, alpha: 100)
        uiviewPlaceDetail.addSubview(uiviewPlacePinBottomLine)
        
        imgPlaceQuickView = UIImageView(frame: CGRect(x: 0, y: 0, width: screenWidth, height: 170))
        imgPlaceQuickView.contentMode = .scaleAspectFill
        imgPlaceQuickView.clipsToBounds = true
        uiviewPlaceDetail.addSubview(imgPlaceQuickView)
        imgPlaceQuickView.alpha = 0
        
        imgPlaceType = UIImageView(frame: CGRect(x: 0, y: 128, width: 58, height: 58))
        imgPlaceType.center.x = screenWidth / 2
        imgPlaceType.layer.borderColor = UIColor(r: 225, g: 225, b: 225, alpha: 100).cgColor
        imgPlaceType.layer.borderWidth = 2
        imgPlaceType.layer.cornerRadius = 5
        imgPlaceType.clipsToBounds = true
        imgPlaceType.contentMode = .scaleAspectFit
        uiviewPlaceDetail.addSubview(imgPlaceType)
        imgPlaceType.backgroundColor = UIColor.white
        
        lblPlaceTitle = UILabel(frame: CGRect(x: 0, y: 191, width: screenWidth, height: 27))
        lblPlaceTitle.center.x = screenWidth / 2
        lblPlaceTitle.text = ""
        lblPlaceTitle.font = UIFont(name: "AvenirNext-Medium", size: 20)
        lblPlaceTitle.textColor = UIColor.faeAppInputTextGrayColor()
        lblPlaceTitle.textAlignment = .center
        uiviewPlaceDetail.addSubview(lblPlaceTitle)
        
        lblPlaceStreet = UILabel(frame: CGRect(x: 0, y: 221, width: screenWidth, height: 22))
        lblPlaceStreet.center.x = screenWidth / 2
        lblPlaceStreet.text = ""
        lblPlaceStreet.font = UIFont(name: "AvenirNext-Medium", size: 16)
        lblPlaceStreet.textColor = UIColor.faeAppInputTextGrayColor()
        lblPlaceStreet.textAlignment = .center
        uiviewPlaceDetail.addSubview(lblPlaceStreet)
        
        lblPlaceCity = UILabel(frame: CGRect(x: 0, y: 243, width: screenWidth, height: 22))
        lblPlaceCity.center.x = screenWidth / 2
        lblPlaceCity.text = ""
        lblPlaceCity.font = UIFont(name: "AvenirNext-Medium", size: 16)
        lblPlaceCity.textColor = UIColor.faeAppInputTextGrayColor()
        lblPlaceCity.textAlignment = .center
        uiviewPlaceDetail.addSubview(lblPlaceCity)
        
        btnGoToPinList = UIButton(frame: CGRect(x: 0, y: 165, width: 53, height: 48))
        btnGoToPinList.setImage(#imageLiteral(resourceName: "pinDetailJumpToOpenedPin"), for: .normal)
        uiviewPlaceDetail.addSubview(btnGoToPinList)
//        btnGoToPinList.addTarget(self, action: #selector(self.actionGoToList(_:)), for: .touchUpInside)
        
        btnMoreOptions = UIButton()
        btnMoreOptions.setImage(#imageLiteral(resourceName: "pinDetailMoreOptions"), for: .normal)
        uiviewPlaceDetail.addSubview(btnMoreOptions)
        uiviewPlaceDetail.addConstraintsWithFormat("H:[v0(53)]-0-|", options: [], views: btnMoreOptions)
        uiviewPlaceDetail.addConstraintsWithFormat("V:|-165-[v0(48)]", options: [], views: btnMoreOptions)
//        btnMoreOptions.addTarget(self, action: #selector(self.showPinMoreButtonDetails(_:)), for: .touchUpInside)
        
//        self.initPlaceBasicInfo()
//        self.manageYelpData()
        
        // Pin icon size is slightly different from social pin's icon
        imgPinIcon = UIImageView()
        imgPinIcon.frame.size.width = 48
        imgPinIcon.center.x = screenWidth / 2
        imgPinIcon.center.y = 507 * screenHeightFactor
//        UIApplication.shared.statusBarStyle = .lightContent
    }
}
