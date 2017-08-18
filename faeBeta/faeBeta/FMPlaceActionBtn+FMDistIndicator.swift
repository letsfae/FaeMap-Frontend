//
//  FMPlaceActionBtn.swift
//  faeBeta
//
//  Created by Yue Shen on 8/16/17.
//  Copyright © 2017 fae. All rights reserved.
//

import UIKit

class FMDistIndicator: UIImageView {
    
    var faeMapCtrler: FaeMapViewController?
    var lblDistance: UILabel!
    
    override init(frame: CGRect = .zero) {
        super.init(frame: frame)
        loadContent()
        isUserInteractionEnabled = true
        layer.zPosition = 1001
        
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(self.hide))
        addGestureRecognizer(tapGesture)
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
        lblDistance.text = distance.format(f: ".1") + " mi"
        show()
    }
    
    func hide() {
        faeMapCtrler?.removeAllRoutes()
        UIView.animate(withDuration: 0.3, delay: 0, options: .curveEaseOut, animations: {
            self.frame.origin.y = screenHeight + 10
            self.faeMapCtrler?.btnCompass.frame.origin.y = 582 * screenHeightFactor
            self.faeMapCtrler?.btnLocateSelf.frame.origin.y = 582 * screenHeightFactor
            self.faeMapCtrler?.btnOpenChat.frame.origin.y = 646 * screenHeightFactor
            self.faeMapCtrler?.btnDiscovery.frame.origin.y = 646 * screenHeightFactor
            self.faeMapCtrler?.btnFilterIcon.center.y = screenHeight - 25
        })
    }
    
    func show() {
        UIView.animate(withDuration: 0.3, delay: 0, options: .curveEaseOut, animations: {
            self.frame.origin.y = screenHeight - 74
            self.faeMapCtrler?.btnCompass.frame.origin.y = 664 * screenHeightFactor
            self.faeMapCtrler?.btnLocateSelf.frame.origin.y = 664 * screenHeightFactor
            self.faeMapCtrler?.btnOpenChat.frame.origin.y = screenHeight + 10
            self.faeMapCtrler?.btnDiscovery.frame.origin.y = screenHeight + 10
            self.faeMapCtrler?.btnFilterIcon.frame.origin.y = screenHeight + 10
        })
    }
}

class FMPlaceActionBtn: UIButton {
    
    var faeMapCtrler: FaeMapViewController?
    
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
    
    func changeStyle(action style: PlacePinAction) {
        show()
        switch style {
        case .detail:
            backgroundColor = UIColor._2559180()
            setTitle("View Place Details", for: .normal)
            break
        case .collect:
            backgroundColor = UIColor._202144214()
            setTitle("Collect this Place", for: .normal)
            break
        case .route:
            backgroundColor = UIColor._144162242()
            setTitle("Draw Route to this Place", for: .normal)
            break
        case .share:
            backgroundColor = UIColor._35197143()
            setTitle("Share this Place", for: .normal)
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
