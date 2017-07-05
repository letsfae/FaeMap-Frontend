//
//  CreatePinOptionsTableView.swift
//  faeBeta
//
//  Created by YAYUAN SHI on 11/29/16.
//  Copyright © 2016 fae. All rights reserved.
//

import UIKit

class CreatePinOptionsTableView: UITableView {
    static let cellHeight:CGFloat = 69
    static let cellReuseIdentifier = "cell"
    init(frame: CGRect){
        super.init(frame: frame, style: .plain)
        setup()
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        setup()
    }
    
    private func setup()
    {
        self.rowHeight = CGFloat(20 * 2 + 29)
        self.backgroundColor = UIColor.clear
        self.separatorStyle = .none
        self.isScrollEnabled = false
        register(CreatePinOptionsTableViewCell.self, forCellReuseIdentifier: CreatePinOptionsTableView.cellReuseIdentifier)
//        register(UINib(nibName: "CreatePinOptionsTableViewCell", bundle: nil ), forCellReuseIdentifier: CreatePinOptionsTableView.cellReuseIdentifier)
    }
}
