//
//  ManageColListViewController.swift
//  faeBeta
//
//  Created by Faevorite 2 on 2017-09-01.
//  Copyright © 2017 fae. All rights reserved.
//

import UIKit

class ManageColListViewController: UIViewController, UITableViewDelegate, UITableViewDataSource, EditMemoDelegate {
    var uiviewNavBar: UIView!
    var btnDone: UIButton!
    var tblManageList: UITableView!
    var uiviewTabBar: UIView!
    var btnShare: UIButton!
    var btnMemo: UIButton!
    var btnRemove: UIButton!
    var selectedIdx = [IndexPath]()
    
    let SHARE = 0
    let MEMO = 1
    let REMOVE = 2
    
    var arrColList: [[String]] = [["Monster Trio Burger", "888 No.3 Road, Richmond",""],
                                  ["Polly Bubble Tea", "888 No.3 Road, Richmond", ""],
                                  ["Polly Bubble Tea", "888 No.3 Road, Richmond", "WOWOWOWOWOWOWOWOWOWOWOWOWWOWOWOWOWOWOWOWOWOWOWOWOW"],
                                  ["Polly Bubble Tea", "888 No.3 Road, Richmond", ""],
                                  ["Polly Bubble Tea", "888 No.3 Road, Richmond", ""]]
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .white
        loadNavBar()
        loadContent()
        loadTab()
    }
    
    fileprivate func loadNavBar() {
        uiviewNavBar = UIView(frame: CGRect(x: 0, y: 0, width: screenWidth, height: 65))
        view.addSubview(uiviewNavBar)
        
        let line = UIView(frame: CGRect(x: 0, y: 64, width: screenWidth, height: 1))
        line.backgroundColor = UIColor._200199204()
        uiviewNavBar.addSubview(line)
        
        btnDone = UIButton(frame: CGRect(x: screenWidth - 85, y: 21, width: 85, height: 43))
        uiviewNavBar.addSubview(btnDone)
        btnDone.setTitle("Done", for: .normal)
        btnDone.setTitleColor(UIColor._2499090(), for: .normal)
        btnDone.titleLabel?.font = UIFont(name: "AvenirNext-Medium", size: 18)
        btnDone.addTarget(self, action: #selector(self.actionDone(_:)), for: .touchUpInside)
        
        let lblTitle = UILabel(frame: CGRect(x: (screenWidth - 145) / 2, y: 28, width: 145, height: 27))
        uiviewNavBar.addSubview(lblTitle)
        lblTitle.textAlignment = .center
        lblTitle.textColor = UIColor._898989()
        lblTitle.font = UIFont(name: "AvenirNext-Medium", size: 20)
        lblTitle.text = "Manage List"
    }
    
    fileprivate func loadContent() {
        tblManageList = UITableView(frame: CGRect(x: 0, y: 65, width: screenWidth, height: screenHeight - 65 - 56), style: .plain)
        view.addSubview(tblManageList)
        tblManageList.backgroundColor = .white
        
        tblManageList.dataSource = self
        tblManageList.delegate = self
        tblManageList.separatorStyle = .none
        tblManageList.estimatedRowHeight = 90
        tblManageList.register(ManageColListCell.self, forCellReuseIdentifier: "ManageColListCell")
    }
    
    fileprivate func loadTab() {
        uiviewTabBar = UIView(frame: CGRect(x: 0, y: screenHeight - 56, width: screenWidth, height: 56))
        uiviewTabBar.backgroundColor = UIColor._241241241()
        view.addSubview(uiviewTabBar)
        
        let btnWidth = (screenWidth - 36) / 3
        btnShare = UIButton(frame: CGRect(x: 10, y: 9, width: btnWidth, height: 38))
        btnShare.backgroundColor = UIColor._174226118_a60()
        btnShare.setTitle("Share", for: .normal)
        btnShare.titleLabel?.font = UIFont(name: "AvenirNext-DemiBold", size: 18)
        btnShare.setTitleColor(.white, for: .normal)
        btnShare.layer.cornerRadius = 8
        btnShare.addTarget(self, action: #selector(actionOperateList(_:)), for: .touchUpInside)
        btnShare.tag = SHARE
        
        btnMemo = UIButton(frame: CGRect(x: 18 + btnWidth, y: 9, width: btnWidth, height: 38))
        btnMemo.backgroundColor = UIColor._194166217_a60()
        btnMemo.setTitle("Memo", for: .normal)
        btnMemo.titleLabel?.font = UIFont(name: "AvenirNext-DemiBold", size: 18)
        btnMemo.setTitleColor(.white, for: .normal)
        btnMemo.layer.cornerRadius = 8
        btnMemo.addTarget(self, action: #selector(actionOperateList(_:)), for: .touchUpInside)
        btnMemo.tag = MEMO
        
        btnRemove = UIButton(frame: CGRect(x: screenWidth - 10 - btnWidth, y: 9, width: btnWidth, height: 38))
        btnRemove.backgroundColor = UIColor._2499090_a60()
        btnRemove.setTitle("Remove", for: .normal)
        btnRemove.titleLabel?.font = UIFont(name: "AvenirNext-DemiBold", size: 18)
        btnRemove.setTitleColor(.white, for: .normal)
        btnRemove.layer.cornerRadius = 8
        btnRemove.addTarget(self, action: #selector(actionOperateList(_:)), for: .touchUpInside)
        btnRemove.tag = REMOVE
        
        uiviewTabBar.addSubview(btnShare)
        uiviewTabBar.addSubview(btnMemo)
        uiviewTabBar.addSubview(btnRemove)
    }
    
    func actionDone(_ sender: UIButton) {
        dismiss(animated: true)
    }
    
    func actionOperateList(_ sender: UIButton) {
        switch sender.tag {
        case SHARE:
            // TODO jichao
            break
        case MEMO:
            let vc = EditMemoViewController()
            vc.delegate = self
            vc.indexPath = selectedIdx[0]
            let cell = tblManageList.cellForRow(at: selectedIdx[0]) as! ManageColListCell
            vc.txtMemo = cell.lblColMemo.text!
            vc.modalPresentationStyle = .overCurrentContext
            present(vc, animated: false)
            break
        case REMOVE:
            for idxPath in selectedIdx {
                let cell = tblManageList.cellForRow(at: idxPath) as! ManageColListCell
                cell.btnSelect.isSelected = false
                let idx = idxPath.row
                arrColList.remove(at: idx)
            }
            reloadAfterDelete()
            selectedIdx.removeAll()
            updateTabBarBtnColor(selectedCount: 0)
            break
        default:
            break
        }
    }
    
    func updateTabBarBtnColor(selectedCount: Int) {
        if selectedCount == 0 {
            btnShare.backgroundColor = UIColor._174226118_a60()
            btnMemo.backgroundColor = UIColor._194166217_a60()
            btnRemove.backgroundColor = UIColor._2499090_a60()
            btnShare.isEnabled = false
            btnMemo.isEnabled = false
            btnRemove.isEnabled = false
        } else if selectedCount == 1 {
            btnShare.backgroundColor = UIColor._174226118()
            btnMemo.backgroundColor = UIColor._194166217()
            btnRemove.backgroundColor = UIColor._2499090()
            btnShare.isEnabled = true
            btnMemo.isEnabled = true
            btnRemove.isEnabled = true
        } else {
            btnShare.backgroundColor = UIColor._174226118_a60()
            btnMemo.backgroundColor = UIColor._194166217_a60()
            btnRemove.backgroundColor = UIColor._2499090()
            btnShare.isEnabled = false
            btnMemo.isEnabled = false
            btnRemove.isEnabled = true
        }
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return arrColList.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "ManageColListCell", for: indexPath) as! ManageColListCell
        let arrName = arrColList[indexPath.row][0]
        let arrAddr = arrColList[indexPath.row][1]
        let arrMemo = arrColList[indexPath.row][2]
        cell.setValueForCell(name: arrName, addr: arrAddr, memo: arrMemo)
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let cell = tableView.cellForRow(at: indexPath) as! ManageColListCell
        if !cell.btnSelect.isSelected {
            cell.btnSelect.isSelected = true
            selectedIdx.append(indexPath)
        } else {
            cell.btnSelect.isSelected = false
            guard let idx = selectedIdx.index(of: indexPath) else {
                return;
            }
            selectedIdx.remove(at: idx)
        }
        updateTabBarBtnColor(selectedCount: selectedIdx.count)
        selectedIdx.sort{$0.row > $1.row}
    }
    
    func reloadAfterDelete() {
        tblManageList.performUpdate({
            self.tblManageList.deleteRows(at: selectedIdx, with: UITableViewRowAnimation.right)
        }) {
            self.tblManageList.reloadData()
        }
    }
    
    // EditMemoDelegate
    func saveMemo(memo: String) {
        let idx = selectedIdx[0].row
        arrColList[idx][2] = memo
        tblManageList.reloadData()
    }
}
