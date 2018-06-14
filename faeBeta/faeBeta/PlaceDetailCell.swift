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
    static var boolMapFold: Bool = true
    static var boolHourFold: Bool = true
//    var uiviewHiddenCell: UIView!
//
//    static var boolFold = true
//
//    internal var cellConstraint = [NSLayoutConstraint]() {
//        didSet {
//            if oldValue.count != 0 {
//                removeConstraints(oldValue)
//            }
//            if cellConstraint.count != 0 {
//                addConstraints(cellConstraint)
//            }
//        }
//    }
//
//    internal var hiddenViewConstraint = [NSLayoutConstraint]() {
//        didSet {
//            if oldValue.count != 0 {
//                removeConstraints(oldValue)
//            }
//            if hiddenViewConstraint.count != 0 {
//                addConstraints(hiddenViewConstraint)
//            }
//        }
//    }
    
    override init(style: UITableViewCellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        selectionStyle = .none
        loadCellContent(reuseIdentifier)
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
    
    fileprivate func loadCellContent(_ identifier: String?) {
        imgDownArrow = UIImageView(frame: CGRect(x: screenWidth - 41, y: 16, width: 26, height: 30))
        imgDownArrow.contentMode = .center
        addSubview(imgDownArrow)
        
//        imgDownArrow.image = PlaceDetailCell.boolFold ? #imageLiteral(resourceName: "arrow_down") : #imageLiteral(resourceName: "arrow_up")
        
        separatorView = UIView()
        separatorView.backgroundColor = UIColor._225225225()
        addSubview(separatorView)
        addConstraintsWithFormat("H:|-66-[v0]-0-|", options: [], views: separatorView)
        addConstraintsWithFormat("V:[v0(1)]-0-|", options: [], views: separatorView)
//        separatorView.isHidden = !PlaceDetailCell.boolFold
        
        imgIcon = UIImageView(frame: CGRect(x: 20, y: 16, width: 26, height: 26))
        imgIcon.contentMode = .scaleToFill
        addSubview(imgIcon)
        
        lblContent = UILabel()
        lblContent.font = UIFont(name: "AvenirNext-Medium", size: 16)
        lblContent.textColor = UIColor._898989()
        lblContent.numberOfLines = identifier == "hour" ? 0 : 1

        addSubview(lblContent)
        addConstraintsWithFormat("H:|-68-[v0]-68-|", options: [], views: lblContent)
        addConstraintsWithFormat("V:|-18-[v0]-17-|", options: [], views: lblContent)
        
//        uiviewHiddenCell = UIView()
//        addSubview(uiviewHiddenCell)
//        addConstraintsWithFormat("H:|-0-[v0]-0-|", options: [], views: uiviewHiddenCell)
        
//        loadHiddenContent()
//        setCellContraints()
    }
    
//    func loadHiddenContent() {}
    
//    func setCellContraints() {
//        if PlaceDetailCell.boolFold {
//            imgDownArrow.image = #imageLiteral(resourceName: "arrow_down")
//            cellConstraint = returnConstraintsWithFormat("V:|-18-[v0]-17-[v1]-1-|", options: [], views: lblContent, uiviewHiddenCell)
//        } else {
//            imgDownArrow.image = #imageLiteral(resourceName: "arrow_up")
//            cellConstraint = returnConstraintsWithFormat("V:|-18-[v0]-9-[v1]-1-|", options: [], views: lblContent, uiviewHiddenCell)
//        }
//    }
    
    func setValueForCell(_ identifier: String?, place: PlacePin, dayIdx: Int = 0, arrHour: [[String]] = [[]]) {
        switch identifier {
        case "map":
            imgIcon.image = #imageLiteral(resourceName: "place_location")
            var addr = place.address1 == "" ? "" : place.address1 + ", "
            addr += place.address2
            lblContent.text = addr
            
            lblContent.numberOfLines = PlaceDetailCell.boolMapFold ? 1 : 0
            separatorView.isHidden = !PlaceDetailCell.boolMapFold
            imgDownArrow.image = PlaceDetailCell.boolMapFold ? #imageLiteral(resourceName: "arrow_down") : #imageLiteral(resourceName: "arrow_up")
            break
        case "hour":
            imgIcon.image = #imageLiteral(resourceName: "place_openinghour")
            let openStatus = closeOrOpen(arrHour[dayIdx])
            var hour = " / " + arrHour[dayIdx][0]
            if arrHour[0].count > 1 {
                for hourIdx in 1..<arrHour[dayIdx].count {
                    if openStatus == "Open" {
                        hour += "\n\t\t" + arrHour[dayIdx][hourIdx]
                    } else if openStatus == "Closed" {
                        hour += "\n\t\t   " + arrHour[dayIdx][hourIdx]
                    }
                }
            }
            lblContent.attributedText = attributedHourText(openStatus: openStatus, hour: hour)
            
            separatorView.isHidden = !PlaceDetailCell.boolHourFold
            imgDownArrow.image = PlaceDetailCell.boolHourFold ? #imageLiteral(resourceName: "arrow_down") : #imageLiteral(resourceName: "arrow_up")
            break
        case "web":
            imgDownArrow.isHidden = true
            imgIcon.image = #imageLiteral(resourceName: "place_web")
            lblContent.text = place.url
            break
        case "phone":
            imgDownArrow.isHidden = true
            imgIcon.image = #imageLiteral(resourceName: "place_call")
            lblContent.text = place.phone
            break
        default:
            break
        }
    }
    
    func attributedHourText(openStatus: String, hour: String) -> NSMutableAttributedString {
        var attrs_0 = [NSAttributedStringKey.foregroundColor: UIColor._898989(), NSAttributedStringKey.font: UIFont(name: "AvenirNext-DemiBold", size: 16)!]
        switch openStatus {
        case "Closed":
            attrs_0 = [NSAttributedStringKey.foregroundColor: UIColor._2559180(), NSAttributedStringKey.font: UIFont(name: "AvenirNext-DemiBold", size: 16)!]
        case "Open":
            attrs_0 = [NSAttributedStringKey.foregroundColor: UIColor(r: 120, g: 200, b: 32, alpha: 100), NSAttributedStringKey.font: UIFont(name: "AvenirNext-DemiBold", size: 16)!]
        default:
            attrs_0 = [NSAttributedStringKey.foregroundColor: UIColor(r: 120, g: 200, b: 32, alpha: 100), NSAttributedStringKey.font: UIFont(name: "AvenirNext-DemiBold", size: 16)!]
        }
        let attrs_1 = [NSAttributedStringKey.foregroundColor: UIColor._898989(), NSAttributedStringKey.font: UIFont(name: "AvenirNext-Medium", size: 16)!]
        let title_0_attr = NSMutableAttributedString(string: openStatus, attributes: attrs_0)
        let title_1_attr = NSMutableAttributedString(string: hour, attributes: attrs_1)
        title_0_attr.append(title_1_attr)
        
        return title_0_attr
    }
    
    func closeOrOpen(_ todayHour: [String]) -> String {
        
        // MARK: - Jichao fix: bug here, if todayHour is "24 hours", need a check for this case
        
        for hour in todayHour {
            if hour == "N/A" || hour == "24 Hours" || hour == "None" {
                return hour
            }
            
            var startHour: String = String(hour.split(separator: "–")[0])
            var endHour: String = String(hour.split(separator: "–")[1])
            if startHour == "Noon" {
                startHour = "12:00 PM"
            }
            if endHour == "Noon" {
                endHour = "12:00 PM"
            } else if endHour == "Midnight" {
                endHour = "00:00 AM"
            }
            
            let dateFormatter = DateFormatter()
            dateFormatter.locale = Locale(identifier: "en_US_POSIX")
            dateFormatter.dateFormat = "h:mm a"
            let dateStart = dateFormatter.date(from: startHour)
            let dateEnd = dateFormatter.date(from: endHour)
            dateFormatter.dateFormat = "HH:mm"
            
            let date24Start = dateFormatter.string(from: dateStart!)
            let date24End = dateFormatter.string(from: dateEnd!)
            
            let hourStart = Int(date24Start.split(separator: ":")[0])!
            var hourEnd = Int(date24End.split(separator: ":")[0])!
            if endHour.contains("AM") {
                hourEnd = hourEnd + 24
            }
            
            let hourCurrent = Calendar.current.component(.hour, from: Date())
            
            if hourCurrent >= hourStart && hourCurrent < hourEnd {
                return "Open"
            }
        }
        return "Closed"
    }
}

