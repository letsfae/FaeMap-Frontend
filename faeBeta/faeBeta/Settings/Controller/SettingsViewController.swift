//
//  ViewController.swift
//  FaeSettings
//
//  Created by 子不语 on 2017/8/28.
//  Copyright © 2017年 子不语. All rights reserved.
//

import UIKit

class SettingsViewController: UIViewController, UITableViewDelegate, UITableViewDataSource {
    
    var uiviewNavBar: FaeNavBar!
    var uiviewInterval: UIView!
    var uiviewVersion: UIView!
    var lblVersion: UILabel!
    var imgVersion: UIImageView!
    let arrSettingsIcons: [UIImage] = [#imageLiteral(resourceName: "Settings_general"), #imageLiteral(resourceName: "Settings_maps"), #imageLiteral(resourceName: "Settings_privacy"), #imageLiteral(resourceName: "Settings_info"), #imageLiteral(resourceName: "Settings_account"), #imageLiteral(resourceName: "Settings_about"), #imageLiteral(resourceName: "Settings_contact"), #imageLiteral(resourceName: "Settings_spread"), #imageLiteral(resourceName: "Settings_logout")]
    // Vicky 09/17/17  注意是"Maps & Display", "Privacy & Security", "Contact & Support"有空格的。这些细节都注意一下，麻烦改一下
    let arrSettingsText: [String] = ["General", "Maps & Display", "Privacy & Security", "My Information", "Fae Account", "About", "Contact & Support", "Spread Love", "Log Out"]
    // Vicky 09/17/17 End
    
    var uiviewLogout: UIView!
    var lblLogout: UILabel!
    var imgLogout: UIImageView!
    var btnLogout: UIButton!
    var btnClose: UIButton!
    
    var uiviewBackground: UIView!
    var btnBackground: UIButton!
    
    var tblSettings: UITableView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupFaeNav()
        setupTableView()
        setupVersionView()
        setupLogoutUIViewBackground()
        setupLogoutView()
    }
    
    @objc func actionBack(_ sender: UIButton) {
        navigationController?.popViewController(animated: true)
    }
    
