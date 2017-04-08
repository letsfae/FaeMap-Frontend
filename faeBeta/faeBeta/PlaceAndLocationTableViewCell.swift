//
//  PlaceAndLocationTableViewCell.swift
//  faeBeta
//  Created by Shiqi Wei on 1/22/17.
//  Copyright © 2016 fae. All rights reserved.
//

import UIKit

class PlaceAndLocationTableViewCell: UITableViewCell {
    
    
    var imgview : UIImageView!
    var name : UILabel!
    var address : UILabel!
    var distance : UILabel!
    var memo : UILabel!
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
        
        
        
        name = UILabel()
        name.font = UIFont(name: "AvenirNext-Medium",size: 16)
        name.textAlignment = NSTextAlignment.left
        name.textColor = UIColor.faeAppInputTextGrayColor()
        self.addSubview(name)
        
        
        distance = UILabel()
        distance.font = UIFont(name: "AvenirNext-Medium",size: 16)
        distance.textAlignment = NSTextAlignment.right
        distance.textColor = UIColor.faeAppInputPlaceholderGrayColor()
        self.addSubview(distance)
        
        
        address = UILabel()
        address.font = UIFont(name: "AvenirNext-Medium",size: 12)
        address.textAlignment = NSTextAlignment.left
        address.textColor = UIColor.faeAppTimeTextBlackColor()
        address.lineBreakMode = NSLineBreakMode.byWordWrapping
        address.numberOfLines = 0;
        self.addSubview(address)
        
        
        
        memo = UILabel()
        memo.font = UIFont(name: "AvenirNext-DemiBoldItalic",size: 12)
        memo.textAlignment = NSTextAlignment.left
        memo.textColor = UIColor.faeAppTimeTextBlackColor()
        memo.lineBreakMode = NSLineBreakMode.byWordWrapping
        memo.numberOfLines = 0;
        self.addSubview(memo)
        
        
        
        
        btnSelected = UIButton()
        btnSelected.layer.cornerRadius = 11
        btnSelected.layer.borderColor = UIColor(red:225/255,green:225/255,blue:225/255,alpha: 1).cgColor
        btnSelected.layer.backgroundColor = UIColor(red:246/255,green:246/255,blue:246/255,alpha: 1).cgColor
        btnSelected.layer.borderWidth = 2
        btnSelected.isHidden = true
        
        self.addSubview(btnSelected)
        
    }
    
    func setValueForCell(_ location: [String: AnyObject]) {
        /*API 写完后再写这里*/
        name?.text = location["name"] as! String?
        address?.text = location["address"] as! String?
        distance?.text = location["distance"] as! String?
        memo?.text = location["memo"] as! String?
        imgview?.image = UIImage(named: "Location")
        /*API 写完后再写这里*/
        
        
        self.removeConstraints(self.constraints)
        
        
        self.addConstraintsWithFormat("H:|-12-[v0(66)]", options: [], views: imgview)
        self.addConstraintsWithFormat("V:|-12-[v0(66)]", options: [], views: imgview)
        self.addConstraintsWithFormat("H:|-93-[v0(200)]", options: [], views: name)
        self.addConstraintsWithFormat("H:[v0(80)]-11-|", options: [], views: distance)
        self.addConstraintsWithFormat("H:|-93-[v0(200)]", options: [], views: address)
        
        self.addConstraintsWithFormat("H:|-93-[v0]-47-|", options: [], views: memo)
        
        self.addConstraintsWithFormat("V:|-34-[v0(22)]", options: [], views: distance)
        
        self.addConstraintsWithFormat("H:[v0(22)]-15-|", options: [], views: btnSelected)
        self.addConstraintsWithFormat("V:|-35-[v0(22)]", options: [], views: btnSelected)
        self.addConstraintsWithFormat("V:|-18-[v0(22)]", options: [], views: name)
        if(memo?.text == ""){
            self.addConstraintsWithFormat("V:|-40-[v0]-15-|", options: [], views: address)
        }else{
            self.addConstraintsWithFormat("V:|-40-[v0]-5-[v1]-15-|", options: [], views: address,memo)
        }
        
        
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
