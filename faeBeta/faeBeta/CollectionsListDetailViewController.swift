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
    func deleteColList(indexPath: IndexPath)
    func updateColName(indexPath: IndexPath, name: String, numItems: Int)
}

class CollectionsListDetailViewController: UIViewController, UITableViewDelegate, UITableViewDataSource, UIScrollViewDelegate, ColListDetailHeaderDelegate, CreateColListDelegate {
    
    var enterMode: CollectionTableMode!
    var uiviewFixedHeader: UIView!
    var uiviewFixedSectionHeader: UIView!
    var lblListName: UILabel!
    var lblItemsNum: UILabel!
    var numItems: Int = 0
    var tblColListDetail: UITableView!
    var uiviewFooter: UIView!
    var btnBack: UIButton!
    var btnMapView: UIButton!
    var btnShare: UIButton!
    var btnMore: UIButton!
    var faeMap = FaeMap()
    var savedItems = [PlacePin]()
    
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
    
    var txtName: String = ""
    var txtDesp: String = ""
    var txtTime: String = "09/2017"
    
    var arrColDetails: CollectionList!
    var colId: Int = -1
    let faeCollection = FaeCollection()
    
    var indexPath: IndexPath!
    weak var delegate: CollectionsListDetailDelegate?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .white
        getSavedItems()
        loadTable()
        loadFooter()
        loadHiddenHeader()
        loadChooseOption()
        ColListDetailHeader.boolExpandMore = false
        loadColItems()
    }
    
    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)
        ColListDetailHeader.boolExpandMore = false
    }
    
    fileprivate func loadColItems() {
        faeCollection.getOneCollection(String(colId)) {(status: Int, message: Any?) in
            if status / 100 == 2 {
                let list = JSON(message!)
                self.arrColDetails = CollectionList(json: list)
                
                self.lblListName.text = self.arrColDetails.colName
                self.txtName = self.arrColDetails.colName
                self.txtDesp = self.arrColDetails.colDesp
//                self.txtTime = self.arrColDetails.colTime
                
                self.tblColListDetail.reloadData()
                print("[Get Collection items] Get Successfully")
            } else {
                print("[Get Collection items] Fail to Get \(status) \(message!)")
            }
        }
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
        let lblNum = UILabel(frame: CGRect(x: 20, y: 4, width: 80, height: 25))
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
        
        automaticallyAdjustsScrollViewInsets = false

        tblColListDetail.delegate = self
        tblColListDetail.dataSource = self
        tblColListDetail.separatorStyle = .none
        tblColListDetail.rowHeight = UITableViewAutomaticDimension
        tblColListDetail.showsVerticalScrollIndicator = false
        tblColListDetail.register(ColListDetailHeader.self, forCellReuseIdentifier: "ColListDetailHeader")
        tblColListDetail.register(AllPlacesCell.self, forCellReuseIdentifier: "AllPlacesCell")
        tblColListDetail.register(ColListEmptyCell.self, forCellReuseIdentifier: "ColListEmptyCell")
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
    }
    
    func actionBack(_ sender: UIButton) {
        print("txtName \(txtName)")
        delegate?.updateColName(indexPath: indexPath, name: txtName, numItems: 0)
        navigationController?.popViewController(animated: true)
    }
    
    func tabButtonPressed(_ sender: UIButton) {
        switch sender.tag {
        case 0:  // map view
            break
        case 1:  // share
            // TODO jichao
            
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
            return savedItems.count == 0 ? 312 : 90
        } else {
            tblColListDetail.estimatedRowHeight = 400
            return tblColListDetail.rowHeight
        }
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if section == 0 {
            return 1
        } else {
            return savedItems.count == 0 ? 1 : savedItems.count
        }
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        if indexPath.section == 0 {
            let cell = tableView.dequeueReusableCell(withIdentifier: "ColListDetailHeader", for: indexPath) as! ColListDetailHeader
            cell.delegate = self
            let img = enterMode == .place ? #imageLiteral(resourceName: "collection_placeHeader") : #imageLiteral(resourceName: "collection_locationHeader")
            cell.setValueForCell(img: img)
            cell.updateValueForCell(name: txtName, desp: txtDesp, time: txtTime)
            return cell
        } else {
            if savedItems.count == 0 {
                let cell = tableView.dequeueReusableCell(withIdentifier: "ColListEmptyCell", for: indexPath) as! ColListEmptyCell
                let img = enterMode == .place ? #imageLiteral(resourceName: "collection_noPlaceList") : #imageLiteral(resourceName: "collection_noLocList")
                cell.setValueForCell(img: img)
                return cell
            } else {
                let cell = tableView.dequeueReusableCell(withIdentifier: "AllPlacesCell", for: indexPath) as! AllPlacesCell
                cell.setValueForCell(place: savedItems[indexPath.row])
                return cell
            }
        }
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if indexPath.section == 1 && savedItems.count != 0 {
            
        }
    }
    
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        if tblColListDetail.contentOffset.y >= 244 {
            uiviewFixedHeader.isHidden = false
        } else {
            uiviewFixedHeader.isHidden = true
        }
        if uiviewFixedSectionHeader != nil {
            if tblColListDetail.contentOffset.y >= tblColListDetail.rect(forSection: 0).height - 65 &&  tblColListDetail.contentOffset.y >= 0 {
                uiviewFixedSectionHeader.isHidden = false
            } else {
                uiviewFixedSectionHeader.isHidden = true
            }
        }
    }
    
    func getSavedItems() {
        if enterMode == .place {
            faeMap.whereKey("is_place", value: "true")
            faeMap.getSavedPins() {(status: Int, message: Any?) in
                if status / 100 == 2 {
                    let savedPinsJSON = JSON(message!)
                    for i in 0..<savedPinsJSON.count {
                        let savedData = PlacePin(json: savedPinsJSON[i])
                        self.savedItems.append(savedData)
                    }
                    self.tblColListDetail.reloadData()
                    self.loadHiddenSectionHeader()
                }
                else {
                    print("Fail to get saved pins!")
                }
            }
        } else {
            loadHiddenSectionHeader()
        }
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
        txtTime = "09/2017"
        tblColListDetail.reloadRows(at: [IndexPath(row: 0, section: 0)], with: .none)
    }
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
        General.shared.avatar(userid: Key.shared.user_id, completion: { (avatarImage) in
            self.imgAvatar.image = avatarImage
        })
    }
    
    func updateValueForCell(name: String, desp: String, time: String) {
        let attribute = [NSFontAttributeName: UIFont(name: "AvenirNext-Medium", size: 16)!, NSForegroundColorAttributeName: UIColor._146146146()]
        let nameAttr = [NSFontAttributeName: UIFont(name: "AvenirNext-DemiBold", size: 16)!, NSForegroundColorAttributeName: UIColor._2499090()]
        let curtStr = NSMutableAttributedString(string: "by ", attributes: attribute)
        let nameStr = NSMutableAttributedString(string: "\(Key.shared.nickname ?? "Someone")", attributes: nameAttr)
        let updateStr = NSMutableAttributedString(string: " ::: Updated \(time)", attributes: attribute)
        
        curtStr.append(nameStr)
        curtStr.append(updateStr)
        
        lblTime.attributedText = curtStr
        lblName.text = name
        
        let despAttr = [NSFontAttributeName: UIFont(name: "AvenirNext-Medium", size: 18)!, NSForegroundColorAttributeName: UIColor._115115115()]
        lblDesp.attributedText = NSAttributedString(string: desp, attributes: despAttr)
        
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
            vc.enterMode = enterMode
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
        let faeCollection = FaeCollection()
        faeCollection.deleteOneCollection(String(colId)) {(status: Int, message: Any?) in
            if status / 100 == 2 {
                self.animationHideOptions()
                self.navigationController?.popViewController(animated: true)
                self.delegate?.deleteColList(indexPath: self.indexPath)
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
}
