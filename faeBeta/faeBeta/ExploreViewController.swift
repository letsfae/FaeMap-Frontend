//
//  ExploreViewController.swift
//  faeBeta
//
//  Created by Yue Shen on 9/12/17.
//  Copyright © 2017 fae. All rights reserved.
//

import UIKit

class ExploreViewController: UIViewController, UICollectionViewDelegate, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout {
    
    var uiviewNavBar: FaeNavBar!
    var clctViewTypes: UICollectionView!
    var clctViewPics: UICollectionView!
    var lblBottomLocation: UILabel!
    var btnGoLeft: UIButton!
    var btnGoRight: UIButton!
    var btnSave: UIButton!
    var btnRefresh: UIButton!
    var btnMap: UIButton!
    
    var intCurtPage = 0
    
    var testTypes = ["Random", "Food", "Drink", "Shopping", "Outdoors", "Cinema", "Pharmacy", "Supermarket", "Fitness", "KTV", "Spa", "School", "Track&Field", "Sushi Bar"]
    
    override func viewDidLoad() {
        super.viewDidLoad()
        loadContent()
    }
    
    func loadContent() {
        view.backgroundColor = .white
        loadNavBar()
        loadTopTypesCollection()
        loadPicCollections()
        loadButtons()
        loadBottomLocation()
    }
    
    func actionSwitchPage(_ sender: UIButton) {
        var numPage = intCurtPage
        if sender == btnGoLeft {
            numPage -= 1
        } else {
            numPage += 1
        }
        guard numPage >= 0 && numPage < 10 else { return }
        clctViewPics.setContentOffset(CGPoint(x: screenWidth * CGFloat(numPage), y: 0), animated: true)
        intCurtPage = numPage
    }
    
    func actionBack(_ sender: UIButton) {
        navigationController?.popViewController(animated: true)
    }
    
    func scrollViewDidEndDecelerating(_ scrollView: UIScrollView) {
        let pageWidth = clctViewPics.frame.size.width
        intCurtPage = Int(clctViewPics.contentOffset.x / pageWidth)
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        if collectionView == clctViewTypes {
            let label = UILabel()
            label.font = FaeFont(fontType: .medium, size: 15)
            label.text = testTypes[indexPath.row]
            let width = label.intrinsicContentSize.width
            return CGSize(width: width + 3.0, height: 36)
        }
        return CGSize(width: screenWidth, height: screenHeight - 116 - 156)
    }
    
    func loadTopTypesCollection() {
        let layout = UICollectionViewFlowLayout()
        layout.scrollDirection = .horizontal
        layout.minimumInteritemSpacing = 0
        layout.minimumLineSpacing = 20
        layout.estimatedItemSize = CGSize(width: 80, height: 36)
        
        clctViewTypes = UICollectionView(frame: CGRect.zero, collectionViewLayout: layout)
        clctViewTypes.register(EXPClctTypeCell.self, forCellWithReuseIdentifier: "exp_types")
        clctViewTypes.delegate = self
        clctViewTypes.dataSource = self
        clctViewTypes.isPagingEnabled = false
        clctViewTypes.backgroundColor = UIColor.clear
        clctViewTypes.showsHorizontalScrollIndicator = false
        clctViewTypes.contentInset = UIEdgeInsets(top: 0, left: 20, bottom: 0, right: 20)
        view.addSubview(clctViewTypes)
        view.addConstraintsWithFormat("H:|-0-[v0]-0-|", options: [], views: clctViewTypes)
        view.addConstraintsWithFormat("V:|-73-[v0(36)]", options: [], views: clctViewTypes)
    }
    
