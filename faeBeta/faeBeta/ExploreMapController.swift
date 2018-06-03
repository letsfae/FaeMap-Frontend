//
//  CollectionMapController.swift
//  faeBeta
//
//  Created by Yue Shen on 5/2/18.
//  Copyright © 2018 fae. All rights reserved.
//

import UIKit

class ExploreMapController: BasicMapController, UICollectionViewDelegate, UICollectionViewDataSource, UIScrollViewDelegate, EXPCellDelegate {
    
    // MARK: - Vars
    
    var arrExpPlace = [PlacePin]()
    var strCategory: String = ""
    private var clctViewMap: UICollectionView!
    private var intCurtPage = 0
    private var placeAnnos = [FaePinAnnotation]()
    
    // MARK: - Life Cycles
    
    override func viewDidLoad() {
        super.viewDidLoad()
        loadTopBar()
        loadClctView()
        loadAnnotations(places: arrExpPlace)
        setTitle(type: strCategory)
        faeMapView.singleTap.isEnabled = true
        faeMapView.doubleTap.isEnabled = false
        faeMapView.longPress.isEnabled = false
        faeMapView.isSingleTapToShowFourIconsEnabled = false
        faeMapView.mapAction = self
        btnZoom.isHidden = true
        btnLocat.isHidden = true
    }
    
    // MARK: - Setup UI
    
    private func loadClctView() {
        let layout = CenterCellCollectionViewFlowLayout()
        layout.scrollDirection = .horizontal
        layout.minimumInteritemSpacing = 0
        layout.minimumLineSpacing = -17
        layout.itemSize = CGSize(width: 250, height: 310)
        
        clctViewMap = UICollectionView(frame: CGRect.zero, collectionViewLayout: layout)
        clctViewMap.register(EXPClctPicMapCell.self, forCellWithReuseIdentifier: "exp_pics_map")
        clctViewMap.delegate = self
        clctViewMap.dataSource = self
        clctViewMap.isPagingEnabled = false
        clctViewMap.backgroundColor = UIColor.clear
        clctViewMap.showsHorizontalScrollIndicator = false
        clctViewMap.contentInset = UIEdgeInsets(top: 0, left: (screenWidth - 250) / 2, bottom: 0, right: (screenWidth - 250) / 2)
        clctViewMap.decelerationRate = UIScrollViewDecelerationRateFast
        clctViewMap.layer.zPosition = 600
        view.addSubview(clctViewMap)
        view.addConstraintsWithFormat("H:|-0-[v0]-0-|", options: [], views: clctViewMap)
        view.addConstraintsWithFormat("V:[v0(310)]-\(4+device_offset_bot)-|", options: [], views: clctViewMap)
    }
    
    override func loadTopBar() {
        super.loadTopBar()
        lblTopBarCenter = FaeLabel(.zero, .center, .medium, 18, ._898989())
        uiviewTopBar.addSubview(lblTopBarCenter)
        uiviewTopBar.addConstraintsWithFormat("H:|-0-[v0]-0-|", options: [], views: lblTopBarCenter)
        uiviewTopBar.addConstraintsWithFormat("V:|-12.5-[v0(25)]", options: [], views: lblTopBarCenter)
    }
    
