//
//  FaeContactsCell.swift
//  FaeContacts
//
//  Created by 子不语 on 2017/6/14.
//  Copyright © 2017年 Yue. All rights reserved.
//

import UIKit

protocol SomeDelegateReceivedRequests: class {
    func refuseRequest(requestId: Int, indexPath: IndexPath)
    func acceptRequest(requestId: Int, indexPath: IndexPath)
}

class FaeReceivedCell: UITableViewCell {
    
    weak var delegate: SomeDelegateReceivedRequests?
    var imgAvatar: UIImageView!
    var lblUserName: UILabel!
    var lblUserSaying: UILabel!
    var btnAgreeRequest: UIButton!
    var btnRefuseRequest: UIButton!
    var userId: Int = -1
    var requestId: Int = -1
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
        imgAvatar = UIImageView(frame: CGRect(x: 14, y: 12, width: 50, height: 50))
        imgAvatar.layer.cornerRadius = 25
        imgAvatar.contentMode = .scaleAspectFill
        imgAvatar.clipsToBounds = true
//        imgAvatar.backgroundColor = .red
        addSubview(imgAvatar)
        
        lblUserName = UILabel()
        lblUserName.textAlignment = .left
        lblUserName.textColor = UIColor._898989()
        lblUserName.font = UIFont(name: "AvenirNext-Medium", size: 18)
//        lblUserName.backgroundColor = .blue
        addSubview(lblUserName)
        
        lblUserSaying = UILabel()
        lblUserSaying.textAlignment = .left
        lblUserSaying.textColor = UIColor._155155155()
        lblUserSaying.font = UIFont(name: "AvenirNext-Medium", size: 13)
//        lblUserSaying.backgroundColor = .green
        addSubview(lblUserSaying)
        
        btnAgreeRequest = UIButton()
        addSubview(btnAgreeRequest)
        btnAgreeRequest.setImage(#imageLiteral(resourceName: "acceptRequest"), for: .normal)
        btnAgreeRequest.addTarget(self, action: #selector(self.acceptRequest(_:)), for: .touchUpInside)
        
        btnRefuseRequest = UIButton()
        addSubview(btnRefuseRequest)
        btnRefuseRequest.setImage(#imageLiteral(resourceName: "cancelRequest"), for: .normal)
        btnRefuseRequest.addTarget(self, action: #selector(self.refuseRequest(_:)), for: .touchUpInside)
        
        bottomLine = UIView()
        bottomLine.backgroundColor = UIColor._200199204()
        addSubview(bottomLine)
        addConstraintsWithFormat("H:|-73-[v0]-0-|", options: [], views: bottomLine)
        addConstraintsWithFormat("V:[v0(1)]-0-|", options: [], views: bottomLine)

        
        addConstraintsWithFormat("H:|-86-[v0]-114-|", options: [], views: lblUserName)
        addConstraintsWithFormat("H:|-86-[v0]-114-|", options: [], views: lblUserSaying)
        addConstraintsWithFormat("V:|-17-[v0(22)]-0-[v1(20)]", options: [], views: lblUserName, lblUserSaying)
        addConstraintsWithFormat("V:|-15-[v0]-15-|", options: [], views: btnAgreeRequest)
        addConstraintsWithFormat("V:|-15-[v0]-15-|", options: [], views: btnRefuseRequest)
        addConstraintsWithFormat("H:[v0(48)]-15-[v1(48)]-10-|", options: [], views:btnRefuseRequest, btnAgreeRequest)
    }
    
    func refuseRequest(_ sender: UIButton) {
        self.delegate?.refuseRequest(requestId: requestId, indexPath: indexPath)
    }
    
    func acceptRequest(_ sender: UIButton) {
        self.delegate?.acceptRequest(requestId: requestId, indexPath: indexPath)
    }
}
