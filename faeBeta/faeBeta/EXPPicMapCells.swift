//
//  EXPCells.swift
//  faeBeta
//
//  Created by Yue Shen on 9/12/17.
//  Copyright © 2017 fae. All rights reserved.
//

import UIKit
import CHIPageControl

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
    private var pageCtrl: CHIPageControlChimayo!
    
    private var clctViewImages: UICollectionView!
    private var intCurtPage = 0
    private var boolInMap = true
    private var placeInfo: PlacePin!
    private var arrImgURL = [String]()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        loadCollectionView()
        loadCellBottom()
        addShadow(view: self, opa: 0.5, offset: CGSize.zero, radius: 3)
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
        if arrImgURL.count == 0 {
            return 1
        } else if arrImgURL.count > 4 {
            return 4
        } else {
            return arrImgURL.count
        }
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
        uiviewSub.layer.cornerRadius = 5
        uiviewSub.clipsToBounds = true
        uiviewSub.backgroundColor = .clear
        addConstraintsWithFormat("H:|-17-[v0]-17-|", options: [], views: uiviewSub)
        addConstraintsWithFormat("V:|-17-[v0]-17-|", options: [], views: uiviewSub)
        
        let layout = UICollectionViewFlowLayout()
        layout.scrollDirection = .vertical
        layout.minimumInteritemSpacing = 0
        layout.minimumLineSpacing = 0
        layout.itemSize = CGSize(width: 218, height: 276)
        
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
    
    private func loadCellBottom() {
        uiviewBottom = UIView()
        uiviewBottom.backgroundColor = UIColor(r: 50, g: 50, b: 50, alpha: 80)
        uiviewSub.addSubview(uiviewBottom)
        uiviewSub.addConstraintsWithFormat("H:|-0-[v0]-0-|", options: [], views: uiviewBottom)
        uiviewSub.addConstraintsWithFormat("V:[v0(66)]-0-|", options: [], views: uiviewBottom)
        
        lblPlaceName = FaeLabel(CGRect.zero, .left, .demiBold, 12, .white)
        uiviewBottom.addSubview(lblPlaceName)
        uiviewBottom.addConstraintsWithFormat("H:|-12-[v0]-30-|", options: [], views: lblPlaceName)
        uiviewBottom.addConstraintsWithFormat("V:|-17-[v0(16)]", options: [], views: lblPlaceName)
        
        lblPlaceAddr = FaeLabel(CGRect.zero, .left, .demiBold, 9.6, .white)
        uiviewBottom.addSubview(lblPlaceAddr)
        uiviewBottom.addConstraintsWithFormat("H:|-12-[v0]-30-|", options: [], views: lblPlaceAddr)
        uiviewBottom.addConstraintsWithFormat("V:|-36-[v0(14)]", options: [], views: lblPlaceAddr)
        
        pageCtrl = CHIPageControlChimayo(frame: CGRect(x: 200, y: 30, width: 0, height: 25))
        pageCtrl.center.y = 33
        pageCtrl.radius = 2.4
        pageCtrl.tintColor = .white
        pageCtrl.currentPageTintColor = .white
        pageCtrl.padding = 3
        pageCtrl.hidesForSinglePage = true
        pageCtrl.isUserInteractionEnabled = false
        uiviewBottom.addSubview(pageCtrl)
        let angle = CGFloat(Double.pi/2)
        pageCtrl.transform = CGAffineTransform(rotationAngle: angle)
    }
}

class EXPClctImgCell: UICollectionViewCell {
    
    private var imgPic: UIImageView!
    private var activityIndicator: UIActivityIndicatorView!
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        backgroundColor = .clear
        loadCellItems()
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
    
    override func prepareForReuse() {
        super.prepareForReuse()
        imgPic.image = nil
    }
    
    private func loadCellItems() {
        imgPic = UIImageView()
        imgPic.contentMode = .scaleAspectFill
        imgPic.layer.cornerRadius = 5
        imgPic.clipsToBounds = true
        //        img.image = #imageLiteral(resourceName: "exp_pic_demo")
        addSubview(imgPic)
        addConstraintsWithFormat("H:|-0-[v0]-0-|", options: [], views: imgPic)
        addConstraintsWithFormat("V:|-0-[v0]-0-|", options: [], views: imgPic)
        
        activityIndicator = createActivityIndicator(large: true)
        addSubview(activityIndicator)
        addConstraintsWithFormat("H:|-0-[v0]-0-|", options: [], views: activityIndicator)
        addConstraintsWithFormat("V:|-0-[v0]-0-|", options: [], views: activityIndicator)
    }
    
    func updateImages(imgURL: String) {
        guard imgURL != "" else {
            imgPic.image = #imageLiteral(resourceName: "default_place")
            return
        }
        imgPic.backgroundColor = ._210210210()
        imgPic.image = nil
        imgPic.sd_setShowActivityIndicatorView(true)
        imgPic.sd_setImage(with: URL(string: imgURL), placeholderImage: nil, options: []) { [weak self] (img, err, cacheType, _) in
            if img == nil || err != nil {
                self?.imgPic.image = Key.shared.defaultPlace
            }
            self?.imgPic.sd_setShowActivityIndicatorView(false)
        }
    }
}
