//
//  FMPlaceActionBtn.swift
//  faeBeta
//
//  Created by Yue Shen on 8/16/17.
//  Copyright © 2017 fae. All rights reserved.
//

import UIKit

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
