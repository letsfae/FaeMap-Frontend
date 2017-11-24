//
//  FMPlaceActionBtn.swift
//  faeBeta
//
//  Created by Yue Shen on 8/16/17.
//  Copyright © 2017 fae. All rights reserved.
//

import UIKit

class FMDistIndicator: UIImageView {
    
    var lblDistance: UILabel!
    var strDistance = ""
    
    override init(frame: CGRect = .zero) {
        super.init(frame: frame)
        loadContent()
        isUserInteractionEnabled = false
        layer.zPosition = 1001
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func loadContent() {
        if screenWidth == 414 {
            image = #imageLiteral(resourceName: "place_new_dist_sub_5_5")
            frame.size = CGSize(width: 228, height: 63)
        } else if screenWidth == 375 {
            image = #imageLiteral(resourceName: "place_new_dist_sub_4_7")
            frame.size = CGSize(width: 189, height: 63)
        } else if screenWidth == 320 {
            image = #imageLiteral(resourceName: "place_new_dist_sub_4_0")
            frame.size = CGSize(width: 134, height: 63)
        }
        center.x = screenWidth / 2
        frame.origin.y = screenHeight + 10
        
        lblDistance = UILabel()
        lblDistance.textColor = UIColor._2499090()
        lblDistance.textAlignment = .center
        lblDistance.font = UIFont(name: "AvenirNext-DemiBold", size: 22)
        addSubview(lblDistance)
        addConstraintsWithFormat("H:|-0-[v0]-0-|", options: [], views: lblDistance)
        addConstraintsWithFormat("V:|-17-[v0(30)]", options: [], views: lblDistance)
    }
    
    func updateDistance(distance: CLLocationDistance) {
        strDistance = distance.format(f: ".1") + " mi"
        lblDistance.text = strDistance
        show()
    }
    
    func hide() {
        UIView.animate(withDuration: 0.3, delay: 0, options: .curveEaseOut, animations: {
            self.frame.origin.y = screenHeight + 10
        })
    }
    
    func show() {
        UIView.animate(withDuration: 0.3, delay: 0, options: .curveEaseOut, animations: {
            self.frame.origin.y = screenHeight - 74 - device_offset_bot
        })
    }
}

class FMPinActionDisplay: UIButton {
    
    override init(frame: CGRect = CGRect.zero) {
        super.init(frame: frame)
        loadContent()
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func loadContent() {
        alpha = 0
        layer.cornerRadius = 2
        setTitleColor(UIColor.white, for: .normal)
        titleLabel?.font = UIFont(name: "AvenirNext-Medium", size: 18)
        isUserInteractionEnabled = false
    }
    
    func changeStyle(action style: PlacePinAction, _ createLocation: FaeMode = .off) {
        let strType = createLocation == .on ? "Location" : "Place"
        show()
        switch style {
        case .detail:
            backgroundColor = UIColor._2559180()
            setTitle("View \(strType) Details", for: .normal)
            break
        case .collect:
            backgroundColor = UIColor._202144214()
            setTitle("Collect this \(strType)", for: .normal)
            break
        case .route:
            backgroundColor = UIColor._144162242()
            setTitle("Draw Route to this \(strType)", for: .normal)
            break
        case .share:
            backgroundColor = UIColor._35197143()
            setTitle("Share this \(strType)", for: .normal)
            break
        }
    }
    
    func hide() {
        alpha = 0
    }
    
    func show() {
        alpha = 1
    }
}
