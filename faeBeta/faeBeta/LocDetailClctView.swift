//
//  LocDetailTableView.swift
//  faeBeta
//
//  Created by Yue Shen on 9/25/17.
//  Copyright © 2017 fae. All rights reserved.
//

import UIKit

extension LocDetailViewController: UICollectionViewDelegate, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout {
    
    func loadCollectionView() {
        let uiviewClctView = UIView(frame: CGRect(x: 0, y: screenHeight - 234 - 49, width: screenWidth, height: 234))
        view.addSubview(uiviewClctView)
        
        lblClctViewTitle = UILabel(frame: CGRect(x: 15, y: 15, width: 150, height: 20))
        uiviewClctView.addSubview(lblClctViewTitle)
        lblClctViewTitle.font = UIFont(name: "AvenirNext-DemiBold", size: 15)
        lblClctViewTitle.textColor = UIColor._138138138()
        lblClctViewTitle.text = "Near this Location"
        
        btnSeeAll = UIButton(frame: CGRect(x: screenWidth - 78, y: 5, width: 78, height: 40))
        uiviewClctView.addSubview(btnSeeAll)
        btnSeeAll.setTitleColor(UIColor._155155155(), for: .normal)
        btnSeeAll.titleLabel?.font = UIFont(name: "AvenirNext-Medium", size: 15)
        btnSeeAll.addTarget(self, action: #selector(btnSeeAllTapped(_:)), for: .touchUpInside)
        
        let flowLayout = UICollectionViewFlowLayout()
        flowLayout.itemSize = CGSize(width: 122, height: 222 - 45)
        flowLayout.minimumLineSpacing = 20
        flowLayout.scrollDirection = .horizontal
        flowLayout.sectionInset = UIEdgeInsetsMake(0, 24, 0, 24)
        clctNearby = UICollectionView(frame: CGRect(x: 0, y: 45, width: screenWidth, height: 222 - 45), collectionViewLayout: flowLayout)
        clctNearby.showsHorizontalScrollIndicator = false
        clctNearby.delegate = self
        clctNearby.dataSource = self
        clctNearby.register(PlacesCollectionCell.self, forCellWithReuseIdentifier: "PlacesCollectionCell")
        uiviewClctView.addSubview(clctNearby)
        clctNearby.backgroundColor = .clear
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return arrNearbyPlaces.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let colCell = collectionView.dequeueReusableCell(withReuseIdentifier: "PlacesCollectionCell", for: indexPath) as! PlacesCollectionCell
        let place = arrNearbyPlaces[indexPath.row]
        colCell.setValueForColCell(place: place)
        return colCell
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        delegateSeeAll?.jumpToPlaceDetail(place: arrNearbyPlaces[indexPath.row])
    }
    
    func btnSeeAllTapped(_ sender: UIButton) {
        delegateSeeAll?.jumpToAllPlaces(places: arrNearbyPlaces, title: "Near this Location")
    }
}
