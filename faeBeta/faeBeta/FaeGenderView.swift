//
//  FaeGenderView.swift
//  FaeGenderView
//
//  Created by Yue on 6/27/17.
//  Copyright © 2017 Yue. All rights reserved.
//

import UIKit
import SwiftyJSON

class FaeGenderView: UIView {
    
    var userId = -1
    var boolAlignLeft = true
    var imgCardGender: UIImageView!
    var lblCardAge: UILabel!
    var realWidth: CGFloat = 0
    var realHeight: CGFloat = 18
    
    static var imageMale = #imageLiteral(resourceName: "userGenderMale")
    static var imageFemale = #imageLiteral(resourceName: "userGenderFemale")
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        backgroundColor = UIColor(r: 149, g: 207, b: 246, alpha: 100)
        layer.cornerRadius = 9 * screenHeightFactor
        clipsToBounds = true
        
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
    
    func loadGenderAge(id: Int, _ completion: @escaping (String, String, String) -> Void ) {
        guard id > 0 else { return }
        let userNameCard = FaeUser()
        userNameCard.getUserCard("\(id)") { (status: Int, message: Any?) in
            DispatchQueue.main.async(execute: {
                guard status / 100 == 2 else { return }
                guard let unwrapMessage = message else {
                    print("[getUserCard] message is nil")
                    return
                }
                let profileInfo = JSON(unwrapMessage)
                let canShowGender = profileInfo["show_gender"].boolValue
                let gender = profileInfo["gender"].stringValue
                let canShowAge = profileInfo["show_age"].boolValue
                let age = profileInfo["age"].stringValue
                joshprint("age", age)
                self.showGenderAge(showGender: canShowGender, gender: gender, showAge: canShowAge, age: age)
                completion(profileInfo["nick_name"].stringValue, profileInfo["user_name"].stringValue, profileInfo["short_intro"].stringValue)
            })
        }
    }
    
    fileprivate func showGenderAge(showGender: Bool, gender: String, showAge: Bool, age: String) {
        
        var marginDiff: CGFloat = 0
        
        if !showGender && !showAge {
            isHidden = true
            imgCardGender.image = nil
            return
        } else if showGender && showAge {
            isHidden = false
            if gender == "male" {
                imgCardGender.image = FaeGenderView.imageMale
                backgroundColor = UIColor._149207246()
            } else if gender == "female" {
                imgCardGender.image = FaeGenderView.imageFemale
                backgroundColor = UIColor._253175222()
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
            lblCardAge.frame.origin.x = 9 * screenHeightFactor
            imgCardGender.image = nil
            backgroundColor = UIColor._210210210()
        } else if showGender && !showAge {
            isHidden = false
            if gender == "male" {
                imgCardGender.image = FaeGenderView.imageMale
                backgroundColor = UIColor._149207246()
            } else if gender == "female" {
                imgCardGender.image = FaeGenderView.imageFemale
                backgroundColor = UIColor._253175222()
            } else {
                imgCardGender.image = nil
            }
            frame.size.width = 28 * screenHeightFactor
            lblCardAge.text = nil
        }
        if !boolAlignLeft {
            marginDiff = 46 * screenWidthFactor - frame.size.width
            frame.origin.x = screenWidth - 61 + marginDiff
        }
    }
}
