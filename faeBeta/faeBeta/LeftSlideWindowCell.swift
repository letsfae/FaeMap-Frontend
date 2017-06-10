//
//  LeftSlideWindowCell.swift
//  SetPicture
//
//  Created by Jacky on 12/17/16.
//  Copyright © 2016 Jacky. All rights reserved.
//

import UIKit

protocol LeftSlideCellDelegate: class {
    func invisibleSwitch(isOn: Bool)
    func mapBoardSwitch(isOn: Bool)
}

class LeftSlideWindowCell: UITableViewCell {
    
    var imageLeft: UIImageView!
    var labelMiddle: UILabel!
    var switchRight: UISwitch!
    
//    weak var delegate: LeftSlideCellDelegate?
    
    override init(style: UITableViewCellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        loadItem()
        selectionStyle = .none
    }
    
    fileprivate func loadItem() {
        imageLeft = UIImageView()
        imageLeft.contentMode = .scaleAspectFill
        imageLeft.clipsToBounds = true
        addSubview(imageLeft)
        addConstraintsWithFormat("H:|-25-[v0(28)]", options: [], views: imageLeft)
        addConstraintsWithFormat("V:|-20-[v0(28)]", options: [], views: imageLeft)
        
        labelMiddle = UILabel()
        labelMiddle.font = UIFont(name: "AvenirNext-Medium", size: 18)
        labelMiddle.textColor = UIColor(red: 89 / 255, green: 89 / 255, blue: 89 / 255, alpha: 1)
        addSubview(labelMiddle)
        addConstraintsWithFormat("H:|-68-[v0(143.65)]", options: [], views: labelMiddle)
        addConstraintsWithFormat("V:|-21-[v0(28)]", options: [], views: labelMiddle)
        
        switchRight = UISwitch(frame: CGRect(x: 0, y: 0, width: 39, height: 23))
        switchRight.isHidden = true
        switchRight.isOn = false
        switchRight.onTintColor = UIColor(red: 249 / 255, green: 90 / 255, blue: 90 / 255, alpha: 1)
        switchRight.transform = CGAffineTransform(scaleX: 39 / 51, y: 23 / 31)
        addSubview(switchRight)
        addConstraintsWithFormat("H:[v0(39)]-23-|", options: [], views: switchRight)
        addConstraintsWithFormat("V:|-20-[v0(23)]", options: [], views: switchRight)
//        switchRight.addTarget(self, action: #selector(self.switchFunctionality(_:)), for: .valueChanged)
    }
    
//    func switchFunctionality(_ sender: UISwitch) {
//        print("[switchFunctionality]", sender.tag)
//        if sender.tag == 0 {
//            self.delegate?.mapBoardSwitch(isOn: sender.isOn)
//        } else if sender.tag == 1 {
//            self.delegate?.invisibleSwitch(isOn: sender.isOn)
//        }
//    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
}
