//
//  ManageColListCell.swift
//  faeBeta
//
//  Created by Faevorite 2 on 2017-09-29.
//  Copyright © 2017 fae. All rights reserved.
//

import UIKit
import SwiftyJSON

protocol ColListCellDelegate: class {
    func reloadCell(indexPath: IndexPath)
}

class ColListPlaceCell: UITableViewCell {
    
    weak var delegate: ColListCellDelegate?
    var imgPic: FaeImageView!
    var lblColName: UILabel!
    var lblColAddr: UILabel!
    var lblColMemo: UILabel!
    var btnSelect: UIButton!
    var indexPath: IndexPath!
    
    internal var memoConstraint = [NSLayoutConstraint]() {
        didSet {
            if oldValue.count != 0 {
                self.removeConstraints(oldValue)
            }
            if memoConstraint.count != 0 {
                self.addConstraints(memoConstraint)
            }
        }
    }
    
    internal var addrConstraint = [NSLayoutConstraint]() {
        didSet {
            if oldValue.count != 0 {
                self.removeConstraints(oldValue)
            }
            if addrConstraint.count != 0 {
                self.addConstraints(addrConstraint)
            }
        }
    }
    
    override init(style: UITableViewCellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        let separatorView = UIView()
        separatorView.backgroundColor = UIColor._206203203()
        addSubview(separatorView)
        addConstraintsWithFormat("H:|-89-[v0]-0-|", options: [], views: separatorView)
        addConstraintsWithFormat("V:[v0(1)]-0-|", options: [], views: separatorView)
        selectionStyle = .none
        loadCellContent()
        if reuseIdentifier != "ManageColPlaceCell" {
            btnSelect.isHidden = true
        }
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    fileprivate func loadCellContent() {
        imgPic = FaeImageView(frame: CGRect(x: 12, y: 12, width: 66, height: 66))
        imgPic.clipsToBounds = true
        imgPic.layer.cornerRadius = 5
        addSubview(imgPic)
        
        lblColName = FaeLabel(CGRect.zero, .left, .medium, 16, UIColor._898989())
        addSubview(lblColName)
        addConstraintsWithFormat("H:|-93-[v0]-50-|", options: [], views: lblColName)
        addConstraintsWithFormat("V:|-26-[v0(22)]", options: [], views: lblColName)
        
        lblColAddr = FaeLabel(CGRect.zero, .left, .medium, 12, UIColor._107105105())
        addSubview(lblColAddr)
        addConstraintsWithFormat("H:|-93-[v0]-50-|", options: [], views: lblColAddr)
        addrConstraint = returnConstraintsWithFormat("V:|-48-[v0(16)]-26-|", options: [], views: lblColAddr)
        
        lblColMemo =  FaeLabel(CGRect.zero, .left, .demiBoldItalic, 12, UIColor._107105105())
        lblColMemo.numberOfLines = 0
//        lblColMemo.text = "123456"
        lblColMemo.backgroundColor = .red
        addSubview(lblColMemo)
        addConstraintsWithFormat("H:|-93-[v0]-50-|", options: [], views: lblColMemo)
        memoConstraint = returnConstraintsWithFormat("V:|-69-[v0(0)]", options: [], views: lblColMemo)
        
        btnSelect = UIButton()
        btnSelect.setImage(#imageLiteral(resourceName: "mb_btnOvalUnselected"), for: .normal)
        btnSelect.setImage(#imageLiteral(resourceName: "mb_btnOvalSelected"), for: .selected)
        btnSelect.isUserInteractionEnabled = false
//        btnSelect.addTarget(self, action: #selector(actionSelect(_:)), for: .touchUpInside)
        addSubview(btnSelect)
        addConstraintsWithFormat("H:[v0(50)]-0-|", options: [], views: btnSelect)
        addConstraintsWithFormat("V:|-20-[v0(50)]", options: [], views: btnSelect)
    }
    
    func setConstraints(memo: String) {
        if memo == "" {
            addrConstraint = returnConstraintsWithFormat("V:|-48-[v0(16)]-26-|", options: [], views: lblColAddr)
            memoConstraint = returnConstraintsWithFormat("V:|-69-[v0(0)]", options: [], views: lblColMemo)
        } else {
            addrConstraint = returnConstraintsWithFormat("V:|-48-[v0(16)]", options: [], views: lblColAddr)
            memoConstraint = returnConstraintsWithFormat("V:|-69-[v0]-21-|", options: [], views: lblColMemo)
        }
    }
    
    func setValueForPlacePin(placeId: Int) {
        if let placeInfo = faePlaceInfoCache.object(forKey: placeId as AnyObject) as? PlacePin {
            setValueForPlace(placeInfo)
            return
        }
        FaeMap.shared.getPin(type: "place", pinId: String(placeId)) { (status, message) in
            guard status / 100 == 2 else { return }
            guard message != nil else { return }
            let resultJson = JSON(message!)
            let placeInfo = PlacePin(json: resultJson)
            faePlaceInfoCache.setObject(placeInfo as AnyObject, forKey: placeId as AnyObject)
            self.setValueForPlace(placeInfo, memoFetched: true)
        }
    }
    
    func setValueForPlace(_ placeInfo: PlacePin, memoFetched: Bool = false) {
        self.lblColName.text = placeInfo.name
        self.lblColAddr.text = placeInfo.address1 + ", " + placeInfo.address2
        self.lblColMemo.text = placeInfo.memo
        print("lblColMemo: \(placeInfo.memo)")
        self.setConstraints(memo: placeInfo.memo)
        if memoFetched {
            delegate?.reloadCell(indexPath: self.indexPath)
        }
        print(self.lblColMemo.frame.height)
        self.imgPic.backgroundColor = .white
        if placeInfo.imageURL == "" {
            imgPic.image = UIImage(named: "place_result_\(placeInfo.class_2_icon_id)") ?? UIImage(named: "place_result_48")
            imgPic.backgroundColor = .white
        } else {
            if let placeImgFromCache = placeInfoBarImageCache.object(forKey: placeInfo.imageURL as AnyObject) as? UIImage {
                self.imgPic.image = placeImgFromCache
                self.imgPic.backgroundColor = UIColor._2499090()
                return
            }
            downloadImage(URL: placeInfo.imageURL) { (rawData) in
                guard let data = rawData else { return }
                DispatchQueue.global(qos: .userInitiated).async {
                    guard let placeImg = UIImage(data: data) else { return }
                    DispatchQueue.main.async {
                        self.imgPic.image = placeImg
                        self.imgPic.backgroundColor = UIColor._2499090()
                        placeInfoBarImageCache.setObject(placeImg, forKey: placeInfo.imageURL as AnyObject)
                    }
                }
            }
        }
    }
}

class ColListLocationCell: UITableViewCell {
    var imgSavedItem: FaeImageView!
    var lblItemName: UILabel!
    var lblItemAddr_1: UILabel!
    var lblItemAddr_2: UILabel!
    var lblColMemo: UILabel!
    var btnSelect: UIButton!
    
    override init(style: UITableViewCellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        let separatorView = UIView()
        addSubview(separatorView)
        separatorView.backgroundColor = UIColor._206203203()
        addConstraintsWithFormat("H:|-89-[v0]-0-|", options: [], views: separatorView)
        addConstraintsWithFormat("V:[v0(1)]-0-|", options: [], views: separatorView)
        selectionStyle = .none
        loadCellContent()
        if reuseIdentifier != "ManageColLocationCell" {
            btnSelect.isHidden = true
        }
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    fileprivate func loadCellContent() {
        imgSavedItem = FaeImageView(frame: CGRect(x: 12, y: 12, width: 66, height: 66))
        imgSavedItem.clipsToBounds = true
        imgSavedItem.contentMode = .scaleAspectFill
        addSubview(imgSavedItem)
        let icon = UIImageView(frame: CGRect(x: 23, y: 22, width: 19, height: 24))
        icon.contentMode = .scaleAspectFit
        icon.image = #imageLiteral(resourceName: "icon_destination")
        imgSavedItem.addSubview(icon)
        
        lblItemName = UILabel()
        lblItemName.textColor = UIColor._898989()
        lblItemName.font = UIFont(name: "AvenirNext-Medium", size: 15)
        addSubview(lblItemName)
        addConstraintsWithFormat("H:|-93-[v0]-50-|", options: [], views: lblItemName)
        
        lblItemAddr_1 = UILabel()
        lblItemAddr_1.textColor = UIColor._107105105()
        lblItemAddr_1.font = UIFont(name: "AvenirNext-Medium", size: 12)
        addSubview(lblItemAddr_1)
        addConstraintsWithFormat("H:|-93-[v0]-50-|", options: [], views: lblItemAddr_1)
        
        lblItemAddr_2 = UILabel()
        lblItemAddr_2.textColor = UIColor._107105105()
        lblItemAddr_2.font = UIFont(name: "AvenirNext-Medium", size: 12)
        addSubview(lblItemAddr_2)
        addConstraintsWithFormat("H:|-93-[v0]-50-|", options: [], views: lblItemAddr_2)
        
        lblColMemo =  FaeLabel(CGRect.zero, .left, .demiBoldItalic, 12, UIColor._107105105())
        lblColMemo.numberOfLines = 0
        addSubview(lblColMemo)
        addConstraintsWithFormat("H:|-93-[v0]-50-|", options: [], views: lblColMemo)
        
        addConstraintsWithFormat("V:|-18-[v0(22)]-0-[v1(16)]-1-[v2(16)]-5-[v3]-18-|", options: [], views: lblItemName, lblItemAddr_1, lblItemAddr_2, lblColMemo)
        
        btnSelect = UIButton()
        btnSelect.setImage(#imageLiteral(resourceName: "mb_btnOvalUnselected"), for: .normal)
        btnSelect.setImage(#imageLiteral(resourceName: "mb_btnOvalSelected"), for: .selected)
        btnSelect.isUserInteractionEnabled = false
        addSubview(btnSelect)
        addConstraintsWithFormat("H:[v0(50)]-0-|", options: [], views: btnSelect)
        addConstraintsWithFormat("V:|-20-[v0(50)]", options: [], views: btnSelect)
    }
    
    func setValueForLocationPin(locId: Int) {
        self.imgSavedItem.alpha = 0
        self.lblItemName.alpha = 0
        self.lblItemAddr_1.alpha = 0
        self.lblItemAddr_2.alpha = 0
        if let locationFromCache = faeLocationCache.object(forKey: locId as AnyObject) as? JSON {
            let lat = locationFromCache["geolocation"]["latitude"].doubleValue
            let lon = locationFromCache["geolocation"]["longitude"].doubleValue
            let location = CLLocation(latitude: lat, longitude: lon)
            self.imgSavedItem.fileID = locationFromCache["file_ids"].intValue
            self.imgSavedItem.loadImage(id: locationFromCache["file_ids"].intValue)
            UIView.animate(withDuration: 0.1, animations: {
                self.imgSavedItem.alpha = 1
            })
            self.getAddressForLocation(locId, location)
            return
        }
        FaeMap.shared.getPin(type: "location", pinId: String(locId)) { (status, message) in
            guard status / 100 == 2 else { return }
            guard message != nil else { return }
            let resultJson = JSON(message!)
            faeLocationCache.setObject(resultJson as AnyObject, forKey: locId as AnyObject)
            let lat = resultJson["geolocation"]["latitude"].doubleValue
            let lon = resultJson["geolocation"]["longitude"].doubleValue
            let location = CLLocation(latitude: lat, longitude: lon)
            self.imgSavedItem.fileID = resultJson["file_ids"].intValue
            self.imgSavedItem.loadImage(id: resultJson["file_ids"].intValue)
            self.lblColMemo.text = resultJson["user_pin_operations"]["memo"].stringValue
            self.getAddressForLocation(locId, location)
            UIView.animate(withDuration: 0.1, animations: {
                self.imgSavedItem.alpha = 1
            })
        }
    }
    
    func getAddressForLocation(_ locId: Int, _ location: CLLocation) {
        if let locationFromCache = faeLocationInfoCache.object(forKey: locId as AnyObject) as? [String] {
            self.lblItemName.text = locationFromCache[0]
            self.lblItemAddr_1.text = locationFromCache[1]
            self.lblItemAddr_2.text = locationFromCache[2]
            UIView.animate(withDuration: 0.1, animations: {
                self.lblItemName.alpha = 1
                self.lblItemAddr_1.alpha = 1
                self.lblItemAddr_2.alpha = 1
            })
            return
        }
        General.shared.getAddress(location: location, original: true) { (original) in
            guard let first = original as? CLPlacemark else { return }
            
            var name = ""
            var subThoroughfare = ""
            var thoroughfare = ""
            
            var address_1 = ""
            var address_2 = ""
            var address_3 = ""
            
            if let n = first.name {
                name = n
                address_1 += n
            }
            if let s = first.subThoroughfare {
                subThoroughfare = s
                if address_1 != "" {
                    address_1 += ", "
                }
                address_1 += s
            }
            if let t = first.thoroughfare {
                thoroughfare = t
                if address_1 != "" {
                    address_1 += ", "
                }
                address_1 += t
            }
            
            if name == subThoroughfare + " " + thoroughfare {
                address_1 = name
            }
            
            if let l = first.locality {
                address_2 += l
            }
            if let a = first.administrativeArea {
                if address_2 != "" {
                    address_2 += ", "
                }
                address_2 += a
            }
            if let p = first.postalCode {
                address_2 += " " + p
            }
            if let c = first.country {
                address_3 += c
            }
            
            DispatchQueue.main.async {
                self.lblItemName.text = address_1
                self.lblItemAddr_1.text = address_2
                self.lblItemAddr_2.text = address_3
                var arrAddrs = [String]()
                arrAddrs.append(address_1)
                arrAddrs.append(address_2)
                arrAddrs.append(address_3)
                faeLocationInfoCache.setObject(arrAddrs as AnyObject, forKey: locId as AnyObject)
                UIView.animate(withDuration: 0.1, animations: {
                    self.lblItemName.alpha = 1
                    self.lblItemAddr_1.alpha = 1
                    self.lblItemAddr_2.alpha = 1
                })
            }
        }
    }
}


