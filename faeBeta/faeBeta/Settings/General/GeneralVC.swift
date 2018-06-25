//
//  SettingsGeneral.swift
//  FaeSettings
//
//  Created by 子不语 on 2017/8/28.
//  Copyright © 2017年 子不语. All rights reserved.
//

import UIKit
import Contacts
import Photos

class SetGeneralViewController: UIViewController, UITableViewDelegate, UITableViewDataSource {
    // MARK: - Properties
    private var uiviewNavBar: FaeNavBar!
    private var arrNames: [String: String] = ["00": "Measurement Units", "01": "Imperial (miles)", "02": "Metric (kilometers)", "10": "Permissions", "11": "Location", "12": "Camera", "13": "Microphone", "14": "Contacts", "15": "Push Notifications", "21": "Background Location", "31": "Email Subscription"]
    private var tblGeneral: UITableView!
    private var uiviewAlert: UIView!
    private var lblAlert: UILabel!
    private var btnAlertAction: UIButton!
    private var btnClose: UIButton!
    private var btnBackground: UIButton!
    private var uiviewBackground: UIView!
    
    private var dictPermissions: [String: Bool] = [:]
    
    // MARK: - Life cycle
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .white
        navigationController?.isNavigationBarHidden = true
        getPermissionStatus()
        loadNavBar()
        loadTableView()
        loadBackground()
        loaduiviewAlert()
        NotificationCenter.default.addObserver(self, selector: #selector(appBecomeActive), name: NSNotification.Name.UIApplicationWillEnterForeground, object: nil)
    }
    
    // MARK: - Set up
    private func getPermissionStatus() {
        if CLLocationManager.locationServicesEnabled() {
            switch CLLocationManager.authorizationStatus() {
            case .notDetermined, .restricted, .denied:
                dictPermissions["Location"] = false
            case .authorizedAlways, .authorizedWhenInUse:
                dictPermissions["Location"] = true
            }
        }
        
        switch AVCaptureDevice.authorizationStatus(for: AVMediaType.video) {
        case .authorized:
            dictPermissions["Camera"] = true
        case .denied, .notDetermined, .restricted:
            dictPermissions["Camera"] = false
        }
        
        switch AVAudioSession.sharedInstance().recordPermission() {
        case AVAudioSessionRecordPermission.granted:
            dictPermissions["Microphone"] = true
        default:
            dictPermissions["Microphone"] = false
        }
        
        switch CNContactStore.authorizationStatus(for: .contacts) {
        case .authorized:
            dictPermissions["Contacts"] = true
        default:
            dictPermissions["Contacts"] = false
        }
        
        if UIApplication.shared.currentUserNotificationSettings?.types == UIUserNotificationType() {
            dictPermissions["Push Notifications"] = false
        } else {
            dictPermissions["Push Notifications"] = true
        }
        
        switch UIApplication.shared.backgroundRefreshStatus { // TODO:
        case .available:
            dictPermissions["Background Location"] = true
        default:
            dictPermissions["Background Location"] = false
        }
    }
    
