//
//  File.swift
//  faeBeta
//
//  Created by Jacky on 1/8/17.
//  Copyright © 2017 fae. All rights reserved.
//

import UIKit
import GoogleMaps

extension EditMoreOptionsViewController{
    
    func loadDetailWindow() {
        //Load Navigation Bar
        buttonCancel = UIButton()
        buttonCancel.setImage(UIImage(named: "cancelEditCommentPin"), for: UIControlState())
        self.view.addSubview(buttonCancel)
        self.view.addConstraintsWithFormat("H:|-15-[v0(54)]", options: [], views: buttonCancel)
        self.view.addConstraintsWithFormat("V:|-28-[v0(25)]", options: [], views: buttonCancel)
        buttonCancel.addTarget(self,
                               action: #selector(self.actionCancel(_:)),
                               for: .touchUpInside)
        
        buttonSave = UIButton()
        buttonSave.setImage(UIImage(named: "saveEditCommentPin"), for: UIControlState())
        self.view.addSubview(buttonSave)
        self.view.addConstraintsWithFormat("H:[v0(38)]-15-|", options: [], views: buttonSave)
        self.view.addConstraintsWithFormat("V:|-28-[v0(25)]", options: [], views: buttonSave)
        buttonSave.addTarget(self,
                             action: #selector(self.actionSave(_:)),
                             for: .touchUpInside)
        
        labelTitle = UILabel()
        labelTitle.font = UIFont(name: "AvenirNext-Medium", size: 20)
        labelTitle.text = "Edit Options"
        labelTitle.textColor = UIColor.faeAppInputTextGrayColor()
        labelTitle.textAlignment = .center
        self.view.addSubview(labelTitle)
        self.view.addConstraintsWithFormat("H:[v0(133)]", options: [], views: labelTitle)
        self.view.addConstraintsWithFormat("V:|-28-[v0(27)]", options: [], views: labelTitle)
        NSLayoutConstraint(item: labelTitle, attribute: .centerX, relatedBy: .equal, toItem: self.view, attribute: .centerX, multiplier: 1.0, constant: 0).isActive = true
        
        uiviewLine = UIView(frame: CGRect(x: 0, y: 64 * screenHeightFactor, width: screenWidth, height: 1))
        uiviewLine.layer.borderWidth = screenWidth
        uiviewLine.layer.borderColor = UIColor(red: 200/255, green: 199/255, blue: 204/255, alpha: 1.0).cgColor
        self.view.addSubview(uiviewLine)
        
        tableMoreOptions = UITableView(frame: CGRect(x: 60, y: 91, width: 295, height: tableViewHeight))
        tableMoreOptions.delegate = self
        tableMoreOptions.dataSource = self
        tableMoreOptions.register(EditOptionTableViewCell.self, forCellReuseIdentifier: "moreOption")
        tableMoreOptions.isScrollEnabled = false
        tableMoreOptions.separatorStyle = .none
        
        self.view.addSubview(tableMoreOptions)
        
        uiviewLineBottom = UIView(frame: CGRect(x: 0, y: 685 * screenHeightFactor, width: screenWidth, height: 1))
        uiviewLineBottom.layer.borderWidth = screenWidth
        uiviewLineBottom.layer.borderColor = UIColor(red: 200/255, green: 199/255, blue: 204/255, alpha: 1.0).cgColor
        self.view.addSubview(uiviewLineBottom)
        
        btnFooter = UIButton(frame: CGRect(x: 176 * screenHeightFactor, y: 698 * screenHeightFactor, width: 63, height: 25))
        btnFooter.setTitle("Edit Pin", for: UIControlState())
        btnFooter.setTitleColor(UIColor(red: 155/255, green: 155/255, blue: 155/255, alpha: 1.0), for: .normal)
        btnFooter.setTitleColor(UIColor.lightGray, for: .highlighted)
        btnFooter.titleLabel?.font = UIFont(name: "AvenirNext-Medium", size: 18)
        self.view.addSubview(btnFooter)
        btnFooter.addTarget(self, action: #selector(self.actionCancel(_:)), for: .touchUpInside)
        
        geoCode = CLGeocoder.init()
        let currentLocation = CLLocation.init(latitude: pinGeoLocation.latitude, longitude: pinGeoLocation.longitude)
        geoCode.reverseGeocodeLocation(currentLocation, completionHandler: {
            (response, error) -> Void in
            if response!.count > 0{
                let placemark = response![0]
                let location = "\(placemark.name!),\(placemark.locality!),\(placemark.administrativeArea!),\(placemark.postalCode!),\(placemark.country!)"
                let index = NSIndexPath.init(row: 0, section: 0)
                let cell = self.tableMoreOptions.cellForRow(at: index as IndexPath) as! EditOptionTableViewCell
                cell.labelMiddle.text = location
                self.currentLocation = placemark.location!
            }
            
        })
        
    }

}
