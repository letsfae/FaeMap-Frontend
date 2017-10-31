//
//  SetMapsViewController.swift
//  FaeSettings
//
//  Created by 子不语 on 2017/8/30.
//  Copyright © 2017年 子不语. All rights reserved.
//

import UIKit

class SetMapsViewController: UIViewController, UITableViewDelegate, UITableViewDataSource {
    
    var uiviewNavBar: FaeNavBar!
    let arrMaps: [String] = ["Map Options", "Auto Refresh Map", "Auto Cycle Pins", "Hide Map Avatars"]
    let arrMapDetails: [String] = ["Allow Fae Map to automatically refresh for new pins when moving to a different location.", "Allow Fae Map to automatically cycle pins in the same location when zooming in and out.", "Hide all Map Avatars on the map. Self Avatar is still publicly visible unless you Go Invisible."]
    var tblMaps: UITableView!
    var uiviewInterval: UIView!
    
    override func viewDidLoad() {
        view.backgroundColor = .white
        self.navigationController?.isNavigationBarHidden = true
        loadNavBar()
        loadTableView()
    }
    
    func loadNavBar() {
        uiviewNavBar = FaeNavBar(frame: .zero)
        uiviewNavBar.lblTitle.text = "Maps & Display"
        view.addSubview(uiviewNavBar)
        uiviewNavBar.leftBtn.addTarget(self, action: #selector(actionGoBack(_:)), for: .touchUpInside)
        uiviewNavBar.loadBtnConstraints()
        uiviewNavBar.rightBtn.setImage(nil, for: .normal)
    }
    
    func loadTableView() {
        tblMaps = UITableView(frame: CGRect(x: 0, y: 65, width: screenWidth, height: screenHeight - 65))
        tblMaps.separatorStyle = .none
        view.addSubview(tblMaps)
        tblMaps.dataSource = self
        tblMaps.delegate = self
        tblMaps.register(GeneralSubTitleCell.self, forCellReuseIdentifier: "GeneralSubTitleCell")
        tblMaps.register(GeneralTitleCell.self, forCellReuseIdentifier: "GeneralTitleCell")
        tblMaps.rowHeight = UITableViewAutomaticDimension
        tblMaps.estimatedRowHeight = 60
    }
    
    @objc func actionGoBack(_ sender: UIButton) {
        self.navigationController?.popViewController(animated: true)
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 4
    }
    
//    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
//        if indexPath.row == 0 {
//            return 60
//        }
//        return 92
//    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        // Vicky 09/17/17 这个地方withIdentifier本来写的是generalCell，让我误以为是GeneralCell，为方便查看，建议以后Identifier命名直接和Cell的class名一样
        if indexPath.row == 0 {
            let cell = tableView.dequeueReusableCell(withIdentifier: "GeneralTitleCell", for: indexPath as IndexPath) as! GeneralTitleCell
            cell.lblName.text = arrMaps[indexPath.row]
            cell.switchIcon.isHidden = true
            cell.lblDes.isHidden = true
            cell.removeContraintsForDes()
            cell.imgView.isHidden = true
            return cell
        }
        let cell = tableView.dequeueReusableCell(withIdentifier: "GeneralSubTitleCell", for: indexPath as IndexPath) as! GeneralSubTitleCell
        cell.lblName.text = arrMaps[indexPath.row]
        cell.switchIcon.isHidden = false
        cell.btnSelect.isHidden = true
        cell.lblDes.isHidden = false
        cell.setContraintsForDes()
        cell.imgView.isHidden = true
        return cell
    }
}
