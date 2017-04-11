//
//  ViewController.swift
//  FaeMapChatSpot
//
//  Created by Sophie Wang on 3/24/17.
//  Copyright 漏 2017 Zixin Wang. All rights reserved.
//

import UIKit

class ViewController: UIViewController, UICollectionViewDelegateFlowLayout, UICollectionViewDataSource {
    
    var chatSpotBar: UIView!
    var imgChatSpot: UIImageView!
    var btnChatEnter: UIButton!
    var lineChatSpotTop: UIView!
    var lineChatSpotBottom: UIView!
    var btnChatSpotLine: UIView!
    var btnChatSpotLinebtn: UIView!
    var btnDropDown: UIButton!
    var chatSpotEmojiBubble: UIButton!
    var chatSpotLeftArrow: UIButton!
    var chatSpotRightArrow: UIButton!
    var chatMemberCollection: UICollectionView!
    var chatPeopleNum: UIView!
    var chatDescription: UIView!
    
    //var InfiniteScrollingCell: UICollectionView!
    //private let reuseIdentifier = "InfiniteScrollingCell"
    
    
    //Chat Spot Variable Initialization
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.view.backgroundColor = UIColor(red: 200/255, green: 199/255, blue: 204/255, alpha: 100)
        
        chatSpotBar = UIView(frame: CGRect(x: 0, y: 0, width: screenWidth, height: 236))
        chatSpotBar.backgroundColor = UIColor.white
        
        imgChatSpot = UIImageView(frame: CGRect(x: (screenWidth/2)-40 ,y: 18 , width:80 , height:80 )) //should add auto layout
        imgChatSpot.image = #imageLiteral(resourceName: "Group 20")
        chatSpotBar.addSubview(imgChatSpot)
        
        let chatGroupName = UILabel(frame: CGRect(x: 0,y: 111, width: screenWidth,height: 30 ))
        chatGroupName.textAlignment = NSTextAlignment.center
        chatGroupName.text = "California Chat"
        chatGroupName.font = UIFont(name: "AvenirNext-Medium",size: 20)
        chatGroupName.textColor = UIColor.darkGray
        chatSpotBar.addSubview(chatGroupName)//should add auto layout
        
        let chatMemberNum = UILabel(frame: CGRect(x: 0,y: 143, width: screenWidth,height: 30 ))
        chatMemberNum.textAlignment = NSTextAlignment.center
        chatMemberNum.text = "39 Members"
        chatMemberNum.font = UIFont(name: "AvenirNext-Medium",size: 16)
        chatMemberNum.textColor = UIColor.lightGray
        chatSpotBar.addSubview(chatMemberNum)//should add auto layout
        
        btnChatEnter = UIButton(frame: CGRect(x: (screenWidth/2)-105 ,y: 185,width: 210 , height:40 ))
        btnChatEnter.center.x = screenWidth/2
        btnChatEnter.setTitle("Enter Chat", for: .normal)
        btnChatEnter.setTitleColor(UIColor.white, for: .normal)
        btnChatEnter.titleLabel?.font = UIFont(name: "AvenirNext-DemiBold", size: 18)
        btnChatEnter.titleLabel?.textAlignment = .center
        btnChatEnter.backgroundColor = UIColor(red:249/255, green:90/255, blue:90/255,alpha:100)
        btnChatEnter.layer.cornerRadius = 20
        chatSpotBar.addSubview(btnChatEnter)//should add auto layout
        
        lineChatSpotBottom = UIView(frame: CGRect(x: 0, y: 236, width: screenWidth, height: 4))
        lineChatSpotBottom.center.x = screenWidth/2
        lineChatSpotBottom.backgroundColor = UIColor(red:241/255, green:241/255, blue:241/255,alpha:100)
        
        chatSpotBar.addSubview(lineChatSpotBottom)
        
        
        lineChatSpotTop = UIView(frame: CGRect(x: 0, y: 65, width: screenWidth, height: 1))
        lineChatSpotTop.center.x = screenWidth/2
        lineChatSpotTop.backgroundColor = UIColor(red:200/255, green:199/255, blue:204/255,alpha:100)
        self.view.addSubview(lineChatSpotTop)
        
        
        self.view.addSubview(chatSpotBar)
        //self.chatSpotBar.addConstraintsWithFormat("H:[v0(50)]-0-|", options: [], views: chatSpotImg)
        //self.chatSpotBar.addConstraintsWithFormat("V:|-0-[v0(50)]", options: [], views: chatSpotImg)
        
        //construct chatSpotBar
        
        chatPeopleNum = UIView(frame: CGRect(x: 0, y: 306, width: screenWidth, height: 33))
        chatPeopleNum.backgroundColor = UIColor.white
        let peopleLabel = UILabel(frame: CGRect(x: 16, y: 10, width: screenWidth-16, height: 20))
        
        let titleFontAttri = [ NSFontAttributeName: UIFont(name: "AvenirNext-Medium", size: 16)! ]
        let memberTitle = NSMutableAttributedString(string: "People 39/50", attributes: titleFontAttri )
        let memberTitleFirst = NSRange(location: 0, length: 6)
        let titleColorAttri = [ NSForegroundColorAttributeName: UIColor.faeAppInputTextGrayColor() ]
        memberTitle.addAttributes(titleColorAttri, range: memberTitleFirst)
        
