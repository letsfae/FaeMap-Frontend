//
//  SetSpreadViewController2.swift
//  FaeSettings
//
//  Created by 子不语 on 2017/9/24.
//  Copyright © 2017年 子不语. All rights reserved.
//

import UIKit
import MessageUI
import Social

class SetSpreadViewController: UIViewController, UITableViewDelegate, UITableViewDataSource, MFMailComposeViewControllerDelegate, MFMessageComposeViewControllerDelegate {
    // MARK: - Properties
    var uiviewNavBar: FaeNavBar!
    var tblSpLove: UITableView!
    var arrStr: [String: String] = ["00": "Invite Friends!", "01": "From Contacts", "02": "From Facebook", "10": "Share Fae Map!", "11": "Send Message", "12": "Send Email", "13": "Share on Facebook", "14": "Share on Twitter", "15": "Other Options"]
    
    // MARK: - Life cycle
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .white
        navigationController?.isNavigationBarHidden = true
        loadNavBar()
        loadTableView()
    }
    
    // MARK: - Set up
    func loadNavBar() {
        uiviewNavBar = FaeNavBar(frame: .zero)
        view.addSubview(uiviewNavBar)
        uiviewNavBar.lblTitle.text = "Spread Love"
        uiviewNavBar.leftBtn.addTarget(self, action: #selector(actionGoBack(_:)), for: .touchUpInside)
        uiviewNavBar.loadBtnConstraints()
        uiviewNavBar.rightBtn.setImage(nil, for: .normal)
    }
    
    func loadTableView() {
        tblSpLove = UITableView(frame: CGRect(x: 0, y: 65 + device_offset_top, width: screenWidth, height: screenHeight - 65 - device_offset_top))
        view.addSubview(tblSpLove)
        tblSpLove.separatorStyle = .none
        tblSpLove.delegate = self
        tblSpLove.dataSource = self
        tblSpLove.register(GeneralTitleCell.self, forCellReuseIdentifier: "GeneralTitleCell")
        tblSpLove.register(GeneralSubTitleCell.self, forCellReuseIdentifier: "GeneralSubTitleCell")
        tblSpLove.estimatedRowHeight = 60
        tblSpLove.rowHeight = UITableViewAutomaticDimension
    }
    
    // MARK: - UITableViewDataSource
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return section == 0 ? 3 : 6
    }
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 2
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let section = indexPath.section
        let row = indexPath.row
        if section == 0 {
            if row == 0 {
                let cell = tableView.dequeueReusableCell(withIdentifier: "GeneralTitleCell", for: indexPath as IndexPath) as! GeneralTitleCell
                cell.switchIcon.isHidden = true
                cell.imgView.isHidden = true
                cell.lblDes.isHidden = false
                cell.setContraintsForDes()
                cell.lblName.text = arrStr["\(section)\(row)"]
                cell.lblDes.text = "Fae Map is better with friends! Invite your friends to share and discover amazing places together!"
                cell.topGrayLine.isHidden = true
                return cell
            }
            let cell = tableView.dequeueReusableCell(withIdentifier: "GeneralSubTitleCell", for: indexPath as IndexPath) as! GeneralSubTitleCell
            cell.switchIcon.isHidden = true
            cell.imgView.isHidden = false
            cell.btnSelect.isHidden = true
            cell.removeContraintsForDes()
            cell.lblName.textColor = UIColor._107105105()
            cell.lblName.text = arrStr["\(section)\(row)"]
            return cell
        }
        if row == 0 {
            let cell = tableView.dequeueReusableCell(withIdentifier: "GeneralTitleCell", for: indexPath as IndexPath) as! GeneralTitleCell
            cell.switchIcon.isHidden = true
            cell.imgView.isHidden = true
            cell.addConstraintsWithFormat("V:|-20-[v0(25)]-20-|", options: [], views: cell.lblName)
            cell.lblName.text = arrStr["\(section)\(row)"]
            cell.topGrayLine.isHidden = false
            return cell
        }
        let cell = tableView.dequeueReusableCell(withIdentifier: "GeneralSubTitleCell", for: indexPath as IndexPath) as! GeneralSubTitleCell
        cell.switchIcon.isHidden = true
        cell.imgView.isHidden = false
        cell.btnSelect.isHidden = true
        cell.removeContraintsForDes()
        cell.lblName.text = arrStr["\(section)\(row)"]
        cell.lblName.textColor = UIColor._107105105()
        return cell
    }
    
    // MARK: - UITableViewDelegate
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if indexPath.section == 0 {
            switch indexPath.row {
            case 1:
                navigationController?.pushViewController(AddFromContactsController(), animated: true)
            default: break
            }
        } else {
            switch indexPath.row {
            case 1:
                if !MFMessageComposeViewController.canSendText() {
                    felixprint("message not available")
                    return
                }
                let messageVC = MFMessageComposeViewController()
                messageVC.messageComposeDelegate = self
                messageVC.body = "Discover amazing places with me on Fae Maps! Check it out here![https://www.faemaps.com/]"
                present(messageVC, animated: true, completion: nil)
            case 2:
                if !MFMailComposeViewController.canSendMail() {
                    felixprint("mail service not available")
                    return
                }
                let composeVC = MFMailComposeViewController()
                composeVC.mailComposeDelegate = self
                composeVC.setSubject("Awesome Place Discovery App to Check Out!")
                composeVC.setMessageBody("Just a quick note to tell you about a cool app I’ve been using. Fae Map is a free place discovery and sharing app that I thought you might like. Check it out here: <a>faemaps.com</a>.\n\nDownload it <a href='https://www.faemaps.com/'>here</a> and let’s discover and go to amazing places together.", isHTML: true)
                present(composeVC, animated: true, completion: nil)
            case 3:
                /*if !SLComposeViewController.isAvailable(forServiceType: SLServiceTypeFacebook) {
                    felixprint("facebook not available")
                    return
                }
                let fbVC = SLComposeViewController(forServiceType: SLServiceTypeFacebook)
                fbVC!.setInitialText("Discover amazing places with me on Fae Maps! Check it out here![https://www.faemaps.com/]")
                present(fbVC!, animated: true, completion: nil)*/
                break
            case 4:
                if UIApplication.shared.canOpenURL(URL(string: "twitter://")!) {
                    UIApplication.shared.openURL(URL(string: "twitter://post?message=hello%20world")!)
                }
                /*if !SLComposeViewController.isAvailable(forServiceType: SLServiceTypeTwitter) {
                    felixprint("twitter not available")
                    return
                }
                let twitterVC = SLComposeViewController(forServiceType: SLServiceTypeTwitter)
                twitterVC!.setInitialText("Discover amazing places with me on Fae Maps! Check it out here![https://www.faemaps.com/]")
                present(twitterVC!, animated: true, completion: nil)*/
            case 5:
                let activityVC = UIActivityViewController(activityItems: ["Discover amazing places with me on Fae Maps! Check it out here![https://www.faemaps.com/]"], applicationActivities: nil)
                activityVC.popoverPresentationController?.sourceView = self.view
                present(activityVC, animated: true, completion: nil)
            default: break
            }
        }
    }
    
    func mailComposeController(_ controller: MFMailComposeViewController, didFinishWith result: MFMailComposeResult, error: Error?) {
        controller.dismiss(animated: true, completion: nil)
    }
    
    func messageComposeViewController(_ controller: MFMessageComposeViewController, didFinishWith result: MessageComposeResult) {
        controller.dismiss(animated: true, completion: nil)
    }
    
    @objc func actionGoBack(_ sender: UIButton) {
        navigationController?.popViewController(animated: true)
    }
}
