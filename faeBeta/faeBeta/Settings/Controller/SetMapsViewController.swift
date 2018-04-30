//
//  SetMapsViewController.swift
//  FaeSettings
//
//  Created by 子不语 on 2017/8/30.
//  Copyright © 2017年 子不语. All rights reserved.
//

import UIKit

class SetMapsViewController: UIViewController, UITableViewDataSource {
    // MARK: - Properties
    private var uiviewNavBar: FaeNavBar!
    private let arrMaps: [String] = ["Map Options", "Auto Refresh Map", "Auto Cycle Pins", "Hide Map Avatars"]
    private let arrMapDetails: [String] = ["Allow Fae Map to automatically refresh for new pins when moving to a different location.", "Allow Fae Map to automatically cycle pins in the same location when zooming in and out.", "Hide all Map Avatars on the map. Self Avatar is still publicly visible unless you Go Invisible."]
    private var tblMaps: UITableView!
    private var uiviewInterval: UIView!
    
    // MARK: - Life cycle
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .white
        self.navigationController?.isNavigationBarHidden = true
        loadNavBar()
        loadTableView()
    }
    
    private func loadNavBar() {
        uiviewNavBar = FaeNavBar(frame: .zero)
        uiviewNavBar.lblTitle.text = "Maps & Display"
        view.addSubview(uiviewNavBar)
        uiviewNavBar.leftBtn.addTarget(self, action: #selector(actionGoBack(_:)), for: .touchUpInside)
        uiviewNavBar.loadBtnConstraints()
        uiviewNavBar.rightBtn.setImage(nil, for: .normal)
    }
    
    private func loadTableView() {
        tblMaps = UITableView(frame: CGRect(x: 0, y: 65 + device_offset_top, width: screenWidth, height: screenHeight - 65 - device_offset_top))
        tblMaps.separatorStyle = .none
        view.addSubview(tblMaps)
        tblMaps.dataSource = self
        tblMaps.register(GeneralSubTitleCell.self, forCellReuseIdentifier: "GeneralSubTitleCell")
        tblMaps.register(GeneralTitleCell.self, forCellReuseIdentifier: "GeneralTitleCell")
        tblMaps.rowHeight = UITableViewAutomaticDimension
        tblMaps.estimatedRowHeight = 60
    }
    
    // MARK: - Button action
    @objc private func actionGoBack(_ sender: UIButton) {
        self.navigationController?.popViewController(animated: true)
    }
    
    // MARK: - UITableViewDataSource
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 4
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        if indexPath.row == 0 {
            let cell = tableView.dequeueReusableCell(withIdentifier: "GeneralTitleCell", for: indexPath as IndexPath) as! GeneralTitleCell
            cell.lblName.text = arrMaps[indexPath.row]
            cell.switchIcon.isHidden = true
            cell.lblDes.isHidden = true
            cell.removeContraintsForDes()
            cell.imgView.isHidden = true
            cell.topGrayLine.isHidden = true
            return cell
        }
        let cell = tableView.dequeueReusableCell(withIdentifier: "GeneralSubTitleCell", for: indexPath as IndexPath) as! GeneralSubTitleCell
        cell.lblName.text = arrMaps[indexPath.row]
        if indexPath.row == 1 {
            cell.switchIcon.isOn = Key.shared.autoRefresh
        } else if indexPath.row == 2 {
            cell.switchIcon.isOn = Key.shared.autoCycle
        } else {
            cell.switchIcon.isOn = Key.shared.hideAvatars
        }
        cell.switchIcon.isHidden = false
        cell.btnSelect.isHidden = true
        cell.lblDes.isHidden = false
        cell.setContraintsForDes()
        cell.imgView.isHidden = true
        return cell
    }
}
