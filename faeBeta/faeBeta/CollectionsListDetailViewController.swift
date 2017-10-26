//
//  CollectionsListDetailViewController.swift
//  faeBeta
//
//  Created by Faevorite 2 on 2017-08-24.
//  Copyright © 2017 fae. All rights reserved.
//

import UIKit
import SwiftyJSON

protocol CollectionsListDetailDelegate: class {
    func deleteColList(enterMode: CollectionTableMode, indexPath: IndexPath)
    func updateColName(enterMode: CollectionTableMode, indexPath: IndexPath, name: String, numItems: Int)
}

class CollectionsListDetailViewController: UIViewController, UITableViewDelegate, UITableViewDataSource, UIScrollViewDelegate, ColListDetailHeaderDelegate, CreateColListDelegate, ManageColListDelegate {
    
    var enterMode: CollectionTableMode!
    var uiviewFixedHeader: UIView!
    var uiviewFixedSectionHeader: UIView!
    var lblListName: UILabel!
    var lblItemsNum: UILabel!
    var numItems: Int = 0
    var lblNum: UILabel!
    var tblColListDetail: UITableView!
    var uiviewFooter: UIView!
    var btnBack: UIButton!
    var btnMapView: UIButton!
    var btnShare: UIButton!
    var btnMore: UIButton!
    var savedItems = [SavedPin]()
    var savedPlaces = [PlacePin]()
    
    // variables in extension file
    var uiviewShadowBG: UIView!
    var uiviewChooseAction: UIView!
    var lblChoose: UILabel!
    var btnActFirst: UIButton!
    var btnActSecond: UIButton!
    var btnActThird: UIButton!
    var btnCancel: UIButton!
    var uiviewMsgHint: UIView!
    var btnCrossCancel: UIButton!
    var btnYes: UIButton!
    
    var creatorId: Int = -1
    var txtName: String = ""
    var txtDesp: String = ""
    var txtTime: String = ""
    
    var arrColDetails: PinCollection!
    var colId: Int = -1
    var colInfo: PinCollection!
    
    var arrSavedPinIds = [Int]()
    
    var indexPath: IndexPath!
    
    weak var delegate: CollectionsListDetailDelegate?
    weak var featureDelegate: MapFilterMenuDelegate?
    
    var boolFromChat: Bool = false
    
    var intRemoveCount = 2
    
