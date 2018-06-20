//
//  ChooseNearByPeople.swift
//  FaeMapBoard
//
//  Created by vicky on 2017/6/3.
//  Copyright © 2017年 Yue. All rights reserved.
//
import TTRangeSlider

extension MapBoardViewController: TTRangeSliderDelegate {
    
    // MARK: - BoardsSearchDelegate
    func sendLocationBack(address: RouteAddress) {
        var arrNames = address.name.split(separator: ",")
        var array = [String]()
        guard arrNames.count >= 1 else { return }
        for i in 0..<arrNames.count {
            let name = String(arrNames[i]).trimmingCharacters(in: CharacterSet.whitespaces)
            array.append(name)
        }
        if array.count >= 3 {
            reloadBottomText(array[0], array[1] + ", " + array[2])
        } else if array.count == 1 {
            reloadBottomText(array[0], "")
        } else if array.count == 2 {
            reloadBottomText(array[0], array[1])
        }
        self.chosenLoc = address.coordinate
        self.uiviewBubbleHint.alpha = 0
        updateNearbyPeople()
        rollUpFilter()
    }
    
    func reloadBottomText(_ city: String, _ state: String) {
        let fullAttrStr = NSMutableAttributedString()
//        let firstImg = #imageLiteral(resourceName: "mapSearchCurrentLocation")
//        let first_attch = InlineTextAttachment()
//        first_attch.fontDescender = -2
//        first_attch.image = UIImage(cgImage: (firstImg.cgImage)!, scale: 3, orientation: .up)
//        let firstImg_attach = NSAttributedString(attachment: first_attch)
//
//        let secondImg = #imageLiteral(resourceName: "exp_bottom_loc_arrow")
//        let second_attch = InlineTextAttachment()
//        second_attch.fontDescender = -1
//        second_attch.image = UIImage(cgImage: (secondImg.cgImage)!, scale: 3, orientation: .up)
//        let secondImg_attach = NSAttributedString(attachment: second_attch)
        let attrs_0 = [NSAttributedStringKey.foregroundColor: UIColor._898989(), NSAttributedStringKey.font: UIFont(name: "AvenirNext-Medium", size: 16)!]
        let title_0_attr = NSMutableAttributedString(string: "  " + city + " ", attributes: attrs_0)
        
        let attrs_1 = [NSAttributedStringKey.foregroundColor: UIColor._138138138(), NSAttributedStringKey.font: UIFont(name: "AvenirNext-Medium", size: 16)!]
        let title_1_attr = NSMutableAttributedString(string: state + "  ", attributes: attrs_1)
        
//        fullAttrStr.append(firstImg_attach)
        fullAttrStr.append(title_0_attr)
        fullAttrStr.append(title_1_attr)
//        fullAttrStr.append(secondImg_attach)
        DispatchQueue.main.async {
            self.lblCurtLoc.attributedText = fullAttrStr
        }
    }
    
    func loadCannotFindPeople() {
        uiviewBubbleHint = UIView(frame: CGRect(x: 0, y: 114, width: screenWidth, height: screenHeight - 114))
        uiviewBubbleHint.backgroundColor = .white
        view.addSubview(uiviewBubbleHint)
        
        imgBubbleHint = UIImageView(frame: CGRect(x: 82 * screenWidthFactor, y: 142 * screenHeightFactor, width: 252, height: 209))
        imgBubbleHint.image = #imageLiteral(resourceName: "mb_bubbleHint")
        uiviewBubbleHint.addSubview(imgBubbleHint)
        
        lblBubbleHint = UILabel(frame: CGRect(x: 24, y: 9, width: 206, height: 75))
        lblBubbleHint.font = UIFont(name: "AvenirNext-Medium", size: 18)
        lblBubbleHint.textColor = UIColor._898989()
        lblBubbleHint.lineBreakMode = .byWordWrapping
        lblBubbleHint.numberOfLines = 0
        imgBubbleHint.addSubview(lblBubbleHint)
        lblBubbleHint.text = strBubbleHint
    }
    
