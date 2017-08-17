//
//  PlaceDetailViewController.swift
//  faeBeta
//
//  Created by Faevorite 2 on 2017-08-14.
//  Copyright © 2017 fae. All rights reserved.
//

import UIKit
import SwiftyJSON

class PlaceDetailViewController: UIViewController {
    
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
//    var arrSimilarPlaces = [PlacePin]()
//    var arrNearbyPlaces = [PlacePin]()
    let faeMap = FaeMap()
    let faePinAction = FaePinAction()
    var boolSaved: Bool = false
    
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
        tblPlaceDetail.contentInset = .zero
        
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
                faePinAction.saveThisPin("place", pinID: String(place.id)) { (status: Int, message: Any?) in
                    if status / 100 == 2 {
                        self.boolSaved = true
                        self.imgSaved.isHidden = false
                    } else {
                        print("[PlaceDetail-Save Pin] Save Place Pin Fail \(status) \(message!)")
                    }
                }
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

class InfiniteScrollingView: UIView {
    var placePhotos = [#imageLiteral(resourceName: "food_1"), #imageLiteral(resourceName: "food_2"), #imageLiteral(resourceName: "food_3"), #imageLiteral(resourceName: "food_4"), #imageLiteral(resourceName: "food_5"), #imageLiteral(resourceName: "food_6")]
    var imgPic_0: UIImageView!
    var imgPic_1: UIImageView!
    var imgPic_2: UIImageView!
    var boolLeft: Bool!
    var boolRight: Bool!
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        loadContent()
        
        let panGesture = UIPanGestureRecognizer()
        panGesture.maximumNumberOfTouches = 1
        panGesture.addTarget(self, action: #selector(handlePanGesture(_:)))
        addGestureRecognizer(panGesture)
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func loadContent() {
        imgPic_0 = UIImageView(frame: frame)
        imgPic_1 = UIImageView(frame: frame)
        imgPic_2 = UIImageView(frame: frame)
        resetSubviews()
        
        addSubview(imgPic_0)
        addSubview(imgPic_1)
        addSubview(imgPic_2)
        imgPic_0.image = placePhotos[0]
        imgPic_1.image = placePhotos[1]
        imgPic_2.image = placePhotos[2]
        boolLeft = placePhotos.count > 1
        boolRight = placePhotos.count > 1
    }
    
    func panToPrev(_ time: Double = 0.3) {
        UIView.animate(withDuration: time, delay: 0, usingSpringWithDamping: 1, initialSpringVelocity: 0, options: .curveEaseOut, animations: {
            self.imgPic_0.frame.origin.x = 0
            self.imgPic_1.frame.origin.x += screenWidth
        }, completion: {_ in
            self.imgPic_2.image = self.imgPic_1.image
            self.imgPic_1.image = self.imgPic_0.image
            var idx = self.placePhotos.index(of: self.imgPic_0.image!)!
            idx = (idx + self.placePhotos.count - 1) % self.placePhotos.count
            self.imgPic_0.image = self.placePhotos[idx]
            self.resetSubviews()
        })
    }
    
    func panToNext(_ time: Double = 0.3) {
        UIView.animate(withDuration: time, delay: 0, usingSpringWithDamping: 1, initialSpringVelocity: 0, options: .curveEaseOut, animations: {
            self.imgPic_1.frame.origin.x = -screenWidth
            self.imgPic_2.frame.origin.x = 0
        }, completion: { _ in
            self.imgPic_0.image = self.imgPic_1.image
            self.imgPic_1.image = self.imgPic_2.image
            var idx = self.placePhotos.index(of: self.imgPic_2.image!)!
            idx = (idx + self.placePhotos.count + 1) % self.placePhotos.count
            self.imgPic_2.image = self.placePhotos[idx]
            self.resetSubviews()
        })
    }
    
    func panBack(_ time: Double = 0.3) {
        UIView.animate(withDuration: time, delay: 0, usingSpringWithDamping: 1, initialSpringVelocity: 0, options: .curveEaseOut, animations: {
            self.resetSubviews()
        }, completion: nil)
    }
    
    var end: CGFloat = 0
    
    func handlePanGesture(_ pan: UIPanGestureRecognizer) {
        var resumeTime: Double = 0.5
        if pan.state == .began {
            end = pan.location(in: self).x
        } else if pan.state == .ended || pan.state == .failed || pan.state == .cancelled {
            let velocity = pan.velocity(in: self)
            let location = pan.location(in: self)
            let distanceMoved = end - location.x
            let percent = distanceMoved / screenWidth
            resumeTime = abs(Double(CGFloat(distanceMoved) / velocity.x))
            if resumeTime > 0.5 {
                resumeTime = 0.5
            } else if resumeTime < 0.3 {
                resumeTime = 0.3
            }
            let absPercent: CGFloat = 0.1
            if percent < -absPercent {
                panToPrev(resumeTime)
            } else if percent > absPercent {
                panToNext(resumeTime)
            } else {
                panBack(resumeTime)
            }
        } else if pan.state == .changed {
            if boolLeft || boolRight {
                let translation = pan.translation(in: self)
                imgPic_0.center.x = imgPic_0.center.x + translation.x
                imgPic_1.center.x = imgPic_1.center.x + translation.x
                imgPic_2.center.x = imgPic_2.center.x + translation.x
                pan.setTranslation(CGPoint.zero, in: self)
            }
        }
    }
    
    func resetSubviews() {
        imgPic_0.frame.origin.x = -screenWidth
        imgPic_1.frame.origin.x = 0
        imgPic_2.frame.origin.x = screenWidth
    }
}
