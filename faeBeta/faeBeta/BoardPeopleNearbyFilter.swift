//
//  BoardPeopleNearbyFilter.swift
//  faeBeta
//
//  Created by Faevorite 2 on 2018-06-18.
//  Copyright © 2018 fae. All rights reserved.
//

import UIKit
import TTRangeSlider

protocol BoardPeopleNearbyFilterDelegate: class {
    func filterPeople()
}

class BoardPeopleNearbyFilter: UIView, TTRangeSliderDelegate {
    // MARK: - Properties
    // Distance
    private var lblDisVal: UILabel!
    private var sliderDisFilter: UISlider!
    private var uiviewDisRedLine: UIView!
    private var factor = 0.621371
    var valDis: Double = 23.0
    
    var unit = Key.shared.measurementUnits == "imperial" ? " mi" : " km" {
        didSet {
            if oldValue != unit {
                updateUIAfterMeasurementUnitChange()
            }
        }
    }
    
    // Gender
    private var btnGenderBoth: UIButton!
    private var btnGenderFemale: UIButton!
    private var btnGenderMale: UIButton!
    private var imgGenderBoth: UIImageView!
    private var imgGenderFemale: UIImageView!
    private var imgGenderMale: UIImageView!
    var valGender: String = "Both"
    
    // Age
    private var lblAgeVal: UILabel!
    private var sliderAgeFilter: TTRangeSlider!
    private var uiviewAgeRedLine: UIView!
    var valAgeLB: Int = 18
    var valAgeUB: Int = 33
    var valAllAge: String = ""
    
    weak var delegate: BoardPeopleNearbyFilterDelegate!
    
