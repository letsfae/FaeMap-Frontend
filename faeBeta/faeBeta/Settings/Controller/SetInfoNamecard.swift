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

class SetInfoNamecard: UIViewController, UINavigationControllerDelegate, UITableViewDelegate, UITableViewDataSource, ViewControllerNameDelegate, ViewControllerIntroDelegate, UIImagePickerControllerDelegate, SendMutipleImagesDelegate {
    
    func protSaveName(txtName: String?) {
        strDisplayName = txtName
        let user = FaeUser()
        user.whereKey("nick_name", value: txtName!)
        user.updateNameCard { (status:Int, objects:Any?) in
            if status / 100 != 2 {
                felixprint("update short intro failed")
            } else {
                self.uiviewNameCard.lblNickName.text = txtName
                self.tblNameCard.reloadData()
            }
        }
    }
    
    func protSaveIntro(txtIntro: String?) {
        strShortIntro = txtIntro
        let user = FaeUser()
        user.whereKey("short_intro", value: txtIntro!)
        user.updateNameCard { (status:Int, objects:Any?) in
            if status / 100 != 2 {
                felixprint("update short intro failed")
            } else {
                self.tblNameCard.reloadData()
            }
        }
    }
    
    var faeNavBar: FaeNavBar!
    var uiviewNameCard: FMNameCardView!
    var uiviewInterval: UIView!
    var tblNameCard: UITableView!
    var arrInfo: [String] = ["Display Name", "Short Info", "Change Profile Picture", "Change Cover Photo"]
    var strDisplayName: String?
    var strShortIntro: String?
    var enterMode: SetInfoEnterMode!
    // Vicky 09/17/71 不要在这个地方单独操作，当你进入SetDisplayName()的时候，有一个push操作，直接在那个地方delegate=self。你在这个地方，是给了SetDisplayName()一个叫做vc的引用，在viewDidLoad里给这个引用的delegate=self,但你在pushViewController里是push了另一个引用，那个引用里需要将vc.delegate=self，否则是无效的。如果还不理解，周一再问我。
    //    var vc = SetDisplayName()
    
    var activityIndicator: UIActivityIndicatorView!
    
    override func viewDidLoad() {
        // super.viewDidLoad() missing here
        super.viewDidLoad()
        //        vc.delegate = self
        view.backgroundColor = .white
        loadContent()
        loadActivityIndicator()
        updateInfo()
    }
    
    func loadContent() {
        faeNavBar = FaeNavBar()
        view.addSubview(faeNavBar)
        faeNavBar.lblTitle.text = "Edit NameCard"
        faeNavBar.loadBtnConstraints()
        faeNavBar.rightBtn.setImage(nil, for: .normal)
        faeNavBar.leftBtn.addTarget(self, action: #selector(actionGoBack(_:)), for: .touchUpInside)
        
        uiviewNameCard = FMNameCardView()
        uiviewNameCard.showFullNameCard()
        uiviewNameCard.frame.origin.y = 65 + 11 + device_offset_top
        uiviewNameCard.boolSmallSize = true
        uiviewNameCard.userId = Key.shared.user_id
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
        
//        let line = UIView(frame: CGRect(x: 0, y: 113, width: screenWidth, height: 1))
//        line.backgroundColor = .black
//        view.addSubview(line)
    }
    
    func loadActivityIndicator() {
        activityIndicator = UIActivityIndicatorView()
        activityIndicator.activityIndicatorViewStyle = .whiteLarge
        activityIndicator.center = view.center
        activityIndicator.hidesWhenStopped = true
        activityIndicator.color = UIColor._2499090()
        view.addSubview(activityIndicator)
        view.bringSubview(toFront: activityIndicator)
    }
    
    func updateInfo() {
        getFromURL("users/name_card", parameter: nil, authentication: Key.shared.headerAuthentication()) { status, result in
            guard status / 100 == 2 else { return }
            let rsltJSON = JSON(result!)
            self.strDisplayName = rsltJSON["nick_name"].stringValue
            self.strShortIntro = rsltJSON["short_intro"].stringValue
            self.tblNameCard.reloadData()
        }
    }
    
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
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        switch indexPath.row {
        case 0:
            // Vicky 09/17/17
            let vc = SetDisplayName()
            vc.delegate = self
            if let nav = navigationController {
                nav.pushViewController(vc, animated: true)
            } else {
                present(vc, animated: true)
            }
            // Vicky 09/17/17 End
            break
        case 1:
            let vc = SetShortIntro()
            vc.delegate = self
            if let nav = navigationController {
                nav.pushViewController(vc, animated: true)
            } else {
                present(vc, animated: true)
            }
            break
        case 2:
            SetAvatar.addProfileAvatar(vc: self, type: "setNamecard")
            break
        default:
            break
        }
    }
    
    @objc func actionGoBack(_ sender: UIButton) {
        if enterMode == .nameCard {
            dismiss(animated: true)
        } else {
            navigationController?.popViewController(animated: true)
        }
    }
    
    // SendMutipleImagesDelegate
    func sendImages(_ images: [UIImage]) {
        print("send image for avatar")
        if let image = images.first {
            //uploadProfileAvatar(image: image)
            SetAvatar.uploadProfileAvatar(image: image, vc: self, type: "setNamecard")
        }
    }
    
    // UIImagePickerControllerDelegate
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [String : Any]) {
        guard let image = info[UIImagePickerControllerOriginalImage] as? UIImage else {
            picker.dismiss(animated: true, completion: nil)
            //showAlert(title: "Taking Photo Failed", message: "please try again")
            SetAvatar.showAlert(title: "Taking Photo Failed", message: "please try again", vc: self)
            return
        }
        picker.dismiss(animated: true, completion: nil)
        //uploadProfileAvatar(image: image)
        SetAvatar.uploadProfileAvatar(image: image, vc: self, type: "setNamecard")
    }
}