    func setupFaeNav() {
        view.backgroundColor = .white
        navigationController?.isNavigationBarHidden = true
        uiviewNavBar = FaeNavBar(frame: .zero)
        view.addSubview(uiviewNavBar)
        uiviewNavBar.lblTitle.text = "Settings"
        
        uiviewNavBar.loadBtnConstraints()
        uiviewNavBar.leftBtn.addTarget(self, action: #selector(actionBack(_:)), for: .touchUpInside)
        uiviewNavBar.rightBtn.isHidden = true
    }
    
    func setupLogoutUIViewBackground() {
        btnBackground = UIButton(frame: view.frame)
        view.addSubview(btnBackground)
        
        uiviewBackground = UIView(frame: view.frame)
        view.addSubview(uiviewBackground)
        uiviewBackground.backgroundColor = UIColor._107105105_a50()
        uiviewBackground.addSubview(btnBackground)
        uiviewBackground.isHidden = true
    }
    
    fileprivate func setupTableView() {
        tblSettings = UITableView()
        view.addSubview(tblSettings)
        tblSettings.frame = CGRect(x: 0, y: uiviewNavBar.bounds.height, width: screenWidth, height: screenHeight - uiviewNavBar.bounds.height)
        tblSettings.separatorStyle = .none
        tblSettings.delegate = self
        tblSettings.dataSource = self
        tblSettings.register(SettingsCell.self, forCellReuseIdentifier: "settingsCell")
        var inset = tblSettings.contentInset
        inset.top = 7
        tblSettings.contentInset = inset
    }
    
    func setupVersionView() {
        uiviewVersion = UIView()
        tblSettings.addSubview(uiviewVersion)
        uiviewVersion.center.x = screenWidth / 2
        tblSettings.addConstraintsWithFormat("H:|-0-[v0]-0-|", options: [], views: uiviewVersion)
        tblSettings.addConstraintsWithFormat("V:|-(-40)-[v0(20)]", options: [], views: uiviewVersion)
        imgVersion = UIImageView()
        imgVersion.image = #imageLiteral(resourceName: "settings_version")
        uiviewVersion.addSubview(imgVersion)
        lblVersion = UILabel()
        uiviewVersion.addSubview(lblVersion)
        //lblVersion.textAlignment = .center
        lblVersion.text = "Fae Map Version 0.5"
        lblVersion.font = UIFont(name: "AvenirNext-Medium", size: 13)
        lblVersion.textColor = UIColor._138138138()
        uiviewVersion.addConstraintsWithFormat("H:|-\(136 * screenWidth / 414)-[v0(12)]-9-[v1(122)]", options: [], views: imgVersion, lblVersion)
        uiviewVersion.addConstraintsWithFormat("V:[v0(10)]-4-|", options: [], views: imgVersion)
        uiviewVersion.addConstraintsWithFormat("V:[v0(18)]-0-|", options: [], views: lblVersion)
    }
    
    func setupLogoutView() {
        //let uiviewLogoutWidth = 290/414*screenWidth
        //uiviewLogout = UIView(frame: CGRect(x: (screenWidth-uiviewLogoutWidth)/2, y: 200/736*screenHeight, width: 290/414*screenWidth, height: 222))
        uiviewLogout = UIView(frame: CGRect(x: 0, y: 200, w: 290, h: 222))
        uiviewLogout.center.x = screenWidth / 2
        uiviewLogout.backgroundColor = .white
        uiviewLogout.layer.cornerRadius = 21 * screenWidthFactor
        uiviewBackground.addSubview(uiviewLogout)
        
        //lblLogout = UILabel(frame: CGRect(x: 85/414*screenWidth, y: 30/736*screenHeight, width: 120, height: 25))
        lblLogout = UILabel(frame: CGRect(x: 0, y: 30, w: 120, h: 25))
        lblLogout.center.x = uiviewLogout.frame.width / 2
        uiviewLogout.addSubview(lblLogout)
        lblLogout.text = "See you soon!"
        lblLogout.textAlignment = .center
        lblLogout.textColor = UIColor._898989()
        lblLogout.font = UIFont(name: "AvenirNext-Medium", size: 18 * screenHeightFactor)
        
        //imgviewLogout = UIImageView(frame: CGRect(x: 111/414*screenWidth, y: 78/736*screenHeight, width: 68, height: 60))
        imgLogout = UIImageView(frame: CGRect(x: 0, y: 78, w: 68, h: 60))
        imgLogout.center.x = uiviewLogout.frame.width / 2
        uiviewLogout.addSubview(imgLogout)
        imgLogout.image = #imageLiteral(resourceName: "Settings_bye")
        
        //btnLogout = UIButton(frame: CGRect(x: 40/414*screenWidth, y: 165/736*screenHeight, width: 209/414*screenWidth, height: 39))
        btnLogout = UIButton(frame: CGRect(x: 0, y: 165, w: 209, h: 39))
        btnLogout.center.x = uiviewLogout.frame.width / 2
        uiviewLogout.addSubview(btnLogout)
        btnLogout.titleLabel?.textColor = .white
        btnLogout.titleLabel?.textAlignment = .center
        btnLogout.setTitle("Log Out", for: .normal)
        btnLogout.titleLabel?.font = UIFont(name: "AvenirNext-Bold", size: 18 * screenHeightFactor)
        btnLogout.backgroundColor = UIColor._2499090()
        btnLogout.layer.cornerRadius = 19 * screenWidthFactor
        btnLogout.addTarget(self, action: #selector(logOut(_:)), for: .touchUpInside)
        
        btnClose = UIButton(frame: CGRect(x: 0, y: 0, width: 47, height: 47))
        uiviewLogout.addSubview(btnClose)
        btnClose.setImage(#imageLiteral(resourceName: "Settings_delete"), for: .normal)
        btnClose.addTarget(self, action: #selector(showMainView(_:)), for: .touchUpInside)
        
    }
    
    @objc func logOut(_ sender: UIButton) {
        let logOut = FaeUser()
        logOut.logOut { (_: Int?, _: Any?) in
            self.jumpToWelcomeView(animated: true)
        }
    }
    
    func jumpToWelcomeView(animated: Bool) {
        /*if Key.shared.navOpenMode == .welcomeFirst {
            navigationController?.popToRootViewController(animated: animated)
        } else {*/
        let welcomeVC = WelcomeViewController()
        navigationController?.pushViewController(welcomeVC, animated: animated)
        navigationController?.viewControllers = [welcomeVC]
        Key.shared.navOpenMode = .welcomeFirst
        Key.shared.is_Login = false
        //}
    }
    
    @objc func showMainView(_ sender: UIButton) {
        uiviewBackground.isHidden = true
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        switch indexPath.row {
        case 0:
            navigationController?.pushViewController(SetGeneralViewController(), animated: true)
        case 1:
            navigationController?.pushViewController(SetMapsViewController(), animated: true)
        case 2:
            navigationController?.pushViewController(SetPrivacyViewController(), animated: true)
        case 3:
            let vc = SetInfoViewController()
            vc.enterMode = .settings
            navigationController?.pushViewController(vc, animated: true)
        case 4:
            navigationController?.pushViewController(SetAccountViewController(), animated: true)
        case 5:
            navigationController?.pushViewController(SetAboutViewController(), animated: true)
        case 6:
            navigationController?.pushViewController(SetContactViewController(), animated: true)
        case 7:
            navigationController?.pushViewController(SetSpreadViewController(), animated: true)
        case 8:
            uiviewBackground.isHidden = false
        default: break
        }
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return arrSettingsIcons.count
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 63
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        // Vicky 09/17/17 按照Sketch文件，Log Out那栏右边的箭头需要隐藏？点击后应该是直接退出，所以不需要箭头
        let cell = tableView.dequeueReusableCell(withIdentifier: "settingsCell", for: indexPath as IndexPath) as! SettingsCell
        cell.imgIcon.image = arrSettingsIcons[indexPath.row]
        cell.lblSetting.text = arrSettingsText[indexPath.row]
        return cell
    }
    
    //    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
    //        if indexPath.row < settingsIcons.count {
    //            let vc = settingsController[indexPath.row]
    //            self.navigationController?.pushViewController(vc, animated: true)
    //            tableView.deselectRow(at: indexPath, animated: true)
    //        }
    //
    //    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
}
