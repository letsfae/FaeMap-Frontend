//
//  ExploreViewController.swift
//  faeBeta
//
//  Created by Yue Shen on 9/12/17.
//  Modified by Yue Shen on 5/7/18.
//  Copyright © 2017 fae. All rights reserved.
//

import UIKit
import SwiftyJSON
import CoreLocation

protocol ExploreDelegate: class {
    func jumpToExpPlacesCollection(places: [PlacePin], category: String)
}

class ExploreViewController: UIViewController, UICollectionViewDelegate, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout, AddPinToCollectionDelegate, AfterAddedToListDelegate, GeneralLocationSearchDelegate, EXPCellDelegate {
    
    // MARK: - Variables
    
    // MARK: Main Items
    weak var delegate: ExploreDelegate?
    
    private var uiviewNavBar: FaeNavBar!
    private var clctViewTypes: UICollectionView!
    private var clctViewPics: UICollectionView!
    private var lblBottomLocation: UILabel!
    private var btnGoLeft: UIButton!
    private var btnGoRight: UIButton!
    private var btnSave: UIButton!
    private var btnRefresh: UIButton!
    private var btnMap: UIButton!
    private var imgSaved: UIImageView!
    
    private var intCurtPage = 0
    
    private var categories: [String] = ["Random", "Food", "Drinks", "Shopping", "Outdoors", "Recreation"]
    private var categoryState: [String: CategoryState] = ["Random": .initial, "Food": .initial, "Drinks": .initial, "Shopping": .initial, "Outdoors": .initial, "Recreation": .initial]
    
    // MARK: Six Types Categories
    private var arrRandom = [PlacePin]()
    private var arrFood = [PlacePin]()
    private var arrDrinks = [PlacePin]()
    private var arrShopping = [PlacePin]()
    private var arrOutdoors = [PlacePin]()
    private var arrRecreation = [PlacePin]()
    
    // MARK: Loading Waves
    private var uiviewAvatarWaveSub: UIView!
    private var imgAvatar: FaeAvatarView!
    private var filterCircle_1: UIImageView!
    private var filterCircle_2: UIImageView!
    private var filterCircle_3: UIImageView!
    private var filterCircle_4: UIImageView!
    
    // MARK: Collecting Pin Control
    private var uiviewSavedList: AddPinToCollectionView!
    private var uiviewAfterAdded: AfterAddedToListView!
    private var arrListSavedThisPin = [Int]()
    
    private var fullyLoaded = false
    private var coordinate: CLLocationCoordinate2D!
    private var strLocation: String = ""
    private var lblNoResults: FaeLabel!
    
    private var USE_TEST_PLACE = false
    
    // MARK: - Life Cycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .white
        loadNavBar()
        loadAvatar()
        DispatchQueue.main.async {
            self.loadContent()
            self.reloadBottomText("Loading...", "")
            self.coordinate = LocManager.shared.curtLoc.coordinate
            self.searchAllCategories()
            self.fullyLoaded = true
            var location: CLLocation!
            if let loc = Key.shared.lastChosenLoc {
                location = CLLocation(latitude: loc.latitude, longitude: loc.longitude)
            } else {
                location = LocManager.shared.curtLoc
            }
            General.shared.getAddress(location: location, original: false, full: false, detach: true) { (address) in
                if let addr = address as? String {
                    let new = addr.split(separator: "@")
                    self.reloadBottomText(String(new[0]), String(new[1]))
                    self.strLocation = "\(String(new[0])), \(String(new[1]))"
                }
            }
        }
        NotificationCenter.default.addObserver(self, selector: #selector(showSavedNoti), name: NSNotification.Name(rawValue: "showSavedNoti_explore"), object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(hideSavedNoti), name: NSNotification.Name(rawValue: "hideSavedNoti_explore"), object: nil)
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        loadWaves()
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
    }
    
    deinit {
        NotificationCenter.default.removeObserver(self, name: NSNotification.Name(rawValue: "showSavedNoti_explore"), object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(showSavedNoti), name: NSNotification.Name(rawValue: "hideSavedNoti_explore"), object: nil)
    }
    
    // MARK: - Loading Content
    
    private func loadContent() {
        loadTopTypesCollection()
        loadPicCollections()
        loadButtons()
        loadBottomLocation()
        loadPlaceListView()
        loadNoResultLabel()
    }
    
    private func loadPlaceListView() {
        uiviewSavedList = AddPinToCollectionView()
        uiviewSavedList.delegate = self
//        uiviewSavedList.loadCollectionData()
        view.addSubview(uiviewSavedList)
        
        uiviewAfterAdded = AfterAddedToListView()
        uiviewAfterAdded.delegate = self
        view.addSubview(uiviewAfterAdded)
        
        uiviewSavedList.uiviewAfterAdded = uiviewAfterAdded
    }
    
