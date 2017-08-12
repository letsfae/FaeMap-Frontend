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
    
    override init(frame: CGRect = CGRect.zero) {
        super.init(frame: CGRect(x: 8, y: 76, width: 398, height: screenHeight - 180))
        loadContent()
        alpha = 0
        layer.zPosition = 605
        tblResults.tableFooterView = UIView()
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    fileprivate func loadContent() {
        
        let imgBack = UIImageView(frame: CGRect(x: -8, y: -8, width: screenWidth, height: screenHeight - 164))
        imgBack.image = #imageLiteral(resourceName: "placeResultTbl_shadow")
        imgBack.contentMode = .scaleAspectFill
        addSubview(imgBack)
        
        tblResults = UITableView(frame: CGRect(x: 0, y: 0, w: 398, h: screenHeight - 180))
        tblResults.register(FMPlaceResultBarCell.self, forCellReuseIdentifier: "placeResultBarCell")
        tblResults.delegate = self
        tblResults.dataSource = self
        addSubview(tblResults)
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
        addConstraintsWithFormat("H:|-15-[v0(66)]", options: [], views: imgType)
        addConstraintsWithFormat("V:|-18-[v0(66)]", options: [], views: imgType)
        
        lblName = UILabel()
        addSubview(lblName)
        lblName.textAlignment = .left
        lblName.textColor = UIColor._898989()
        lblName.font = UIFont(name: "AvenirNext-Medium", size: 15)
        addConstraintsWithFormat("H:|-96-[v0]-30-|", options: [], views: lblName)
        addConstraintsWithFormat("V:|-23-[v0(20)]", options: [], views: lblName)
        
        lblAddr = UILabel()
        addSubview(lblAddr)
        lblAddr.textAlignment = .left
        lblAddr.textColor = UIColor._107107107()
        lblAddr.font = UIFont(name: "AvenirNext-Medium", size: 12)
        addConstraintsWithFormat("H:|-96-[v0]-30-|", options: [], views: lblAddr)
        addConstraintsWithFormat("V:|-46-[v0(16)]", options: [], views: lblAddr)
        
        lblHours = UILabel()
        addSubview(lblHours)
        lblHours.textAlignment = .left
        lblHours.textColor = UIColor._107107107()
        lblHours.font = UIFont(name: "AvenirNext-Medium", size: 12)
        addConstraintsWithFormat("H:|-96-[v0]-30-|", options: [], views: lblHours)
        addConstraintsWithFormat("V:|-63-[v0(16)]", options: [], views: lblHours)
        lblHours.text = "Open 24 Hours"
        
        lblPrice = UILabel()
        addSubview(lblPrice)
        lblPrice.textAlignment = .right
        lblPrice.textColor = UIColor._107107107()
        lblPrice.font = UIFont(name: "AvenirNext-Medium", size: 13)
        addConstraintsWithFormat("H:[v0(32)]-18-|", options: [], views: lblPrice)
        addConstraintsWithFormat("V:|-69-[v0(18)]", options: [], views: lblPrice)
        lblPrice.text = "$$$$"
    }
}
