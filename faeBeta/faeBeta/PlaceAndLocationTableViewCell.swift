//
//  PlaceAndLocationTableViewCell.swift
//  faeBeta
//  Created by Shiqi Wei on 1/22/17.
//  Copyright © 2016 fae. All rights reserved.
//

import UIKit

class PlaceAndLocationTableViewCell: UITableViewCell {
    
    var imgview : UIImageView!
    var lblName : UILabel!
    var lblAddress : UILabel!
    var lblDistance : UILabel!
    var lblMemo : UILabel!
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
        self.addSubview(imgview)
        
        lblName = UILabel()
        lblName.font = UIFont(name: "AvenirNext-Medium", size: 16)
        lblName.textAlignment = .left
        lblName.textColor = UIColor._898989()
        self.addSubview(lblName)
        
        lblDistance = UILabel()
        lblDistance.font = UIFont(name: "AvenirNext-Medium", size: 16)
        lblDistance.textAlignment = .right
        lblDistance.textColor = UIColor._155155155()
        self.addSubview(lblDistance)
        
        lblAddress = UILabel()
        lblAddress.font = UIFont(name: "AvenirNext-Medium", size: 12)
        lblAddress.textAlignment = .left
        lblAddress.textColor = UIColor._107107107()
        lblAddress.lineBreakMode = NSLineBreakMode.byWordWrapping
        lblAddress.numberOfLines = 0;
        self.addSubview(lblAddress)
        
        lblMemo = UILabel()
        lblMemo.font = UIFont(name: "AvenirNext-DemiBoldItalic", size: 12)
        lblMemo.textAlignment = .left
        lblMemo.textColor = UIColor._107107107()
        lblMemo.lineBreakMode = NSLineBreakMode.byWordWrapping
        lblMemo.numberOfLines = 0;
        self.addSubview(lblMemo)

        btnSelected = UIButton()
        btnSelected.layer.cornerRadius = 11
        btnSelected.layer.borderColor = UIColor(red: 225/255, green: 225/255, blue: 225/255, alpha: 1).cgColor
        btnSelected.layer.backgroundColor = UIColor(red: 246/255, green: 246/255, blue: 246/255, alpha: 1).cgColor
        btnSelected.layer.borderWidth = 2
        btnSelected.isHidden = true
        self.addSubview(btnSelected)
    }
    
    func setValueForCell(_ location: [String: AnyObject]) {
        /*API 写完后再写这里*/
        lblName?.text = location["name"] as! String?
        lblAddress?.text = location["address"] as! String?
        lblDistance?.text = location["distance"] as! String?
        lblMemo?.text = location["memo"] as! String?
        imgview?.image = UIImage(named: "Location")
        /*API 写完后再写这里*/

        self.removeConstraints(self.constraints)
        self.addConstraintsWithFormat("H:|-12-[v0(66)]", options: [], views: imgview)
        self.addConstraintsWithFormat("V:|-12-[v0(66)]", options: [], views: imgview)
        self.addConstraintsWithFormat("H:|-93-[v0(200)]", options: [], views: lblName)
        self.addConstraintsWithFormat("H:[v0(80)]-11-|", options: [], views: lblDistance)
        self.addConstraintsWithFormat("H:|-93-[v0(200)]", options: [], views: lblAddress)
        
        self.addConstraintsWithFormat("H:|-93-[v0]-47-|", options: [], views: lblMemo)
        
        self.addConstraintsWithFormat("V:|-34-[v0(22)]", options: [], views: lblDistance)
        
        self.addConstraintsWithFormat("H:[v0(22)]-15-|", options: [], views: btnSelected)
        self.addConstraintsWithFormat("V:|-35-[v0(22)]", options: [], views: btnSelected)
        self.addConstraintsWithFormat("V:|-18-[v0(22)]", options: [], views: lblName)
        if lblMemo?.text == "" {
            self.addConstraintsWithFormat("V:|-40-[v0]-15-|", options: [], views: lblAddress)
        }
        else {
            self.addConstraintsWithFormat("V:|-40-[v0]-5-[v1]-15-|", options: [], views: lblAddress,lblMemo)
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
