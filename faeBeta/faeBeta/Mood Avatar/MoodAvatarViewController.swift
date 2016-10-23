//
//  MoodAvatarViewController.swift
//  faeBeta
//
//  Created by User on 7/14/16.
//  Copyright © 2016 fae. All rights reserved.
//

import UIKit

class MoodAvatarViewController: UIViewController, UITableViewDelegate, UITableViewDataSource, MoodAvatarDelegate{
    
    var tableView : UITableView!
    var headerReuseIdentifier = "MoodAvatarHeaderTableViewCell"
    var reuseIdentifier = "MoodAvatarTableViewCell"
    
    let screenWidth = UIScreen.mainScreen().bounds.width
    let screenHeight = UIScreen.mainScreen().bounds.height
    
    let titles = ["Happy", "Sad", "LOL!", "Bored", "ARGHH", "So Fabulous", "Looking for Love", "Dreaming", "Hit Me Up!", "Shy", "The Feels", "Shh..Meditating", "Not Rigth Now", "Me Want Food", "Selling", "Doing Faevors", "Tourist", "Much Wow"]
    let maleImageName = ["avatar_1", "avatar_2", "avatar_3", "avatar_4", "avatar_5", "avatar_6", "avatar_7", "avatar_8", "avatar_9", "avatar_10", "avatar_11", "avatar_12", "avatar_13", "avatar_14", "avatar_15", "avatar_16", "avatar_17", "avatar_18"]
    let femaleImageName = ["avatar_19", "avatar_20", "avatar_21", "avatar_22", "avatar_23", "avatar_24", "avatar_25", "avatar_26", "avatar_27", "avatar_28", "avatar_29", "avatar_30", "avatar_31", "avatar_32", "avatar_33", "avatar_34", "avatar_35", "avatar_36"]
    
    var faeGray = UIColor(red: 89 / 255, green: 89 / 255, blue: 89 / 255, alpha: 1.0)
    
    var shadowGray = UIColor(red: 200 / 255, green: 199 / 255, blue: 204 / 255, alpha: 1)
    
    var currentAvatarIndex = 0
    
    var numberOfMood = 18
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        tableView = UITableView(frame: CGRect(x: 0, y: 0, width: screenWidth, height: screenHeight))
        tableView.registerNib(UINib(nibName: "MoodAvatarHeaderTableViewCell", bundle: nil), forCellReuseIdentifier: headerReuseIdentifier)
        tableView.registerNib(UINib(nibName: "MoodAvatarTableViewCell", bundle: nil), forCellReuseIdentifier: reuseIdentifier)
        tableView.delegate = self
        tableView.dataSource = self
        tableView.separatorStyle = .None
        tableView.allowsSelection = false
        self.view.addSubview(tableView)
        navigationBarSetting()
    }
    
    // TODO : set avatar to backend
    override func viewWillDisappear(animated: Bool) {
        super.viewWillDisappear(true)
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func navigationBarSetting() {
        self.navigationController?.navigationBar.hidden = false
        self.navigationController?.navigationBar.topItem?.title = ""
        self.title = "Mood Avatar"
        let attributes = [NSFontAttributeName : UIFont(name: "Avenir Next", size: 20)!, NSForegroundColorAttributeName : faeGray]
        self.navigationController!.navigationBar.titleTextAttributes = attributes
        self.navigationController?.navigationBar.shadowImage = nil
    }
    
    
    //table view delegate function
    
    func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return 2
    }
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if section == 0 {
            return 1
        } else {
            return 18
        }
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        if indexPath.section == 0 {
            let cell = tableView.dequeueReusableCellWithIdentifier(headerReuseIdentifier) as! MoodAvatarHeaderTableViewCell
            if currentAvatarIndex >= numberOfMood {
                cell.currentAvatarImage.image = UIImage(named: femaleImageName[currentAvatarIndex - numberOfMood])
                userAvatarMap = femaleImageName[currentAvatarIndex - numberOfMood]
            } else {
                cell.currentAvatarImage.image = UIImage(named: maleImageName[currentAvatarIndex])
                userAvatarMap = maleImageName[currentAvatarIndex]
            }
            print("avatar change")
            // Unsafe
            let twoPartMiniAvatar = userAvatarMap.componentsSeparatedByString("_")
            userMiniAvatar = Int(twoPartMiniAvatar[1])
            let updateMiniAvatar = FaeUser()
            if let miniAvatar = userMiniAvatar {
                updateMiniAvatar.whereKey("mini_avatar", value: "\(miniAvatar)")
            }
            updateMiniAvatar.updateAccountBasicInfo({(status: Int, message: AnyObject?) in
                if status / 100 == 2 {
                    print("Successfully update miniavatar")
                }
                else {
                    print("Fail to update miniavatar")
                }
            })
            return cell
        } else {
            let cell = tableView.dequeueReusableCellWithIdentifier(reuseIdentifier) as! MoodAvatarTableViewCell
            cell.moodLabel.text = titles[indexPath.row]
            cell.maleImage.image = UIImage(named: maleImageName[indexPath.row])
            cell.femaleImage.image = UIImage(named: femaleImageName[indexPath.row])
            cell.maleIndex = indexPath.row
            cell.femaleIndex = indexPath.row + numberOfMood
            cell.moodDelegate = self
            if currentAvatarIndex % numberOfMood == indexPath.row {
                if currentAvatarIndex < numberOfMood {
                    cell.maleIdicateImage.image = UIImage(named: "selectedMoodButton")
                    cell.femaleIdicateImage.image = UIImage(named: "unselectedMoodButton")
                } else {
                    cell.femaleIdicateImage.image = UIImage(named : "selectedMoodButton")
                    cell.maleIdicateImage.image = UIImage(named: "unselectedMoodButton")
                }
            } else {
                cell.maleIdicateImage.image = UIImage(named: "unselectedMoodButton")
                cell.femaleIdicateImage.image = UIImage(named: "unselectedMoodButton")
            }
            return cell
        }
    }
    
    func tableView(tableView: UITableView, heightForRowAtIndexPath indexPath: NSIndexPath) -> CGFloat {
        if indexPath.section == 0 {
            return 122
        } else {
            return 60
        }
    }
    
    func tableView(tableView: UITableView, heightForFooterInSection section: Int) -> CGFloat {
        if section == 0 {
            return 22
        } else {
            return 0
        }
    }
    
    func changeCurrentAvatar(index: Int) {
        currentAvatarIndex = index
        tableView.reloadData()
    }
    
    //    func tableView(tableView: UITableView, viewForFooterInSection section: Int) -> UIView? {
    //        let view = UIView(frame: CGRect(x: 0, y: 0, width: screenWidth, height: 1))
    //        view.backgroundColor = UIColor(red: 200 / 255, green: 199 / 255, blue: 204 / 255, alpha: 1.0)
    //        return view
    //    }
    
    /*
     // MARK: - Navigation
     
     // In a storyboard-based application, you will often want to do a little preparation before navigation
     override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
     // Get the new view controller using segue.destinationViewController.
     // Pass the selected object to the new view controller.
     }
     */
    
}