protocol PlaceDetailMapCellDelegate: class {
    func jumpToMainMapWithPlace()
}


class PlaceDetailMapCell: UITableViewCell {
    var separatorView: UIView!
    var boolPlaceAdded = false
    var imgViewMap: UIImageView!
    var imgPlaceIcon: UIImageView!
    weak var delegate: PlaceDetailMapCellDelegate?
    
    override init(style: UITableViewCellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        selectionStyle = .none
        loadCellContent()
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
    
    fileprivate func loadCellContent() {
        separatorView = UIView()
        separatorView.backgroundColor = UIColor._225225225()
        addSubview(separatorView)
        addConstraintsWithFormat("H:|-66-[v0]-0-|", options: [], views: separatorView)
        addConstraintsWithFormat("V:[v0(1)]-0-|", options: [], views: separatorView)
        
        imgViewMap = UIImageView()
        imgViewMap.contentMode = .top
        imgViewMap.clipsToBounds = true
        imgViewMap.isUserInteractionEnabled = true
        addSubview(imgViewMap)
        addConstraintsWithFormat("H:|-68-[v0(\(280 * screenWidthFactor))]", options: [], views: imgViewMap)
        addConstraintsWithFormat("V:|-0-[v0(\(150))]-8-|", options: [], views: imgViewMap)
//        uiviewHiddenCell.addSubview(imgViewMap)
//        uiviewHiddenCell.addConstraintsWithFormat("H:|-68-[v0(\(280 * screenWidthFactor))]", options: [], views: imgViewMap)
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(handleMapTap))
        imgViewMap.addGestureRecognizer(tapGesture)
        
        imgPlaceIcon = UIImageView(frame: CGRect(x: 0, y: 49, width: 56, height: 56))
        imgPlaceIcon.center.x = 140 * screenWidthFactor
        imgViewMap.addSubview(imgPlaceIcon)
    }
    
