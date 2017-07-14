//
//  MapKitAnnotation.swift
//  faeBeta
//
//  Created by Yue on 7/12/17.
//  Copyright © 2017 fae. All rights reserved.
//

import UIKit
import SwiftyJSON
import CCHMapClusterController
import MapKit

class FaePinAnnotation: MKPointAnnotation {
    
    // general
    var type: String!
    var id: Int = -1
    var mapViewCluster: CCHMapClusterController?
    
    // place pin & social pin
    var icon: UIImage!
    var pinInfo: AnyObject!
    
    init(type: String) {
        super.init()
        self.type = type
    }
    
    // user pin only
    var avatar: UIImage!
    var miniAvatar: Int!
    var positions = [CLLocationCoordinate2D]()
    var count = 0
    
    init(type: String, json: JSON) {
        super.init()
        self.type = type
        guard type == "user" else { return }
        self.id = json["user_id"].intValue
        self.miniAvatar = json["mini_avatar"].intValue
        guard let posArr = json["geolocation"].array else { return }
        for pos in posArr {
            let pos_i = CLLocationCoordinate2DMake(pos["latitude"].doubleValue, pos["longitude"].doubleValue)
            self.positions.append(pos_i)
        }
        self.coordinate = self.positions[self.count]
        self.count += 1
        guard Mood.avatars[miniAvatar] != nil else {
            print("[init] map avatar image is nil")
            return
        }
        self.avatar = Mood.avatars[miniAvatar]
        self.changePosition()
    }
    
    // change the position of user pin given the five fake coordinates from Fae-API
    func changePosition() {
        let time = Double.random(min: 5, max: 20)
        DispatchQueue.global(qos: .default).asyncAfter(deadline: .now() + time) {
            if self.count == 5 {
                self.count = 0
            }
            DispatchQueue.main.async { [index = self.count] in
                UIView.animate(withDuration: 0.3, animations: {
                    self.mapViewCluster?.removeAnnotations([self], withCompletionHandler: nil)
                }, completion: { _ in
                    self.coordinate = self.positions[index]
                    self.mapViewCluster?.addAnnotations([self], withCompletionHandler: nil)
                    self.count += 1
                    self.changePosition()
                })
            }
        }
    }
    
    // social pin only
    
}

class SelfAnnotationView: MKAnnotationView {
    
    var selfMarkerIcon: UIButton!
    var myPositionCircle_1: UIImageView! // Self Position Marker
    var myPositionCircle_2: UIImageView! // Self Position Marker
    var myPositionCircle_3: UIImageView! // Self Position Marker
    
