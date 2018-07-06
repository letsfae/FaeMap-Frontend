//
//  EXPPicCell.swift
//  faeBeta
//
//  Created by Yue Shen on 6/2/18.
//  Copyright © 2018 fae. All rights reserved.
//

import Foundation
import CHIPageControl

class EXPClctPicCell: UICollectionViewCell, UICollectionViewDelegate, UICollectionViewDataSource, UIScrollViewDelegate {
    
    weak var delegate: EXPCellDelegate?
    
    private var uiviewSub: UIView!
    private var uiviewBottom: UIView!
    private var lblPlaceName: FaeLabel!
    private var lblPlaceAddr: FaeLabel!
    
    private var clctViewImages: UICollectionView!
    
    private var intCurtPage = 0
    
    private var placeInfo: PlacePin!
    private var arrImgURL = [String]()
    private var pageCtrl: CHIPageControlChimayo!
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        loadCollectionView()
        loadCellBottom()
    }
    
    override func prepareForReuse() {
        super.prepareForReuse()
        pageCtrl.set(progress: 0, animated: false)
        clctViewImages.setContentOffset(.zero, animated: false)
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
    
    func updateCell(placeData: PlacePin) {
        placeInfo = placeData
        lblPlaceName.text = placeData.name
        if placeData.address1 != "" {
            var arrNames = placeData.address2.split(separator: ",")
            guard arrNames.count >= 1 else {
                lblPlaceAddr.text = placeData.address1
                return
            }
            let cityName = String(arrNames[0]).trimmingCharacters(in: CharacterSet.whitespaces)
            lblPlaceAddr.text = placeData.address1 + ", " + cityName
        } else {
            General.shared.updateAddress(label: lblPlaceAddr, place: placeData, full: false)
        }
        
        arrImgURL.removeAll(keepingCapacity: true)
        arrImgURL = Array(placeData.imageURLs.prefix(4))
        clctViewImages.reloadData()
        pageCtrl.numberOfPages = arrImgURL.count
    }
    
    func scrollViewDidEndDecelerating(_ scrollView: UIScrollView) {
        let pageHeight = clctViewImages.frame.size.height
        intCurtPage = Int(clctViewImages.contentOffset.y / pageHeight)
        pageCtrl.set(progress: intCurtPage, animated: true)
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return arrImgURL.count == 0 ? 1 : arrImgURL.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        if collectionView == clctViewImages {
            let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "exp_img", for: indexPath) as! EXPClctImgCell
            if arrImgURL.count == 0 {
                cell.updateImages(imgURL: "")
            } else {
                cell.updateImages(imgURL: arrImgURL[indexPath.row])
            }
            return cell
        } else {
            let cell = UICollectionViewCell()
            return cell
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        delegate?.jumpToPlaceDetail(placeInfo)
    }
    
    private func loadCollectionView() {
        uiviewSub = UIView()
        addSubview(uiviewSub)
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
    
    private func loadCellBottom() {
        uiviewBottom = UIView()
        uiviewBottom.backgroundColor = UIColor(r: 50, g: 50, b: 50, alpha: 80)
        uiviewSub.addSubview(uiviewBottom)
        uiviewSub.addConstraintsWithFormat("H:|-0-[v0]-0-|", options: [], views: uiviewBottom)
        uiviewSub.addConstraintsWithFormat("V:[v0(110)]-0-|", options: [], views: uiviewBottom)
        
        lblPlaceName = FaeLabel(CGRect.zero, .left, .demiBold, 20, .white)
        uiviewBottom.addSubview(lblPlaceName)
        uiviewBottom.addConstraintsWithFormat("H:|-22-[v0]-53-|", options: [], views: lblPlaceName)
        uiviewBottom.addConstraintsWithFormat("V:|-28-[v0(27)]", options: [], views: lblPlaceName)
        
        lblPlaceAddr = FaeLabel(CGRect.zero, .left, .demiBold, 16, .white)
        uiviewBottom.addSubview(lblPlaceAddr)
        uiviewBottom.addConstraintsWithFormat("H:|-22-[v0]-53-|", options: [], views: lblPlaceAddr)
        uiviewBottom.addConstraintsWithFormat("V:|-60-[v0(22)]", options: [], views: lblPlaceAddr)
        
        pageCtrl = CHIPageControlChimayo(frame: CGRect(x: 300, y: 45, width: 0, height: 25))
        pageCtrl.center.y = 55
        pageCtrl.radius = 4
        pageCtrl.tintColor = .white
        pageCtrl.currentPageTintColor = .white
        pageCtrl.padding = 6
        pageCtrl.hidesForSinglePage = true
        pageCtrl.isUserInteractionEnabled = false
        uiviewBottom.addSubview(pageCtrl)
        let angle = CGFloat(Double.pi/2)
        pageCtrl.transform = CGAffineTransform(rotationAngle: angle)
    }
}
