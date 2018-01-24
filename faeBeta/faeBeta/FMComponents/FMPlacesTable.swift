//
//  FMPlacesTable.swift
//  faeBeta
//
//  Created by Yue Shen on 8/11/17.
//  Copyright © 2017 fae. All rights reserved.
//

import UIKit

protocol FMPlaceTableDelegate: class {
    func selectPlaceFromTable(_ placeData: PlacePin)
}

class FMPlacesTable: UIView, UITableViewDelegate, UITableViewDataSource {
    
    weak var delegate: FMPlaceTableDelegate?
    var tblResults: UITableView!
    var arrPlaces = [PlacePin]()
    var lblNumResults: UILabel!
    
    override init(frame: CGRect = CGRect.zero) {
        super.init(frame: CGRect(x: 0, y: 68 + device_offset_top, width: screenWidth, height: screenHeight - 164 * screenHeightFactor - device_offset_bot_main))
        loadContent()
        alpha = 0
        layer.zPosition = 605
        clipsToBounds = true
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func updatePlacesArray(places: [PlacePin]) -> [PlacePin] {
        arrPlaces.removeAll()
        for i in 0..<50 {
            if i >= places.count { break }
            let place = places[i]
            place.name = "\(i+1). " + place.name
            arrPlaces.append(place)
        }
        tblResults.reloadData()
        lblNumResults.text = arrPlaces.count == 1 ? "1 Result" : "\(arrPlaces.count) Results"
        return arrPlaces
    }
    
    func show(_ completion: @escaping () -> Void) {
        self.frame.size.height = 102
        self.alpha = 1
        UIView.animate(withDuration: 0.5, delay: 0, options: .curveEaseOut, animations: {
            let iphone_x_offset: CGFloat = screenHeight == 812 ? 24 : 0
            self.frame.size.height = screenHeight - 164 * screenHeightFactor - device_offset_bot_main - iphone_x_offset
            completion()
        }, completion: nil)
    }
    
    func hide() {
        self.frame.size.height = 102
        self.alpha = 0
    }
    
    fileprivate func loadContent() {
        let imgBack = UIImageView(frame: CGRect(x: 0, y: 0, width: screenWidth, height: screenHeight - 164 * screenHeightFactor))
        imgBack.image = #imageLiteral(resourceName: "placeResultTbl_shadow")
        imgBack.contentMode = .scaleAspectFit
        addSubview(imgBack)
        
        var table_offset_top: CGFloat = 0
        switch screenHeight {
        case 812:
            table_offset_top = 3
            break
        case 736:
            break
        case 667:
            break
        case 568:
            break
        default:
            break
        }
        
        var table_offset_left: CGFloat = 0
        switch screenHeight {
        case 812:
            table_offset_left = 0.5
            break
        case 736:
            break
        case 667:
            break
        case 568:
            break
        default:
            break
        }
        
        var table_length_offset: CGFloat = 0
        switch screenHeight {
        case 812:
            table_length_offset = 77
            break
        case 736:
            break
        case 667:
            break
        case 568:
            break
        default:
            break
        }
        
        tblResults = UITableView(frame: CGRect(x: 8 + table_offset_left, y: 10 + table_offset_top, width: 397 * screenWidthFactor - table_offset_left, height: screenHeight - 230 * screenHeightFactor - table_length_offset))
        tblResults.center.x = screenWidth / 2
        tblResults.register(FMPlaceResultBarCell.self, forCellReuseIdentifier: "placeResultBarCell")
        tblResults.delegate = self
        tblResults.dataSource = self
        tblResults.tableFooterView = UIView()
        var table_insets = UIEdgeInsets(top: -2, left: -0.5, bottom: 0, right: 0)
        switch screenHeight {
        case 812:
            table_insets = UIEdgeInsets(top: -5, left: 0, bottom: 0, right: 0)
            break
        case 736:
            table_insets = UIEdgeInsets(top: -2, left: -0.5, bottom: 0, right: 0)
            break
        case 667:
            break
        case 568:
            break
        default:
            break
        }
        tblResults.contentInset = table_insets
        addSubview(tblResults)
        
        var table_offset_bot: CGFloat = 0
        switch screenHeight {
        case 812:
            table_offset_bot = 273
            break
        case 736:
            table_offset_bot = 220
            break
        case 667:
            break
        case 568:
            break
        default:
            break
        }
        let footView = UIView(frame: CGRect(x: 8, y: screenHeight - table_offset_bot, width: screenWidth - 16, height: 49*screenHeightFactor))
        footView.clipsToBounds = true
        addSubview(footView)

        let grayLine = UIView(frame: CGRect(x: 0, y: 0, width: 397 * screenWidthFactor, height: 1))
        grayLine.center.x = screenWidth / 2
        grayLine.backgroundColor = UIColor._200199204()
        footView.addSubview(grayLine)
        
        lblNumResults = UILabel()
        lblNumResults.textAlignment = .center
        lblNumResults.textColor = UIColor._107105105()
        lblNumResults.font = UIFont(name: "AvenirNext-Medium", size: 16)
        footView.addSubview(lblNumResults)
        footView.addConstraintsWithFormat("H:|-0-[v0]-0-|", options: [], views: lblNumResults)
        footView.addConstraintsWithFormat("V:[v0(\(21*screenHeightFactor))]-\(13*screenHeightFactor)-|", options: [], views: lblNumResults)
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let placeData = arrPlaces[indexPath.row]
        delegate?.selectPlaceFromTable(placeData)
        
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return arrPlaces.count
    }
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "placeResultBarCell", for: indexPath) as! FMPlaceResultBarCell
        let data = arrPlaces[indexPath.row]
        cell.setValueForPlace(data)
        return cell
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 90
    }
    
}