    func getPeoplePage() {
        vickyprint("userStatus \(Key.shared.onlineStatus)")
        if curtTitle == "People" && !boolUsrVisibleIsOn {
            tblMapBoard.isHidden = true
            uiviewBubbleHint.alpha = 1
            strBubbleHint = "Oops, you are invisible right now, turn off invisibility to discover! :)"
            lblBubbleHint.text = strBubbleHint
            btnSearchLoc.isUserInteractionEnabled = false
        } else {
            tblMapBoard.isHidden = false
            uiviewBubbleHint.alpha = 0
            btnSearchLoc.isUserInteractionEnabled = true
        }
    }
    
    // sideMenuDelegate
    func userInvisible(isOn: Bool) {
        vickyprint("isOn \(isOn)")
        if (isOn) {
            boolUsrVisibleIsOn = false
        } else {
            boolUsrVisibleIsOn = true
        }
        getPeoplePage()
    }
    
    // function for button on upper right of People table mode
    @objc func chooseNearbyPeopleInfo(_ sender: UIButton) {
        // in people page
        if sender.tag == 1 {
            imgPeopleLocDetail.image = #imageLiteral(resourceName: "mb_rightArrow")
            sender.tag = 0
            uiviewLineBelowLoc.frame.origin.x = 14
            uiviewLineBelowLoc.frame.size.width = screenWidth - 28
            uiviewPeopleNearyFilter.isHidden = false
            UIView.animate(withDuration: 0.5, delay: 0, usingSpringWithDamping: 1, initialSpringVelocity: 0, options: .curveEaseOut, animations: {
                self.uiviewPeopleNearyFilter.frame.origin.y = 113 + device_offset_top
            }, completion: nil)
            self.tblMapBoard.delaysContentTouches = false
//            sliderDisFilter.setValue(Float(disVal)!, animated: false)
        } else {
            // in both place & people
            let vc = SelectLocationViewController()
            vc.delegate = self
            vc.mode = .part
            vc.boolFromExplore = true
            navigationController?.pushViewController(vc, animated: false)
        }
    }
    
    @objc func rollUpPeopleLocPage(_ sender: AnyObject) {
        rollUpFilter()
    }
    
    func rollUpFilter() {
        if uiviewPeopleNearyFilter != nil && !uiviewPeopleNearyFilter.isHidden {
            UIView.animate(withDuration: 0.5, delay: 0, usingSpringWithDamping: 1, initialSpringVelocity: 0, options: .curveEaseOut, animations: {
                self.uiviewPeopleNearyFilter.frame.origin.y = -203
            }, completion: { _ in
                self.uiviewPeopleNearyFilter.isHidden = true
            })
            imgPeopleLocDetail.image = #imageLiteral(resourceName: "mb_curtLoc")
            btnSearchLoc.tag = 1
            uiviewLineBelowLoc.frame.origin.x = 0
            uiviewLineBelowLoc.frame.size.width = screenWidth
            updateNearbyPeople()
        }
    }
    
    func updateNearbyPeople() {
        // when user is invisible
        if !boolUsrVisibleIsOn || curtTitle != "People" {
            return
        }
        showWaves()
        getMBPeopleInfo ({ [weak self] (count: Int) in
            //            print(self.mbPeople)
            guard let `self` = self else { return }
            if count == 0 {   // self.mbPeople.count == 0
                self.strBubbleHint = "We can’t find any matches nearby, try a different setting! :)"
                self.lblBubbleHint.text = self.strBubbleHint
            } else {
                self.tblMapBoard.reloadData()
            }
            self.hideWaves(count: count)
        })
    }
    
    func loadChooseNearbyPeopleView() {
        uiviewPeopleNearyFilter = BoardPeopleNearbyFilter(frame: CGRect(x: 0, y: 113, width: screenWidth, height: 316))
        self.view.addSubview(uiviewPeopleNearyFilter)
        uiviewPeopleNearyFilter.frame.origin.y = -203
    }
}
