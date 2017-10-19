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
        imgPic.clipsToBounds = true
        imgPic.layer.cornerRadius = 9
        addSubview(imgPic)
        
        lblListName = UILabel(frame: CGRect(x: 102, y: 29, width: screenWidth - 102 - 15, height: 25))
        lblListName.textColor = UIColor._898989()
        lblListName.font = UIFont(name: "AvenirNext-Medium", size: 18)
        addSubview(lblListName)
        
        lblListNum = UILabel(frame: CGRect(x: 102, y: 55, width: screenWidth - 102 - 15, height: 18))
        lblListNum.textColor = UIColor._107105105()
        lblListNum.font = UIFont(name: "AvenirNext-Medium", size: 13)
        addSubview(lblListNum)
    }
    
    func setValueForCell(cols: PinCollection) {
        imgPic.image = cols.colType == "place" ? #imageLiteral(resourceName: "defaultPlaceIcon") : #imageLiteral(resourceName: "collection_locIcon")
        lblListName.text = cols.colName
        lblListNum.text = cols.itemsCount == 0 ? "0 item" : "\(cols.itemsCount) items"
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


