//
//  BoardPeopleCell.swift
//  FaeMapBoard
//
//  Created by vicky on 4/14/17.
//  Copyright © 2017 Yue. All rights reserved.
//

import UIKit

class BoardPeopleCell: UITableViewCell {

    var imgAvatar: UIImageView!
    var lblUsrName: UILabel!
    var lblIntro: UILabel!
    var lblDistance: UILabel!
    var imgGender: UIImageView!
    var imgGenderWithAge: UIImageView!
    var lblAge: UILabel!
    
    override init(style: UITableViewCellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        let separatorView = UIView(frame: CGRect(x: 89.5, y: 89, width: screenWidth - 89.5, height: 1))
        separatorView.backgroundColor = UIColor._225225225()
        addSubview(separatorView)
        selectionStyle = .none
        loadCellContent()
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
    
    fileprivate func loadCellContent() {
        
        imgAvatar = UIImageView(frame: CGRect(x: 15, y: 15, width: 66, height: 66))
        addSubview(imgAvatar)
        imgAvatar.layer.cornerRadius = 33
        imgAvatar.clipsToBounds = true
        imgAvatar.contentMode = .scaleAspectFill
        
        lblUsrName = UILabel()
        addSubview(lblUsrName)
        lblUsrName.font = UIFont(name: "AvenirNext-Medium", size: 18)
        lblUsrName.textColor = UIColor._898989()
        lblUsrName.lineBreakMode = .byTruncatingTail
        addConstraintsWithFormat("H:|-95-[v0]-90-|", options: [], views: lblUsrName)
        
        lblIntro = UILabel()
        addSubview(lblIntro)
        lblIntro.font = UIFont(name: "AvenirNext-Medium", size: 13)
        lblIntro.textColor = UIColor._182182182()
        lblIntro.lineBreakMode = .byTruncatingTail
        addConstraintsWithFormat("H:|-95-[v0]-90-|", options: [], views: lblIntro)
        addConstraintsWithFormat("V:|-23-[v0(25)]-1-[v1(18)]", options: [], views: lblUsrName, lblIntro)
        
        imgGender = UIImageView()
        addSubview(imgGender)
        imgGender.contentMode = .scaleAspectFill
        addConstraintsWithFormat("H:[v0(28)]-15-|", options: [], views: imgGender)
        addConstraintsWithFormat("V:|-12-[v0(18)]", options: [], views: imgGender)
        
        imgGenderWithAge = UIImageView()
        addSubview(imgGenderWithAge)
        imgGenderWithAge.contentMode = .scaleAspectFill
        addConstraintsWithFormat("H:[v0(46)]-15-|", options: [], views: imgGenderWithAge)
        addConstraintsWithFormat("V:|-12-[v0(18)]", options: [], views: imgGenderWithAge)
        
        lblAge = UILabel(frame: CGRect(x: 20, y: 5, width: 24, height: 10))
        imgGenderWithAge.addSubview(lblAge)
        lblAge.textAlignment = .center
        lblAge.font = UIFont(name: "AvenirNext-DemiBold", size: 12)
        lblAge.textColor = .white
        lblAge.lineBreakMode = .byTruncatingTail
        
        lblDistance = UILabel()
        addSubview(lblDistance)
        lblDistance.font = UIFont(name: "AvenirNext-Medium", size: 13)
        lblDistance.textColor = UIColor._155155155()
        lblDistance.textAlignment = .right
        addConstraintsWithFormat("H:[v0(70)]-10-|", options: [], views: lblDistance)
        addConstraintsWithFormat("V:[v0(18)]-12-|", options: [], views: lblDistance)
    }
    
    func setValueForCell(people: BoardUserInfoViewModel) {
        if people.avatar == nil {
            General.shared.avatar(userid: people.people.userId, completion: { (avatarImage) in
                self.imgAvatar.image = avatarImage
            })
        }
        lblUsrName.text = people.name
        lblIntro.text = people.shortIntro
        imgGender.image = people.imageGenderAndAge
        imgGenderWithAge.image = people.imageGenderAndAge
        lblAge.text = people.age
        lblDistance.text = people.distance
    }
}
