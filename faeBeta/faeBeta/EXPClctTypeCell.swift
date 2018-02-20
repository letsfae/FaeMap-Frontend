//
//  EXPClctTypeCell.swift
//  faeBeta
//
//  Created by Yue Shen on 2/6/18.
//  Copyright © 2018 fae. All rights reserved.
//

import UIKit

enum CategoryState {
    case initial, unread, read, selected
}

class EXPClctTypeCell: UICollectionViewCell {
    
    //weak var delegate: ExploreCategorySearch?
    
    var btnType: UIButton!
    var category = ""
    var indexPath: IndexPath!
    var state = CategoryState.initial {
        didSet {
            guard fullLoaded else { return }
            switch state {
            case .initial:
                btnType.titleLabel?.font = FaeFont(fontType: .medium, size: 15)
                btnType.setTitleColor(.lightGray, for: .normal)
            case .unread:
                btnType.titleLabel?.font = FaeFont(fontType: .medium, size: 15)
                btnType.setTitleColor(UIColor(r: 102, g: 192, b: 251, alpha: 100), for: .normal)
            case .read:
                btnType.titleLabel?.font = FaeFont(fontType: .medium, size: 15)
                btnType.setTitleColor(.lightGray, for: .normal)
            case .selected:
                btnType.titleLabel?.font = FaeFont(fontType: .demiBold, size: 15)
                btnType.setTitleColor(UIColor._2499090(), for: .normal)
            }
        }
    }
    
    var fullLoaded = false
    
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
        fullLoaded = true
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func setButtonColor(selected: Bool) {
        btnType.isSelected = selected
        if selected {
            btnType.titleLabel?.font = FaeFont(fontType: .demiBold, size: 15)
        } else {
            btnType.titleLabel?.font = FaeFont(fontType: .medium, size: 15)
        }
    }
    
    func loadCellItems() {
        btnType = UIButton()
        btnType.setTitle("", for: .normal)
        btnType.setTitleColor(.lightGray, for: .normal)
        btnType.titleLabel?.font = FaeFont(fontType: .medium, size: 15)
        btnType.titleLabel?.textAlignment = .center
        btnType.addTarget(self, action: #selector(actionSearch), for: .touchUpInside)
        btnType.isUserInteractionEnabled = false
        addSubview(btnType)
        widthContraint = returnConstraintsWithFormat("H:|-0-[v0(50)]", options: [], views: btnType)
        addConstraintsWithFormat("V:[v0(36)]-0-|", options: [], views: btnType)
    }
    
    @objc func actionSearch() {
        guard indexPath != nil else { return }
        //delegate?.search(category: category, indexPath: indexPath)
    }
    
    func updateTitle(type: String) {
        category = type
        btnType.setTitle(type, for: .normal)
        guard let lblWidth = btnType.titleLabel?.intrinsicContentSize.width else { return }
        widthContraint = returnConstraintsWithFormat("H:|-0-[v0(\(Int(lblWidth) + 3))]", options: [], views: btnType)
    }
}
