//
//  PinTableViewCell.swift
//  faeBeta
//  Created by Shiqi Wei on 1/22/17.
//  Copyright © 2016 fae. All rights reserved.
//

import UIKit

class PinTableViewCell: UITableViewCell {
    
    let screenWidth = UIScreen.main.bounds.width

    var date : UILabel!
    var time : UILabel!
    var desc : UILabel!
    var like : UILabel!
    var comment : UILabel!
    var moreThanThreePics : UILabel!
    var firstImgView : UIImageView!
    var secondImgView : UIImageView!
    var thirdImgView : UIImageView!
    var likeimg : UIImage!
    var likebtn : UIButton!
    var commimg : UIImage!
    var commbtn : UIButton!
    var tab : UIImageView!
    var hotimgview : UIImageView!
    var hot_status: String!
    var type: String!
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
    
    override init(style: UITableViewCellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        setUpUI()
    }
    
    
    // Setup the cell when creat it
    func setUpUI() {
        
        
         //set the date
        date = UILabel()
        date.font = UIFont(name: "AvenirNext-Medium",size: 13)
        date.textAlignment = NSTextAlignment.left
        date.textColor = UIColor.faeAppTimeTextBlackColor()
        self.addSubview(date)

        
        
        //set the time
        time = UILabel()
        time.font = UIFont(name: "AvenirNext-Medium",size: 13)
        time.textAlignment = NSTextAlignment.right
        time.textColor = UIColor.faeAppInputPlaceholderGrayColor()

        self.addSubview(time)

        
        // set description
        desc = UILabel()
        //desc.isEditable = false
        desc.lineBreakMode = NSLineBreakMode.byTruncatingTail
        desc.numberOfLines = 3
        desc.font = UIFont(name: "AvenirNext-Regular",size: 18)
        desc.textAlignment = NSTextAlignment.left
        desc.textColor = UIColor.faeAppInputTextGrayColor()
        self.addSubview(desc)

        //desc.layer.borderColor = UIColor.black.cgColor
        //self.desc.textContainerInset.top = -4
        //desc.isScrollEnabled = false
        
        // set like number
        like = UILabel()
        like.font = UIFont(name: "AvenirNext-Medium",size: 10)
        like.textAlignment = NSTextAlignment.right
        like.textColor = UIColor.faeAppTimeTextBlackColor()
        self.addSubview(like)

        
        // set like button
        likeimg = UIImage(named: "like")!
        likebtn = UIButton(type:UIButtonType.custom) as UIButton
        likebtn.setImage(likeimg,for:UIControlState.normal)
        self.addSubview(likebtn)

        
        
        // set comment number
        comment = UILabel()
        comment.font = UIFont(name: "AvenirNext-Medium",size: 10)
        comment.textAlignment = NSTextAlignment.right
        comment.textColor = UIColor.faeAppTimeTextBlackColor()
        self.addSubview(comment)

        
        // set comment button
        commimg = UIImage(named: "comment")!
        commbtn = UIButton(type:UIButtonType.custom) as UIButton
        commbtn.setImage(commimg,for:UIControlState.normal)
        self.addSubview(commbtn)

        
        // set tab
        tab = UIImageView()
        self.addSubview(tab!)

        
        // set hot
        hotimgview = UIImageView()
        self.addSubview(hotimgview!)

        
        
        //set pics
        
        firstImgView = UIImageView()
        self.addSubview(firstImgView!)
        
        secondImgView = UIImageView()
        self.addSubview(secondImgView!)
        
        thirdImgView = UIImageView()
        self.addSubview(thirdImgView!)
        
        moreThanThreePics = UILabel()
        moreThanThreePics.text = "3+"
        moreThanThreePics.font = UIFont(name: "AvenirNext-Medium",size: 18)
        moreThanThreePics.textColor = UIColor.faeAppInputPlaceholderGrayColor()
        self.addSubview(moreThanThreePics)
        
    }
    
    
    // call this fuction when reuse cell, set value to the cell and rebuild the layout
    
