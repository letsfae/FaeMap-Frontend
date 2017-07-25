//
//  MapFilterMenuMenu.swift
//  faeBeta
//
//  Created by Vicky on 7/25/17.
//  Copyright © 2017 fae. All rights reserved.
//

import UIKit

protocol MapFilterMenuDelegate: class {
    func autoReresh(isOn: Bool)
    func autoCyclePins(isOn: Bool)
    func showAvatars(isOn: Bool)
}

class MapFilterMenu: UIView {
    weak var delegate: MapFilterMenuDelegate?
    
    var uiviewMapOpt1: UIView!
    var uiviewMapOpt2: UIView!
    var imgDot1: UIImageView!
    var imgDot2: UIImageView!
    var btnDiscovery: UIButton!
    var lblDiscovery: UILabel!
    var lblRefresh: UILabel!
    var lblCyclePins: UILabel!
    var lblShowAvatars: UILabel!
    var switchRefresh: UISwitch!
    var switchCyclePins: UISwitch!
    var switchShowAvatars: UISwitch!
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setUpUI()
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    fileprivate func setUpUI() {
        backgroundColor = .white
        
        // draw three lines
        let firstLine = UIView(frame: CGRect(x: 0, y: 0, width: screenWidth, height: 1))
        firstLine.backgroundColor = UIColor.faeAppNavBarBorderColor()
        addSubview(firstLine)
        
        let secLine = UIView(frame: CGRect(x: 0, y: 66, width: screenWidth, height: 1))
        secLine.backgroundColor = UIColor.faeAppNavBarBorderColor()
        addSubview(secLine)
        
        let thirdLine = UIView(frame: CGRect(x: 0, y: 433, width: screenWidth, height: 1))
        thirdLine.backgroundColor = UIColor.faeAppNavBarBorderColor()
        addSubview(thirdLine)
        
        // draw two uiview of Map Options
        uiviewMapOpt1 = UIView(frame: CGRect(x: 0, y: 67, width: screenWidth, height: 366))
        uiviewMapOpt1.backgroundColor = .white
        addSubview(uiviewMapOpt1)
        
        uiviewMapOpt2 = UIView(frame: CGRect(x: screenWidth, y: 67, width: screenWidth, height: 366))
        uiviewMapOpt2.backgroundColor = .white
        addSubview(uiviewMapOpt2)
        
        // draw two dots
        imgDot1 = UIImageView(frame: CGRect(x: screenWidth/2 - 11.5, y: 448, width: 8, height: 8))
        imgDot1.backgroundColor = UIColor.faeAppRedColor()
        imgDot1.layer.cornerRadius = 4
        addSubview(imgDot1)
        
        imgDot2 = UIImageView(frame: CGRect(x: screenWidth/2 + 3.5, y: 448, width: 8, height: 8))
        imgDot2.backgroundColor = UIColor.faeAppInfoLabelGrayColor()
        imgDot2.layer.cornerRadius = 4
        addSubview(imgDot2)

        // draw downArraw button
        let imgDownArrow = UIImageView(frame: CGRect(x: (screenWidth-36)/2, y: 0, width: 36, height: 30))
        imgDownArrow.image = #imageLiteral(resourceName: "mapFilterMenuArrow")
        imgDownArrow.contentMode = .center
        addSubview(imgDownArrow)
        
        // draw fake button to hide map filter menu
        let btnHideMFMenu = UIButton(frame: CGRect(x: 0, y: 0, width: screenWidth, height: 66))
        btnHideMFMenu.addTarget(self, action: #selector(self.hideMapFilterMenuPage(_:)), for: .touchUpInside)
        addSubview(btnHideMFMenu)
        
        // draw "Map Options"
        let lblMapOptions = UILabel(frame: CGRect(x: (screenWidth-250)/2, y: 29, width: 250, height: 27))
        lblMapOptions.text = "Map Options"
        lblMapOptions.textAlignment = .center
        lblMapOptions.font = UIFont(name: "AvenirNext-Medium", size: 20)
        lblMapOptions.textColor = UIColor.faeAppInputTextGrayColor()
        addSubview(lblMapOptions)

        loadView1()
        loadView2()
        
        let swipeGes1 = UISwipeGestureRecognizer(target: self, action: #selector(self.swipeFromOpt1ToOpt2))
        swipeGes1.direction = .left
        uiviewMapOpt1.addGestureRecognizer(swipeGes1)
        
        let swipeGes2 = UISwipeGestureRecognizer(target: self, action: #selector(self.swipeFromOpt2ToOpt1))
        swipeGes2.direction = .right
        uiviewMapOpt2.addGestureRecognizer(swipeGes2)
    }
    
    func loadView1() {
        // draw "Map Type"
        let lblMapType = UILabel(frame: CGRect(x: 30, y: 15, width: 100, height: 25))
        lblMapType.text = "Map Type"
        lblMapType.font = UIFont(name: "AvenirNext-Medium", size: 18)
        lblMapType.textColor = UIColor.faeAppInputTextGrayColor()
        uiviewMapOpt1.addSubview(lblMapType)
        
        // draw Discovery button
        btnDiscovery = UIButton(frame: CGRect(x: (screenWidth-138)/2, y: 55, width: 138, height: 90))
        btnDiscovery.setImage(#imageLiteral(resourceName: "mapFilterDiscovery"), for: .normal)
        btnDiscovery.addTarget(self, action: #selector(self.switchBetweenDisAndSocial(_:)), for: .touchUpInside)
        uiviewMapOpt1.addSubview(btnDiscovery)
        
        // draw "Discovery" label
        lblDiscovery = UILabel(frame: CGRect(x: (screenWidth-100)/2, y: 152, width: 100, height: 19))
        lblDiscovery.text = "Discovery"
        lblDiscovery.textAlignment = .center
        lblDiscovery.font = UIFont(name: "AvenirNext-DemiBold", size: 14)
        lblDiscovery.textColor = UIColor.faeAppRedColor()
        uiviewMapOpt1.addSubview(lblDiscovery)
        
        // draw three labels - "Auto Refresh", "Auto Cycle Pins", "Show Avatars"
        lblRefresh = UILabel(frame: CGRect(x: 30, y: 196, width: 159, height: 25))
        lblRefresh.text = "Auto Refresh"
        lblRefresh.font = UIFont(name: "AvenirNext-Medium", size: 18)
        lblRefresh.textColor = UIColor.faeMapFilterActiveTxtColor()
        uiviewMapOpt1.addSubview(lblRefresh)
        
        lblCyclePins = UILabel(frame: CGRect(x: 30, y: 250, width: 150, height: 25))
        lblCyclePins.text = "Auto Cycle Pins"
        lblCyclePins.font = UIFont(name: "AvenirNext-Medium", size: 18)
        lblCyclePins.textColor = UIColor.faeAppInactiveBtnGrayColor()
        uiviewMapOpt1.addSubview(lblCyclePins)
        
        lblShowAvatars = UILabel(frame: CGRect(x: 30, y: 303, width: 150, height: 25))
        lblShowAvatars.text = "Show Avatars"
        lblShowAvatars.font = UIFont(name: "AvenirNext-Medium", size: 18)
        lblShowAvatars.textColor = UIColor.faeAppInactiveBtnGrayColor()
        uiviewMapOpt1.addSubview(lblShowAvatars)
        
        // draw three Switch buttons
        switchRefresh = UISwitch()
        switchRefresh.onTintColor = UIColor.faeAppRedColor()
        switchRefresh.transform = CGAffineTransform(scaleX: 39 / 51, y: 23 / 31)
        switchRefresh.addTarget(self, action: #selector(self.switchAutoRefresh(_:)), for: .valueChanged)
        switchRefresh.isOn = true
        uiviewMapOpt1.addSubview(switchRefresh)
        addConstraintsWithFormat("H:[v0(39)]-26-|", options: [], views: switchRefresh)
        addConstraintsWithFormat("V:|-193-[v0(23)]", options: [], views: switchRefresh)
        
        switchCyclePins = UISwitch()
        switchCyclePins.onTintColor = UIColor.faeAppRedColor()
        switchCyclePins.transform = CGAffineTransform(scaleX: 39 / 51, y: 23 / 31)
        switchCyclePins.addTarget(self, action: #selector(self.switchAutoCyclePins(_:)), for: .valueChanged)
        switchCyclePins.isOn = false
        uiviewMapOpt1.addSubview(switchCyclePins)
        addConstraintsWithFormat("H:[v0(39)]-26-|", options: [], views: switchCyclePins)
        addConstraintsWithFormat("V:|-247-[v0(23)]", options: [], views: switchCyclePins)
        
        switchShowAvatars = UISwitch()
        switchShowAvatars.onTintColor = UIColor.faeAppRedColor()
        switchShowAvatars.transform = CGAffineTransform(scaleX: 39 / 51, y: 23 / 31)
        switchShowAvatars.addTarget(self, action: #selector(self.switchShowAvatars(_:)), for: .valueChanged)
        switchShowAvatars.isOn = false
        uiviewMapOpt1.addSubview(switchShowAvatars)
        addConstraintsWithFormat("H:[v0(39)]-26-|", options: [], views: switchShowAvatars)
        addConstraintsWithFormat("V:|-300-[v0(23)]", options: [], views: switchShowAvatars)
    }
    
    func loadView2() {
    }
    
    func swipeFromOpt1ToOpt2(_ sender: UIGestureRecognizer) {
        UIView.animate(withDuration: 0.5, delay: 0, usingSpringWithDamping: 1, initialSpringVelocity: 0, options: .curveEaseOut, animations: {
            self.uiviewMapOpt1.frame.origin.x = -screenWidth
            self.uiviewMapOpt2.frame.origin.x = 0
            self.imgDot2.backgroundColor = UIColor.faeAppRedColor()
            self.imgDot1.backgroundColor = UIColor.faeAppInfoLabelGrayColor()
        }, completion: { _ in
        })
        
    }
    
    func swipeFromOpt2ToOpt1(_ sender: UIGestureRecognizer) {
        UIView.animate(withDuration: 0.5, delay: 0, usingSpringWithDamping: 1, initialSpringVelocity: 0, options: .curveEaseOut, animations: {
            self.uiviewMapOpt1.frame.origin.x = 0
            self.uiviewMapOpt2.frame.origin.x = screenWidth
            self.imgDot1.backgroundColor = UIColor.faeAppRedColor()
            self.imgDot2.backgroundColor = UIColor.faeAppInfoLabelGrayColor()
        }, completion: { _ in
        })
    }
    
    func hideMapFilterMenuPage(_ sender: Any?) {
        print("hideMapFilterMenuPage")
    }
    
    func switchBetweenDisAndSocial(_ sender: UIButton) {
    }
    
    func switchAutoRefresh(_ sender: UISwitch) {
        if switchRefresh.isOn {
            lblRefresh.textColor = UIColor.faeMapFilterActiveTxtColor()
            delegate?.autoReresh(isOn: true)
        } else {
            lblRefresh.textColor = UIColor.faeAppInactiveBtnGrayColor()
            delegate?.autoReresh(isOn: false)
        }
    }
    
    func switchAutoCyclePins(_ sender: UISwitch) {
        if switchCyclePins.isOn {
            lblCyclePins.textColor = UIColor.faeMapFilterActiveTxtColor()
            delegate?.autoCyclePins(isOn: true)
        } else {
            lblCyclePins.textColor = UIColor.faeAppInactiveBtnGrayColor()
            delegate?.autoCyclePins(isOn: false)
        }
    }
    
    func switchShowAvatars(_ sender: UISwitch) {
        if switchShowAvatars.isOn {
            lblShowAvatars.textColor = UIColor.faeMapFilterActiveTxtColor()
            delegate?.showAvatars(isOn: true)
        } else {
            lblShowAvatars.textColor = UIColor.faeAppInactiveBtnGrayColor()
            delegate?.showAvatars(isOn: false)
        }
    }
}
