//
//  EditPinCollectionViewCell.swift
//  faeBeta
//
//  Created by Jacky on 1/7/17.
//  Copyright © 2017 fae. All rights reserved.
//

import UIKit

protocol EditMediaCollectionCellDelegate: class {
    func deleteMedia(cell: EditPinCollectionViewCell)
}

class EditPinCollectionViewCell: UICollectionViewCell {
    
    var media: UIImageView!
    var fullView: UIView!
    var circleLayer: CAShapeLayer!
    var buttonCancel: UIButton!
    
    weak var delegate: EditMediaCollectionCellDelegate?
    
    override init(frame: CGRect){
        super.init(frame: frame)
        loadItems()
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    func loadItems() {
        fullView = UIView(frame: CGRect(x: 0, y: 0, width: 100, height: 100))
        self.addSubview(fullView)
        
        media = UIImageView(frame: CGRect(x: 0, y: 5, width: 95, height: 95))
        media.clipsToBounds = true
        media.layer.cornerRadius = 13.5
        media.contentMode = .scaleAspectFill
        var center = CGPoint()
        center.x = 100
        center.y = 0
        let arcInCorner = UIBezierPath(arcCenter: center, radius: CGFloat(23.5), startAngle: CGFloat(0.5 * M_PI+0.214), endAngle: CGFloat(1.5 * M_PI-0.214), clockwise: true)
        circleLayer = CAShapeLayer()
        circleLayer.path = arcInCorner.cgPath
        circleLayer.lineWidth = 3
        circleLayer.strokeColor = UIColor.white.cgColor
        circleLayer.fillColor = UIColor.clear.cgColor
        circleLayer.zPosition = 999
        //fullView.layer.addSublayer(circleLayer)
        fullView.addSubview(media)
        
        buttonCancel = UIButton(frame: CGRect(x: 74, y: 0, width: 26, height: 26))
        buttonCancel.setImage(#imageLiteral(resourceName: "Cancel"), for: UIControlState())
        buttonCancel.alpha = 0.7
        buttonCancel.addTarget(self, action: #selector(self.deletePinMedia(_ :)), for: .touchUpInside)
        fullView.addSubview(buttonCancel)
    }
    
    func deletePinMedia(_ sender: UIButton){
        self.delegate?.deleteMedia(cell: self)
    }
    
}
