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
    var grayLine: UIView!
    var showed = false
    
    internal var tblVConstraint = [NSLayoutConstraint]() {
        didSet {
            if oldValue.count != 0 {
                removeConstraints(oldValue)
            }
            if tblVConstraint.count != 0 {
                addConstraints(tblVConstraint)
            }
        }
    }
    
    internal var lineVConstraint = [NSLayoutConstraint]() {
        didSet {
            if oldValue.count != 0 {
                removeConstraints(oldValue)
            }
            if lineVConstraint.count != 0 {
                addConstraints(lineVConstraint)
            }
        }
    }
    
    override init(frame: CGRect = CGRect.zero) {
        super.init(frame: CGRect(x: 7, y: 76 + device_offset_top, width: screenWidth - 14, height: 90))
        loadContent()
        alpha = 0
        layer.zPosition = 605
        addShadow(view: self, opa: 0.5, offset: CGSize.zero, radius: 3)
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    fileprivate func loadContent() {
        tblResults = UITableView()
        tblResults.register(FMPlaceResultBarCell.self, forCellReuseIdentifier: "placeResultBarCell")
        tblResults.delegate = self
        tblResults.dataSource = self
        tblResults.tableFooterView = UIView()
        tblResults.layer.cornerRadius = 2
        tblResults.backgroundColor = .white
        addSubview(tblResults)
        addConstraintsWithFormat("H:|-0-[v0]-0-|", options: [], views: tblResults)
        tblVConstraint = returnConstraintsWithFormat("V:|-0-[v0]-0-|", options: [], views: tblResults)
        
        let footView = UIView()
        footView.clipsToBounds = true
        footView.layer.cornerRadius = 2
        footView.backgroundColor = .white
        addSubview(footView)
        sendSubview(toBack: footView)
        addConstraintsWithFormat("H:|-0-[v0]-0-|", options: [], views: footView)
        addConstraintsWithFormat("V:[v0(54)]-0-|", options: [], views: footView)
        
        lblNumResults = UILabel()
        lblNumResults.textAlignment = .center
        lblNumResults.textColor = UIColor._107105105()
        lblNumResults.font = UIFont(name: "AvenirNext-Medium", size: 16)
        footView.addSubview(lblNumResults)
        footView.addConstraintsWithFormat("H:|-0-[v0]-0-|", options: [], views: lblNumResults)
        footView.addConstraintsWithFormat("V:|-20-[v0(21)]", options: [], views: lblNumResults)
        
        grayLine = UIView()
        grayLine.backgroundColor = UIColor._200199204()
        addSubview(grayLine)
        addConstraintsWithFormat("H:|-0-[v0]-0-|", options: [], views: grayLine)
        lineVConstraint = returnConstraintsWithFormat("V:[v0(1)]-0-|", options: [], views: grayLine)
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
        self.frame.size.height = 90
        self.alpha = 1
        Key.shared.FMVCtrler?.uiviewPlaceBar.alpha = 0
        UIView.animate(withDuration: 0.5, delay: 0, options: .curveEaseOut, animations: {
            self.frame.size.height = screenHeight == 812 ? 587 : 556 * screenHeightFactor
            self.tblVConstraint = self.returnConstraintsWithFormat("V:|-0-[v0]-48-|", options: [], views: self.tblResults)
            self.lineVConstraint = self.returnConstraintsWithFormat("V:[v0(1)]-48-|", options: [], views: self.grayLine)
            self.layoutIfNeeded()
            completion()
        }, completion: { _ in
            self.showed = true
        })
    }
    
    func hide(_ completion: @escaping () -> Void) {
        UIView.animate(withDuration: 0.5, delay: 0, options: .curveEaseOut, animations: {
            self.frame.size.height = 90
            self.tblVConstraint = self.returnConstraintsWithFormat("V:|-0-[v0]-0-|", options: [], views: self.tblResults)
            self.lineVConstraint = self.returnConstraintsWithFormat("V:[v0(1)]-0-|", options: [], views: self.grayLine)
            self.layoutIfNeeded()
            completion()
        }, completion: { _ in
            Key.shared.FMVCtrler?.uiviewPlaceBar.alpha = 1
            self.alpha = 0
            self.showed = false
        })
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
    var arrDay = ["Sat", "Sun", "Mon", "Tue", "Wed", "Thu", "Fri"]
    var arrHour = [String]()
    
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
        if placeInfo.hours.count > 0 {
            arrHour.removeAll()
            for day in arrDay {
                if placeInfo.hours.index(forKey: day) == nil {
                    arrHour.append("N/A")
                } else {
                    arrHour.append(placeInfo.hours[day]!)
                }
            }
            let date = Date()
            let calendar = Calendar.current
            let components = calendar.dateComponents([.weekday], from: date)
            
            if let weekday = components.weekday {
                if weekday == 7 {
                    lblHours.text = arrDay[0] + ": " + arrHour[0]
                } else if weekday == 8 {
                    lblHours.text = arrDay[1] + ": " + arrHour[1]
                } else {
                    lblHours.text = arrDay[weekday] + ": " + arrHour[weekday]
                }
            } else {
                lblHours.text = nil
            }
        } else {
            lblHours.text = nil
        }
        General.shared.downloadImageForView(place: placeInfo, url: placeInfo.imageURL, imgPic: imgSavedItem)
    }
    
    fileprivate func loadContent() {
        imgSavedItem = UIImageView()
        imgSavedItem.layer.cornerRadius = 5
        imgSavedItem.clipsToBounds = true
        addSubview(imgSavedItem)
        addConstraintsWithFormat("H:|-12-[v0(66)]", options: [], views: imgSavedItem)
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
        addConstraintsWithFormat("V:|-66-[v0(12)]", options: [], views: lblPrice)
        lblPrice.text = ""
    }
}

