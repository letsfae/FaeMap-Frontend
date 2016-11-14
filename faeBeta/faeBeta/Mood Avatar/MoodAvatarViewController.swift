//
//  MoodAvatarViewController.swift
//  faeBeta
//
//  Created by Mingjie Jin on 7/14/16.
//  Remodeled by Yue Shen on 10/23/16.
//  Copyright © 2016 fae. All rights reserved.
//

import UIKit

class MoodAvatarViewController: UIViewController, UITableViewDelegate, UITableViewDataSource {
    
    var tableView: UITableView!
    var currentAvatarIndex = -999
    var headerView: UIView!
    var imageCurrentAvatar: UIImageView!
    var labelCurrentAvatar: UILabel!
    
    let screenWidth = UIScreen.main.bounds.width
    let screenHeight = UIScreen.main.bounds.height
    
    let titles = ["Happy", "Sad", "LOL!", "Bored", "ARGHH", "So Fabulous", "Looking for Love", "Dreaming", "Hit Me Up!", "Shy", "The Feels", "Shh..Meditating", "Not Rigth Now", "Me Want Food", "Selling", "Doing Faevors", "Tourist", "Much Wow"]
    let maleImageName = ["avatar_1", "avatar_2", "avatar_3", "avatar_4", "avatar_5", "avatar_6", "avatar_7", "avatar_8", "avatar_9", "avatar_10", "avatar_11", "avatar_12", "avatar_13", "avatar_14", "avatar_15", "avatar_16", "avatar_17", "avatar_18"]
    let femaleImageName = ["avatar_19", "avatar_20", "avatar_21", "avatar_22", "avatar_23", "avatar_24", "avatar_25", "avatar_26", "avatar_27", "avatar_28", "avatar_29", "avatar_30", "avatar_31", "avatar_32", "avatar_33", "avatar_34", "avatar_35", "avatar_36"]
    
    var faeGray = UIColor(red: 89/255, green: 89/255, blue: 89/255, alpha: 1.0)
    var shadowGray = UIColor(red: 200/255, green: 199/255, blue: 204/255, alpha: 1)
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        tableView = UITableView(frame: CGRect(x: 0, y: 144, width: screenWidth, height: screenHeight-159))
        tableView.delegate = self
        tableView.dataSource = self
        tableView.allowsSelection = false
        tableView.register(MoodAvatarTableViewCell.self, forCellReuseIdentifier: "moodAvatarCell")
        self.view.addSubview(tableView)
        navigationBarSetting()
        loadAvatarHeader()
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(true)
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
    func navigationBarSetting() {
        self.navigationController?.navigationBar.isHidden = false
        self.navigationController?.navigationBar.topItem?.title = ""
        self.title = "Mood Avatar"
        let attributes = [NSFontAttributeName : UIFont(name: "AvenirNext-Medium", size: 20)!, NSForegroundColorAttributeName : faeGray] as [String : Any]
        self.navigationController!.navigationBar.titleTextAttributes = attributes
        self.navigationController?.navigationBar.shadowImage = nil
    }
    
    func loadAvatarHeader() {
//        let height: CGFloat = 144/736 * screenHeight
        headerView = UIView(frame: CGRect(x: 0, y: 0, width: screenWidth, height: 145))
        self.view.addSubview(headerView)
        
        labelCurrentAvatar = UILabel()
        labelCurrentAvatar.font = UIFont(name: "AvenirNext-Medium", size: 18)
        labelCurrentAvatar.textColor = UIColor(red: 89/255, green: 89/255, blue: 89/255, alpha: 1.0)
        labelCurrentAvatar.textAlignment = .center
        labelCurrentAvatar.text = "Current Map Avatar:"
        self.headerView.addSubview(labelCurrentAvatar)
        self.headerView.addConstraintsWithFormat("H:[v0(186)]", options: [], views: labelCurrentAvatar)
        self.headerView.addConstraintsWithFormat("V:|-18-[v0(25)]", options: [], views: labelCurrentAvatar)
        NSLayoutConstraint(item: labelCurrentAvatar, attribute: .centerX, relatedBy: .equal, toItem: self.headerView, attribute: .centerX, multiplier: 1.0, constant: 0).isActive = true
        
        imageCurrentAvatar = UIImageView()
        imageCurrentAvatar.image = UIImage(named: "avatar_1")
        self.headerView.addSubview(imageCurrentAvatar)
        self.headerView.addConstraintsWithFormat("H:[v0(70)]", options: [], views: imageCurrentAvatar)
        self.headerView.addConstraintsWithFormat("V:[v0(70)]-30-|", options: [], views: imageCurrentAvatar)
        NSLayoutConstraint(item: imageCurrentAvatar, attribute: .centerX, relatedBy: .equal, toItem: self.headerView, attribute: .centerX, multiplier: 1.0, constant: 0).isActive = true
        
        // Line at y = 64
        let uiviewCommentPinUnderLine01 = UIView(frame: CGRect(x: 0, y: 122, width: screenWidth, height: 1))
        uiviewCommentPinUnderLine01.layer.borderWidth = 1
        uiviewCommentPinUnderLine01.layer.borderColor = UIColor(red: 197/255, green: 196/255, blue: 201/255, alpha: 1.0).cgColor
        self.headerView.addSubview(uiviewCommentPinUnderLine01)
        
        // Gray Block
        let uiviewCommentPinDetailGrayBlock = UIView(frame: CGRect(x: 0, y: 123, width: screenWidth, height: 20))
        uiviewCommentPinDetailGrayBlock.backgroundColor = UIColor(red: 248/255, green: 248/255, blue: 248/255, alpha: 1.0)
        self.headerView.addSubview(uiviewCommentPinDetailGrayBlock)
        
        // Line at y = 292
        let uiviewCommentPinUnderLine02 = UIView(frame: CGRect(x: 0, y: 143, width: screenWidth, height: 1))
        uiviewCommentPinUnderLine02.layer.borderWidth = 1
        uiviewCommentPinUnderLine02.layer.borderColor = UIColor(red: 197/255, green: 196/255, blue: 201/255, alpha: 1.0).cgColor
        self.headerView.addSubview(uiviewCommentPinUnderLine02)
    }
    
