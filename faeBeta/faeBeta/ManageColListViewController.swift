//
//  ManageColListViewController.swift
//  faeBeta
//
//  Created by Faevorite 2 on 2017-09-01.
//  Copyright © 2017 fae. All rights reserved.
//

import UIKit

protocol ManageColListDelegate: class {
    func returnValBack()
    func finishDeleting(ids: [Int])
}

class ManageColListViewController: UIViewController, UITableViewDelegate, UITableViewDataSource, EditMemoDelegate {
    var uiviewNavBar: UIView!
    var btnDone: UIButton!
    var tblManageList: UITableView!
    var uiviewTabBar: UIView!
    var btnShare: UIButton!
    var btnMemo: UIButton!
    var btnRemove: UIButton!
    var selectedIdx = [IndexPath]()
    var enterMode: CollectionTableMode!
    var colId: Int = -1
    
    let SHARE = 0
    let MEMO = 1
    let REMOVE = 2
    
    weak var delegate: ManageColListDelegate?
    var arrSavedIds = [Int]()
//    var arrColList = [SavedPin]()
    
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
        tblManageList.estimatedRowHeight = 100
        tblManageList.register(ColListPlaceCell.self, forCellReuseIdentifier: "ManageColPlaceCell")
        tblManageList.register(ColListLocationCell.self, forCellReuseIdentifier: "ManageColLocationCell")
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
        delegate?.returnValBack()//savedItems: arrColList)
        dismiss(animated: true)
    }
    
    var desiredCount = 0
    var deleteCount = 0 {
        didSet {
            guard desiredCount != 0 && deleteCount != 0 else { return }
            if deleteCount == desiredCount {
                reloadAfterDelete()
            }
        }
    }
    
    func actionOperateList(_ sender: UIButton) {
        switch sender.tag {
        case SHARE:
            // TODO jichao
            //let cell = tblManageList.cellForRow(at: selectedIdx[0]) as! ManageColListCell
            //let vcShareCollection = NewChatShareController(friendListMode: .place)
            //vcShareCollection.placeDetail = "\(cell.lblColName.text);\(cell.lblColAddr.text)"
            //navigationController?.pushViewController(vcShareCollection, animated: true)
            break
        case MEMO:
            let vc = EditMemoViewController()
            vc.delegate = self
            vc.enterMode = enterMode
            vc.indexPath = selectedIdx[0]
            vc.pinId = arrSavedIds[selectedIdx[0].row] //arrColList[selectedIdx[0].row].pinId
            vc.modalPresentationStyle = .overCurrentContext
            present(vc, animated: false)
            break
        case REMOVE:
            // 对后端需求，批量删除？
            print(arrSavedIds)
            desiredCount = selectedIdx.count
            for i in 0..<selectedIdx.count {
                let idxPath = selectedIdx[i]
                let id = String(arrSavedIds[idxPath.row])
                let cell = self.tblManageList.cellForRow(at: idxPath) as! ColListPlaceCell
                cell.btnSelect.isSelected = false
                let idx = idxPath.row
                FaeCollection.shared.unsaveFromCollection(enterMode.rawValue, collectionID: String(colId), pinID: id) {(status: Int, message: Any?) in
                    if status / 100 == 2 {
                        self.arrSavedIds.remove(at: idx)
                        self.deleteCount += 1
                    } else {
                        print("[Fail to Unsave Item From Collection] \(status) \(message!)")
                    }
                }
            }
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
        return arrSavedIds.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        if enterMode == .place {
            let cell = tableView.dequeueReusableCell(withIdentifier: "ManageColPlaceCell", for: indexPath) as! ColListPlaceCell
            let savedId = arrSavedIds[indexPath.row]
            cell.setValueForPlacePin(placeId: savedId)
            cell.btnSelect.isSelected = selectedIdx.contains(indexPath)
            return cell
        } else {
            let cell = tableView.dequeueReusableCell(withIdentifier: "ManageColLocationCell", for: indexPath) as! ColListLocationCell
            let savedId = arrSavedIds[indexPath.row]
            cell.setValueForLocationPin(locId: savedId)
            cell.btnSelect.isSelected = selectedIdx.contains(indexPath)
            return cell
        }
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if enterMode == .place {
            let cell = tableView.cellForRow(at: indexPath) as! ColListPlaceCell
            if !cell.btnSelect.isSelected {
                cell.btnSelect.isSelected = true
                selectedIdx.append(indexPath)
            } else {
                cell.btnSelect.isSelected = false
                guard let idx = selectedIdx.index(of: indexPath) else {
                    return
                }
                selectedIdx.remove(at: idx)
            }
        } else {
            let cell = tableView.cellForRow(at: indexPath) as! ColListLocationCell
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
        }
        updateTabBarBtnColor(selectedCount: selectedIdx.count)
        selectedIdx.sort{$0.row > $1.row}
    }
    
    func reloadAfterDelete() {
        tblManageList.performUpdate({
            self.tblManageList.deleteRows(at: selectedIdx, with: UITableViewRowAnimation.right)
        }) {
            self.selectedIdx.removeAll()
            self.tblManageList.reloadData()
            self.updateTabBarBtnColor(selectedCount: 0)
            self.delegate?.finishDeleting(ids: self.arrSavedIds)
        }
    }
    
    // EditMemoDelegate
    func saveMemo(memo: String) {
        tblManageList.reloadData()
    }
}
