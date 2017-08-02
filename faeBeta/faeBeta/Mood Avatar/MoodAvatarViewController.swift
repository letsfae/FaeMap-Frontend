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
    var uiviewHeader: UIView!
    var imageCurrentAvatar: UIImageView!
    var labelCurrentAvatar: UILabel!
    var buttonSave: UIButton!
    
    let titles = ["Happy", "Sad", "LOL!", "Bored", "ARGHH", "So Fabulous", "Looking for Love", "Dreaming", "Hit Me Up!", "Shy", "The Feels", "Shh..Meditating", "Not Right Now", "Me Want Food", "Selling", "Doing Faevors", "Tourist", "Much Wow"]
    
    var shadowGray = UIColor(red: 200/255, green: 199/255, blue: 204/255, alpha: 1)
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.view.backgroundColor = UIColor.white
        navigationBarSetting()
        loadAvatarHeader()
        loadTableView()
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        NotificationCenter.default.post(name: Notification.Name(rawValue: "appWillEnterForeground"), object: nil)
    }
    
    private func navigationBarSetting() {
        let uiviewNavBar = UIView(frame: CGRect(x: -1, y: -1, width: screenWidth+2, height: 66))
        uiviewNavBar.layer.borderColor = UIColor(red: 200/255, green: 199/255, blue: 204/255, alpha: 1).cgColor
        uiviewNavBar.layer.borderWidth = 1
        uiviewNavBar.backgroundColor = UIColor.white
        self.view.addSubview(uiviewNavBar)
        
        let lblTitle = UILabel(frame: CGRect(x: 0, y: 28, width: 130, height: 27))
        lblTitle.center.x = screenWidth / 2
        lblTitle.text = "Mood Avatar"
        lblTitle.textAlignment = .center
        lblTitle.font = UIFont(name: "AvenirNext-Medium", size: 20)
        lblTitle.textColor = UIColor._898989()
        uiviewNavBar.addSubview(lblTitle)
        
        let buttonCancel = UIButton()
        buttonCancel.setImage(UIImage(named: "cancelEditCommentPin"), for: UIControlState())
        uiviewNavBar.addSubview(buttonCancel)
        uiviewNavBar.addConstraintsWithFormat("H:|-15-[v0(54)]", options: [], views: buttonCancel)
        uiviewNavBar.addConstraintsWithFormat("V:|-28-[v0(25)]", options: [], views: buttonCancel)
        buttonCancel.addTarget(self, action: #selector(self.actionCancel(_:)), for: .touchUpInside)
        
        buttonSave = UIButton()
        buttonSave.setImage(UIImage(named: "saveEditCommentPin"), for: UIControlState())
        uiviewNavBar.addSubview(buttonSave)
        uiviewNavBar.addConstraintsWithFormat("H:[v0(38)]-15-|", options: [], views: buttonSave)
        uiviewNavBar.addConstraintsWithFormat("V:|-28-[v0(25)]", options: [], views: buttonSave)
        buttonSave.addTarget(self, action: #selector(self.actionSave(_:)), for: .touchUpInside)
        buttonSave.isEnabled = false
    }
    
    private func loadTableView() {
        tableView = UITableView(frame: CGRect(x: 0, y: 206, width: screenWidth, height: screenHeight-206))
        tableView.delegate = self
        tableView.dataSource = self
        tableView.allowsSelection = false
        tableView.register(MoodAvatarTableViewCell.self, forCellReuseIdentifier: "moodAvatarCell")
        self.view.addSubview(tableView)
    }
    
    private func loadAvatarHeader() {
        uiviewHeader = UIView(frame: CGRect(x: 0, y: 65, width: screenWidth, height: 141))
        self.view.addSubview(uiviewHeader)
        
        labelCurrentAvatar = UILabel()
        labelCurrentAvatar.font = UIFont(name: "AvenirNext-Medium", size: 18)
        labelCurrentAvatar.textColor = UIColor(red: 89/255, green: 89/255, blue: 89/255, alpha: 1.0)
        labelCurrentAvatar.textAlignment = .center
        labelCurrentAvatar.text = "Current Map Avatar:"
        self.uiviewHeader.addSubview(labelCurrentAvatar)
        self.uiviewHeader.addConstraintsWithFormat("H:[v0(186)]", options: [], views: labelCurrentAvatar)
        self.uiviewHeader.addConstraintsWithFormat("V:|-18-[v0(25)]", options: [], views: labelCurrentAvatar)
        NSLayoutConstraint(item: labelCurrentAvatar, attribute: .centerX, relatedBy: .equal, toItem: self.uiviewHeader, attribute: .centerX, multiplier: 1.0, constant: 0).isActive = true
        
        imageCurrentAvatar = UIImageView()
        imageCurrentAvatar.image = UIImage(named: "miniAvatar_\(userMiniAvatar+1)")
        self.uiviewHeader.addSubview(imageCurrentAvatar)
        self.uiviewHeader.addConstraintsWithFormat("H:[v0(74)]", options: [], views: imageCurrentAvatar)
        self.uiviewHeader.addConstraintsWithFormat("V:[v0(74)]-25-|", options: [], views: imageCurrentAvatar)
        NSLayoutConstraint(item: imageCurrentAvatar, attribute: .centerX, relatedBy: .equal, toItem: self.uiviewHeader, attribute: .centerX, multiplier: 1.0, constant: 0).isActive = true
        
        // Gray Block
        let uiviewGrayBlock = UIView(frame: CGRect(x: 0, y: 123, width: screenWidth, height: 12))
        uiviewGrayBlock.backgroundColor = UIColor(red: 248/255, green: 248/255, blue: 248/255, alpha: 1.0)
        self.uiviewHeader.addSubview(uiviewGrayBlock)
    }
    
    //table view delegate function
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 65
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
        let indexMale = indexPath.row + 1
        let indexFemale = indexPath.row + 19
        cell.maleImage.image = UIImage(named: "miniAvatar_\(indexMale)")
        cell.femaleImage.image = UIImage(named: "miniAvatar_\(indexFemale)")
        cell.buttonLeft.addTarget(self, action: #selector(MoodAvatarViewController.changeAvatar), for: .touchUpInside)
        cell.buttonLeft.tag = indexMale
        cell.buttonRight.addTarget(self, action: #selector(MoodAvatarViewController.changeAvatar), for: .touchUpInside)
        cell.buttonRight.tag = indexFemale
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
        return cell
    }
    
    func actionCancel(_ sender: UIButton) {
        self.navigationController?.popViewController(animated: true)
    }
    
    func actionSave(_ sender: UIButton) {
        let updateMiniAvatar = FaeUser()
        userAvatarMap = "miniAvatar_\(userMiniAvatar)"
        updateMiniAvatar.whereKey("mini_avatar", value: "\(userMiniAvatar-1)")
        updateMiniAvatar.updateAccountBasicInfo({(status: Int, message: Any?) in
            if status / 100 == 2 {
                print("Successfully update miniavatar")
                self.navigationController?.popViewController(animated: true)
                NotificationCenter.default.post(name: NSNotification.Name(rawValue: "changeCurrentMoodAvatar"), object: nil)
            }
            else {
                print("Fail to update miniavatar")
            }
        })
    }
    
    func changeAvatar(_ sender: UIButton) {
        buttonSave.isEnabled = true
        userMiniAvatar = sender.tag
        currentAvatarIndex = sender.tag
        tableView.reloadData()
        imageCurrentAvatar.image = UIImage(named: "miniAvatar_\(sender.tag)")
    }
}
