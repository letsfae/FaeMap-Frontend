//
//  EXPCells.swift
//  faeBeta
//
//  Created by Yue Shen on 9/12/17.
//  Copyright © 2017 fae. All rights reserved.
//

import UIKit

protocol EXPCellDelegate: class {
    func jumpToPlaceDetail(_ placeInfo: PlacePin)
}

class EXPClctPicMapCell: UICollectionViewCell, UICollectionViewDelegate, UICollectionViewDataSource, UIScrollViewDelegate {
    
    // MARK: - Vars
    
    weak var delegate: EXPCellDelegate?
    
    private var uiviewSub: UIView!
    private var uiviewBottom: UIView!
    private var lblPlaceName: FaeLabel!
    private var lblPlaceAddr: FaeLabel!
    
    private var clctViewImages: UICollectionView!
    
    private var uiviewPageCtrlSub: UIView!
    private var arrPageDot = [UIButton]()
    
    private var intCurtPage = 0
    
    private var boolInMap = true
    
    private var placeInfo: PlacePin!
    
    private var arrImgURL = [String]() {
        didSet {
            
        }
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        loadCollectionView()
        loadCellItems()
//        loadPageCtrl()
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func updateCell(placeData: PlacePin) {
        placeInfo = placeData
        lblPlaceName.text = placeData.name
        var arrNames = placeData.address2.split(separator: ",")
        guard arrNames.count >= 1 else {
            lblPlaceAddr.text = placeData.address1
            return
        }
        let cityName = String(arrNames[0]).trimmingCharacters(in: CharacterSet.whitespaces)
        lblPlaceName.text = placeData.name
        lblPlaceAddr.text = placeData.address1 + ", " + cityName
        arrImgURL.removeAll(keepingCapacity: true)
        arrImgURL.append(placeData.imageURL)
        clctViewImages.reloadData()
    }
    
    func scrollViewDidEndDecelerating(_ scrollView: UIScrollView) {
        let pageHeight = clctViewImages.frame.size.height
        intCurtPage = Int(clctViewImages.contentOffset.y / pageHeight)
        
        guard arrPageDot.count > 0 else { return }
        
        for i in 0..<arrPageDot.count {
            arrPageDot[i].isSelected = intCurtPage == i
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return arrImgURL.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        if collectionView == clctViewImages {
            let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "exp_img", for: indexPath) as! EXPClctImgCell
            cell.updateImages(placeInfo: placeInfo, imgURL: arrImgURL[indexPath.row])
            return cell
        } else {
            let cell = UICollectionViewCell()
            return cell
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        delegate?.jumpToPlaceDetail(placeInfo)
    }
    
    private func loadPageCtrl() {
        
        for uiview in arrPageDot {
            uiview.removeFromSuperview()
        }
        arrPageDot.removeAll()
        
        uiviewPageCtrlSub = UIView(frame: CGRect(x: 249 - 17 - 18, y: 310 - 17 - 17 - 32, width: 5, height: 32))
        addSubview(uiviewPageCtrlSub)
        
        for i in 0...3 {
            let imgDot = UIButton(frame: CGRect(x: 0, y: 9 * i, width: 5, height: 5))
            imgDot.setImage(#imageLiteral(resourceName: "exp_page_ctrl_hollow"), for: .normal)
            imgDot.setImage(#imageLiteral(resourceName: "exp_page_ctrl_full"), for: .selected)
            imgDot.adjustsImageWhenHighlighted = false
            imgDot.isUserInteractionEnabled = false
            uiviewPageCtrlSub.addSubview(imgDot)
            arrPageDot.append(imgDot)
            if i == intCurtPage {
                imgDot.isSelected = true
            }
        }
    }
    
    private func loadCollectionView() {
        
        let imgBack = UIImageView()
        imgBack.contentMode = .scaleAspectFit
        imgBack.image = #imageLiteral(resourceName: "exp_map_clct_shadow")
        addSubview(imgBack)
        addConstraintsWithFormat("H:|-0-[v0]-0-|", options: [], views: imgBack)
        addConstraintsWithFormat("V:|-0-[v0]-0-|", options: [], views: imgBack)
        
        uiviewSub = UIView()
        addSubview(uiviewSub)
        uiviewSub.layer.cornerRadius = 5
        uiviewSub.clipsToBounds = true
        uiviewSub.backgroundColor = .clear
        addConstraintsWithFormat("H:|-17-[v0]-17-|", options: [], views: uiviewSub)
        addConstraintsWithFormat("V:|-17-[v0]-17-|", options: [], views: uiviewSub)
        
        let layout = UICollectionViewFlowLayout()
        layout.scrollDirection = .vertical
        layout.minimumInteritemSpacing = 0
        layout.minimumLineSpacing = 0
        layout.itemSize = CGSize(width: 218, height: 279)
        
        clctViewImages = UICollectionView(frame: CGRect.zero, collectionViewLayout: layout)
        clctViewImages.register(EXPClctImgCell.self, forCellWithReuseIdentifier: "exp_img")
        clctViewImages.delegate = self
        clctViewImages.dataSource = self
        clctViewImages.isPagingEnabled = true
        clctViewImages.backgroundColor = UIColor.clear
        clctViewImages.showsVerticalScrollIndicator = false
        clctViewImages.backgroundColor = .clear
        clctViewImages.alwaysBounceVertical = false
        uiviewSub.addSubview(clctViewImages)
        uiviewSub.addConstraintsWithFormat("H:|-0-[v0]-0-|", options: [], views: clctViewImages)
        uiviewSub.addConstraintsWithFormat("V:|-0-[v0]-0-|", options: [], views: clctViewImages)
    }
    
    private func loadCellItems() {
        uiviewBottom = UIView()
        uiviewBottom.backgroundColor = UIColor(r: 50, g: 50, b: 50, alpha: 80)
        uiviewSub.addSubview(uiviewBottom)
        uiviewSub.addConstraintsWithFormat("H:|-0-[v0]-0-|", options: [], views: uiviewBottom)
        uiviewSub.addConstraintsWithFormat("V:[v0(66)]-0-|", options: [], views: uiviewBottom)
        
        lblPlaceName = FaeLabel(CGRect.zero, .left, .demiBold, 12, .white)
        uiviewBottom.addSubview(lblPlaceName)
        uiviewBottom.addConstraintsWithFormat("H:|-12-[v0]-30-|", options: [], views: lblPlaceName)
        uiviewBottom.addConstraintsWithFormat("V:|-17-[v0(16)]", options: [], views: lblPlaceName)
        lblPlaceName.text = "Wing Stop"
        
        lblPlaceAddr = FaeLabel(CGRect.zero, .left, .demiBold, 9.6, .white)
        uiviewBottom.addSubview(lblPlaceAddr)
        uiviewBottom.addConstraintsWithFormat("H:|-12-[v0]-30-|", options: [], views: lblPlaceAddr)
        uiviewBottom.addConstraintsWithFormat("V:|-36-[v0(14)]", options: [], views: lblPlaceAddr)
        lblPlaceAddr.text = "3260 Wilshire Blvd, Los Angeles"
    }
}

class EXPClctPicCell: UICollectionViewCell, UICollectionViewDelegate, UICollectionViewDataSource, UIScrollViewDelegate {
    
    weak var delegate: EXPCellDelegate?
    
    private var uiviewSub: UIView!
    private var uiviewBottom: UIView!
    private var lblPlaceName: FaeLabel!
    private var lblPlaceAddr: FaeLabel!
    
    private var clctViewImages: UICollectionView!
    
    private var uiviewPageCtrlSub: UIView!
    private var arrPageDot = [UIButton]()
    
    private var intCurtPage = 0
    
    private var placeInfo: PlacePin!
    
    private var arrImgURL = [String]() {
        didSet {
            
        }
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        loadCollectionView()
        loadCellItems()
//        loadPageCtrl()
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func updateCell(placeData: PlacePin) {
        placeInfo = placeData
        lblPlaceName.text = placeData.name
        var arrNames = placeData.address2.split(separator: ",")
        guard arrNames.count >= 1 else {
            lblPlaceAddr.text = placeData.address1
            return
        }
        let cityName = String(arrNames[0]).trimmingCharacters(in: CharacterSet.whitespaces)
        lblPlaceName.text = placeData.name
        lblPlaceAddr.text = placeData.address1 + ", " + cityName
        arrImgURL.removeAll(keepingCapacity: true)
        arrImgURL.append(placeData.imageURL)
        clctViewImages.reloadData()
    }
    
    func scrollViewDidEndDecelerating(_ scrollView: UIScrollView) {
        let pageHeight = clctViewImages.frame.size.height
        intCurtPage = Int(clctViewImages.contentOffset.y / pageHeight)
        
        guard arrPageDot.count > 0 else { return }
        
        for i in 0..<arrPageDot.count {
            arrPageDot[i].isSelected = intCurtPage == i
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return arrImgURL.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        if collectionView == clctViewImages {
            let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "exp_img", for: indexPath) as! EXPClctImgCell
            cell.updateImages(placeInfo: placeInfo, imgURL: arrImgURL[indexPath.row])
            return cell
        } else {
            let cell = UICollectionViewCell()
            return cell
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        delegate?.jumpToPlaceDetail(placeInfo)
    }
    
    private func loadPageCtrl() {
        
        for uiview in arrPageDot {
            uiview.removeFromSuperview()
        }
        arrPageDot.removeAll()
        
        uiviewPageCtrlSub = UIView(frame: CGRect(x: screenWidth - 26 - 30.5, y: screenHeight - 116 - 156 - 28.5 - 53, width: 8, height: 53))
        addSubview(uiviewPageCtrlSub)
        
        for i in 0...3 {
            let imgDot = UIButton(frame: CGRect(x: 0, y: 15 * i, width: 8, height: 8))
            imgDot.setImage(#imageLiteral(resourceName: "exp_page_ctrl_hollow"), for: .normal)
            imgDot.setImage(#imageLiteral(resourceName: "exp_page_ctrl_full"), for: .selected)
            imgDot.adjustsImageWhenHighlighted = false
            imgDot.isUserInteractionEnabled = false
            uiviewPageCtrlSub.addSubview(imgDot)
            arrPageDot.append(imgDot)
            if i == intCurtPage {
                imgDot.isSelected = true
            }
        }
    }
    
    private func loadCollectionView() {
        uiviewSub = UIView()
        addSubview(uiviewSub)
        uiviewSub.layer.borderWidth = 2
        uiviewSub.layer.borderColor = UIColor._200199204().cgColor
        uiviewSub.layer.cornerRadius = 8
        uiviewSub.clipsToBounds = true
        addConstraintsWithFormat("H:|-26-[v0]-26-|", options: [], views: uiviewSub)
        addConstraintsWithFormat("V:|-0-[v0]-0-|", options: [], views: uiviewSub)
        
        let layout = UICollectionViewFlowLayout()
        layout.scrollDirection = .vertical
        layout.minimumInteritemSpacing = 0
        layout.minimumLineSpacing = 0
        layout.itemSize = CGSize(width: screenWidth - 52, height: screenHeight - 116 - 156 - device_offset_bot - device_offset_top)
        
        clctViewImages = UICollectionView(frame: CGRect.zero, collectionViewLayout: layout)
        clctViewImages.register(EXPClctImgCell.self, forCellWithReuseIdentifier: "exp_img")
        clctViewImages.delegate = self
        clctViewImages.dataSource = self
        clctViewImages.isPagingEnabled = true
        clctViewImages.backgroundColor = UIColor.clear
        clctViewImages.showsVerticalScrollIndicator = false
        uiviewSub.addSubview(clctViewImages)
        uiviewSub.addConstraintsWithFormat("H:|-0-[v0]-0-|", options: [], views: clctViewImages)
        uiviewSub.addConstraintsWithFormat("V:|-0-[v0]-0-|", options: [], views: clctViewImages)
    }
    
    private func loadCellItems() {
        uiviewBottom = UIView()
        uiviewBottom.backgroundColor = UIColor(r: 50, g: 50, b: 50, alpha: 80)
        uiviewSub.addSubview(uiviewBottom)
        uiviewSub.addConstraintsWithFormat("H:|-0-[v0]-0-|", options: [], views: uiviewBottom)
        uiviewSub.addConstraintsWithFormat("V:[v0(110)]-0-|", options: [], views: uiviewBottom)
        
        lblPlaceName = FaeLabel(CGRect.zero, .left, .demiBold, 20, .white)
        uiviewBottom.addSubview(lblPlaceName)
        uiviewBottom.addConstraintsWithFormat("H:|-22-[v0]-53-|", options: [], views: lblPlaceName)
        uiviewBottom.addConstraintsWithFormat("V:|-28-[v0(27)]", options: [], views: lblPlaceName)
        lblPlaceName.text = "Wing Stop"
        
        lblPlaceAddr = FaeLabel(CGRect.zero, .left, .demiBold, 16, .white)
        uiviewBottom.addSubview(lblPlaceAddr)
        uiviewBottom.addConstraintsWithFormat("H:|-22-[v0]-53-|", options: [], views: lblPlaceAddr)
        uiviewBottom.addConstraintsWithFormat("V:|-60-[v0(22)]", options: [], views: lblPlaceAddr)
        lblPlaceAddr.text = "3260 Wilshire Blvd, Los Angeles"
    }
}

class EXPClctImgCell: UICollectionViewCell {
    
    private var img: UIImageView!
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        backgroundColor = .clear
        loadCellItems()
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func loadCellItems() {
        img = UIImageView()
        img.contentMode = .scaleAspectFill
//        img.image = #imageLiteral(resourceName: "exp_pic_demo")
        addSubview(img)
        addConstraintsWithFormat("H:|-0-[v0]-0-|", options: [], views: img)
        addConstraintsWithFormat("V:|-0-[v0]-0-|", options: [], views: img)
    }
    
    func updateImages(placeInfo: PlacePin, imgURL: String) {
        General.shared.downloadImageForView(url: imgURL, imgPic: img)
    }
}

//protocol ExploreCategorySearch: class {
    //func search(category: String, indexPath: IndexPath)
//}


