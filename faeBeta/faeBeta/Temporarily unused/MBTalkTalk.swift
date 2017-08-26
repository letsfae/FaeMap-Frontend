//
//  MBTalkTalk.swift
//  faeBeta
//
//  Created by Faevorite 2 on 2017-08-17.
//  Copyright © 2017 fae. All rights reserved.
//

import UIKit

// for TalkTalk page
extension MapBoardViewController {
    // function for loading talk post uiview and switch buttons
    func loadTalkPostHead() {
        uiviewTalkPostHead = UIView(frame: CGRect(x: 0, y: 64, width: screenWidth, height: 31))
        view.addSubview(uiviewTalkPostHead)
        uiviewTalkPostHead.backgroundColor = .white
        uiviewTalkPostHead.isHidden = true
        
        btnMyTalks = UIButton()
        uiviewTalkPostHead.addSubview(btnMyTalks)
        uiviewTalkPostHead.addConstraintsWithFormat("V:|-0-[v0]-0-|", options: [], views: btnMyTalks)
        uiviewTalkPostHead.addConstraintsWithFormat("H:|-40-[v0(130)]", options: [], views: btnMyTalks)
        
        let uiviewGrayUnderLine = UIView(frame: CGRect(x: 0, y: uiviewTalkPostHead.frame.height - 1, width: screenWidth, height: 1))
        uiviewGrayUnderLine.backgroundColor = UIColor._200199204()
        uiviewTalkPostHead.addSubview(uiviewGrayUnderLine)
        
        btnMyTalks.setTitle("My Talks", for: .normal)
        btnMyTalks.setTitleColor(UIColor._2499090(), for: .normal)
        btnMyTalks.titleLabel?.font = UIFont(name: "AvenirNext-DemiBold", size: 18)
        btnMyTalks.tag = 0
        btnMyTalks.addTarget(self, action: #selector(self.switchBetweenTalkAndComment(_:)), for: .touchUpInside)
        
        uiviewRedUnderLine = UIView(frame: CGRect(x: 40, y: uiviewTalkPostHead.frame.height - 2, width: 130, height: 2))
        uiviewRedUnderLine.backgroundColor = UIColor._2499090()
        uiviewTalkPostHead.addSubview(uiviewRedUnderLine)
        
        btnComments = UIButton()
        uiviewTalkPostHead.addSubview(btnComments)
        uiviewTalkPostHead.addConstraintsWithFormat("V:|-0-[v0]-0-|", options: [], views: btnComments)
        uiviewTalkPostHead.addConstraintsWithFormat("H:[v0(130)]-40-|", options: [], views: btnComments)
        
        btnComments.setTitle("Comments", for: .normal)
        btnComments.setTitleColor(UIColor._146146146(), for: .normal)
        btnComments.titleLabel?.font = UIFont(name: "AvenirNext-Regular", size: 18)
        btnComments.tag = 1
        btnComments.addTarget(self, action: #selector(switchBetweenTalkAndComment(_:)), for: .touchUpInside)
    }
    
    func loadTalkTabView() {
        uiviewTalkTab = UIView()
        uiviewTalkTab.backgroundColor = UIColor._248248248()
        view.addSubview(uiviewTalkTab)
        view.addConstraintsWithFormat("H:|-0-[v0]-0-|", options: [], views: uiviewTalkTab)
        view.addConstraintsWithFormat("V:[v0(49)]-0-|", options: [], views: uiviewTalkTab)
        
        let tabLine = UIView()
        tabLine.backgroundColor = UIColor._200199204()
        uiviewTalkTab.addSubview(tabLine)
        uiviewTalkTab.addConstraintsWithFormat("H:|-0-[v0]-0-|", options: [], views: tabLine)
        uiviewTalkTab.addConstraintsWithFormat("V:|-0-[v0(1)]", options: [], views: tabLine)
        
        // add three buttons
        btnTalkFeed = UIButton()
        btnTalkFeed.setImage(#imageLiteral(resourceName: "mb_activeTalkFeed"), for: .selected)
        btnTalkFeed.setImage(#imageLiteral(resourceName: "mb_inactiveTalkFeed"), for: .normal)
        
        btnTalkFeed.tag = 0
        uiviewTalkTab.addSubview(btnTalkFeed)
        uiviewTalkTab.addConstraintsWithFormat("H:|-67-[v0(47)]", options: [], views: btnTalkFeed)
        uiviewTalkTab.addConstraintsWithFormat("V:[v0(37)]-6-|", options: [], views: btnTalkFeed)
        
        btnTalkTopic = UIButton()
        btnTalkTopic.setImage(#imageLiteral(resourceName: "mb_activeTalkTopic"), for: .selected)
        btnTalkTopic.setImage(#imageLiteral(resourceName: "mb_inactiveTalkTopic"), for: .normal)
        btnTalkTopic.tag = 1
        uiviewTalkTab.addSubview(btnTalkTopic)
        let padding = (screenWidth - 47) / 2
        uiviewTalkTab.addConstraintsWithFormat("H:|-\(padding)-[v0(47)]-\(padding)-|", options: [], views: btnTalkTopic)
        uiviewTalkTab.addConstraintsWithFormat("V:[v0(37)]-6-|", options: [], views: btnTalkTopic)
        
        btnTalkMypost = UIButton()
        btnTalkMypost.setImage(#imageLiteral(resourceName: "mb_activeTalkMypost"), for: .selected)
        btnTalkMypost.setImage(#imageLiteral(resourceName: "mb_inactiveTalkMypost"), for: .normal)
        btnTalkMypost.tag = 2
        uiviewTalkTab.addSubview(btnTalkMypost)
        uiviewTalkTab.addConstraintsWithFormat("H:[v0(47)]-67-|", options: [], views: btnTalkMypost)
        uiviewTalkTab.addConstraintsWithFormat("V:[v0(37)]-6-|", options: [], views: btnTalkMypost)
        
        btnTalkFeed.addTarget(self, action: #selector(self.getTalkTableMode(_:)), for: .touchUpInside)
        btnTalkTopic.addTarget(self, action: #selector(self.getTalkTableMode(_:)), for: .touchUpInside)
        btnTalkMypost.addTarget(self, action: #selector(self.getTalkTableMode(_:)), for: .touchUpInside)
    }
    
    func getTalkTableMode(_ sender: UIButton) {
        if sender.tag == 0 {
            talkTableMode = .feed
        } else if sender.tag == 1 {
            talkTableMode = .topic
        } else if sender.tag == 2 {
            talkTableMode = .post
        }
        switchTalkTabPage()
        reloadTableMapBoard()
    }
    
    // function for switch tab page in talk mode
    func switchTalkTabPage() {
        if talkTableMode == .feed {
            btnTalkFeed.isSelected = true
            btnTalkTopic.isSelected = false
            btnTalkMypost.isSelected = false
            uiviewNavBar.rightBtn.isHidden = false
        } else if talkTableMode == .topic {
            btnTalkFeed.isSelected = false
            btnTalkTopic.isSelected = true
            btnTalkMypost.isSelected = false
            uiviewNavBar.rightBtn.isHidden = true
        } else if talkTableMode == .post {
            btnTalkFeed.isSelected = false
            btnTalkTopic.isSelected = false
            btnTalkMypost.isSelected = true
            uiviewNavBar.rightBtn.isHidden = true
        }
        
        if talkTableMode == .post {
            //            tblMapBoard.frame = CGRect(x: 0, y: 95, width: screenWidth, height: screenHeight - 145)
            uiviewAllCom.isHidden = true
            uiviewNavBar.bottomLine.isHidden = true
            uiviewTalkPostHead.isHidden = false
        } else {
            //            tblMapBoard.frame = CGRect(x: 0, y: 114, width: screenWidth, height: screenHeight - 163)
            uiviewAllCom.isHidden = false
            uiviewNavBar.bottomLine.isHidden = false
            uiviewTalkPostHead.isHidden = true
        }
    }
    
    // function for add talk feed when press upper right plus button in talk mode
    func addTalkFeed(_ sender: UIButton) {
        print("addTalkFeed")
    }
    
    func switchBetweenTalkAndComment(_ sender: UIButton) {
        var targetCenter: CGFloat = 0
        if sender.tag == 0 {
            talkPostTableMode = .talk
            btnMyTalks.setTitleColor(UIColor._2499090(), for: .normal)
            btnComments.setTitleColor(UIColor._146146146(), for: .normal)
            btnMyTalks.titleLabel?.font = UIFont(name: "AvenirNext-DemiBold", size: 18)
            btnComments.titleLabel?.font = UIFont(name: "AvenirNext-Regular", size: 18)
            targetCenter = btnMyTalks.center.x
        } else if sender.tag == 1 {
            talkPostTableMode = .comment
            btnComments.setTitleColor(UIColor._2499090(), for: .normal)
            btnMyTalks.setTitleColor(UIColor._146146146(), for: .normal)
            btnComments.titleLabel?.font = UIFont(name: "AvenirNext-DemiBold", size: 18)
            btnMyTalks.titleLabel?.font = UIFont(name: "AvenirNext-Regular", size: 18)
            targetCenter = btnComments.center.x
        }
        
        // Animation of the red sliding line (My Talks, Comments)
        UIView.animate(withDuration: 0.25, animations: ({
            self.uiviewRedUnderLine.center.x = targetCenter
        }), completion: { _ in
        })
        
        reloadTableMapBoard()
    }
    
    func incDecVoteCount(_ sender: UIButton) {
        if sender.tag == 0 {
            print("0")
        } else if sender.tag == 1 {
            print("1")
        }
    }
}

