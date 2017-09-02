//
//  AddPlaceToCollectionView.swift
//  faeBeta
//
//  Created by Faevorite 2 on 2017-08-16.
//  Copyright © 2017 fae. All rights reserved.
//

import UIKit

class AfterAddedToListView: UIView {
    
    var uiviewAfterAdded: UIView!
    
    override init(frame: CGRect = .zero) {
        super.init(frame: CGRect(x: 0, y: screenHeight, width: screenWidth, height: 60))
        loadContent()
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    fileprivate func loadContent() {
        
        layer.zPosition = 1002
        
        let blurEffect = UIBlurEffect(style: UIBlurEffectStyle.dark)
        let blurEffectView = UIVisualEffectView(effect: blurEffect)
        blurEffectView.frame = self.bounds
        addSubview(blurEffectView)
        
        let lblCollected = FaeLabel(CGRect(x: 20, y: 19, width: 150, height: 25), .left, .medium, 18, .white)
        lblCollected.text = "Collocted to List!"
        addSubview(lblCollected)
        
        let btnUndo = UIButton()
        btnUndo.setTitle("Undo", for: .normal)
        btnUndo.setTitleColor(.white, for: .normal)
        btnUndo.setTitleColor(.lightGray, for: .highlighted)
        btnUndo.titleLabel?.font = FaeFont(fontType: .demiBold, size: 18)
        addSubview(btnUndo)
        addConstraintsWithFormat("H:[v0(46)]-109-|", options: [], views: btnUndo)
        addConstraintsWithFormat("V:|-19-[v0(25)]", options: [], views: btnUndo)
        
        let btnSeeList = UIButton()
        btnSeeList.setTitle("See List", for: .normal)
        btnSeeList.setTitleColor(.white, for: .normal)
        btnSeeList.setTitleColor(.lightGray, for: .highlighted)
        btnSeeList.titleLabel?.font = FaeFont(fontType: .demiBold, size: 18)
        addSubview(btnSeeList)
        addConstraintsWithFormat("H:[v0(64)]-20-|", options: [], views: btnSeeList)
        addConstraintsWithFormat("V:|-19-[v0(25)]", options: [], views: btnSeeList)
    }
    
    func show() {
        UIView.animate(withDuration: 0.3, delay: 0, options: .curveEaseOut, animations: {
            self.frame.origin.y = screenHeight - self.frame.size.height
        }, completion: nil)
    }
    
    func hide() {
        UIView.animate(withDuration: 0.3, delay: 0, options: .curveEaseOut, animations: {
            self.frame.origin.y = screenHeight
        }, completion: nil)
    }
}

protocol AddPlacetoCollectionDelegate: class {
    func createColList()
    func cancelAddPlace()
}

class AddPlaceToCollectionView: UIView, UITableViewDelegate, UITableViewDataSource {
    weak var delegate: AddPlacetoCollectionDelegate?
    
    var uiviewHeader: UIView!
    var btnNew: UIButton!
    var btnCancel: UIButton!
    var tblAddCollection: UITableView!
    var uiviewAfterAdded: AfterAddedToListView!
    
    override init(frame: CGRect = .zero) {
        super.init(frame: CGRect(x: 0, y: screenHeight, width: screenWidth, height: 434 * screenHeightFactor))
        backgroundColor = .white
        loadContent()
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func show() {
        UIView.animate(withDuration: 0.3, delay: 0, options: .curveEaseOut, animations: {
            self.frame.origin.y = screenHeight - self.frame.size.height
        }, completion: nil)
    }
    
    func hide() {
        UIView.animate(withDuration: 0.3, delay: 0, options: .curveEaseOut, animations: {
            self.frame.origin.y = screenHeight
        }, completion: nil)
    }
    
    fileprivate func loadContent() {
        layer.zPosition = 1001
        
        uiviewHeader = UIView(frame: CGRect(x: 0, y: 0, width: screenWidth, height: 58))
        addSubview(uiviewHeader)
        
        //        let swipeGesture = UISwipeGestureRecognizer(target: self, action: #selector(actionCancel(_:)))
        //        swipeGesture.direction = .down
        //        uiviewHeader.addGestureRecognizer(swipeGesture)
        
        let upperLine = UIView(frame: CGRect(x: 0, y: 0, width: screenWidth, height: 1))
        upperLine.backgroundColor = UIColor._200199204()
        uiviewHeader.addSubview(upperLine)
        
        let lowerLine = UIView(frame: CGRect(x: 0, y: 57, width: screenWidth, height: 1))
        lowerLine.backgroundColor = UIColor._200199204()
        uiviewHeader.addSubview(lowerLine)
        
        let lblAddCollection = UILabel(frame: CGRect(x: (screenWidth - 200) / 2, y: 20, width: 200, height: 27))
        lblAddCollection.textColor = UIColor._898989()
        lblAddCollection.font = UIFont(name: "AvenirNext-Medium", size: 20)
        lblAddCollection.text = "Add to Collection"
        lblAddCollection.textAlignment = .center
        uiviewHeader.addSubview(lblAddCollection)
        
        btnCancel = UIButton(frame: CGRect(x: 0, y: 16, width: 87, height: 35))
        btnCancel.setTitle("Cancel", for: .normal)
        btnCancel.setTitleColor(UIColor._115115115(), for: .normal)
        btnCancel.titleLabel?.font = UIFont(name: "AvenirNext-Medium", size: 18)
        uiviewHeader.addSubview(btnCancel)
        btnCancel.addTarget(self, action: #selector(actionCancel(_:)), for: .touchUpInside)
        
        btnNew = UIButton(frame: CGRect(x: screenWidth - 69, y: 16, width: 69, height: 35))
        btnNew.setTitle("New", for: .normal)
        btnNew.setTitleColor(UIColor._2499090(), for: .normal)
        btnNew.titleLabel?.font = UIFont(name: "AvenirNext-Medium", size: 18)
        uiviewHeader.addSubview(btnNew)
        btnNew.addTarget(self, action: #selector(actionNew(_:)), for: .touchUpInside)
        
        loadTable()
    }
    
    fileprivate func loadTable() {
        tblAddCollection = UITableView(frame: CGRect(x: 0, y: 58, width: screenWidth, height: 434 * screenHeightFactor - 58))
        tblAddCollection.delegate = self
        tblAddCollection.dataSource = self
        tblAddCollection.showsVerticalScrollIndicator = false
        tblAddCollection.register(CollectionsListCell.self, forCellReuseIdentifier: "CollectionsListCell")
        tblAddCollection.separatorStyle = .none
        addSubview(tblAddCollection)
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 100
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 3
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "CollectionsListCell", for: indexPath) as! CollectionsListCell
        let arr = ["Favorite Place", "Saved Places", "Places to Go"]
        cell.lblListName.text = arr[indexPath.row]
        cell.lblListNum.text = "12 items"
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        self.hide()
        uiviewAfterAdded.show()
        DispatchQueue.main.asyncAfter(deadline: .now() + 3) {
            self.uiviewAfterAdded.hide()
        }
    }
    
    func actionCancel(_ sender: UIButton) {
        delegate?.cancelAddPlace()
    }
    
    func actionNew(_ sender: UIButton) {
        delegate?.createColList()
    }
}