    override init(frame: CGRect = CGRect.zero) {
        super.init(frame: CGRect(x: 0, y: -203, width: screenWidth, height: 316))
        backgroundColor = .white
        isHidden = true
        setupUI()
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
    
    private func setupUI() {
        let swipeGesture = UISwipeGestureRecognizer(target: self, action: #selector(rollUpSelf(_:)))
        addGestureRecognizer(swipeGesture)
        swipeGesture.direction = .up
        
        let uiviewLowerLine = UIView(frame: CGRect(x: 0, y: 315, width: screenWidth, height: 1))
        uiviewLowerLine.backgroundColor = UIColor._200199204()
        addSubview(uiviewLowerLine)
        
        // draw three lines
        let uiviewFirstLine = UIView(frame: CGRect(x: 14, y: 0, width: screenWidth - 28, height: 1))
        uiviewFirstLine.backgroundColor = UIColor._206203203()
        
        let uiviewSecLine = UIView(frame: CGRect(x: 14, y: 99, width: screenWidth - 28, height: 1))
        uiviewSecLine.backgroundColor = UIColor._206203203()
        
        let uiviewThirdLine = UIView(frame: CGRect(x: 14, y: 195, width: screenWidth - 28, height: 1))
        uiviewThirdLine.backgroundColor = UIColor._206203203()
        
        addSubview(uiviewFirstLine)
        addSubview(uiviewSecLine)
        addSubview(uiviewThirdLine)
        
        // draw labels and buttons
        let lblDis = UILabel(frame: CGRect(x: 15, y: 22, width: 150, height: 21))
        lblDis.text = "Maximum Distance"
        
        lblDisVal = UILabel(frame: CGRect(x: screenWidth - 95, y: 22, width: 80, height: 22))
        lblDisVal.text = String(format: "%.1f", valDis) + unit
        lblDisVal.textAlignment = .right
        
        let lblGender = UILabel(frame: CGRect(x: 15, y: 119, width: 150, height: 21))
        lblGender.text = "Gender"
        
        let lblGenderBoth = UILabel()
        lblGenderBoth.text = "Both"
        let lblGenderFemale = UILabel()
        lblGenderFemale.text = "Female"
        let lblGenderMale = UILabel()
        lblGenderMale.text = "Male"
        
        let width = screenWidth / 3
        btnGenderBoth = UIButton(frame: CGRect(x: 0, y: 146, width: width, height: 39))
        btnGenderBoth.tag = 0
        
        btnGenderFemale = UIButton(frame: CGRect(x: width, y: 146, width: width, height: 39))
        btnGenderFemale.tag = 1
        
        btnGenderMale = UIButton(frame: CGRect(x: width * 2, y: 146, width: width, height: 39))
        btnGenderMale.tag = 2
        
        imgGenderBoth = UIImageView()
        imgGenderFemale = UIImageView()
        imgGenderMale = UIImageView()
        
        highlightSelectedGender()
        
        btnGenderBoth.addTarget(self, action: #selector(self.selectGender(_:)), for: .touchUpInside)
        btnGenderFemale.addTarget(self, action: #selector(self.selectGender(_:)), for: .touchUpInside)
        btnGenderMale.addTarget(self, action: #selector(self.selectGender(_:)), for: .touchUpInside)
        
        let lblAgeRange = UILabel(frame: CGRect(x: 15, y: 215, width: 150, height: 21))
        lblAgeRange.text = "Age Range"
        
        lblAgeVal = UILabel(frame: CGRect(x: screenWidth - 95, y: 215, width: 80, height: 22))
        lblAgeVal.text = "\(valAgeLB)-\(valAgeUB)"
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
        
        addSubview(lblDis)
        addSubview(lblGender)
        addSubview(lblGenderBoth)
        addSubview(lblGenderFemale)
        addSubview(lblGenderMale)
        addSubview(lblAgeRange)
        addSubview(lblDisVal)
        addSubview(lblAgeVal)
        addSubview(imgGenderBoth)
        addSubview(imgGenderMale)
        addSubview(imgGenderFemale)
        addSubview(btnGenderBoth)
        addSubview(btnGenderMale)
        addSubview(btnGenderFemale)
        
        addConstraintsWithFormat("V:|-155-[v0(21)]", options: [], views: lblGenderBoth)
        addConstraintsWithFormat("V:|-155-[v0(21)]", options: [], views: lblGenderFemale)
        addConstraintsWithFormat("V:|-155-[v0(21)]", options: [], views: lblGenderMale)
        addConstraintsWithFormat("V:|-156-[v0(19)]", options: [], views: imgGenderBoth)
        addConstraintsWithFormat("V:|-156-[v0(19)]", options: [], views: imgGenderFemale)
        addConstraintsWithFormat("V:|-156-[v0(19)]", options: [], views: imgGenderMale)
        
        addConstraintsWithFormat("H:|-32-[v0(19)]-15-[v1(36)]", options: [], views: imgGenderBoth, lblGenderBoth)
        let leftPadding = (screenWidth - 89) / 2
        addConstraintsWithFormat("H:|-\(leftPadding)-[v0(19)]-15-[v1(55)]", options: [], views: imgGenderFemale, lblGenderFemale)
        addConstraintsWithFormat("H:[v0(19)]-15-[v1(38)]-32-|", options: [], views: imgGenderMale, lblGenderMale)
        
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
        sliderAgeFilter.selectedMinimum = Float(valAgeLB)
        sliderAgeFilter.selectedMaximum = Float(valAgeUB)
        
        addSubview(sliderDisFilter)
        addSubview(sliderAgeFilter)
        
        // draw upArraw button
        let btnUpArrow = UIButton(frame: CGRect(x: (screenWidth-36)/2, y: 288, width: 36, height: 25))
        btnUpArrow.setImage(#imageLiteral(resourceName: "mapFilterArrow"), for: .normal)
        addSubview(btnUpArrow)
        btnUpArrow.addTarget(self, action: #selector(self.rollUpSelf(_:)), for: .touchUpInside)
        
        // set initial value for distance
        sliderDisFilter.setValue(Float(valDis), animated: false)
    }
    
    // MARK: - Button actions
    @objc func rollUpSelf(_ sender: Any?) {
        delegate?.filterPeople()
    }
    
    @objc func selectGender(_ sender: UIButton) {
        if sender.tag == 0 {
            valGender = "Both"
        } else if sender.tag == 1 {
            valGender = "Female"
        } else if sender.tag == 2 {
            valGender = "Male"
        }
        highlightSelectedGender()
    }
    
    private func highlightSelectedGender() {
        if valGender == "Both" {
            imgGenderBoth.image = #imageLiteral(resourceName: "mb_btnOvalSelected")
            imgGenderFemale.image = #imageLiteral(resourceName: "mb_btnOvalUnselected")
            imgGenderMale.image = #imageLiteral(resourceName: "mb_btnOvalUnselected")
        } else if valGender == "Female" {
            imgGenderBoth.image = #imageLiteral(resourceName: "mb_btnOvalUnselected")
            imgGenderFemale.image = #imageLiteral(resourceName: "mb_btnOvalSelected")
            imgGenderMale.image = #imageLiteral(resourceName: "mb_btnOvalUnselected")
        } else if valGender == "Male" {
            imgGenderBoth.image = #imageLiteral(resourceName: "mb_btnOvalUnselected")
            imgGenderFemale.image = #imageLiteral(resourceName: "mb_btnOvalUnselected")
            imgGenderMale.image = #imageLiteral(resourceName: "mb_btnOvalSelected")
        }
    }
    
    @objc func changeDisRange(_ sender: UISlider) {
        valDis = Double(sender.value)
        lblDisVal.text = String(format: "%.1f", valDis) + unit
    }
    
    // MARK: - Animations
    func animateHide() {
        UIView.animate(withDuration: 0.5, delay: 0, usingSpringWithDamping: 1, initialSpringVelocity: 0, options: .curveEaseOut, animations: {
            self.frame.origin.y = -203
        }, completion: { _ in
            self.isHidden = true
        })
    }
    
    func animateShow() {
        isHidden = false
        UIView.animate(withDuration: 0.5, delay: 0, usingSpringWithDamping: 1, initialSpringVelocity: 0, options: .curveEaseOut, animations: {
            self.frame.origin.y = 113 + device_offset_top
        }, completion: nil)
    }
    
    // MARK: - TTRangeSliderDelegate
    func rangeSlider(_ sender: TTRangeSlider, didChangeSelectedMinimumValue selectedMinimum: Float, andMaximumValue selectedMaximum: Float) {
        valAgeLB = Int(selectedMinimum)
        valAgeUB = Int(selectedMaximum)
        if valAgeLB == 18 && valAgeUB == 50 {
            valAllAge = ""
            lblAgeVal.text = valAllAge
        } else if valAgeUB == 50 {
            lblAgeVal.text = "\(valAgeLB)-50+"
        } else {
            lblAgeVal.text = "\(valAgeLB)-\(valAgeUB)"
        }
    }
    
    // After select "imperial" or "metric" in Settings page
    private func updateUIAfterMeasurementUnitChange() {
        lblDisVal.text = String(format: "%.1f", valDis) + unit
        sliderDisFilter.setValue(Float(valDis), animated: false)
    }
}
