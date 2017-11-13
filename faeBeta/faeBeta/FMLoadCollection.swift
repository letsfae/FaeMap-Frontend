//
//  FMLoadCollection.swift
//  faeBeta
//
//  Created by Yue Shen on 9/17/17.
//  Copyright © 2017 fae. All rights reserved.
//

import UIKit

extension FaeMapViewController: UICollectionViewDelegate, UICollectionViewDataSource, UIScrollViewDelegate {
    
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
            cell.updateCell(placeData: arrExpPlace[indexPath.row])
            return cell
        } else {
            let cell = UICollectionViewCell()
            return cell
        }
    }
    
    func scrollViewDidEndDecelerating(_ scrollView: UIScrollView) {
        let pageWidth: CGFloat = 250
        joshprint(clctViewMap.contentOffset.x)
        intCurtPage = Int(clctViewMap.contentOffset.x / pageWidth)
        joshprint(intCurtPage)
    }
}
