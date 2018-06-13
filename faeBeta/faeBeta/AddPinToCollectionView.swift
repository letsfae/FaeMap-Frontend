//
//  AddPinToCollectionView.swift
//  faeBeta
//
//  Created by Faevorite 2 on 2017-08-16.
//  Copyright © 2017 fae. All rights reserved.
//

import UIKit
import SwiftyJSON
import RealmSwift

protocol AddPinToCollectionDelegate: class {
    func createColList()
}

class AddPinToCollectionView: UIView, UITableViewDelegate, UITableViewDataSource {
    
    weak var delegate: AddPinToCollectionDelegate?
    
    private var uiviewHeader: UIView!
    private var btnNew: UIButton!
    private var btnCancel: UIButton!
    var tblAddCollection: UITableView!
    
    public var uiviewAfterAdded: AfterAddedToListView!
    private var realmColPlaces: Results<RealmCollection>!
    private var realmColLocations: Results<RealmCollection>!
    private let realm = try! Realm()
    public var tableMode: CollectionTableMode = .place {
        didSet {
            guard fullLoaded else { return }
            tblAddCollection.reloadData()
        }
    }
    public var pinToSave: FaePinAnnotation!
    private var timer: Timer?
    var arrListSavedThisPin = [Int]() {
        didSet {
            guard fullLoaded else { return }
            tblAddCollection.reloadData()
        }
    }
    private var fullLoaded = false
    private var notificationToken: NotificationToken? = nil
    public var fromLocDetail = false
    public var locId = -1
    private var showed: Bool = false
    
