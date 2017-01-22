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
    
    let titles = ["Happy", "Sad", "LOL!", "Bored", "ARGHH", "So Fabulous", "Looking for Love", "Dreaming", "Hit Me Up!", "Shy", "The Feels", "Shh..Meditating", "Not Rigth Now", "Me Want Food", "Selling", "Doing Faevors", "Tourist", "Much Wow"]
    
    var shadowGray = UIColor(red: 200/255, green: 199/255, blue: 204/255, alpha: 1)
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.view.backgroundColor = UIColor.white
        navigationBarSetting()
        loadAvatarHeader()
        loadTableView()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        UIView.animate(withDuration: 0.5, animations: { 
            
        }, completion: nil)
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(true)
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
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
        lblTitle.textColor = UIColor.faeAppInputTextGrayColor()
        self.view.addSubview(lblTitle)
    }
    
    private func loadTableView() {
        tableView = UITableView(frame: CGRect(x: 0, y: 209, width: screenWidth, height: screenHeight-209))
        tableView.delegate = self
        tableView.dataSource = self
        tableView.allowsSelection = false
        tableView.register(MoodAvatarTableViewCell.self, forCellReuseIdentifier: "moodAvatarCell")
        self.view.addSubview(tableView)
    }
    
    private func loadAvatarHeader() {
        headerView = UIView(frame: CGRect(x: 0, y: 65, width: screenWidth, height: 145))
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
        imageCurrentAvatar.image = UIImage(named: "miniAvatar_1")
        self.headerView.addSubview(imageCurrentAvatar)
        self.headerView.addConstraintsWithFormat("H:[v0(74)]", options: [], views: imageCurrentAvatar)
        self.headerView.addConstraintsWithFormat("V:[v0(74)]-25-|", options: [], views: imageCurrentAvatar)
        NSLayoutConstraint(item: imageCurrentAvatar, attribute: .centerX, relatedBy: .equal, toItem: self.headerView, attribute: .centerX, multiplier: 1.0, constant: 0).isActive = true
        
        let uiviewLine01 = UIView(frame: CGRect(x: 0, y: 122, width: screenWidth, height: 1))
        uiviewLine01.layer.borderWidth = 1
        uiviewLine01.layer.borderColor = UIColor(red: 197/255, green: 196/255, blue: 201/255, alpha: 1.0).cgColor
        self.headerView.addSubview(uiviewLine01)
        
        // Gray Block
        let uiviewGrayBlock = UIView(frame: CGRect(x: 0, y: 123, width: screenWidth, height: 20))
        uiviewGrayBlock.backgroundColor = UIColor(red: 248/255, green: 248/255, blue: 248/255, alpha: 1.0)
        self.headerView.addSubview(uiviewGrayBlock)
        
        let uiviewLine02 = UIView(frame: CGRect(x: 0, y: 143, width: screenWidth, height: 1))
        uiviewLine02.layer.borderWidth = 1
        uiviewLine02.layer.borderColor = UIColor(red: 197/255, green: 196/255, blue: 201/255, alpha: 1.0).cgColor
        self.headerView.addSubview(uiviewLine02)
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
        let indexMale = indexPath.row + 1
        let indexFemale = indexPath.row + 19
        cell.maleImage.image = UIImage(named: "miniAvatar_\(indexMale)")
        cell.femaleImage.image = UIImage(named: "miniAvatar_\(indexFemale)")
        cell.buttonLeft.addTarget(self, action: #selector(MoodAvatarViewController.changeMaleAvatar), for: .touchUpInside)
        cell.buttonLeft.tag = indexMale
        cell.buttonRight.addTarget(self, action: #selector(MoodAvatarViewController.changeFemaleAvatar), for: .touchUpInside)
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
        cell.separatorInset = UIEdgeInsets.zero
        cell.layoutMargins = UIEdgeInsets.zero
        return cell
    }
    
    func changeMaleAvatar(_ sender: UIButton) {
        // Unsafe
        
        userAvatarMap = "miniAvatar_\(sender.tag)"
        userMiniAvatar = sender.tag
        currentAvatarIndex = sender.tag
        tableView.reloadData()
        imageCurrentAvatar.image = UIImage(named: "miniAvatar_\(sender.tag)")
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
        userAvatarMap = "miniAvatar_\(sender.tag)"
        userMiniAvatar = sender.tag
        currentAvatarIndex = sender.tag
        tableView.reloadData()
        imageCurrentAvatar.image = UIImage(named: "miniAvatar_\(sender.tag)")
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
