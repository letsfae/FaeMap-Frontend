//
//  ManageColListCell.swift
//  faeBeta
//
//  Created by Faevorite 2 on 2017-09-29.
//  Copyright © 2017 fae. All rights reserved.
//

import UIKit

class ManageColListCell: UITableViewCell {
    var imgPic: UIImageView!
    var lblColName: UILabel!
    var lblColAddr: UILabel!
    var lblColMemo: UILabel!
    var btnSelect: UIButton!
    
    override init(style: UITableViewCellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        let separatorView = UIView()
        separatorView.backgroundColor = UIColor._225225225()
        addSubview(separatorView)
        addConstraintsWithFormat("H:|-89.5-[v0]-0-|", options: [], views: separatorView)
        addConstraintsWithFormat("V:[v0(1)]-0-|", options: [], views: separatorView)
        selectionStyle = .none
        loadCellContent()
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    fileprivate func loadCellContent() {
        imgPic = UIImageView(frame: CGRect(x: 12, y: 12, width: 66, height: 66))
        imgPic.backgroundColor = .red
//        imgPic.image =
        imgPic.clipsToBounds = true
        imgPic.layer.cornerRadius = 5
        addSubview(imgPic)
        
        lblColName = FaeLabel(CGRect.zero, .left, .medium, 16, UIColor._898989())
        addSubview(lblColName)
        addConstraintsWithFormat("H:|-93-[v0]-50-|", options: [], views: lblColName)
        
        lblColAddr = FaeLabel(CGRect.zero, .left, .medium, 12, UIColor._107105105())
        addSubview(lblColAddr)
        addConstraintsWithFormat("H:|-93-[v0]-50-|", options: [], views: lblColAddr)
        
        lblColMemo =  FaeLabel(CGRect.zero, .left, .demiBoldItalic, 12, UIColor._107105105())
        lblColMemo.numberOfLines = 0
        addSubview(lblColMemo)
        addConstraintsWithFormat("H:|-93-[v0]-50-|", options: [], views: lblColMemo)
        
        addConstraintsWithFormat("V:|-26-[v0(22)]-0-[v1(16)]-5-[v2]-18-|", options: [], views: lblColName, lblColAddr, lblColMemo)
        
        btnSelect = UIButton()
        btnSelect.setImage(#imageLiteral(resourceName: "mb_btnOvalUnselected"), for: .normal)
        btnSelect.setImage(#imageLiteral(resourceName: "mb_btnOvalSelected"), for: .selected)
        btnSelect.isUserInteractionEnabled = false
//        btnSelect.addTarget(self, action: #selector(actionSelect(_:)), for: .touchUpInside)
        addSubview(btnSelect)
        addConstraintsWithFormat("H:[v0(50)]-0-|", options: [], views: btnSelect)
        addConstraintsWithFormat("V:|-20-[v0(50)]", options: [], views: btnSelect)
    }
    
    func setValueForCell(savedItem: SavedPin) {
        lblColName.text = savedItem.pinName
        lblColAddr.text = savedItem.pinAddr
        lblColMemo.text = savedItem.memo
    }
}
