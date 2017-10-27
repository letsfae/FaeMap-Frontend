//
//  PlaceDetailCell.swift
//  faeBeta
//
//  Created by Vicky on 2017-08-15.
//  Copyright © 2017 fae. All rights reserved.
//

import UIKit

class PlaceDetailCell: UITableViewCell {
    var imgIcon: UIImageView!
    var lblContent: UILabel!
    var imgDownArrow: UIImageView!
    var separatorView: UIView!
    var uiviewHiddenCell: UIView!
    
    static var boolFold = true
    
    internal var cellConstraint = [NSLayoutConstraint]() {
        didSet {
            if oldValue.count != 0 {
                removeConstraints(oldValue)
            }
            if cellConstraint.count != 0 {
                addConstraints(cellConstraint)
            }
        }
    }
    
    internal var hiddenViewConstraint = [NSLayoutConstraint]() {
        didSet {
            if oldValue.count != 0 {
                removeConstraints(oldValue)
            }
            if hiddenViewConstraint.count != 0 {
                addConstraints(hiddenViewConstraint)
            }
        }
    }
    
    override init(style: UITableViewCellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        selectionStyle = .none
        loadDownArrow()
        loadCellContent()
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    fileprivate func loadCellContent() {
        separatorView = UIView()
        separatorView.backgroundColor = UIColor._225225225()
        addSubview(separatorView)
        addConstraintsWithFormat("H:|-66-[v0]-0-|", options: [], views: separatorView)
        addConstraintsWithFormat("V:[v0(1)]-0-|", options: [], views: separatorView)
        
        imgIcon = UIImageView(frame: CGRect(x: 20, y: 16, width: 26, height: 26))
        imgIcon.contentMode = .scaleToFill
        addSubview(imgIcon)
        
        lblContent = UILabel()
        lblContent.font = UIFont(name: "AvenirNext-Medium", size: 16)
        lblContent.textColor = UIColor._898989()
        lblContent.numberOfLines = 0
        addSubview(lblContent)
        addConstraintsWithFormat("H:|-68-[v0]-68-|", options: [], views: lblContent)
        
        uiviewHiddenCell = UIView()
        addSubview(uiviewHiddenCell)
        addConstraintsWithFormat("H:|-0-[v0]-0-|", options: [], views: uiviewHiddenCell)
        
        loadHiddenContent()
        setCellContraints()
    }
    
    func loadHiddenContent() {}
    
    func setCellContraints() {
        if PlaceDetailCell.boolFold {
            imgDownArrow.image = #imageLiteral(resourceName: "arrow_down")
            cellConstraint = returnConstraintsWithFormat("V:|-18-[v0(22)]-17-[v1]-1-|", options: [], views: lblContent, uiviewHiddenCell)
        } else {
            imgDownArrow.image = #imageLiteral(resourceName: "arrow_up")
            cellConstraint = returnConstraintsWithFormat("V:|-18-[v0]-9-[v1]-1-|", options: [], views: lblContent, uiviewHiddenCell)
        }
    }
    
    fileprivate func loadDownArrow() {
        imgDownArrow = UIImageView(frame: CGRect(x: screenWidth - 41, y: 16, width: 26, height: 30))
        imgDownArrow.contentMode = .center
        addSubview(imgDownArrow)
    }
    
    func setValueForCell(place: PlacePin) {}
}

protocol PlaceDetailSmallMapCellDelegate: class {
    func jumpToMainMapWithPlace()
}

class PlaceDetailMapCell: PlaceDetailCell {
    
    var placeData: PlacePin!
    var boolPlaceAdded = false
    var imgViewMap: UIImageView!
    var imgPlaceIcon: UIImageView!
    weak var delegate: PlaceDetailSmallMapCellDelegate?
    
    override init(style: UITableViewCellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func setValueForCell(place: PlacePin) {
        placeData = place
        imgIcon.image = #imageLiteral(resourceName: "place_location")
        lblContent.text = place.address1 + ", " + place.address2
        imgPlaceIcon.image = UIImage(named: "place_map_\(placeData.class_2_icon_id)") ?? #imageLiteral(resourceName: "place_map_48")
        AddPinToCollectionView().mapScreenShot(coordinate: placeData.coordinate, size: CGSize(width: 280 * screenWidthFactor, height: 200), icon: false) { (snapShotImage) in
            self.imgViewMap.image = snapShotImage
        }
    }
    
    override func loadHiddenContent() {
        imgViewMap = UIImageView()
        imgViewMap.contentMode = .top
        imgViewMap.clipsToBounds = true
        imgViewMap.isUserInteractionEnabled = true
        uiviewHiddenCell.addSubview(imgViewMap)
        uiviewHiddenCell.addConstraintsWithFormat("H:|-68-[v0(\(280 * screenWidthFactor))]", options: [], views: imgViewMap)
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(handleMapTap))
        imgViewMap.addGestureRecognizer(tapGesture)
        
        imgPlaceIcon = UIImageView(frame: CGRect(x: 0, y: 49, width: 56, height: 56))
        imgPlaceIcon.center.x = 140 * screenWidthFactor
        imgViewMap.addSubview(imgPlaceIcon)
    }
    
    func handleMapTap() {
        delegate?.jumpToMainMapWithPlace()
    }
    
