//
//  EXPPicCell.swift
//  faeBeta
//
//  Created by Yue Shen on 6/2/18.
//  Copyright © 2018 fae. All rights reserved.
//

import Foundation

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
    
    private var arrImgURL = [String]()
    
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
        arrImgURL = placeData.imageURLs
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
        //        uiviewSub.layer.borderWidth = 2
        //        uiviewSub.layer.borderColor = UIColor._200199204().cgColor
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
//        lblPlaceName.text = "Wing Stop"
        
        lblPlaceAddr = FaeLabel(CGRect.zero, .left, .demiBold, 16, .white)
        uiviewBottom.addSubview(lblPlaceAddr)
        uiviewBottom.addConstraintsWithFormat("H:|-22-[v0]-53-|", options: [], views: lblPlaceAddr)
        uiviewBottom.addConstraintsWithFormat("V:|-60-[v0(22)]", options: [], views: lblPlaceAddr)
//        lblPlaceAddr.text = "3260 Wilshire Blvd, Los Angeles"
    }
}