    override init(frame: CGRect = .zero) {
        super.init(frame: CGRect(x: 0, y: screenHeight, width: screenWidth, height: 434 * screenHeightFactor + device_offset_bot))
        backgroundColor = .white
        loadContent()
        loadCollectionData()
        observeOnCollectionChange()
        fullLoaded = true
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
    
    deinit {
        notificationToken?.invalidate()
    }

    private func loadCollectionData() {
        /*realmColPlaces = RealmCollection.filterCollectedTypes(type: "place")
        realmColLocations = RealmCollection.filterCollectedTypes(type: "location")*/
        realmColPlaces = realm.filterCollectedTypes(type: "place")
        realmColLocations = realm.filterCollectedTypes(type: "location")
    }
    
    func show() {
        guard !showed else { return }
        showed = true
        UIView.animate(withDuration: 0.3, delay: 0, options: .curveEaseOut, animations: {
            self.frame.origin.y = screenHeight - self.frame.size.height
        }, completion: nil)
    }
    
    func hide() {
        guard showed else { return }
        showed = false
        UIView.animate(withDuration: 0.3, delay: 0, options: .curveEaseOut, animations: {
            self.frame.origin.y = screenHeight
        }, completion: nil)
    }
    
    private func loadContent() {
        layer.zPosition = 1001
        
        uiviewHeader = UIView(frame: CGRect(x: 0, y: 0, width: screenWidth, height: 58))
        addSubview(uiviewHeader)
        
        let upperLine = UIView(frame: CGRect(x: 0, y: 0, width: screenWidth, height: 1))
        upperLine.backgroundColor = UIColor._200199204()
        uiviewHeader.addSubview(upperLine)
        
        let lowerLine = UIView(frame: CGRect(x: 0, y: 57, width: screenWidth, height: 1))
        lowerLine.backgroundColor = UIColor._200199204()
        uiviewHeader.addSubview(lowerLine)
        
        let lblAddCollection = UILabel(frame: CGRect(x: (screenWidth - 200) / 2, y: 20, width: 200, height: 27))
        lblAddCollection.textColor = UIColor._898989()
        lblAddCollection.font = UIFont(name: "AvenirNext-Medium", size: 20)
        lblAddCollection.text = "Collect"
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
        
        tblAddCollection = UITableView(frame: CGRect(x: 0, y: 58, width: screenWidth, height: 434 * screenHeightFactor - 58))
        tblAddCollection.delegate = self
        tblAddCollection.dataSource = self
        tblAddCollection.showsVerticalScrollIndicator = false
        tblAddCollection.register(CollectionsListCell.self, forCellReuseIdentifier: "CollectionsListCell")
        tblAddCollection.separatorStyle = .none
        addSubview(tblAddCollection)
    }
    
    // MARK: - Place Pin Save & Unsave
    
    private func savePlaceTo(collection: RealmCollection) {
        guard let placeData = pinToSave.pinInfo as? PlacePin else { return }
        FaeCollection.shared.saveToCollection(collection.type, collectionID: "\(collection.collection_id)", pinID: "\(placeData.id)", completion: { (code, result) in
            guard code / 100 == 2 else {
                
                return
            }
            self.hide()
            self.uiviewAfterAdded.show("Collected to List!")
            self.arrListSavedThisPin.append(collection.collection_id)
            self.uiviewAfterAdded.pinIdInAction = placeData.id
            //            self.tblAddCollection.reloadData()
            NotificationCenter.default.post(name: Notification.Name(rawValue: "showSavedNoti_place"), object: nil)
            NotificationCenter.default.post(name: Notification.Name(rawValue: "showSavedNoti_placeDetail"), object: nil)
            NotificationCenter.default.post(name: Notification.Name(rawValue: "showSavedNoti_explore"), object: nil)
            self.timer = Timer.scheduledTimer(timeInterval: 4, target: self, selector: #selector(self.timerFunc), userInfo: nil, repeats: false)
            // save pin to RealmCollection
            RealmCollection.savePin(collection_id: collection.collection_id, type: "place", pin_id: placeData.id)
        })
    }
    
    private func unsavePlaceFrom(collection: RealmCollection) {
        guard let placeData = pinToSave.pinInfo as? PlacePin else { return }
        FaeCollection.shared.unsaveFromCollection(collection.type, collectionID: "\(collection.collection_id)", pinID: "\(placeData.id)", completion: { (code, result) in
            guard code / 100 == 2 else { return }
            self.hide()
            self.uiviewAfterAdded.show(save: false, "Removed from List!")
            self.arrListSavedThisPin = self.arrListSavedThisPin.filter({ $0 != collection.collection_id })
            self.uiviewAfterAdded.pinIdInAction = placeData.id
            self.tblAddCollection.reloadData()
            if self.arrListSavedThisPin.count == 0 {
                NotificationCenter.default.post(name: Notification.Name(rawValue: "hideSavedNoti_place"), object: nil)
                NotificationCenter.default.post(name: Notification.Name(rawValue: "hideSavedNoti_placeDetail"), object: nil)
                NotificationCenter.default.post(name: Notification.Name(rawValue: "hideSavedNoti_explore"), object: nil)
            }
            self.timer = Timer.scheduledTimer(timeInterval: 4, target: self, selector: #selector(self.timerFunc), userInfo: nil, repeats: false)
            
            // delete pin from RealmCollection
            RealmCollection.unsavePin(collection_id: collection.collection_id, type: "location", pin_id: placeData.id)
        })
    }
    
    private func saveLocationTo(collection: RealmCollection) {
        //print("[pin in action]" ,uiviewAfterAdded.pinIdInAction)
        guard uiviewAfterAdded.pinIdInAction == -1 else {
            let locationId = uiviewAfterAdded.pinIdInAction
            saveLocationToWithId(collection, locationId)
            return
        }
        
        if fromLocDetail && uiviewAfterAdded.pinIdInAction > 0 {
            let locationId = locId
            saveLocationToWithId(collection, locationId)
            return
        }
        
        // TODO YUE 这个地方经常报错
        Key.shared.FMVCtrler?.useActivityIndicator(on: true)
        
        // 1: get screen shot of loc pin
        mapScreenShot(coordinate: pinToSave.coordinate) { (snapShotImage) in
            FaeImage.shared.type = "image"
            FaeImage.shared.image = snapShotImage
            
            // 2: upload the screen shot and get file id
            FaeImage.shared.faeUploadFile { (status, message) in
                guard status / 100 == 2 && message != nil else {
                    Key.shared.FMVCtrler?.useActivityIndicator(on: false)
                    showAlert(title: "Tried to save pin but failed", message: "please try again", viewCtrler: Key.shared.FMVCtrler)
                    return
                }
                let fileIDJSON = JSON(message!)
                let fileId = fileIDJSON["file_id"].intValue
                
                // 3: create a loc pin in server with file id
                FaeMap.shared.whereKey("content", value: "\(fileId)")
                FaeMap.shared.whereKey("file_ids", value: "\(fileId)")
                FaeMap.shared.whereKey("geo_latitude", value: "\(self.pinToSave.coordinate.latitude)")
                FaeMap.shared.whereKey("geo_longitude", value: "\(self.pinToSave.coordinate.longitude)")
                FaeMap.shared.postPin(type: "location", completion: { (status, message) in
                    guard status / 100 == 2 else {
                        Key.shared.FMVCtrler?.useActivityIndicator(on: false)
                        showAlert(title: "Tried to save pin but failed", message: "please try again", viewCtrler: Key.shared.FMVCtrler)
                        return
                    }
                    guard message != nil else {
                        Key.shared.FMVCtrler?.useActivityIndicator(on: false)
                        showAlert(title: "Tried to save pin but failed", message: "please try again", viewCtrler: Key.shared.FMVCtrler)
                        return
                    }
                    let idJSON = JSON(message!)
                    let locationId = idJSON["location_id"].intValue
                    print("locationId \(locationId)")
                    self.uiviewAfterAdded.pinIdInAction = locationId
                    
                    // 4: save loc pin to server
                    self.saveLocationToWithId(collection, locationId)
                })
            }
        }
    }
    
    private func saveLocationToWithId(_ collection: RealmCollection, _ locationId: Int) {
        FaeCollection.shared.saveToCollection(collection.type, collectionID: "\(collection.collection_id)", pinID: "\(locationId)", completion: { (code, result) in
            Key.shared.FMVCtrler?.useActivityIndicator(on: false)
            guard code / 100 == 2 else {
                showAlert(title: "Tried to save pin but failed", message: "please try again", viewCtrler: Key.shared.FMVCtrler)
                return
            }
            self.hide()
            self.uiviewAfterAdded.show("Collected to List!")
            self.arrListSavedThisPin.append(collection.collection_id)
            NotificationCenter.default.post(name: Notification.Name(rawValue: "showSavedNoti_loc"), object: locationId)
            NotificationCenter.default.post(name: Notification.Name(rawValue: "showSavedNoti_locDetail"), object: locationId)
            self.timer = Timer.scheduledTimer(timeInterval: 3, target: self, selector: #selector(self.timerFunc), userInfo: nil, repeats: false)
            
            // save pin to RealmCollection
            
            RealmCollection.savePin(collection_id: collection.collection_id, type: "location", pin_id: locationId)
        })
    }
    
    private func unsaveLocationFrom(_ collection: RealmCollection, _ locationId: Int) {
        let loc_id = fromLocDetail ? locId : locationId
        print("unsave \(collection) \(locId)")
        FaeCollection.shared.unsaveFromCollection(collection.type, collectionID: "\(collection.collection_id)", pinID: "\(loc_id)", completion: { (code, result) in
            guard code / 100 == 2 else { return }
            self.hide()
            self.uiviewAfterAdded.show(save: false, "Removed from List!")
            self.arrListSavedThisPin = self.arrListSavedThisPin.filter({ $0 != collection.collection_id })
            self.uiviewAfterAdded.pinIdInAction = loc_id
//            self.tblAddCollection.reloadData()
            if self.arrListSavedThisPin.count == 0 {
                NotificationCenter.default.post(name: Notification.Name(rawValue: "hideSavedNoti_loc"), object: loc_id)
                NotificationCenter.default.post(name: Notification.Name(rawValue: "hideSavedNoti_locDetail"), object: loc_id)
            }
            self.timer = Timer.scheduledTimer(timeInterval: 3, target: self, selector: #selector(self.timerFunc), userInfo: nil, repeats: false)
            
            // unsave pin from RealmCollection
            RealmCollection.unsavePin(collection_id: collection.collection_id, type: "location", pin_id: loc_id)
        })
    }
    
    private func observeOnCollectionChange() {
        let datasource = tableMode == .place ? realmColPlaces : realmColLocations
        notificationToken?.invalidate()
        notificationToken = datasource?.observe { [weak self] (changes: RealmCollectionChange) in
            guard let tableview = self?.tblAddCollection else { return }
            switch changes {
            case .initial:
                tableview.reloadData()
            case .update(_, let deletions, let insertions, let modifications):
                tableview.beginUpdates()
                tableview.insertRows(at: insertions.map({ IndexPath(row: $0, section: 0)}), with: .none)
                tableview.deleteRows(at: deletions.map({ IndexPath(row: $0, section: 0)}), with: .right)
                tableview.reloadRows(at: modifications.map({ IndexPath(row: $0, section: 0)}), with: .none)
                tableview.endUpdates()
            case .error:
                print("error")
            }
        }
    }
    
    @objc private func timerFunc() {
        uiviewAfterAdded.hide()
    }
    
    @objc private func actionCancel(_ sender: UIButton) {
        self.hide()
    }
    
    @objc private func actionNew(_ sender: UIButton) {
        delegate?.createColList()
    }
}

// MARK: - Table View Delegate

extension AddPinToCollectionView {
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 100
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return tableMode == .place ? realmColPlaces.count : realmColLocations.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tblAddCollection.dequeueReusableCell(withIdentifier: "CollectionsListCell", for: indexPath) as! CollectionsListCell
        let collection = tableMode == .place ? realmColPlaces[indexPath.row] : realmColLocations[indexPath.row]
        let isSavedInThisList = arrListSavedThisPin.contains(collection.collection_id)
        cell.setValueForCell(cols: collection, isIn: isSavedInThisList)
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        //joshprint(arrCollection[indexPath.row])
        let colInfo = tableMode == .place ? realmColPlaces[indexPath.row] : realmColLocations[indexPath.row]
        uiviewAfterAdded.selectedCollection = colInfo
        self.timer?.invalidate()
        self.timer = nil
        let isInThisList = arrListSavedThisPin.contains(colInfo.collection_id)
        switch tableMode {
        case .place:
            if isInThisList {
                unsavePlaceFrom(collection: colInfo)
            } else {
                savePlaceTo(collection: colInfo)
            }
        case .location:
            if isInThisList {
                let locationId = self.uiviewAfterAdded.pinIdInAction
                unsaveLocationFrom(colInfo, locationId)
            } else {
                saveLocationTo(collection: colInfo)
            }
        }
    }
}

// MARK: - Get Screen Shot of Location with Map

extension AddPinToCollectionView {
    
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
}
