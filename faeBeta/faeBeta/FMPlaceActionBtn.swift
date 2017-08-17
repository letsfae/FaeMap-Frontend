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
    
    func actionPlaceAction(_ sender: UIButton) {
        switch sender.tag {
        case 1:
            guard let ann = faeMapCtrler?.selectedAnn else { return }
            guard let placePin = ann.pinInfo as? PlacePin else { return }
            let vcPlaceDetail = PlaceDetailViewController()
            vcPlaceDetail.place = placePin
            faeMapCtrler?.navigationController?.pushViewController(vcPlaceDetail, animated: true)
            break
        case 2:
            guard let ann = faeMapCtrler?.selectedAnn else { return }
            guard let placePin = ann.pinInfo as? PlacePin else { return }
            let pinId = placePin.id
            let collectPlace = FaePinAction()
            collectPlace.saveThisPin("place", pinID: "\(pinId)", completion: { (status, message) in
                guard status / 100 == 2 else { return }
                self.faeMapCtrler?.selectedAnnView?.optionsToNormal(saved: true)
            })
            break
        case 3:
            break
        case 4:
            break
        default:
            break
        }
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
            tag = 1
            backgroundColor = UIColor._2559180()
            setTitle("View Place Details", for: .normal)
            break
        case .collect:
            tag = 2
            backgroundColor = UIColor._202144214()
            setTitle("Collect this Place", for: .normal)
            break
        case .route:
            tag = 3
            backgroundColor = UIColor._144162242()
            setTitle("Draw Route to this Place", for: .normal)
            break
        case .share:
            tag = 4
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