    func setValueForCell(_ pin: [String: AnyObject]) {
        //The cell is reuseable, so clear the constrains when reuse the cell
        self.removeConstraints(self.constraints)

        firstImgView.isHidden = true
        secondImgView.isHidden = true
        thirdImgView.isHidden = true
        moreThanThreePics.isHidden = true

        
        // set the value to those data
        
        
        let createat = pin["created_at"] as! String?
        date.text = createat?.formatNSDate()

        time.text = (createat?.formatFaeDate())! + " on Map"
        
        hot_status = ""

        if let likeCount = pin["liked_count"] as! Int? {
            like.text = String(likeCount)
            if likeCount >= 15 {
                hot_status = "hot"
            }
        }
        if let commentCount = pin["comment_count"]as! Int?  {
            comment.text = String(commentCount)
            if commentCount >= 10 {
                hot_status = "hot"
            }
        }
        
        
        
        //Add the constraints
        self.addConstraintsWithFormat("H:|-13-[v0(200)]", options: [], views: date)
        self.addConstraintsWithFormat("V:|-12-[v0(18)]", options: [], views: date)
        
        self.addConstraintsWithFormat("H:[v0(160)]-13-|", options: [], views: time)
        self.addConstraintsWithFormat("V:|-12-[v0(18)]", options: [], views: time)
        
        self.addConstraintsWithFormat("H:|-20-[v0]-20-|", options: [], views: desc)
        
        self.addConstraintsWithFormat("H:[v0(27)]-95-|", options: [], views: like)
        self.addConstraintsWithFormat("V:[v0(14)]-11-|", options: [], views: like)
        
        self.addConstraintsWithFormat("H:[v0(18)]-73-|", options: [], views: likebtn)
        self.addConstraintsWithFormat("V:[v0(15)]-12-|", options: [], views: likebtn)
        
        
        self.addConstraintsWithFormat("H:[v0(27)]-34-|", options: [], views: comment)
        self.addConstraintsWithFormat("V:[v0(14)]-11-|", options: [], views: comment)
        
        self.addConstraintsWithFormat("H:[v0(18)]-13-|", options: [], views: commbtn)
        self.addConstraintsWithFormat("V:[v0(15)]-12-|", options: [], views: commbtn)
        
        self.addConstraintsWithFormat("H:|-0-[v0(20)]|", options: [], views: tab)
        self.addConstraintsWithFormat("V:[v0(11)]-14-|", options: [], views: tab)
        
        self.addConstraintsWithFormat("H:[v0(18)]-134-|", options: [], views: hotimgview)
        self.addConstraintsWithFormat("V:[v0(20)]-10-|", options: [], views: hotimgview)
        

        // hot or not
        if(hot_status == "hot"){
            hotimgview.image = UIImage(named: "hot")
        }else{
            hotimgview.image = UIImage()
        }
        
        
        // pic or not(Pin with pics or just pin)
        
        if(pin["type"]as! String? != "comment"){
            
            desc.text = pin["description"] as! String?
            
            tab.image = UIImage(named: "tab_comment")
            
            if let imgArr = pin["file_ids"]{
                let count = imgArr.count
                // no pic
                if(count!==0){
                    self.addConstraintsWithFormat("V:|-39-[v0]-42-|", options: [], views: desc)
                }
                // the first image
                if(count!>0){
                    
                    firstImgView.isHidden = false
                    
                    let imgId = imgArr[0]?.description
                    let fileURL = "https://dev.letsfae.com/files/"+imgId!+"/data"
                    self.addConstraintsWithFormat("H:|-20-[v0(95)]", options: [], views: firstImgView)
                    
                    firstImgView.contentMode = .scaleAspectFill
                    firstImgView.layer.cornerRadius = 13.5
                    firstImgView.clipsToBounds = true
                    firstImgView.isUserInteractionEnabled = true
                    firstImgView.sd_setImage(with: URL(string: fileURL), placeholderImage: nil, options: [.retryFailed, .refreshCached], completed: { (image, error, SDImageCacheType, imageURL) in
                        if image != nil {
                            
                        }
                    })
                    self.addConstraintsWithFormat("V:|-39-[v0]-12-[v1(95)]-42-|", options: [], views: desc,firstImgView)
                }
                // the second image
                
                if(count!>1){
                    secondImgView.isHidden = false
                    let imgId = imgArr[1]?.description
                    let fileURL = "https://dev.letsfae.com/files/"+imgId!+"/data"
                    self.addConstraintsWithFormat("H:[v0]-10-[v1(95)]", options: [], views: firstImgView,secondImgView)
                    secondImgView.contentMode = .scaleAspectFill
                    secondImgView.layer.cornerRadius = 13.5
                    secondImgView.clipsToBounds = true
                    secondImgView.isUserInteractionEnabled = true
                    secondImgView.sd_setImage(with: URL(string: fileURL), placeholderImage: nil, options: [.retryFailed, .refreshCached], completed: { (image, error, SDImageCacheType, imageURL) in
                        if image != nil {
                            
                        }
                    })
                    self.addConstraintsWithFormat("V:[v0]-12-[v1(95)]-42-|", options: [], views: desc,secondImgView)
                }
                //the third image
                if(count!>2){
                    thirdImgView.isHidden = false
                    let imgId = imgArr[2]?.description
                    let fileURL = "https://dev.letsfae.com/files/"+imgId!+"/data"
                    self.addConstraintsWithFormat("H:[v0]-10-[v1(95)]", options: [], views: secondImgView,thirdImgView)
                    
                    thirdImgView.contentMode = .scaleAspectFill
                    thirdImgView.layer.cornerRadius = 13.5
                    thirdImgView.clipsToBounds = true
                    thirdImgView.isUserInteractionEnabled = true
                    thirdImgView.sd_setImage(with: URL(string: fileURL), placeholderImage: nil, options: [.retryFailed, .refreshCached], completed: { (image, error, SDImageCacheType, imageURL) in
                        if image != nil {
                            
                        }
                    })
                    self.addConstraintsWithFormat("V:[v0]-12-[v1(95)]-42-|", options: [], views: desc,thirdImgView)
                }
                // more than 3 pics
                if(count!>3){
                    moreThanThreePics.isHidden = false
                    self.addConstraintsWithFormat("V:[v0]-47-[v1(25)]", options: [], views: desc,moreThanThreePics)
                    self.addConstraintsWithFormat("H:[v0]-18-[v1(23)]", options: [], views: thirdImgView,moreThanThreePics)
                    
                }
                
            }
            
        }else{
            desc.text = pin["content"] as! String?
            tab.image = UIImage(named: "tab_story")
            self.addConstraintsWithFormat("V:|-39-[v0]-42-|", options: [], views: desc)
            
        }

    }
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }
    
    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
        
        // Configure the view for the selected state
    }
    
    
    // Resize the width of the cell
    override func layoutSubviews() {
        self.bounds = CGRect(x: 0,y: 0, width: screenWidth - 18, height:  self.bounds.size.height)

    }
    
}
