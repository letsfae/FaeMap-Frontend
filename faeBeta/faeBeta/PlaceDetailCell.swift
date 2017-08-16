//
//  PlaceDetailCell.swift
//  faeBeta
//
//  Created by Faevorite 2 on 2017-08-15.
//  Copyright © 2017 fae. All rights reserved.
//

import UIKit

class PlaceDetailCell: UITableViewCell {
    var imgIcon: UIImageView!
    var lblContent: UILabel!
    var imgDownArrow: UIImageView!
    var separatorView: UIView!
    var uiviewHiddenCell: UIView!
    
    internal var cellContraint = [NSLayoutConstraint]() {
        didSet {
            if oldValue.count != 0 {
                removeConstraints(oldValue)
            }
            if cellContraint.count != 0 {
                addConstraints(cellContraint)
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
        lblContent.lineBreakMode = .byWordWrapping
        addSubview(lblContent)
        addConstraintsWithFormat("H:|-68-[v0]-68-|", options: [], views: lblContent)
        
        uiviewHiddenCell = UIView()
//        uiviewHiddenCell.backgroundColor = .red
        addSubview(uiviewHiddenCell)
        addConstraintsWithFormat("H:|-0-[v0]-0-|", options: [], views: uiviewHiddenCell)
        
        setCellContraints()
    }
    
    func setCellContraints() {
        if imgDownArrow.image == nil || imgDownArrow.image == #imageLiteral(resourceName: "arrow_down") {
            cellContraint = returnConstraintsWithFormat("V:|-18-[v0(22)]-17-[v1(0)]-1-|", options: [], views: lblContent, uiviewHiddenCell)
            uiviewHiddenCell.isHidden = true
        } else {
            cellContraint = returnConstraintsWithFormat("V:|-18-[v0]-9-[v1]-1-|", options: [], views: lblContent, uiviewHiddenCell)
            uiviewHiddenCell.isHidden = false
        }
    }
    
    fileprivate func loadDownArrow() {
        imgDownArrow = UIImageView(frame: CGRect(x: screenWidth - 41, y: 16, width: 26, height: 30))
        imgDownArrow.contentMode = .center
        imgDownArrow.image = #imageLiteral(resourceName: "arrow_down")
        addSubview(imgDownArrow)
    }
    
    func setValueForCell(place: PlacePin) {}
}

class PlaceDetailSection1Cell: PlaceDetailCell {
    
    override init(style: UITableViewCellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        loadHiddenContent()
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func setValueForCell(place: PlacePin) {
        imgIcon.image = #imageLiteral(resourceName: "place_location")
        lblContent.text = place.address1 + ", " + place.address2
    }
    
    func loadHiddenContent() {
        let mapView = UIImageView()
        mapView.image = #imageLiteral(resourceName: "defaultPlaceIcon")
        mapView.contentMode = .scaleToFill
        uiviewHiddenCell.addSubview(mapView)
        uiviewHiddenCell.addConstraintsWithFormat("V:|-0-[v0(150)]-8-|", options: [], views: mapView)
        uiviewHiddenCell.addConstraintsWithFormat("H:|-\(screenWidth / 2 - 140)-[v0(280)]", options: [], views: mapView)
    }
}

class PlaceDetailSection2Cell: PlaceDetailCell, UITableViewDelegate, UITableViewDataSource {
    var arrDay = ["Monday", "Tuesday", "Wednesday", "Thursday", "Friday", "Saturday", "Sunday"]
    var arrHour = ["10:00 AM - 8:00 PM", "10:00 AM - 8:00 PM", "10:00 AM - 8:00 PM", "N.A", "10:00 AM - 8:00 PM", "10:00 AM - 8:00 PM", "N.A"]
    
    override init(style: UITableViewCellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        loadHiddenContent()
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func setValueForCell(place: PlacePin) {
        imgIcon.image = #imageLiteral(resourceName: "place_openinghour")
        lblContent.text = "Open / 9:00am - 8:00pm"
    }
    
    func loadHiddenContent() {
        let lblHint = UILabel()
        lblHint.text = "Holiday might affect these hours."
        lblHint.textColor = UIColor._182182182()
        lblHint.font = UIFont(name: "AvenirNext-MediumItalic", size: 15)
        uiviewHiddenCell.addSubview(lblHint)
        uiviewHiddenCell.addConstraintsWithFormat("H:|-68-[v0(240)]", options: [], views: lblHint)
        
        let tblOpeningHours = UITableView()
        uiviewHiddenCell.addSubview(tblOpeningHours)
        uiviewHiddenCell.addConstraintsWithFormat("H:|-68-[v0]-38-|", options: [], views: tblOpeningHours)
        uiviewHiddenCell.addConstraintsWithFormat("V:|-2-[v0(\(28 * 7))]-11-[v1(20)]-16-|", options: [], views: tblOpeningHours, lblHint)
        
        tblOpeningHours.delegate = self
        tblOpeningHours.dataSource = self
        tblOpeningHours.register(PlaceOpeningHourCell.self, forCellReuseIdentifier: "PlaceOpeningHourCell")
        tblOpeningHours.separatorStyle = .none
        tblOpeningHours.allowsSelection = false
        tblOpeningHours.rowHeight = 28
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return arrDay.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "PlaceOpeningHourCell", for: indexPath) as! PlaceOpeningHourCell
        let day = arrDay[indexPath.row]
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
        lblContent.text = row == 0 ? "https://www.faemaps.com/" : "+1 (209) 829 9986"
    }
}

class PlaceOpeningHourCell: UITableViewCell {
    var lblDay: UILabel!
    var lblHour: UILabel!
    override init(style: UITableViewCellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
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
