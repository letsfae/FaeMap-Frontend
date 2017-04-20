//
//  ViewController.swift
//  FaeMapChatSpot
//
//  Created by Sophie Wang on 3/24/17.
//  Copyright 漏 2017 Zixin Wang. All rights reserved.
//

import UIKit

class ViewController: UIViewController, UICollectionViewDelegateFlowLayout, UICollectionViewDataSource{
    
    var btnChatEnter: UIButton!
    var btnChatSpotLeftArrow: UIButton!
    var btnChatSpotRightArrow: UIButton!
    var btnDropDown: UIButton!
    var chatSpotEmojiBubble: UIButton!
    var cllcviewChatMember: UICollectionView!
    var imgChatSpot: UIImageView!
    var lblChatMemberNum: UILabel!
    var lblDescriptionText: UILabel!
    var mutableAttrStringMemberNum: NSMutableAttributedString!
    var mutableAttrStringMemberTotal: NSMutableAttributedString!
    var uiviewChatDescription: UIView!
    var uiviewChatPeopleNum: UIView!
    var uiviewChatSpotBar: UIView!
    var uiviewChatSpotLine: UIView!
    var uiviewChatSpotLineFirstBottom: UIView!
    var uiviewChatSpotLineSecondBottom: UIView!
    var uiviewChatSpotLineTop: UIView!
    //Chat Spot Variable Initialization
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.view.backgroundColor = UIColor(red: 200/255, green: 199/255, blue: 204/255, alpha: 100)
        
        uiviewChatSpotBar = UIView(frame: CGRect(x: 0, y: 0, width: screenWidth, height: 236))
        uiviewChatSpotBar.backgroundColor = UIColor.white
        
        imgChatSpot = UIImageView(frame: CGRect(x: (screenWidth/2)-40, y: 18, width: 80, height: 80))
        imgChatSpot.layer.cornerRadius = 40
        imgChatSpot.clipsToBounds = true
        imgChatSpot.backgroundColor = UIColor.faeAppRedColor()
        uiviewChatSpotBar.addSubview(imgChatSpot)
        
        let lblChatGroupName = UILabel(frame: CGRect(x: 0, y: 111, width: screenWidth, height: 30))
        lblChatGroupName.textAlignment = NSTextAlignment.center
        lblChatGroupName.text = "California Chat"
        lblChatGroupName.font = UIFont(name: "AvenirNext-Medium", size: 20)
        lblChatGroupName.textColor = UIColor.faeAppInputTextGrayColor()
        uiviewChatSpotBar.addSubview(lblChatGroupName)
        
        lblChatMemberNum = UILabel(frame: CGRect(x: 0, y: 143, width: screenWidth, height: 30))
        lblChatMemberNum.textAlignment = NSTextAlignment.center
        lblChatMemberNum.text = "39 Members"
        lblChatMemberNum.font = UIFont(name: "AvenirNext-Medium", size: 16)
        lblChatMemberNum.textColor = UIColor.faeAppInputPlaceholderGrayColor()
        
        uiviewChatSpotBar.addSubview(lblChatMemberNum)
        
        btnChatEnter = UIButton(frame: CGRect(x: 0, y: 185, width: 210 , height: 40))
        btnChatEnter.center.x = screenWidth/2
        btnChatEnter.setTitle("Enter Chat", for: .normal)
        btnChatEnter.setTitleColor(UIColor.white, for: .normal)
        btnChatEnter.titleLabel?.font = UIFont(name: "AvenirNext-DemiBold", size: 18)
        btnChatEnter.titleLabel?.textAlignment = .center
        btnChatEnter.backgroundColor = UIColor(red: 249/255, green: 90/255, blue: 90/255, alpha: 100)
        btnChatEnter.layer.cornerRadius = 20
        uiviewChatSpotBar.addSubview(btnChatEnter)
        
        uiviewChatSpotLineFirstBottom = UIView(frame: CGRect(x: 0, y: 236, width: screenWidth, height: 4))
        uiviewChatSpotLineFirstBottom.center.x = screenWidth/2
        uiviewChatSpotLineFirstBottom.backgroundColor = UIColor(red: 241/255, green: 241/255, blue: 241/255, alpha: 100)
        
        uiviewChatSpotBar.addSubview(uiviewChatSpotLineFirstBottom)
        //add first bottom line
        
        uiviewChatSpotLineTop = UIView(frame: CGRect(x: 0, y: 65, width: screenWidth, height: 1))
        uiviewChatSpotLineTop.center.x = screenWidth/2
        uiviewChatSpotLineTop.backgroundColor = UIColor(red: 200/255, green: 199/255, blue: 204/255, alpha: 100)
        self.view.addSubview(uiviewChatSpotLineTop)
        //add top line
        
        self.view.addSubview(uiviewChatSpotBar)
        
        uiviewChatPeopleNum = UIView(frame: CGRect(x: 0, y: 306, width: screenWidth, height: 33))
        uiviewChatPeopleNum.backgroundColor = UIColor.white
        let peopleLabel = UILabel(frame: CGRect(x: 16, y: 10, width: screenWidth-16, height: 20))
        
        let attriMemberStrPeople = [NSForegroundColorAttributeName: UIColor.faeAppInputTextGrayColor(),
                                    NSFontAttributeName: UIFont(name: "AvenirNext-Medium", size: 16)!]
        
        let attriMemberNum = [NSForegroundColorAttributeName: UIColor.faeAppRedColor(),
                              NSFontAttributeName: UIFont(name: "AvenirNext-Medium", size: 16)!]
        
