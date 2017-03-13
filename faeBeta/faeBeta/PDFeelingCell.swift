//
//  PDFeelingCell.swift
//  faeBeta
//
//  Created by Yue on 3/12/17.
//  Copyright © 2017 fae. All rights reserved.
//

import UIKit

class PDFeelingCell: UITableViewCell {
    
    var img_01: PDFeelingItem!
    var img_02: PDFeelingItem!
    var img_03: PDFeelingItem!
    var img_04: PDFeelingItem!
    var img_05: PDFeelingItem!
    var img_06: PDFeelingItem!
    var img_07: PDFeelingItem!
    var img_08: PDFeelingItem!
    var img_09: PDFeelingItem!
    var img_10: PDFeelingItem!
    var img_11: PDFeelingItem!
    
    override init(style: UITableViewCellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        self.separatorInset = UIEdgeInsetsMake(0, 500, 0, 0)
        loadCellContent()
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    fileprivate func loadCellContent() {
        
        let h_offset = ceil((screenWidth-138)/4)
        let h_offset_1 = ceil((screenWidth-92-h_offset)/2)
        
        img_01 = PDFeelingItem()
        img_01.image.image = #imageLiteral(resourceName: "pdFeeling_01")
        addSubview(img_01)
        img_02 = PDFeelingItem()
        img_02.image.image = #imageLiteral(resourceName: "pdFeeling_02")
        addSubview(img_02)
        img_03 = PDFeelingItem()
        img_03.image.image = #imageLiteral(resourceName: "pdFeeling_03")
        addSubview(img_03)
        addConstraintsWithFormat("H:|-\(h_offset)-[v0(46)]-\(h_offset)-[v1(46)]-\(h_offset)-[v2(46)]", options: [], views: img_01, img_02, img_03)
        
        img_04 = PDFeelingItem()
        img_04.image.image = #imageLiteral(resourceName: "pdFeeling_04")
        addSubview(img_04)
        img_05 = PDFeelingItem()
        img_05.image.image = #imageLiteral(resourceName: "pdFeeling_05")
        addSubview(img_05)
        img_06 = PDFeelingItem()
        img_06.image.image = #imageLiteral(resourceName: "pdFeeling_06")
        addSubview(img_06)
        addConstraintsWithFormat("H:|-\(h_offset)-[v0(46)]-\(h_offset)-[v1(46)]-\(h_offset)-[v2(46)]", options: [], views: img_04, img_05, img_06)

        img_07 = PDFeelingItem()
        img_07.image.image = #imageLiteral(resourceName: "pdFeeling_07")
        addSubview(img_07)
        img_08 = PDFeelingItem()
        img_08.image.image = #imageLiteral(resourceName: "pdFeeling_08")
        addSubview(img_08)
        img_09 = PDFeelingItem()
        img_09.image.image = #imageLiteral(resourceName: "pdFeeling_09")
        addSubview(img_09)
        addConstraintsWithFormat("H:|-\(h_offset)-[v0(46)]-\(h_offset)-[v1(46)]-\(h_offset)-[v2(46)]", options: [], views: img_07, img_08, img_09)
        
        img_10 = PDFeelingItem()
        img_10.image.image = #imageLiteral(resourceName: "pdFeeling_10")
        addSubview(img_10)
        img_11 = PDFeelingItem()
        img_11.image.image = #imageLiteral(resourceName: "pdFeeling_11")
        addSubview(img_11)
        addConstraintsWithFormat("H:|-\(h_offset_1)-[v0(46)]-\(h_offset)-[v1(46)]", options: [], views: img_10, img_11)
        
        addConstraintsWithFormat("V:|-26-[v0(66)]-28-[v1(66)]-28-[v2(66)]-28-[v3(66)]-16-|", options: [], views: img_01, img_04, img_07, img_10)
        addConstraintsWithFormat("V:|-26-[v0(66)]-28-[v1(66)]-28-[v2(66)]-28-[v3(66)]-16-|", options: [], views: img_02, img_05, img_08, img_11)
        addConstraintsWithFormat("V:|-26-[v0(66)]-28-[v1(66)]-28-[v2(66)]-110-|", options: [], views: img_03, img_06, img_09)
    }
    
}

class PDFeelingItem: UIView {
    
    var image: UIImageView!
    var label: UILabel!
    
    override init(frame: CGRect) {
        let newFrame = CGRect(origin: CGPoint(x: frame.minX, y: frame.minY), size: CGSize(width: 46, height: 66))
        super.init(frame: newFrame)
        loadItemContent()
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    fileprivate func loadItemContent() {
        image = UIImageView(frame: CGRect(x: 0, y: 0, width: 46, height: 46))
        image.clipsToBounds = true
        image.contentMode = .scaleAspectFit
        image.image = #imageLiteral(resourceName: "pdFeeling_01")
        addSubview(image)
        
        label = UILabel(frame: CGRect(x: 0, y: 46, width: 46, height: 20))
        label.textColor = UIColor.faeAppTimeTextBlackColor()
        label.textAlignment = .center
        label.text = "0"
        label.font = UIFont(name: "AvenirNext-Medium", size: 15)
        addSubview(label)
    }
}
