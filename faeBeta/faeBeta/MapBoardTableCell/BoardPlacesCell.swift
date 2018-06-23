//
//  BoardPlacesCell.swift
//  FaeMapBoard
//
//  Created by vicky on 4/14/17.
//  Copyright © 2017 Yue. All rights reserved.
//

import UIKit

protocol SeeAllPlacesDelegate: class {
    func jumpToAllPlaces(places inCategory: BoardPlaceCategoryViewModel)
    func jumpToPlaceDetail(place: PlacePin)
}

class BoardPlacesCell: UITableViewCell, UICollectionViewDelegate, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout {
    
    weak var delegate: SeeAllPlacesDelegate?
    var lblTitle: UILabel!
    var btnSeeAll: UIButton!
    var colInfo: UICollectionView!
    var viewModelPlaces: BoardPlaceCategoryViewModel!
    var title: String!
    
    override init(style: UITableViewCellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        selectionStyle = .none
        loadCellContent()
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
    
    fileprivate func loadCellContent() {
        lblTitle = UILabel(frame: CGRect(x: 15, y: 15, width: 250, height: 20))
        addSubview(lblTitle)
        lblTitle.font = UIFont(name: "AvenirNext-DemiBold", size: 15)
        lblTitle.textColor = UIColor._138138138()
        
        btnSeeAll = UIButton(frame: CGRect(x: screenWidth - 78, y: 5, width: 78, height: 40))
        addSubview(btnSeeAll)
        btnSeeAll.setTitleColor(UIColor._155155155(), for: .normal)
        btnSeeAll.titleLabel?.font = UIFont(name: "AvenirNext-Medium", size: 15)
        btnSeeAll.addTarget(self, action: #selector(btnSeeAllTapped(_:)), for: .touchUpInside)
        btnSeeAll.setTitle("See All", for: .normal)
        
        let flowLayout = UICollectionViewFlowLayout()
        flowLayout.itemSize = CGSize(width: 122, height: 222 - 45)
        flowLayout.minimumLineSpacing = 20
        flowLayout.scrollDirection = .horizontal
        flowLayout.sectionInset = UIEdgeInsetsMake(0, 24, 0, 24)
        colInfo = UICollectionView(frame: CGRect(x: 0, y: 45, width: screenWidth, height: 222 - 45), collectionViewLayout: flowLayout)
        colInfo.showsHorizontalScrollIndicator = false
        colInfo.delegate = self
        colInfo.dataSource = self
        colInfo.register(PlacesCollectionCell.self, forCellWithReuseIdentifier: "PlacesCollectionCell")
        addSubview(colInfo)
        colInfo.backgroundColor = .clear
    }
    
    func setValueForCell(viewModelPlaces: BoardPlaceCategoryViewModel) {
        self.title = viewModelPlaces.title
        lblTitle.text = viewModelPlaces.title

        self.viewModelPlaces = viewModelPlaces
        colInfo.reloadData()
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        if let viewModelPlaces = viewModelPlaces {
            return viewModelPlaces.numberOfPlaces
        }
        return 0
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let colCell = collectionView.dequeueReusableCell(withReuseIdentifier: "PlacesCollectionCell", for: indexPath) as! PlacesCollectionCell
        
        if let viewModelPlace = viewModelPlaces.viewModel(for: indexPath.row) {
            colCell.setValueForColCell(place: viewModelPlace)
        }
        
        return colCell
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        delegate?.jumpToPlaceDetail(place: viewModelPlaces.places[indexPath.row])
    }
    
    @objc func btnSeeAllTapped(_ sender: UIButton) {
        Key.shared.mapHeadTitle = self.title
        delegate?.jumpToAllPlaces(places: viewModelPlaces)
    }
    
    /*
    fileprivate func loadCellContent() {
        imgPlaceIcon = UIImageView(frame: CGRect(x: 20, y: 20, width: 50, height: 50))
        addSubview(imgPlaceIcon)
        imgPlaceIcon.contentMode = .scaleAspectFill
        
        lblPlaceName = UILabel()
        addSubview(lblPlaceName)
        lblPlaceName.font = UIFont(name: "AvenirNext-Medium", size: 16)
        lblPlaceName.textColor = UIColor._898989()
        lblPlaceName.lineBreakMode = .byTruncatingTail
        addConstraintsWithFormat("H:|-93-[v0]-90-|", options: [], views: lblPlaceName)
        
        lblPlaceAddr = UILabel()
        addSubview(lblPlaceAddr)
        lblPlaceAddr.font = UIFont(name: "AvenirNext-Medium", size: 12)
        lblPlaceAddr.textColor = UIColor._182182182()
        lblPlaceAddr.lineBreakMode = .byTruncatingTail
        addConstraintsWithFormat("H:|-93-[v0]-90-|", options: [], views: lblPlaceAddr)
        addConstraintsWithFormat("V:|-26-[v0(22)]-1-[v1(16)]", options: [], views: lblPlaceName, lblPlaceAddr)
        
        lblDistance = UILabel()
        addSubview(lblDistance)
        lblDistance.font = UIFont(name: "AvenirNext-Medium", size: 16)
        lblDistance.textColor = UIColor._155155155()
        lblDistance.textAlignment = .right
        addConstraintsWithFormat("H:[v0(70)]-10-|", options: [], views: lblDistance)
        addConstraintsWithFormat("V:|-34-[v0(22)]", options: [], views: lblDistance)
    }
    
    func setValueForCell(place: MBPlacesStruct, curtLoc: CLLocation) {
        imgPlaceIcon.image = place.icon
        lblPlaceName.text = place.name
        lblPlaceAddr.text = place.address
        lblDistance.text = place.distance
    }
    */
}

class PlacesCollectionCell: UICollectionViewCell {
    
    var imgPic: UIImageView!
    var lblName: UILabel!
    var lblAddress: UILabel!
    var indicatorView: UIActivityIndicatorView!
    
    override init(frame : CGRect) {
        super.init(frame: frame)
        loadCellContent()
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
    
    fileprivate func loadCellContent() {
        imgPic = UIImageView(frame: CGRect(x: 0, y: 4, width: 120, height: 120))
        imgPic.clipsToBounds = true
        imgPic.layer.cornerRadius = 5
        //imgPic.layer.borderWidth = 1
        //imgPic.layer.borderColor = UIColor._200199204().cgColor
        addSubview(imgPic)
        
        lblName = UILabel(frame: CGRect(x: 0, y: 133, width: 120, height: 18))
        lblName.textColor = UIColor._898989()
        lblName.font = UIFont(name: "AvenirNext-DemiBold", size: 13)
        addSubview(lblName)
        
        lblAddress = UILabel(frame: CGRect(x: 0, y: 151, width: 120, height: 18))
        lblAddress.textColor = UIColor._115115115()
        lblAddress.font = UIFont(name: "AvenirNext-Medium", size: 13)
        addSubview(lblAddress)
        
        indicatorView = createActivityIndicator(large: true)
        indicatorView.center.x = 60
        indicatorView.center.y = 60
        addSubview(indicatorView)
    }
    
    func setValueForColCell(place: BoardPlaceViewModel) {
        imgPic.image = nil
        lblName.text = place.name
        lblAddress.text = place.address
//        lblName.text = place.name
//        var addr = place.address1 == "" ? "" : place.address1 + ", "
//        addr += place.address2
//        lblAddress.text = addr
        
        imgPic.backgroundColor = .white
        indicatorView.startAnimating()
        General.shared.downloadImageForView(url: place.imageURL, imgPic: imgPic) {
            self.indicatorView.stopAnimating()
        }
    }
}
