//
//  AddPinToCollectionView.swift
//  faeBeta
//
//  Created by Faevorite 2 on 2017-08-16.
//  Copyright © 2017 fae. All rights reserved.
//

import UIKit
import SwiftyJSON

protocol AddPinToCollectionDelegate: class {
    func createColList()
    func cancelAddPlace()
}

class AddPinToCollectionView: UIView, UITableViewDelegate, UITableViewDataSource {
    weak var delegate: AddPinToCollectionDelegate?
    
    var uiviewHeader: UIView!
    var btnNew: UIButton!
    var btnCancel: UIButton!
    var tblAddCollection: UITableView!
    var uiviewAfterAdded: AfterAddedToListView!
    let faeCollection = FaeCollection()
    var arrCollection = [PinCollection]()
    var tableMode: CollectionTableMode = .place
    var pinToSave: FaePinAnnotation!
    var timer: Timer?
    var arrListSavedThisPin = [Int]() {
        didSet {
            guard fullLoaded else { return }
            tblAddCollection.reloadData()
        }
    }
    var fullLoaded = false
    
    override init(frame: CGRect = .zero) {
        super.init(frame: CGRect(x: 0, y: screenHeight, width: screenWidth, height: 434 * screenHeightFactor))
        backgroundColor = .white
        loadContent()
        loadCollectionData()
        fullLoaded = true
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func loadCollectionData() {
        faeCollection.getCollections {(status: Int, message: Any?) in
            if status / 100 == 2 {
                let collections = JSON(message!)
                guard let colArray = collections.array else {
                    print("[loadCollectionData] fail to parse collections info")
                    return
                }
                self.arrCollection.removeAll()
                for col in colArray {
                    let data = PinCollection(json: col)
                    if data.colType == self.tableMode.rawValue {
                        self.arrCollection.append(data)
                    }
                }
                self.tblAddCollection.reloadData()
            } else {
                print("[Get Collections] Fail to Get \(status) \(message!)")
            }
        }
    }
    
    func show() {
        UIView.animate(withDuration: 0.3, delay: 0, options: .curveEaseOut, animations: {
            self.frame.origin.y = screenHeight - self.frame.size.height
        }, completion: nil)
    }
    
    func hide() {
        UIView.animate(withDuration: 0.3, delay: 0, options: .curveEaseOut, animations: {
            self.frame.origin.y = screenHeight
        }, completion: nil)
    }
    
    fileprivate func loadContent() {
        layer.zPosition = 1001
        
        uiviewHeader = UIView(frame: CGRect(x: 0, y: 0, width: screenWidth, height: 58))
        addSubview(uiviewHeader)
        
        //        let swipeGesture = UISwipeGestureRecognizer(target: self, action: #selector(actionCancel(_:)))
        //        swipeGesture.direction = .down
        //        uiviewHeader.addGestureRecognizer(swipeGesture)
        
        let upperLine = UIView(frame: CGRect(x: 0, y: 0, width: screenWidth, height: 1))
        upperLine.backgroundColor = UIColor._200199204()
        uiviewHeader.addSubview(upperLine)
        
        let lowerLine = UIView(frame: CGRect(x: 0, y: 57, width: screenWidth, height: 1))
        lowerLine.backgroundColor = UIColor._200199204()
        uiviewHeader.addSubview(lowerLine)
        
        let lblAddCollection = UILabel(frame: CGRect(x: (screenWidth - 200) / 2, y: 20, width: 200, height: 27))
        lblAddCollection.textColor = UIColor._898989()
        lblAddCollection.font = UIFont(name: "AvenirNext-Medium", size: 20)
        lblAddCollection.text = "Add to Collection"
        lblAddCollection.textAlignment = .center
        uiviewHeader.addSubview(lblAddCollection)
        
        btnCancel = UIButton(frame: CGRect(x: 0, y: 16, width: 87, height: 35))
        btnCancel.setTitle("Cancel", for: .normal)
        btnCancel.setTitleColor(UIColor._115115115(), for: .normal)
        btnCancel.titleLabel?.font = UIFont(name: "AvenirNext-Medium", size: 18)
        uiviewHeader.addSubview(btnCancel)
        btnCancel.addTarget(self, action: #selector(actionCancel(_:)), for: .touchUpInside)
        
        btnNew = UIButton(frame: CGRect(x: screenWidth - 69, y: 16, width: 69, height: 35))
        btnNew.setTitle("New", for: .normal)
        btnNew.setTitleColor(UIColor._2499090(), for: .normal)
        btnNew.titleLabel?.font = UIFont(name: "AvenirNext-Medium", size: 18)
        uiviewHeader.addSubview(btnNew)
        btnNew.addTarget(self, action: #selector(actionNew(_:)), for: .touchUpInside)
        
        loadTable()
    }
    
    fileprivate func loadTable() {
        tblAddCollection = UITableView(frame: CGRect(x: 0, y: 58, width: screenWidth, height: 434 * screenHeightFactor - 58))
        tblAddCollection.delegate = self
        tblAddCollection.dataSource = self
        tblAddCollection.showsVerticalScrollIndicator = false
        tblAddCollection.register(CollectionsListCell.self, forCellReuseIdentifier: "CollectionsListCell")
        tblAddCollection.separatorStyle = .none
        addSubview(tblAddCollection)
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 100
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return arrCollection.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tblAddCollection.dequeueReusableCell(withIdentifier: "CollectionsListCell", for: indexPath) as! CollectionsListCell
        let collection = arrCollection[indexPath.row]
        let isSavedInThisList = arrListSavedThisPin.contains(collection.colId)
        cell.setValueForCell(cols: collection, isIn: isSavedInThisList)
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        joshprint(arrCollection[indexPath.row])
        let colInfo = arrCollection[indexPath.row]
        uiviewAfterAdded.selectedCollection = colInfo
        self.timer?.invalidate()
        self.timer = nil
        if tableMode == .place {
            guard let placeData = pinToSave.pinInfo as? PlacePin else { return }
            FaeCollection.shared.saveToCollection(colInfo.colType, collectionID: "\(colInfo.colId)", pinID: "\(placeData.id)", completion: { (code, result) in
                guard code / 100 == 2 else { return }
                self.hide()
                self.uiviewAfterAdded.show()
                self.arrListSavedThisPin.append(colInfo.colId)
                self.uiviewAfterAdded.pinIdInAction = placeData.id
                self.tblAddCollection.reloadData()
                NotificationCenter.default.post(name: Notification.Name(rawValue: "showSavedNoti_place"), object: nil)
                NotificationCenter.default.post(name: Notification.Name(rawValue: "showSavedNoti_placeDetail"), object: nil)
                NotificationCenter.default.post(name: Notification.Name(rawValue: "showSavedNoti_explore"), object: nil)
                self.timer = Timer.scheduledTimer(timeInterval: 3, target: self, selector: #selector(self.timerFunc), userInfo: nil, repeats: false)
            })
        } else {
            guard self.uiviewAfterAdded.pinIdInAction == -1 else {
                let locationId = self.uiviewAfterAdded.pinIdInAction
                self.saveToCollection(colInfo: colInfo, locationId: locationId)
                return
            }
            mapScreenShot(coordinate: pinToSave.coordinate) { (snapShotImage) in
                FaeImage.shared.type = "image"
                FaeImage.shared.image = snapShotImage
                FaeImage.shared.faeUploadFile { (status, message) in
                    guard status / 100 == 2 else { return }
                    guard message != nil else { return }
                    let fileIDJSON = JSON(message!)
                    let fileId = fileIDJSON["file_id"].intValue
                    FaeMap.shared.whereKey("content", value: "\(fileId)")
                    FaeMap.shared.whereKey("file_ids", value: "\(fileId)")
                    FaeMap.shared.whereKey("geo_latitude", value: "\(self.pinToSave.coordinate.latitude)")
                    FaeMap.shared.whereKey("geo_longitude", value: "\(self.pinToSave.coordinate.longitude)")
                    FaeMap.shared.postPin(type: "location", completion: { (status, message) in
                        guard status / 100 == 2 else { return }
                        guard message != nil else { return }
                        let idJSON = JSON(message!)
                        let locationId = idJSON["location_id"].intValue
                        self.uiviewAfterAdded.pinIdInAction = locationId
                        self.saveToCollection(colInfo: colInfo, locationId: locationId)
                    })
                }
            }
        }
    }
    
    func saveToCollection(colInfo: PinCollection, locationId: Int) {
        FaeCollection.shared.saveToCollection(colInfo.colType, collectionID: "\(colInfo.colId)", pinID: "\(locationId)", completion: { (code, result) in
            guard code / 100 == 2 else { return }
            self.hide()
            self.uiviewAfterAdded.show()
            self.arrListSavedThisPin.append(colInfo.colId)
            self.tblAddCollection.reloadData()
            NotificationCenter.default.post(name: Notification.Name(rawValue: "showSavedNoti_loc"), object: locationId)
            NotificationCenter.default.post(name: Notification.Name(rawValue: "showSavedNoti_locDetail"), object: locationId)
            self.timer = Timer.scheduledTimer(timeInterval: 3, target: self, selector: #selector(self.timerFunc), userInfo: nil, repeats: false)
        })
    }
    
    func mapScreenShot(coordinate: CLLocationCoordinate2D, size: CGSize = CGSize(width: 66, height: 66), icon: Bool = true, _ completion: @escaping (UIImage) -> Void) {
        let mapSnapshotOptions = MKMapSnapshotOptions()
        
        // Set the region of the map that is rendered.
        let region = MKCoordinateRegionMakeWithDistance(coordinate, 1000, 1000)
        mapSnapshotOptions.region = region
        
        // Set the scale of the image. We'll just use the scale of the current device, which is 2x scale on Retina screens.
        mapSnapshotOptions.scale = UIScreen.main.scale
        
        // Set the size of the image output.
        mapSnapshotOptions.size = size
        
        // Show buildings and Points of Interest on the snapshot
        mapSnapshotOptions.showsBuildings = true
        mapSnapshotOptions.showsPointsOfInterest = true
        
        let snapShotter = MKMapSnapshotter(options: mapSnapshotOptions)
        
        snapShotter.start { (snapShot, error) in
            guard let snap = snapShot else { return }
//            let imgView = UIImageView(frame: CGRect(x: 0, y: 0, width: 66, height: 66))
//            imgView.image = snapShot?.image
//            UIApplication.shared.keyWindow?.addSubview(imgView)
            let imgMap = snap.image
            if icon == false {
                completion(imgMap)
                return
            }
            let imgAnnotation = UIImage(named: "locationMiniPin")!
            UIGraphicsBeginImageContextWithOptions(imgMap.size, true, imgMap.scale)
            imgMap.draw(at: .zero)
            let annotationHeight = imgMap.size.height / 3.0
            let annotationWith = annotationHeight * imgAnnotation.size.width / imgAnnotation.size.height
            imgAnnotation.draw(in: CGRect(x: (imgMap.size.width - annotationWith) / 2, y: (imgMap.size.height - annotationHeight) / 2, width: annotationWith, height: annotationHeight))
            let imgFinal = UIGraphicsGetImageFromCurrentImageContext()
            UIGraphicsEndImageContext()
            
            completion(imgFinal!)
        }
    }
    
    func timerFunc() {
        uiviewAfterAdded.hide()
    }
    
    func actionCancel(_ sender: UIButton) {
        print("actionCancel")
        delegate?.cancelAddPlace()
    }
    
    func actionNew(_ sender: UIButton) {
        delegate?.createColList()
    }
}

protocol AfterAddedToListDelegate: class {
    func seeList()
    func undoCollect(colId: Int)
}

class AfterAddedToListView: UIView {
    
    weak var delegate: AfterAddedToListDelegate?
    var uiviewAfterAdded: UIView!
    var pinIdInAction: Int = -1
    var selectedCollection: PinCollection!
    
    override init(frame: CGRect = .zero) {
        super.init(frame: CGRect(x: 0, y: screenHeight, width: screenWidth, height: 60))
        loadContent()
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    fileprivate func loadContent() {
        
        layer.zPosition = 1002
        
        let blurEffect = UIBlurEffect(style: UIBlurEffectStyle.dark)
        let blurEffectView = UIVisualEffectView(effect: blurEffect)
        blurEffectView.frame = self.bounds
        addSubview(blurEffectView)
        
        let lblSaved = FaeLabel(CGRect(x: 20, y: 19, width: 150, height: 25), .left, .medium, 18, .white)
        lblSaved.text = "Collocted to List!"
        addSubview(lblSaved)
        
        let btnUndo = UIButton()
        btnUndo.setTitle("Undo", for: .normal)
        btnUndo.setTitleColor(.white, for: .normal)
        btnUndo.setTitleColor(.lightGray, for: .highlighted)
        btnUndo.titleLabel?.font = FaeFont(fontType: .demiBold, size: 18)
        btnUndo.addTarget(self, action: #selector(undoCollecting), for: .touchUpInside)
        addSubview(btnUndo)
        addConstraintsWithFormat("H:[v0(46)]-109-|", options: [], views: btnUndo)
        addConstraintsWithFormat("V:|-19-[v0(25)]", options: [], views: btnUndo)
        
        let btnSeeList = UIButton()
        btnSeeList.setTitle("See List", for: .normal)
        btnSeeList.setTitleColor(.white, for: .normal)
        btnSeeList.setTitleColor(.lightGray, for: .highlighted)
        btnSeeList.titleLabel?.font = FaeFont(fontType: .demiBold, size: 18)
        btnSeeList.addTarget(self, action: #selector(goToList), for: .touchUpInside)
        addSubview(btnSeeList)
        addConstraintsWithFormat("H:[v0(64)]-20-|", options: [], views: btnSeeList)
        addConstraintsWithFormat("V:|-19-[v0(25)]", options: [], views: btnSeeList)
    }
    
    func undoCollecting() {
        guard let col = selectedCollection, pinIdInAction != -1 else { return }
        self.hide()
        FaeCollection.shared.unsaveFromCollection(col.colType, collectionID: String(col.colId), pinID: String(pinIdInAction)) { (status, message) in
            guard status / 100 == 2 else { return }
            joshprint("[undoCollecting] successfully undo saving")
            self.selectedCollection = nil
            self.delegate?.undoCollect(colId: col.colId)
        }
    }
    
    func goToList() {
        delegate?.seeList()
    }
    
    func show() {
        UIView.animate(withDuration: 0.3, delay: 0, options: .curveEaseOut, animations: {
            self.frame.origin.y = screenHeight - self.frame.size.height
        }, completion: nil)
    }
    
    func hide() {
        UIView.animate(withDuration: 0.3, delay: 0, options: .curveEaseOut, animations: {
            self.frame.origin.y = screenHeight
        }, completion: nil)
    }
}
