//
//  ChooseNearByPeople.swift
//  FaeMapBoard
//
//  Created by vicky on 2017/6/3.
//  Copyright © 2017年 Yue. All rights reserved.
//
import TTRangeSlider

extension MapBoardViewController: BoardPeopleNearbyFilterDelegate, NameCardDelegate, AddFriendFromNameCardDelegate {
    // MARK: - Load people part of boards
    func loadNearbyPeopleFilter() {
        uiviewPeopleNearyFilter = BoardPeopleNearbyFilter(frame: CGRect.zero)
        uiviewPeopleNearyFilter.delegate = self
        view.addSubview(uiviewPeopleNearyFilter)
    }
    
    func loadAvatarWaves() {
        uiviewAvatarWave = BoardAvatarWaves(frame: CGRect.zero)
        tblPeople.addSubview(uiviewAvatarWave)
    }
    
    func loadNameCard() {
        view.addSubview(uiviewNameCard)
        uiviewNameCard.delegate = self
    }
    
    // MARK: - Button actions
    // function for button on upper right of People table mode
    @objc func chooseNearbyPeopleInfo(_ sender: UIButton) {
        // in people page
        if sender.tag == 1 {
            imgPeopleLocDetail.image = #imageLiteral(resourceName: "mb_rightArrow")
            sender.tag = 0
            uiviewLineBelowLoc.frame.origin.x = 14
            uiviewLineBelowLoc.frame.size.width = screenWidth - 28
            uiviewPeopleNearyFilter.animateShow()
            
            self.tblPeople.delaysContentTouches = false
        } else {
            // in both place & people
            let vc = SelectLocationViewController()
            vc.delegate = self
            vc.mode = .part
            vc.boolFromExplore = true
            navigationController?.pushViewController(vc, animated: false)
        }
    }
    
    func rollUpFilter() {
        if uiviewPeopleNearyFilter != nil && !uiviewPeopleNearyFilter.isHidden {
            uiviewPeopleNearyFilter.animateHide()
            
            viewModelPeople.valDis = uiviewPeopleNearyFilter.valDis
            viewModelPeople.valGender = uiviewPeopleNearyFilter.valGender
            viewModelPeople.valAgeLB = uiviewPeopleNearyFilter.valAgeLB
            viewModelPeople.valAgeUB = uiviewPeopleNearyFilter.valAgeUB
            viewModelPeople.valAllAge = uiviewPeopleNearyFilter.valAllAge
            
            imgPeopleLocDetail.image = #imageLiteral(resourceName: "mb_curtLoc")
            btnSearchLoc.tag = 1
            uiviewLineBelowLoc.frame.origin.x = 0
            uiviewLineBelowLoc.frame.size.width = screenWidth
        }
    }
    
    // MARK: - SideMenuDelegate
    func userInvisible(isOn: Bool) {
        boolUsrVisibleIsOn = !isOn
        viewModelPeople.visible = boolUsrVisibleIsOn
    }
    
    // MARK: - BoardPeopleNearbyFilterDelegate
    func filterPeople() {
        rollUpFilter()
    }
    
    // MARK: - NameCardDelegate
    func openFaeUsrInfo() {
        let fmUsrInfo = FMUserInfo()
        fmUsrInfo.userId = uiviewNameCard.userId
        uiviewNameCard.hideSelf()
        navigationController?.pushViewController(fmUsrInfo, animated: true)
    }
    
    func chatUser(id: Int) {
        uiviewNameCard.hideSelf()
        let vcChat = ChatViewController()
        vcChat.arrUserIDs.append("\(Key.shared.user_id)")
        vcChat.arrUserIDs.append("\(id)")
        vcChat.strChatId = "\(id)"
        navigationController?.pushViewController(vcChat, animated: true)
    }
    
    func reportUser(id: Int) {
        let reportPinVC = ReportViewController()
        reportPinVC.reportType = 0
        present(reportPinVC, animated: true, completion: nil)
    }
    
    func openAddFriendPage(userId: Int, status: FriendStatus) {
        let addFriendVC = AddFriendFromNameCardViewController()
        addFriendVC.delegate = uiviewNameCard
        addFriendVC.contactsDelegate = self
        addFriendVC.userId = userId
        addFriendVC.statusMode = status
        addFriendVC.modalPresentationStyle = .overCurrentContext
        present(addFriendVC, animated: false)
    }
    
    // MARK: - AddFriendFromNameCardDelegate
    func changeContactsTable(action: Int, userId: Int) {
        print("changeContactsTable")
        uiviewNameCard.hide { }
    }
}