    //table view delegate function
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 60
    }
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 18
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "moodAvatarCell", for: indexPath)as! MoodAvatarTableViewCell
        cell.labelAvatarDes.text = titles[indexPath.row]
        cell.maleImage.image = UIImage(named: maleImageName[indexPath.row])
        cell.femaleImage.image = UIImage(named: femaleImageName[indexPath.row])
        cell.buttonLeft.addTarget(self, action: #selector(MoodAvatarViewController.changeMaleAvatar), for: .touchUpInside)
        cell.buttonLeft.tag = indexPath.row + 1
        cell.buttonRight.addTarget(self, action: #selector(MoodAvatarViewController.changeFemaleAvatar), for: .touchUpInside)
        cell.buttonRight.tag = indexPath.row + 19
        if currentAvatarIndex == cell.buttonLeft.tag {
            cell.maleRedBtn.image = UIImage(named: "selectedMoodButton")
        }
        else {
            cell.maleRedBtn.image = UIImage(named: "unselectedMoodButton")
        }
        if currentAvatarIndex == cell.buttonRight.tag {
            cell.femaleRedBtn.image = UIImage(named: "selectedMoodButton")
        }
        else {
            cell.femaleRedBtn.image = UIImage(named: "unselectedMoodButton")
        }
        cell.separatorInset = UIEdgeInsets.zero
        cell.layoutMargins = UIEdgeInsets.zero
        return cell
    }
    
    func changeMaleAvatar(_ sender: UIButton) {
        // Unsafe
        userAvatarMap = "avatar_\(sender.tag)"
        userMiniAvatar = sender.tag
        currentAvatarIndex = sender.tag
        tableView.reloadData()
        imageCurrentAvatar.image = UIImage(named: "avatar_\(sender.tag)")
        let updateMiniAvatar = FaeUser()
        if let miniAvatar = userMiniAvatar {
            print(miniAvatar)
            updateMiniAvatar.whereKey("mini_avatar", value: "\(miniAvatar-1)")
            updateMiniAvatar.updateAccountBasicInfo({(status: Int, message: Any?) in
                if status / 100 == 2 {
                    print("Successfully update miniavatar")
                }
                else {
                    print("Fail to update miniavatar")
                }
            })
        }
    }
    
    func changeFemaleAvatar(_ sender: UIButton) {
        // Unsafe
        userAvatarMap = "avatar_\(sender.tag)"
        userMiniAvatar = sender.tag
        currentAvatarIndex = sender.tag
        tableView.reloadData()
        imageCurrentAvatar.image = UIImage(named: "avatar_\(sender.tag)")
        let updateMiniAvatar = FaeUser()
        if let miniAvatar = userMiniAvatar {
            print(miniAvatar)
            updateMiniAvatar.whereKey("mini_avatar", value: "\(miniAvatar-1)")
            updateMiniAvatar.updateAccountBasicInfo({(status: Int, message: Any?) in
                if status / 100 == 2 {
                    print("Successfully update miniavatar")
                }
                else {
                    print("Fail to update miniavatar")
                }
            })
        }
    }
}