    private func loadNavBar() {
        uiviewNavBar = FaeNavBar(frame: .zero)
        view.addSubview(uiviewNavBar)
        uiviewNavBar.lblTitle.text = "General"
        uiviewNavBar.leftBtn.addTarget(self, action: #selector(actionGoBack(_:)), for: .touchUpInside)
        uiviewNavBar.loadBtnConstraints()
        uiviewNavBar.rightBtn.setImage(nil, for: .normal)
    }
    
    private func loadTableView() {
        tblGeneral = UITableView(frame: CGRect(x: 0, y: 65 + device_offset_top, width: screenWidth, height: screenHeight - 65 - device_offset_top))
        view.addSubview(tblGeneral)
        tblGeneral.delegate = self
        tblGeneral.dataSource = self
        tblGeneral.register(GeneralTitleCell.self, forCellReuseIdentifier: "general_title")
        tblGeneral.register(GeneralSubTitleCell.self, forCellReuseIdentifier: "general_subtitle")
        tblGeneral.estimatedRowHeight = 47
        tblGeneral.rowHeight = UITableViewAutomaticDimension
    }
    
    private func loadBackground() {
        btnBackground = UIButton(frame: view.frame)
        view.addSubview(btnBackground)
        
        uiviewBackground = UIView(frame: view.frame)
        view.addSubview(uiviewBackground)
        uiviewBackground.backgroundColor = UIColor._107105105_a50()
        uiviewBackground.addSubview(btnBackground)
    }
    
    private func loaduiviewAlert() {
        uiviewAlert = UIView(frame: CGRect(x: 0, y: 200, w: 290, h: 161))
        uiviewAlert.center.x = screenWidth / 2
        uiviewBackground.addSubview(uiviewAlert)
        uiviewAlert.backgroundColor = .white
        uiviewAlert.layer.cornerRadius = 21 * screenWidthFactor
        
        lblAlert = UILabel(frame: CGRect(x: 0, y: 30, w: 260, h: 60))
        lblAlert.center.x = uiviewAlert.frame.width / 2
        uiviewAlert.addSubview(lblAlert)
        lblAlert.numberOfLines = 2
        lblAlert.text = "Oops, please verify your\nEmail to Subscribe!"
        lblAlert.textAlignment = .center
        lblAlert.textColor = UIColor._898989()
        lblAlert.font = UIFont(name: "AvenirNext-Medium", size: 18 * screenHeightFactor)
        
        btnAlertAction = UIButton(frame: CGRect(x: 0, y: 102, w: 208, h: 39))
        btnAlertAction.center.x = uiviewAlert.frame.width / 2
        uiviewAlert.addSubview(btnAlertAction)
        btnAlertAction.titleLabel?.textColor = .white
        btnAlertAction.titleLabel?.textAlignment = .center
        btnAlertAction.setTitle("Got it!", for: .normal)
        btnAlertAction.backgroundColor = UIColor._2499090()
        btnAlertAction.layer.cornerRadius = 19 * screenWidthFactor
        btnAlertAction.addTarget(self, action: #selector(showMainView(_:)), for: .touchUpInside)
        
        btnClose = UIButton(frame: CGRect(x: 0, y: 0, width: 47, height: 47))
        uiviewAlert.addSubview(btnClose)
        btnClose.setImage(#imageLiteral(resourceName: "Settings_delete"), for: .normal)
        btnClose.addTarget(self, action: #selector(showMainView(_:)), for: .touchUpInside)
        
        uiviewBackground.isHidden = true
    }
    
    // MARK: - Button & switch actions
    @objc private func switchEmailSubscription(_ sender: UISwitch) {
        // TODO
        if sender.isOn == true {
            if !Key.shared.userEmailVerified {
                uiviewBackground.isHidden = false
            }
        } else {
            uiviewBackground.isHidden = true
        }
    }
    
    @objc private func showMainView(_ sender: UIImageView) {
        uiviewBackground.isHidden = true
        let subscriptionCell = tblGeneral.cellForRow(at: IndexPath(row: 0, section: 3)) as! GeneralTitleCell
        subscriptionCell.switchIcon.isOn = false
    }
    
    private func showEmailAlert(_ sender: UIButton) {
        
    }
    
    @objc private func actionGoBack(_ sender: UIButton) {
        navigationController?.popViewController(animated: true)
    }
    
    @objc private func appBecomeActive() {
        getPermissionStatus()
        tblGeneral.reloadData()
    }
    
    // MARK: - UITableViewDataSource
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if section == 0 {
            return 3
        } else if section == 1 {
            return 6
        } else {
            return 1
        }
    }
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 4
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let sec = indexPath.section
        let row = indexPath.row
        
        // sec==0 is MeasureMent part
        if sec == 0 {
            // row==0 is title "Measurement Unit"
            if row == 0 {
                let cell = tableView.dequeueReusableCell(withIdentifier: "general_title", for: indexPath as IndexPath) as! GeneralTitleCell
                cell.lblName.text = arrNames["\(sec)\(row)"]
                cell.lblDes.isHidden = true
                cell.removeContraintsForDes()
                cell.switchIcon.isHidden = true
                cell.imgView.isHidden = true
                cell.topGrayLine.isHidden = true
                return cell
            }
            let cell = tableView.dequeueReusableCell(withIdentifier: "general_subtitle", for: indexPath as IndexPath) as! GeneralSubTitleCell
            if let name = arrNames["\(sec)\(row)"] {
                cell.updateName(name: name)
            }
            if row == 1 {
                cell.btnSelect.isSelected = Key.shared.measurementUnits == "imperial"
            } else {
                cell.btnSelect.isSelected = Key.shared.measurementUnits == "metric"
            }
            cell.lblDes.isHidden = true
            cell.removeContraintsForDes()
            cell.switchIcon.isHidden = true
            cell.btnSelect.isHidden = false
            cell.imgView.isHidden = true
            return cell
        } else if sec == 1 {
            // sec==1 is Permission part
            if row == 0 {
                let cell = tableView.dequeueReusableCell(withIdentifier: "general_title", for: indexPath as IndexPath) as! GeneralTitleCell
                cell.lblName.text = arrNames["\(sec)\(row)"]
                cell.lblDes.isHidden = true
                cell.removeContraintsForDes()
                cell.switchIcon.isHidden = true
                cell.imgView.isHidden = true
                cell.topGrayLine.isHidden = false
                return cell
            }
            let cell = tableView.dequeueReusableCell(withIdentifier: "general_subtitle", for: indexPath as IndexPath) as! GeneralSubTitleCell
            cell.lblName.text = arrNames["\(sec)\(row)"]
            cell.lblDes.isHidden = row != 5
            if row == 5 {
                cell.setContraintsForDes()
            } else {
                cell.removeContraintsForDes()
            }
            cell.switchIcon.isHidden = false
            cell.switchIcon.tag = 10 + row
            cell.switchIcon.isOn = dictPermissions[arrNames["\(sec)\(row)"]!]!
            cell.btnSelect.isHidden = true
            cell.imgView.isHidden = true
            return cell
        } else {
            let cell = tableView.dequeueReusableCell(withIdentifier: "general_title", for: indexPath as IndexPath) as! GeneralTitleCell
            cell.lblDes.isHidden = false
            cell.setContraintsForDes()
            cell.switchIcon.isHidden = false
            cell.switchIcon.tag = 31
            cell.imgView.isHidden = true
            cell.topGrayLine.isHidden = false
            if sec == 2 {
                cell.lblName.text = "Background Location"
                cell.lblDes.text = "Enable for faster Discovery Performance at different locations and more accurate Local Recommendations."
            } else {
                cell.lblName.text = "Email Subscription"
                cell.lblDes.text = "Enable to receive recommendations, local favorites, newsletters, and updates by email."
                if !Key.shared.userEmailVerified {
                    cell.switchIcon.isOn = false
                } else {
                    cell.switchIcon.isOn = Key.shared.emailSubscribed
                }
                cell.uiviewBackground = self.uiviewBackground
            }
            return cell
        }
    }
    
    // MARK: - UITableViewDelegate
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let section = indexPath.section
        let row = indexPath.row
        
        if section == 0 {
            // section == 0 exchange Imperial & Metric
            if row == 1 {
                let cell = tableView.cellForRow(at: indexPath) as! GeneralSubTitleCell
                if cell.btnSelect.isSelected == false {
                    cell.btnSelect.isSelected = true
                    let cell2 = tableView.cellForRow(at: IndexPath(row: 2, section: 0)) as! GeneralSubTitleCell
                    cell2.btnSelect.isSelected = false
                    Key.shared.measurementUnits = "imperial"
                    let boardPeopleVM = BoardPeopleViewModel()
                    boardPeopleVM.unit = " mi"
                    FaeUser.shared.whereKey("measurement_units", value: "imperial")
                    FaeUser.shared.setUserSettings { (status, message) in
                        guard status / 100 == 2 else { return }
                    }
                }
            } else if row == 2 {
                let cell = tableView.cellForRow(at: indexPath) as! GeneralSubTitleCell
                if cell.btnSelect.isSelected == false {
                    cell.btnSelect.isSelected = true
                    let cell2 = tableView.cellForRow(at: IndexPath(row: 1, section: 0)) as! GeneralSubTitleCell
                    cell2.btnSelect.isSelected = false
                    Key.shared.measurementUnits = "metric"
                    let boardPeopleVM = BoardPeopleViewModel()
                    boardPeopleVM.unit = " km"
                    FaeUser.shared.whereKey("measurement_units", value: "metric")
                    FaeUser.shared.setUserSettings { (status, message) in
                        guard status / 100 == 2 else { return }
                    }
                }
            }
        } else if section == 1 {
            switch row {
            case 1:
                break
            case 2:
                let status = AVCaptureDevice.authorizationStatus(for: .video)
                if status != .authorized {
                    AVCaptureDevice.requestAccess(for: .video, completionHandler: { (isOn) in
                        DispatchQueue.main.async {
                            let cell = tableView.cellForRow(at: indexPath) as! GeneralSubTitleCell
                            cell.switchIcon.isOn = AVCaptureDevice.authorizationStatus(for: .video) == .authorized
                        }
                    })
                } else {
                    UIApplication.shared.openURL(URL(string: UIApplicationOpenSettingsURLString)!)
                }
                break
            case 3:
                let status = AVCaptureDevice.authorizationStatus(for: .audio)
                if status != .authorized {
                    AVCaptureDevice.requestAccess(for: .audio, completionHandler: { (isOn) in
                        DispatchQueue.main.async {
                            let cell = tableView.cellForRow(at: indexPath) as! GeneralSubTitleCell
                            cell.switchIcon.isOn = AVCaptureDevice.authorizationStatus(for: .audio) == .authorized
                        }
                    })
                } else {
                    UIApplication.shared.openURL(URL(string: UIApplicationOpenSettingsURLString)!)
                }
                break
            case 4:
                break
            case 5:
                break
            default:
                break
            }
            if row > 0 && row != 2 && row != 3 {
                UIApplication.shared.openURL(URL(string: UIApplicationOpenSettingsURLString)!)
            }
        } else if section == 3 {
            let cell = tableView.cellForRow(at: indexPath as IndexPath) as! GeneralTitleCell
            uiviewBackground.isHidden = !cell.switchIcon.isOn
        }
    }
}
