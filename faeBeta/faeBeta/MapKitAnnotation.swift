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

let mapAvatarWidth = 35

class FaePinAnnotation: MKPointAnnotation {
    
    override func isEqual(_ object: Any?) -> Bool {
        guard let rhs = object as? FaePinAnnotation else { return false }
        return self.id == rhs.id && self.type == rhs.type
    }
    
    static func ==(lhs: FaePinAnnotation, rhs: FaePinAnnotation) -> Bool {
        return lhs.isEqual(rhs)
    }
    
    // general
    var type: String!
    var id: Int = -1
    var mapViewCluster: CCHMapClusterController?
    
    // place pin & social pin
    var icon = UIImage()
    var class_2_icon_id: Int = 0
    var pinInfo: AnyObject!
    
    init(type: String) {
        super.init()
        self.type = type
    }
    
    // user pin only
    var avatar = UIImage()
    var miniAvatar: Int!
    var positions = [CLLocationCoordinate2D]()
    var count = 0
    var isValid = false {
        didSet {
            if isValid {
                self.timer?.invalidate()
                self.timer = nil
                self.timer = Timer.scheduledTimer(timeInterval: self.getRandomTime(), target: self, selector: #selector(self.changePosition), userInfo: nil, repeats: false)
            } else {
                self.count = 0
                self.timer?.invalidate()
                self.timer = nil
            }
        }
    }
    var timer: Timer?
    
    init(type: String, cluster: CCHMapClusterController, json: JSON = JSON([])) {
        super.init()
        self.mapViewCluster = cluster
        self.type = type
        if type == "place" {
            let placePin = PlacePin(json: json)
            self.pinInfo = placePin as AnyObject
            self.id = json["place_id"].intValue
            self.class_2_icon_id = json["categories"]["class2_icon_id"].intValue != 0 ? json["categories"]["class2_icon_id"].intValue : 48
            self.icon = placePin.icon ?? #imageLiteral(resourceName: "place_map_48")
            self.coordinate = placePin.coordinate
        }
        else if type == "user" {
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
            self.avatar = Mood.avatars[miniAvatar] ?? UIImage()
            self.changePosition()
            self.timer = Timer.scheduledTimer(timeInterval: getRandomTime(), target: self, selector: #selector(self.changePosition), userInfo: nil, repeats: false)
        }
    }
    
    deinit {
        self.isValid = false
    }
    
    func getRandomTime() -> Double {
        return Double.random(min: 15, max: 30)
    }
    
    // change the position of user pin given the five fake coordinates from Fae-API
    func changePosition() {
        guard self.isValid else { return }
        if self.count >= 5 {
            self.count = 0
        }
        self.mapViewCluster?.removeAnnotations([self], withCompletionHandler: {
            guard self.isValid else { return }
            if self.positions.indices.contains(self.count) {
                self.coordinate = self.positions[self.count]
            } else {
                self.count = 0
                self.timer?.invalidate()
                self.timer = nil
                self.timer = Timer.scheduledTimer(timeInterval: self.getRandomTime(), target: self, selector: #selector(self.changePosition), userInfo: nil, repeats: false)
                return
            }
            self.mapViewCluster?.addAnnotations([self], withCompletionHandler: nil)
            self.count += 1
            self.timer?.invalidate()
            self.timer = nil
            self.timer = Timer.scheduledTimer(timeInterval: self.getRandomTime(), target: self, selector: #selector(self.changePosition), userInfo: nil, repeats: false)
        })
    }
    
}

class SelfAnnotationView: MKAnnotationView {
    
    var selfIcon = UIImageView()
    var outsideCircle_1: UIImageView!
    var outsideCircle_2: UIImageView!
    var outsideCircle_3: UIImageView!
    let anchorPoint = CGPoint(x: 19, y: 19)
    
    var selfIcon_invisible: UIImageView!
    var outsideCircle_invisible: UIImageView!
    
    var boolInvisible = false
    
    var mapAvatar: Int = 1 {
        didSet {
            selfIcon.image = UIImage(named: "miniAvatar_\(mapAvatar)")
        }
    }
    
    var timer: Timer?
    
    override init(annotation: MKAnnotation?, reuseIdentifier: String?) {
        super.init(annotation: annotation, reuseIdentifier: reuseIdentifier)
        frame = CGRect(x: 0, y: 0, width: mapAvatarWidth, height: mapAvatarWidth)
        clipsToBounds = false
        layer.zPosition = 2
        loadSelfMarkerSubview()
        getSelfAccountInfo()
        NotificationCenter.default.addObserver(self, selector: #selector(self.reloadSelfMarker), name: NSNotification.Name(rawValue: "userAvatarAnimationRestart"), object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(self.changeAvatar), name: NSNotification.Name(rawValue: "changeCurrentMoodAvatar"), object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(self.invisibleMode), name: NSNotification.Name(rawValue: "invisibleMode"), object: nil)
    }
    
    deinit {
        NotificationCenter.default.removeObserver(self, name: NSNotification.Name(rawValue: "userAvatarAnimationRestart"), object: nil)
        NotificationCenter.default.removeObserver(self, name: NSNotification.Name(rawValue: "changeCurrentMoodAvatar"), object: nil)
        NotificationCenter.default.removeObserver(self, name: NSNotification.Name(rawValue: "invisibleMode"), object: nil)
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func invisibleMode() {
        if outsideCircle_1 != nil {
            outsideCircle_1.removeFromSuperview()
            outsideCircle_2.removeFromSuperview()
            outsideCircle_3.removeFromSuperview()
        }
        
        selfIcon.isHidden = true
        
        if selfIcon_invisible != nil {
            selfIcon_invisible.removeFromSuperview()
            outsideCircle_invisible.removeFromSuperview()
        }
        
        let offset_1: CGFloat = CGFloat(mapAvatarWidth - 80) / 2.0
        outsideCircle_invisible = UIImageView(frame: CGRect(x: offset_1, y: offset_1, w: 80, h: 80))
        outsideCircle_invisible.image = #imageLiteral(resourceName: "invisible_mode_outside")
        addSubview(outsideCircle_invisible)
        
        let offset_0: CGFloat = CGFloat(mapAvatarWidth - 12) / 2.0
        selfIcon_invisible = UIImageView(frame: CGRect(x: offset_0 - 3, y: offset_0 - 4.5, w: 18, h: 20))
        selfIcon_invisible.image = #imageLiteral(resourceName: "invisible_mode_inside")
        selfIcon_invisible.contentMode = .scaleAspectFit
        selfIcon_invisible.clipsToBounds = false
        selfIcon_invisible.layer.anchorPoint = CGPoint(x: 0.5, y: 0.57) // perfect
        addSubview(selfIcon_invisible)
        
        LocManager.shared.locManager.startUpdatingHeading()
        
        timer?.invalidate()
        timer = nil
        
        timer = Timer.scheduledTimer(timeInterval: 2, target: self, selector: #selector(updateHeading), userInfo: nil, repeats: true)
    }
    
    func updateHeading() {
        UIView.animate(withDuration: 0.5, animations: {
            self.selfIcon_invisible.transform = CGAffineTransform(rotationAngle: CGFloat(Double.pi * LocManager.shared.curtHeading) / 180.0)
        }, completion: nil)
    }
    
    func changeAvatar() {
        guard userStatus != 5 else { return }
        mapAvatar = userMiniAvatar
    }
    
    func getSelfAccountInfo() {
        let getSelfInfo = FaeUser()
        getSelfInfo.getAccountBasicInfo({(status: Int, message: Any?) in
            guard status / 100 == 2 else {
                self.mapAvatar = 1
                self.reloadSelfMarker()
                return
            }
            let selfUserInfoJSON = JSON(message!)
            userFirstname = selfUserInfoJSON["first_name"].stringValue
            userLastname = selfUserInfoJSON["last_name"].stringValue
            userBirthday = selfUserInfoJSON["birthday"].stringValue
            userUserGender = selfUserInfoJSON["gender"].stringValue
            userUserName = selfUserInfoJSON["user_name"].stringValue
            userMiniAvatar = selfUserInfoJSON["mini_avatar"].intValue + 1
            LocalStorageManager.shared.saveInt("userMiniAvatar", value: userMiniAvatar)
            self.mapAvatar = selfUserInfoJSON["mini_avatar"].intValue + 1
            if userStatus == 5 {
                return
            }
            self.reloadSelfMarker()
        })
    }
    
    func loadSelfMarkerSubview() {
        selfIcon = UIImageView(frame: CGRect(x: 0, y: 0, width: mapAvatarWidth, height: mapAvatarWidth))
        selfIcon.layer.zPosition = 5
        selfIcon.center = anchorPoint
        addSubview(selfIcon)
    }
    
    func reloadSelfMarker() {
        
        guard userStatus != 5 else { return }
        
        timer?.invalidate()
        timer = nil
        LocManager.shared.locManager.stopUpdatingHeading()
        
        selfIcon.isHidden = false
        
        if selfIcon_invisible != nil {
            selfIcon_invisible.removeFromSuperview()
            outsideCircle_invisible.removeFromSuperview()
        }
        
        if outsideCircle_1 != nil {
            outsideCircle_1.removeFromSuperview()
            outsideCircle_2.removeFromSuperview()
            outsideCircle_3.removeFromSuperview()
        }
        outsideCircle_1 = UIImageView(frame: CGRect(x: 0, y: 0, width: 24, height: 24))
        outsideCircle_2 = UIImageView(frame: CGRect(x: 0, y: 0, width: 24, height: 24))
        outsideCircle_3 = UIImageView(frame: CGRect(x: 0, y: 0, width: 24, height: 24))
        outsideCircle_1.layer.zPosition = 0
        outsideCircle_2.layer.zPosition = 1
        outsideCircle_3.layer.zPosition = 2
        outsideCircle_1.center = anchorPoint
        outsideCircle_2.center = anchorPoint
        outsideCircle_3.center = anchorPoint
        outsideCircle_1.isUserInteractionEnabled = false
        outsideCircle_2.isUserInteractionEnabled = false
        outsideCircle_3.isUserInteractionEnabled = false
        outsideCircle_1.image = UIImage(named: "myPosition_outside")
        outsideCircle_2.image = UIImage(named: "myPosition_outside")
        outsideCircle_3.image = UIImage(named: "myPosition_outside")
        
        addSubview(outsideCircle_3)
        addSubview(outsideCircle_2)
        addSubview(outsideCircle_1)
        
        selfMarkerAnimation()
    }
    
    func selfMarkerAnimation() {
        
        let circleWidth = 100
        let offSet = -(circleWidth - mapAvatarWidth) / 2
        
        UIView.animate(withDuration: 2.4, delay: 0, options: [.repeat, .curveEaseIn, .beginFromCurrentState], animations: ({
            if self.outsideCircle_1 != nil {
                self.outsideCircle_1.alpha = 0.0
                self.outsideCircle_1.frame = CGRect(x: offSet, y: offSet, width: circleWidth, height: circleWidth)
            }
        }), completion: nil)
        
        UIView.animate(withDuration: 2.4, delay: 0.8, options: [.repeat, .curveEaseIn, .beginFromCurrentState], animations: ({
            if self.outsideCircle_2 != nil {
                self.outsideCircle_2.alpha = 0.0
                self.outsideCircle_2.frame = CGRect(x: offSet, y: offSet, width: circleWidth, height: circleWidth)
            }
        }), completion: nil)
        
        UIView.animate(withDuration: 2.4, delay: 1.6, options: [.repeat, .curveEaseIn, .beginFromCurrentState], animations: ({
            if self.outsideCircle_3 != nil {
                self.outsideCircle_3.alpha = 0.0
                self.outsideCircle_3.frame = CGRect(x: offSet, y: offSet, width: circleWidth, height: circleWidth)
            }
        }), completion: nil)
    }
}

class UserPinAnnotationView: MKAnnotationView {
    
    var imageView: UIImageView!
    
    override init(annotation: MKAnnotation?, reuseIdentifier: String?) {
        super.init(annotation: annotation, reuseIdentifier: reuseIdentifier)
        frame = CGRect(x: 0, y: 0, width: mapAvatarWidth, height: mapAvatarWidth)
        imageView = UIImageView(frame: CGRect(x: 0, y: 0, width: mapAvatarWidth, height: mapAvatarWidth))
        addSubview(imageView)
        imageView.contentMode = .scaleAspectFit
        layer.zPosition = 1
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func assignImage(_ image: UIImage) {
        imageView.image = image
    }
}

protocol PlacePinAnnotationDelegate: class {
    func placePinAction(action: PlacePinAction)
}

enum PlacePinAction: String {
    case detail
    case collect
    case route
    case share
}

class PlacePinAnnotationView: MKAnnotationView {
    
    weak var delegate: PlacePinAnnotationDelegate?
    
    var imgIcon: UIImageView!
    
    var btnDetail: UIButton!
    var btnCollect: UIButton!
    var btnRoute: UIButton!
    var btnShare: UIButton!
    
    var arrBtns = [UIButton]()
    
    override init(annotation: MKAnnotation?, reuseIdentifier: String?) {
        super.init(annotation: annotation, reuseIdentifier: reuseIdentifier)
        frame = CGRect(x: 0, y: 0, width: 56, height: 56)
        layer.zPosition = 1
        layer.anchorPoint = CGPoint(x: 0.5, y: 1.0)
        
        imgIcon = UIImageView(frame: CGRect(x: 28, y: 56, width: 0, height: 0))
        imgIcon.contentMode = .scaleAspectFit
        imgIcon.layer.zPosition = 1
        addSubview(imgIcon)
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func assignImage(_ image: UIImage) {
        // when an image is set for the annotation view,
        // it actually adds the image to the image view
        imgIcon.image = image
    }
    
    fileprivate func loadButtons() {
        btnDetail = UIButton(frame: CGRect(x: 0, y: 43, width: 42, height: 42))
        btnDetail.setImage(#imageLiteral(resourceName: "place_new_detail"), for: .normal)
        btnDetail.alpha = 0
        btnDetail.layer.zPosition = 0
        
        btnCollect = UIButton(frame: CGRect(x: 35, y: 0, width: 42, height: 42))
        btnCollect.setImage(#imageLiteral(resourceName: "place_new_collect"), for: .normal)
        btnCollect.alpha = 0
        btnCollect.layer.zPosition = 0
        
        btnRoute = UIButton(frame: CGRect(x: 93, y: 0, width: 42, height: 42))
        btnRoute.setImage(#imageLiteral(resourceName: "place_new_route"), for: .normal)
        btnRoute.alpha = 0
        btnRoute.layer.zPosition = 0
        
        btnShare = UIButton(frame: CGRect(x: 128, y: 43, width: 42, height: 42))
        btnShare.setImage(#imageLiteral(resourceName: "place_new_share"), for: .normal)
        btnShare.alpha = 0
        btnShare.layer.zPosition = 0
        
        addSubview(btnDetail)
        addSubview(btnCollect)
        addSubview(btnRoute)
        addSubview(btnShare)
        
        arrBtns.append(btnDetail)
        arrBtns.append(btnCollect)
        arrBtns.append(btnRoute)
        arrBtns.append(btnShare)
    }
    
    fileprivate func removeButtons() {
        for btn in arrBtns {
            btn.removeTarget(nil, action: nil, for: .touchUpInside)
            btn.removeFromSuperview()
        }
        arrBtns.removeAll()
    }
    
    func showButtons() {
        loadButtons()
        var point = self.frame.origin; point.x -= 57 ;point.y -= 54
        frame = CGRect(x: point.x, y: point.y, width: 170, height: 110)
        imgIcon.center.x = 85; imgIcon.frame.origin.y = 54
        var delay: Double = 0
        for btn in arrBtns {
            btn.addTarget(self, action: #selector(self.action(_:)), for: .touchUpInside)
            btn.center = self.imgIcon.center
            UIView.animate(withDuration: 0.2, delay: delay, usingSpringWithDamping: 1, initialSpringVelocity: 0.5, options: [.curveEaseOut], animations: {
                btn.alpha = 1
                if btn == self.btnDetail { btn.frame.origin = CGPoint(x: 0, y: 43) }
                else if btn == self.btnCollect { btn.frame.origin = CGPoint(x: 35, y: 0) }
                else if btn == self.btnRoute { btn.frame.origin = CGPoint(x: 93, y: 0) }
                else if btn == self.btnShare { btn.frame.origin = CGPoint(x: 128, y: 43) }
            }, completion: nil)
            delay += 0.075
        }
    }
    
    func hideButtons() {
        UIView.animate(withDuration: 0.2, animations: {
            for btn in self.arrBtns {
                btn.alpha = 0
                btn.center = self.imgIcon.center
            }
        }, completion: { _ in
            var point = self.frame.origin; point.x += 57; point.y += 54
            self.frame = CGRect(x: point.x, y: point.y, width: 56, height: 56)
            self.imgIcon.frame.origin = CGPoint.zero
            self.removeButtons()
        })
    }
    
    func action(_ sender: UIButton) {
        if sender == btnDetail { delegate?.placePinAction(action: .detail) }
        else if sender == btnCollect { delegate?.placePinAction(action: .collect) }
        else if sender == btnRoute { delegate?.placePinAction(action: .route) }
        else if sender == btnShare { delegate?.placePinAction(action: .share) }
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
        layer.zPosition = 1
        layer.anchorPoint = CGPoint(x: 0.5, y: 1.0)
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
