//
//  ChooseNearByPeople.swift
//  FaeMapBoard
//
//  Created by vicky on 2017/6/3.
//  Copyright © 2017年 Yue. All rights reserved.
//
import TTRangeSlider

extension MapBoardViewController: TTRangeSliderDelegate {
    // function for button on upper right of People table mode
    func chooseNearbyPeopleInfo(_ sender: UIButton) {
        UIView.animate(withDuration: 0.5, delay: 0, usingSpringWithDamping: 1, initialSpringVelocity: 0, options: .curveEaseOut, animations: {
            self.uiviewPeopleLocDetail.frame.origin.y = 65
        }, completion: nil)
        btnNavBarMenu.isUserInteractionEnabled = false
        self.tableMapBoard.delaysContentTouches = false
        sliderDisFilter.setValue(Float(disVal)!, animated: false)
        
        let swipeGesture = UISwipeGestureRecognizer(target: self, action: #selector(self.rollUpPeopleLocPage(_:)))
        uiviewPeopleLocDetail.addGestureRecognizer(swipeGesture)
        swipeGesture.direction = .up
    }
    
    func rollUpPeopleLocPage(_ sender: AnyObject) {
        UIView.animate(withDuration: 0.5, delay: 0, usingSpringWithDamping: 1, initialSpringVelocity: 0, options: .curveEaseOut, animations: {
            self.uiviewPeopleLocDetail.frame.origin.y = -301
        }, completion: nil)
        btnNavBarMenu.isUserInteractionEnabled = true
        
        if boolNoMatch {   // self.mbPeople.count == 0
            self.tableMapBoard.isHidden = true
            self.uiviewBubbleHint.isHidden = false
            strBubbleHint = "We can’t find any matches nearby, try a different setting! :)"
            lblBubbleHint.text = strBubbleHint
        }
    }
    
    func loadChooseNearbyPeopleView() {
        uiviewPeopleLocDetail = UIView(frame: CGRect(x: 0, y: 65, width: screenWidth, height: 364))
        self.view.addSubview(uiviewPeopleLocDetail)
        uiviewPeopleLocDetail.backgroundColor = .white
        uiviewPeopleLocDetail.frame.origin.y = -301   // 65 - 364

        let uiviewLowerLine = UIView(frame: CGRect(x: 0, y: 363, width: screenWidth, height: 1))
        uiviewLowerLine.backgroundColor = UIColor.faeAppNavBarBorderColor()
        uiviewPeopleLocDetail.addSubview(uiviewLowerLine)
        
        // draw three line
        let uiviewFirstLine = UIView(frame: CGRect(x: 14, y: 48, width: screenWidth - 28, height: 1))
        uiviewFirstLine.backgroundColor = UIColor(red: 206/255, green: 203/255, blue: 203/255, alpha: 1)
        
        let uiviewSecLine = UIView(frame: CGRect(x: 14, y: 147, width: screenWidth - 28, height: 1))
        uiviewSecLine.backgroundColor = UIColor(red: 206/255, green: 203/255, blue: 203/255, alpha: 1)
        
        let uiviewThirdLine = UIView(frame: CGRect(x: 14, y: 243, width: screenWidth - 28, height: 1))
        uiviewThirdLine.backgroundColor = UIColor(red: 206/255, green: 203/255, blue: 203/255, alpha: 1)
        
        uiviewPeopleLocDetail.addSubview(uiviewFirstLine)
        uiviewPeopleLocDetail.addSubview(uiviewSecLine)
        uiviewPeopleLocDetail.addSubview(uiviewThirdLine)
        
        // draw title
        let imgIcon = UIImageView(frame: CGRect(x: 14, y: 13, width: 24, height: 24))
        imgIcon.image = #imageLiteral(resourceName: "mb_iconBeforeCurtLoc")
        let lblCurtLoc = UILabel(frame: CGRect(x: 50, y: 14.5, width: 300, height: 21))
        lblCurtLoc.text = "Current Location"
        lblCurtLoc.font = UIFont(name: "AvenirNext-Medium", size: 16)
        lblCurtLoc.textColor = UIColor.faeAppTimeTextBlackColor()
        uiviewPeopleLocDetail.addSubview(imgIcon)
        uiviewPeopleLocDetail.addSubview(lblCurtLoc)
        
        // draw labels and buttons
        let lblDis = UILabel(frame: CGRect(x: 15, y: 70, width: 150, height: 21))
        lblDis.text = "Maximum Distance"
        
        lblDisVal = UILabel(frame: CGRect(x: screenWidth - 95, y: 70, width: 80, height: 22))
        lblDisVal.text = "\(disVal) km"
        lblDisVal.textAlignment = .right
        
        let lblGender = UILabel(frame: CGRect(x: 15, y: 167, width: 150, height: 21))
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
        
        let lblAgeRange = UILabel(frame: CGRect(x: 15, y: 263, width: 150, height: 21))
        lblAgeRange.text = "Age Range"
        
        lblAgeVal = UILabel(frame: CGRect(x: screenWidth - 95, y: 263, width: 80, height: 22))
        lblAgeVal.text = "\(ageLBVal)-\(ageUBVal)"
        lblAgeVal.textAlignment = .right
        
        lblDis.textColor = UIColor.faeAppTimeTextBlackColor()
        lblGender.textColor = UIColor.faeAppTimeTextBlackColor()
        lblGenderBoth.textColor = UIColor.faeAppTimeTextBlackColor()
        lblGenderMale.textColor = UIColor.faeAppTimeTextBlackColor()
        lblGenderFemale.textColor = UIColor.faeAppTimeTextBlackColor()
        lblAgeRange.textColor = UIColor.faeAppTimeTextBlackColor()
        lblDisVal.textColor = UIColor.faeAppInactiveBtnGrayColor()
        lblAgeVal.textColor = UIColor.faeAppInactiveBtnGrayColor()
        
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
        
        uiviewPeopleLocDetail.addConstraintsWithFormat("V:|-203-[v0(21)]", options: [], views: lblGenderBoth)
        uiviewPeopleLocDetail.addConstraintsWithFormat("V:|-203-[v0(21)]", options: [], views: lblGenderFemale)
        uiviewPeopleLocDetail.addConstraintsWithFormat("V:|-203-[v0(21)]", options: [], views: lblGenderMale)
        uiviewPeopleLocDetail.addConstraintsWithFormat("V:|-199-[v0(29)]", options: [], views: btnGenderBoth)
        uiviewPeopleLocDetail.addConstraintsWithFormat("V:|-199-[v0(29)]", options: [], views: btnGenderFemale)
        uiviewPeopleLocDetail.addConstraintsWithFormat("V:|-199-[v0(29)]", options: [], views: btnGenderMale)
        
        uiviewPeopleLocDetail.addConstraintsWithFormat("H:|-27-[v0(29)]-10-[v1(36)]", options: [], views: btnGenderBoth, lblGenderBoth)
        let leftPadding = (screenWidth - 89) / 2
        uiviewPeopleLocDetail.addConstraintsWithFormat("H:|-\(leftPadding)-[v0(29)]-10-[v1(55)]", options: [], views: btnGenderFemale, lblGenderFemale)
        uiviewPeopleLocDetail.addConstraintsWithFormat("H:[v0(29)]-10-[v1(38)]-27-|", options: [], views: btnGenderMale, lblGenderMale)
        
        sliderDisFilter = UISlider(frame: CGRect(x: 28, y: 104, width: screenWidth - 56, height: 28))
        sliderDisFilter.setThumbImage(#imageLiteral(resourceName: "mb_emptyRedOval"), for: .normal)
        sliderDisFilter.maximumTrackTintColor = UIColor.faeAppNavBarBorderColor()
        sliderDisFilter.minimumTrackTintColor = UIColor.faeAppRedColor()
        sliderDisFilter.minimumValue = 0
        sliderDisFilter.maximumValue = 100
        sliderDisFilter.addTarget(self, action: #selector(self.changeDisRange(_:)), for: .valueChanged)
        
        sliderAgeFilter = TTRangeSlider(frame: CGRect(x: 28, y: 310, width: screenWidth - 56, height: 28))
        sliderAgeFilter.delegate = self
        sliderAgeFilter.tintColor = UIColor.faeAppNavBarBorderColor()
        sliderAgeFilter.tintColorBetweenHandles = UIColor.faeAppRedColor()
        sliderAgeFilter.handleImage = #imageLiteral(resourceName: "mb_emptyRedOval")
        sliderAgeFilter.handleDiameter = 22
        sliderAgeFilter.lineHeight = 2.4
        sliderAgeFilter.selectedHandleDiameterMultiplier = 1.0
        sliderAgeFilter.hideLabels = true
        sliderAgeFilter.minValue = 16
        sliderAgeFilter.maxValue = 55
        sliderAgeFilter.selectedMinimum = Float(ageLBVal)
        sliderAgeFilter.selectedMaximum = Float(ageUBVal)
        //        sliderAgeFilter.addTarget(self, action: #selector(self.changeAgeRange(_:)), for: .valueChanged)
        
        uiviewPeopleLocDetail.addSubview(sliderDisFilter)
        uiviewPeopleLocDetail.addSubview(sliderAgeFilter)
        
        // draw upArraw button
        let btnUpArrow = UIButton(frame: CGRect(x: (screenWidth-36)/2, y: 336, width: 36, height: 25))
        btnUpArrow.setImage(#imageLiteral(resourceName: "mb_btnUpArrow"), for: .normal)
        uiviewPeopleLocDetail.addSubview(btnUpArrow)
        btnUpArrow.addTarget(self, action: #selector(self.rollUpPeopleLocPage(_:)), for: .touchUpInside)
        
        self.view.bringSubview(toFront: uiviewNavBar)
    }
    
    func selectGender(_ sender: UIButton) {
        if sender.tag == 0 {
            seletedGender = "Both"
        } else if sender.tag == 1 {
            seletedGender = "Female"
        } else if sender.tag == 2 {
            seletedGender = "Male"
        }
        highlightGenderBtn()
    }
    
    fileprivate func highlightGenderBtn() {
        if seletedGender == "Both" {
            btnGenderBoth.setImage(#imageLiteral(resourceName: "mb_btnOvalSelected"), for: .normal)
            btnGenderFemale.setImage(#imageLiteral(resourceName: "mb_btnOvalUnselected"), for: .normal)
            btnGenderMale.setImage(#imageLiteral(resourceName: "mb_btnOvalUnselected"), for: .normal)
        } else if seletedGender == "Female" {
            btnGenderBoth.setImage(#imageLiteral(resourceName: "mb_btnOvalUnselected"), for: .normal)
            btnGenderFemale.setImage(#imageLiteral(resourceName: "mb_btnOvalSelected"), for: .normal)
            btnGenderMale.setImage(#imageLiteral(resourceName: "mb_btnOvalUnselected"), for: .normal)
        } else if seletedGender == "Male" {
            btnGenderBoth.setImage(#imageLiteral(resourceName: "mb_btnOvalUnselected"), for: .normal)
            btnGenderFemale.setImage(#imageLiteral(resourceName: "mb_btnOvalUnselected"), for: .normal)
            btnGenderMale.setImage(#imageLiteral(resourceName: "mb_btnOvalSelected"), for: .normal)
        }
    }

    func changeDisRange(_ sender: UISlider) {
        disVal = String(format: "%.1f", sender.value)
        lblDisVal.text = disVal + " km"
    }
    
    func rangeSlider(_ sender: TTRangeSlider, didChangeSelectedMinimumValue selectedMinimum: Float, andMaximumValue selectedMaximum: Float) {
        ageLBVal = Int(selectedMinimum)
        ageUBVal = Int(selectedMaximum)
        lblAgeVal.text = "\(ageLBVal)-\(ageUBVal)"
    }
}
