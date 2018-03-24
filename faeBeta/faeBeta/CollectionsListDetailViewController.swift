//
//  CollectionsListDetailViewController.swift
//  faeBeta
//
//  Created by Faevorite 2 on 2017-08-24.
//  Copyright © 2017 fae. All rights reserved.
//

import UIKit
import SwiftyJSON
import RealmSwift

class CollectionsListDetailViewController: UIViewController, UITableViewDelegate, UITableViewDataSource, UIScrollViewDelegate, ColListDetailHeaderDelegate, ManageColListDelegate {
    
    var enterMode: CollectionTableMode!
    
    var uiviewFixedHeader: UIView!
    var uiviewFixedSectionHeader: UIView!
    var uiviewAvatarShadow: UIView!
    var uiviewFooter: UIView!
    
    var imgHeader: UIImageView!
    var imgAvatar: UIImageView!
    
    var lblNum: UILabel!
    var lblListName: UILabel!
    var lblItemsNum: UILabel!
    
    var tblColListDetail: UITableView!
    
    var btnBack: UIButton!
    var btnMapView: UIButton!
    var btnShare: UIButton!
    var btnMore: UIButton!
    
    var numItems: Int = 0
    
    // variables in extension file
    var uiviewShadowBG: UIView!
    var uiviewChooseAction: UIView!
    var uiviewMsgHint: UIView!
    
    var lblChoose: UILabel!
    
    var btnActFirst: UIButton!
    var btnActSecond: UIButton!
    var btnActThird: UIButton!
    var btnCancel: UIButton!
    var btnCrossCancel: UIButton!
    var btnYes: UIButton!
    
    let realm = try! Realm()
    var realmColDetails: RealmCollection!
    var notificationToken: NotificationToken? = nil
    var objectToken: NotificationToken? = nil
    var colId: Int = -1
    var loadFromServer = false
    
    weak var featureDelegate: MapFilterMenuDelegate?
    
    var boolFromChat: Bool = false
    var boolReadMore: Bool = false
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .white
        
        guard RealmCollection.filterCollectedPin(collection_id: colId) != nil else {
            return
        }
        
