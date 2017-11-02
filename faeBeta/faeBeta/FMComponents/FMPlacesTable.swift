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
        super.init(frame: CGRect(x: 0, y: 68, width: screenWidth, height: screenHeight - 164 * screenHeightFactor))
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
            self.frame.size.height = screenHeight - 164 * screenHeightFactor
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
        
        tblResults = UITableView(frame: CGRect(x: 8, y: 8, width: 397 * screenWidthFactor, height: screenHeight - 229 * screenHeightFactor))
        tblResults.register(FMPlaceResultBarCell.self, forCellReuseIdentifier: "placeResultBarCell")
        tblResults.delegate = self
        tblResults.dataSource = self
        tblResults.tableFooterView = UIView()
        addSubview(tblResults)
        
        let footView = UIView()
        addSubview(footView)
        addConstraintsWithFormat("H:|-0-[v0]-0-|", options: [], views: footView)
        addConstraintsWithFormat("V:[v0(\(49*screenHeightFactor))]-8-|", options: [], views: footView)
        let grayLine = UIView(frame: CGRect(x: 0, y: 0, width: screenWidth, height: 1))
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
        addConstraintsWithFormat("H:|-90-[v0]-30-|", options: [], views: lblItemAddr)
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
        addConstraintsWithFormat("V:|-69-[v0(12)]", options: [], views: lblPrice)
        lblPrice.text = ""
    }
}

