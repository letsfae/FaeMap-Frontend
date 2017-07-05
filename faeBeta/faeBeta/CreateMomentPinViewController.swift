//
//  CreateMomentPinViewController.swift
//  faeBeta
//
//  Created by Yue on 11/24/16.
//  Copyright © 2016 fae. All rights reserved.
//

import UIKit
import CoreLocation

class CreateMomentPinViewController: CreatePinBaseViewController {

    var btnTakeMedia: UIButton!
    var btnSelectMedia: UIButton!
    var imagePicker: UIImagePickerController!
    var selectedMediaArray = [UIImage]()
    var collectionViewMedia: UICollectionView!
    var activityIndicator: UIActivityIndicatorView!
    var btnAddMedia: UIButton!
    var lastContentOffset: CGFloat = -999

    override func viewDidLoad() {
        pinType = .story
        super.viewDidLoad()
    }
    
    override func setupBaseUI() {
        super.setupBaseUI()
        
        btnSubmit.backgroundColor = UIColor(red: 149/255, green: 207/255, blue: 246/255, alpha: 0.65)
        imgTitle.image = #imageLiteral(resourceName: "momentPinTitleImage")
        lblTitle.text = "Create Story Pin"
        switchAnony.onTintColor = UIColor(red: 149/255, green: 207/255, blue: 246/255, alpha: 1)
        
        textviewDescrip.placeHolder = "Add Description..."
        loadCreateMediaPinView()
    }
    
