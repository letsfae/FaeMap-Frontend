//
//  LeftSlidingMenuViewController.swift
//  faeBeta
//
//  Created by Jacky on 12/19/16.
//  Copyright © 2016 fae. All rights reserved.
//

import UIKit
import RealmSwift

class LeftSlidingMenuViewController: UIViewController, UITableViewDataSource, UITableViewDelegate {
    
    var uiViewLeftWindow: UIView!
    var buttonBackground: UIButton!
    var imageLeftSlideWindowUp: UIImageView!
    var imageLeftSlideWindowMiddle: UIImageView!
    var imageAvatar: UIImageView!
    var label: UILabel!
    var tableLeftSlideWindow: UITableView!
    var backgroundColorViewTop: UIView!
    var backgroundColorViewDown: UIView!
    
    // For pan gesture var
    var sizeFrom: CGFloat = 0
    var sizeTo: CGFloat = 0
    var space: CGFloat = 0
    var end: CGFloat = 0
    var percent: Double = 0
    // End of pan gesture var
    
    override func viewDidLoad() {
        super.viewDidLoad()
        loadLeftWindow()
        let leftSwipe = UISwipeGestureRecognizer()
        leftSwipe.direction = .left
        leftSwipe.addTarget(self, action: #selector(self.actionSwipeGesture(_:)))
        self.tableLeftSlideWindow.addGestureRecognizer(leftSwipe)
        self.buttonBackground.addGestureRecognizer(leftSwipe)
        let draggingGesture = UIPanGestureRecognizer(target: self, action: #selector(self.panActionCommentPinDetailDrag(_:)))
        self.view.addGestureRecognizer(draggingGesture)
        let realm = try! Realm()
        let selfInfoRealm = realm.objects(SelfInformation.self).filter("currentUserID == \(user_id.stringValue) AND avatar != nil")
        if selfInfoRealm.count >= 1 {
            if let selfAvatar = selfInfoRealm.first {
                let picture = UIImage.sd_image(with: selfAvatar.avatar as Data!)
                imageAvatar.image = picture
            }
        }
        else {
            if user_id != nil {
                let stringHeaderURL = "\(baseURL)/files/users/\(user_id.stringValue)/avatar"
                imageAvatar.sd_setImage(with: URL(string: stringHeaderURL), placeholderImage: Key.sharedInstance.imageDefaultMale, options: [.retryFailed, .refreshCached], completed: { (image, error, SDImageCacheType, imageURL) in
                    if image != nil {
                        let selfInfoRealm = SelfInformation()
                        selfInfoRealm.currentUserID = Int(user_id)
                        selfInfoRealm.avatar = UIImageJPEGRepresentation(image!, 1.0) as NSData?
                        try! realm.write {
                            realm.add(selfInfoRealm)
                        }
                    }
                })
            }
        }
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        UIView.animate(withDuration: 0.5, animations: {
            self.buttonBackground.alpha = 1
            self.tableLeftSlideWindow.center.x += 290
            self.backgroundColorViewTop.center.x += 290
            self.backgroundColorViewDown.center.x += 290
        }, completion: nil)
    }
    
    func panActionCommentPinDetailDrag(_ pan: UIPanGestureRecognizer) {
        var resumeTime: Double = 0.5
        if pan.state == .began {
            let location = pan.location(in: view)
            space = location.x - 290
            end = location.x
            if tableLeftSlideWindow.frame.origin.x == 0 {
                sizeFrom = 0
                sizeTo = -290
            }
        } else if pan.state == .ended || pan.state == .failed || pan.state == .cancelled {
            let velocity = pan.velocity(in: view)
            resumeTime = abs(Double(CGFloat(screenHeight - 256) / velocity.y))
            if resumeTime >= 0.5 {
                resumeTime = 0.5
            }
            if percent > 0.5 {
                UIView.animate(withDuration: resumeTime, animations: {
                    self.tableLeftSlideWindow.frame.origin.x = self.sizeTo
                    self.backgroundColorViewTop.frame.origin.x = self.sizeTo
                    self.backgroundColorViewDown.frame.origin.x = self.sizeTo
                    self.buttonBackground.alpha = 0
                }, completion: {(done: Bool) in
                    self.dismiss(animated: false, completion: nil)
                })
            }
            else {
                UIView.animate(withDuration: resumeTime, animations: {
                    self.tableLeftSlideWindow.frame.origin.x = self.sizeFrom
                    self.backgroundColorViewTop.frame.origin.x = self.sizeFrom
                    self.backgroundColorViewDown.frame.origin.x = self.sizeFrom
                    self.buttonBackground.alpha = 1
                })
            }
        } else {
            let location = pan.location(in: view)
            if location.x <= end {
                self.tableLeftSlideWindow.frame.origin.x = location.x - (290 + space)
                self.backgroundColorViewTop.frame.origin.x = location.x - (290 + space)
                self.backgroundColorViewDown.frame.origin.x = location.x - (290 + space)
                self.buttonBackground.alpha = (location.x - space) / 290
                percent = Double((end - location.x) / 290)
            }
            
        }
    }
    
    func actionCloseMenu(_ sender: UIButton) {
        UIView.animate(withDuration: 0.5, animations: {
            self.buttonBackground.alpha = 0
            self.tableLeftSlideWindow.center.x -= 290
            self.backgroundColorViewTop.center.x -= 290
            self.backgroundColorViewDown.center.x -= 290
        }) { (done: Bool) in
            self.dismiss(animated: false, completion: nil)
        }
    }
    
    func actionSwipeGesture(_ sender: UIGestureRecognizer) {
        actionCloseMenu(buttonBackground)
    }
    
    func loadLeftWindow () {
        buttonBackground = UIButton(frame: CGRect(x: 0, y: 0, width: screenWidth, height: screenHeight))
        buttonBackground.backgroundColor = UIColor(red: 107/255, green: 105/255, blue: 105/255, alpha: 0.7)
        buttonBackground.addTarget(self, action: #selector(self.actionCloseMenu(_:)), for: .touchUpInside)
        self.view.addSubview(buttonBackground)
        buttonBackground.alpha = 0
        
        backgroundColorViewTop = UIView(frame: CGRect(x: 0, y: 0, width: 290, height: screenHeight/2))
        backgroundColorViewTop.backgroundColor = UIColor.faeAppRedColor()
        self.view.addSubview(backgroundColorViewTop)
        self.backgroundColorViewTop.center.x -= 290
        
        backgroundColorViewDown = UIView(frame: CGRect(x: 0, y: screenHeight/2, width: 290, height: screenHeight/2))
        backgroundColorViewDown.backgroundColor = UIColor.white
        self.view.addSubview(backgroundColorViewDown)
        self.backgroundColorViewDown.center.x -= 290
        
        
        uiViewLeftWindow = UIView(frame: CGRect(x: 0, y: 0, width: 290, height: 241.5))
        uiViewLeftWindow.backgroundColor = UIColor.white
        
        imageLeftSlideWindowUp = UIImageView(frame: CGRect(x: 0, y: 0, width: 290, height: 238))
        imageLeftSlideWindowUp.image = UIImage(named: "leftWindowbackground")
        uiViewLeftWindow.addSubview(imageLeftSlideWindowUp)
        
        imageAvatar = UIImageView(frame: CGRect(x: 105, y: 49, width: 81, height: 81))
        imageAvatar.image = UIImage(named: "AvatarMenBigger")
        uiViewLeftWindow.addSubview(imageAvatar)
        
        label = UILabel(frame: CGRect(x: 0, y: 142, width: 290, height: 27))
        label.text = "Lin Lin"
        label.font = UIFont(name: "AvenirNext-DemiBold", size: 20)
        label.textColor = UIColor.white
        label.center.x = 145
        label.textAlignment = .center
        uiViewLeftWindow.addSubview(label)
        
        imageLeftSlideWindowMiddle = UIImageView(frame: CGRect(x: 0, y: 138, width: 290, height: 120))
        imageLeftSlideWindowMiddle.image = UIImage(named: "leftWindowCloud")
        uiViewLeftWindow.addSubview(imageLeftSlideWindowMiddle)
        
        tableLeftSlideWindow = UITableView(frame: CGRect(x: 0, y: 0, width: 290, height: screenHeight))
        tableLeftSlideWindow.delegate = self
        tableLeftSlideWindow.dataSource = self
        tableLeftSlideWindow.register(LeftSlideWindowCell.self, forCellReuseIdentifier: "cellLeftSlideWindow")
        tableLeftSlideWindow.separatorStyle = .none
        tableLeftSlideWindow.tableHeaderView = uiViewLeftWindow
        self.view.addSubview(tableLeftSlideWindow)
        tableLeftSlideWindow.center.x -= 290
        tableLeftSlideWindow.backgroundColor = UIColor.clear
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableLeftSlideWindow.dequeueReusableCell(withIdentifier: "cellLeftSlideWindow", for: indexPath) as! LeftSlideWindowCell
        let array = ["Map Boards", "Go Invisible", "Relations", "Mood Avatar", "Pins", "My Activities", "Settings"]
        cell.imageLeft.image = UIImage(named: "leftSlideWindowImage\(indexPath.row)")
        cell.labelMiddle.text = array[indexPath.row]
        if indexPath.row < 2 {
            cell.switchRight.isHidden = false
            cell.switchRight.tag = indexPath.row
            cell.switchRight.addTarget(self, action: #selector(self.swicherIsSelect(_:)), for: .valueChanged)
        }
        cell.selectionStyle = .none
        return cell
    }
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 7
    }
    func swicherIsSelect (_ sender: UISwitch) {
        if sender.tag == 0 {
            if sender.isOn {
                print("Go Map Boards")
            }else {
                print("Map off")
            }
        }
        if sender.tag == 1 {
            if sender.isOn {
                print("Go Invisible")
            }else {
                print("Invisible off")
            }
            
        }
    }
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let cell = tableLeftSlideWindow.cellForRow(at: indexPath) as! LeftSlideWindowCell
        if indexPath.row < 2 {
            UIView.animate(withDuration: 0.15, animations: {
                cell.switchRight.isOn = !cell.switchRight.isOn
            }, completion: { (complete) in
                self.swicherIsSelect(cell.switchRight)
            })
        }
        print("'\(cell.labelMiddle.text!)' at row \(indexPath.row+1) is selected")
    }
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 67
    }
}