    func loadPicCollections() {
        let layout = UICollectionViewFlowLayout()
        layout.itemSize = CGSize(width: screenWidth, height: screenHeight - 116 - 156)
        layout.scrollDirection = .horizontal
        layout.minimumInteritemSpacing = 0
        layout.minimumLineSpacing = 0
        
        clctViewPics = UICollectionView(frame: CGRect.zero, collectionViewLayout: layout)
        clctViewPics.register(EXPClctPicCell.self, forCellWithReuseIdentifier: "exp_pics")
        clctViewPics.delegate = self
        clctViewPics.dataSource = self
        clctViewPics.isPagingEnabled = true
        clctViewPics.backgroundColor = UIColor.clear
        clctViewPics.showsHorizontalScrollIndicator = false
        view.addSubview(clctViewPics)
        view.addConstraintsWithFormat("H:|-0-[v0]-0-|", options: [], views: clctViewPics)
        view.addConstraintsWithFormat("V:|-116-[v0]-156-|", options: [], views: clctViewPics)
    }
    
    func loadButtons() {
        let uiviewBtnSub = UIView(frame: CGRect(x: (screenWidth - 370) / 2, y: screenHeight - 138, width: 370, height: 78))
        view.addSubview(uiviewBtnSub)
        
        btnGoLeft = UIButton()
        btnGoLeft.setImage(#imageLiteral(resourceName: "exp_go_left"), for: .normal)
        btnGoLeft.addTarget(self, action: #selector(actionSwitchPage(_:)), for: .touchUpInside)
        uiviewBtnSub.addSubview(btnGoLeft)
        uiviewBtnSub.addConstraintsWithFormat("H:|-0-[v0(78)]", options: [], views: btnGoLeft)
        uiviewBtnSub.addConstraintsWithFormat("V:|-0-[v0(78)]", options: [], views: btnGoLeft)
        
        btnSave = UIButton()
        btnSave.setImage(#imageLiteral(resourceName: "exp_save"), for: .normal)
        uiviewBtnSub.addSubview(btnSave)
        uiviewBtnSub.addConstraintsWithFormat("H:|-82-[v0(66)]", options: [], views: btnSave)
        uiviewBtnSub.addConstraintsWithFormat("V:|-6-[v0(66)]", options: [], views: btnSave)
        
        btnRefresh = UIButton()
        btnRefresh.setImage(#imageLiteral(resourceName: "exp_refresh"), for: .normal)
        uiviewBtnSub.addSubview(btnRefresh)
        uiviewBtnSub.addConstraintsWithFormat("H:|-152-[v0(66)]", options: [], views: btnRefresh)
        uiviewBtnSub.addConstraintsWithFormat("V:|-6-[v0(66)]", options: [], views: btnRefresh)
        
        btnMap = UIButton()
        btnMap.setImage(#imageLiteral(resourceName: "exp_map"), for: .normal)
        uiviewBtnSub.addSubview(btnMap)
        uiviewBtnSub.addConstraintsWithFormat("H:[v0(66)]-82-|", options: [], views: btnMap)
        uiviewBtnSub.addConstraintsWithFormat("V:|-6-[v0(66)]", options: [], views: btnMap)
        
        btnGoRight = UIButton()
        btnGoRight.setImage(#imageLiteral(resourceName: "exp_go_right"), for: .normal)
        btnGoRight.addTarget(self, action: #selector(actionSwitchPage(_:)), for: .touchUpInside)
        uiviewBtnSub.addSubview(btnGoRight)
        uiviewBtnSub.addConstraintsWithFormat("H:[v0(78)]-0-|", options: [], views: btnGoRight)
        uiviewBtnSub.addConstraintsWithFormat("V:|-0-[v0(78)]", options: [], views: btnGoRight)
    }
    
    func loadBottomLocation() {
        lblBottomLocation = UILabel()
        lblBottomLocation.numberOfLines = 1
        lblBottomLocation.textAlignment = .center
        view.addSubview(lblBottomLocation)
        view.addConstraintsWithFormat("H:|-0-[v0]-0-|", options: [], views: lblBottomLocation)
        view.addConstraintsWithFormat("V:[v0(25)]-19-|", options: [], views: lblBottomLocation)
        reloadBottomText("Los Angeles", "CA, United States")
    }
    
    func reloadBottomText(_ city: String, _ state: String) {
        let fullAttrStr = NSMutableAttributedString()
        
        let firstImg = #imageLiteral(resourceName: "mapSearchCurrentLocation")
        let first_attch = InlineTextAttachment()
        first_attch.fontDescender = -2
        first_attch.image = UIImage(cgImage: (firstImg.cgImage)!, scale: 3, orientation: .up)
        let firstImg_attach = NSAttributedString(attachment: first_attch)
        
        let secondImg = #imageLiteral(resourceName: "exp_bottom_loc_arrow")
        let second_attch = InlineTextAttachment()
        second_attch.fontDescender = -1
        second_attch.image = UIImage(cgImage: (secondImg.cgImage)!, scale: 3, orientation: .up)
        let secondImg_attach = NSAttributedString(attachment: second_attch)
        let attrs_0 = [NSForegroundColorAttributeName: UIColor._898989(), NSFontAttributeName: UIFont(name: "AvenirNext-Medium", size: 16)!]
//        let attrs_0 = [NSAttributedStringKey.font: UIFont(name: "AvenirNext-Medium", size: 16)!, NSAttributedStringKey.foregroundColor: UIColor._898989()]
        let title_0_attr = NSMutableAttributedString(string: "  " + city + " ", attributes: attrs_0)
        
        let attrs_1 = [NSForegroundColorAttributeName: UIColor._138138138(), NSFontAttributeName: UIFont(name: "AvenirNext-Medium", size: 13)!]
//        let attrs_1 = [NSAttributedStringKey.font: UIFont(name: "AvenirNext-Medium", size: 13)!, NSAttributedStringKey.foregroundColor: UIColor._138138138()]
        let title_1_attr = NSMutableAttributedString(string: state + "  ", attributes: attrs_1)
        
        fullAttrStr.append(firstImg_attach)
        fullAttrStr.append(title_0_attr)
        fullAttrStr.append(title_1_attr)
        fullAttrStr.append(secondImg_attach)
        
        lblBottomLocation.attributedText = fullAttrStr
    }
    
    
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        if collectionView == clctViewPics {
            return 10
        } else if collectionView == clctViewTypes {
            return testTypes.count
        }
        return 10
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        if collectionView == clctViewPics {
            let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "exp_pics", for: indexPath) as! EXPClctPicCell
            return cell
        } else if collectionView == clctViewTypes {
            let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "exp_types", for: indexPath) as! EXPClctTypeCell
            cell.updateTitle(type: testTypes[indexPath.row])
            return cell
        } else {
            let cell = UICollectionViewCell()
            return cell
        }
    }
    
    func loadNavBar() {
        uiviewNavBar = FaeNavBar()
        view.addSubview(uiviewNavBar)
        uiviewNavBar.rightBtn.isHidden = true
        uiviewNavBar.loadBtnConstraints()
        
        let title_0 = "Explore "
        let title_1 = "Around Me"
        let attrs_0 = [NSForegroundColorAttributeName: UIColor._898989(), NSFontAttributeName: UIFont(name: "AvenirNext-Medium", size: 20)!]
        let attrs_1 = [NSForegroundColorAttributeName: UIColor._2499090(), NSFontAttributeName: UIFont(name: "AvenirNext-Medium", size: 20)!]
        let title_0_attr = NSMutableAttributedString(string: title_0, attributes: attrs_0)
        let title_1_attr = NSMutableAttributedString(string: title_1, attributes: attrs_1)
        title_0_attr.append(title_1_attr)
        
        uiviewNavBar.lblTitle.attributedText = title_0_attr

        uiviewNavBar.leftBtn.addTarget(self, action: #selector(actionBack(_:)), for: .touchUpInside)
    }
    
    
}

protocol EXPCellDelegate: class {
    
}

class EXPClctPicCell: UICollectionViewCell, UICollectionViewDelegate, UICollectionViewDataSource, UIScrollViewDelegate {
    
    weak var delegate: EXPCellDelegate?
    
    var uiviewSub: UIView!
    var uiviewBottom: UIView!
    var lblPlaceName: FaeLabel!
    var lblPlaceAddr: FaeLabel!
    
    var clctViewImages: UICollectionView!
    
    var uiviewPageCtrlSub: UIView!
    var arrPageDot = [UIView]()
    
    var intCurtPage = 0
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        loadCollectionView()
        loadCellItems()
        loadPageCtrl()
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func scrollViewDidEndDecelerating(_ scrollView: UIScrollView) {
        let pageHeight = clctViewImages.frame.size.height
        intCurtPage = Int(clctViewImages.contentOffset.y / pageHeight)
        
        guard arrPageDot.count > 0 else { return }
        
        for i in 0..<arrPageDot.count {
            arrPageDot[i].backgroundColor = intCurtPage == i ? .white : .clear
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return 4
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        if collectionView == clctViewImages {
            let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "exp_img", for: indexPath) as! EXPClctImgCell
            return cell
        } else {
            let cell = UICollectionViewCell()
            return cell
        }
    }
    
    func loadPageCtrl() {
        
        for uiview in arrPageDot {
            uiview.removeFromSuperview()
        }
        arrPageDot.removeAll()
        
        uiviewPageCtrlSub = UIView(frame: CGRect(x: screenWidth - 26 - 30.5, y: screenHeight - 116 - 156 - 28.5 - 53, width: 8, height: 53))
        addSubview(uiviewPageCtrlSub)
        
        for i in 0...3 {
            let uiviewDot = UIView(frame: CGRect(x: 0, y: 15 * i, width: 8, height: 8))
            uiviewDot.layer.borderColor = UIColor.white.cgColor
            uiviewDot.layer.borderWidth = 1
            uiviewDot.layer.cornerRadius = 4
            uiviewPageCtrlSub.addSubview(uiviewDot)
            arrPageDot.append(uiviewDot)
            if i == intCurtPage {
                uiviewDot.backgroundColor = .white
            }
        }
    }
    
    func loadCollectionView() {
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
        layout.itemSize = CGSize(width: screenWidth - 52, height: screenHeight - 116 - 156)
        
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
    
    func loadCellItems() {
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
    
    var img: UIImageView!
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        loadCellItems()
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func loadCellItems() {
        img = UIImageView()
        img.contentMode = .scaleAspectFill
        img.image = #imageLiteral(resourceName: "exp_pic_demo")
        addSubview(img)
        addConstraintsWithFormat("H:|-0-[v0]-0-|", options: [], views: img)
        addConstraintsWithFormat("V:|-0-[v0]-0-|", options: [], views: img)
    }
}

class EXPClctTypeCell: UICollectionViewCell {
    weak var delegate: EXPCellDelegate?
    
    var btnType: UIButton!
    
    internal var widthContraint = [NSLayoutConstraint]() {
        didSet {
            if oldValue.count != 0 {
                removeConstraints(oldValue)
            }
            if widthContraint.count != 0 {
                addConstraints(widthContraint)
            }
        }
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        loadCellItems()
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func loadCellItems() {
        btnType = UIButton()
        btnType.setTitle("", for: .normal)
        btnType.setTitleColor(UIColor(r: 102, g: 192, b: 251, alpha: 100), for: .normal)
        btnType.setTitleColor(.lightGray, for: .highlighted)
        btnType.titleLabel?.font = FaeFont(fontType: .medium, size: 15)
        btnType.titleLabel?.textAlignment = .center
        addSubview(btnType)
        widthContraint = returnConstraintsWithFormat("H:|-0-[v0(50)]", options: [], views: btnType)
        addConstraintsWithFormat("V:[v0(36)]-0-|", options: [], views: btnType)
    }
    
    func updateTitle(type: String) {
        btnType.setTitle(type, for: .normal)
        guard let lblWidth = btnType.titleLabel?.intrinsicContentSize.width else { return }
        widthContraint = returnConstraintsWithFormat("H:|-0-[v0(\(Int(lblWidth) + 3))]", options: [], views: btnType)
    }
}