    func setValueForCell(place: PlacePin) {
        imgPlaceIcon.image = UIImage(named: "place_map_\(place.class_2_icon_id)") ?? #imageLiteral(resourceName: "place_map_48")
        AddPinToCollectionView().mapScreenShot(coordinate: place.coordinate, size: CGSize(width: 280 * screenWidthFactor, height: 200), icon: false) { (snapShotImage) in
            self.imgViewMap.image = snapShotImage
        }
    }
    
    @objc func handleMapTap() {
        delegate?.jumpToMainMapWithPlace()
    }
    
//    override func setCellContraints() {
//        super.setCellContraints()
//        if PlaceDetailCell.boolFold {
//            lblContent.numberOfLines = 1
//            hiddenViewConstraint = returnConstraintsWithFormat("V:|-0-[v0(0)]-0-|", options: [], views: imgViewMap)
//        } else {
//            lblContent.numberOfLines = 0
//            hiddenViewConstraint = returnConstraintsWithFormat("V:|-0-[v0(150)]-8-|", options: [], views: imgViewMap)
//        }
//    }
}

/*
class PlaceDetailHoursCell: PlaceDetailCell { //, UITableViewDelegate, UITableViewDataSource {
    var tblOpeningHours: UITableView!
    var lblHint: UILabel!
    
    var arrDay_LG = ["Saturday", "Sunday", "Monday", "Tuesday", "Wednesday", "Thursday", "Friday"]
    var arrDay = ["Sat", "Sun", "Mon", "Tue", "Wed", "Thu", "Fri"]
    var arrHour = [[String]]()
    var dayIdx = 0
    var boolCellFold: Bool = true
    
    override init(style: UITableViewCellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
    
    override func setValueForCell(place: PlacePin) {
        lblContent.numberOfLines = 0
        
        imgIcon.image = #imageLiteral(resourceName: "place_openinghour")
        
        for day in arrDay {
            if place.hours.index(forKey: day) == nil {
                arrHour.append(["N/A"])
            } else {
                arrHour.append(place.hours[day]!)
            }
        }
        
        let date = Date()
        let calendar = Calendar.current
        let components = calendar.dateComponents([.weekday], from: date)
        
        // components.weekday 2 - Mon, 3 - Tue, 4 - Wed, 5 - Thur, 6 - Fri, 7 - Sat, 8 - Sun
        if let weekday = components.weekday {
            dayIdx = weekday
            let openStatus = closeOrOpen(arrHour[dayIdx])
            
            if weekday == 7 {
                dayIdx = 0
            } else if weekday == 8 {
                dayIdx = 1
            }
            
            var hour = " / " + arrHour[dayIdx][0]
            if arrHour[0].count > 1 {
                for hourIdx in 1..<arrHour[dayIdx].count {
                    if openStatus == "Open" {
                        hour += "\n\t\t" + arrHour[dayIdx][hourIdx]
                    } else if openStatus == "Closed" {
                        hour += "\n\t\t   " + arrHour[dayIdx][hourIdx]
                    }
                }
            }
            
            lblContent.attributedText = attributedHourText(openStatus: openStatus, hour: hour)
        }

//        tblOpeningHours.reloadData()
    }
    
    func attributedHourText(openStatus: String, hour: String) -> NSMutableAttributedString {
        var attrs_0 = [NSAttributedStringKey.foregroundColor: UIColor._898989(), NSAttributedStringKey.font: UIFont(name: "AvenirNext-DemiBold", size: 16)!]
        switch openStatus {
        case "Closed":
            attrs_0 = [NSAttributedStringKey.foregroundColor: UIColor._2559180(), NSAttributedStringKey.font: UIFont(name: "AvenirNext-DemiBold", size: 16)!]
        case "Open":
            attrs_0 = [NSAttributedStringKey.foregroundColor: UIColor(r: 120, g: 200, b: 32, alpha: 100), NSAttributedStringKey.font: UIFont(name: "AvenirNext-DemiBold", size: 16)!]
        default:
            attrs_0 = [NSAttributedStringKey.foregroundColor: UIColor(r: 120, g: 200, b: 32, alpha: 100), NSAttributedStringKey.font: UIFont(name: "AvenirNext-DemiBold", size: 16)!]
        }
        let attrs_1 = [NSAttributedStringKey.foregroundColor: UIColor._898989(), NSAttributedStringKey.font: UIFont(name: "AvenirNext-Medium", size: 16)!]
        let title_0_attr = NSMutableAttributedString(string: openStatus, attributes: attrs_0)
        let title_1_attr = NSMutableAttributedString(string: hour, attributes: attrs_1)
        title_0_attr.append(title_1_attr)
        
        return title_0_attr
    }
    
    func closeOrOpen(_ todayHour: [String]) -> String {
        
        // MARK: - Jichao fix: bug here, if todayHour is "24 hours", need a check for this case
        
        for hour in todayHour {
            if hour == "N/A" || hour == "24 Hours" || hour == "None" {
                return hour
            }
            
            var startHour: String = String(hour.split(separator: "–")[0])
            var endHour: String = String(hour.split(separator: "–")[1])
            if startHour == "Noon" {
                startHour = "12:00 PM"
            }
            if endHour == "Noon" {
                endHour = "12:00 PM"
            } else if endHour == "Midnight" {
                endHour = "00:00 AM"
            }
            
            let dateFormatter = DateFormatter()
            dateFormatter.locale = Locale(identifier: "en_US_POSIX")
            dateFormatter.dateFormat = "h:mm a"
            let dateStart = dateFormatter.date(from: startHour)
            let dateEnd = dateFormatter.date(from: endHour)
            dateFormatter.dateFormat = "HH:mm"
            
            let date24Start = dateFormatter.string(from: dateStart!)
            let date24End = dateFormatter.string(from: dateEnd!)
            
            let hourStart = Int(date24Start.split(separator: ":")[0])!
            var hourEnd = Int(date24End.split(separator: ":")[0])!
            if endHour.contains("AM") {
                hourEnd = hourEnd + 24
            }
            
            let hourCurrent = Calendar.current.component(.hour, from: Date())
            
            if hourCurrent >= hourStart && hourCurrent < hourEnd {
                return "Open"
            }
        }
        return "Closed"
    }
    
    override func loadHiddenContent() {
//        tblOpeningHours = UITableView()
//        uiviewHiddenCell.addSubview(tblOpeningHours)
//        uiviewHiddenCell.addConstraintsWithFormat("H:|-68-[v0]-38-|", options: [], views: tblOpeningHours)
//
//        tblOpeningHours.delegate = self
//        tblOpeningHours.dataSource = self
//        tblOpeningHours.register(PlaceOpeningHourCell.self, forCellReuseIdentifier: "PlaceOpeningHourCell")
//        tblOpeningHours.separatorStyle = .none
//        tblOpeningHours.isUserInteractionEnabled = true
//        tblOpeningHours.isScrollEnabled = false
//        tblOpeningHours.cellLayoutMarginsFollowReadableWidth = true
////        tblOpeningHours.rowHeight = 28
//
////        let foldCell = UITapGestureRecognizer(target: self, action: #selector(actionFoldCell(_:)))
////        tblOpeningHours.addGestureRecognizer(foldCell)
//
//        lblHint = UILabel()
//        lblHint.text = "Holidays may affect these hours"
//        lblHint.textColor = UIColor._182182182()
//        lblHint.font = UIFont(name: "AvenirNext-MediumItalic", size: 15)
//        uiviewHiddenCell.addSubview(lblHint)
//        uiviewHiddenCell.addConstraintsWithFormat("H:|-68-[v0(240)]", options: [], views: lblHint)
    }
    
//    override func setCellContraints() {
//        super.setCellContraints()
//        if PlaceDetailCell.boolFold {
//            hiddenViewConstraint = returnConstraintsWithFormat("V:|-0-[v0(0)]-0-[v1(0)]-0-|", options: [], views: tblOpeningHours, lblHint)
//        } else {
//            hiddenViewConstraint = returnConstraintsWithFormat("V:|-2-[v0(\(28*7))]-11-[v1(20)]-16-|", options: [], views: tblOpeningHours, lblHint)
//        }
//    }
    
//    func actionFoldCell(_ sender: UITapGestureRecognizer) {
//        PlaceDetailCell.boolFold = true
//        setCellContraints()
//    }
    
//    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
//        return arrDay.count
//    }
//
//    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
//        tblOpeningHours.rowHeight = UITableViewAutomaticDimension
//        tblOpeningHours.estimatedRowHeight = 28
//
//        return tblOpeningHours.rowHeight
//    }
//
//    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
//        let cell = tableView.dequeueReusableCell(withIdentifier: "PlaceOpeningHourCell", for: indexPath) as! PlaceOpeningHourCell
//        let row = (indexPath.row + dayIdx) % arrDay.count
//        let day = arrDay_LG[row]
//        let hour = arrHour[row]
//        cell.setValueForOpeningHourCell(day: day, hour: hour)
//
//        if indexPath.row == 0 {
//            cell.lblDay.font = UIFont(name: "AvenirNext-Bold", size: 15)
//            cell.lblHour.font = UIFont(name: "AvenirNext-Bold", size: 15)
//        }
//
//        return cell
//    }
}

class PlaceDetailSection3Cell: PlaceDetailCell {
    
    var isURL = true
    
    override init(style: UITableViewCellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
    
    override func setValueForCell(place: PlacePin) {
        imgDownArrow.isHidden = true
        imgIcon.image = isURL ? #imageLiteral(resourceName: "place_web") : #imageLiteral(resourceName: "place_call")
        lblContent.text = isURL ? place.url : place.phone
    }
}
*/

