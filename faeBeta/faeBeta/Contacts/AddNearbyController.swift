//
//  AddNearbyViewController.swift
//  FaeContacts
//
//  Created by 子不语 on 2017/6/27.
//  Copyright © 2017年 Yue. All rights reserved.
//

import UIKit

class AddNearbyController: UIViewController, UITableViewDelegate, UITableViewDataSource {
    var uiviewNavBar: FaeNavBar!
    var lblScanTitle: UILabel!
    var lblScanSubtitle: UILabel!
    var imgBigCircle: UIImageView!
    var imgScan: UIImageView!
    var imgAvatar: UIImageView!
    var imgScan2: UIImageView!
    var imgScan3: UIImageView!
    var tblUsernames: UITableView!
    var btnRight: UIButton!
    //change ShowScanedResult to true can get into tableView
    var ShowScanedResult = false
    
    // Joshua: array with more than 30 items will cause sourcekitservice to consume too much cpu and memory resource
//    var testArray = ["Afghanistan", "Albania", "Algeria", "American Samoa", "Andorra", "Angola", "Anguilla", "Antarctica", "Antigua and Barbuda", "Argentina", "Armenia", "Aruba", "Australia", "Austria", "Azerbaijan", "Bahamas", "Bahrain", "Bangladesh", "Barbados", "Belarus", "Belgium", "Belize", "Benin", "Bermuda", "Bhutan", "Bolivia", "Bosnia and Herzegowina", "Botswana", "Bouvet Island", "Brazil", "British Indian Ocean Territory", "Brunei Darussalam", "Bulgaria", "Burkina Faso", "Burundi", "Cambodia", "Cameroon", "Canada", "Cape Verde", "Cayman Islands", "Central African Republic", "Chad", "Chile", "China", "Christmas Island", "Cocos (Keeling) Islands", "Colombia", "Comoros", "Congo", "Congo, the Democratic Republic of the", "Cook Islands", "Costa Rica", "Cote d'Ivoire", "Croatia (Hrvatska)", "Cuba", "Cyprus", "Czech Republic", "Denmark", "Djibouti", "Dominica", "Dominican Republic", "East Timor", "Ecuador", "Egypt", "El Salvador", "Equatorial Guinea"]
    var testArray = ["Afghanistan", "Albania", "Algeria", "American Samoa", "Andorra", "Angola", "Anguilla", "Antarctica", "Antigua and Barbuda", "Argentina", "Armenia", "Aruba"]
    
    override func viewDidLoad() {
        view.backgroundColor = UIColor.white
        loadNavBar()
        loadTextView()
        loadImgView()
        loadTable()
        loadScanAnimation()
        if ShowScanedResult {
            lblScanTitle.isHidden = true
            lblScanSubtitle.isHidden = true
            imgScan.isHidden = true
            imgScan2.isHidden = true
            imgScan3.isHidden = true
            imgAvatar.isHidden = true
            tblUsernames.isHidden = false
        }
        else {
            lblScanTitle.isHidden = false
            lblScanSubtitle.isHidden = false
            imgScan.isHidden = false
            imgScan2.isHidden = false
            imgScan3.isHidden = false
            imgAvatar.isHidden = false
            tblUsernames.isHidden = true
        }
    }
    
