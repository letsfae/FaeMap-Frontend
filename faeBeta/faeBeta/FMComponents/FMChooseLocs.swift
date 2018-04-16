//
//  FMChooseLocs.swift
//  faeBeta
//
//  Created by Yue Shen on 8/18/17.
//  Copyright © 2017 fae. All rights reserved.
//

import UIKit

protocol FMRouteCalculateDelegate: class {
    func hideRouteCalculatorComponents()
}

class FMChooseLocs: UIView {
    
    weak var delegate: FMRouteCalculateDelegate?
    var lblStartPoint: UILabel!
    var lblDestination: UILabel!
    
    override init(frame: CGRect = .zero) {
        super.init(frame: CGRect(x: 0, y: -119 - device_offset_top, width: screenWidth, height: 119 + device_offset_top))
        loadContent()
        layer.zPosition = 1001
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func loadContent() {
        
        backgroundColor = .white
        
        let leftBtn = UIButton()
        leftBtn.setImage(#imageLiteral(resourceName: "mainScreenSearchToFaeMap"), for: .normal)
        addSubview(leftBtn)
        addConstraintsWithFormat("H:|-0-[v0(40.5)]", options: [], views: leftBtn)
        addConstraintsWithFormat("V:|-\(21+device_offset_top)-[v0(38)]", options: [], views: leftBtn)
        leftBtn.addTarget(self, action: #selector(actionBackBtn), for: .touchUpInside)
        
        let imgLhsSign = UIImageView()
        imgLhsSign.contentMode = .scaleAspectFit
        imgLhsSign.image = #imageLiteral(resourceName: "place_new_choose_locations_lhs")
        addSubview(imgLhsSign)
        addConstraintsWithFormat("H:|-46-[v0(19)]", options: [], views: imgLhsSign)
        addConstraintsWithFormat("V:|-\(32+device_offset_top)-[v0(67)]", options: [], views: imgLhsSign)
        
        let lineMid = UIView()
        lineMid.backgroundColor = UIColor._200199204()
        addSubview(lineMid)
        addConstraintsWithFormat("H:|-69-[v0]-68-|", options: [], views: lineMid)
        addConstraintsWithFormat("V:|-\(64.5+device_offset_top)-[v0(1)]", options: [], views: lineMid)
        
        let lineBottom = UIView()
        lineBottom.backgroundColor = UIColor._200199204()
        addSubview(lineBottom)
        addConstraintsWithFormat("H:|-0-[v0]-0-|", options: [], views: lineBottom)
        addConstraintsWithFormat("V:[v0(1)]-0-|", options: [], views: lineBottom)
        
        lblStartPoint = UILabel()
        lblStartPoint.textColor = UIColor._898989()
        lblStartPoint.textAlignment = .left
        lblStartPoint.font = UIFont(name: "AvenirNext-Medium", size: 18)
        lblStartPoint.text = "Current Location"
        lblStartPoint.isUserInteractionEnabled = true
        addSubview(lblStartPoint)
        addConstraintsWithFormat("H:|-72-[v0]-68-|", options: [], views: lblStartPoint)
        addConstraintsWithFormat("V:|-\(18.5+device_offset_top)-[v0(43)]", options: [], views: lblStartPoint)
        
        lblDestination = UILabel()
        lblDestination.textColor = UIColor._898989()
        lblDestination.textAlignment = .left
        lblDestination.font = UIFont(name: "AvenirNext-Medium", size: 18)
        lblDestination.isUserInteractionEnabled = true
        addSubview(lblDestination)
        addConstraintsWithFormat("H:|-72-[v0]-68-|", options: [], views: lblDestination)
        addConstraintsWithFormat("V:|-\(69+device_offset_top)-[v0(43)]", options: [], views: lblDestination)
    }
    
    func updateStartPoint(name: String) {
        lblStartPoint.text = name
    }
    
    func updateDestination(name: String) {
        lblDestination.text = name
    }
    
    @objc func actionBackBtn() {
        delegate?.hideRouteCalculatorComponents()
    }
    
    func hide(animated: Bool = true) {
        if !animated {
            self.frame.origin.y = -self.frame.size.height
            return
        } else {
            UIView.animate(withDuration: 0.3, delay: 0, options: .curveEaseOut, animations: {
                self.frame.origin.y = -self.frame.size.height
            })
        }
    }
    
    func show(animated: Bool = true) {
        if animated {
            UIView.animate(withDuration: 0.3, delay: 0, options: .curveEaseOut, animations: {
                self.frame.origin.y = 0
            })
        } else {
            self.frame.origin.y = 0
        }
    }
}
