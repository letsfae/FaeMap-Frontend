//
//  LeftSlidingMenuViewController.swift
//  faeBeta
//
//  Created by Jacky on 12/19/16.
//  Copyright © 2016 fae. All rights reserved.
//

import UIKit

class LeftSlidingMenuViewController: UIViewController, UITableViewDataSource, UITableViewDelegate {
    
    var uiViewLeftWindow: UIView!
    var buttonBackground: UIButton!
    var imageLeftSlideWindowUp: UIImageView!
    var imageLeftSlideWindowMiddle: UIImageView!
    var imageAvatar: UIImageView!
    var label: UILabel!
    var tableLeftSlideWindow: UITableView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        loadLeftWindow()
    }
    
    func loadLeftWindow () {
        buttonBackground = UIButton(frame: CGRect(x: 0, y: 0, width: screenWidth, height: screenHeight))
        buttonBackground.backgroundColor = UIColor(red: 107/255, green: 105/255, blue: 105/255, alpha: 0.7)
        buttonBackground.addTarget(self, action: #selector(self.hideLeftWindow(_:)), for: .touchUpInside)
        self.view.addSubview(buttonBackground)
        
        uiViewLeftWindow = UIView(frame: CGRect(x: 0, y: 0, width: 290, height: screenHeight))
        uiViewLeftWindow.backgroundColor = UIColor.white
        self.buttonBackground.addSubview(uiViewLeftWindow)
        
        imageLeftSlideWindowUp = UIImageView(frame: CGRect(x: 0, y: 0, width: 290, height: 238))
        imageLeftSlideWindowUp.image = UIImage(named: "leftWindowbackground")
        uiViewLeftWindow.addSubview(imageLeftSlideWindowUp)
        
        imageAvatar = UIImageView(frame: CGRect(x: 105, y: 49, width: 81, height: 81))
        imageAvatar.image = UIImage(named: "AvatarMenBigger")
        uiViewLeftWindow.addSubview(imageAvatar)
        
        label = UILabel(frame: CGRect(x: 116, y: 142, width: 58, height: 27))
        label.text = "Lin Lin"
        let attributedString = NSMutableAttributedString(string: label.text!)//加入! 的目的是
        attributedString.addAttribute(NSKernAttributeName, value: CGFloat(-0.21), range: NSRange(location: 0, length: attributedString.length))
        label.attributedText = attributedString
        label.font = UIFont(name: "AvenirNext-DemiBold", size: 20)
        label.textColor = UIColor.white
        uiViewLeftWindow.addSubview(label)
        
        imageLeftSlideWindowMiddle = UIImageView(frame: CGRect(x: 0, y: 138, width: 290, height: 120))
        imageLeftSlideWindowMiddle.image = UIImage(named: "leftWindowCloud")
        uiViewLeftWindow.addSubview(imageLeftSlideWindowMiddle)
        
        tableLeftSlideWindow = UITableView(frame: CGRect(x: 0, y: 241.5, width: 290, height: 476))
        tableLeftSlideWindow.delegate = self
        tableLeftSlideWindow.dataSource = self
        tableLeftSlideWindow.register(LeftSlideWindowCell.self, forCellReuseIdentifier: "cellLeftSlideWindow")
        tableLeftSlideWindow.separatorStyle = .none
        uiViewLeftWindow.addSubview(tableLeftSlideWindow)
        
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
    
    func hideLeftWindow (_ sender: UIButton) {
        UIView.animate(withDuration: 0.4, animations: {
            self.uiViewLeftWindow.center.x -= self.buttonBackground.frame.size.width
            self.buttonBackground.alpha = 0
        })
    }

}