    func loadNavBar() {
        uiviewNavBar = FaeNavBar(frame: .zero)
        view.addSubview(uiviewNavBar)
        uiviewNavBar.rightBtn.isHidden = true
        uiviewNavBar.loadBtnConstraints()
        uiviewNavBar.lblTitle.text = "Add Nearby"
        uiviewNavBar.leftBtn.addTarget(self, action: #selector(self.actionGoBack(_:)), for: .touchUpInside)
        if ShowScanedResult {
            uiviewNavBar.rightBtn.isHidden = false
            uiviewNavBar.rightBtn.setImage(nil, for: .normal)
            uiviewNavBar.rightBtn.setTitle("Refresh", for: .normal)
            uiviewNavBar.rightBtn.setTitleColor(UIColor._2499090(), for: .normal)
            uiviewNavBar.rightBtn.titleLabel?.font = UIFont(name: "AvenirNext-Medium", size: 18)
            uiviewNavBar.rightBtn.addConstraintsWithFormat("H:|-0-[v0(64)]", options: [], views: uiviewNavBar.rightBtn.titleLabel!)
        }
    }
    
    func loadTextView() {
        lblScanTitle = UILabel()
        lblScanTitle.text = "Scanning for people nerby!"
        lblScanTitle.textAlignment = .center
        lblScanTitle.textColor = UIColor._898989()
        lblScanTitle.font = UIFont(name: "AvenirNext-Medium", size: 18)
        
        lblScanSubtitle = UILabel()
        lblScanSubtitle.text = "make sure others are also scanning..."
        lblScanSubtitle.textAlignment = .center
        lblScanSubtitle.textColor = UIColor._138138138()
        lblScanSubtitle.font = UIFont(name: "AvenirNext-Medium", size: 16)
        
        view.addSubview(lblScanTitle)
        view.addSubview(lblScanSubtitle)
        
        view.addConstraintsWithFormat("H:|-0-[v0]-0-|", options: [], views: lblScanTitle)
        view.addConstraintsWithFormat("H:|-0-[v0]-0-|", options: [], views: lblScanSubtitle)
        view.addConstraintsWithFormat("V:|-110-[v0]", options: [], views: lblScanTitle)
        view.addConstraintsWithFormat("V:|-140-[v0]", options: [], views: lblScanSubtitle)
    }
    
    func loadImgView() {
        if imgScan != nil {
            imgScan.removeFromSuperview()
            imgScan2.removeFromSuperview()
            imgScan3.removeFromSuperview()
        }
        imgScan = UIImageView()
        imgScan.frame = CGRect(x: 117*screenWidthFactor, y: 278, width: 180*screenWidthFactor, height: 180*screenHeightFactor)
        imgScan.layer.cornerRadius = 90
        imgScan.contentMode = .scaleAspectFill
        
        imgScan2 = UIImageView()
        imgScan2.frame = CGRect(x: 117*screenWidthFactor, y: 278, width: 180*screenWidthFactor, height: 180*screenHeightFactor)
        imgScan2.layer.cornerRadius = 90
        imgScan2.contentMode = .scaleAspectFill
        
        imgScan3 = UIImageView()
        imgScan3.frame = CGRect(x: 117*screenWidthFactor, y: 278, width: 180*screenWidthFactor, height: 180*screenHeightFactor)
        imgScan3.layer.cornerRadius = 90
        imgScan3.contentMode = .scaleToFill

        
        view.addSubview(imgScan3)
        view.addSubview(imgScan2)
        view.addSubview(imgScan)
        imgScan.layer.zPosition = 0
        imgScan2.layer.zPosition = 1
        imgScan3.layer.zPosition = 2
        imgScan.isUserInteractionEnabled = false
        imgScan2.isUserInteractionEnabled = false
        imgScan3.isUserInteractionEnabled = false
        imgScan.image = UIImage(named: "imgScan")
        imgScan2.image = UIImage(named: "imgScan")
        imgScan3.image = UIImage(named: "imgScan")
        
        imgAvatar = UIImageView(frame: CGRect(x: 167*screenWidthFactor, y: 328, width: 80*screenWidthFactor, height: 80*screenHeightFactor))
        imgAvatar.layer.cornerRadius = 40 * screenWidthFactor
        imgAvatar.contentMode = .scaleAspectFill
        view.addSubview(imgAvatar)
        General.shared.avatar(userid: Key.shared.user_id, completion: { (avatarImage) in
            self.imgAvatar.image = avatarImage
        })
        imgAvatar.layer.borderWidth = 5
        imgAvatar.layer.borderColor = UIColor.white.cgColor
        imgAvatar.layer.zPosition = 3
        imgAvatar.clipsToBounds = true
    }
    
    func loadScanAnimation() {
        UIView.animate(withDuration: 2.4, delay: 0, options: [.repeat, .curveEaseIn], animations: ({
            if self.imgScan != nil {
                self.imgScan.alpha = 0.0
                self.imgScan.frame = CGRect(x: 32*screenWidthFactor, y: 193, width: 350*screenWidthFactor, height: 350*screenHeightFactor)
            }
        }), completion: nil)
        
        UIView.animate(withDuration: 2.4, delay: 0.8, options: [.repeat, .curveEaseIn], animations: ({
            if self.imgScan2 != nil {
                self.imgScan2.alpha = 0.0
                self.imgScan2.frame = CGRect(x: 32*screenWidthFactor, y: 193, width: 350*screenWidthFactor, height: 350*screenHeightFactor)
            }
        }), completion: nil)
        
        UIView.animate(withDuration: 2.4, delay: 1.6, options: [.repeat, .curveEaseIn], animations: ({
            if self.imgScan3 != nil {
                self.imgScan3.alpha = 0.0
                self.imgScan3.frame = CGRect(x: 32*screenWidthFactor, y: 193, width: 350*screenWidthFactor, height: 350*screenHeightFactor)
            }
        }), completion: nil)
    }
    
    func loadTable() {
        tblUsernames = UITableView()
        tblUsernames.frame = CGRect(x: 0, y: 65, width: screenWidth, height: screenHeight - 65)
        tblUsernames.dataSource = self
        tblUsernames.delegate = self
        tblUsernames.register(FaeContactsCell.self, forCellReuseIdentifier: "FaeContactsCell")
        tblUsernames.indicatorStyle = .white
        view.addSubview(tblUsernames)
    }
    
    @objc func actionGoBack(_ sender: UIButton) {
        self.navigationController?.popViewController(animated: true)
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return testArray.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "FaeAddUsernameCell", for: indexPath) as! FaeAddUsernameCell
        cell.lblUserName.text = testArray[indexPath.row]
        cell.lblUserSaying.text = testArray[indexPath.row]
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        print("User selected table row \(indexPath.row) and item \(testArray[indexPath.row])")
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 74
    }
}