class FMPlaceResultBarCell: UITableViewCell {
    
    var class_2_icon_id = 0
    var imgSavedItem: UIImageView!
    var lblItemName: UILabel!
    var lblItemAddr: UILabel!
    var lblHours: UILabel!
    var lblPrice: UILabel!
    
    override init(style: UITableViewCellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        separatorInset = UIEdgeInsets(top: 0, left: 90, bottom: 0, right: 0)
        layoutMargins = UIEdgeInsets.zero
        selectionStyle = .none
        backgroundColor = .clear
        loadContent()
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func setValueForPlace(_ placeInfo: PlacePin) {
        lblItemName.text = placeInfo.name
        lblItemAddr.text = placeInfo.address1 + ", " + placeInfo.address2
        imgSavedItem.backgroundColor = .white
        lblPrice.text = placeInfo.price
        // TODO: Yue - Hours update
//        lblHours.text = placeInfo.hours
        General.shared.downloadImageForView(place: placeInfo, url: placeInfo.imageURL, imgPic: imgSavedItem)
    }
    
    fileprivate func loadContent() {
        imgSavedItem = UIImageView()
        imgSavedItem.layer.cornerRadius = 5
        imgSavedItem.clipsToBounds = true
        addSubview(imgSavedItem)
        addConstraintsWithFormat("H:|-9-[v0(66)]", options: [], views: imgSavedItem)
        addConstraintsWithFormat("V:|-12-[v0(66)]", options: [], views: imgSavedItem)
        
        lblItemName = UILabel()
        addSubview(lblItemName)
        lblItemName.textAlignment = .left
        lblItemName.textColor = UIColor._898989()
        lblItemName.font = UIFont(name: "AvenirNext-Medium", size: 15)
        addConstraintsWithFormat("H:|-90-[v0]-30-|", options: [], views: lblItemName)
        addConstraintsWithFormat("V:|-17-[v0(20)]", options: [], views: lblItemName)
        
        lblItemAddr = UILabel()
        addSubview(lblItemAddr)
        lblItemAddr.textAlignment = .left
        lblItemAddr.textColor = UIColor._107107107()
        lblItemAddr.font = UIFont(name: "AvenirNext-Medium", size: 12)
        addConstraintsWithFormat("H:|-90-[v0]-25-|", options: [], views: lblItemAddr)
        addConstraintsWithFormat("V:|-40-[v0(16)]", options: [], views: lblItemAddr)
        
        lblHours = UILabel()
        addSubview(lblHours)
        lblHours.textAlignment = .left
        lblHours.textColor = UIColor._107107107()
        lblHours.font = UIFont(name: "AvenirNext-Medium", size: 12)
        addConstraintsWithFormat("H:|-90-[v0]-30-|", options: [], views: lblHours)
        addConstraintsWithFormat("V:|-57-[v0(16)]", options: [], views: lblHours)
        lblHours.text = ""
        
        lblPrice = UILabel()
        addSubview(lblPrice)
        lblPrice.textAlignment = .right
        lblPrice.textColor = UIColor._107107107()
        lblPrice.font = UIFont(name: "AvenirNext-Medium", size: 13)
        addConstraintsWithFormat("H:[v0(32)]-12-|", options: [], views: lblPrice)
        addConstraintsWithFormat("V:|-66-[v0(12)]", options: [], views: lblPrice)
        lblPrice.text = ""
    }
}