    private func loadNoResultLabel() {
        var y_offset: CGFloat = 550
        switch screenHeight {
        case 736, 667:
            y_offset = 515 * screenHeightFactor
        case 568:
            y_offset = 350
        default:
            break
        }
        lblNoResults = FaeLabel(CGRect(x: 0, y: y_offset, width: 270, height: 88) , .center, .medium, 16, UIColor._146146146())
        lblNoResults.center.x = screenWidth / 2
        lblNoResults.numberOfLines = 3
        lblNoResults.text = "Sorry… we can’t suggest any place\ncards currently, please try a different\nlocation or check back later!"
        view.addSubview(lblNoResults)
        lblNoResults.alpha = 0
    }
    
    private func loadAvatar() {
        let xAxis: CGFloat = screenWidth / 2
        var yAxis: CGFloat = 324.5 * screenHeightFactor
        yAxis += screenHeight == 812 ? 80 : 0
        
        uiviewAvatarWaveSub = UIView(frame: CGRect(x: 0, y: 0, width: screenWidth, height: screenWidth))
        uiviewAvatarWaveSub.center = CGPoint(x: xAxis, y: yAxis)
        view.addSubview(uiviewAvatarWaveSub)
        
        let imgAvatarSub = UIImageView(frame: CGRect(x: 0, y: 0, width: 98, height: 98))
        imgAvatarSub.contentMode = .scaleAspectFill
        imgAvatarSub.image = #imageLiteral(resourceName: "exp_avatar_border")
        imgAvatarSub.center = CGPoint(x: xAxis, y: xAxis)
        uiviewAvatarWaveSub.addSubview(imgAvatarSub)
        
        imgAvatar = FaeAvatarView(frame: CGRect(x: 0, y: 0, width: 86, height: 86))
        imgAvatar.layer.cornerRadius = 43
        imgAvatar.contentMode = .scaleAspectFill
        imgAvatar.center = CGPoint(x: xAxis, y: xAxis)
        imgAvatar.isUserInteractionEnabled = false
        imgAvatar.clipsToBounds = true
        uiviewAvatarWaveSub.addSubview(imgAvatar)
        imgAvatar.userID = Key.shared.user_id
        imgAvatar.loadAvatar(id: Key.shared.user_id)
    }
    
    private func loadWaves() {
        func createFilterCircle() -> UIImageView {
            let xAxis: CGFloat = screenWidth / 2
            let imgView = UIImageView(frame: CGRect.zero)
            imgView.frame.size = CGSize(width: 98, height: 98)
            imgView.center = CGPoint(x: xAxis, y: xAxis)
            imgView.image = #imageLiteral(resourceName: "exp_wave")
            imgView.tag = 0
            return imgView
        }
        if filterCircle_1 != nil {
            filterCircle_1.removeFromSuperview()
            filterCircle_2.removeFromSuperview()
            filterCircle_3.removeFromSuperview()
            filterCircle_4.removeFromSuperview()
        }
        filterCircle_1 = createFilterCircle()
        filterCircle_2 = createFilterCircle()
        filterCircle_3 = createFilterCircle()
        filterCircle_4 = createFilterCircle()
        uiviewAvatarWaveSub.addSubview(filterCircle_1)
        uiviewAvatarWaveSub.addSubview(filterCircle_2)
        uiviewAvatarWaveSub.addSubview(filterCircle_3)
        uiviewAvatarWaveSub.addSubview(filterCircle_4)
        uiviewAvatarWaveSub.sendSubview(toBack: filterCircle_1)
        uiviewAvatarWaveSub.sendSubview(toBack: filterCircle_2)
        uiviewAvatarWaveSub.sendSubview(toBack: filterCircle_3)
        uiviewAvatarWaveSub.sendSubview(toBack: filterCircle_4)
        
        waveAnimation(circle: filterCircle_1, delay: 0)
        waveAnimation(circle: filterCircle_2, delay: 0.5)
        waveAnimation(circle: filterCircle_3, delay: 2)
        waveAnimation(circle: filterCircle_4, delay: 2.5)
    }
    
    private func waveAnimation(circle: UIImageView, delay: Double) {
        let animateTime: Double = 3
        let radius: CGFloat = screenWidth
        let newFrame = CGRect(x: 0, y: 0, width: radius, height: radius)
        
        let xAxis: CGFloat = screenWidth / 2
        circle.frame.size = CGSize(width: 98, height: 98)
        circle.center = CGPoint(x: xAxis, y: xAxis)
        circle.alpha = 1
        
        DispatchQueue.main.asyncAfter(deadline: .now() + delay) {
            UIView.animate(withDuration: animateTime, delay: 0, options: [.curveEaseOut], animations: ({
                circle.alpha = 0.0
                circle.frame = newFrame
            }), completion: { _ in
                self.waveAnimation(circle: circle, delay: 0.75)
            })
        }
    }
    
