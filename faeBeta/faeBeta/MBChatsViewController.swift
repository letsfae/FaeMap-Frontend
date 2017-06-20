//
//  MBChatsViewController.swift
//  FaeMapBoard
//
//  Created by vicky on 4/12/17.
//  Copyright © 2017 Yue. All rights reserved.
//

import UIKit

class MBChatsViewController: UIViewController, UITableViewDelegate, UITableViewDataSource {
    var uiviewNavBar: UIView!
    var uiviewAllCom: UIView!
    var tableChats: UITableView!
    var btnChatSpots: UIButton!
    var btnBubbles: UIButton!
    var uiviewRedUnderLine: UIView!
    
    enum TableMode: Int {
        case chatSpots = 0
        case bubbles = 1
    }
    var tableMode: TableMode = .chatSpots
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.view.backgroundColor = .white
        loadNavBar()
        loadViewContent()
        loadTable()
    }
    
    fileprivate func loadNavBar() {
        
        uiviewNavBar = UIView(frame: CGRect(x: 0, y: 0, width: screenWidth, height: 65))
        uiviewNavBar.backgroundColor = .white
        self.view.addSubview(uiviewNavBar)
        
        btnChatSpots = UIButton()
        uiviewNavBar.addSubview(btnChatSpots)
        uiviewNavBar.addConstraintsWithFormat("V:|-22-[v0]-0-|", options: [], views: btnChatSpots)
        uiviewNavBar.addConstraintsWithFormat("H:|-65-[v0(\(130 * screenWidthFactor))]", options: [], views: btnChatSpots)
        
        let uiviewGrayUnderLine = UIView(frame: CGRect(x: 0, y: uiviewNavBar.frame.height - 1, width: screenWidth, height: 1))
        uiviewGrayUnderLine.backgroundColor = UIColor.faeAppNavBarBorderColor()
        uiviewNavBar.addSubview(uiviewGrayUnderLine)
        
        btnChatSpots.setTitle("Chat Spots", for: .normal)
        btnChatSpots.setTitleColor(UIColor.faeAppRedColor(), for: .normal)
        btnChatSpots.titleLabel?.font = UIFont(name: "AvenirNext-DemiBold", size: 18)
        btnChatSpots.tag = 0
        btnChatSpots.addTarget(self, action: #selector(self.switchBetweenChatSpotsAndBubbles(_:)), for: .touchUpInside)
        
        btnBubbles = UIButton()
        uiviewNavBar.addSubview(btnBubbles)
        uiviewNavBar.addConstraintsWithFormat("V:|-22-[v0]-0-|", options: [], views: btnBubbles)
        uiviewNavBar.addConstraintsWithFormat("H:[v0(\(130 * screenWidthFactor))]-65-|", options: [], views: btnBubbles)
        
        btnBubbles.setTitle("Bubbles", for: .normal)
        btnBubbles.setTitleColor(UIColor.faeAppInactiveBtnGrayColor(), for: .normal)
        btnBubbles.titleLabel?.font = UIFont(name: "AvenirNext-Regular", size: 18)
        btnBubbles.tag = 1
        btnBubbles.addTarget(self, action: #selector(self.switchBetweenChatSpotsAndBubbles(_:)), for: .touchUpInside)
        
        uiviewRedUnderLine = UIView(frame: CGRect(x: 60, y: uiviewNavBar.frame.height - 2, width: 130 * screenWidthFactor, height: 2))
        uiviewRedUnderLine.backgroundColor = UIColor.faeAppRedColor()
        uiviewNavBar.addSubview(uiviewRedUnderLine)
        
        let btnBackNavBar = UIButton(frame: CGRect(x: 0, y: 20, width: 40.5, height: 42))
        btnBackNavBar.setImage(#imageLiteral(resourceName: "mainScreenSearchToFaeMap"), for: .normal)
        btnBackNavBar.addTarget(self, action: #selector(self.backToMapBoard(_:)), for: .touchUpInside)
        uiviewNavBar.addSubview(btnBackNavBar)
    }
    
    func switchBetweenChatSpotsAndBubbles(_ sender: UIButton) {
        var targetCenter: CGFloat!
        if sender.tag == 0 {
            tableMode = .chatSpots
            btnChatSpots.setTitleColor(UIColor.faeAppRedColor(), for: .normal)
            btnBubbles.setTitleColor(UIColor.faeAppInactiveBtnGrayColor(), for: .normal)
            btnChatSpots.titleLabel?.font = UIFont(name: "AvenirNext-DemiBold", size: 18)
            btnBubbles.titleLabel?.font = UIFont(name: "AvenirNext-Regular", size: 18)
            targetCenter = btnChatSpots.center.x
        } else if sender.tag == 1 {
            tableMode = .bubbles
            btnBubbles.setTitleColor(UIColor.faeAppRedColor(), for: .normal)
            btnChatSpots.setTitleColor(UIColor.faeAppInactiveBtnGrayColor(), for: .normal)
            btnBubbles.titleLabel?.font = UIFont(name: "AvenirNext-DemiBold", size: 18)
            btnChatSpots.titleLabel?.font = UIFont(name: "AvenirNext-Regular", size: 18)
            targetCenter = btnBubbles.center.x
        }
        
        // Animation of the red sliding line (Chat Spots, Bubbles)
        UIView.animate(withDuration: 0.25, animations: ({
            self.uiviewRedUnderLine.center.x = targetCenter
        }), completion: { _ in
        })
        tableChats.reloadData()
    }
    
    fileprivate func loadViewContent() {
        uiviewAllCom = UIView(frame: CGRect(x: 0, y: 65, width: screenWidth, height: 49))
        uiviewAllCom.backgroundColor = .white
        self.view.addSubview(uiviewAllCom)
        
        let imgIconBeforeAllCom = UIImageView(frame: CGRect(x: 13, y: 13, width: 24, height: 24))
        imgIconBeforeAllCom.image = #imageLiteral(resourceName: "mb_iconBeforeAllCom")
        uiviewAllCom.addSubview(imgIconBeforeAllCom)
        
        let lblAllCom = UILabel(frame: CGRect(x: 50, y: 14.5, width: 300, height: 22))
        lblAllCom.text = "All Communities"
        lblAllCom.font = UIFont(name: "AvenirNext-Medium", size: 16)
        lblAllCom.textColor = UIColor.faeAppTimeTextBlackColor()
        uiviewAllCom.addSubview(lblAllCom)
        
        // draw line
        let lblAllComUnderLine = UIView(frame: CGRect(x: 0, y: uiviewAllCom.frame.height - 1, width: screenWidth, height: 1))
        lblAllComUnderLine.layer.borderColor = UIColor.faeAppNavBarBorderGrayColor()
        lblAllComUnderLine.layer.borderWidth = 1
        uiviewAllCom.addSubview(lblAllComUnderLine)
    }

    fileprivate func loadTable() {
        tableChats = UITableView(frame: CGRect(x: 0, y: 114, width: screenWidth, height: screenHeight - 114), style: UITableViewStyle.plain)
        tableChats.backgroundColor = .white
        tableChats.register(MBChatSpotsCell.self, forCellReuseIdentifier: "mbChatSpotsCell")
        tableChats.register(MBChatBubblesCell.self, forCellReuseIdentifier: "mbChatBubblesCell")
        tableChats.delegate = self
        tableChats.dataSource = self
        
        tableChats.separatorStyle = .none

        self.view.addSubview(tableChats)
    }
    
    func backToMapBoard(_ sender: UIButton) {
//        self.dismiss(animated: false, completion: nil)
        self.navigationController?.popViewController(animated: true)
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        if tableMode == .chatSpots {
            return 90
        }
        return 62
    }
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    let imgChatAvatarArr: Array = ["default_Avatar", "default_Avatar", "default_Avatar"]
    let lblChatTitleTxt: Array = ["University of SoCal Beach Chat", "University of SoCal Beach Chat", "University of SoCal Beach Chat"]
    let lblChatContTxt: Array = ["Once upon a time, there was a mountain top bxagagfa", "Once upon a time, there was a mountain top bxagagfa", "Once upon a time, there was a mountain top bxagagfa"]
    
    let imgBubbleAvatarArr: Array = ["default_Avatar", "default_Avatar", "default_Avatar", "default_Avatar"]
    let lblBubbleTitleTxt: Array = ["Anyone seen my dog?", "Anyone seen my dog?", "Anyone seen my dog?", "Anyone seen my dog?"]
    let lblBubbleTimeTxt: Array = ["Just now in Los Angeles", "30 min ago in Los Angeles", "30 min ago in Los Angeles", "Just now in San Francisco"]
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if tableMode == .chatSpots {
            return lblChatTitleTxt.count
        }
        return lblBubbleTitleTxt.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        if tableMode == .chatSpots {
            let cell = tableView.dequeueReusableCell(withIdentifier: "mbChatSpotsCell", for: indexPath) as! MBChatSpotsCell
            cell.imgAvatar.image = UIImage(named: imgChatAvatarArr[indexPath.row])
            cell.lblChatTitle?.text = lblChatTitleTxt[indexPath.row]
            cell.lblChatCont?.text = lblChatContTxt[indexPath.row]
            return cell
        } else if tableMode == .bubbles {
            let cell = tableView.dequeueReusableCell(withIdentifier: "mbChatBubblesCell", for: indexPath) as! MBChatBubblesCell
            cell.imgAvatar.image = UIImage(named: imgBubbleAvatarArr[indexPath.row])
            cell.lblBubbleTitle?.text = lblBubbleTitleTxt[indexPath.row]
            cell.lblBubbleTime?.text = lblBubbleTimeTxt[indexPath.row]
            return cell
        }
        return UITableViewCell()
    }
}