        let memberTitleSecond = NSRange(location: 7, length: 2)
        memberTitle.addAttribute(NSForegroundColorAttributeName, value: UIColor.faeAppRedColor(), range: memberTitleSecond)
        
        let memberTitleThird = NSRange(location: 9, length: 3)
        memberTitle.addAttribute(NSForegroundColorAttributeName, value: UIColor.faeAppInputPlaceholderGrayColor(), range: memberTitleThird)
        peopleLabel.attributedText = memberTitle
        
        
        //  peopleLabel.text = "People 39/50"
        chatPeopleNum.addSubview(peopleLabel)
        
        self.view.addSubview(chatPeopleNum)
        
        let layout: UICollectionViewFlowLayout = UICollectionViewFlowLayout()
        layout.sectionInset = UIEdgeInsets(top:10 ,left: 15,bottom:19, right:0)
        layout.itemSize = CGSize(width: 50, height:50 )
        layout.scrollDirection = .horizontal
        //chatMemberCollection = UICollectionView(frame: CGRect(x: 0 ,y: 282,width: screenWidth , height:40))
        chatMemberCollection = UICollectionView(frame: CGRect(x: 0 ,y: 339,width: screenWidth , height:85), collectionViewLayout: layout)
        chatMemberCollection.dataSource = self
        chatMemberCollection.delegate = self
        chatMemberCollection.register(UICollectionViewCell.self, forCellWithReuseIdentifier:"MemberCell")
        chatMemberCollection.backgroundColor = UIColor.white
        
        
        self.view.addSubview(chatMemberCollection)
        //construct collectionview
        
        btnChatSpotLine = UIView(frame: CGRect(x: 0, y: 424, width: screenWidth, height: 1))
        btnChatSpotLine.center.x = screenWidth/2
        btnChatSpotLine.backgroundColor = UIColor(red:200/255, green:199/255, blue:204/255,alpha:100)
        self.view.addSubview(btnChatSpotLine)
        
        chatDescription = UIView(frame: CGRect(x: 0 ,y: 425,width: screenWidth , height:310))
        chatDescription.backgroundColor = UIColor.white
        let description = UILabel(frame: CGRect(x: 15, y: 428-425,width: screenWidth, height:22))
        description.text = "Description"
        description.textColor = UIColor(red:89/255,green:89/255,blue:89/255, alpha:100)
        description.font = UIFont(name: "AvenirNext-Medium",size: 16)
        chatDescription.addSubview(description)
        
        let descriptionText = UILabel()
        descriptionText.lineBreakMode = NSLineBreakMode.byTruncatingTail
        descriptionText.numberOfLines = 20
        descriptionText.text = "Once upon a time there was a ninja fruit, inside the ninja fruit there was a ninja.One day someone ate the fruit and also ate the ninja.The person therefore was never seen again."
        descriptionText.textColor = UIColor(red:146/255,green:146/255,blue:146/255, alpha:100)
        descriptionText.font = UIFont(name: "AvenirNext-Medium",size: 16)
        chatDescription.addSubview(descriptionText)
        chatDescription.addConstraintsWithFormat("H:|-20-[v0]-20-|", options:[], views:descriptionText)
        chatDescription.addConstraintsWithFormat("V:|-40-[v0]", options:[], views:descriptionText)
        
        btnChatSpotLinebtn = UIView(frame: CGRect(x: 0 ,y: 280,width: screenWidth , height:1))
        btnChatSpotLinebtn.center.x = screenWidth/2
        btnChatSpotLinebtn.backgroundColor = UIColor(red:200/255, green:199/255, blue:204/255,alpha:100)
        chatDescription.addSubview(btnChatSpotLinebtn)
        
        btnDropDown = UIButton(frame: CGRect(x: (screenWidth/2)-18 ,y: 290,width: 36 , height:9 ))
        btnDropDown.center.x = screenWidth/2
        btnDropDown.backgroundColor = UIColor(red:234/255, green:234/255, blue:234/255,alpha:100)
        btnDropDown.layer.cornerRadius = 5
        chatDescription.addSubview(btnDropDown)//should add auto layout
        
        
        
        self.view.addSubview(chatDescription)
        
        
        
        
        
        
    }
    
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return 14
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "MemberCell",
                                                      for: indexPath)
        
        //let newsize = CGSize(width: 30, height:30)
        
        if(indexPath.row == 0){
            cell.layer.cornerRadius = cell.frame.size.width / 2
            cell.backgroundColor = UIColor.yellow
            
            
            cell.layer.borderWidth = 2
            let cellbordercolor: UIColor = UIColor(red:249/255 ,green: 90/255,blue:90/255,alpha:100)
            cell.layer.borderColor = cellbordercolor.cgColor  //supposed to be resized to 52
            
            
        }
        else{
            
            cell.layer.cornerRadius = cell.frame.size.width / 2
            cell.backgroundColor = UIColor.yellow
            cell.layer.borderWidth = 0
            
        }
        
        return cell
    }
    
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    
}