class PlaceOpeningHourCell: UITableViewCell {
    
    var lblDay: UILabel!
    var lblHour: UILabel!
    
    override init(style: UITableViewCellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        selectionStyle = .none
        loadCellContent()
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
    
    fileprivate func loadCellContent() {
        lblDay = UILabel(frame: CGRect(x: 68, y: 4, width: 85, height: 20))
        lblDay.textColor = UIColor._107105105()
        lblDay.font = UIFont(name: "AvenirNext-Medium", size: 15)
        addSubview(lblDay)
        
        lblHour = UILabel()
        lblHour.textColor = UIColor._107105105()
        lblHour.font = UIFont(name: "AvenirNext-Medium", size: 15)
        lblHour.textAlignment = .right
        lblHour.lineBreakMode = .byWordWrapping
        lblHour.numberOfLines = 0
        addSubview(lblHour)
        
        addConstraintsWithFormat("H:[v0(200)]-38-|", options: [], views: lblHour)
        addConstraintsWithFormat("V:|-4-[v0]-4-|", options: [], views: lblHour)
    }
    
    func setValueForOpeningHourCell(_ day: String, _ hour: [String], bold: Bool) {
        lblDay.text = day
        var openingHour = hour[0]
        if hour.count > 1 {
            for idx in 1..<hour.count {
                openingHour += "\n" + hour[idx]
            }
        }
        
        lblHour.text = openingHour
        
        lblDay.font = bold ? FaeFont(fontType: .bold, size: 15) : FaeFont(fontType: .medium, size: 15)
        lblHour.font = bold ? FaeFont(fontType: .bold, size: 15) : FaeFont(fontType: .medium, size: 15)
    }
}

class PlaceHourMayVaryCell: UITableViewCell {
    var separatorView: UIView!
    var lblHint: UILabel!
    
