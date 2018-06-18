//
//  AfterAddedToListView.swift
//  faeBeta
//
//  Created by Yue Shen on 6/10/18.
//  Copyright © 2018 fae. All rights reserved.
//

import UIKit

protocol AfterAddedToListDelegate: class {
    func seeList()
    func undoCollect(colId: Int, mode: UndoMode)
}

enum UndoMode {
    case save
    case unsave
}

class AfterAddedToListView: UIView {
    
    weak var delegate: AfterAddedToListDelegate?
    var uiviewAfterAdded: UIView!
    var pinIdInAction: Int = -1
    var selectedCollection: RealmCollection!
    var lblSaved: FaeLabel!
    var mode: UndoMode = .save
    var btnUndo: UIButton!
    var btnSeeList: UIButton!
    private var showed: Bool = false
    
    override init(frame: CGRect = .zero) {
        let height: CGFloat = screenHeight == 812 ? 49 + device_offset_bot : 60
        super.init(frame: CGRect(x: 0, y: screenHeight, width: screenWidth, height: height))
        loadContent()
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
    
    private func loadContent() {
        layer.zPosition = 1002
        
        let blurEffect = UIBlurEffect(style: UIBlurEffectStyle.dark)
        let blurEffectView = UIVisualEffectView(effect: blurEffect)
        blurEffectView.frame = self.bounds
        addSubview(blurEffectView)
        
        lblSaved = FaeLabel(CGRect(x: 20, y: 19, width: 170, height: 25), .left, .medium, 18, .white)
        lblSaved.text = "Collected to List!"
        addSubview(lblSaved)
        
        btnUndo = UIButton()
        btnUndo.setTitle("Undo", for: .normal)
        btnUndo.setTitleColor(.white, for: .normal)
        btnUndo.setTitleColor(.lightGray, for: .highlighted)
        btnUndo.titleLabel?.font = FaeFont(fontType: .demiBold, size: 18)
        btnUndo.addTarget(self, action: #selector(undoCollecting), for: .touchUpInside)
        addSubview(btnUndo)
        addConstraintsWithFormat("H:[v0(46)]-109-|", options: [], views: btnUndo)
        addConstraintsWithFormat("V:|-19-[v0(25)]", options: [], views: btnUndo)
        
        btnSeeList = UIButton()
        btnSeeList.setTitle("See List", for: .normal)
        btnSeeList.setTitleColor(.white, for: .normal)
        btnSeeList.setTitleColor(.lightGray, for: .highlighted)
        btnSeeList.titleLabel?.font = FaeFont(fontType: .demiBold, size: 18)
        btnSeeList.addTarget(self, action: #selector(goToList), for: .touchUpInside)
        addSubview(btnSeeList)
        addConstraintsWithFormat("H:[v0(64)]-20-|", options: [], views: btnSeeList)
        addConstraintsWithFormat("V:|-19-[v0(25)]", options: [], views: btnSeeList)
    }
    
    @objc func undoCollecting() {
        guard let col = selectedCollection, pinIdInAction != -1 else { return }
        self.hide()
        switch mode {
        case .save:
            FaeCollection.shared.saveToCollection(col.type, collectionID: String(col.collection_id), pinID: String(pinIdInAction)) { [weak self] (status, message) in
                guard status / 100 == 2 else { return }
                joshprint("[undoCollecting] successfully saved again")
                guard let `self` = self else { return }
                self.selectedCollection = nil
                self.delegate?.undoCollect(colId: col.collection_id, mode: self.mode)

                RealmCollection.savePin(collection_id: col.collection_id, type: col.type, pin_id: self.pinIdInAction)
            }
        case .unsave:
            FaeCollection.shared.unsaveFromCollection(col.type, collectionID: String(col.collection_id), pinID: String(pinIdInAction)) { [weak self] (status, message) in
                guard status / 100 == 2 else { return }
                joshprint("[undoCollecting] successfully unsave this pin")
                guard let `self` = self else { return }
                self.selectedCollection = nil
                self.delegate?.undoCollect(colId: col.collection_id, mode: self.mode)
                
                RealmCollection.unsavePin(collection_id: col.collection_id, type: col.type, pin_id: self.pinIdInAction)
            }
        }
    }
    
    @objc func goToList() {
        delegate?.seeList()
    }
    
    public func reset() {
        pinIdInAction = -1
    }
    
    func show(save: Bool = true, _ content: String) {
        //lblSaved.text = save ? "Collected to List!" : "Removed from List!"
        lblSaved.text = content
        mode = !save ? .save : .unsave
        guard !showed else { return }
        showed = true
        UIView.animate(withDuration: 0.3, delay: 0, options: .curveEaseOut, animations: {
            self.frame.origin.y = screenHeight - self.frame.size.height
        }, completion: nil)
    }
    
    func hide() {
        guard showed else { return }
        showed = false
        UIView.animate(withDuration: 0.3, delay: 0, options: .curveEaseOut, animations: {
            self.frame.origin.y = screenHeight
        }, completion: nil)
    }
}
