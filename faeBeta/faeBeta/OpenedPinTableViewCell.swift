//
//  OpenedPinTableViewCell.swift
//  faeBeta
//
//  Created by Yue on 11/1/16.
//  Copyright © 2016 fae. All rights reserved.
//

import UIKit
import CoreLocation

protocol OpenedPinTableViewCellDelegate {
    // Pass CL2D location to OpenedPinTableViewController
    func passCL2DLocationToOpenedPinList(coordinate: CLLocationCoordinate2D, commentID: Int)
}

class OpenedPinTableViewCell: UITableViewCell {
 
    var delegate: OpenedPinTableViewCellDelegate?
    
    var imageViewAvatar: UIImageView!
    var content: UILabel!
    var time: UILabel!
    var deleteButton: UIButton!
    var jumpToDetail: UIButton!
    var underLine: UIView!
    var cellY: CGFloat = 0
    var commentID: Int = -999
    var userID: String = "NULL"
    var location: CLLocationCoordinate2D!
    
    override init(style: UITableViewCellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        loadAvatar()
        loadLabel()
        loadUnderLine()
        loadButton()
        loadBackground()
    }
    
    func loadAvatar() {
        imageViewAvatar = UIImageView(frame: CGRect(x: 14, y: 13, width: 50, height: 50))
        imageViewAvatar.image = UIImage(named: "avatar_expand_no")
        self.addSubview(imageViewAvatar)
        imageViewAvatar.layer.masksToBounds = true
        self.addConstraintsWithFormat("H:|-14-[v0(50)]", options: [], views: imageViewAvatar)
        self.addConstraintsWithFormat("V:|-13-[v0(50)]", options: [], views: imageViewAvatar)
    }
    
    func loadLabel() {
        content = UILabel(frame: CGRect(x: 80, y: 17, width: 250, height: 25))
        self.addSubview(content)
        content.font = UIFont(name: "AvenirNext-Regular", size: 18.0)
        content.text = ""
        content.textColor = UIColor(red: 89/255, green: 89/255, blue: 89/255, alpha: 1.0)
        self.addConstraintsWithFormat("H:|-80-[v0(250)]", options: [], views: content)
        self.addConstraintsWithFormat("V:|-17-[v0(25)]", options: [], views: content)
        
        time = UILabel(frame: CGRect(x: 80, y: 41, width: 130, height: 18))
        self.addSubview(time)
        time.font = UIFont(name: "AvenirNext-Medium", size: 13.0)
        time.text = ""
        time.textColor = UIColor(red: 155/255, green: 155/255, blue: 155/255, alpha: 1.0)
        self.addConstraintsWithFormat("H:|-80-[v0(150)]", options: [], views: time)
        self.addConstraintsWithFormat("V:|-41-[v0(18)]", options: [], views: time)
    }
    
    func loadButton() {
        deleteButton = UIButton(frame: CGRect(x: 341, y: 14, width: 100, height: 48))
        let imageDelete = UIImage(named: "comment_pin_delete")
        deleteButton.setImage(imageDelete, forState: .Normal)
        self.addSubview(deleteButton)
        self.addConstraintsWithFormat("H:[v0(100)]-(-27)-|", options: [], views: deleteButton)
        self.addConstraintsWithFormat("V:|-14-[v0(48)]", options: [], views: deleteButton)
        deleteButton.enabled = false
        
        jumpToDetail = UIButton(frame: CGRect(x: 0, y: 3, width: 341, height: 70))
        self.addSubview(jumpToDetail)
        self.addConstraintsWithFormat("H:|-0-[v0(\(screenWidth-73))]", options: [], views: jumpToDetail)
        self.addConstraintsWithFormat("V:|-3-[v0(70)]", options: [], views: jumpToDetail)
        jumpToDetail.addTarget(self, action: #selector(OpenedPinTableViewCell.jumpToDetailAndAnimate(_:)), forControlEvents: .TouchUpInside)
        jumpToDetail.enabled = false
    }
    
    func loadUnderLine() {
        underLine = UIView(frame: CGRectMake(0, 75, screenWidth, 1))
        underLine.layer.borderWidth = screenWidth
        underLine.layer.borderColor = UIColor(red: 200/255, green: 199/255, blue: 204/255, alpha: 1.0).CGColor
        self.addSubview(underLine)
    }
    
    func loadBackground() {
        self.backgroundColor = UIColor.clearColor()
    }
    
    func jumpToDetailAndAnimate(sender: UIButton) {
        print("TESTing Cell Button")
        print(location)
        self.delegate?.passCL2DLocationToOpenedPinList(location, commentID: commentID)
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
