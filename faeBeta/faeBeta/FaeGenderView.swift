//
//  FaeGenderView.swift
//  FaeGenderView
//
//  Created by Yue on 6/27/17.
//  Copyright © 2017 Yue. All rights reserved.
//

import UIKit

class FaeGenderView: UIView {
    
    var userId = -1
    var boolAlignLeft = true
    var imgCardGender: UIImageView!
    var lblCardAge: UILabel!
    
    override init(frame: CGRect) {
        let newFrame = CGRect(origin: CGPoint(x: frame.minX,
                                              y: frame.minY),
                              size: CGSize(width: 46 * screenWidthFactor,
                                           height: 18 * screenHeightFactor))
        super.init(frame: newFrame)
        
        backgroundColor = UIColor(r: 149, g: 207, b: 246, alpha: 100)
        layer.cornerRadius = 9 * screenHeightFactor
        
        loadContent()
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    fileprivate func loadContent() {
        imgCardGender = UIImageView(frame: CGRect(x: 9, y: 3, width: 10, height: 12))
        imgCardGender.contentMode = .scaleAspectFit
        addSubview(imgCardGender)
        
        lblCardAge = UILabel(frame: CGRect(x: 25, y: 1, width: 16, height: 14))
        lblCardAge.textColor = UIColor.white
        lblCardAge.font = UIFont(name: "AvenirNext-Demibold", size: 13 * screenHeightFactor)
        addSubview(lblCardAge)
    }
    
    func showGenderAge(showGender: Bool, gender: String, showAge: Bool, age: String) {
        
        var marginDiff: CGFloat = 0
        
        if !showGender && !showAge {
            isHidden = true
            imgCardGender.image = nil
            return
        } else if showGender && showAge {
            isHidden = false
            if gender == "male" {
                imgCardGender.image = #imageLiteral(resourceName: "userGenderMale")
                backgroundColor = UIColor.maleBackgroundColor()
            } else if gender == "female" {
                imgCardGender.image = #imageLiteral(resourceName: "userGenderFemale")
                backgroundColor = UIColor.femaleBackgroundColor()
            } else {
                isHidden = true
                imgCardGender.image = nil
            }
            lblCardAge.text = age
            lblCardAge.frame.size = lblCardAge.intrinsicContentSize
            frame.size.width = 32 * screenHeightFactor + lblCardAge.intrinsicContentSize.width
        } else if showAge && !showGender {
            isHidden = false
            lblCardAge.text = age
            lblCardAge.frame.size = lblCardAge.intrinsicContentSize
            frame.size.width = 17 * screenHeightFactor + lblCardAge.intrinsicContentSize.width
            lblCardAge.frame.origin.x = 97 * screenHeightFactor
            imgCardGender.image = nil
            backgroundColor = UIColor.faeAppShadowGrayColor()
        } else if showGender && !showAge {
            isHidden = false
            if gender == "male" {
                imgCardGender.image = #imageLiteral(resourceName: "userGenderMale")
                backgroundColor = UIColor.maleBackgroundColor()
            } else if gender == "female" {
                imgCardGender.image = #imageLiteral(resourceName: "userGenderFemale")
                backgroundColor = UIColor.femaleBackgroundColor()
            } else {
                imgCardGender.image = nil
            }
            frame.size.width = 28 * screenHeightFactor
            lblCardAge.text = nil
        }
        if !boolAlignLeft {
            marginDiff = 46 * screenWidthFactor - frame.size.width
            frame.origin.x = frame.origin.x + marginDiff
        }
    }
    
}
