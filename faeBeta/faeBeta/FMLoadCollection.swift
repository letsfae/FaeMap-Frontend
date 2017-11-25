//
//  FMLoadCollection.swift
//  faeBeta
//
//  Created by Yue Shen on 9/17/17.
//  Copyright © 2017 fae. All rights reserved.
//

import UIKit

extension FaeMapViewController: UICollectionViewDelegate, UICollectionViewDataSource, UIScrollViewDelegate, EXPCellDelegate {
    
    // EXPCellDelegate
    func jumpToPlaceDetail(_ placeInfo: PlacePin) {
        let vcPlaceDetail = PlaceDetailViewController()
        vcPlaceDetail.place = placeInfo
        vcPlaceDetail.featureDelegate = self
        vcPlaceDetail.delegate = self
        navigationController?.pushViewController(vcPlaceDetail, animated: true)
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
        clctViewMap.layer.zPosition = 600
        view.addSubview(clctViewMap)
        view.addConstraintsWithFormat("H:|-0-[v0]-0-|", options: [], views: clctViewMap)
        view.addConstraintsWithFormat("V:[v0(310)]-\(4+device_offset_bot)-|", options: [], views: clctViewMap)
        
        clctViewMap.isHidden = true
    }
    
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
    
    func scrollViewDidEndDecelerating(_ scrollView: UIScrollView) {
        let pageWidth: CGFloat = 233
        intCurtPage = Int((clctViewMap.contentOffset.x + 63) / pageWidth)
        highlightPlace(intCurtPage)
    }
    
    func highlightPlace(_ idx: Int) {
        guard idx < arrExpPlace.count else { return }
        deselectAllAnnotations()
        let pinId = arrExpPlace[idx].id
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
    }
    
    func scrollTo(_ id: Int) {
        guard arrExpPlace.count > 0 else { return }
        for i in 0..<arrExpPlace.count {
            guard arrExpPlace[i].id == id else { continue }
            var offset = clctViewMap.contentOffset
            offset.x = CGFloat(233 * i) - 63
            clctViewMap.setContentOffset(offset, animated: true)
        }
    }
}