        loadColItems()
        loadTable()
        loadHeaderImg()
        loadFooter()
        loadHiddenHeader()
        loadHiddenSectionHeader()
        loadChooseOption()
        observeOnCollectionChange()
        ColListDetailHeader.boolExpandMore = false
        
//        print(realm.objects(CollectedPin.self))
    }
    
    deinit {
        objectToken?.invalidate()
    }
    
    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)
        ColListDetailHeader.boolExpandMore = false
    }
    
    // MARK: - Loading Parts
    
    fileprivate func loadColItems() {
        if btnMapView != nil {
            btnMapView.isEnabled = false
        }
        realmColDetails = RealmCollection.filterCollectedPin(collection_id: colId)
        getSavedItems(colId: colId)
    }
    
    fileprivate func loadHeaderImg() {
        imgHeader = UIImageView(frame: CGRect(x: 0, y: 0, width: screenWidth, height: 180))
        tblColListDetail.addSubview(imgHeader)
        imgHeader.image = enterMode == .place ? #imageLiteral(resourceName: "collection_placeHeader") : #imageLiteral(resourceName: "collection_locationHeader")
        
        uiviewAvatarShadow = UIView(frame: CGRect(x: 20, y: 139, width: 78, height: 78))
        uiviewAvatarShadow.layer.cornerRadius = 39
        uiviewAvatarShadow.layer.shadowColor = UIColor._182182182().cgColor
        uiviewAvatarShadow.layer.shadowOpacity = 1
        uiviewAvatarShadow.layer.shadowRadius = 8
        uiviewAvatarShadow.layer.shadowOffset = CGSize(width: 0, height: 1)
        
        imgAvatar = UIImageView(frame: CGRect(x: 0, y: 0, width: 58, height: 58))
        imgAvatar.layer.cornerRadius = 29
        imgAvatar.contentMode = .scaleAspectFill
        imgAvatar.clipsToBounds = true
        imgAvatar.layer.borderWidth = 5
        imgAvatar.layer.borderColor = UIColor.white.cgColor
        General.shared.avatar(userid: realmColDetails.user_id) { (avatarImage) in
            self.imgAvatar.image = avatarImage
            self.imgAvatar.isUserInteractionEnabled = true
        }
        
        imgHeader.addSubview(uiviewAvatarShadow)
        uiviewAvatarShadow.addSubview(imgAvatar)
    }
    
    fileprivate func loadHiddenHeader() {
        uiviewFixedHeader = UIView(frame: CGRect(x: 0, y: 0, width: screenWidth, height: 65 + device_offset_top))
        uiviewFixedHeader.backgroundColor = .white
        view.addSubview(uiviewFixedHeader)
        
        lblListName = UILabel(frame: CGRect(x: 20, y: 28 + device_offset_top, width: screenWidth - 40, height: 27))
        lblListName.font = UIFont(name: "AvenirNext-Medium", size: 20)
        lblListName.textColor = UIColor._898989()
        lblListName.text = realmColDetails.name
        lblListName.textAlignment = .center
        lblListName.lineBreakMode = .byTruncatingTail
        uiviewFixedHeader.addSubview(lblListName)
        
        let line = UIView(frame: CGRect(x: 0, y: 64 + device_offset_top, width: screenWidth, height: 1))
        line.backgroundColor = UIColor._200199204()
        uiviewFixedHeader.addSubview(line)
        uiviewFixedHeader.isHidden = true
    }
    
    fileprivate func loadHiddenSectionHeader() {
        uiviewFixedSectionHeader = UIView(frame: CGRect(x: 0, y: 65 + device_offset_top, width: screenWidth, height: 34))
        uiviewFixedSectionHeader.backgroundColor = .white
        view.addSubview(uiviewFixedSectionHeader)
        
        lblNum = UILabel(frame: CGRect(x: 20, y: 4, width: 80, height: 25))
        uiviewFixedSectionHeader.addSubview(lblNum)
        lblNum.textColor = UIColor._146146146()
        lblNum.font = UIFont(name: "AvenirNext-Medium", size: 18)
        lblNum.text = realmColDetails.pins.count > 1 ? "\(realmColDetails.pins.count) items" : "\(realmColDetails.pins.count) item"
        
        let lblDateAdded = UILabel(frame: CGRect(x: screenWidth - 110, y: 6, width: 90, height: 22))
        uiviewFixedSectionHeader.addSubview(lblDateAdded)
        lblDateAdded.textColor = UIColor._146146146()
        lblDateAdded.font = UIFont(name: "AvenirNext-Medium", size: 16)
        lblDateAdded.text = "Date Added"
        
        let line = UIView(frame: CGRect(x: 0, y: 33, width: screenWidth, height: 1))
        line.backgroundColor = UIColor._225225225()
        uiviewFixedSectionHeader.addSubview(line)
        uiviewFixedSectionHeader.isHidden = true
    }
    
    fileprivate func loadTable() {
        tblColListDetail = UITableView(frame: CGRect(x: 0, y: 0, width: screenWidth, height: screenHeight - 48 - device_offset_bot))
        view.addSubview(tblColListDetail)
        
        tblColListDetail.delegate = self
        tblColListDetail.dataSource = self
        tblColListDetail.separatorStyle = .none
        tblColListDetail.rowHeight = UITableViewAutomaticDimension
        tblColListDetail.showsVerticalScrollIndicator = false
        tblColListDetail.register(ColListDetailHeader.self, forCellReuseIdentifier: "ColListDetailHeader")
        tblColListDetail.register(ColListPlaceCell.self, forCellReuseIdentifier: "ColListPlaceCell")
        tblColListDetail.register(ColListLocationCell.self, forCellReuseIdentifier: "ColListLocationCell")
        tblColListDetail.register(ColListEmptyCell.self, forCellReuseIdentifier: "ColListEmptyCell")
        
        if #available(iOS 11.0, *) {
            tblColListDetail.contentInsetAdjustmentBehavior = .never
        } else {
            automaticallyAdjustsScrollViewInsets = false
        }
    }
    
    fileprivate func loadFooter() {
        uiviewFooter = UIView(frame: CGRect(x: 0, y: screenHeight - 49 - device_offset_bot, width: screenWidth, height: 49 + device_offset_bot))
        view.addSubview(uiviewFooter)
        
        let line = UIView(frame: CGRect(x: 0, y: 0, width: screenWidth, height: 1))
        line.backgroundColor = UIColor._200199204()
        uiviewFooter.addSubview(line)
        
        btnBack = UIButton(frame: CGRect(x: 0, y: 1, width: 40.5, height: 48))
        btnBack.setImage(#imageLiteral(resourceName: "navigationBack"), for: .normal)
        btnBack.addTarget(self, action: #selector(actionBack(_:)), for: .touchUpInside)
        
        btnMapView = UIButton(frame: CGRect(x: screenWidth / 2 - 77, y: 2, width: 47, height: 47))
        btnMapView.setImage(#imageLiteral(resourceName: "mb_allPlaces"), for: .normal)
        btnMapView.tag = 0
        btnMapView.addTarget(self, action: #selector(tabButtonPressed(_:)), for: .touchUpInside)
        
        btnShare = UIButton(frame: CGRect(x: screenWidth / 2 + 30, y: 2, width: 47, height: 47))
        btnShare.setImage(#imageLiteral(resourceName: "place_share"), for: .normal)
        btnShare.tag = 1
        btnShare.addTarget(self, action: #selector(tabButtonPressed(_:)), for: .touchUpInside)
        
        btnMore = UIButton(frame: CGRect(x: screenWidth - 5 - 47, y: 2, width: 47, height: 47))
        btnMore.setImage(#imageLiteral(resourceName: "pinDetailMore"), for: .normal)
        btnMore.addTarget(self, action: #selector(moreButtonPressed(_:)), for: .touchUpInside)
        
        uiviewFooter.addSubview(btnBack)
        uiviewFooter.addSubview(btnMapView)
        uiviewFooter.addSubview(btnShare)
        uiviewFooter.addSubview(btnMore)
        
        btnMore.isHidden = boolFromChat
    }
    
    @objc func actionBack(_ sender: UIButton) {
        navigationController?.popViewController(animated: true)
    }
    
    @objc func tabButtonPressed(_ sender: UIButton) {
        switch sender.tag {
        case 0: // map view
            var arrCtrlers = navigationController?.viewControllers
            if let ctrler = Key.shared.FMVCtrler {
                ctrler.arrCtrlers = arrCtrlers!
                ctrler.boolFromMap = false
            }
            while !(arrCtrlers?.last is InitialPageController) {
                arrCtrlers?.removeLast()
            }
            var arrSavedPinIds = [Int]()
            for pin in realmColDetails.pins {
                arrSavedPinIds.append(pin.pin_id)
            }
            featureDelegate = Key.shared.FMVCtrler
            featureDelegate?.showSavedPins(type: enterMode.rawValue, savedPinIds: arrSavedPinIds, isCollections: true, colName: realmColDetails.name)
            navigationController?.setViewControllers(arrCtrlers!, animated: false)
        case 1: // share
            // TODO JICHAO
            let vcShareCollection = NewChatShareController(friendListMode: .collection)
//            vcShareCollection.collectionDetail = arrColDetails
            vcShareCollection.collectionDetail = realmColDetails
            navigationController?.pushViewController(vcShareCollection, animated: true)
        default: break
        }
    }
    
    @objc func moreButtonPressed(_ sender: UIButton) {
        animationShowOptions()
    }
    
    // MARK: - TableView Delegates
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 2
    }
    
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return section == 1 ? 34 : 0
    }
    
    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        if section == 1 {
            let uiviewSectionHeader = UIView()
            uiviewSectionHeader.backgroundColor = .white
            lblItemsNum = UILabel(frame: CGRect(x: 20, y: 4, width: 80, height: 25))
            uiviewSectionHeader.addSubview(lblItemsNum)
            lblItemsNum.textColor = UIColor._146146146()
            lblItemsNum.font = UIFont(name: "AvenirNext-Medium", size: 18)
            lblItemsNum.text = realmColDetails.pins.count > 1 ? "\(realmColDetails.pins.count) items" : "\(realmColDetails.pins.count) item"
            
            let lblDateAdded = UILabel(frame: CGRect(x: screenWidth - 110, y: 6, width: 90, height: 22))
            uiviewSectionHeader.addSubview(lblDateAdded)
            lblDateAdded.textColor = UIColor._146146146()
            lblDateAdded.font = UIFont(name: "AvenirNext-Medium", size: 16)
            lblDateAdded.text = "Date Added"
            
            let line = UIView(frame: CGRect(x: 0, y: 33, width: screenWidth, height: 1))
            line.backgroundColor = UIColor._225225225()
            uiviewSectionHeader.addSubview(line)
            
            return uiviewSectionHeader
        }
        return nil
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        if indexPath.section == 1 {
            if realmColDetails.pins.count == 0 {
                return 312
            } else {
                tblColListDetail.rowHeight = UITableViewAutomaticDimension
                tblColListDetail.estimatedRowHeight = 100
                return tblColListDetail.rowHeight
            }
        } else {
            tblColListDetail.estimatedRowHeight = 400
            return tblColListDetail.rowHeight
        }
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if section == 0 {
            return 1
        } else {
            return realmColDetails.pins.count == 0 ? 1 : realmColDetails.pins.count
        }
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        if indexPath.section == 0 {
            var cell: ColListDetailHeader
            if boolReadMore {
                cell = tblColListDetail.cellForRow(at: IndexPath(row: 0, section: 0)) as! ColListDetailHeader
                cell.loadDescription(colInfo: realmColDetails)
                boolReadMore = false
                return cell
            }
            cell = tableView.dequeueReusableCell(withIdentifier: "ColListDetailHeader", for: indexPath) as! ColListDetailHeader
            cell.delegate = self
            cell.updateValueForCell(colInfo: realmColDetails)
            cell.loadDescription(colInfo: realmColDetails)
            return cell
        } else {
            if realmColDetails.pins.count == 0 {
                let cell = tableView.dequeueReusableCell(withIdentifier: "ColListEmptyCell", for: indexPath) as! ColListEmptyCell
                let img = enterMode == .place ? #imageLiteral(resourceName: "collection_noPlaceList") : #imageLiteral(resourceName: "collection_noLocList")
                cell.setValueForCell(img: img)
                return cell
            } else {
                let idx = realmColDetails.pins.count - indexPath.row - 1
                if enterMode == .location {
                    let cell = tableView.dequeueReusableCell(withIdentifier: "ColListLocationCell", for: indexPath) as! ColListLocationCell
                    cell.indexPath = indexPath
                    cell.setValueForLocationPin(locId: realmColDetails.pins[idx].pin_id)
                    cell.selectedLocId = realmColDetails.pins[idx].pin_id
                    return cell
                } else {
                    let cell = tableView.dequeueReusableCell(withIdentifier: "ColListPlaceCell", for: indexPath) as! ColListPlaceCell
                    cell.indexPath = indexPath
                    cell.setValueForPlacePin(placeId: realmColDetails.pins[idx].pin_id)
                    return cell
                }
            }
        }
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if indexPath.section != 1 || realmColDetails.pins.count == 0 {
            return
        }
        
        if enterMode == .place {
            let cell = tableView.cellForRow(at: indexPath) as! ColListPlaceCell
            let vc = PlaceDetailViewController()
            vc.enterMode = .collection
            vc.place = cell.selectedPlace
            navigationController?.pushViewController(vc, animated: true)
        } else {
            let cell = tableView.cellForRow(at: indexPath) as! ColListLocationCell
            let vc = LocDetailViewController()
            vc.enterMode = .collection
            vc.locationId = cell.selectedLocId
            vc.coordinate = cell.coordinate
//            vc.delegate = self
//            vc.featureDelegate = self
            vc.strLocName = cell.lblItemName.text ?? "Invalid Name"
            var addr = "Invalid Address"
            if cell.lblItemAddr_1.text! != "" && cell.lblItemAddr_2.text! != "" {
                addr = cell.lblItemAddr_1.text! + ", " + cell.lblItemAddr_2.text!
            }
            vc.strLocAddr = addr
            navigationController?.pushViewController(vc, animated: true)
        }
    }
    
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        if imgHeader != nil {
            var frame = imgHeader.frame
            if tblColListDetail.contentOffset.y < 0 * screenHeightFactor {
                frame.origin.y = tblColListDetail.contentOffset.y
                imgHeader.frame = frame
            } else {
                frame.origin.y = 0
                imgHeader.frame = frame
            }
        }
        
        if tblColListDetail.contentOffset.y >= 236 - device_offset_top {
            uiviewFixedHeader.isHidden = false
        } else {
            uiviewFixedHeader.isHidden = true
        }
        if uiviewFixedSectionHeader != nil {
            if tblColListDetail.contentOffset.y >= tblColListDetail.rect(forSection: 0).height - 65 - device_offset_top && tblColListDetail.contentOffset.y >= 0 {
                uiviewFixedSectionHeader.isHidden = false
            } else {
                uiviewFixedSectionHeader.isHidden = true
            }
        }
    }
    
    var desiredCount = 0
    var fetchedCount = 0 {
        didSet {
            guard desiredCount != 0 && fetchedCount != 0 else { return }
            if fetchedCount == desiredCount {
                tblColListDetail.reloadData()
                loadFromServer = false
            }
        }
    }
    
    func getSavedItems(colId: Int) {
        desiredCount = realmColDetails.count
        if desiredCount == realmColDetails.pins.count {
//            print("self.realmColDetails \(self.realmColDetails)")
            
            if btnMapView != nil {
                btnMapView.isEnabled = true
            }
            for collectedPin in self.realmColDetails.pins {
                FaeMap.shared.getPin(type: self.enterMode.rawValue, pinId: String(collectedPin.pin_id)) { (status, message) in
                    guard status / 100 == 2 else { return }
                    guard message != nil else { return }
                    let resultJson = JSON(message!)
                    let placeInfo = PlacePin(json: resultJson)
                    faePlaceInfoCache.setObject(placeInfo as AnyObject, forKey: collectedPin.pin_id as AnyObject)
                    self.fetchedCount += 1
                }
            }
            return
        }
        
        if self.realmColDetails.pins.count != 0 {
            try! self.realm.write {
                self.realmColDetails.pins.removeAll()
            }
        }

        FaeCollection.shared.getOneCollection(String(colId), completion: { (status, message) in
            guard status / 100 == 2 else { return }
            guard message != nil else { return }
            let resultJson = JSON(message!)
            let arrLocPinId = resultJson["pins"].arrayValue//.reversed()
//            print(arrLocPinId)

            self.loadFromServer = true
            
            if self.btnMapView != nil {
                self.btnMapView.isEnabled = self.desiredCount != 0
            }
            
            let col = RealmCollection.filterCollectedPin(collection_id: colId)
            for pin in arrLocPinId {
                let collectedPin = CollectedPin(pin_id: pin["pin_id"].intValue, added_at: pin["added_at"].stringValue)
                collectedPin.setPrimaryKeyInfo(pin["pin_id"].intValue, pin["added_at"].stringValue)
        
                try! self.realm.write {
                    col?.pins.append(collectedPin)
                }
            }
            
            for collectedPin in arrLocPinId {
                FaeMap.shared.getPin(type: self.enterMode.rawValue, pinId: collectedPin["pin_id"].stringValue) { (status, message) in
                    guard status / 100 == 2 else { return }
                    guard message != nil else { return }
                    let resultJson = JSON(message!)
                    let placeInfo = PlacePin(json: resultJson)
                    faePlaceInfoCache.setObject(placeInfo as AnyObject, forKey: collectedPin["pin_id"].intValue as AnyObject)
                    self.fetchedCount += 1
                }
            }
        })
    }
    
    // MARK: - ColListDetailHeaderDelegate
    func readMore() {
        boolReadMore = true
        UIView.setAnimationsEnabled(false)
        tblColListDetail.reloadSections(IndexSet(integer: 0), with: .none)
        UIView.setAnimationsEnabled(true)
    }
    
    private func observeOnCollectionChange() {
        objectToken = realmColDetails.observe { change in
            guard let tableview = self.tblColListDetail else { return }
            switch change {
            case .change:
                print("colDetails change")
                if self.loadFromServer {
                    return
                }
                self.lblListName.text = self.realmColDetails.name
                self.lblNum.text = self.realmColDetails.count > 1 ? "\(self.realmColDetails.count) items" : "\(self.realmColDetails.count) item"
                tableview.reloadData()
            case .error(let error):
                print(error)
            case .deleted:
                print("The object was deleted")
            }
        }
    }
}

// MARK: -
protocol ColListDetailHeaderDelegate: class {
    func readMore()
}

// MARK: -
class ColListDetailHeader: UITableViewCell {
    var lblName: UILabel!
    var lblTime: UILabel!
    var lblDesp: UILabel!
    var line: UIView!
    var uiviewReadMore: UIView!
    static var boolExpandMore = false
    weak var delegate: ColListDetailHeaderDelegate?
    
    override init(style: UITableViewCellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        selectionStyle = .none
        loadCellContent()
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    fileprivate func loadCellContent() {
        lblName = UILabel()
        lblName.numberOfLines = 0
        lblName.font = UIFont(name: "AvenirNext-Medium", size: 20)
        lblName.textColor = UIColor._898989()
        addSubview(lblName)
        addConstraintsWithFormat("H:|-25-[v0]-25-|", options: [], views: lblName)
        
        lblTime = UILabel()
        addSubview(lblTime)
        
        addConstraintsWithFormat("H:|-25-[v0]-25-|", options: [], views: lblTime)
        
        lblDesp = UILabel()
        lblDesp.numberOfLines = 0
        addSubview(lblDesp)
        addConstraintsWithFormat("H:|-25-[v0]-25-|", options: [], views: lblDesp)

        uiviewReadMore = UIView()
        lblDesp.addSubview(uiviewReadMore)
        lblDesp.addConstraintsWithFormat("V:|-50-[v0(25)]", options: [], views: uiviewReadMore)
        lblDesp.addConstraintsWithFormat("H:[v0(115)]-2-|", options: [], views: uiviewReadMore)
        uiviewReadMore.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(getFullDesp(_:))))
        lblDesp.isUserInteractionEnabled = true
        
        line = UIView()
        line.backgroundColor = UIColor._241241241()
        addSubview(line)
        addConstraintsWithFormat("H:|-0-[v0]-0-|", options: [], views: line)
        addConstraintsWithFormat("V:|-212-[v0]-5-[v1(22)]-10-[v2]-20-[v3(5)]-0-|", options: [], views: lblName, lblTime, lblDesp, line)
    }
    
    func updateValueForCell(colInfo: RealmCollection) {
        let attribute = [NSAttributedStringKey.font: UIFont(name: "AvenirNext-Medium", size: 16)!, NSAttributedStringKey.foregroundColor: UIColor._146146146()]
        let nameAttr = [NSAttributedStringKey.font: UIFont(name: "AvenirNext-DemiBold", size: 16)!, NSAttributedStringKey.foregroundColor: UIColor._2499090()]
        let curtStr = NSMutableAttributedString(string: "by ", attributes: attribute)
        
        FaeGenderView.shared.loadGenderAge(id: colInfo.user_id) { (nickName, _, _) in
            let nameStr = NSMutableAttributedString(string: nickName, attributes: nameAttr)
            let updateTime = colInfo.last_updated_at
            let updateDate = updateTime.split(separator: " ")[0].split(separator: "-")
            let lastUpdate = updateDate[1] + "/" + updateDate[0]
            let updateStr = NSMutableAttributedString(string: " ::: Updated \(lastUpdate)", attributes: attribute)
            curtStr.append(nameStr)
            curtStr.append(updateStr)
            
            self.lblTime.attributedText = curtStr
        }
        
        lblName.text = colInfo.name
    }
    
    func loadDescription(colInfo: RealmCollection) {
        let despAttr = [NSAttributedStringKey.font: UIFont(name: "AvenirNext-Medium", size: 18)!, NSAttributedStringKey.foregroundColor: UIColor._115115115()]
        lblDesp.attributedText = NSAttributedString(string: colInfo.descrip, attributes: despAttr)
        
        let (lineCount, newDesp) = getReadMoreDesp(colInfo.descrip)
        if lineCount <= 3 || ColListDetailHeader.boolExpandMore {
            uiviewReadMore.isHidden = true
            lblDesp.numberOfLines = 0
            addConstraintsWithFormat("V:|-212-[v0]-5-[v1(22)]-10-[v2]-20-[v3(5)]-0-|", options: [], views: lblName, lblTime, lblDesp, line)
        } else {
            let moreAttr = [NSAttributedStringKey.font: UIFont(name: "AvenirNext-Medium", size: 18)!, NSAttributedStringKey.foregroundColor: UIColor._2499090()]
            let newDesp = NSMutableAttributedString(string: newDesp + "... ", attributes: despAttr)
            newDesp.append(NSAttributedString(string: "Read More", attributes: moreAttr))
            lblDesp.attributedText = newDesp
            lblDesp.numberOfLines = 3
            uiviewReadMore.isHidden = false
        }
    }

    
    func getReadMoreDesp(_ desp: String) -> (Int, String) {
        for endIndex in 0..<desp.count {
            let newDesp = (desp as NSString).substring(to: endIndex) + "... Read More"
            let height = newDesp.boundingRect(with: CGSize(width: screenWidth - 50, height: CGFloat(MAXFLOAT)), options: .usesLineFragmentOrigin, attributes: [NSAttributedStringKey.font: UIFont(name: "AvenirNext-Medium", size: 18)!], context: nil).size.height
            if height > 74.0 { // 3 lines
                return (4, (desp as NSString).substring(to: endIndex - 1))
            }
            if endIndex == desp.count - 1 {
                return (1, desp)
            }
        }
        return (0, "")
    }
    
    @objc func getFullDesp(_ recognizer: UITapGestureRecognizer) {
        if recognizer.state == .ended {
            ColListDetailHeader.boolExpandMore = true
            delegate?.readMore()
        }
    }
}

class ColListEmptyCell: UITableViewCell {
    var imgEmpty: UIImageView!
    
    override init(style: UITableViewCellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        selectionStyle = .none
        loadCellContent()
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    fileprivate func loadCellContent() {
        imgEmpty = UIImageView(frame: CGRect(x: 0, y: 60, width: screenWidth, height: 193))
        imgEmpty.contentMode = .center
        addSubview(imgEmpty)
    }
    
    func setValueForCell(img: UIImage) {
        imgEmpty.image = img
    }
}

extension CollectionsListDetailViewController {
    fileprivate func loadChooseOption() {
        uiviewShadowBG = UIView(frame: CGRect(x: 0, y: 0, width: screenWidth, height: screenHeight))
        uiviewShadowBG.backgroundColor = UIColor._107105105_a50()
        view.addSubview(uiviewShadowBG)
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(actionCancel(_:)))
        uiviewShadowBG.addGestureRecognizer(tapGesture)
        
        uiviewChooseAction = UIView(frame: CGRect(x: 0, y: 200, w: 290, h: 302))
        uiviewChooseAction.center.x = screenWidth / 2
        uiviewChooseAction.backgroundColor = .white
        uiviewChooseAction.layer.cornerRadius = 20
        uiviewShadowBG.addSubview(uiviewChooseAction)
        
        uiviewShadowBG.alpha = 0
        uiviewChooseAction.alpha = 0
        
        lblChoose = UILabel(frame: CGRect(x: 0, y: 20, w: 290, h: 25))
        lblChoose.textAlignment = .center
        lblChoose.text = "Choose an Option"
        lblChoose.textColor = UIColor._898989()
        lblChoose.font = UIFont(name: "AvenirNext-Medium", size: 18 * screenHeightFactor)
        uiviewChooseAction.addSubview(lblChoose)
        
        btnActFirst = UIButton(frame: CGRect(x: 41, y: 65, w: 208, h: 50))
        btnActSecond = UIButton(frame: CGRect(x: 41, y: 130, w: 208, h: 50))
        btnActThird = UIButton(frame: CGRect(x: 41, y: 195, w: 208, h: 50))
        btnActFirst.setTitle("Manage", for: .normal)
        btnActSecond.setTitle("Settings", for: .normal)
        btnActThird.setTitle("Delete", for: .normal)
        
        var btnActions = [UIButton]()
        btnActions.append(btnActFirst)
        btnActions.append(btnActSecond)
        btnActions.append(btnActThird)
        
        for i in 0..<btnActions.count {
            btnActions[i].tag = i
            btnActions[i].setTitleColor(UIColor._2499090(), for: .normal)
            btnActions[i].titleLabel?.font = UIFont(name: "AvenirNext-DemiBold", size: 18 * screenHeightFactor)
            btnActions[i].addTarget(self, action: #selector(actionChooseOption(_:)), for: .touchUpInside)
            btnActions[i].layer.borderWidth = 2
            btnActions[i].layer.borderColor = UIColor._2499090().cgColor
            btnActions[i].layer.cornerRadius = 26 * screenWidthFactor
            uiviewChooseAction.addSubview(btnActions[i])
        }
        
        btnCancel = UIButton()
        btnCancel.setTitle("Cancel", for: .normal)
        btnCancel.setTitleColor(UIColor._2499090(), for: .normal)
        btnCancel.titleLabel?.font = UIFont(name: "AvenirNext-Medium", size: 18 * screenHeightFactor)
        btnCancel.addTarget(self, action: #selector(actionCancel(_:)), for: .touchUpInside)
        uiviewChooseAction.addSubview(btnCancel)
        view.addConstraintsWithFormat("H:|-80-[v0]-80-|", options: [], views: btnCancel)
        view.addConstraintsWithFormat("V:[v0(25)]-\(15 * screenHeightFactor)-|", options: [], views: btnCancel)
        
        loadDeleteConfirm()
    }
    
    fileprivate func loadDeleteConfirm() {
        uiviewMsgHint = UIView(frame: CGRect(x: 0, y: 200, w: 290, h: 208))
        uiviewMsgHint.backgroundColor = .white
        uiviewMsgHint.center.x = screenWidth / 2
        uiviewMsgHint.layer.cornerRadius = 20 * screenWidthFactor
        uiviewMsgHint.isHidden = true
        
        btnCrossCancel = UIButton(frame: CGRect(x: 0, y: 0, w: 42, h: 40))
        btnCrossCancel.tag = 0
        btnCrossCancel.setImage(#imageLiteral(resourceName: "check_cross_red"), for: .normal)
        btnCrossCancel.addTarget(self, action: #selector(actionCancel(_:)), for: .touchUpInside)
        
        let lblMsgSent = UILabel(frame: CGRect(x: 0, y: 30, w: 290, h: 50))
        lblMsgSent.numberOfLines = 2
        lblMsgSent.textAlignment = .center
        lblMsgSent.font = UIFont(name: "AvenirNext-Medium", size: 18 * screenHeightFactor)
        lblMsgSent.textColor = UIColor._898989()
        lblMsgSent.text = "Are you sure you want \nto delete this list?"
        
        let lblMsg = UILabel(frame: CGRect(x: 0, y: 93, w: 290, h: 36))
        lblMsg.numberOfLines = 2
        lblMsg.textAlignment = .center
        lblMsg.font = UIFont(name: "AvenirNext-Medium", size: 13 * screenHeightFactor)
        lblMsg.textColor = UIColor._138138138()
        lblMsg.text = "This list cannot be recovered and all \nitems in this list will be removed."
        
        btnYes = UIButton(frame: CGRect(x: 41, y: 149, w: 208, h: 39))
        btnYes.setTitle("Yes", for: .normal)
        btnYes.setTitleColor(UIColor.white, for: .normal)
        btnYes.titleLabel?.font = UIFont(name: "AvenirNext-DemiBold", size: 18 * screenHeightFactor)
        btnYes.backgroundColor = UIColor._2499090()
        btnYes.layer.cornerRadius = 19 * screenWidthFactor
        btnYes.addTarget(self, action: #selector(actionYes(_:)), for: .touchUpInside)
        
        uiviewMsgHint.addSubview(lblMsgSent)
        uiviewMsgHint.addSubview(lblMsg)
        uiviewMsgHint.addSubview(btnCrossCancel)
        uiviewMsgHint.addSubview(btnYes)
        view.addSubview(uiviewMsgHint)
    }
    
    @objc func actionCancel(_ sender: Any) {
        animationHideOptions()
    }
    
    @objc func actionChooseOption(_ sender: UIButton) {
        switch sender.tag {
        case 0: // manage
            animationHideOptions()
            let vc = ManageColListViewController()
            vc.delegate = self
            vc.enterMode = enterMode
            vc.colId = colId
            present(vc, animated: true)
        case 1: // settings
            animationHideOptions()
            let vc = CreateColListViewController()
            vc.txtListName = realmColDetails.name
            vc.txtListDesp = realmColDetails.descrip
            vc.enterMode = enterMode
            vc.colId = colId
            present(vc, animated: true)
        case 2: // delete
            animationActionView()
        default: break
        }
    }
    
    @objc func actionYes(_ sender: UIButton) {
        FaeCollection.shared.deleteOneCollection(String(colId)) { (status: Int, message: Any?) in
            if status / 100 == 2 {
                self.animationHideOptions()
                
                // remove from realm
                guard let collection = self.realm.object(ofType: RealmCollection.self, forPrimaryKey: self.colId) else {
                    return
                }
                
                try! self.realm.write {
                    if collection.pins.count != 0 {
                        for pin in collection.pins {
                            guard let deletedPin = self.realm.object(ofType: CollectedPin.self, forPrimaryKey: "\(pin.pin_id)_\(pin.added_at)") else {
                                continue
                            }
                            self.realm.delete(deletedPin)
                        }
                    }
                    
                    self.realm.delete(collection)
                }
                
                self.navigationController?.popViewController(animated: true)
            } else {
                print("[Collections] Fail to Delete \(status) \(message!)")
            }
        }
    }
    
    // animations
    func animationActionView() {
        uiviewChooseAction.isHidden = true
        uiviewMsgHint.isHidden = false
        uiviewChooseAction.alpha = 0
        uiviewMsgHint.alpha = 0
        UIView.animate(withDuration: 0.25, delay: 0, options: .curveEaseOut, animations: {
            self.uiviewMsgHint.alpha = 1
        }, completion: nil)
    }
    
    func animationShowOptions() {
        uiviewShadowBG.alpha = 0
        uiviewChooseAction.alpha = 0
        UIView.animate(withDuration: 0.25, delay: 0, options: .curveEaseOut, animations: {
            self.uiviewShadowBG.alpha = 1
            self.uiviewChooseAction.alpha = 1
        }, completion: nil)
    }
    
    func animationHideOptions() {
        uiviewShadowBG.alpha = 1
        uiviewChooseAction.alpha = 1
        uiviewMsgHint.alpha = 1
        UIView.animate(withDuration: 0.25, delay: 0, options: .curveEaseOut, animations: {
            self.uiviewChooseAction.alpha = 0
            self.uiviewMsgHint.alpha = 0
            self.uiviewShadowBG.alpha = 0
        }, completion: { _ in
            self.uiviewChooseAction.isHidden = false
            self.uiviewMsgHint.isHidden = true
        })
    }
    // animations end
    
    // ManageColListDelegate
    func returnValBack() {
        let section = IndexSet(integer: 1)
        tblColListDetail.reloadSections(section, with: .none)
    }
}
