//
//  AddFriendViewController.swift
//  FaeContacts
//
//  Created by Justin He on 6/14/17.
//  Copyright © 2017 Yue. All rights reserved.
//

import UIKit

class AddFriendViewController: UIViewController, UITableViewDelegate, UITableViewDataSource {
    
    let optionsArray: [String] = ["Search Username", "From Contacts", "Scan Nearby", "Share Username"] // for testing.
    let optionsImagesArray = [#imageLiteral(resourceName: "searchUsernamesIcon"), #imageLiteral(resourceName: "fromContactsIcon"), #imageLiteral(resourceName: "scanNearbyIcon"), #imageLiteral(resourceName: "shareUsernameIcon")]
    var tblOptions: UITableView!
    var uiviewNavBar: FaeNavBar!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        loadNavBar()
        loadTable()
    }
    
    func actionGoBack(_ sender: UIButton) {
        self.navigationController?.popViewController(animated: true)
    }
    
    /* Joshua: 06/15/17
     load the top nav bar
     */
    func loadNavBar() {
        uiviewNavBar = FaeNavBar(frame: .zero)
        view.addSubview(uiviewNavBar)
        uiviewNavBar.rightBtn.isHidden = true
        uiviewNavBar.loadBtnConstraints()
        uiviewNavBar.lblTitle.text = "Add Friends"
        uiviewNavBar.leftBtn.addTarget(self, action: #selector(self.actionGoBack(_:)), for: .touchUpInside)
    }
    
    func loadTable() {
        tblOptions = UITableView()
        tblOptions.separatorStyle = .none
        tblOptions.frame = CGRect(x: 0, y: 65, width: screenWidth, height: screenHeight - 65)
        tblOptions.dataSource = self
        tblOptions.delegate = self
        tblOptions.register(FaeAddFriendOptionsCell.self, forCellReuseIdentifier: "myOptionsCell")
        tblOptions.register(FaeRecommendedCell.self, forCellReuseIdentifier: "myRecommendedCell")
        view.addSubview(tblOptions)
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return optionsArray.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        if indexPath.section == 0 {
            let cell = tableView.dequeueReusableCell(withIdentifier: "myOptionsCell", for: indexPath as IndexPath) as! FaeAddFriendOptionsCell
            cell.lblOption.text = "\(optionsArray[indexPath.row])"
            cell.imgIcon.image = optionsImagesArray[indexPath.row]
            if indexPath.row == optionsArray.count-1 {
                cell.bottomLine.isHidden = true
            }
            return cell
        } else if indexPath.section == 1 {
            let cell = tableView.dequeueReusableCell(withIdentifier: "myRecommendedCell", for: indexPath as IndexPath) as! FaeRecommendedCell
            cell.lblUserName.text = optionsArray[indexPath.row]
            cell.lblUserSaying.text = optionsArray[indexPath.row]
            cell.lblUserRecommendReason.text = "through Contacts."
            return cell
        }
        // Vicky 07/12/2017
        //        else {
        //            let cell = tableView.dequeueReusableCell(withIdentifier: "myCell", for: indexPath as IndexPath)
        //            cell.textLabel!.text = "\(optionsArray[indexPath.row])"
        //            return cell
        //        }
        return UITableViewCell()
        // Vicky 07/12/2017 END
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        print("User selected table row \(indexPath.row) and item \(optionsArray[indexPath.row])")
//        if indexPath.row == 0 && indexPath.section == 0 {
//            let vc = AddUsernameController()
//            self.navigationController?.pushViewController(vc, animated: true)
//            tableView.deselectRow(at: indexPath, animated: true)
//        }
//        if indexPath.row == 1 && indexPath.section == 0 {
//            let vc = AddFromContactsController()
//            self.navigationController?.pushViewController(vc, animated: true)
//            tableView.deselectRow(at: indexPath, animated: true)
//        }
//        if indexPath.row == 2 && indexPath.section == 0 {
//            let vc = AddNearbyController()
//            self.navigationController?.pushViewController(vc, animated: true)
//            tableView.deselectRow(at: indexPath, animated: true)
//        }
        // Vicky 07/12/2017
        if indexPath.section == 0 {
            if indexPath.row == 0 {     // "Search Username"
                let vc = AddUsernameController()
                self.navigationController?.pushViewController(vc, animated: true)
                tableView.deselectRow(at: indexPath, animated: true)
            } else if indexPath.row == 1 {   // "From Contacts"
                let vc = AddFromContactsController()
                self.navigationController?.pushViewController(vc, animated: true)
                tableView.deselectRow(at: indexPath, animated: true)
            } else if indexPath.row == 2 {   // "Scan Nearby"
                let vc = AddNearbyController()
                self.navigationController?.pushViewController(vc, animated: true)
                tableView.deselectRow(at: indexPath, animated: true)
            }
            else {   // indexPath.row == 3  "Share Username"
                tableView.deselectRow(at: indexPath, animated: true)
                let activityVC = UIActivityViewController(activityItems: ["Discover amazing places with me on Fae Maps! Add my Username: linlin https://www.xxx.com"], applicationActivities: nil)
                activityVC.popoverPresentationController?.sourceView = self.view
                self.present(activityVC, animated: true, completion: nil)
            }
        }
        // Vicky 07/12/2017 End
    }
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 2
    }
    
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        if section == 1 {
            return 25
        }
        return 0
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        if indexPath.section == 1 {
            return 93
        }
        return 53
    }
    
    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        if section == 1 {
            let header = UIView()
            header.backgroundColor = UIColor.faeAppSectionBackgroundColor()
            header.frame = CGRect(x: 0, y: 0, width: screenWidth + 2, height: 25)
            let topLine = UIView(frame: CGRect(x: 0, y: 0, width: screenWidth, height: 1))
            topLine.layer.borderWidth = 1
            topLine.layer.borderColor = UIColor.faeAppNavBarBorderGrayColor()
            header.addSubview(topLine)
            let bottomLine = UIView(frame: CGRect(x: 0, y: 24, width: screenWidth, height: 1))
            bottomLine.layer.borderWidth = 1
            bottomLine.layer.borderColor = UIColor.faeAppNavBarBorderGrayColor()
            header.addSubview(bottomLine)
            let label = UILabel()
            label.text = "Recommended"
            label.textColor = UIColor.faeAppInputPlaceholderGrayColor()
            label.font = UIFont(name: "AvenirNext-DemiBold", size: 15)
            label.sizeToFit()
            header.addSubview(label)
            header.addConstraintsWithFormat("V:|-0-[v0]-0-|", options: [], views: label)
            header.addConstraintsWithFormat("H:|-15-[v0]", options: [], views: label)
            return header
        }
        return nil
    }
    
    
}
