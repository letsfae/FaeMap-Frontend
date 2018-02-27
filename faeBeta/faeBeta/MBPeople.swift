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
            self.lblAllCom.attributedText = fullAttrStr
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
    
    // LeftSlidingMenuDelegate
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
            uiviewPeopleLocDetail.isHidden = false
            UIView.animate(withDuration: 0.5, delay: 0, usingSpringWithDamping: 1, initialSpringVelocity: 0, options: .curveEaseOut, animations: {
                self.uiviewPeopleLocDetail.frame.origin.y = 113 + device_offset_top
            }, completion: nil)
            self.tblMapBoard.delaysContentTouches = false
            sliderDisFilter.setValue(Float(disVal)!, animated: false)
        } else { // in both place & people
            /* 老板要求改为直接地图上选取
            let vc = BoardsSearchViewController()
            vc.strSearchedLocation = lblAllCom.text
            vc.enterMode = .location
            vc.isCitySearch = true
            vc.delegate = self
            navigationController?.pushViewController(vc, animated: true)
            */
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
        if uiviewPeopleLocDetail != nil && !uiviewPeopleLocDetail.isHidden {
            UIView.animate(withDuration: 0.5, delay: 0, usingSpringWithDamping: 1, initialSpringVelocity: 0, options: .curveEaseOut, animations: {
                self.uiviewPeopleLocDetail.frame.origin.y = -203
            }, completion: { _ in
                self.uiviewPeopleLocDetail.isHidden = true
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
        getMBPeopleInfo ({ (count: Int) in
            //            print(self.mbPeople)
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
        uiviewPeopleLocDetail = UIView(frame: CGRect(x: 0, y: 113, width: screenWidth, height: 316))
        self.view.addSubview(uiviewPeopleLocDetail)
        uiviewPeopleLocDetail.backgroundColor = .white
        uiviewPeopleLocDetail.frame.origin.y = -203   // 113 - 316
        self.uiviewPeopleLocDetail.isHidden = true
        
        let swipeGesture = UISwipeGestureRecognizer(target: self, action: #selector(rollUpPeopleLocPage(_:)))
        uiviewPeopleLocDetail.addGestureRecognizer(swipeGesture)
        swipeGesture.direction = .up
        
        let uiviewLowerLine = UIView(frame: CGRect(x: 0, y: 315, width: screenWidth, height: 1))
        uiviewLowerLine.backgroundColor = UIColor._200199204()
        uiviewPeopleLocDetail.addSubview(uiviewLowerLine)
        
        // draw three lines
        let uiviewFirstLine = UIView(frame: CGRect(x: 14, y: 0, width: screenWidth - 28, height: 1))
        uiviewFirstLine.backgroundColor = UIColor._206203203()
        
        let uiviewSecLine = UIView(frame: CGRect(x: 14, y: 99, width: screenWidth - 28, height: 1))
        uiviewSecLine.backgroundColor = UIColor._206203203()
        
        let uiviewThirdLine = UIView(frame: CGRect(x: 14, y: 195, width: screenWidth - 28, height: 1))
        uiviewThirdLine.backgroundColor = UIColor._206203203()
        
        uiviewPeopleLocDetail.addSubview(uiviewFirstLine)
        uiviewPeopleLocDetail.addSubview(uiviewSecLine)
        uiviewPeopleLocDetail.addSubview(uiviewThirdLine)
        
        // draw labels and buttons
        let lblDis = UILabel(frame: CGRect(x: 15, y: 22, width: 150, height: 21))
        lblDis.text = "Maximum Distance"
        
        lblDisVal = UILabel(frame: CGRect(x: screenWidth - 95, y: 22, width: 80, height: 22))
        lblDisVal.text = "\(disVal) km"
        lblDisVal.textAlignment = .right
        
        let lblGender = UILabel(frame: CGRect(x: 15, y: 119, width: 150, height: 21))
        lblGender.text = "Gender"
        
        let lblGenderBoth = UILabel()
        lblGenderBoth.text = "Both"
        let lblGenderFemale = UILabel()
        lblGenderFemale.text = "Female"
        let lblGenderMale = UILabel()
        lblGenderMale.text = "Male"
        
        btnGenderBoth = UIButton()
        btnGenderBoth.tag = 0
        
        btnGenderFemale = UIButton()
        btnGenderFemale.tag = 1
        
        btnGenderMale = UIButton()
        btnGenderMale.tag = 2
        
        highlightGenderBtn()
        
        btnGenderBoth.addTarget(self, action: #selector(self.selectGender(_:)), for: .touchUpInside)
        btnGenderFemale.addTarget(self, action: #selector(self.selectGender(_:)), for: .touchUpInside)
        btnGenderMale.addTarget(self, action: #selector(self.selectGender(_:)), for: .touchUpInside)
        
        let lblAgeRange = UILabel(frame: CGRect(x: 15, y: 215, width: 150, height: 21))
        lblAgeRange.text = "Age Range"
        
        lblAgeVal = UILabel(frame: CGRect(x: screenWidth - 95, y: 215, width: 80, height: 22))
        lblAgeVal.text = "\(ageLBVal)-\(ageUBVal)"
        lblAgeVal.textAlignment = .right
        
        lblDis.textColor = UIColor._107107107()
        lblGender.textColor = UIColor._107107107()
        lblGenderBoth.textColor = UIColor._107107107()
        lblGenderMale.textColor = UIColor._107107107()
        lblGenderFemale.textColor = UIColor._107107107()
        lblAgeRange.textColor = UIColor._107107107()
        lblDisVal.textColor = UIColor._146146146()
        lblAgeVal.textColor = UIColor._146146146()
        
        lblDis.font = UIFont(name: "AvenirNext-Medium", size: 16)
        lblGender.font = UIFont(name: "AvenirNext-Medium", size: 16)
        lblGenderBoth.font = UIFont(name: "AvenirNext-Medium", size: 16)
        lblGenderFemale.font = UIFont(name: "AvenirNext-Medium", size: 16)
        lblGenderMale.font = UIFont(name: "AvenirNext-Medium", size: 16)
        lblAgeRange.font = UIFont(name: "AvenirNext-Medium", size: 16)
        lblDisVal.font = UIFont(name: "AvenirNext-Medium", size: 16)
        lblAgeVal.font = UIFont(name: "AvenirNext-Medium", size: 16)
        
        uiviewPeopleLocDetail.addSubview(lblDis)
        uiviewPeopleLocDetail.addSubview(lblGender)
        uiviewPeopleLocDetail.addSubview(lblGenderBoth)
        uiviewPeopleLocDetail.addSubview(lblGenderFemale)
        uiviewPeopleLocDetail.addSubview(lblGenderMale)
        uiviewPeopleLocDetail.addSubview(lblAgeRange)
        uiviewPeopleLocDetail.addSubview(lblDisVal)
        uiviewPeopleLocDetail.addSubview(lblAgeVal)
        uiviewPeopleLocDetail.addSubview(btnGenderBoth)
        uiviewPeopleLocDetail.addSubview(btnGenderMale)
        uiviewPeopleLocDetail.addSubview(btnGenderFemale)
        
        uiviewPeopleLocDetail.addConstraintsWithFormat("V:|-155-[v0(21)]", options: [], views: lblGenderBoth)
        uiviewPeopleLocDetail.addConstraintsWithFormat("V:|-155-[v0(21)]", options: [], views: lblGenderFemale)
        uiviewPeopleLocDetail.addConstraintsWithFormat("V:|-155-[v0(21)]", options: [], views: lblGenderMale)
        uiviewPeopleLocDetail.addConstraintsWithFormat("V:|-151-[v0(29)]", options: [], views: btnGenderBoth)
        uiviewPeopleLocDetail.addConstraintsWithFormat("V:|-151-[v0(29)]", options: [], views: btnGenderFemale)
        uiviewPeopleLocDetail.addConstraintsWithFormat("V:|-151-[v0(29)]", options: [], views: btnGenderMale)
        
        uiviewPeopleLocDetail.addConstraintsWithFormat("H:|-27-[v0(29)]-10-[v1(36)]", options: [], views: btnGenderBoth, lblGenderBoth)
        let leftPadding = (screenWidth - 89) / 2
        uiviewPeopleLocDetail.addConstraintsWithFormat("H:|-\(leftPadding)-[v0(29)]-10-[v1(55)]", options: [], views: btnGenderFemale, lblGenderFemale)
        uiviewPeopleLocDetail.addConstraintsWithFormat("H:[v0(29)]-10-[v1(38)]-27-|", options: [], views: btnGenderMale, lblGenderMale)
        
        sliderDisFilter = UISlider(frame: CGRect(x: 28, y: 56, width: screenWidth - 56, height: 28))
        sliderDisFilter.setThumbImage(#imageLiteral(resourceName: "mb_emptyRedOval"), for: .normal)
        sliderDisFilter.maximumTrackTintColor = UIColor._200199204()
        sliderDisFilter.minimumTrackTintColor = UIColor._2499090()
        sliderDisFilter.minimumValue = 0
        sliderDisFilter.maximumValue = 100
        sliderDisFilter.addTarget(self, action: #selector(self.changeDisRange(_:)), for: .valueChanged)
        
        sliderAgeFilter = TTRangeSlider(frame: CGRect(x: 28, y: 248, width: screenWidth - 56, height: 28))
        sliderAgeFilter.delegate = self
        sliderAgeFilter.tintColor = UIColor._200199204()
        sliderAgeFilter.tintColorBetweenHandles = UIColor._2499090()
        sliderAgeFilter.handleImage = #imageLiteral(resourceName: "mb_emptyRedOval")
        sliderAgeFilter.handleDiameter = 22
        sliderAgeFilter.lineHeight = 2.4
        sliderAgeFilter.selectedHandleDiameterMultiplier = 1.0
        sliderAgeFilter.hideLabels = true
        sliderAgeFilter.minValue = 18
        sliderAgeFilter.maxValue = 50
        sliderAgeFilter.selectedMinimum = Float(ageLBVal)
        sliderAgeFilter.selectedMaximum = Float(ageUBVal)
        
        uiviewPeopleLocDetail.addSubview(sliderDisFilter)
        uiviewPeopleLocDetail.addSubview(sliderAgeFilter)
        
        // draw upArraw button
        let btnUpArrow = UIButton(frame: CGRect(x: (screenWidth-36)/2, y: 288, width: 36, height: 25))
        btnUpArrow.setImage(#imageLiteral(resourceName: "mapFilterArrow"), for: .normal)
        uiviewPeopleLocDetail.addSubview(btnUpArrow)
        btnUpArrow.addTarget(self, action: #selector(self.rollUpPeopleLocPage(_:)), for: .touchUpInside)
    }
    
    @objc func selectGender(_ sender: UIButton) {
        if sender.tag == 0 {
            selectedGender = "Both"
        } else if sender.tag == 1 {
            selectedGender = "Female"
        } else if sender.tag == 2 {
            selectedGender = "Male"
        }
        highlightGenderBtn()
    }
    
    fileprivate func highlightGenderBtn() {
        if selectedGender == "Both" {
            btnGenderBoth.setImage(#imageLiteral(resourceName: "mb_btnOvalSelected"), for: .normal)
            btnGenderFemale.setImage(#imageLiteral(resourceName: "mb_btnOvalUnselected"), for: .normal)
            btnGenderMale.setImage(#imageLiteral(resourceName: "mb_btnOvalUnselected"), for: .normal)
        } else if selectedGender == "Female" {
            btnGenderBoth.setImage(#imageLiteral(resourceName: "mb_btnOvalUnselected"), for: .normal)
            btnGenderFemale.setImage(#imageLiteral(resourceName: "mb_btnOvalSelected"), for: .normal)
            btnGenderMale.setImage(#imageLiteral(resourceName: "mb_btnOvalUnselected"), for: .normal)
        } else if selectedGender == "Male" {
            btnGenderBoth.setImage(#imageLiteral(resourceName: "mb_btnOvalUnselected"), for: .normal)
            btnGenderFemale.setImage(#imageLiteral(resourceName: "mb_btnOvalUnselected"), for: .normal)
            btnGenderMale.setImage(#imageLiteral(resourceName: "mb_btnOvalSelected"), for: .normal)
        }
    }

    @objc func changeDisRange(_ sender: UISlider) {
        disVal = String(format: "%.1f", sender.value)
        lblDisVal.text = "\(disVal) km"
    }
    
    func rangeSlider(_ sender: TTRangeSlider, didChangeSelectedMinimumValue selectedMinimum: Float, andMaximumValue selectedMaximum: Float) {
        ageLBVal = Int(selectedMinimum)
        ageUBVal = Int(selectedMaximum)
        if ageLBVal == 18 && ageUBVal == 50 {
            lblAgeVal.text = "All"
            
        } else if ageUBVal == 50 {
            lblAgeVal.text = "\(ageLBVal)-50+"
        } else {
            lblAgeVal.text = "\(ageLBVal)-\(ageUBVal)"
        }
    }
    
    func searchLoc(_ sender: UIButton) {
        let vc = BoardsSearchViewController()
        vc.strSearchedLocation = lblAllCom.text
        vc.enterMode = .location
        vc.delegate = self
        navigationController?.pushViewController(vc, animated: true)
    }
}
