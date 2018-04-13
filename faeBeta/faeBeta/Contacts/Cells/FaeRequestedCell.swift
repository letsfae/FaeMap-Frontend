//
//  FaeRequestedCell.swift
//  FaeContacts
//
//  Created by 子不语 on 2017/6/14.
//  Copyright © 2017年 Yue. All rights reserved.
//

import UIKit

protocol ContactsRequestedDelegate: class {
    func withdrawRequest(userId: Int, indexPath: IndexPath)
    func resendRequest(userId: Int, indexPath: IndexPath)
}

class FaeRequestedCell: UITableViewCell {
    
    weak var delegate: ContactsRequestedDelegate?
    var imgAvatar: UIImageView!
    var lblUserName: UILabel!
    var lblUserSaying: UILabel!
    var btnCancelRequest: UIButton!
    var btnResendRequest: UIButton!
    var userId: Int = -1
    //var requestId: Int = -1
    var indexPath: IndexPath!
    var bottomLine: UIView!
    
    override init(style: UITableViewCellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        separatorInset = UIEdgeInsets.zero
        layoutMargins = UIEdgeInsets.zero
        selectionStyle = .none
        loadFriendsCellContent()
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    fileprivate func loadFriendsCellContent() {
        imgAvatar = UIImageView(frame: CGRect.zero)
        imgAvatar.frame = CGRect(x: 14, y: 12, width: 50, height: 50)
        imgAvatar.layer.cornerRadius = 25
        imgAvatar.contentMode = .scaleAspectFill
        imgAvatar.clipsToBounds = true
        addSubview(imgAvatar)
        
        lblUserName = UILabel()
        lblUserName.textAlignment = .left
        lblUserName.textColor = UIColor._898989()
        lblUserName.font = UIFont(name: "AvenirNext-Medium", size: 18)
        addSubview(lblUserName)
        
        lblUserSaying = UILabel()
        lblUserSaying.textAlignment = .left
        lblUserSaying.textColor = UIColor._155155155()
        lblUserSaying.font = UIFont(name: "AvenirNext-Medium", size: 13)
        addSubview(lblUserSaying)
        
        btnCancelRequest = UIButton()
        addSubview(btnCancelRequest)
        btnCancelRequest.setImage(#imageLiteral(resourceName: "cancelRequest"), for: .normal)
        btnCancelRequest.addTarget(self, action: #selector(cancelRequest(_:)), for: .touchUpInside)
        
        btnResendRequest = UIButton()
        addSubview(btnResendRequest)
        btnResendRequest.setImage(#imageLiteral(resourceName: "resendRequest"), for: .normal)
        btnResendRequest.addTarget(self, action: #selector(resendRequest(_:)), for: .touchUpInside)
        
        bottomLine = UIView()
        bottomLine.backgroundColor = UIColor._200199204()
        addSubview(bottomLine)
        addConstraintsWithFormat("H:|-73-[v0]-0-|", options: [], views: bottomLine)
        addConstraintsWithFormat("V:[v0(1)]-0-|", options: [], views: bottomLine)

        addConstraintsWithFormat("H:|-86-[v0]-114-|", options: [], views: lblUserName)
        addConstraintsWithFormat("H:|-86-[v0]-114-|", options: [], views: lblUserSaying)
        addConstraintsWithFormat("V:|-17-[v0(22)]-0-[v1(20)]", options: [], views: lblUserName, lblUserSaying)
        addConstraintsWithFormat("V:|-15-[v0]-15-|", options: [], views: btnCancelRequest)
        addConstraintsWithFormat("V:|-15-[v0]-15-|", options: [], views: btnResendRequest)
        addConstraintsWithFormat("H:[v0(48)]-15-[v1(48)]-10-|", options: [], views:btnCancelRequest, btnResendRequest)
    }
    
    @objc func cancelRequest(_ sender: UIButton) {
        self.delegate?.withdrawRequest(userId: userId, indexPath: indexPath)
    }
    
    @objc func resendRequest(_ sender: UIButton) {
        self.delegate?.resendRequest(userId: userId, indexPath: indexPath)

    }
}
