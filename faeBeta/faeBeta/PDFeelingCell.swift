//
//  PDFeelingCell.swift
//  faeBeta
//
//  Created by Yue on 3/12/17.
//  Copyright © 2017 fae. All rights reserved.
//

import UIKit

protocol PinFeelingCellDelegate: class {
    func postFeelingFromFeelingCell(_ feeling: Int)
    func deleteFeelingFromFeelingCell()
}

class PDFeelingCell: UITableViewCell {
    
    weak var delegate: PinFeelingCellDelegate?
    
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
    var imgArray = [PDFeelingItem]()
    
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
        img_02 = PDFeelingItem()
        img_03 = PDFeelingItem()
        img_04 = PDFeelingItem()
        img_05 = PDFeelingItem()
        img_06 = PDFeelingItem()
        img_07 = PDFeelingItem()
        img_08 = PDFeelingItem()
        img_09 = PDFeelingItem()
        img_10 = PDFeelingItem()
        img_11 = PDFeelingItem()
        
        imgArray.append(img_01)
        imgArray.append(img_02)
        imgArray.append(img_03)
        imgArray.append(img_04)
        imgArray.append(img_05)
        imgArray.append(img_06)
        imgArray.append(img_07)
        imgArray.append(img_08)
        imgArray.append(img_09)
        imgArray.append(img_10)
        imgArray.append(img_11)
        
        for i in 0..<11 {
            if i >= 9 {
                imgArray[i].image.image = UIImage(named: "pdFeeling_\(i+1)")
            } else {
                imgArray[i].image.image = UIImage(named: "pdFeeling_0\(i+1)")
            }
            addSubview(imgArray[i])
            imgArray[i].tag = i
            imgArray[i].addTarget(self, action: #selector(self.postFeeling(_:)), for: .touchUpInside)
        }
        
        addConstraintsWithFormat("H:|-\(h_offset)-[v0(46)]-\(h_offset)-[v1(46)]-\(h_offset)-[v2(46)]", options: [], views: img_01, img_02, img_03)
        addConstraintsWithFormat("H:|-\(h_offset)-[v0(46)]-\(h_offset)-[v1(46)]-\(h_offset)-[v2(46)]", options: [], views: img_04, img_05, img_06)
        addConstraintsWithFormat("H:|-\(h_offset)-[v0(46)]-\(h_offset)-[v1(46)]-\(h_offset)-[v2(46)]", options: [], views: img_07, img_08, img_09)
        addConstraintsWithFormat("H:|-\(h_offset_1)-[v0(46)]-\(h_offset)-[v1(46)]", options: [], views: img_10, img_11)
        addConstraintsWithFormat("V:|-26-[v0(66)]-28-[v1(66)]-28-[v2(66)]-28-[v3(66)]-16-|", options: [], views: img_01, img_04, img_07, img_10)
        addConstraintsWithFormat("V:|-26-[v0(66)]-28-[v1(66)]-28-[v2(66)]-28-[v3(66)]-16-|", options: [], views: img_02, img_05, img_08, img_11)
        addConstraintsWithFormat("V:|-26-[v0(66)]-28-[v1(66)]-28-[v2(66)]-110-|", options: [], views: img_03, img_06, img_09)
    }
    
    func postFeeling(_ sender: PDFeelingItem) {
        self.delegate?.postFeelingFromFeelingCell(sender.tag)
    }
    
}

class PDFeelingItem: UIButton {
    
    var image: UIImageView!
    var label: UILabel!
    var avatar: UIImageView!
    
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
        
        avatar = UIImageView(frame: CGRect(x: 27, y: 25, width: 20, height: 20))
        avatar.clipsToBounds = true
        avatar.contentMode = .scaleAspectFit
        avatar.layer.cornerRadius = 10
        addSubview(avatar)
        avatar.backgroundColor = UIColor.faeAppRedColor()
        avatar.isHidden = true
    }
}
