//
//  MoodAvatarViewController.swift
//  faeBeta
//
//  Created by Mingjie Jin on 7/14/16.
//  Remodeled by Yue Shen on 10/23/16.
//  Copyright © 2016 fae. All rights reserved.
//

import UIKit

class MoodAvatarViewController: UIViewController, UITableViewDelegate, UITableViewDataSource, MoodAvatarCellDelegate {
    
    var tblView: UITableView!
    var intCurtAvatar = -999
    var uiviewHeader: UIView!
    var imgCurtAvatar: UIImageView!
    var lblCurtAvatar: UILabel!
    var btnSave: UIButton!
    
    let titles = ["Happy", "LOL!", "Dreaming", "ARGHH >:(", "Touched", "So Fabulous",  "Lots of Love <3", "Bored", "Hit Me Up!", "Super Shy", "Emotionnal", "Shh..Meditating", "Don't Disturb", "Delicious", "Curious", "Scout", "Tourist", "Doge"]
    
    var shadowGray = UIColor._200199204()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = UIColor.white
        if LocalStorageManager.shared.readByKey("userMiniAvatar") != nil {
            userMiniAvatar = LocalStorageManager.shared.readByKey("userMiniAvatar") as! Int
        }
        intCurtAvatar = userMiniAvatar
        navigationBarSetting()
        loadAvatarHeader()
        loadTableView()
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        NotificationCenter.default.post(name: Notification.Name(rawValue: "appWillEnterForeground"), object: nil)
    }
    
    private func navigationBarSetting() {
        let uiviewNavBar = FaeNavBar()
        uiviewNavBar.loadBtnConstraints()
        uiviewNavBar.rightBtn.isHidden = true
        uiviewNavBar.lblTitle.text = "Mood Avatars"
        view.addSubview(uiviewNavBar)
        
        uiviewNavBar.leftBtn.addTarget(self, action: #selector(actionCancel(_:)), for: .touchUpInside)
        
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
        cell.delegate = self
        cell.lblAvatarDes.text = titles[indexPath.row]
        let indexMale = indexPath.row + 1
        let indexFemale = indexPath.row + 19
        cell.imgMale.image = UIImage(named: "miniAvatar_\(indexMale)")
        cell.imgFemale.image = UIImage(named: "miniAvatar_\(indexFemale)")
        cell.btnLeft.tag = indexMale
        cell.btnRight.tag = indexFemale
        if intCurtAvatar == cell.btnLeft.tag {
            cell.maleRedBtn.image = UIImage(named: "selectedMoodButton")
        }
        else {
            cell.maleRedBtn.image = UIImage(named: "unselectedMoodButton")
        }
        if intCurtAvatar == cell.btnRight.tag {
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
        LocalStorageManager.shared.saveInt("userMiniAvatar", value: userMiniAvatar)
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
    
    func changeAvatar(tag: Int) {
        btnSave.isEnabled = true
        userMiniAvatar = tag
        intCurtAvatar = tag
        tblView.reloadData()
        imgCurtAvatar.image = UIImage(named: "miniAvatar_\(tag)")
    }
}
