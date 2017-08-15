//
//  AllPlacesViewController.swift
//  faeBeta
//
//  Created by Faevorite 2 on 2017-08-11.
//  Copyright © 2017 fae. All rights reserved.
//

import UIKit

class AllPlacesViewController: UIViewController, UITableViewDelegate, UITableViewDataSource {
    var tblAllPlaces: UITableView!
    var strTitle: String! = ""
    var places = [MBPlacesStruct]()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .white
        loadNavBar()
        loadTable()
    }

    func loadNavBar() {
        let uiviewNavBar = FaeNavBar(frame: .zero)
        view.addSubview(uiviewNavBar)
        uiviewNavBar.rightBtn.setImage(#imageLiteral(resourceName: "mb_allPlaces"), for: .normal)
        uiviewNavBar.loadBtnConstraints()
        uiviewNavBar.lblTitle.text = strTitle
        uiviewNavBar.leftBtn.addTarget(self, action: #selector(self.actionGoBack(_:)), for: .touchUpInside)
        uiviewNavBar.rightBtn.addTarget(self, action: #selector(self.jumpToMapPlaces(_:)), for: .touchUpInside)
    }
    
    func loadTable() {
        tblAllPlaces = UITableView(frame: CGRect(x: 0, y: 65, width: screenWidth, height: screenHeight - 65))
        view.addSubview(tblAllPlaces)
        tblAllPlaces.delegate = self
        tblAllPlaces.dataSource = self
        tblAllPlaces.register(AllPlacesCell.self, forCellReuseIdentifier: "AllPlacesCell")
        tblAllPlaces.separatorStyle = .none
        tblAllPlaces.showsVerticalScrollIndicator = false
    }
    
    func actionGoBack(_ sender: UIButton) {
        navigationController?.popViewController(animated: true)
    }
    
    func jumpToMapPlaces(_ sender: UIButton) {
        
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 90
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return places.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "AllPlacesCell", for: indexPath) as! AllPlacesCell
        cell.setValueForCell(place: places[indexPath.row]) //, curtLoc: LocManager.shared.curtLoc)
        return cell
    }
}