    // MARK: - CollectionView Delegates
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return arrExpPlace.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        if collectionView == clctViewMap {
            let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "exp_pics_map", for: indexPath) as! EXPClctPicMapCell
            cell.delegate = self
            cell.updateCell(placeData: arrExpPlace[indexPath.row])
            return cell
        } else {
            let cell = UICollectionViewCell()
            return cell
        }
    }
    
    // MARK: - ScrollView Delegates
    func scrollViewDidEndDecelerating(_ scrollView: UIScrollView) {
        let pageWidth: CGFloat = 233
        intCurtPage = Int((clctViewMap.contentOffset.x + 63) / pageWidth)
        highlightPlace(intCurtPage)
    }

    private func highlightPlace(_ idx: Int) {
        guard idx < arrExpPlace.count else { return }
        
        let place = arrExpPlace[idx]
        
        func findAnnotation() {
            var desiredAnno: CCHMapClusterAnnotation!
            for anno in faeMapView.annotations {
                guard let cluster = anno as? CCHMapClusterAnnotation else { continue }
                guard let firstAnn = cluster.annotations.first as? FaePinAnnotation else { continue }
                guard let placeInfo = firstAnn.pinInfo as? PlacePin else { continue }
                if placeInfo == place {
                    desiredAnno = cluster
                    break
                }
            }
            faeBeta.animateToCoordinate(mapView: faeMapView, coordinate: place.coordinate)
            if desiredAnno != nil {
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
                    self.faeMapView.selectAnnotation(desiredAnno, animated: false)
                }
            }
        }
        
        deselectAllAnnotations()
        
        findAnnotation()
        /*
        for place in self.visibleClusterPins {
            guard let firstAnn = place.annotations.first as? FaePinAnnotation else { continue }
            guard firstAnn.id == pinId else { continue }
            let idx = firstAnn.class_2_icon_id
            firstAnn.icon = UIImage(named: "place_map_\(idx)s") ?? #imageLiteral(resourceName: "place_map_48")
            guard let anView = faeMapView.view(for: place) as? PlacePinAnnotationView else { continue }
            anView.assignImage(firstAnn.icon)
            selectedPlace = firstAnn
            selectedPlaceView = anView
        }
         */
    }
    
    // MARK: - Pin Control
    
    override func tapPlacePin(didSelect view: MKAnnotationView) {
        super.tapPlacePin(didSelect: view)
        guard let cluster = view.annotation as? CCHMapClusterAnnotation else { return }
        guard let firstAnn = cluster.annotations.first as? FaePinAnnotation else { return }
        scrollTo(firstAnn.id)
    }
    
    private func loadAnnotations(places: [PlacePin]) {
        placeAnnos = places.map { FaePinAnnotation(type: .place, cluster: self.placeClusterManager, data: $0) }
        placeClusterManager.addAnnotations(placeAnnos, withCompletionHandler: {
            self.highlightPlace(0)
        })
        zoomToFitAllAnnotations(annotations: placeAnnos)
    }
    
    // MARK: - EXPCellDelegate
    func jumpToPlaceDetail(_ placeInfo: PlacePin) {
        let vcPlaceDetail = PlaceDetailViewController()
        vcPlaceDetail.place = placeInfo
        navigationController?.pushViewController(vcPlaceDetail, animated: true)
    }
    
    // MARK: - 辅助函数
    
    private func deselectAllAnnotations(full: Bool = true) {
        
        if let idx = selectedPlace?.class_2_icon_id {
            if full {
                selectedPlace?.icon = UIImage(named: "place_map_\(idx)") ?? #imageLiteral(resourceName: "place_map_48")
                selectedPlace?.isSelected = false
                guard let img = selectedPlace?.icon else { return }
                selectedPlaceAnno?.assignImage(img)
                selectedPlaceAnno?.hideButtons()
                selectedPlaceAnno?.superview?.sendSubview(toBack: selectedPlaceAnno!)
                selectedPlaceAnno?.zPos = 7
                selectedPlaceAnno?.optionsReady = false
                selectedPlaceAnno?.optionsOpened = false
                selectedPlaceAnno = nil
                selectedPlace = nil
            } else {
                selectedPlaceAnno?.hideButtons()
                selectedPlaceAnno?.optionsOpened = false
            }
        }
    }
    
    private func scrollTo(_ id: Int) {
        guard arrExpPlace.count > 0 else { return }
        for i in 0..<arrExpPlace.count {
            guard arrExpPlace[i].id == id else { continue }
            var offset = clctViewMap.contentOffset
            offset.x = CGFloat(233 * i) - 63
            clctViewMap.setContentOffset(offset, animated: true)
        }
    }
    
    private func zoomToFitAllAnnotations(annotations: [MKPointAnnotation]) {
        guard let firstAnn = annotations.first else { return }
        let point = MKMapPointForCoordinate(firstAnn.coordinate)
        var zoomRect = MKMapRectMake(point.x, point.y, 0.1, 0.1)
        for annotation in annotations {
            let annotationPoint = MKMapPointForCoordinate(annotation.coordinate)
            let pointRect = MKMapRectMake(annotationPoint.x, annotationPoint.y, 0.1, 0.1)
            zoomRect = MKMapRectUnion(zoomRect, pointRect)
        }
        var edgePadding = UIEdgeInsetsMake(240, 40, 100, 40)
        edgePadding = UIEdgeInsetsMake(120, 40, 300, 40)
        faeMapView.setVisibleMapRect(zoomRect, edgePadding: edgePadding, animated: false)
    }
    
    private func setTitle(type: String) {
        let title_0 = type
        let title_1 = " Around Me"
        let attrs_0 = [NSAttributedStringKey.foregroundColor: UIColor._898989(), NSAttributedStringKey.font: UIFont(name: "AvenirNext-Medium", size: 18)!]
        let attrs_1 = [NSAttributedStringKey.foregroundColor: UIColor._2499090(), NSAttributedStringKey.font: UIFont(name: "AvenirNext-Medium", size: 18)!]
        let title_0_attr = NSMutableAttributedString(string: title_0, attributes: attrs_0)
        let title_1_attr = NSMutableAttributedString(string: title_1, attributes: attrs_1)
        title_0_attr.append(title_1_attr)
        
        lblTopBarCenter.attributedText = title_0_attr
    }
    
    // MARK: Find Map Annotation
    
}

extension ExploreMapController: MapAction {
    
    func placePinTap(view: MKAnnotationView) {
        tapPlacePin(didSelect: view)
    }
    
    func allPlacesDeselect(_ full: Bool) {
        deselectAllAnnotations(full: full)
    }
    
    func singleElsewhereTapExceptInfobar() {
        faeMapView.mapGesture(isOn: true)
        deselectAllAnnotations(full: true)
    }
}
