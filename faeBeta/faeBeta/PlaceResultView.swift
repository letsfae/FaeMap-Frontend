//
//  PlaceResultView.swift
//  faeBeta
//
//  Created by Yue Shen on 7/27/17.
//  Copyright © 2017 fae. All rights reserved.
//

import UIKit

protocol PlaceViewDelegate: class {
    func animateTo(view: MKAnnotationView?)
    func goToNext(view: MKAnnotationView?)
    func goToPrev(view: MKAnnotationView?)
}

class PlaceResultView: UIView {
    
    weak var delegate: PlaceViewDelegate?
    
    var imgBack_0 = PlaceView()
    var imgBack_1 = PlaceView()
    var imgBack_2 = PlaceView()
    
    var offset: CGFloat = 0
    
    var boolLeft = true
    var boolRight = true
    
    var views = [MKAnnotationView]()
    
    override init(frame: CGRect = CGRect.zero) {
        super.init(frame: CGRect(x: 0, y: 70, width: screenWidth, height: 68))
        loadContent()
        let panGesture = UIPanGestureRecognizer()
        panGesture.addTarget(self, action: #selector(self.handlePanGesture(_:)))
        addGestureRecognizer(panGesture)
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func loadContent() {
        layer.zPosition = 605
        addSubview(imgBack_0)
        addSubview(imgBack_1)
        addSubview(imgBack_2)
        
        resetSubviews()
    }
    
    func resetSubviews() {
        imgBack_0.frame.origin.x = -screenWidth + 2
        imgBack_1.frame.origin.x = 0 + 2
        imgBack_2.frame.origin.x = screenWidth + 2
    }
    
    func loadingData(for index: Int, data: PlacePin, views: [MKAnnotationView]) {
        self.views = views
        //        switch index {
        //        case 0:
//        imgBack_0.imgType.image = UIImage(named: "place_result_\(data.class_two_idx)") ?? UIImage()
//        imgBack_0.lblName.text = data.name
//        imgBack_0.lblAddr.text = data.address1 + ", " + data.address2
        //            break
        //        case 1:
        imgBack_1.imgType.image = UIImage(named: "place_result_\(data.class_two_idx)") ?? UIImage()
        imgBack_1.lblName.text = data.name
        imgBack_1.lblAddr.text = data.address1 + ", " + data.address2
        //            break
        //        case 2:
//        imgBack_2.imgType.image = UIImage(named: "place_result_\(data.class_two_idx)") ?? UIImage()
//        imgBack_2.lblName.text = data.name
//        imgBack_2.lblAddr.text = data.address1 + ", " + data.address2
        //            break
        //        default:
        //            break
        //        }
    }
    
    func handlePanGesture(_ pan: UIPanGestureRecognizer) {
        let location = pan.location(in: self)
        if pan.state == .began {
            offset = location.x
        } else if pan.state == .ended || pan.state == .failed || pan.state == .cancelled {
            let percent_1 = imgBack_1.center.x / screenWidth
            if percent_1 > 0.7 && percent_1 < 1 {
                UIView.animate(withDuration: 0.3, animations: {
                    self.imgBack_0.frame.origin.x = 2
                    self.imgBack_1.frame.origin.x += screenWidth + 2
                }, completion: {_ in
                    self.delegate?.goToNext(view: self.views[0])
                    self.resetSubviews()
                })
            } else if percent_1 < 0.3 && percent_1 > 0 {
                UIView.animate(withDuration: 0.3, animations: {
                    self.imgBack_1.frame.origin.x = -screenWidth + 2
                    self.imgBack_2.frame.origin.x = 2
                }, completion: {_ in
                    self.delegate?.goToPrev(view: self.views[1])
                    self.resetSubviews()
                })
            } else {
                UIView.animate(withDuration: 0.3, animations: {
                    self.resetSubviews()
                }, completion: nil)
            }
        } else {
            let off = location.x - offset
            imgBack_1.frame.origin.x += off
            if off >= 0  {
                imgBack_0.frame.origin.x += off
            } else {
                imgBack_2.frame.origin.x += off
            }
            offset = location.x
        }
    }
}

class PlaceView: UIImageView {
    
    var class_two_idx = 0
    var imgType: UIImageView!
    var lblName: UILabel!
    var lblAddr: UILabel!
    
    override init(frame: CGRect = CGRect.zero) {
        super.init(frame: CGRect(x: 2, y: 0, w: 410, h: 80))
        loadContent()
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func loadContent() {
        contentMode = .scaleAspectFit
        image = #imageLiteral(resourceName: "placeResult_shadow")
        
        imgType = UIImageView()
        addSubview(imgType)
        addConstraintsWithFormat("H:|-15-[v0(58)]", options: [], views: imgType)
        addConstraintsWithFormat("V:|-11-[v0(58)]", options: [], views: imgType)
        
        lblName = UILabel()
        addSubview(lblName)
        lblName.textAlignment = .left
        lblName.textColor = UIColor._898989()
        lblName.font = UIFont(name: "AvenirNext-Medium", size: 15)
        addConstraintsWithFormat("H:|-83-[v0]-30-|", options: [], views: lblName)
        addConstraintsWithFormat("V:|-22-[v0(20)]", options: [], views: lblName)
        
        lblAddr = UILabel()
        addSubview(lblAddr)
        lblAddr.textAlignment = .left
        lblAddr.textColor = UIColor._107107107()
        lblAddr.font = UIFont(name: "AvenirNext-Medium", size: 12)
        addConstraintsWithFormat("H:|-83-[v0]-30-|", options: [], views: lblAddr)
        addConstraintsWithFormat("V:|-43-[v0(16)]", options: [], views: lblAddr)
    }
}