    fileprivate func loadCreateMediaPinView() {
        let layout = CenterCellCollectionViewFlowLayout()
        layout.itemSize = CGSize(width: 200, height: 200)
        layout.scrollDirection = .horizontal
        layout.minimumInteritemSpacing = 0
        layout.minimumLineSpacing = 49
        
        collectionViewMedia = UICollectionView(frame: CGRect(x: 0, y: 200, width: screenWidth, height: 200), collectionViewLayout: layout)
        collectionViewMedia.register(CMPCollectionViewCell.self, forCellWithReuseIdentifier: "selectedMedia")
        collectionViewMedia.delegate = self
        collectionViewMedia.dataSource = self
        collectionViewMedia.isPagingEnabled = false
        collectionViewMedia.isHidden = true
        collectionViewMedia.backgroundColor = UIColor.clear
        collectionViewMedia.showsHorizontalScrollIndicator = false
        collectionViewMedia.layer.zPosition = 100
        self.view.addSubview(collectionViewMedia)
        
        btnTakeMedia = UIButton(frame: CGRect(x: 109, y: 268, width: 65, height: 65))
        btnTakeMedia.setImage(UIImage(named: "momentPinTakeMoment"), for: UIControlState())
        self.view.addSubview(btnTakeMedia)
        self.view.addConstraintsWithFormat("H:|-109-[v0(65)]", options: [], views: btnTakeMedia)
        self.view.addConstraintsWithFormat("V:|-268-[v0(65)]", options: [], views: btnTakeMedia)
        btnTakeMedia.addTarget(self, action: #selector(self.actionTakePhoto(_:)), for: .touchUpInside)
        
        btnSelectMedia = UIButton(frame: CGRect(x: 241, y: 268, width: 65, height: 65))
        btnSelectMedia.setImage(UIImage(named: "momentPinSelectMoment"), for: UIControlState())
        self.view.addSubview(btnSelectMedia)
        self.view.addConstraintsWithFormat("H:[v0(65)]-109-|", options: [], views: btnSelectMedia)
        self.view.addConstraintsWithFormat("V:|-268-[v0(65)]", options: [], views: btnSelectMedia)
        btnSelectMedia.addTarget(self, action: #selector(self.actionTakeMedia(_:)), for: .touchUpInside)
        
        loadAddMediaButton()
    }
    
    fileprivate func loadAddMediaButton() {
        btnAddMedia = UIButton()
        btnAddMedia.tag = 0
        btnAddMedia.alpha = 0
        btnAddMedia.setImage(#imageLiteral(resourceName: "momentAddMedia"), for: .normal)
        btnAddMedia.addTarget(self, action: #selector(self.actionAddMedia(_:)), for: .touchUpInside)
        self.view.addSubview(btnAddMedia)
        self.view.addConstraintsWithFormat("H:[v0(88)]-0-|", options: [], views: btnAddMedia)
        self.view.addConstraintsWithFormat("V:|-200-[v0(200)]", options: [], views: btnAddMedia)
    }
    
    override func switchToMoreOptions() {
        super.switchToMoreOptions()
        UIView.animate(withDuration: 0.4, animations: {
            Void in
            self.tblPinOptions.alpha = 0
            self.collectionViewMedia.alpha = 0
            if !self.btnSelectMedia.isHidden {
                self.btnSelectMedia.alpha = 0
                self.btnTakeMedia.alpha = 0
            }
            self.btnAddMedia.alpha = 0
            self.collectionViewMedia.alpha = 0
            
            self.lblTitle.text = "More Options"
            self.tblMoreOptions.alpha = 1
            
            self.setSubmitButton(withTitle: "Back", isEnabled: true)
        }) { _ in
            self.showAlert(title: "This feature is coming soon in the next version!", message: "")
        }
    }
    
    override func leaveMoreOptions() {
        super.leaveMoreOptions()
        UIView.animate(withDuration: 0.4, animations: {
            Void in
            self.tblPinOptions.alpha = 1
            self.collectionViewMedia.alpha = 1
            if !self.btnSelectMedia.isHidden {
                self.btnSelectMedia.alpha = 1
                self.btnTakeMedia.alpha = 1
            }
            self.btnAddMedia.alpha = 1
            self.collectionViewMedia.alpha = 1
            
            self.lblTitle.text = "Create Story Pin"
            self.tblMoreOptions.alpha = 0
            
            self.setSubmitButton(withTitle: "Submit!", isEnabled: self.boolBtnSubmitEnabled)
        })
    }
    
    override func switchToDescription() {
        super.switchToDescription()
        UIView.animate(withDuration: 0.4, animations: {
            Void in
            self.tblPinOptions.alpha = 0
            self.lblTitle.text = "Add Description"
            self.collectionViewMedia.alpha = 0
            if !self.btnSelectMedia.isHidden {
                self.btnSelectMedia.alpha = 0
                self.btnTakeMedia.alpha = 0
            }
            self.btnAddMedia.alpha = 0
            self.collectionViewMedia.alpha = 0
            
            self.textviewDescrip.alpha = 1
            
            self.setSubmitButton(withTitle: "Back", isEnabled: true)
        }, completion:{
            Complete in
            self.textviewDescrip.becomeFirstResponder()
        })
    }
    
    override func leaveDescription() {
        super.leaveDescription()
        self.tblPinOptions.reloadData()
        
        self.boolBtnSubmitEnabled = selectedMediaArray.count > 0 || (textviewDescrip?.text.characters.count)! > 0
        
        UIView.animate(withDuration: 0.4, animations: {
            Void in
            self.tblPinOptions.alpha = 1
            self.lblTitle.text = "Create Story Pin"
            self.collectionViewMedia.alpha = 1
            if !self.btnSelectMedia.isHidden {
                self.btnSelectMedia.alpha = 1
                self.btnTakeMedia.alpha = 1
            }
            self.btnAddMedia.alpha = 1
            self.collectionViewMedia.alpha = 1
            
            self.textviewDescrip.alpha = 0
            
            self.setSubmitButton(withTitle: "Submit!", isEnabled: self.boolBtnSubmitEnabled)
        }, completion:{
            Complete in
            self.textviewDescrip.resignFirstResponder()
        })
    }
    
    override func actionSubmit() {
        if selectedMediaArray.count == 0 {
            self.showAlert(title: "Please add at least one image!", message: "")
            return
        } else if textviewDescrip.text == "" {
            self.showAlert(title: "Please add a description for your story!", message: "")
            return
        }
        //        if sender.tag == 0 {
        //            return
        //        }
        //        sender.tag = 0
        
        activityIndicator = UIActivityIndicatorView()
        activityIndicator.layer.zPosition = 101
        activityIndicator.activityIndicatorViewStyle = .whiteLarge
        activityIndicator.center = view.center
        activityIndicator.hidesWhenStopped = true
        activityIndicator.color = UIColor(red: 149 / 255, green: 207 / 255, blue: 246 / 255, alpha: 1.0)
        self.view.addSubview(activityIndicator)
        self.view.bringSubview(toFront: activityIndicator)
        activityIndicator.startAnimating()
        self.uploadingFile(image: selectedMediaArray[0],
                           count: 0,
                           total: selectedMediaArray.count,
                           fileIDs: "")
    }
}
