//
//  PlaceAndLocationTableViewCell.swift
//  faeBeta
//  Created by Shiqi Wei on 1/22/17.
//  Copyright © 2016 fae. All rights reserved.
//

import UIKit

class PlaceAndLocationTableViewCell: UITableViewCell {
    
    let screenWidth = UIScreen.main.bounds.width
    let screenHeight = UIScreen.main.bounds.height
    
    var imgview : UIImageView!
    var name : UILabel!
    var address : UILabel!
    var distance : UILabel!
    var btnSelected: UIButton!
//    var sparator: UIView!
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
    
    override init(style: UITableViewCellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        self.setUpUI()
    }
    
    func setUpUI() {
        
        imgview = UIImageView()
        //showImage!.layer.masksToBounds = true
        self.addSubview(imgview)
        //Add the constraints
        self.addConstraintsWithFormat("H:|-12-[v0(66)]", options: [], views: imgview)
        self.addConstraintsWithFormat("V:|-12-[v0(66)]", options: [], views: imgview)
        
        
        name = UILabel()
        name.font = UIFont(name: "AvenirNext-Medium",size: 16)
        name.textAlignment = NSTextAlignment.left
        name.textColor = UIColor.faeAppInputTextGrayColor()
        self.addSubview(name)
        self.addConstraintsWithFormat("H:|-93-[v0(200)]", options: [], views: name)
        self.addConstraintsWithFormat("V:|-18-[v0(20)]", options: [], views: name)
        
        distance = UILabel()
        distance.font = UIFont(name: "AvenirNext-Medium",size: 16)
        distance.textAlignment = NSTextAlignment.right
        distance.textColor = UIColor.faeAppInputPlaceholderGrayColor()
        self.addSubview(distance)
        self.addConstraintsWithFormat("H:[v0(80)]-11-|", options: [], views: distance)
        self.addConstraintsWithFormat("V:|-34-[v0(22)]-34-|", options: [], views: distance)

        address = UILabel()
        address.font = UIFont(name: "AvenirNext-Medium",size: 12)
        address.textAlignment = NSTextAlignment.left
        address.textColor = UIColor.faeAppTimeTextBlackColor()
        address.lineBreakMode = NSLineBreakMode.byWordWrapping
        address.numberOfLines = 0;
        self.addSubview(address)
        self.addConstraintsWithFormat("H:|-93-[v0(200)]", options: [], views: address)
        self.addConstraintsWithFormat("V:|-40-[v0(38)]", options: [], views: address)
        
        btnSelected = UIButton()
        btnSelected.layer.cornerRadius = 11
        btnSelected.layer.borderColor = UIColor(red:225/255,green:225/255,blue:225/255,alpha: 1).cgColor
        btnSelected.layer.backgroundColor = UIColor(red:246/255,green:246/255,blue:246/255,alpha: 1).cgColor
        btnSelected.layer.borderWidth = 2
        btnSelected.isHidden = true
        
        self.addSubview(btnSelected)
        self.addConstraintsWithFormat("H:[v0(22)]-15-|", options: [], views: btnSelected)
        self.addConstraintsWithFormat("V:|-35-[v0(22)]", options: [], views: btnSelected)
        
        
    }
    
    func setValueForCell(_ location: [String: AnyObject]) {
        /*API 写完后再写这里*/
//        name?.text = location[0]
//        address?.text = location[1]
//        distance?.text = location[2]
        /*API 写完后再写这里*/
        imgview?.image = UIImage(named: "Location")
    }
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }
    

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
        //print("啦啦啦啦啦啦啦啦啦啦啦")
        // Configure the view for the selected state
    }
    
}
