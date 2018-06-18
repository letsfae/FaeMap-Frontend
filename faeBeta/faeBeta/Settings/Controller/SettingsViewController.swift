//
//  ViewController.swift
//  FaeSettings
//
//  Created by 子不语 on 2017/8/28.
//  Copyright © 2017年 子不语. All rights reserved.
//

import UIKit

class SettingsViewController: UIViewController, UITableViewDelegate, UITableViewDataSource {
    // MARK: - Properties
    private var uiviewNavBar: FaeNavBar!
    private var uiviewInterval: UIView!
    private var uiviewVersion: UIView!
    private var lblVersion: UILabel!
    private var imgVersion: UIImageView!
    private let arrSettingsIcons: [UIImage] = [#imageLiteral(resourceName: "Settings_general"), #imageLiteral(resourceName: "Settings_maps"), #imageLiteral(resourceName: "Settings_privacy"), #imageLiteral(resourceName: "Settings_info"), #imageLiteral(resourceName: "Settings_account"), #imageLiteral(resourceName: "Settings_about"), #imageLiteral(resourceName: "Settings_contact"), #imageLiteral(resourceName: "Settings_spread"), #imageLiteral(resourceName: "Settings_logout")]
    private let arrSettingsText: [String] = ["General", "Maps & Display", "Privacy & Security", "My Information", "Fae Account", "About", "Contact & Support", "Spread Love", "Log Out"]
    
    private var uiviewLogout: UIView!
    private var lblLogout: UILabel!
    private var imgLogout: UIImageView!
    private var btnLogout: UIButton!
    private var btnClose: UIButton!
    
    private var uiviewBackground: UIView!
    private var btnBackground: UIButton!
    
    private var tblSettings: UITableView!
    
    // MARK: - Life cycle
    override func viewDidLoad() {
        super.viewDidLoad()
        setupFaeNav()
        setupTableView()
        setupVersionView()
        setupLogoutUIViewBackground()
        setupLogoutView()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        tblSettings.reloadRows(at: [IndexPath(row: 4, section: 0)], with: .none)
    }
    
    private func setupFaeNav() {
        view.backgroundColor = .white
        navigationController?.isNavigationBarHidden = true
        uiviewNavBar = FaeNavBar(frame: .zero)
        view.addSubview(uiviewNavBar)
        uiviewNavBar.lblTitle.text = "Settings"
        
        uiviewNavBar.loadBtnConstraints()
        uiviewNavBar.leftBtn.addTarget(self, action: #selector(actionBack(_:)), for: .touchUpInside)
        uiviewNavBar.rightBtn.isHidden = true
    }
    
    private func setupLogoutUIViewBackground() {
        btnBackground = UIButton(frame: view.frame)
        view.addSubview(btnBackground)
        
        uiviewBackground = UIView(frame: view.frame)
        view.addSubview(uiviewBackground)
        uiviewBackground.backgroundColor = UIColor._107105105_a50()
        uiviewBackground.addSubview(btnBackground)
        uiviewBackground.isHidden = true
    }
    
    private func setupTableView() {
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
    
    private func setupVersionView() {
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
    
    private func setupLogoutView() {
        uiviewLogout = UIView(frame: CGRect(x: 0, y: 200, w: 290, h: 222))
        uiviewLogout.center.x = screenWidth / 2
        uiviewLogout.backgroundColor = .white
        uiviewLogout.layer.cornerRadius = 21 * screenWidthFactor
        uiviewBackground.addSubview(uiviewLogout)
        
        lblLogout = UILabel(frame: CGRect(x: 0, y: 30, w: 120, h: 25))
        lblLogout.center.x = uiviewLogout.frame.width / 2
        uiviewLogout.addSubview(lblLogout)
        lblLogout.text = "See you soon!"
        lblLogout.textAlignment = .center
        lblLogout.textColor = UIColor._898989()
        lblLogout.font = UIFont(name: "AvenirNext-Medium", size: 18 * screenHeightFactor)
        
        imgLogout = UIImageView(frame: CGRect(x: 0, y: 78, w: 68, h: 60))
        imgLogout.center.x = uiviewLogout.frame.width / 2
        uiviewLogout.addSubview(imgLogout)
        imgLogout.image = #imageLiteral(resourceName: "Settings_bye")
        
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
    
    // MARK: - Button actions
    @objc private func actionBack(_ sender: UIButton) {
        navigationController?.popViewController(animated: true)
    }
    
    @objc private func logOut(_ sender: UIButton) {
        let logOut = FaeUser()
        logOut.logOut { [weak self] (_: Int?, _: Any?) in
            self?.jumpToWelcomeView(animated: true)
        }
    }
    
    private func jumpToWelcomeView(animated: Bool) {
        let welcomeVC = WelcomeViewController()
        navigationController?.pushViewController(welcomeVC, animated: animated)
        navigationController?.viewControllers = [welcomeVC]
        Key.shared.navOpenMode = .welcomeFirst
        Key.shared.is_Login = false
    }
    
    @objc private func showMainView(_ sender: UIButton) {
        uiviewBackground.isHidden = true
    }
    
    // MARK: - UITableViewDelegate
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
    
    // MARK: - UITableViewDataSource
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return arrSettingsIcons.count
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 63
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "settingsCell", for: indexPath as IndexPath) as! SettingsCell
        cell.imgIcon.image = arrSettingsIcons[indexPath.row]
        cell.lblSetting.text = arrSettingsText[indexPath.row]
        if indexPath.row == 4 {
            if !Key.shared.userEmailVerified && !Key.shared.userPhoneVerified {
                cell.imgExclamation.isHidden = false
            } else {
                cell.imgExclamation.isHidden = true
            }
        }
        return cell
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
}