    override init(annotation: MKAnnotation?, reuseIdentifier: String?) {
        super.init(annotation: annotation, reuseIdentifier: reuseIdentifier)
        frame = CGRect(x: 0, y: 0, width: 44, height: 44)
        self.clipsToBounds = false
        loadSelfMarkerSubview()
//        reloadSelfMarker()
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func assignImage(_ image: UIImage) {
        selfMarkerIcon.setImage(image, for: .normal)
    }
    
    func loadSelfMarkerSubview() {
        selfMarkerIcon = UIButton(frame: CGRect(x: 0, y: 0, width: 44, height: 44))
        selfMarkerIcon.adjustsImageWhenHighlighted = false
        selfMarkerIcon.layer.zPosition = 5
        let point = CGPoint(x: 22, y: 22)
        selfMarkerIcon.center = point
        self.addSubview(selfMarkerIcon)
    }
    
    func reloadSelfMarker() {
        if myPositionCircle_1 != nil {
            myPositionCircle_1.removeFromSuperview()
            myPositionCircle_2.removeFromSuperview()
            myPositionCircle_3.removeFromSuperview()
        }
        let point = CGPoint(x: 22, y: 22)
        myPositionCircle_1 = UIImageView(frame: CGRect(x: 0, y: 0, width: 24, height: 24))
        myPositionCircle_2 = UIImageView(frame: CGRect(x: 0, y: 0, width: 24, height: 24))
        myPositionCircle_3 = UIImageView(frame: CGRect(x: 0, y: 0, width: 24, height: 24))
        myPositionCircle_1.layer.zPosition = 0
        myPositionCircle_2.layer.zPosition = 1
        myPositionCircle_3.layer.zPosition = 2
        myPositionCircle_1.center = point
        myPositionCircle_2.center = point
        myPositionCircle_3.center = point
        myPositionCircle_1.isUserInteractionEnabled = false
        myPositionCircle_2.isUserInteractionEnabled = false
        myPositionCircle_3.isUserInteractionEnabled = false
        self.myPositionCircle_1.image = UIImage(named: "myPosition_outside")
        self.myPositionCircle_2.image = UIImage(named: "myPosition_outside")
        self.myPositionCircle_3.image = UIImage(named: "myPosition_outside")
        
        self.addSubview(myPositionCircle_3)
        self.addSubview(myPositionCircle_2)
        self.addSubview(myPositionCircle_1)
        
        selfMarkerAnimation()
    }
    
    func selfMarkerAnimation() {
        UIView.animate(withDuration: 2.4, delay: 0, options: [.repeat, .curveEaseIn], animations: ({
            if self.myPositionCircle_1 != nil {
                self.myPositionCircle_1.alpha = 0.0
                self.myPositionCircle_1.frame = CGRect(x: -38, y: -38, width: 120, height: 120)
            }
        }), completion: nil)
        
        UIView.animate(withDuration: 2.4, delay: 0.8, options: [.repeat, .curveEaseIn], animations: ({
            if self.myPositionCircle_2 != nil {
                self.myPositionCircle_2.alpha = 0.0
                self.myPositionCircle_2.frame = CGRect(x: -38, y: -38, width: 120, height: 120)
            }
        }), completion: nil)
        
        UIView.animate(withDuration: 2.4, delay: 1.6, options: [.repeat, .curveEaseIn], animations: ({
            if self.myPositionCircle_3 != nil {
                self.myPositionCircle_3.alpha = 0.0
                self.myPositionCircle_3.frame = CGRect(x: -38, y: -38, width: 120, height: 120)
            }
        }), completion: nil)
    }
}

class UserPinAnnotationView: MKAnnotationView {
    
    var imageView: UIImageView!
    
    override init(annotation: MKAnnotation?, reuseIdentifier: String?) {
        super.init(annotation: annotation, reuseIdentifier: reuseIdentifier)
        frame = CGRect(x: 0, y: 0, width: 44, height: 44)
        imageView = UIImageView(frame: CGRect(x: 0, y: 0, width: 44, height: 44))
        addSubview(imageView)
        imageView.contentMode = .scaleAspectFit
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func assignImage(_ image: UIImage) {
        imageView.image = image
    }
}

class PlacePinAnnotationView: MKAnnotationView {
    
    var imageView: UIImageView!
    
    override init(annotation: MKAnnotation?, reuseIdentifier: String?) {
        super.init(annotation: annotation, reuseIdentifier: reuseIdentifier)
        frame = CGRect(x: 0, y: 0, width: 60, height: 64)
        imageView = UIImageView(frame: CGRect(x: 30, y: 64, width: 0, height: 0))
        addSubview(imageView)
        imageView.contentMode = .scaleAspectFit
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func assignImage(_ image: UIImage) {
        // when an image is set for the annotation view,
        // it actually adds the image to the image view
        imageView.image = image
    }
}

class SocialPinAnnotationView: MKAnnotationView {
    
    var imageView: UIImageView!
    
    override init(annotation: MKAnnotation?, reuseIdentifier: String?) {
        super.init(annotation: annotation, reuseIdentifier: reuseIdentifier)
        frame = CGRect(x: 0, y: 0, width: 60, height: 61)
        imageView = UIImageView(frame: CGRect(x: 30, y: 61, width: 0, height: 0))
        addSubview(imageView)
        imageView.contentMode = .scaleAspectFit
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func assignImage(_ image: UIImage) {
        // when an image is set for the annotation view,
        // it actually adds the image to the image view
        imageView.image = image
    }
}