    override init(style: UITableViewCellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        selectionStyle = .none
        loadCellContent()
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
    
    fileprivate func loadCellContent() {
        separatorView = UIView()
        separatorView.backgroundColor = UIColor._225225225()
        addSubview(separatorView)
        addConstraintsWithFormat("H:|-66-[v0]-0-|", options: [], views: separatorView)
        addConstraintsWithFormat("V:[v0(1)]-0-|", options: [], views: separatorView)
        
        lblHint = UILabel()
        lblHint.text = "Holidays may affect these hours"
        lblHint.textColor = UIColor._182182182()
        lblHint.font = UIFont(name: "AvenirNext-MediumItalic", size: 15)
        addSubview(lblHint)
        addConstraintsWithFormat("H:|-68-[v0(240)]", options: [], views: lblHint)
        addConstraintsWithFormat("V:|-11-[v0(20)]-16-|", options: [], views: lblHint)
    }
//    lblHint = UILabel()
//    lblHint.text = "Holidays may affect these hours"
//    lblHint.textColor = UIColor._182182182()
//    lblHint.font = UIFont(name: "AvenirNext-MediumItalic", size: 15)
//    uiviewHiddenCell.addSubview(lblHint)
//    uiviewHiddenCell.addConstraintsWithFormat("H:|-68-[v0(240)]", options: [], views: lblHint)
//    hiddenViewConstraint = returnConstraintsWithFormat("V:|-2-[v0(\(28*7))]-11-[v1(20)]-16-|", options: [], views: tblOpeningHours, lblHint)
    
    
}
