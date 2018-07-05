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
        
        imgDownArrow.image = #imageLiteral(resourceName: "arrow_down")
        
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
        lblContent.numberOfLines = identifier == "hour" ? 0 : 1
        
        addSubview(lblContent)
        addConstraintsWithFormat("H:|-68-[v0]-68-|", options: [], views: lblContent)
        addConstraintsWithFormat("V:|-18-[v0]-18-|", options: [], views: lblContent)
    }
    
    func setValueForCell(_ identifier: String?, place: PlacePin) {
        switch identifier {
        case "map":
            imgIcon.image = #imageLiteral(resourceName: "place_location")
            var addr = place.address1 == "" ? "" : place.address1 + ", "
            addr += place.address2
            
            
            General.shared.getAddress(location: place.loc_coordinate) { (status, address) in
                guard status != 400 else {
                    return
                }
                if let addr = address as? String {
                    print("test placepin \(addr)")
                }
            }
            
            lblContent.text = addr
            break
        case "hour":
            imgIcon.image = #imageLiteral(resourceName: "place_openinghour")
            var openStatus = place.openOrClose
            let todayHours = place.hoursToday
            var hour = ""
            if todayHours.count == 1 && (todayHours[0] == "N/A" || todayHours[0] == "None") && openStatus == "N/A" {
                openStatus = ""
                hour = "N/A"
            } else {
                hour = " / " + todayHours[0]
                if todayHours.count > 1 {
                    for index in 1..<todayHours.count {
                        if openStatus == "Open" {
                            hour += "\n\t\t" + todayHours[index]
                        } else {
                            hour += "\n\t\t   " + todayHours[index]
                        }
                    }
                }
            }
            
            lblContent.attributedText = attributedHourText(openStatus: openStatus, hour: hour)
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
    
    func foldOrUnfold(_ lines: Int = 0, _ boolHidden: Bool, _ image: UIImage, _ space: Int) {
        lblContent.numberOfLines = lines
        separatorView.isHidden = boolHidden
        imgDownArrow.image = image
        cellConstraint = returnConstraintsWithFormat("V:|-18-[v0]-\(space)-|", options: [], views: lblContent)
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
        addConstraintsWithFormat("H:|-67-[v0(\(280 * screenWidthFactor + 2))]", options: [], views: imgViewMap)
        addConstraintsWithFormat("V:|-0-[v0(\(152))]-19-|", options: [], views: imgViewMap)
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(handleMapTap))
        imgViewMap.addGestureRecognizer(tapGesture)
        
        imgPlaceIcon = UIImageView(frame: CGRect(x: 0, y: 50, width: 56, height: 56))
        imgPlaceIcon.center.x = 140 * screenWidthFactor + 1
        imgViewMap.addSubview(imgPlaceIcon)
    }
    
    func setValueForCell(place: PlacePin) {
        imgPlaceIcon.image = place.icon //UIImage(named: "place_map_\(place.class_2_icon_id)") ?? #imageLiteral(resourceName: "place_map_48")
        AddPinToCollectionView().mapScreenShot(coordinate: place.coordinate, size: CGSize(width: 280 * screenWidthFactor, height: 152), icon: false) { [weak self] (snapShotImage) in
            guard let `self` = self else { return }
            self.imgViewMap.image = snapShotImage
            self.imgViewMap.layer.borderColor = UIColor._225225225().cgColor
            self.imgViewMap.layer.borderWidth = 1
        }
    }
    
    @objc func handleMapTap() {
        delegate?.jumpToMainMapWithPlace()
    }
}

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
        var openingHour = hour[0] == "None" ? "N/A" : hour[0]
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

class PlaceHoursHintCell: UITableViewCell {
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
}