    private func loadTopTypesCollection() {
        let layout = UICollectionViewFlowLayout()
        layout.scrollDirection = .horizontal
        layout.minimumInteritemSpacing = 0
        layout.minimumLineSpacing = 20
        layout.estimatedItemSize = CGSize(width: 80, height: 36)
        
        clctViewTypes = UICollectionView(frame: CGRect.zero, collectionViewLayout: layout)
        clctViewTypes.register(EXPClctTypeCell.self, forCellWithReuseIdentifier: "exp_types")
        clctViewTypes.delegate = self
        clctViewTypes.dataSource = self
        clctViewTypes.isPagingEnabled = false
        clctViewTypes.backgroundColor = UIColor.clear
        clctViewTypes.showsHorizontalScrollIndicator = false
        clctViewTypes.contentInset = UIEdgeInsets(top: 0, left: 20, bottom: 0, right: 20)
        view.addSubview(clctViewTypes)
        view.addConstraintsWithFormat("H:|-0-[v0]-0-|", options: [], views: clctViewTypes)
        view.addConstraintsWithFormat("V:|-\(73+device_offset_top)-[v0(36)]", options: [], views: clctViewTypes)
    }
    
    private func loadPicCollections() {
        let layout = UICollectionViewFlowLayout()
        layout.itemSize = CGSize(width: screenWidth, height: screenHeight - 116 - 156)
        layout.scrollDirection = .horizontal
        layout.minimumInteritemSpacing = 0
        layout.minimumLineSpacing = 0
        
        clctViewPics = UICollectionView(frame: CGRect.zero, collectionViewLayout: layout)
        clctViewPics.register(EXPClctPicCell.self, forCellWithReuseIdentifier: "exp_pics")
        clctViewPics.delegate = self
        clctViewPics.dataSource = self
        clctViewPics.isPagingEnabled = true
        clctViewPics.backgroundColor = UIColor.clear
        clctViewPics.showsHorizontalScrollIndicator = false
        clctViewPics.alpha = 0
        view.addSubview(clctViewPics)
        view.addConstraintsWithFormat("H:|-0-[v0]-0-|", options: [], views: clctViewPics)
        view.addConstraintsWithFormat("V:|-\(116+device_offset_top)-[v0]-\(156+device_offset_bot)-|", options: [], views: clctViewPics)
    }
    
