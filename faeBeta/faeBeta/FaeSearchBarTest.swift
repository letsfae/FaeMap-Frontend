//
//  FaeSearchBarTest.swift
//  faeBeta
//
//  Created by Vicky on 2017-07-28.
//  Copyright © 2017 fae. All rights reserved.
//

import UIKit

protocol FaeSearchBarTestDelegate: class {
    func searchBarTextDidBeginEditing(_ searchBar: FaeSearchBarTest)
    func searchBar(_ searchBar: FaeSearchBarTest, textDidChange searchText: String)
    func searchBarSearchButtonClicked(_ searchBar: FaeSearchBarTest)
    func searchBarCancelButtonClicked(_ searchBar: FaeSearchBarTest)
}

class FaeSearchBarTest: UIView, UITextFieldDelegate {
    weak var delegate: FaeSearchBarTestDelegate?
    var imgSearch: UIImageView!
    var btnClose: UIButton!
    var txtSchField: UITextField!
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setUpUI()
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    fileprivate func setUpUI() {
        imgSearch = UIImageView()
        imgSearch.image = #imageLiteral(resourceName: "searchBarIcon")
        addSubview(imgSearch)
        let padding = (self.frame.size.height - 15) / 2
        addConstraintsWithFormat("V:|-\(padding)-[v0]-\(padding)-|", options: [], views: imgSearch)
        
        btnClose = UIButton()
        btnClose.setImage(#imageLiteral(resourceName: "mainScreenSearchClearSearchBar"), for: .normal)
        addSubview(btnClose)
        btnClose.addTarget(self, action: #selector(self.actionDeleteSearchTxt(_:)), for: .touchUpInside)
        addConstraintsWithFormat("V:|-0-[v0]-0-|", options: [], views: btnClose)
        
        txtSchField = UITextField()
        txtSchField.delegate = self
        addSubview(txtSchField)
        addConstraintsWithFormat("V:|-0-[v0]-0-|", options: [], views: txtSchField)
        
        addConstraintsWithFormat("H:|-10-[v0(15)]-9-[v1]-5-[v2(30)]-21-|", options: [], views: imgSearch, txtSchField, btnClose)
        
        btnClose.isHidden = true
        
        txtSchField.textColor = UIColor._898989()
        txtSchField.font = UIFont(name: "AvenirNext-Medium", size: 18)
        txtSchField.clearButtonMode = .never
        txtSchField.contentHorizontalAlignment = .left
        txtSchField.textAlignment = .left
        txtSchField.contentVerticalAlignment = .center
        txtSchField.tintColor = UIColor._2499090()
        txtSchField.autocapitalizationType = .none
        txtSchField.autocorrectionType = .no
        txtSchField.returnKeyType = .search
        txtSchField.addTarget(self, action: #selector(self.actionTextFieldDidChange(_:)), for: .editingChanged)
    }
    
    func actionDeleteSearchTxt(_ sender: UIButton) {
        txtSchField.text = ""
        btnClose.isHidden = true
        delegate?.searchBar(self, textDidChange: "")
        delegate?.searchBarCancelButtonClicked(self)
    }
    
    func actionTextFieldDidChange(_ textField: UITextField) {
        if textField.text != "" {
            btnClose.isHidden = false
        } else {
            btnClose.isHidden = true
        }
        delegate?.searchBar(self, textDidChange: textField.text!)
    }
    
    func textFieldDidBeginEditing(_ textField: UITextField) {
        delegate?.searchBarTextDidBeginEditing(self)
    }
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        delegate?.searchBarSearchButtonClicked(self)
        return true
    }
}

