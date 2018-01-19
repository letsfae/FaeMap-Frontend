//
//  SettingsGeneral.swift
//  FaeSettings
//
//  Created by 子不语 on 2017/8/28.
//  Copyright © 2017年 子不语. All rights reserved.
//

// Vicky 09/17/17 这个页面我不知道在其他iphone型号有没有问题，在iPhone6上Scroll是scroll不下去的，你仔细注意一下“Background Location”以及“Email Subscription”的字体，老板给的是size 18,你用的是size 16。这个地方的实现我建议全部换成table来实现，而不是scrollView，(这样可能容易点儿？）分四个section，最后两个section可以用同一个cell，前两个section的"Measurement Units"和"Permissions"部分可以用sectionHeaderView来实现，具体自己查一下。只是个建议，自己衡量，只要UI和Sketch文件同样，下拉滑动时候没有问题，随便用什么实现都可以。 ps:这个问题在SetFaeMap.swift文件里也有出现，刚才发现是scrollview.isPagingEnabled = true这句话导致的，你可以试着在你自己手机上运行，将这句话分别给true和false看看有什么不同，我现在都给你改成false了，目前显示正常了。

import UIKit
import Contacts
import Photos

class SetGeneralViewController: UIViewController, UITableViewDelegate, UITableViewDataSource {
    var uiviewNavBar: FaeNavBar!
    var arrNames: [String: String] = ["00": "Measurement Units", "01": "Imperial (miles)", "02": "Metric (kilometers)", "10": "Permissions", "11": "Location", "12": "Camera", "13": "Microphone", "14": "Contacts", "15": "Push Notifications", "21": "Background Location", "31": "Email Subscription"]
    var tblGeneral: UITableView!
    var uiviewAlert: UIView!
    var lblAlert: UILabel!
    var btnAlertAction: UIButton!
    var btnClose: UIButton!
    var btnBackground: UIButton!
    var uiviewBackground: UIView!
    
    var dictPermissions: [String: Bool] = [:]
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Vicky 09/17/17 把所有ViewController的背景色置为白色，我这里给你添加了一个作为例子，其他文件也都全部加上，我不知道在你从Settings主页面点击General等滑动动画时候有没有一个transition的问题，是因为你所有view的backgroundColor都没有赋值。
        view.backgroundColor = .white
        // Vicky 09/17/17 End
        navigationController?.isNavigationBarHidden = true
        getPermissionStatus()
        loadNavBar()
        loadTableView()
        loadBackground()
        loaduiviewAlert()
        NotificationCenter.default.addObserver(self, selector: #selector(appBecomeActive), name: NSNotification.Name.UIApplicationWillEnterForeground, object: nil)
    }
    