    var faeMapCtrler: FaeMapViewController?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .white
        loadTable()
        loadFooter()
        loadColItems()
        loadHiddenHeader()
        loadHiddenSectionHeader()
        loadChooseOption()
        ColListDetailHeader.boolExpandMore = false
    }
    
    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)
        ColListDetailHeader.boolExpandMore = false
    }
    
    fileprivate func loadColItems() {
        creatorId = arrColDetails.creatorId
        colId = arrColDetails.colId
        txtName = arrColDetails.colName
        txtDesp = arrColDetails.colDesp
        txtTime = arrColDetails.colTime
        numItems = arrColDetails.itemsCount
        btnMapView.isEnabled = false
        self.getSavedItems(colId: self.colId)
    }
    
    fileprivate func loadHiddenHeader() {
        uiviewFixedHeader = UIView(frame: CGRect(x: 0, y: 0, width: screenWidth, height: 65))
        uiviewFixedHeader.backgroundColor = .white
        view.addSubview(uiviewFixedHeader)
        
        lblListName = UILabel(frame: CGRect(x: 20, y: 28, width: screenWidth - 40, height: 27))
        lblListName.font = UIFont(name: "AvenirNext-Medium", size: 20)
        lblListName.textColor = UIColor._898989()
        lblListName.text = txtName
        lblListName.lineBreakMode = .byTruncatingTail
        lblListName.text = arrColDetails.colName
        uiviewFixedHeader.addSubview(lblListName)
        
        let line = UIView(frame: CGRect(x: 0, y: 64, width: screenWidth, height: 1))
        line.backgroundColor = UIColor._200199204()
        uiviewFixedHeader.addSubview(line)
        uiviewFixedHeader.isHidden = true
    }
    
    fileprivate func loadHiddenSectionHeader() {
        uiviewFixedSectionHeader = UIView(frame: CGRect(x: 0, y: 65, width: screenWidth, height: 34))
        uiviewFixedSectionHeader.backgroundColor = .white
        view.addSubview(uiviewFixedSectionHeader)
        
        lblNum = UILabel(frame: CGRect(x: 20, y: 4, width: 80, height: 25))
        uiviewFixedSectionHeader.addSubview(lblNum)
        lblNum.textColor = UIColor._146146146()
        lblNum.font = UIFont(name: "AvenirNext-Medium", size: 18)
        lblNum.text = "\(numItems) items"
        
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
        tblColListDetail = UITableView(frame: CGRect(x: 0, y: 0, width: screenWidth, height: screenHeight - 49))
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
        uiviewFooter = UIView(frame: CGRect(x: 0, y: screenHeight - 49, width: screenWidth, height: 49))
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
    
    func actionBack(_ sender: UIButton) {
        delegate?.updateColName(enterMode: enterMode, indexPath: indexPath, name: txtName, numItems: numItems)
        navigationController?.popViewController(animated: true)
    }
    
    func tabButtonPressed(_ sender: UIButton) {
        switch sender.tag {
        case 0: // map view
            var arrCtrlers = navigationController?.viewControllers
            if let ctrler = faeMapCtrler {
                ctrler.arrCtrlers = arrCtrlers!
                ctrler.boolFromMap = false
            }
            for _ in 0..<intRemoveCount {
                arrCtrlers?.removeLast()
            }
            featureDelegate?.showSavedPins(type: arrColDetails.colType, savedPinIds: arrSavedPinIds, isCollections: true, colName: arrColDetails.colName)
            navigationController?.setViewControllers(arrCtrlers!, animated: false)
            break
        case 1: // share
            // TODO: jichao
            let vcShareCollection = NewChatShareController(friendListMode: .collection)
            vcShareCollection.collectionDetail = arrColDetails
            navigationController?.pushViewController(vcShareCollection, animated: true)
            break
        default:
            break
        }
    }
    
    func moreButtonPressed(_ sender: UIButton) {
        animationShowOptions()
    }
    
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
            lblItemsNum.text = "\(numItems) items"
            
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
            if arrSavedPinIds.count == 0 {
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
            return arrSavedPinIds.count == 0 ? 1 : arrSavedPinIds.count
        }
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        if indexPath.section == 0 {
            let cell = tableView.dequeueReusableCell(withIdentifier: "ColListDetailHeader", for: indexPath) as! ColListDetailHeader
            cell.delegate = self
            let img = enterMode == .place ? #imageLiteral(resourceName: "collection_placeHeader") : #imageLiteral(resourceName: "collection_locationHeader")
            cell.setValueForCell(img: img)
            cell.updateValueForCell(colInfo: arrColDetails)
            return cell
        } else {
            if arrSavedPinIds.count == 0 {
                let cell = tableView.dequeueReusableCell(withIdentifier: "ColListEmptyCell", for: indexPath) as! ColListEmptyCell
                let img = enterMode == .place ? #imageLiteral(resourceName: "collection_noPlaceList") : #imageLiteral(resourceName: "collection_noLocList")
                cell.setValueForCell(img: img)
                return cell
            } else {
                if enterMode == .location {
                    let cell = tableView.dequeueReusableCell(withIdentifier: "ColListLocationCell", for: indexPath) as! ColListLocationCell
                    cell.setValueForLocationPin(locId: arrSavedPinIds[indexPath.row])
                    return cell
                } else {
                    let cell = tableView.dequeueReusableCell(withIdentifier: "ColListPlaceCell", for: indexPath) as! ColListPlaceCell
                    cell.setValueForPlacePin(placeId: arrSavedPinIds[indexPath.row])
//                    let test = ["12345","678","",""]
//                    cell.lblColMemo.text = test[indexPath.row]
                    return cell
                }
            }
        }
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if indexPath.section == 1 && arrSavedPinIds.count != 0 {
            
        }
    }
    
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        if tblColListDetail.contentOffset.y >= 244 {
            uiviewFixedHeader.isHidden = false
        } else {
            uiviewFixedHeader.isHidden = true
        }
        if uiviewFixedSectionHeader != nil {
            if tblColListDetail.contentOffset.y >= tblColListDetail.rect(forSection: 0).height - 65 && tblColListDetail.contentOffset.y >= 0 {
                uiviewFixedSectionHeader.isHidden = false
            } else {
                uiviewFixedSectionHeader.isHidden = true
            }
        }
    }
    
    func getSavedItems(colId: Int) {
        FaeCollection.shared.getOneCollection(String(colId), completion: { (status, message) in
            guard status / 100 == 2 else { return }
            guard message != nil else { return }
            let resultJson = JSON(message!)
            let arrLocPinId = resultJson["pins"].arrayValue
            self.arrSavedPinIds = arrLocPinId.map({ $0["pin_id"].intValue })
            joshprint(self.arrSavedPinIds)
            self.tblColListDetail.reloadData()
            self.btnMapView.isEnabled = true
        })
        
        if arrSavedPinIds.count == 0 {
            return
        }
        
        // 实在不行采用的办法
        /*
        for placeId in arrSavedPinIds {
            FaeMap.shared.getPin(type: "place", pinId: String(placeId)) { (status, message) in
                guard status / 100 == 2 else { return }
                guard message != nil else { return }
                let resultJson = JSON(message!)
                let placeInfo = PlacePin(json: resultJson)
                savedPlaces.append(placeInfo)
            }
        }
        */
    }
    
    // ColListDetailHeaderDelegate
    func readMore() {
        let section = IndexSet(integer: 0)
        tblColListDetail.reloadSections(section, with: .none)
    }
    // ColListDetailHeaderDelegate End
    
    // CreateColListDelegate
    func saveSettings(name: String, desp: String) {
        lblListName.text = name
        txtName = name
        txtDesp = desp
        
        let curtDate = Date()
        let dateformatter = DateFormatter()
        dateformatter.dateFormat = "YYYY-MM-dd HH:mm:ss"
        let date = dateformatter.string(from: curtDate).split(separator: " ")[0].split(separator: "-")
        txtTime = date[1] + "/" + date[0]
        arrColDetails.colName = txtName
        arrColDetails.colDesp = txtDesp
        arrColDetails.colTime = txtTime
        tblColListDetail.reloadRows(at: [IndexPath(row: 0, section: 0)], with: .none)
    }
    
    func updateCols(col: PinCollection) {}
    // CreateColListDelegate End
}

