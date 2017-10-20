//
//  AlbumTableViewCell.swift
//  quickChat
//
//  Created by User on 7/12/16.
//  Copyright © 2016 User. All rights reserved.
//

import UIKit

// this table view cell is for the table that show every smart album in CustomCollectionViewController

class AlbumTableViewCell: UITableViewCell {
    
    var imgTitle: UIImageView!
    var lblAlbumTitle: UILabel!
    var lblAlbumNumber: UILabel!
    var imgCheckMark: UIImageView!
    
    override init(style: UITableViewCellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        
        imgTitle = UIImageView(frame: CGRect(x: 10, y: 10, width: 60, height: 60))
        imgTitle.contentMode = .scaleAspectFill
        imgTitle.clipsToBounds = true
        addSubview(imgTitle)
        
        lblAlbumTitle = UILabel(frame: CGRect(x: 89, y: 19, w: 260, h: 22))
        lblAlbumTitle.textAlignment = .left
        lblAlbumTitle.textColor = UIColor._898989()
        lblAlbumTitle.font = UIFont(name: "AvenirNext-Medium", size: 18)
        addSubview(lblAlbumTitle)
        
        lblAlbumNumber = UILabel(frame: CGRect(x: 89, y: 41, w: 100, h: 20))
        lblAlbumNumber.textAlignment = .left
        lblAlbumNumber.textColor = UIColor._146146146()
        lblAlbumNumber.font = UIFont(name: "AvenirNext-Medium", size: 15)
        addSubview(lblAlbumNumber)
        
        imgCheckMark = UIImageView()
        imgCheckMark.image = UIImage(named: "albumTableCheckMark")
        addSubview(imgCheckMark)
        addConstraintsWithFormat("H:[v0(19)]-10-|", options: [], views: imgCheckMark)
        addConstraintsWithFormat("V:|-34-[v0(15)]", options: [], views: imgCheckMark)
        
        selectionStyle = .none
        
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
        // Configure the view for the selected state
    }
    
    func setCheckMark(_ bool : Bool) {
        imgCheckMark.isHidden = bool
    }
    
}
