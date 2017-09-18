//
//  EXPMapViewController.swift
//  faeBeta
//
//  Created by Yue Shen on 9/14/17.
//  Copyright © 2017 fae. All rights reserved.
//

import UIKit

class EXPMapViewController: UIViewController, MKMapViewDelegate, UICollectionViewDelegate, UICollectionViewDataSource {
    
    static let shared = EXPMapViewController()
    
    var lblSearchContent: UILabel!
    var faeMapView: MKMapView!
    var clctViewMap: UICollectionView!
    var arrPlaceData = [PlacePin]()
    var faePlacePins = [FaePinAnnotation]()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .white
        loadMapView()
        loadSearchBar()
        loadSmallClctView()
        setTitle(type: "Random")
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        clctViewMap.reloadData()
        let annotations = faeMapView.annotations
        faeMapView.removeAnnotations(annotations)
        faePlacePins = arrPlaceData.map { FaePinAnnotation(type: "place", cluster: nil, data: $0) }
        faeMapView.addAnnotations(faePlacePins)
        zoomToFitAllAnnotations(annotations: faePlacePins)
    }
    
    func zoomToFitAllAnnotations(annotations: [MKPointAnnotation]) {
        guard let firstAnn = annotations.first else { return }
        let point = MKMapPointForCoordinate(firstAnn.coordinate)
        var zoomRect = MKMapRectMake(point.x, point.y, 0.1, 0.1)
        for annotation in annotations {
            let annotationPoint = MKMapPointForCoordinate(annotation.coordinate)
            let pointRect = MKMapRectMake(annotationPoint.x, annotationPoint.y, 0.1, 0.1)
            zoomRect = MKMapRectUnion(zoomRect, pointRect)
        }
        let edgePadding = UIEdgeInsetsMake(100, 40, 100, 40)
        faeMapView.setVisibleMapRect(zoomRect, edgePadding: edgePadding, animated: true)
    }
    
    func mapView(_ mapView: MKMapView, viewFor annotation: MKAnnotation) -> MKAnnotationView? {
        if annotation is MKUserLocation {
            let identifier = "self_selected_mode"
            var anView: SelfAnnotationView
            if let dequeuedView = mapView.dequeueReusableAnnotationView(withIdentifier: identifier) as? SelfAnnotationView {
                dequeuedView.annotation = annotation
                anView = dequeuedView
            } else {
                anView = SelfAnnotationView(annotation: annotation, reuseIdentifier: identifier)
            }
            if userStatus == 5 {
                anView.invisibleOn()
            }
            return anView
        } else if annotation is FaePinAnnotation {
            guard let firstAnn = annotation as? FaePinAnnotation else { return nil }
            guard firstAnn.type == "place" else { return nil }
            return viewForPlace(annotation: annotation, first: firstAnn)
        } else {
            return nil
        }
    }
    
    func viewForPlace(annotation: MKAnnotation, first: FaePinAnnotation, animated: Bool = true) -> MKAnnotationView {
        let identifier = "place"
        var anView: PlacePinAnnotationView
        if let dequeuedView = faeMapView.dequeueReusableAnnotationView(withIdentifier: identifier) as? PlacePinAnnotationView {
            dequeuedView.annotation = annotation
            anView = dequeuedView
        } else {
            anView = PlacePinAnnotationView(annotation: annotation, reuseIdentifier: identifier)
        }
        anView.assignImage(first.icon)
//        anView.delegate = self
        if animated {
            if first.animatable {
                let delay: Double = Double(arc4random_uniform(100)) / 100 // Delay 0-1 seconds, randomly
                DispatchQueue.main.async {
                    anView.imgIcon.frame = CGRect(x: 28, y: 56, width: 0, height: 0)
                    UIView.animate(withDuration: 0.6, delay: delay, usingSpringWithDamping: 0.4, initialSpringVelocity: 0, options: .curveLinear, animations: {
                        anView.imgIcon.frame = CGRect(x: 0, y: 0, width: 56, height: 56)
                        anView.alpha = 1
                    }, completion: nil)
                }
            } else {
                anView.imgIcon.frame = CGRect(x: 0, y: 0, width: 56, height: 56)
                anView.alpha = 1
            }
        } else {
            anView.imgIcon.frame = CGRect(x: 0, y: 0, width: 56, height: 56)
            anView.alpha = 1
        }
        return anView
    }
    
    func actionBack(_ sender: UIButton) {
        navigationController?.popViewController(animated: false)
    }
    
    func loadSearchBar() {
        let imgSchbarShadow = UIImageView()
        imgSchbarShadow.frame = CGRect(x: 2, y: 17, width: 410 * screenWidthFactor, height: 60)
        imgSchbarShadow.image = #imageLiteral(resourceName: "mapSearchBar")
        view.addSubview(imgSchbarShadow)
        imgSchbarShadow.layer.zPosition = 500
        imgSchbarShadow.isUserInteractionEnabled = true
        
        // Left window on main map to open account system
        let btnLeftWindow = UIButton()
        btnLeftWindow.setImage(#imageLiteral(resourceName: "mainScreenSearchToFaeMap"), for: .normal)
        imgSchbarShadow.addSubview(btnLeftWindow)
        btnLeftWindow.addTarget(self, action: #selector(self.actionBack(_:)), for: .touchUpInside)
        imgSchbarShadow.addConstraintsWithFormat("H:|-6-[v0(40.5)]", options: [], views: btnLeftWindow)
        imgSchbarShadow.addConstraintsWithFormat("V:|-6-[v0(48)]", options: [], views: btnLeftWindow)
        btnLeftWindow.adjustsImageWhenDisabled = false
        
        lblSearchContent = UILabel()
        lblSearchContent.textAlignment = .center
        lblSearchContent.numberOfLines = 1
        lblSearchContent.font = UIFont(name: "AvenirNext-Medium", size: 18)
        lblSearchContent.textColor = UIColor._898989()
        imgSchbarShadow.addSubview(lblSearchContent)
        imgSchbarShadow.addConstraintsWithFormat("H:|-0-[v0]-0-|", options: [], views: lblSearchContent)
        imgSchbarShadow.addConstraintsWithFormat("V:|-18.5-[v0(25)]", options: [], views: lblSearchContent)
    }
    
    func setTitle(type: String) {
        let title_0 = type
        let title_1 = " Around Me"
        let attrs_0 = [NSForegroundColorAttributeName: UIColor._898989(), NSFontAttributeName: UIFont(name: "AvenirNext-Medium", size: 18)!]
        let attrs_1 = [NSForegroundColorAttributeName: UIColor._2499090(), NSFontAttributeName: UIFont(name: "AvenirNext-Medium", size: 18)!]
        let title_0_attr = NSMutableAttributedString(string: title_0, attributes: attrs_0)
        let title_1_attr = NSMutableAttributedString(string: title_1, attributes: attrs_1)
        title_0_attr.append(title_1_attr)
        
        lblSearchContent.attributedText = title_0_attr
    }
    
    func loadMapView() {
        faeMapView = FaeMapView(frame: CGRect(x: 0, y: 0, width: screenWidth, height: screenHeight))
        faeMapView.delegate = self
        view.addSubview(faeMapView)
        view.sendSubview(toBack: faeMapView)
        faeMapView.showsPointsOfInterest = false
        faeMapView.showsCompass = false
        faeMapView.delegate = self
        faeMapView.showsUserLocation = true
        let camera = faeMapView.camera
        camera.altitude = Key.shared.dblAltitude
        camera.centerCoordinate = Key.shared.selectedLoc
        camera.altitude = 35000
        faeMapView.setCamera(camera, animated: false)
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return arrPlaceData.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        if collectionView == clctViewMap {
            let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "exp_pics_map", for: indexPath) as! EXPClctPicMapCell
            cell.updateCell(placeData: arrPlaceData[indexPath.row])
            return cell
        } else {
            let cell = UICollectionViewCell()
            return cell
        }
    }
    
    func loadSmallClctView() {
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
        view.addSubview(clctViewMap)
        view.addConstraintsWithFormat("H:|-0-[v0]-0-|", options: [], views: clctViewMap)
        view.addConstraintsWithFormat("V:[v0(310)]-4-|", options: [], views: clctViewMap)
    }
}