protocol ColListDetailHeaderDelegate: class {
    func readMore()
}

class ColListDetailHeader: UITableViewCell {
    var uiviewHiddenHeader: UIView!
    var uiviewAvatarShadow: UIView!
    var imgHeader: UIImageView!
    var imgAvatar: UIImageView!
    var lblName: UILabel!
    var lblTime: UILabel!
    var lblDesp: UILabel!
    var line: UIView!
    var btnReadMore: UIButton!
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
        imgHeader = UIImageView(frame: CGRect(x: 0, y: 0, width: screenWidth, height: 180))
        addSubview(imgHeader)
        
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
        
        addSubview(uiviewAvatarShadow)
        uiviewAvatarShadow.addSubview(imgAvatar)
        
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
        
        btnReadMore = UIButton()
        btnReadMore.backgroundColor = .white
        let despAttr = [NSFontAttributeName: UIFont(name: "AvenirNext-Medium", size: 18)!, NSForegroundColorAttributeName: UIColor._115115115()]
        let moreAttr = [NSFontAttributeName: UIFont(name: "AvenirNext-Medium", size: 18)!, NSForegroundColorAttributeName: UIColor._2499090()]
        let strReadMore = NSMutableAttributedString(string: "... ", attributes: despAttr)
        let more = NSMutableAttributedString(string: "Read More", attributes: moreAttr)
        strReadMore.append(more)
        btnReadMore.setAttributedTitle(strReadMore, for: .normal)
        btnReadMore.addTarget(self, action: #selector(getFullDesp(_:)), for: .touchUpInside)
        lblDesp.addSubview(btnReadMore)
        lblDesp.isUserInteractionEnabled = true
        lblDesp.addConstraintsWithFormat("V:|-50-[v0(25)]", options: [], views: btnReadMore)
        lblDesp.addConstraintsWithFormat("H:[v0(115)]-2-|", options: [], views: btnReadMore)
        
        line = UIView()
        line.backgroundColor = UIColor._241241241()
        addSubview(line)
        addConstraintsWithFormat("H:|-0-[v0]-0-|", options: [], views: line)
        addConstraintsWithFormat("V:|-212-[v0]-5-[v1(22)]-10-[v2]-20-[v3(5)]-0-|", options: [], views: lblName, lblTime, lblDesp, line)
    }
    
    func setValueForCell(img: UIImage) {
        imgHeader.image = img
        General.shared.avatar(userid: Key.shared.user_id, completion: { avatarImage in
            self.imgAvatar.image = avatarImage
        })
    }
    