    private func loadButtons() {
        let uiviewBtnSub = UIView(frame: CGRect(x: (screenWidth - 370) / 2, y: screenHeight - 138 - device_offset_bot, width: 370, height: 78))
        view.addSubview(uiviewBtnSub)
        
        btnGoLeft = UIButton()
        btnGoLeft.setImage(#imageLiteral(resourceName: "exp_go_left"), for: .normal)
        btnGoLeft.addTarget(self, action: #selector(actionSwitchPage(_:)), for: .touchUpInside)
        uiviewBtnSub.addSubview(btnGoLeft)
        uiviewBtnSub.addConstraintsWithFormat("H:|-0-[v0(78)]", options: [], views: btnGoLeft)
        uiviewBtnSub.addConstraintsWithFormat("V:|-0-[v0(78)]", options: [], views: btnGoLeft)
        
        btnSave = UIButton()
        btnSave.setImage(#imageLiteral(resourceName: "exp_save"), for: .normal)
        btnSave.addTarget(self, action: #selector(actionSave(_:)), for: .touchUpInside)
        uiviewBtnSub.addSubview(btnSave)
        uiviewBtnSub.addConstraintsWithFormat("H:|-82-[v0(66)]", options: [], views: btnSave)
        uiviewBtnSub.addConstraintsWithFormat("V:|-6-[v0(66)]", options: [], views: btnSave)
        imgSaved = UIImageView(frame: CGRect(x: 50, y: 16, width: 0, height: 0))
        imgSaved.image = #imageLiteral(resourceName: "place_new_collected")
        imgSaved.alpha = 0
        btnSave.addSubview(imgSaved)
        
        btnRefresh = UIButton()
        btnRefresh.setImage(#imageLiteral(resourceName: "exp_refresh"), for: .normal)
        btnRefresh.addTarget(self, action: #selector(actionRefresh), for: .touchUpInside)
        uiviewBtnSub.addSubview(btnRefresh)
        uiviewBtnSub.addConstraintsWithFormat("H:|-152-[v0(66)]", options: [], views: btnRefresh)
        uiviewBtnSub.addConstraintsWithFormat("V:|-6-[v0(66)]", options: [], views: btnRefresh)
        
        btnMap = UIButton()
        btnMap.setImage(#imageLiteral(resourceName: "exp_map"), for: .normal)
        btnMap.addTarget(self, action: #selector(actionExpMap), for: .touchUpInside)
        uiviewBtnSub.addSubview(btnMap)
        uiviewBtnSub.addConstraintsWithFormat("H:[v0(66)]-82-|", options: [], views: btnMap)
        uiviewBtnSub.addConstraintsWithFormat("V:|-6-[v0(66)]", options: [], views: btnMap)
        
        btnGoRight = UIButton()
        btnGoRight.setImage(#imageLiteral(resourceName: "exp_go_right"), for: .normal)
        btnGoRight.addTarget(self, action: #selector(actionSwitchPage(_:)), for: .touchUpInside)
        uiviewBtnSub.addSubview(btnGoRight)
        uiviewBtnSub.addConstraintsWithFormat("H:[v0(78)]-0-|", options: [], views: btnGoRight)
        uiviewBtnSub.addConstraintsWithFormat("V:|-0-[v0(78)]", options: [], views: btnGoRight)
    }
    
    private func loadBottomLocation() {
        lblBottomLocation = UILabel()
        lblBottomLocation.numberOfLines = 1
        lblBottomLocation.textAlignment = .center
        lblBottomLocation.isUserInteractionEnabled = true
        view.addSubview(lblBottomLocation)
        view.addConstraintsWithFormat("H:|-0-[v0]-0-|", options: [], views: lblBottomLocation)
        view.addConstraintsWithFormat("V:[v0(25)]-\(19+device_offset_bot)-|", options: [], views: lblBottomLocation)
        lblBottomLocation.isHidden = true
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(tapToChooseLoc(_:)))
        lblBottomLocation.addGestureRecognizer(tapGesture)
    }
    
    private func loadNavBar() {
        uiviewNavBar = FaeNavBar()
        view.addSubview(uiviewNavBar)
        uiviewNavBar.rightBtn.isHidden = true
        uiviewNavBar.loadBtnConstraints()
        
        let title_0 = "Explore "
        let title_1 = "Around Me"
        let attrs_0 = [NSAttributedStringKey.foregroundColor: UIColor._898989(), NSAttributedStringKey.font: UIFont(name: "AvenirNext-Medium", size: 20)!]
        let attrs_1 = [NSAttributedStringKey.foregroundColor: UIColor._2499090(), NSAttributedStringKey.font: UIFont(name: "AvenirNext-Medium", size: 20)!]
        let title_0_attr = NSMutableAttributedString(string: title_0, attributes: attrs_0)
        let title_1_attr = NSMutableAttributedString(string: title_1, attributes: attrs_1)
        title_0_attr.append(title_1_attr)
        
        uiviewNavBar.lblTitle.attributedText = title_0_attr
        uiviewNavBar.leftBtn.addTarget(self, action: #selector(actionBack(_:)), for: .touchUpInside)
    }
    
    // MARK: - Button Actions
    
    @objc private func actionExpMap() {
        var arrPlaceData = [PlacePin]()
        let lastSelectedRow = Key.shared.selectedTypeIdx.row
        let cat = categories[lastSelectedRow]
        switch cat {
        case "Random":
            arrPlaceData = arrRandom
        case "Food":
            arrPlaceData = arrFood
        case "Drinks":
            arrPlaceData = arrDrinks
        case "Shopping":
            arrPlaceData = arrShopping
        case "Outdoors":
            arrPlaceData = arrOutdoors
        case "Recreation":
            arrPlaceData = arrRecreation
        default:
            break
        }
        let vc = ExploreMapController()
        vc.arrExpPlace = arrPlaceData
        vc.strCategory = cat
        navigationController?.pushViewController(vc, animated: false)
//        delegate?.jumpToExpPlacesCollection(places: arrPlaceData, category: cat)
//        var arrCtrlers = navigationController?.viewControllers
//        if let ctrler = Key.shared.FMVCtrler {
//            ctrler.arrCtrlers = arrCtrlers!
//        }
//        while !(arrCtrlers?.last is InitialPageController) {
//            arrCtrlers?.removeLast()
//        }
//        Key.shared.initialCtrler?.goToFaeMap(animated: false)
//        navigationController?.setViewControllers(arrCtrlers!, animated: false)
    }
    
    @objc private func actionSave(_ sender: UIButton) {
        uiviewSavedList.show()
//        uiviewSavedList.loadCollectionData()
    }
    
    @objc private func actionSwitchPage(_ sender: UIButton) {
        var arrCount = 0
        let lastSelectedRow = Key.shared.selectedTypeIdx.row
        let cat = categories[lastSelectedRow]
        switch cat {
        case "Random":
            arrCount = arrRandom.count
        case "Food":
            arrCount = arrFood.count
        case "Drinks":
            arrCount = arrDrinks.count
        case "Shopping":
            arrCount = arrShopping.count
        case "Outdoors":
            arrCount = arrOutdoors.count
        case "Recreation":
            arrCount = arrRecreation.count
        default:
            break
        }
        var numPage = intCurtPage
        if sender == btnGoLeft {
            numPage -= 1
        } else {
            numPage += 1
        }
        if numPage < 0 {
            numPage = arrCount - 1
        } else if numPage >= arrCount {
            numPage = 0
        }
        if (numPage == 0 && intCurtPage != 1) || (numPage == arrCount - 1 && intCurtPage != arrCount - 2) {
            UIView.animate(withDuration: 0.3, animations: {
                self.clctViewPics.alpha = 0
            }, completion: { _ in
                self.clctViewPics.setContentOffset(CGPoint(x: screenWidth * CGFloat(numPage), y: 0), animated: false)
                self.intCurtPage = numPage
                self.checkSavedStatus(idx: self.intCurtPage)
                UIView.animate(withDuration: 0.3, animations: {
                    self.clctViewPics.alpha = 1
                }, completion: { _ in
                    
                })
            })
        } else {
            clctViewPics.setContentOffset(CGPoint(x: screenWidth * CGFloat(numPage), y: 0), animated: true)
            intCurtPage = numPage
            checkSavedStatus(idx: intCurtPage)
        }
    }
    
    @objc private func actionBack(_ sender: UIButton) {
        navigationController?.popViewController(animated: true)
    }
    
    @objc private func actionRefresh() {
        guard coordinate != nil else { return }
        showWaves()
        buttonEnable(on: false)
        search(category: Key.shared.lastCategory, indexPath: Key.shared.selectedTypeIdx)
        resetVisitedIndex()
    }
    
    private func resetVisitedIndex() {
        intCurtPage = 0
    }
    
    // MARK: - Other Functions
    
    private func buttonEnable(on: Bool) {
        btnGoLeft.isEnabled = on
        btnSave.isEnabled = on
        btnRefresh.isEnabled = on
        btnMap.isEnabled = on
        btnGoRight.isEnabled = on
        //lblBottomLocation.isUserInteractionEnabled = on
        clctViewTypes.isUserInteractionEnabled = on
    }
    
    // MARK: Save Noti
    
    @objc private func showSavedNoti() {
        UIView.animate(withDuration: 0.2, delay: 0, options: .curveEaseOut, animations: {
            self.imgSaved.frame = CGRect(x: 41, y: 7, width: 18, height: 18)
            self.imgSaved.alpha = 1
        }, completion: nil)
    }
    
    @objc private func hideSavedNoti() {
        UIView.animate(withDuration: 0.2, delay: 0, options: .curveEaseOut, animations: {
            self.imgSaved.frame = CGRect(x: 50, y: 16, width: 0, height: 0)
            self.imgSaved.alpha = 0
        }, completion: nil)
    }
    
    // MARK: Location Text
    private func reloadBottomText(_ city: String, _ state: String) {
        strLocation = "\(city), \(state)"
        let fullAttrStr = NSMutableAttributedString()
        let firstImg = #imageLiteral(resourceName: "mapSearchCurrentLocation")
        let first_attch = InlineTextAttachment()
        first_attch.fontDescender = -2
        first_attch.image = UIImage(cgImage: (firstImg.cgImage)!, scale: 3, orientation: .up)
        let firstImg_attach = NSAttributedString(attachment: first_attch)
        
        let secondImg = #imageLiteral(resourceName: "exp_bottom_loc_arrow")
        let second_attch = InlineTextAttachment()
        second_attch.fontDescender = -1
        second_attch.image = UIImage(cgImage: (secondImg.cgImage)!, scale: 3, orientation: .up)
        let secondImg_attach = NSAttributedString(attachment: second_attch)
        let attrs_0 = [NSAttributedStringKey.foregroundColor: UIColor._898989(), NSAttributedStringKey.font: UIFont(name: "AvenirNext-Medium", size: 16)!]
        let title_0_attr = NSMutableAttributedString(string: "  " + city + " ", attributes: attrs_0)
        
        let attrs_1 = [NSAttributedStringKey.foregroundColor: UIColor._138138138(), NSAttributedStringKey.font: UIFont(name: "AvenirNext-Medium", size: 13)!]
        let title_1_attr = NSMutableAttributedString(string: state + "  ", attributes: attrs_1)
        
        fullAttrStr.append(firstImg_attach)
        fullAttrStr.append(title_0_attr)
        fullAttrStr.append(title_1_attr)
        fullAttrStr.append(secondImg_attach)
        DispatchQueue.main.async {
            self.lblBottomLocation.attributedText = fullAttrStr
            self.lblBottomLocation.isHidden = false
        }
    }
    
    // MARK: - UIScrollViewDelegate
    
    func scrollViewDidEndDecelerating(_ scrollView: UIScrollView) {
        let pageWidth = clctViewPics.frame.size.width
        intCurtPage = Int(clctViewPics.contentOffset.x / pageWidth)
        checkSavedStatus(idx: intCurtPage)
    }
    
    // MARK: - Pin Info
    
    private func checkSavedStatus(idx: Int) {
        var arrPlaceData = [PlacePin]()
        let lastSelectedRow = Key.shared.selectedTypeIdx.row
        let cat = categories[lastSelectedRow]
        switch cat {
        case "Random":
            arrPlaceData = arrRandom
        case "Food":
            arrPlaceData = arrFood
        case "Drinks":
            arrPlaceData = arrDrinks
        case "Shopping":
            arrPlaceData = arrShopping
        case "Outdoors":
            arrPlaceData = arrOutdoors
        case "Recreation":
            arrPlaceData = arrRecreation
        default:
            break
        }
        guard idx < arrPlaceData.count else { return }
        uiviewSavedList.pinToSave = FaePinAnnotation(type: .place, cluster: nil, data: arrPlaceData[idx] as AnyObject)
        getPinSavedInfo(id: arrPlaceData[idx].id, type: "place") { (ids) in
            self.arrListSavedThisPin = ids
            self.uiviewSavedList.arrListSavedThisPin = ids
            if ids.count > 0 {
                self.showSavedNoti()
            } else {
                self.hideSavedNoti()
            }
        }
    }
    
    private func getPinSavedInfo(id: Int, type: String, _ completion: @escaping ([Int]) -> Void) {
        FaeMap.shared.getPin(type: type, pinId: String(id)) { (status, message) in
            guard status / 100 == 2 else { return }
            guard message != nil else { return }
            let resultJson = JSON(message!)
            var ids = [Int]()
            guard let is_saved = resultJson["user_pin_operations"]["is_saved"].string else {
                completion(ids)
                return
            }
            guard is_saved != "false" else { return }
            for colIdRaw in is_saved.split(separator: ",") {
                let strColId = String(colIdRaw)
                guard let colId = Int(strColId) else { continue }
                ids.append(colId)
            }
            completion(ids)
        }
    }
    
    // MARK: - Gesture Recognizers
    
    @objc private func tapToChooseLoc(_ tap: UITapGestureRecognizer) {
        let vc = SelectLocationViewController()
        vc.delegate = self
        vc.mode = .part
        vc.boolFromExplore = true
        navigationController?.pushViewController(vc, animated: false)
    }
    
    // MARK: - UICollectionViewDelegate
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        if collectionView == clctViewTypes {
            let label = UILabel()
            label.font = FaeFont(fontType: .medium, size: 15)
            label.text = categories[indexPath.row]
            let width = label.intrinsicContentSize.width
            return CGSize(width: width + 3.0, height: 36)
        }
        return CGSize(width: screenWidth, height: screenHeight - 116 - 156 - device_offset_top - device_offset_bot)
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        if collectionView == clctViewPics {
            let selectedIdxRow = Key.shared.selectedTypeIdx.row
            let isInitial = categoryState[categories[selectedIdxRow]] != .initial
            var count = 0
            switch selectedIdxRow {
            case 0:
                count = arrRandom.count
            case 1:
                count = arrFood.count
            case 2:
                count = arrDrinks.count
            case 3:
                count = arrShopping.count
            case 4:
                count = arrOutdoors.count
            case 5:
                count = arrRecreation.count
            default:
                return 0
            }
            lblNoResults.alpha = count == 0 && isInitial ? 1 : 0
            if count == 0 {
                showWaves()
            } else {
                hideWaves()
            }
            return count
        } else if collectionView == clctViewTypes {
            return categories.count
        }
        return 10
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        if collectionView == clctViewPics {
            let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "exp_pics", for: indexPath) as! EXPClctPicCell
            cell.delegate = self
            var data: PlacePin!
            let lastSelectedRow = Key.shared.selectedTypeIdx.row
            let cat = categories[lastSelectedRow]
            switch cat {
            case "Random":
                data = arrRandom[indexPath.row]
            case "Food":
                data = arrFood[indexPath.row]
            case "Drinks":
                data = arrDrinks[indexPath.row]
            case "Shopping":
                data = arrShopping[indexPath.row]
            case "Outdoors":
                data = arrOutdoors[indexPath.row]
            case "Recreation":
                data = arrRecreation[indexPath.row]
            default:
                break
            }
            cell.updateCell(placeData: data)
            return cell
        } else {
            let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "exp_types", for: indexPath) as! EXPClctTypeCell
            
            let cat = categories[indexPath.row]
            cell.updateTitle(type: cat)
            cell.indexPath = indexPath
            
            if let catState = categoryState[cat] {
                cell.state = catState
            }
            
            return cell
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        if collectionView == clctViewPics {
            var placePin: PlacePin!
            let lastSelectedRow = Key.shared.selectedTypeIdx.row
            let cat = categories[lastSelectedRow]
            switch cat {
            case "Random":
                placePin = arrRandom[indexPath.row]
            case "Food":
                placePin = arrFood[indexPath.row]
            case "Drinks":
                placePin = arrDrinks[indexPath.row]
            case "Shopping":
                placePin = arrShopping[indexPath.row]
            case "Outdoors":
                placePin = arrOutdoors[indexPath.row]
            case "Recreation":
                placePin = arrRecreation[indexPath.row]
            default:
                break
            }
            let vcPlaceDetail = PlaceDetailViewController()
            vcPlaceDetail.place = placePin
            navigationController?.pushViewController(vcPlaceDetail, animated: true)
        } else {
            let lastSelected = Key.shared.selectedTypeIdx
            if let cell = clctViewTypes.cellForItem(at: lastSelected) as? EXPClctTypeCell {
                cell.state = .read
            }
            if let cell = clctViewTypes.cellForItem(at: indexPath) as? EXPClctTypeCell {
                cell.state = .selected
            }
            Key.shared.selectedTypeIdx = indexPath
            let lastSelectedRow = Key.shared.selectedTypeIdx.row
            Key.shared.lastCategory = categories[lastSelectedRow]
            clctViewPics.reloadData()
        }
    }
    
    // MARK: - EXPCellDelegate
    func jumpToPlaceDetail(_ placeInfo: PlacePin) {
        let vcPlaceDetail = PlaceDetailViewController()
        vcPlaceDetail.place = placeInfo
        navigationController?.pushViewController(vcPlaceDetail, animated: true)
    }
    
    // MARK: - Category Search
    
    private func searchAllCategories() {
        buttonEnable(on: false)
        for i in 0..<categories.count {
            search(category: categories[i], indexPath: IndexPath(row: i, section: 0))
        }
    }
    
    private func loadPlaces(center: CLLocationCoordinate2D, indexPath: IndexPath) {
        DispatchQueue.main.asyncAfter(deadline: .now() + 1) {
            
            guard !self.USE_TEST_PLACE else {
                self.arrRandom = generator(center, 20, 0)
                if Key.shared.selectedTypeIdx.row == 0 {
                    self.categoryState["Random"] = .selected
                } else {
                    self.categoryState["Random"] = .unread
                }
                self.clctViewTypes.reloadItems(at: [IndexPath(row: 0, section: 0)])
                if indexPath == Key.shared.selectedTypeIdx {
                    self.clctViewPics.reloadData()
                    self.hideWaves()
                    self.buttonEnable(on: true)
                }
                return
            }
            
            General.shared.getPlacePins(coordinate: center, radius: 0, count: 200, completion: { (status, placesJSON) in
                guard status / 100 == 2 else {
                    //.fail
                    if indexPath == Key.shared.selectedTypeIdx {
                        self.buttonEnable(on: true)
                    }
                    return
                }
                guard let mapPlaceJsonArray = placesJSON.array else {
                    //.fail
                    if indexPath == Key.shared.selectedTypeIdx {
                        self.buttonEnable(on: true)
                    }
                    return
                }
                guard mapPlaceJsonArray.count > 0 else {
                    //.fail
                    if indexPath == Key.shared.selectedTypeIdx {
                        self.buttonEnable(on: true)
                    }
                    return
                }
                let arrRaw = mapPlaceJsonArray.map { PlacePin(json: $0) }
                self.arrRandom = self.getRandomIndex(arrRaw)
                if Key.shared.selectedTypeIdx.row == 0 {
                    self.categoryState["Random"] = .selected
                } else {
                    self.categoryState["Random"] = .unread
                }
                self.clctViewTypes.reloadItems(at: [IndexPath(row: 0, section: 0)])
                if indexPath == Key.shared.selectedTypeIdx {
                    self.clctViewPics.reloadData()
                    self.hideWaves()
                    self.buttonEnable(on: true)
                }
                self.checkSavedStatus(idx: 0)
            })
        }
    }
    
    private func showWaves() {
        UIView.animate(withDuration: 0.3, animations: {
            if self.clctViewPics != nil {
                self.clctViewPics.alpha = 0
            }
            self.uiviewAvatarWaveSub.alpha = 1
        })
    }
    
    private func hideWaves() {
        UIView.animate(withDuration: 0.3, animations: {
            self.clctViewPics.alpha = 1
            self.uiviewAvatarWaveSub.alpha = 0
        })
    }
    
    private func search(category: String, indexPath: IndexPath, flag: Bool = true) {
        
        if category == "Random" {
            loadPlaces(center: coordinate, indexPath: indexPath)
            return
        }
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 1) {
            FaeSearch.shared.whereKey("content", value: category)
            FaeSearch.shared.whereKey("source", value: "categories")
            FaeSearch.shared.whereKey("type", value: "place")
            FaeSearch.shared.whereKey("size", value: "200")
            FaeSearch.shared.whereKey("radius", value: "99999999")
            FaeSearch.shared.whereKey("offset", value: "0")
            FaeSearch.shared.whereKey("sort", value: [["geo_location": "asc"]])
            FaeSearch.shared.whereKey("location", value: ["latitude": LocManager.shared.searchedLoc.coordinate.latitude,
                                                          "longitude": LocManager.shared.searchedLoc.coordinate.longitude])
            //FaeSearch.shared.whereKey("location", value: "{latitude:\(self.coordinate.latitude), longitude:\(self.coordinate.longitude)}")
            FaeSearch.shared.search { (status: Int, message: Any?) in
                if status / 100 != 2 || message == nil {
                    // 给CategoryState增加fail
                    if indexPath == Key.shared.selectedTypeIdx {
                        self.buttonEnable(on: true)
                    }
                    return
                }
                let placeInfoJSON = JSON(message!)
                guard let placeInfoJsonArray = placeInfoJSON.array else {
                    // .fail
                    if indexPath == Key.shared.selectedTypeIdx {
                        self.buttonEnable(on: true)
                    }
                    return
                }
                let arrRaw = placeInfoJsonArray.map { PlacePin(json: $0) }
                switch category {
                case "Random":
                    self.arrRandom = self.getRandomIndex(arrRaw)
                case "Food":
                    self.arrFood = self.getRandomIndex(arrRaw)
                case "Drinks":
                    self.arrDrinks = self.getRandomIndex(arrRaw)
                case "Shopping":
                    self.arrShopping = self.getRandomIndex(arrRaw)
                case "Outdoors":
                    self.arrOutdoors = self.getRandomIndex(arrRaw)
                case "Recreation":
                    self.arrRecreation = self.getRandomIndex(arrRaw)
                default:
                    break
                }
                if Key.shared.selectedTypeIdx == indexPath {
                    self.categoryState[category] = .selected
                } else {
                    self.categoryState[category] = .unread
                }
                self.clctViewTypes.reloadItems(at: [indexPath])
                if indexPath == Key.shared.selectedTypeIdx {
                    self.clctViewPics.reloadData()
                    self.hideWaves()
                    self.buttonEnable(on: true)
                }
                self.checkSavedStatus(idx: 0)
            }
        }
    }
    
    private func getRandomIndex(_ arrRaw: [PlacePin]) -> [PlacePin] {
        var tempRaw = arrRaw
        var arrResult = [PlacePin]()
        let count = arrRaw.count < 20 ? arrRaw.count : 20
        for _ in 0..<count {
            let random: Int = Int(arc4random_uniform(UInt32(tempRaw.count)))
            arrResult.append(tempRaw[random])
            tempRaw.remove(at: random)
        }
        return arrResult
    }
    
    // MARK: - AfterAddedToListDelegate
    func seeList() {
        // TODO VICKY
        uiviewAfterAdded.hide()
        let vcList = CollectionsListDetailViewController()
        vcList.enterMode = uiviewSavedList.tableMode
        vcList.colId = uiviewAfterAdded.selectedCollection.collection_id
        //        vcList.colInfo = uiviewAfterAdded.selectedCollection
        //        vcList.arrColDetails = uiviewAfterAdded.selectedCollection
        navigationController?.pushViewController(vcList, animated: true)
    }
    
    func undoCollect(colId: Int, mode: UndoMode) {
        uiviewAfterAdded.hide()
        uiviewSavedList.show()
        switch mode {
        case .save:
            uiviewSavedList.arrListSavedThisPin.append(colId)
        case .unsave:
            if uiviewSavedList.arrListSavedThisPin.contains(colId) {
                let arrListIds = uiviewSavedList.arrListSavedThisPin
                uiviewSavedList.arrListSavedThisPin = arrListIds.filter { $0 != colId }
            }
        }
        if uiviewSavedList.arrListSavedThisPin.count <= 0 {
            hideSavedNoti()
        } else if uiviewSavedList.arrListSavedThisPin.count == 1 {
            showSavedNoti()
        }
    }
    
    // MARK: - AddPlacetoCollectionDelegate
    func createColList() {
        let vc = CreateColListViewController()
        vc.enterMode = .place
        present(vc, animated: true)
    }
    
    // MARK: - GeneralLocationSearchDelegate
    func sendLocationBack(address: RouteAddress) {
        var arrNames = address.name.split(separator: ",")
        var array = [String]()
        guard arrNames.count >= 1 else { return }
        for i in 0..<arrNames.count {
            let name = String(arrNames[i]).trimmingCharacters(in: CharacterSet.whitespaces)
            array.append(name)
        }
        if array.count >= 3 {
            reloadBottomText(array[0], array[1] + ", " + array[2])
        } else if array.count == 1 {
            reloadBottomText(array[0], "")
        } else if array.count == 2 {
            reloadBottomText(array[0], array[1])
        }
        self.coordinate = address.coordinate
        search(category: Key.shared.lastCategory, indexPath: Key.shared.selectedTypeIdx)
    }
    
}
