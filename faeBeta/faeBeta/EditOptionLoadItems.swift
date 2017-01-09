//
//  File.swift
//  faeBeta
//
//  Created by Jacky on 1/8/17.
//  Copyright © 2017 fae. All rights reserved.
//

import UIKit

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
        labelTitle.textColor = UIColor(red: 89/255, green: 89/255, blue: 89/255, alpha: 1.0)
        self.view.addSubview(labelTitle)
        self.view.addConstraintsWithFormat("H:[v0(133)]", options: [], views: labelTitle)
        self.view.addConstraintsWithFormat("V:|-28-[v0(27)]", options: [], views: labelTitle)
        NSLayoutConstraint(item: labelTitle, attribute: .centerX, relatedBy: .equal, toItem: self.view, attribute: .centerX, multiplier: 1.0, constant: 0).isActive = true
        
        uiviewLine = UIView(frame: CGRect(x: 0, y: 64, width: screenWidth, height: 1))
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
    }
    
}
