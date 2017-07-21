//
//  FaeRequestedCell.swift
//  FaeContacts
//
//  Created by 子不语 on 2017/6/14.
//  Copyright © 2017年 Yue. All rights reserved.
//

import UIKit

protocol SomeDelegateRequested: class {
    func cancelRequest(requestId: Int, indexPath: IndexPath)
    func resendRequest(requestId: Int)
}

class FaeRequestedCell: UITableViewCell {
    
    weak var delegate: SomeDelegateRequested?
    var imgAvatar: UIImageView!
    var lblUserName: UILabel!
    var lblUserSaying: UILabel!
    var btnCancelRequest: UIButton!
    var btnResendRequest: UIButton!
    var requestId: Int!
    var indexPath: IndexPath!
    var bottomLine: UIView!
    
    override init(style: UITableViewCellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        separatorInset = UIEdgeInsets.zero
        layoutMargins = UIEdgeInsets.zero
        loadFriendsCellContent()
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    fileprivate func loadFriendsCellContent() {
        imgAvatar = UIImageView()
        imgAvatar.frame = CGRect(x: 14, y: 12, width: 50, height: 50)
        imgAvatar.layer.cornerRadius = 25
        imgAvatar.contentMode = .scaleAspectFill
        imgAvatar.clipsToBounds = true
        imgAvatar.backgroundColor = .red
        addSubview(imgAvatar)
        
        lblUserName = UILabel()
        lblUserName.textAlignment = .left
        lblUserName.textColor = UIColor.faeAppInputTextGrayColor()
        lblUserName.font = UIFont(name: "AvenirNext-Medium", size: 18)
//        lblUserName.backgroundColor = .blue
        addSubview(lblUserName)
        
        lblUserSaying = UILabel()
        lblUserSaying.textAlignment = .left
        lblUserSaying.textColor = UIColor.faeAppInputPlaceholderGrayColor()
        lblUserSaying.font = UIFont(name: "AvenirNext-Medium", size: 13)
//        lblUserSaying.backgroundColor = .green
        addSubview(lblUserSaying)
        
        btnCancelRequest = UIButton()
        addSubview(btnCancelRequest)
        btnCancelRequest.setImage(#imageLiteral(resourceName: "btnRefuse"), for: .normal)
        btnCancelRequest.addTarget(self, action: #selector(cancelRequest(_:)), for: .touchUpInside)
        
        btnResendRequest = UIButton()
        addSubview(btnResendRequest)
        btnResendRequest.setImage(#imageLiteral(resourceName: "btnRequest"), for: .normal)
        btnResendRequest.addTarget(self, action: #selector(resendRequest(_:)), for: .touchUpInside)
        
        bottomLine = UIView()
        bottomLine.backgroundColor = UIColor.faeAppNavBarBorderColor()
        addSubview(bottomLine)
        addConstraintsWithFormat("H:|-73-[v0]-0-|", options: [], views: bottomLine)
        addConstraintsWithFormat("V:[v0(1)]-0-|", options: [], views: bottomLine)

        addConstraintsWithFormat("H:|-86-[v0]-114-|", options: [], views: lblUserName)
        addConstraintsWithFormat("H:|-86-[v0]-114-|", options: [], views: lblUserSaying)
        addConstraintsWithFormat("V:|-17-[v0(22)]-0-[v1(20)]-17-|", options: [], views: lblUserName, lblUserSaying)
        addConstraintsWithFormat("V:|-17-[v0(45)]-17-|", options: [], views: btnCancelRequest)
        addConstraintsWithFormat("V:|-17-[v0(45)]-17-|", options: [], views: btnResendRequest)
        addConstraintsWithFormat("H:[v0(45)]-0-[v1(45)]-0-|", options: [], views:btnCancelRequest, btnResendRequest)
    }
    
    func cancelRequest(_ sender: UIButton) {
        self.delegate?.cancelRequest(requestId: requestId, indexPath: indexPath)
    }
    
    func resendRequest(_ sender: UIButton) {
        self.delegate?.resendRequest(requestId: requestId)

    }
}