        let attriMemberTotal = [ NSForegroundColorAttributeName: UIColor.faeAppInputPlaceholderGrayColor(),NSFontAttributeName: UIFont(name: "AvenirNext-Medium", size: 16)! ]
        //set attributes
        
        let mutableAttrStringPeople = NSMutableAttributedString(string: "People  ", attributes: attriMemberStrPeople)
        mutableAttrStringMemberNum = NSMutableAttributedString(string: "39", attributes: attriMemberNum)
        let mutableAttrStringSlash = NSMutableAttributedString(string: "/", attributes: attriMemberTotal)
        mutableAttrStringMemberTotal = NSMutableAttributedString(string: "50", attributes: attriMemberTotal)
        //set attributed parts
        
        let mutableStrIniTitle = NSMutableAttributedString(string:"")
        mutableStrIniTitle.append(mutableAttrStringPeople)
        mutableStrIniTitle.append(mutableAttrStringMemberNum)
        mutableStrIniTitle.append(mutableAttrStringSlash)
        mutableStrIniTitle.append(mutableAttrStringMemberTotal)
        peopleLabel.attributedText = mutableStrIniTitle
        
        uiviewChatPeopleNum.addSubview(peopleLabel)
        
        self.view.addSubview(uiviewChatPeopleNum)
        
        let layout = UICollectionViewFlowLayout()
        layout.sectionInset = UIEdgeInsets(top: 10, left: 15, bottom: 19, right: 0)
        layout.itemSize = CGSize(width: 50, height: 50)
        layout.scrollDirection = .horizontal
        cllcviewChatMember = UICollectionView(frame: CGRect(x: 0, y: 339, width: screenWidth, height: 85), collectionViewLayout: layout)
        cllcviewChatMember.dataSource = self
        cllcviewChatMember.delegate = self
        cllcviewChatMember.register(UICollectionViewCell.self, forCellWithReuseIdentifier:"MemberCell")
        cllcviewChatMember.backgroundColor = UIColor.white
        
        self.view.addSubview(cllcviewChatMember)
        //construct collectionview
        
        uiviewChatSpotLine = UIView(frame: CGRect(x: 0, y: 424, width: screenWidth, height: 1))
        uiviewChatSpotLine.center.x = screenWidth/2
        uiviewChatSpotLine.backgroundColor = UIColor(red: 200/255, green: 199/255, blue: 204/255, alpha: 100)
        self.view.addSubview(uiviewChatSpotLine)
        
        uiviewChatDescription = UIView(frame: CGRect(x: 0 , y: 425, width: screenWidth , height: 310))
        uiviewChatDescription.backgroundColor = UIColor.white
        let lbldescription = UILabel(frame: CGRect(x: 15, y: 14, width: screenWidth, height: 22))
        lbldescription.text = "Description"
        lbldescription.textColor = UIColor(red: 89/255, green: 89/255, blue: 89/255, alpha: 100)
        lbldescription.font = UIFont(name: "AvenirNext-Medium", size: 16)
        uiviewChatDescription.addSubview(lbldescription)
        
        lblDescriptionText = UILabel()
        lblDescriptionText.lineBreakMode = NSLineBreakMode.byTruncatingTail
        lblDescriptionText.numberOfLines = 20
        lblDescriptionText.text = "Once upon a time there was a ninja fruit, inside the ninja fruit there was a ninja.One day someone ate the fruit and also ate the ninja.The person therefore was never seen again."
        lblDescriptionText.textColor = UIColor(red: 146/255, green: 146/255, blue: 146/255, alpha: 100)
        lblDescriptionText.font = UIFont(name: "AvenirNext-Medium", size: 16)
        uiviewChatDescription.addSubview(lblDescriptionText)
        uiviewChatDescription.addConstraintsWithFormat("H:|-20-[v0]-20-|", options: [], views: lblDescriptionText)
        uiviewChatDescription.addConstraintsWithFormat("V:|-40-[v0]", options: [], views: lblDescriptionText)
        
        uiviewChatSpotLineSecondBottom = UIView(frame: CGRect(x: 0, y: 280, width: screenWidth, height: 1))
        uiviewChatSpotLineSecondBottom.center.x = screenWidth/2
        uiviewChatSpotLineSecondBottom.backgroundColor = UIColor(red: 200/255, green: 199/255, blue: 204/255, alpha:100)
        uiviewChatDescription.addSubview(uiviewChatSpotLineSecondBottom)
        btnDropDown = UIButton(frame: CGRect(x: (screenWidth/2)-18, y: 290, width: 36, height: 9))
        btnDropDown.center.x = screenWidth/2
        btnDropDown.backgroundColor = UIColor(red: 234/255, green: 234/255, blue: 234/255, alpha: 100)
        btnDropDown.layer.cornerRadius = 5
        uiviewChatDescription.addSubview(btnDropDown)
        self.view.addSubview(uiviewChatDescription)
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return 14
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "MemberCell",
                                                      for: indexPath)
        if indexPath.row == 0 {
            cell.layer.cornerRadius = cell.frame.size.width / 2
            cell.backgroundColor = UIColor.yellow
            cell.layer.borderWidth = 2
            let cellbordercolor: UIColor = UIColor(red: 249/255, green: 90/255, blue: 90/255, alpha: 100)
            cell.layer.borderColor = cellbordercolor.cgColor
        }
        else {
            cell.layer.cornerRadius = cell.frame.size.width / 2
            cell.backgroundColor = UIColor.yellow
            cell.layer.borderWidth = 0
        }
        return cell
    }
}