    func loadNavBar() {
        uiviewNavBar = FaeNavBar(frame: .zero)
        view.addSubview(uiviewNavBar)
        uiviewNavBar.lblTitle.text = "General"
        uiviewNavBar.leftBtn.addTarget(self, action: #selector(actionGoBack(_:)), for: .touchUpInside)
        uiviewNavBar.loadBtnConstraints()
        uiviewNavBar.rightBtn.setImage(nil, for: .normal)
    }
    
    func loadTableView() {
        tblGeneral = UITableView(frame: CGRect(x: 0, y: 65 + device_offset_top, width: screenWidth, height: screenHeight - 65 - device_offset_top))
        view.addSubview(tblGeneral)
        tblGeneral.delegate = self
        tblGeneral.dataSource = self
        tblGeneral.register(GeneralTitleCell.self, forCellReuseIdentifier: "general_title")
        tblGeneral.register(GeneralSubTitleCell.self, forCellReuseIdentifier: "general_subtitle")
        tblGeneral.estimatedRowHeight = 47
        tblGeneral.rowHeight = UITableViewAutomaticDimension
    }
    
    func loadBackground() {
        btnBackground = UIButton(frame: view.frame)
        // btnBackground.addTarget(self, action: #selector(notouch(_:)), for: .touchUpInside)
        view.addSubview(btnBackground)
        
        uiviewBackground = UIView(frame: view.frame)
        view.addSubview(uiviewBackground)
        uiviewBackground.backgroundColor = UIColor._107105105_a50()
        uiviewBackground.addSubview(btnBackground)
    }
    
    func loaduiviewAlert() {
        //let alertWidth = 290 / 414 * screenWidth
        //let alertY = 200 / 736 * screenHeight
        //uiviewAlert = UIView(frame: CGRect(x: (screenWidth - alertWidth) / 2, y: alertY, width: alertWidth, height: 161))
        uiviewAlert = UIView(frame: CGRect(x: 0, y: 200, w: 290, h: 161))
        uiviewAlert.center.x = screenWidth / 2
        uiviewBackground.addSubview(uiviewAlert)
        uiviewAlert.backgroundColor = .white
        uiviewAlert.layer.cornerRadius = 21 * screenWidthFactor
        
        //let alertLabelWidth = 210 / 414 * screenWidth
        //let alertLabelY = 30 / 736 * screenHeight
        //lblAlert = UILabel(frame: CGRect(x: 41 / 414 * screenWidth, y: alertLabelY, width: alertLabelWidth, height: 60))
        lblAlert = UILabel(frame: CGRect(x: 0, y: 30, w: 260, h: 60))
        lblAlert.center.x = uiviewAlert.frame.width / 2
        uiviewAlert.addSubview(lblAlert)
        lblAlert.numberOfLines = 2
        lblAlert.text = "Oops, please verify your\nEmail to Subscribe!"
        lblAlert.textAlignment = .center
        lblAlert.textColor = UIColor._898989()
        lblAlert.font = UIFont(name: "AvenirNext-Medium", size: 18 * screenHeightFactor)
        
        //let alertActionWidth = 208 / 414 * screenWidth
        //let alertActionY = 102 / 736 * screenHeight
        //btnAlertAction = UIButton(frame: CGRect(x: 41 / 414 * screenWidth, y: alertActionY, width: alertActionWidth, height: 39))
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
    
//    func tableView(_ tableView: UITableView, viewForFooterInSection section: Int) -> UIView? {
//        let uiview = UIView()
//        uiview.backgroundColor = UIColor._241241241()
//        return uiview
//    }
//    
//    func tableView(_ tableView: UITableView, heightForFooterInSection section: Int) -> CGFloat {
//        return 5
//    }
    
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
                cell.switchIcon.isOn = Key.shared.emailSubscribed
                cell.uiviewBackground = self.uiviewBackground
            }
            return cell
        }
    }
    
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
                    FaeUser.shared.whereKey("measurement_units", value: "metric")
                    FaeUser.shared.setUserSettings { (status, message) in
                        guard status / 100 == 2 else { return }
                    }
                }
            }
        } else
        if section == 1 {
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
    
    @objc func switchEmailSubscription(_ sender: UISwitch) {
        if sender.isOn == true {
            uiviewBackground.isHidden = false
        } else {
            uiviewBackground.isHidden = true
        }
    }
    
    @objc func showMainView(_ sender: UIImageView) {
        uiviewBackground.isHidden = true
    }
    
    func showEmailAlert(_ sender: UIButton) {
        
    }
    
    @objc func actionGoBack(_ sender: UIButton) {
        navigationController?.popViewController(animated: true)
    }
    
    func getPermissionStatus() {
        if CLLocationManager.locationServicesEnabled() {
            switch CLLocationManager.authorizationStatus() {
            case .notDetermined, .restricted, .denied:
                dictPermissions["Location"] = false
                break
            case .authorizedAlways, .authorizedWhenInUse:
                dictPermissions["Location"] = true
            }
        }
        
        switch AVCaptureDevice.authorizationStatus(for: AVMediaType.video) {
        case .authorized:
            dictPermissions["Camera"] = true
            break
        case .denied, .notDetermined, .restricted:
            dictPermissions["Camera"] = false
        }
        
        switch AVAudioSession.sharedInstance().recordPermission() {
        case AVAudioSessionRecordPermission.granted:
            dictPermissions["Microphone"] = true
            break
        default:
            dictPermissions["Microphone"] = false
        }
        
        switch CNContactStore.authorizationStatus(for: .contacts) {
        case .authorized:
            dictPermissions["Contacts"] = true
            break
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
    
    @objc func appBecomeActive() {
        getPermissionStatus()
        tblGeneral.reloadData()
    }
    
}