    func updateValueForCell(colInfo: PinCollection) {
        
        General.shared.avatar(userid: colInfo.creatorId) { (avatarImage) in
            self.imgAvatar.image = avatarImage
            self.imgAvatar.isUserInteractionEnabled = true
        }
        
        let attribute = [NSFontAttributeName: UIFont(name: "AvenirNext-Medium", size: 16)!, NSForegroundColorAttributeName: UIColor._146146146()]
        let nameAttr = [NSFontAttributeName: UIFont(name: "AvenirNext-DemiBold", size: 16)!, NSForegroundColorAttributeName: UIColor._2499090()]
        let curtStr = NSMutableAttributedString(string: "by ", attributes: attribute)
        
        FaeGenderView.shared.loadGenderAge(id: colInfo.creatorId) { (nickName, _, _) in
            let nameStr = NSMutableAttributedString(string: nickName, attributes: nameAttr)
            let updateStr = NSMutableAttributedString(string: " ::: Updated \(colInfo.colTime)", attributes: attribute)
            curtStr.append(nameStr)
            curtStr.append(updateStr)
            
            self.lblTime.attributedText = curtStr
        }
        
        lblName.text = colInfo.colName
        
        let despAttr = [NSFontAttributeName: UIFont(name: "AvenirNext-Medium", size: 18)!, NSForegroundColorAttributeName: UIColor._115115115()]
        lblDesp.attributedText = NSAttributedString(string: colInfo.colDesp, attributes: despAttr)
        
        var lineCount: Int = 0
        let textSize = CGSize(width: screenWidth - 50, height: CGFloat(MAXFLOAT))
        let rHeight = Float(lblDesp.sizeThatFits(textSize).height)
        let charSize = Float(lblDesp.font.lineHeight)
        lineCount = lroundf(rHeight / charSize)
        //        print("textsize: \(textSize)")
        //        print("rHeight: \(rHeight)")
        //        print("charSize: \(charSize)")
        //        print("No of lines: \(lineCount)")
        
        //        print(lineCount)
        //        print(ColListDetailHeader.boolExpandMore)
        if lineCount <= 3 || ColListDetailHeader.boolExpandMore {
            btnReadMore.isHidden = true
            lblDesp.numberOfLines = 0
        } else {
            lblDesp.numberOfLines = 3
            btnReadMore.backgroundColor = .white
            btnReadMore.isHidden = false
        }
    }
    