    override func setCellContraints() {
        super.setCellContraints()
        if PlaceDetailCell.boolFold {
            hiddenViewConstraint = returnConstraintsWithFormat("V:|-0-[v0(0)]-0-|", options: [], views: imgViewMap)
        } else {
            hiddenViewConstraint = returnConstraintsWithFormat("V:|-0-[v0(150)]-8-|", options: [], views: imgViewMap)
        }
    }
}

class PlaceDetailHoursCell: PlaceDetailCell, UITableViewDelegate, UITableViewDataSource {
    var tblOpeningHours: UITableView!
    var lblHint: UILabel!
    
    var arrDay_LG = ["Saturday", "Sunday", "Monday", "Tuesday", "Wednesday", "Thursday", "Friday"]
    var arrDay = ["Sat", "Sun", "Mon", "Tue", "Wed", "Thu", "Fri"]
    var arrHour = [String]()
    
    override init(style: UITableViewCellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func setValueForCell(place: PlacePin) {
        imgIcon.image = #imageLiteral(resourceName: "place_openinghour")
        for day in arrDay {
            if place.hours.index(forKey: day) == nil {
                arrHour.append("N/A")
            } else {
                arrHour.append(place.hours[day]!)
            }
        }
        
        let date = Date()
        let calendar = Calendar.current
        let components = calendar.dateComponents([.weekday], from: date)
        
        if let weekday = components.weekday {
            if weekday == 7 {
                lblContent.text = arrDay_LG[0] + " / " + arrHour[0]
            } else if weekday == 8 {
                lblContent.text = arrDay_LG[1] + " / " + arrHour[1]
            } else {
                lblContent.text = arrDay_LG[weekday] + " / " + arrHour[weekday]
            }
        }

        tblOpeningHours.reloadData()
    }
    
    override func loadHiddenContent() {
        tblOpeningHours = UITableView()
        uiviewHiddenCell.addSubview(tblOpeningHours)
        uiviewHiddenCell.addConstraintsWithFormat("H:|-68-[v0]-38-|", options: [], views: tblOpeningHours)
        
        tblOpeningHours.delegate = self
        tblOpeningHours.dataSource = self
        tblOpeningHours.register(PlaceOpeningHourCell.self, forCellReuseIdentifier: "PlaceOpeningHourCell")
        tblOpeningHours.separatorStyle = .none
        tblOpeningHours.isUserInteractionEnabled = true
        tblOpeningHours.isScrollEnabled = false
        tblOpeningHours.rowHeight = 28
        
//        let foldCell = UITapGestureRecognizer(target: self, action: #selector(actionFoldCell(_:)))
//        tblOpeningHours.addGestureRecognizer(foldCell)
        
        lblHint = UILabel()
        lblHint.text = "Holiday might affect these hours."
        lblHint.textColor = UIColor._182182182()
        lblHint.font = UIFont(name: "AvenirNext-MediumItalic", size: 15)
        uiviewHiddenCell.addSubview(lblHint)
        uiviewHiddenCell.addConstraintsWithFormat("H:|-68-[v0(240)]", options: [], views: lblHint)
    }
    
    override func setCellContraints() {
        super.setCellContraints()
        if PlaceDetailCell.boolFold {
            hiddenViewConstraint = returnConstraintsWithFormat("V:|-0-[v0(0)]-0-[v1(0)]-0-|", options: [], views: tblOpeningHours, lblHint)
        } else {
            hiddenViewConstraint = returnConstraintsWithFormat("V:|-2-[v0(\(28 * 7))]-11-[v1(20)]-16-|", options: [], views: tblOpeningHours, lblHint)
        }
    }
    
//    func actionFoldCell(_ sender: UITapGestureRecognizer) {
//        PlaceDetailCell.boolFold = true
//        setCellContraints()
//    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return arrDay.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "PlaceOpeningHourCell", for: indexPath) as! PlaceOpeningHourCell
        let day = arrDay_LG[indexPath.row]
        let hour = arrHour[indexPath.row]
        cell.setValueForCell(day: day, hour: hour)
        return cell
    }
}

class PlaceDetailSection3Cell: PlaceDetailCell {
    var row: Int = 0
    
    override init(style: UITableViewCellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func setValueForCell(place: PlacePin) {
        imgDownArrow.isHidden = true
        imgIcon.image = row == 0 ? #imageLiteral(resourceName: "place_web") : #imageLiteral(resourceName: "place_call")
        lblContent.text = row == 0 ? place.url : place.phone
    }
}

class PlaceOpeningHourCell: UITableViewCell {
    var lblDay: UILabel!
    var lblHour: UILabel!
    override init(style: UITableViewCellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        selectionStyle = .none
        loadContent()
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    fileprivate func loadContent() {
        lblDay = UILabel(frame: CGRect(x: 0, y: 4, width: 85, height: 20))
        lblDay.textColor = UIColor._107105105()
        lblDay.font = UIFont(name: "AvenirNext-Medium", size: 15)
        addSubview(lblDay)
        
        lblHour = UILabel()
        lblHour.textColor = UIColor._107105105()
        lblHour.font = UIFont(name: "AvenirNext-Medium", size: 15)
        lblHour.textAlignment = .right
        addSubview(lblHour)
        
        addConstraintsWithFormat("H:[v0(150)]-0-|", options: [], views: lblHour)
        addConstraintsWithFormat("V:|-4-[v0(20)]", options: [], views: lblHour)
    }
    
    func setValueForCell(day: String, hour: String) {
        lblDay.text = day
        lblHour.text = hour
    }
}
