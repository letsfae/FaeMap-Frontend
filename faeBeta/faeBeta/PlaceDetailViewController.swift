//
//  PlaceDetailViewController.swift
//  faeBeta
//
//  Created by Faevorite 2 on 2017-08-14.
//  Copyright © 2017 fae. All rights reserved.
//

import UIKit

class PlaceDetailViewController: UIViewController {
    var place: PlacePin!
    var uiviewHeader: UIView!
    var uiviewSubHeader: UIView!
    var uiviewFooter: UIView!
    var btnBack: UIButton!
    var btnSave: UIButton!
    var btnRoute: UIButton!
    var btnShare: UIButton!
    var lblName: UILabel!
    var lblCategory: UILabel!
    var lblPrice: UILabel!
    var imgPic_0: UIImageView!
    var imgPic_1: UIImageView!
    var imgPic_2: UIImageView!
    var tblPlaceDetail: UITableView!
    let arrTitle = ["Similar Places", "Near this Place"]
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .white
        loadHeader()
        loadMidTable()
        loadFooter()
    }
    
    func loadHeader() {
        uiviewHeader = UIView(frame: CGRect(x: 0, y: 0, w: 414, h: 208))
//        uiviewHeader.layer.borderColor = UIColor.black.cgColor
//        uiviewHeader.layer.borderWidth = 1
//        view.addSubview(uiviewHeader)
        imgPic_0 = UIImageView(frame: CGRect(x: -414, y: 0, w: 414, h: 208))
        imgPic_1 = UIImageView(frame: CGRect(x: 0, y: 0, w: 414, h: 208))
        imgPic_2 = UIImageView(frame: CGRect(x: 414, y: 0, w: 414, h: 208))
        uiviewHeader.addSubview(imgPic_0)
        uiviewHeader.addSubview(imgPic_1)
        uiviewHeader.addSubview(imgPic_2)
        imgPic_0.backgroundColor = .red
        imgPic_1.backgroundColor = .yellow
        imgPic_2.backgroundColor = .green
        
        uiviewSubHeader = UIView(frame: CGRect(x: 0, y: 208, w: 414, h: 101))
        uiviewSubHeader.backgroundColor = .white
//        uiviewHeader.addSubview(uiviewSubHeader)
        
        lblName = UILabel(frame: CGRect(x: 20, y: 21 * screenHeightFactor, width: screenWidth - 40, height: 27))
        lblName.font = UIFont(name: "AvenirNext-Medium", size: 20)
        lblName.textColor = UIColor._898989()
        lblName.text = place.name
        
        lblCategory = UILabel(frame: CGRect(x: 20, y: 53 * screenHeightFactor, width: screenWidth - 90, height: 22))
        lblCategory.font = UIFont(name: "AvenirNext-Medium", size: 16)
        lblCategory.textColor = UIColor._146146146()
        lblCategory.text = place.class_1
        
        lblPrice = UILabel()
        lblPrice.font = UIFont(name: "AvenirNext-Medium", size: 16)
        lblPrice.textColor = UIColor._107105105()
        lblPrice.textAlignment = .right
        lblPrice.text = "$$$"
        
        uiviewSubHeader.addSubview(lblName)
        uiviewSubHeader.addSubview(lblCategory)
        uiviewSubHeader.addSubview(lblPrice)
        uiviewSubHeader.addConstraintsWithFormat("H:[v0(100)]-15-|", options: [], views: lblPrice)
        uiviewSubHeader.addConstraintsWithFormat("V:[v0(22)]-\(14 * screenHeightFactor)-|", options: [], views: lblPrice)
        
        let uiviewLine = UIView(frame: CGRect(x: 0, y: 96, w: 414, h: 5))
        uiviewLine.backgroundColor = UIColor._241241241()
        uiviewSubHeader.addSubview(uiviewLine)
    }
    
    func loadMidTable() {
        tblPlaceDetail = UITableView(frame: CGRect(x: 0, y: 0, width: screenWidth, height: screenHeight - 49))
//        tblPlaceDetail.contentInset = UIEdgeInsets(top: -22, left: 0, bottom: 0, right: 0)
        view.addSubview(tblPlaceDetail)
        tblPlaceDetail.tableHeaderView = uiviewHeader
        
        tblPlaceDetail.delegate = self
        tblPlaceDetail.dataSource = self
        tblPlaceDetail.register(PlaceDetailSection1Cell.self, forCellReuseIdentifier: "PlaceDetailSection1Cell")
        tblPlaceDetail.register(PlaceDetailSection2Cell.self, forCellReuseIdentifier: "PlaceDetailSection2Cell")
        tblPlaceDetail.register(PlaceDetailSection3Cell.self, forCellReuseIdentifier: "PlaceDetailSection3Cell")
        tblPlaceDetail.register(MBPlacesCell.self, forCellReuseIdentifier: "MBPlacesCell")
        tblPlaceDetail.separatorStyle = .none
        tblPlaceDetail.showsVerticalScrollIndicator = false
    }

    func loadFooter() {
        uiviewFooter = UIView(frame: CGRect(x: 0, y: screenHeight - 49, width: screenWidth, height: 49))
        view.addSubview(uiviewFooter)
        
        let line = UIView(frame: CGRect(x: 0, y: 0, width: screenWidth, height: 1))
        line.backgroundColor = UIColor._200199204()
        uiviewFooter.addSubview(line)
        
        btnBack = UIButton(frame: CGRect(x: 0, y: 1, width: 40.5, height: 48))
        btnBack.setImage(#imageLiteral(resourceName: "navigationBack"), for: .normal)
        btnBack.addTarget(self, action: #selector(backToMapBoard(_:)), for: .touchUpInside)
        
        btnSave = UIButton(frame: CGRect(x: screenWidth / 2 - 105, y: 2, width: 47, height: 47))
        btnSave.setImage(#imageLiteral(resourceName: "place_save"), for: .normal)
        btnSave.tag = 0
        btnBack.addTarget(self, action: #selector(tabButtonPressed(_:)), for: .touchUpInside)
        
        btnRoute = UIButton(frame: CGRect(x: (screenWidth - 47) / 2, y: 2, width: 47, height: 47))
        btnRoute.setImage(#imageLiteral(resourceName: "place_route"), for: .normal)
        btnRoute.tag = 1
        btnRoute.addTarget(self, action: #selector(tabButtonPressed(_:)), for: .touchUpInside)
        
        btnShare = UIButton(frame: CGRect(x: screenWidth / 2 + 58, y: 2, width: 47, height: 47))
        btnShare.setImage(#imageLiteral(resourceName: "place_share"), for: .normal)
        btnShare.tag = 2
        btnShare.addTarget(self, action: #selector(tabButtonPressed(_:)), for: .touchUpInside)
        
        uiviewFooter.addSubview(btnBack)
        uiviewFooter.addSubview(btnSave)
        uiviewFooter.addSubview(btnRoute)
        uiviewFooter.addSubview(btnShare)
    }
    
    func backToMapBoard(_ sender: UIButton) {
        navigationController?.popViewController(animated: true)
    }
    
    func tabButtonPressed(_ sender: UIButton) {
        
    }
}
