//
//  CollectionsListCell.swift
//  faeBeta
//
//  Created by Faevorite 2 on 2017-08-08.
//  Copyright © 2017 fae. All rights reserved.
//

import UIKit

class CollectionsListCell: UITableViewCell {
    
    var imgPic: UIImageView!
    var imgAvatar: UIImageView!
    var lblListName: UILabel!
    var lblListNum: UILabel!
    var imgIsIn: UIImageView!
    
    override init(style: UITableViewCellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        let separatorView = UIView(frame: CGRect(x: 98, y: 99, width: screenWidth - 98, height: 1))
        separatorView.backgroundColor = UIColor._225225225()
        addSubview(separatorView)
//        selectionStyle = .none
        loadCellContent()
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    fileprivate func loadCellContent() {
        imgPic = UIImageView(frame: CGRect(x: 11, y: 15, width: 72, height: 72))
        imgPic.clipsToBounds = true
        imgPic.contentMode = .scaleAspectFill
        addSubview(imgPic)
        
        imgAvatar = UIImageView(frame: CGRect(x: 64, y: 68, width: 25, height: 25))
        imgAvatar.clipsToBounds = true
        imgAvatar.layer.borderColor = UIColor.white.cgColor
        imgAvatar.layer.borderWidth = 3
        imgAvatar.layer.cornerRadius = 12.5
        addSubview(imgAvatar)
        
        lblListName = UILabel(frame: CGRect(x: 102, y: 29, width: screenWidth - 102 - 15, height: 25))
        lblListName.textColor = UIColor._898989()
        lblListName.font = UIFont(name: "AvenirNext-Medium", size: 18)
        addSubview(lblListName)
        
        lblListNum = UILabel(frame: CGRect(x: 102, y: 55, width: screenWidth - 102 - 15, height: 18))
        lblListNum.textColor = UIColor._107105105()
        lblListNum.font = UIFont(name: "AvenirNext-Medium", size: 13)
        addSubview(lblListNum)
        
        imgIsIn = UIImageView()
        imgIsIn.image = #imageLiteral(resourceName: "mb_tick")
        addSubview(imgIsIn)
        addConstraintsWithFormat("H:[v0(20)]-12-|", options: [], views: imgIsIn)
        addConstraintsWithFormat("V:|-41-[v0(20)]", options: [], views: imgIsIn)
        imgIsIn.isHidden = true
    }
    
    func setValueForCell(cols: RealmCollection, isIn: Bool = false) {
        imgPic.image = cols.type == "place" ? #imageLiteral(resourceName: "defaultPlaceIcon") : #imageLiteral(resourceName: "collection_locIcon")
        General.shared.avatar(userid: cols.user_id, completion: { avatarImage in
            self.imgAvatar.image = avatarImage
        })
        lblListName.text = cols.name
        lblListNum.text = cols.count <= 1 ? "\(cols.count) item" : "\(cols.count) items"
        imgIsIn.isHidden = !isIn
    }
}

class CollectionsEmptyListCell: UITableViewCell {
    var imgPic: UIImageView!
    var lblListName: UILabel!
    var lblListNum: UILabel!
    
    override init(style: UITableViewCellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        let separatorView = UIView(frame: CGRect(x: 98, y: 99, width: screenWidth - 98, height: 1))
        separatorView.backgroundColor = UIColor._225225225()
        addSubview(separatorView)
        selectionStyle = .none
        loadCellContent()
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    fileprivate func loadCellContent() {
        imgPic = UIImageView(frame: CGRect(x: 11, y: 15, width: 70, height: 70))
        imgPic.image = #imageLiteral(resourceName: "collection_emptyListIcon")
        addSubview(imgPic)
        
        lblListName = UILabel(frame: CGRect(x: 102, y: 40, width: screenWidth - 102 - 15, height: 25))
        lblListName.textColor = UIColor._898989()
        lblListName.font = UIFont(name: "AvenirNext-Medium", size: 18)
        lblListName.text = "Create a New List..."
        addSubview(lblListName)
    }
}


