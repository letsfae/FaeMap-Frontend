//
//  SetNamecardViewController.swift
//  FaeSettings
//
//  Created by 子不语 on 2017/9/17.
//  Copyright © 2017年 子不语. All rights reserved.
//

import UIKit
import SwiftyJSON

enum SetInfoEnterMode {
    case nameCard
    case settings
}

class SetInfoNamecard: UIViewController, UINavigationControllerDelegate, UITableViewDelegate, UITableViewDataSource, PassDisplayNameBackDelegate, PassShortIntroBackDelegate, UIImagePickerControllerDelegate, ChooseAvatarDelegate {

    // MARK: - Properties
    private var faeNavBar: FaeNavBar!
    var uiviewNameCard: FMNameCardView!
    private var uiviewInterval: UIView!
    private var tblNameCard: UITableView!
    private var arrInfo: [String] = ["Display Name", "Short Info", "Change Profile Picture", "Change Cover Photo"]
    private var strDisplayName: String?
    private var strShortIntro: String?
    var enterMode: SetInfoEnterMode!
    
    var activityIndicator: UIActivityIndicatorView!
    private var isProfilePhoto: Bool = true
    
    // MARK: - Life cycle
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .white
        loadContent()
        loadActivityIndicator()
        updateInfo()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        uiviewNameCard.userId = Key.shared.user_id // refresh user namecard
    }
    
    // MARK: - Set up
    private func loadContent() {
        faeNavBar = FaeNavBar()
        view.addSubview(faeNavBar)
        faeNavBar.lblTitle.text = "Edit NameCard"
        faeNavBar.loadBtnConstraints()
        faeNavBar.rightBtn.setImage(nil, for: .normal)
        faeNavBar.leftBtn.addTarget(self, action: #selector(actionGoBack(_:)), for: .touchUpInside)
        
        uiviewNameCard = FMNameCardView()
        uiviewNameCard.showFullNameCard()
        uiviewNameCard.frame.origin.y = 65 + 11 + device_offset_top * screenHeightFactor
        uiviewNameCard.boolSmallSize = true
        uiviewNameCard.userId = Key.shared.user_id
        uiviewNameCard.btnOptions.removeFromSuperview()
        view.addSubview(uiviewNameCard)
        
        uiviewInterval = UIView(frame: CGRect(x: 0, y: 390, w: 414, h: 5 / screenHeightFactor))
        uiviewInterval.frame.origin.y += device_offset_top
        view.addSubview(uiviewInterval)
        uiviewInterval.backgroundColor = UIColor._241241241()
        
        tblNameCard = UITableView(frame: CGRect(x: 0, y: 390 * screenHeightFactor + 5 + device_offset_top, width: screenWidth, height: screenHeight - device_offset_top - 5 - 390 * screenHeightFactor))
        view.addSubview(tblNameCard)
        tblNameCard.delegate = self
        tblNameCard.dataSource = self
        tblNameCard.register(SetAccountCell.self, forCellReuseIdentifier: "cell")
        tblNameCard.separatorStyle = .none
        tblNameCard.alwaysBounceVertical = false
    }
    
    private func loadActivityIndicator() {
        activityIndicator = UIActivityIndicatorView()
        activityIndicator.activityIndicatorViewStyle = .whiteLarge
        activityIndicator.center = view.center
        activityIndicator.hidesWhenStopped = true
        activityIndicator.color = UIColor._2499090()
        view.addSubview(activityIndicator)
        view.bringSubview(toFront: activityIndicator)
    }
    
    private func updateInfo() {
        strDisplayName = Key.shared.nickname
        strShortIntro = Key.shared.introduction
        getFromURL("users/name_card", parameter: nil, authentication: Key.shared.headerAuthentication()) { [unowned self] status, result in
            guard status / 100 == 2 else { return }
            let rsltJSON = JSON(result!)
            self.strDisplayName = rsltJSON["nick_name"].stringValue
            self.strShortIntro = rsltJSON["short_intro"].stringValue
            self.tblNameCard.reloadData()
        }
    }
    
    // MARK: - Button action
    @objc private func actionGoBack(_ sender: UIButton) {
        if enterMode == .nameCard {
            dismiss(animated: true)
        } else {
            navigationController?.popViewController(animated: true)
        }
    }
    
    // MARK: - UITableViewDataSource
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return arrInfo.count
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 60
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "cell", for: indexPath as IndexPath) as! SetAccountCell
        cell.lblTitle.text = arrInfo[indexPath.row]
        if indexPath.row == 0 {
            cell.lblContent.text = strDisplayName
        }
        if indexPath.row == 1 {
            cell.lblContent.text = strShortIntro
        }
        return cell
    }
    
    // MARK: - UITableViewDelegate
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        switch indexPath.row {
        case 0:
            let vc = SetDisplayName()
            if let str = strDisplayName {
                vc.strFieldText = str
            }
            vc.delegate = self
            if let nav = navigationController {
                nav.pushViewController(vc, animated: true)
            } else {
                present(vc, animated: true)
            }
        case 1:
            let vc = SetShortIntro()
            if let str = strShortIntro {
                vc.strFieldText = str
            }
            vc.delegate = self
            if let nav = navigationController {
                nav.pushViewController(vc, animated: true)
            } else {
                present(vc, animated: true)
            }
        case 2:
            isProfilePhoto = true
            SetAvatar.addUserImage(vc: self, type: "setInfoNamecard")
        case 3:
            isProfilePhoto = false
            SetAvatar.addUserImage(vc: self, type: "setInfoNamecard")
        default: break
        }
    }
    
    // MARK: - PassDisplayNameBackDelegate
    func protSaveDisplayName(txtName: String?) {
        strDisplayName = txtName
        uiviewNameCard.lblNickName.text = txtName
        tblNameCard.reloadData()
    }
    
    // MARK: - PassShortIntroBackDelegate
    func protSaveShortIntro(txtIntro: String?) {
        strShortIntro = txtIntro
        tblNameCard.reloadData()
    }
    
    // MARK: - ChooseAvatarDelegate
    func finishChoosingAvatar(with imageData: Data) {
        SetAvatar.uploadUserImage(image: UIImage(data: imageData)!, vc: self, type: "setInfoNamecard", isProfilePic: self.isProfilePhoto)
    }
    
    // MARK: - UIImagePickerControllerDelegate
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [String : Any]) {
        guard let image = info[UIImagePickerControllerOriginalImage] as? UIImage else {
            picker.dismiss(animated: true, completion: nil)
            SetAvatar.showAlert(title: "Taking Photo Failed", message: "please try again", vc: self)
            return
        }
        picker.dismiss(animated: true, completion: nil)
        SetAvatar.uploadUserImage(image: image, vc: self, type: "setNamecard", isProfilePic: self.isProfilePhoto)
    }
}
