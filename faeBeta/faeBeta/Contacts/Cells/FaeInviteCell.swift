//
//  FaeInviteCell.swift
//  FaeContacts
//
//  Created by 子不语 on 2017/6/29.
//  Copyright © 2017年 Yue. All rights reserved.
//

import UIKit
import MessageUI

protocol ContactsInviteDelegate: class {
    func inviteToFaevorite(indexPath: IndexPath)
}

class FaeInviteCell: UITableViewCell {
    var lblName: UILabel!
    var lblTel: UILabel!
    var btnInvite: UIButton!
    var bottomLine: UIView!
    var indexPath: IndexPath!
    weak var delegate: ContactsInviteDelegate!
    
    override init(style: UITableViewCellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        separatorInset = UIEdgeInsets.zero
        layoutMargins = UIEdgeInsets.zero
        selectionStyle = .none
        loadInviteContent()
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
//    override func prepareForReuse() {
//        super.prepareForReuse()
//        btnInvite.setImage(nil, for: .normal)
//    }
    
    func loadInviteContent() {
        lblName = UILabel()
        lblName.textAlignment = .left
        lblName.textColor = UIColor._898989()
        lblName.font = UIFont(name: "AvenirNext-Medium", size: 18)
        addSubview(lblName)
        addConstraintsWithFormat("H:|-25-[v0]-173-|", options: [], views: lblName)
        
        lblTel = UILabel()
        lblTel.textAlignment = .left
        lblTel.textColor = UIColor._107107107()
        lblTel.font = UIFont(name: "AvenirNext-Medium", size: 13)
        addSubview(lblTel)
        addConstraintsWithFormat("H:|-25-[v0]-173-|", options: [], views: lblTel)
        addConstraintsWithFormat("V:|-17-[v0(22)]-0-[v1(20)]", options: [], views: lblName, lblTel)
        
        btnInvite = UIButton()
        addSubview(btnInvite)
        btnInvite.setImage(#imageLiteral(resourceName: "btnInvite"), for: .normal)
        btnInvite.setImage(#imageLiteral(resourceName: "btnInvited"), for: .selected)
        btnInvite.addTarget(self, action: #selector(self.changeInviteStatus(_:)), for: .touchUpInside)
        addConstraintsWithFormat("V:|-26-[v0(29)]", options: [], views: btnInvite)
        addConstraintsWithFormat("H:[v0(86)]-17-|", options: [], views: btnInvite)
        
        bottomLine = UIView()
        bottomLine.backgroundColor = UIColor._200199204()
        addSubview(bottomLine)
        addConstraintsWithFormat("H:|-14-[v0]-60-|", options: [], views: bottomLine)
        addConstraintsWithFormat("V:[v0(1)]-0-|", options: [], views: bottomLine)
    }
    
    @objc func changeInviteStatus(_ sender: UIButton) {
        delegate?.inviteToFaevorite(indexPath: indexPath)
    }
}
