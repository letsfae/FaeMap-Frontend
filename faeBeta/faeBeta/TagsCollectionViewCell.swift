//
//  TagsCollectionViewCell.swift
//  faeBeta
//
//  Created by blesssecret on 9/24/16.
//  Copyright © 2016 fae. All rights reserved.
//

import UIKit

class TagsCollectionViewCell: UICollectionViewCell {
    var labelTitle : UILabel!
    var colorSelf : UIColor = UIColor.clearColor(){
        didSet {
            self.contentView.layer.borderColor = colorSelf.CGColor
            if selected == true {
                cellDidSelected()
            } else {
                cellDidUnselected()
            }
        }
    }
    var colors = [UIColor]()
    override var selected: Bool {
        didSet {
            if selected == false {
                cellDidUnselected()
            } else {
                cellDidSelected()
            }
        }
    }
    override init(frame: CGRect) {
        super.init(frame: frame)
        self.clipsToBounds = false;
        self.contentView.clipsToBounds = false;
        
//        self.contentView.layer.borderColor = colorSelf.CGColor;
        self.contentView.layer.borderWidth = 2.0;
        self.contentView.layer.cornerRadius = 6.6
        let wid = self.contentView.bounds.width
        let hei = self.contentView.bounds.height
        labelTitle = UILabel(frame: CGRectMake(25,0,wid - 25 * 2, hei))
        labelTitle.font = UIFont(name: "AvenirNext-DemiBold", size: 18)
        labelTitle.translatesAutoresizingMaskIntoConstraints = false;
        labelTitle.backgroundColor = UIColor.clearColor()
        labelTitle.textColor = colorSelf
        self.contentView.addSubview(labelTitle)
        
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func cellDidSelected() {
        labelTitle.textColor = UIColor.whiteColor()
        self.contentView.backgroundColor = colorSelf
    }
    
    func cellDidUnselected() {
        self.contentView.backgroundColor = UIColor.clearColor()
        labelTitle.textColor = colorSelf
    }
    func newContentSize() -> CGSize {
        var size = labelTitle.intrinsicContentSize()
        size.height = 39;
        size.width += 25 * 2
        return size;
    }
}
