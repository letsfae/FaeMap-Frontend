//
//  FMPlacesTable.swift
//  faeBeta
//
//  Created by Yue Shen on 8/11/17.
//  Copyright © 2017 fae. All rights reserved.
//

import UIKit

class FMPlacesTable: UIView, UITableViewDelegate, UITableViewDataSource {
    
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
    
    func show() {
        self.frame.size.height = 102
        self.alpha = 1
        UIView.animate(withDuration: 0.3, animations: {
            self.frame.size.height = screenHeight - 164 * screenHeightFactor
        })
    }
    
    func hide() {
        self.frame.size.height = 102
        UIView.animate(withDuration: 0.3, animations: {
            self.frame.size.height = 102
            self.alpha = 0
        })
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
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return arrPlaces.count
    }
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "placeResultBarCell", for: indexPath) as! FMPlaceResultBarCell
        let data = arrPlaces[indexPath.row]
        cell.class_2_icon_id = data.class_2_icon_id
        cell.lblAddr.text = data.address1 + ", " + data.address2
        cell.lblName.text = data.name
        return cell
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 90
    }
    
}

class FMPlaceResultBarCell: UITableViewCell {
    
    var class_2_icon_id = 0 {
        didSet {
            imgType.image = UIImage(named: "place_result_\(class_2_icon_id)") ?? #imageLiteral(resourceName: "place_result_48")
        }
    }
    var imgType: UIImageView!
    var lblName: UILabel!
    var lblAddr: UILabel!
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
    
    fileprivate func loadContent() {
        imgType = UIImageView()
        imgType.layer.cornerRadius = 5
        imgType.clipsToBounds = true
        addSubview(imgType)
        addConstraintsWithFormat("H:|-9-[v0(66)]", options: [], views: imgType)
        addConstraintsWithFormat("V:|-12-[v0(66)]", options: [], views: imgType)
        
        lblName = UILabel()
        addSubview(lblName)
        lblName.textAlignment = .left
        lblName.textColor = UIColor._898989()
        lblName.font = UIFont(name: "AvenirNext-Medium", size: 15)
        addConstraintsWithFormat("H:|-90-[v0]-30-|", options: [], views: lblName)
        addConstraintsWithFormat("V:|-17-[v0(20)]", options: [], views: lblName)
        
        lblAddr = UILabel()
        addSubview(lblAddr)
        lblAddr.textAlignment = .left
        lblAddr.textColor = UIColor._107107107()
        lblAddr.font = UIFont(name: "AvenirNext-Medium", size: 12)
        addConstraintsWithFormat("H:|-90-[v0]-30-|", options: [], views: lblAddr)
        addConstraintsWithFormat("V:|-40-[v0(16)]", options: [], views: lblAddr)
        
        lblHours = UILabel()
        addSubview(lblHours)
        lblHours.textAlignment = .left
        lblHours.textColor = UIColor._107107107()
        lblHours.font = UIFont(name: "AvenirNext-Medium", size: 12)
        addConstraintsWithFormat("H:|-90-[v0]-30-|", options: [], views: lblHours)
        addConstraintsWithFormat("V:|-57-[v0(16)]", options: [], views: lblHours)
        lblHours.text = "Open 24 Hours"
        
        lblPrice = UILabel()
        addSubview(lblPrice)
        lblPrice.textAlignment = .right
        lblPrice.textColor = UIColor._107107107()
        lblPrice.font = UIFont(name: "AvenirNext-Medium", size: 13)
        addConstraintsWithFormat("H:[v0(32)]-12-|", options: [], views: lblPrice)
        addConstraintsWithFormat("V:|-69-[v0(12)]", options: [], views: lblPrice)
        lblPrice.text = "$$$$"
    }
}

