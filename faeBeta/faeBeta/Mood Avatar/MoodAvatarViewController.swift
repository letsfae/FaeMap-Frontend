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
    
    var tblView: UITableView!
    var intCurtAvatar = -999
    var uiviewHeader: UIView!
    var imgCurtAvatar: UIImageView!
    var lblCurtAvatar: UILabel!
    var btnSave: UIButton!
    
    let titles = ["Happy", "Sad", "LOL!", "Bored", "ARGHH", "So Fabulous", "Looking for Love", "Dreaming", "Hit Me Up!", "Shy", "The Feels", "Shh..Meditating", "Not Right Now", "Me Want Food", "Selling", "Doing Faevors", "Tourist", "Much Wow"]
    
    var shadowGray = UIColor._200199204()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = UIColor.white
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
        uiviewNavBar.layer.borderColor = UIColor._200199204().cgColor
        uiviewNavBar.layer.borderWidth = 1
        uiviewNavBar.backgroundColor = UIColor.white
        view.addSubview(uiviewNavBar)
        
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
        buttonCancel.addTarget(self, action: #selector(actionCancel(_:)), for: .touchUpInside)
        
        btnSave = UIButton()
        btnSave.setImage(UIImage(named: "saveEditCommentPin"), for: UIControlState())
        uiviewNavBar.addSubview(btnSave)
        uiviewNavBar.addConstraintsWithFormat("H:[v0(38)]-15-|", options: [], views: btnSave)
        uiviewNavBar.addConstraintsWithFormat("V:|-28-[v0(25)]", options: [], views: btnSave)
        btnSave.addTarget(self, action: #selector(actionSave(_:)), for: .touchUpInside)
        btnSave.isEnabled = false
    }
    
    private func loadTableView() {
        tblView = UITableView(frame: CGRect(x: 0, y: 206, width: screenWidth, height: screenHeight-206))
        tblView.delegate = self
        tblView.dataSource = self
        tblView.allowsSelection = false
        tblView.register(MoodAvatarTableViewCell.self, forCellReuseIdentifier: "moodAvatarCell")
        view.addSubview(tblView)
    }
    
    private func loadAvatarHeader() {
        uiviewHeader = UIView(frame: CGRect(x: 0, y: 65, width: screenWidth, height: 141))
        view.addSubview(uiviewHeader)
        
        lblCurtAvatar = UILabel()
        lblCurtAvatar.font = UIFont(name: "AvenirNext-Medium", size: 18)
        lblCurtAvatar.textColor = UIColor._898989()
        lblCurtAvatar.textAlignment = .center
        lblCurtAvatar.text = "Current Map Avatar:"
        uiviewHeader.addSubview(lblCurtAvatar)
        uiviewHeader.addConstraintsWithFormat("H:[v0(186)]", options: [], views: lblCurtAvatar)
        uiviewHeader.addConstraintsWithFormat("V:|-18-[v0(25)]", options: [], views: lblCurtAvatar)
        NSLayoutConstraint(item: lblCurtAvatar, attribute: .centerX, relatedBy: .equal, toItem: uiviewHeader, attribute: .centerX, multiplier: 1.0, constant: 0).isActive = true
        
        imgCurtAvatar = UIImageView()
        imgCurtAvatar.image = UIImage(named: "miniAvatar_\(userMiniAvatar)")
        uiviewHeader.addSubview(imgCurtAvatar)
        uiviewHeader.addConstraintsWithFormat("H:[v0(74)]", options: [], views: imgCurtAvatar)
        uiviewHeader.addConstraintsWithFormat("V:[v0(74)]-25-|", options: [], views: imgCurtAvatar)
        NSLayoutConstraint(item: imgCurtAvatar, attribute: .centerX, relatedBy: .equal, toItem: uiviewHeader, attribute: .centerX, multiplier: 1.0, constant: 0).isActive = true
        
        // Gray Block
        let uiviewGrayBlock = UIView(frame: CGRect(x: 0, y: 123, width: screenWidth, height: 12))
        uiviewGrayBlock.backgroundColor = UIColor._248248248()
        uiviewHeader.addSubview(uiviewGrayBlock)
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
        if intCurtAvatar == cell.buttonLeft.tag {
            cell.maleRedBtn.image = UIImage(named: "selectedMoodButton")
        }
        else {
            cell.maleRedBtn.image = UIImage(named: "unselectedMoodButton")
        }
        if intCurtAvatar == cell.buttonRight.tag {
            cell.femaleRedBtn.image = UIImage(named: "selectedMoodButton")
        }
        else {
            cell.femaleRedBtn.image = UIImage(named: "unselectedMoodButton")
        }
        return cell
    }
    
    func actionCancel(_ sender: UIButton) {
        navigationController?.popViewController(animated: true)
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
        btnSave.isEnabled = true
        userMiniAvatar = sender.tag
        intCurtAvatar = sender.tag
        tblView.reloadData()
        imgCurtAvatar.image = UIImage(named: "miniAvatar_\(sender.tag)")
    }
}
