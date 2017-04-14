//
//  PDLoadPlacePin.swift
//  faeBeta
//
//  Created by Yue on 2/8/17.
//  Copyright © 2017 fae. All rights reserved.
//

import UIKit
import SDWebImage
import RealmSwift

extension PinDetailViewController {
    func loadPlaceFromRealm(pinTypeId: String) {
        let realm = try! Realm()
        if let opinListElem = realm.objects(OPinListElem.self).filter("pinTypeId == '\(pinTypeId)'").first {
            self.lblPlaceTitle.text = opinListElem.pinContent
            self.lblPlaceStreet.text = opinListElem.street
            self.lblPlaceCity.text = opinListElem.city
            let imageURL = opinListElem.imageURL
            self.imgPlaceQuickView.sd_setImage(with: URL(string: imageURL), placeholderImage: nil, options: [.retryFailed, .refreshCached], completed: { (image, error, SDImageCacheType, imageURL) in
                UIView.animate(withDuration: 0.3, animations: {
                    self.imgPlaceQuickView.alpha = 1
                })
            })
            PinDetailViewController.placeType = opinListElem.category
            initPlaceBasicInfo()
        }
    }
    
    func manageYelpData() {
        self.lblPlaceTitle.text = PinDetailViewController.strPlaceTitle
        self.lblPlaceStreet.text = PinDetailViewController.strPlaceStreet
        self.lblPlaceCity.text = PinDetailViewController.strPlaceCity
        let imageURL = PinDetailViewController.strPlaceImageURL
        self.imgPlaceQuickView.sd_setImage(with: URL(string: imageURL), placeholderImage: nil, options: [.retryFailed, .refreshCached], completed: { (image, error, SDImageCacheType, imageURL) in
            UIView.animate(withDuration: 0.3, animations: {
                self.imgPlaceQuickView.alpha = 1
            })
        })
    }
    
    func loadPlaceDetail() {
        uiviewPlaceDetail = UIView(frame: CGRect(x: 0, y: 0, width: screenWidth, height: 320))
        uiviewPlaceDetail.backgroundColor = UIColor.white
        view.addSubview(uiviewPlaceDetail)
        uiviewPlaceDetail.center.y -= screenHeight
        uiviewPlaceDetail.layer.zPosition = 110
        
        uiviewPlaceLine = UIView(frame: CGRect(x: 0, y: 292, width: screenWidth, height: 1))
        uiviewPlaceLine.backgroundColor = UIColor(r: 200, g: 199, b: 204, alpha: 100)
        uiviewPlaceDetail.addSubview(uiviewPlaceLine)
        
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
        
        btnGoToPinList_Place = UIButton(frame: CGRect(x: 0, y: 165, width: 53, height: 48))
        btnGoToPinList_Place.setImage(#imageLiteral(resourceName: "pinDetailJumpToOpenedPin"), for: .normal)
        uiviewPlaceDetail.addSubview(btnGoToPinList_Place)
        btnGoToPinList_Place.addTarget(self, action: #selector(self.actionGoToList(_:)), for: .touchUpInside)
        
        btnMoreOptions_Place = UIButton()
        btnMoreOptions_Place.setImage(#imageLiteral(resourceName: "pinDetailMoreOptions"), for: .normal)
        uiviewPlaceDetail.addSubview(btnMoreOptions_Place)
        uiviewPlaceDetail.addConstraintsWithFormat("H:[v0(53)]-0-|", options: [], views: btnMoreOptions_Place)
        uiviewPlaceDetail.addConstraintsWithFormat("V:|-165-[v0(48)]", options: [], views: btnMoreOptions_Place)
        btnMoreOptions_Place.addTarget(self, action: #selector(self.showPinMoreButtonDetails(_:)), for: .touchUpInside)
        
        initPlaceBasicInfo()
        manageYelpData()
    }
    
    func initPlaceBasicInfo() {
        switch PinDetailViewController.placeType {
        case "burgers":
            pinIcon.image = #imageLiteral(resourceName: "placePinBurger")
            imgPlaceType.image = #imageLiteral(resourceName: "placeDetailBurger")
            break
        case "pizza":
            pinIcon.image = #imageLiteral(resourceName: "placePinPizza")
            imgPlaceType.image = #imageLiteral(resourceName: "placeDetailPizza")
            break
        case "foodtrucks":
            pinIcon.image = #imageLiteral(resourceName: "placePinFoodtruck")
            imgPlaceType.image = #imageLiteral(resourceName: "placeDetailFoodtruck")
            break
        case "coffee":
            pinIcon.image = #imageLiteral(resourceName: "placePinCoffee")
            imgPlaceType.image = #imageLiteral(resourceName: "placeDetailCoffee")
            break
        case "desserts":
            pinIcon.image = #imageLiteral(resourceName: "placePinDesert")
            imgPlaceType.image = #imageLiteral(resourceName: "placeDetailDesert")
            break
        case "movietheaters":
            pinIcon.image = #imageLiteral(resourceName: "placePinCinema")
            imgPlaceType.image = #imageLiteral(resourceName: "placeDetailCinema")
            break
        case "beautysvc":
            pinIcon.image = #imageLiteral(resourceName: "placePinBoutique")
            imgPlaceType.image = #imageLiteral(resourceName: "placeDetailBoutique")
            break
        case "playgrounds":
            pinIcon.image = #imageLiteral(resourceName: "placePinSport")
            imgPlaceType.image = #imageLiteral(resourceName: "placeDetailSport")
            break
        case "museums":
            pinIcon.image = #imageLiteral(resourceName: "placePinArt")
            imgPlaceType.image = #imageLiteral(resourceName: "placeDetailArt")
            break
        case "juicebars":
            pinIcon.image = #imageLiteral(resourceName: "placePinBoba")
            imgPlaceType.image = #imageLiteral(resourceName: "placeDetailBoba")
            break
        default:
            break
        }
    }
}
