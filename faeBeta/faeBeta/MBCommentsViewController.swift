//
//  MBCommentsViewController.swift
//  FaeMapBoard
//
//  Created by vicky on 4/11/17.
//  Copyright © 2017 Yue. All rights reserved.
//

import UIKit
import GoogleMaps

class MBCommentsViewController: UIViewController, UITableViewDataSource, UITableViewDelegate {
    var tableComments: UITableView!
    var mbComments = [MBSocialStruct]()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        loadNavBar()
        loadTable()
    }
    
    fileprivate func loadNavBar() {
        let uiviewNavBar = UIView(frame: CGRect(x: 0, y: 0, width: screenWidth, height: 65))
        uiviewNavBar.backgroundColor = .white
        self.view.addSubview(uiviewNavBar)
        
        let uiviewLine = UIView(frame: CGRect(x: 0, y: 64, width: screenWidth, height: 1))
        uiviewLine.backgroundColor = UIColor.faeAppNavBarBorderColor()
        uiviewNavBar.addSubview(uiviewLine)
        
        let lblTitle = UILabel(frame: CGRect(x: (screenWidth - 101) / 2, y: 28, width: 101, height: 27))
        lblTitle.text = "Comments"
        lblTitle.textColor = UIColor.faeAppInputTextGrayColor()
        lblTitle.font = UIFont(name: "AvenirNext-Medium", size: 20)
        lblTitle.textAlignment = NSTextAlignment.center
        uiviewNavBar.addSubview(lblTitle)
        
        let btnBackNavBar = UIButton(frame: CGRect(x: 0, y: 20, width: 40.5, height: 42))
        btnBackNavBar.setImage(#imageLiteral(resourceName: "mainScreenSearchToFaeMap"), for: .normal)
        btnBackNavBar.addTarget(self, action: #selector(self.backToMapBoard(_:)), for: .touchUpInside)
        uiviewNavBar.addSubview(btnBackNavBar)
        
    }
    
    fileprivate func loadTable() {
        tableComments = UITableView(frame: CGRect(x: 0, y: 65, width: screenWidth, height: screenHeight - 65))
        tableComments.backgroundColor = .white
        tableComments.register(MBCommentsCell.self, forCellReuseIdentifier: "mbCommentsCell")
        tableComments.delegate = self
        tableComments.dataSource = self
        tableComments.separatorStyle = .none
        tableComments.rowHeight = UITableViewAutomaticDimension
        tableComments.estimatedRowHeight = 200
//        tableComments.allowsSelection = false
        
        self.view.addSubview(tableComments)
    }

    func backToMapBoard(_ sender: UIButton) {
//        self.dismiss(animated: false, completion: nil)
        self.navigationController?.popViewController(animated: true)
    }
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }

//    let imgAvatarArr: Array = ["default_Avatar", "default_Avatar", "default_Avatar"]
//    let lblUsrNameTxt: Array = ["Holly Laura", "Anonymous", "Peach"]
//    let lblTimeTxt: Array = ["Just Now", "Yesterday", "December 29, 2016"]
//    let lblContTxt: Array = ["There's a party going on later near campus, anyone wanna go with me? Looking for around 3 more people!", "There's a party going on later near campus, anyone wanna go with me? Looking for around 3 more people! COMECOMECOME", "Wuts up?"]
//    let lblComLocTxt: Array = ["Los Angeles CA, 2714 S. Hoover St.", "Los Angeles CA, 2714 S. Hooooooooooooooooooover St.", "Los Angeles CA, 2714 S. Hoover St."]
//    let lblFavCountTxt: Array = [8, 7, 5]
//    let lblReplyCountTxt: Array = [12, 5, 4]
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.mbComments.count
    }
    
    // Yue 06/11/17
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "mbCommentsCell", for: indexPath) as! MBCommentsCell
        
        let comment = self.mbComments[indexPath.row]
        cell.lblTime.text = comment.date
        cell.lblContent.attributedText = comment.attributedText
        if comment.anonymous || comment.displayName == "" {
            cell.lblUsrName.text = "Someone"
            cell.imgAvatar.image = #imageLiteral(resourceName: "default_Avatar")
        } else {
            cell.lblUsrName.text = comment.displayName
            cell.setValueForCell(userId: comment.userId)
        }
        
        cell.setAddressForCell(position: comment.position, id: comment.pinId, type: comment.type)
        
        cell.imgHotPin.isHidden = comment.status != "hot"
 
        cell.lblComLoc.text = comment.address
        cell.lblFavCount.text = String(comment.likeCount)
        cell.lblReplyCount.text = String(comment.commentCount)
        
        return cell
    }
    // Yue 06/11/17 End
}