    func getFullDesp(_ sender: UIButton) {
        ColListDetailHeader.boolExpandMore = true
        delegate?.readMore()
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
/*
class ColListPlaceCell: UITableViewCell {
    
    var imgSavedItem: FaeImageView!
    var lblItemName: UILabel!
    var lblItemAddr: UILabel!
    
    override init(style: UITableViewCellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        let separatorView = UIView(frame: CGRect(x: 89, y: 89, width: screenWidth - 89, height: 1))
        separatorView.backgroundColor = UIColor._206203203()
        addSubview(separatorView)
        selectionStyle = .none
        loadCellContent()
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    fileprivate func loadCellContent() {
        imgSavedItem = FaeImageView(frame: CGRect(x: 12, y: 12, width: 66, height: 66))
        imgSavedItem.layer.cornerRadius = 5
        imgSavedItem.clipsToBounds = true
        imgSavedItem.backgroundColor = .white
        imgSavedItem.contentMode = .scaleAspectFill
        addSubview(imgSavedItem)
        
        lblItemName = UILabel(frame: CGRect(x: 93, y: 26, width: screenWidth - 93, height: 22))
        lblItemName.textColor = UIColor._898989()
        lblItemName.font = UIFont(name: "AvenirNext-Medium", size: 15)
        addSubview(lblItemName)
        
        lblItemAddr = UILabel(frame: CGRect(x: 93, y: 48, width: screenWidth - 93, height: 16))
        lblItemAddr.textColor = UIColor._107105105()
        lblItemAddr.font = UIFont(name: "AvenirNext-Medium", size: 12)
        addSubview(lblItemAddr)
    }
    
    func setValueForCell(placeId: Int) {
        FaeMap.shared.getPin(type: "place", pinId: String(placeId)) { (status, message) in
            guard status / 100 == 2 else { return }
            guard message != nil else { return }
            let resultJson = JSON(message!)
            let placeInfo = PlacePin(json: resultJson)
            self.setValueForPlace(placeInfo)
        }
    }
    
    func setValueForPlace(_ placeInfo: PlacePin) {
        lblItemName.text = placeInfo.name
        lblItemAddr.text = placeInfo.address1 + ", " + placeInfo.address2
        imgSavedItem.backgroundColor = .white
        if placeInfo.imageURL == "" {
            imgSavedItem.image = UIImage(named: "place_result_\(placeInfo.class_2_icon_id)") ?? UIImage(named: "place_result_48")
            imgSavedItem.backgroundColor = .white
        } else {
            if let placeImgFromCache = placeInfoBarImageCache.object(forKey: placeInfo.imageURL as AnyObject) as? UIImage {
                self.imgSavedItem.image = placeImgFromCache
                self.imgSavedItem.backgroundColor = UIColor._2499090()
                return
            }
            downloadImage(URL: placeInfo.imageURL) { (rawData) in
                guard let data = rawData else { return }
                DispatchQueue.global(qos: .userInitiated).async {
                    guard let placeImg = UIImage(data: data) else { return }
                    DispatchQueue.main.async {
                        self.imgSavedItem.image = placeImg
                        self.imgSavedItem.backgroundColor = UIColor._2499090()
                        placeInfoBarImageCache.setObject(placeImg, forKey: placeInfo.imageURL as AnyObject)
                    }
                }
            }
        }
    }
}

let faeLocationCache = NSCache<AnyObject, AnyObject>()
let faeLocationInfoCache = NSCache<AnyObject, AnyObject>()

class ColListLocationCell: UITableViewCell {
    
    var imgSavedItem: FaeImageView!
    var lblItemName: UILabel!
    var lblItemAddr_1: UILabel!
    var lblItemAddr_2: UILabel!
    
    override init(style: UITableViewCellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        let separatorView = UIView(frame: CGRect(x: 89, y: 89, width: screenWidth - 89, height: 1))
        separatorView.backgroundColor = UIColor._206203203()
        addSubview(separatorView)
        selectionStyle = .none
        loadCellContent()
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    fileprivate func loadCellContent() {
        imgSavedItem = FaeImageView(frame: CGRect(x: 12, y: 12, width: 66, height: 66))
        imgSavedItem.clipsToBounds = true
        imgSavedItem.contentMode = .scaleAspectFill
        addSubview(imgSavedItem)
        let icon = UIImageView(frame: CGRect(x: 23, y: 22, width: 19, height: 24))
        icon.contentMode = .scaleAspectFit
        icon.image = #imageLiteral(resourceName: "icon_destination")
        imgSavedItem.addSubview(icon)
        
        lblItemName = UILabel(frame: CGRect(x: 93, y: 18, width: screenWidth - 110, height: 22))
        lblItemName.textColor = UIColor._898989()
        lblItemName.font = UIFont(name: "AvenirNext-Medium", size: 15)
        addSubview(lblItemName)
        
        lblItemAddr_1 = UILabel(frame: CGRect(x: 93, y: 40, width: screenWidth - 93, height: 16))
        lblItemAddr_1.textColor = UIColor._107105105()
        lblItemAddr_1.font = UIFont(name: "AvenirNext-Medium", size: 12)
        addSubview(lblItemAddr_1)
        
        lblItemAddr_2 = UILabel(frame: CGRect(x: 93, y: 57, width: screenWidth - 93, height: 16))
        lblItemAddr_2.textColor = UIColor._107105105()
        lblItemAddr_2.font = UIFont(name: "AvenirNext-Medium", size: 12)
        addSubview(lblItemAddr_2)
    }
    
    func setValueForLocationPin(locId: Int) {
        self.imgSavedItem.alpha = 0
        self.lblItemName.alpha = 0
        self.lblItemAddr_1.alpha = 0
        self.lblItemAddr_2.alpha = 0
        if let locationFromCache = faeLocationCache.object(forKey: locId as AnyObject) as? JSON {
            let lat = locationFromCache["geolocation"]["latitude"].doubleValue
            let lon = locationFromCache["geolocation"]["longitude"].doubleValue
            let location = CLLocation(latitude: lat, longitude: lon)
            self.imgSavedItem.fileID = locationFromCache["file_ids"].intValue
            self.imgSavedItem.loadImage(id: locationFromCache["file_ids"].intValue)
            UIView.animate(withDuration: 0.1, animations: {
                self.imgSavedItem.alpha = 1
            })
            self.getAddressForLocation(locId, location)
            return
        }
        FaeMap.shared.getPin(type: "location", pinId: String(locId)) { (status, message) in
            guard status / 100 == 2 else { return }
            guard message != nil else { return }
            let resultJson = JSON(message!)
            faeLocationCache.setObject(resultJson as AnyObject, forKey: locId as AnyObject)
            let lat = resultJson["geolocation"]["latitude"].doubleValue
            let lon = resultJson["geolocation"]["longitude"].doubleValue
            let location = CLLocation(latitude: lat, longitude: lon)
            self.imgSavedItem.fileID = resultJson["file_ids"].intValue
            self.imgSavedItem.loadImage(id: resultJson["file_ids"].intValue)
            self.getAddressForLocation(locId, location)
            UIView.animate(withDuration: 0.1, animations: {
                self.imgSavedItem.alpha = 1
            })
        }
    }
    
    func getAddressForLocation(_ locId: Int, _ location: CLLocation) {
        if let locationFromCache = faeLocationInfoCache.object(forKey: locId as AnyObject) as? [String] {
            self.lblItemName.text = locationFromCache[0]
            self.lblItemAddr_1.text = locationFromCache[1]
            self.lblItemAddr_2.text = locationFromCache[2]
            UIView.animate(withDuration: 0.1, animations: {
                self.lblItemName.alpha = 1
                self.lblItemAddr_1.alpha = 1
                self.lblItemAddr_2.alpha = 1
            })
            return
        }
        General.shared.getAddress(location: location, original: true) { (original) in
            guard let first = original as? CLPlacemark else { return }
            
            var name = ""
            var subThoroughfare = ""
            var thoroughfare = ""
            
            var address_1 = ""
            var address_2 = ""
            var address_3 = ""
            
            if let n = first.name {
                name = n
                address_1 += n
            }
            if let s = first.subThoroughfare {
                subThoroughfare = s
                if address_1 != "" {
                    address_1 += ", "
                }
                address_1 += s
            }
            if let t = first.thoroughfare {
                thoroughfare = t
                if address_1 != "" {
                    address_1 += ", "
                }
                address_1 += t
            }
            
            if name == subThoroughfare + " " + thoroughfare {
                address_1 = name
            }
            
            if let l = first.locality {
                address_2 += l
            }
            if let a = first.administrativeArea {
                if address_2 != "" {
                    address_2 += ", "
                }
                address_2 += a
            }
            if let p = first.postalCode {
                address_2 += " " + p
            }
            if let c = first.country {
                address_3 += c
            }
            
            DispatchQueue.main.async {
                self.lblItemName.text = address_1
                self.lblItemAddr_1.text = address_2
                self.lblItemAddr_2.text = address_3
                var arrAddrs = [String]()
                arrAddrs.append(address_1)
                arrAddrs.append(address_2)
                arrAddrs.append(address_3)
                faeLocationInfoCache.setObject(arrAddrs as AnyObject, forKey: locId as AnyObject)
                UIView.animate(withDuration: 0.1, animations: {
                    self.lblItemName.alpha = 1
                    self.lblItemAddr_1.alpha = 1
                    self.lblItemAddr_2.alpha = 1
                })
            }
        }
    }
}
*/
extension CollectionsListDetailViewController {
    fileprivate func loadChooseOption() {
        uiviewShadowBG = UIView(frame: CGRect(x: 0, y: 0, width: screenWidth, height: screenHeight))
        uiviewShadowBG.backgroundColor = UIColor(r: 107, g: 105, b: 105, alpha: 70)
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
    
    func actionCancel(_ sender: Any) {
        animationHideOptions()
    }
    
    func actionChooseOption(_ sender: UIButton) {
        switch sender.tag {
        case 0: // manage
            animationHideOptions()
            let vc = ManageColListViewController()
            vc.delegate = self
            vc.enterMode = enterMode
//            vc.arrColList = savedItems
            vc.arrSavedIds = arrSavedPinIds
            vc.colId = colId
            present(vc, animated: true)
            break
        case 1: // settings
            animationHideOptions()
            let vc = CreateColListViewController()
            vc.delegate = self
            vc.txtListName = txtName
            vc.txtListDesp = txtDesp
            vc.colId = colId
            present(vc, animated: true)
            break
        case 2: // delete
            animationActionView()
            break
        default:
            break
        }
    }
    
    func actionYes(_ sender: UIButton) {
        FaeCollection.shared.deleteOneCollection(String(colId)) { (status: Int, message: Any?) in
            if status / 100 == 2 {
                self.animationHideOptions()
                self.navigationController?.popViewController(animated: true)
                self.delegate?.deleteColList(enterMode: self.enterMode, indexPath: self.indexPath)
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
//        self.savedItems = savedItems
//        numItems = savedItems.count
//        if lblNum != nil {
//            lblNum.text = "\(numItems) items"
//        }
        
        let section = IndexSet(integer: 1)
        tblColListDetail.reloadSections(section, with: .none)
    }
}
