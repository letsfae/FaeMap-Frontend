//
//  PlaceDetailViewController.swift
//  faeBeta
//
//  Created by Faevorite 2 on 2017-08-14.
//  Copyright © 2017 fae. All rights reserved.
//

import UIKit
import SwiftyJSON

class PlaceDetailViewController: UIViewController, SeeAllPlacesDelegate, AddPlacetoCollectionDelegate {
    var place: PlacePin!
    var uiviewHeader: UIView!
    var uiviewSubHeader: FixedHeader!
    var uiviewFixedHeader: FixedHeader!
    var uiviewScrollingPhotos: InfiniteScrollingView!
    var uiviewFooter: UIView!
    var btnBack: UIButton!
    var btnSave: UIButton!
    var imgSaved: UIImageView!
    var btnRoute: UIButton!
    var btnShare: UIButton!
    var tblPlaceDetail: UITableView!
    let arrTitle = ["Similar Places", "Near this Place"]
    var arrRelatedPlaces = [[PlacePin]]()
    let faeMap = FaeMap()
    let faePinAction = FaePinAction()
    var boolSaved: Bool = false
    var uiviewAddCollection: AddPlaceToCollectionView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .white
        loadHeader()
        loadMidTable()
        loadFixedHeader()
        loadFooter()
        checkSavedStatus()
        getRelatedPlaces(lat: String(LocManager.shared.curtLat), long: String(LocManager.shared.curtLong), radius: 9999999, isSimilar: true, completion: { (arrPlaces) in
            self.arrRelatedPlaces.append(arrPlaces)
            self.getRelatedPlaces(lat: String(self.place.coordinate.latitude), long: String(self.place.coordinate.longitude), radius: 5000, isSimilar: false, completion: { (arrPlaces) in
                self.arrRelatedPlaces.append(arrPlaces)
                self.tblPlaceDetail.reloadData()
            })
        })
        PlaceDetailCell.boolFold = true
        
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        UIApplication.shared.statusBarStyle = .lightContent
    }
    
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        UIApplication.shared.statusBarStyle = .default
    }
    
    func checkSavedStatus() {
        faeMap.whereKey("is_place", value: "true")
        faeMap.getSavedPins() {(status: Int, message: Any?) in
            if status / 100 == 2 {
                let savedPinsJSON = JSON(message!)
                for i in 0..<savedPinsJSON.count {
                    if savedPinsJSON[i]["pin_id"].intValue == self.place.id {
                        self.boolSaved = true
                        self.imgSaved.isHidden = false
                        break
                    }
                }
            }
            else {
                print("Fail to get saved pins!")
            }
        }
    }
    
    func getRelatedPlaces(lat: String, long: String, radius: Int, isSimilar: Bool, completion:@escaping ([PlacePin]) -> Void) {
        faeMap.whereKey("geo_latitude", value: "\(lat)")
        faeMap.whereKey("geo_longitude", value: "\(long)")
        faeMap.whereKey("radius", value: "\(radius)")
        faeMap.whereKey("type", value: "place")
        faeMap.whereKey("max_count", value: "1000")
        faeMap.getMapInformation { (status: Int, message: Any?) in
            var arrPlaces = [PlacePin]()
            arrPlaces.removeAll()
            if status / 100 == 2 {
                let json = JSON(message!)
                guard let placeJson = json.array else {
                    return
                }
                for pl in placeJson {
                    let placePin = PlacePin(json: pl)
                    if arrPlaces.count < 15 && placePin.id != self.place.id {
                        if isSimilar && placePin.class_1 == self.place.class_1 || !isSimilar {
                            arrPlaces.append(placePin)
                        }
                    }
                }
            } else {
                print("Get Related Places Fail \(status) \(message!)")
            }
            completion(arrPlaces)
        }
    }
    
    func loadHeader() {
        uiviewHeader = UIView(frame: CGRect(x: 0, y: 0, w: 414, h: 309))
        
        uiviewScrollingPhotos = InfiniteScrollingView(frame: CGRect(x: 0, y: 0, w: 414, h: 208))
        uiviewHeader.addSubview(uiviewScrollingPhotos)
        
        uiviewSubHeader = FixedHeader(frame: CGRect(x: 0, y: 208, w: 414, h: 101))
        uiviewHeader.addSubview(uiviewSubHeader)
        uiviewSubHeader.setValue(place: place)
    }
    
    func loadFixedHeader() {
        uiviewFixedHeader = FixedHeader(frame: CGRect(x: 0, y: 0, w: 414, h: 101))
        view.addSubview(uiviewFixedHeader)
        uiviewFixedHeader.setValue(place: place)
        uiviewFixedHeader.isHidden = true
    }
    
    func loadMidTable() {
        
        
        tblPlaceDetail = UITableView(frame: CGRect(x: 0, y: 0, width: screenWidth, height: screenHeight - 49))
        view.addSubview(tblPlaceDetail)
        tblPlaceDetail.tableHeaderView = uiviewHeader
        
        automaticallyAdjustsScrollViewInsets = false
                
        tblPlaceDetail.delegate = self
        tblPlaceDetail.dataSource = self
        tblPlaceDetail.register(PlaceDetailSection1Cell.self, forCellReuseIdentifier: "PlaceDetailSection1Cell")
        tblPlaceDetail.register(PlaceDetailSection2Cell.self, forCellReuseIdentifier: "PlaceDetailSection2Cell")
        tblPlaceDetail.register(PlaceDetailSection3Cell.self, forCellReuseIdentifier: "PlaceDetailSection3Cell")
        tblPlaceDetail.register(MBPlacesCell.self, forCellReuseIdentifier: "MBPlacesCell")
        tblPlaceDetail.separatorStyle = .none
        tblPlaceDetail.showsVerticalScrollIndicator = false
    }

    func loadFooter() {
        uiviewFooter = UIView(frame: CGRect(x: 0, y: screenHeight - 49, width: screenWidth, height: 49))
        view.addSubview(uiviewFooter)
        
        let line = UIView(frame: CGRect(x: 0, y: 0, width: screenWidth, height: 1))
        line.backgroundColor = UIColor._200199204()
        uiviewFooter.addSubview(line)
        
        btnBack = UIButton(frame: CGRect(x: 0, y: 1, width: 40.5, height: 48))
        btnBack.setImage(#imageLiteral(resourceName: "navigationBack"), for: .normal)
        btnBack.addTarget(self, action: #selector(backToMapBoard(_:)), for: .touchUpInside)
        
        btnSave = UIButton(frame: CGRect(x: screenWidth / 2 - 105, y: 2, width: 47, height: 47))
        btnSave.setImage(#imageLiteral(resourceName: "place_save"), for: .normal)
        btnSave.tag = 0
        btnSave.addTarget(self, action: #selector(tabButtonPressed(_:)), for: .touchUpInside)
        
        btnRoute = UIButton(frame: CGRect(x: (screenWidth - 47) / 2, y: 2, width: 47, height: 47))
        btnRoute.setImage(#imageLiteral(resourceName: "place_route"), for: .normal)
        btnRoute.tag = 1
        btnRoute.addTarget(self, action: #selector(tabButtonPressed(_:)), for: .touchUpInside)
        
        btnShare = UIButton(frame: CGRect(x: screenWidth / 2 + 58, y: 2, width: 47, height: 47))
        btnShare.setImage(#imageLiteral(resourceName: "place_share"), for: .normal)
        btnShare.tag = 2
        btnShare.addTarget(self, action: #selector(tabButtonPressed(_:)), for: .touchUpInside)
        
        uiviewFooter.addSubview(btnBack)
        uiviewFooter.addSubview(btnSave)
        uiviewFooter.addSubview(btnRoute)
        uiviewFooter.addSubview(btnShare)
        
        imgSaved = UIImageView(frame: CGRect(x: 29, y: 5, width: 18, height: 18))
        btnSave.addSubview(imgSaved)
        imgSaved.image = #imageLiteral(resourceName: "place_saved")
        imgSaved.isHidden = true
        
        loadAddtoCollection()
    }
    
    fileprivate func loadAddtoCollection() {
        uiviewAddCollection = AddPlaceToCollectionView()
        uiviewAddCollection.delegate = self
        view.addSubview(uiviewAddCollection)
    }
    
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        if tblPlaceDetail.contentOffset.y >= 208 * screenHeightFactor {
            uiviewFixedHeader.isHidden = false
        } else {
            uiviewFixedHeader.isHidden = true
        }
    }
    
    func backToMapBoard(_ sender: UIButton) {
        navigationController?.popViewController(animated: true)
    }
    
    func tabButtonPressed(_ sender: UIButton) {
        switch sender.tag {
        case 0:
            if boolSaved {
                faePinAction.unsaveThisPin("place", pinID: String(place.id)) { (status: Int, message: Any?) in
                    if status / 100 == 2 {
                        self.boolSaved = false
                        self.imgSaved.isHidden = true
                    } else {
                        print("[PlaceDetail-Unsave Pin] Unsave Place Pin Fail \(status) \(message!)")
                    }
                }
            } else {
                showAddCollectionView()
                /*
                faePinAction.saveThisPin("place", pinID: String(place.id)) { (status: Int, message: Any?) in
                    if status / 100 == 2 {
                        self.boolSaved = true
                        self.imgSaved.isHidden = false
                    } else {
                        print("[PlaceDetail-Save Pin] Save Place Pin Fail \(status) \(message!)")
                    }
                }
                 */
            }
            break
        case 1:
            break
        case 2:
            break
        default:
            break
        }
    }
    
    func showAddCollectionView() {
        uiviewAddCollection.show()
    }
    
    func hideAddCollectionView() {
        uiviewAddCollection.hide()
    }
    
    func scrollViewWillBeginDragging(_ scrollView: UIScrollView) {
        hideAddCollectionView()
    }
    
    // SeeAllPlacesDelegate
    func jumpToAllPlaces(places: [PlacePin], title: String) {
        let vc = AllPlacesViewController()
        vc.places = places
        vc.strTitle = title
        navigationController?.pushViewController(vc, animated: true)
    }
    
    func jumpToPlaceDetail(place: PlacePin) {
        let vc = PlaceDetailViewController()
        vc.place = place
        navigationController?.pushViewController(vc, animated: true)
    }
    // SeeAllPlacesDelegate End
    
    // AddPlacetoCollectionDelegate
    func cancelAddPlace() {
        hideAddCollectionView()
    }
    
    func createColList() {
        let vc = CreateColListViewController()
        present(vc, animated: true)
//        navigationController?.pushViewController(vc, animated: true)
    }
    // AddPlacetoCollectionDelegate End
}

class FixedHeader: UIView {
    var lblName: UILabel!
    var lblCategory: UILabel!
    var lblPrice: UILabel!
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setupUI()
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    fileprivate func setupUI() {
        backgroundColor = .white
        
        lblName = UILabel(frame: CGRect(x: 20, y: 21 * screenHeightFactor, width: screenWidth - 40, height: 27))
        lblName.font = UIFont(name: "AvenirNext-Medium", size: 20)
        lblName.textColor = UIColor._898989()
        
        lblCategory = UILabel(frame: CGRect(x: 20, y: 53 * screenHeightFactor, width: screenWidth - 90, height: 22))
        lblCategory.font = UIFont(name: "AvenirNext-Medium", size: 16)
        lblCategory.textColor = UIColor._146146146()
        
        lblPrice = UILabel()
        lblPrice.font = UIFont(name: "AvenirNext-Medium", size: 16)
        lblPrice.textColor = UIColor._107105105()
        lblPrice.textAlignment = .right
        
        addSubview(lblName)
        addSubview(lblCategory)
        addSubview(lblPrice)
        addConstraintsWithFormat("H:[v0(100)]-15-|", options: [], views: lblPrice)
        addConstraintsWithFormat("V:[v0(22)]-\(14 * screenHeightFactor)-|", options: [], views: lblPrice)
        
        let uiviewLine = UIView(frame: CGRect(x: 0, y: 96, w: 414, h: 5))
        uiviewLine.backgroundColor = UIColor._241241241()
        addSubview(uiviewLine)
    }
    
    func setValue(place: PlacePin) {
        lblName.text = place.name
        lblCategory.text = place.class_1
        lblPrice.text = "$$$"
    }
}

/*
class InfiniteScrollingView: UIView, UICollectionViewDelegate, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout {
    var placePhotos = [#imageLiteral(resourceName: "defaultMen"), #imageLiteral(resourceName: "defaultWomen"), #imageLiteral(resourceName: "defaultCover"), #imageLiteral(resourceName: "defaultPlaceIcon")]
    var carousePhotos = [#imageLiteral(resourceName: "defaultPlaceIcon"), #imageLiteral(resourceName: "defaultMen"), #imageLiteral(resourceName: "defaultWomen"), #imageLiteral(resourceName: "defaultCover"), #imageLiteral(resourceName: "defaultPlaceIcon"), #imageLiteral(resourceName: "defaultMen")]
    var colViewScrolling: UICollectionView!
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        loadContent()
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    fileprivate func loadContent() {
        let flowLayout = InfiniteScrollingLayout() // UICollectionViewFlowLayout()
        flowLayout.itemSize = CGSize(width: frame.size.width, height: frame.size.height)
        colViewScrolling = UICollectionView(frame: CGRect(x: 0, y: 0, width: frame.size.width, height: frame.size.height), collectionViewLayout: flowLayout)
        colViewScrolling.decelerationRate = UIScrollViewDecelerationRateFast
        colViewScrolling.showsHorizontalScrollIndicator = false
        colViewScrolling.delegate = self
        colViewScrolling.dataSource = self
        colViewScrolling.register(InfiniteScrollingCell.self, forCellWithReuseIdentifier: "InfiniteScrollingCell")
        addSubview(colViewScrolling)
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return placePhotos.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "InfiniteScrollingCell", for: indexPath) as! InfiniteScrollingCell
        let photo = placePhotos[indexPath.row]
        cell.setValueForCell(photo: photo)
        
        return cell
    }
}

class InfiniteScrollingCell: UICollectionViewCell {
    var imgPlacePhotos: UIImageView!
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        loadCellContent()
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    fileprivate func loadCellContent() {
        imgPlacePhotos = UIImageView()//frame: CGRect(x: 0, y: 0, width: screenWidth, height: 208 * screenHeightFactor))
        addSubview(imgPlacePhotos)
        imgPlacePhotos.contentMode = .scaleToFill
        addConstraintsWithFormat("H:|-0-[v0]-0-|", options: [], views: imgPlacePhotos)
        addConstraintsWithFormat("V:|-0-[v0]-0-|", options: [], views: imgPlacePhotos)
    }
    
    func setValueForCell(photo: UIImage) {
        imgPlacePhotos.image = photo
    }
}

class InfiniteScrollingLayout: UICollectionViewFlowLayout {
    override init() {
        super.init()
        scrollDirection = .horizontal
        minimumLineSpacing = 0
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func targetContentOffset(forProposedContentOffset proposedContentOffset: CGPoint, withScrollingVelocity velocity: CGPoint) -> CGPoint {
        var rect: CGRect = .zero
        rect.origin.y = 0
        rect.origin.x = proposedContentOffset.x
        rect.size = (collectionView!.frame.size)

        let originArray = super.layoutAttributesForElements(in: rect)
        let attributes = NSArray(array: originArray!, copyItems: true) as? [UICollectionViewLayoutAttributes]

        let centerX = proposedContentOffset.x + collectionView!.frame.size.width * 0.5

        var minDelta: CGFloat = CGFloat(MAXFLOAT)
        for attrs in attributes! {
            if abs(minDelta) > abs(attrs.center.x - centerX) {
                minDelta = attrs.center.x - centerX
            }
        }
        return CGPoint(x: proposedContentOffset.x + minDelta, y: proposedContentOffset.y)
    }
}
*/
