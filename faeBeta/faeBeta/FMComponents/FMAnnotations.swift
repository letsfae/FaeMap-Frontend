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

let mapAvatarWidth: CGFloat = 35

class AddressAnnotation: MKPointAnnotation {
    var isStartPoint = false
}
class AddressAnnotationView: MKAnnotationView {
    
    var icon = UIImageView()
    
    override init(annotation: MKAnnotation?, reuseIdentifier: String?) {
        super.init(annotation: annotation, reuseIdentifier: reuseIdentifier)
        frame = CGRect(x: 0, y: 0, width: 48, height: 52)
        layer.zPosition = 2
        layer.anchorPoint = CGPoint(x: 0.5, y: 1)
        icon = UIImageView(frame: CGRect(x: 0, y: 0, width: 48, height: 52))
        addSubview(icon)
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}

class FaePinAnnotation: MKPointAnnotation {
    
    override func isEqual(_ object: Any?) -> Bool {
        guard let rhs = object as? FaePinAnnotation else { return false }
        return id == rhs.id && type == rhs.type
    }
    
    static func ==(lhs: FaePinAnnotation, rhs: FaePinAnnotation) -> Bool {
        return lhs.isEqual(rhs)
    }
    
    // general
    var type: String!
    var id: Int = -1
    var mapViewCluster: CCHMapClusterController?
    var animatable = true
    
    // location pin
    var address_1 = ""
    var address_2 = ""
    
    // place pin
    var icon = UIImage()
    var class_2_icon_id: Int = 48
    var pinInfo: AnyObject!
    var selected = false
    
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
    
    /// - parameter type: pin type, only 'place' and 'user' are available for now
    ///             cluster: the cluster manager passed from FaeMapViewController, default is nil
    ///             data: the data need to manage with, only PlacePin and UserPin are available for now
    init(type: String, cluster: CCHMapClusterController? = nil, data: AnyObject) {
        super.init()
        mapViewCluster = cluster
        self.type = type
        if type == "place" {
            guard let placePin = data as? PlacePin else { return }
            pinInfo = data
            id = placePin.id
            class_2_icon_id = placePin.class_2_icon_id
            icon = placePin.icon ?? #imageLiteral(resourceName: "place_map_48")
            coordinate = placePin.coordinate
        } else if type == "user" {
            guard let userPin = data as? UserPin else { return }
            id = userPin.id
            miniAvatar = userPin.miniAvatar
            positions = userPin.positions
            coordinate = positions[self.count]
            count += 1
            guard Mood.avatars[miniAvatar] != nil else {
                print("[init] map avatar image is nil")
                return
            }
            avatar = Mood.avatars[miniAvatar] ?? UIImage()
            changePosition()
            timer = Timer.scheduledTimer(timeInterval: getRandomTime(), target: self, selector: #selector(changePosition), userInfo: nil, repeats: false)
        } else if type == "location" {
            guard let position = data as? CLLocationCoordinate2D else { return }
            icon = #imageLiteral(resourceName: "location_pin")
            coordinate = position
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
        guard isValid else { return }
        if count >= 5 {
            count = 0
        }
        mapViewCluster?.removeAnnotations([self], withCompletionHandler: {
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
    
    let anchorPoint = CGPoint(x: mapAvatarWidth / 2, y: mapAvatarWidth / 2)
    var selfIcon = UIImageView()
    var img: UIImageView!
    var inner: UIImageView!
    var red: UIImageView!
    
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
        layer.zPosition = 10
        loadBasic()
        if let identifier = reuseIdentifier {
            if identifier == "self_selected_mode" {
                invisibleOn()
            } else {
                getSelfAccountInfo()
            }
        }
        NotificationCenter.default.addObserver(self, selector: #selector(invisibleOff), name: NSNotification.Name(rawValue: "invisibleMode_off"), object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(getSelfAccountInfo), name: NSNotification.Name(rawValue: "reloadUser&MapInfo"), object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(changeAvatar), name: NSNotification.Name(rawValue: "changeCurrentMoodAvatar"), object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(invisibleOn), name: NSNotification.Name(rawValue: "invisibleMode_on"), object: nil)
    }
    
    deinit {
        NotificationCenter.default.removeObserver(self, name: NSNotification.Name(rawValue: "invisibleMode_off"), object: nil)
        NotificationCenter.default.removeObserver(self, name: NSNotification.Name(rawValue: "reloadUser&MapInfo"), object: nil)
        NotificationCenter.default.removeObserver(self, name: NSNotification.Name(rawValue: "changeCurrentMoodAvatar"), object: nil)
        NotificationCenter.default.removeObserver(self, name: NSNotification.Name(rawValue: "invisibleMode_on"), object: nil)
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func loadBasic() {
        let offSet_0: CGFloat = CGFloat(mapAvatarWidth / 2)
        
        img = UIImageView(frame: CGRect(x: offSet_0, y: offSet_0, width: 0, height: 0))
        img.image = #imageLiteral(resourceName: "outside_circle")
        img.alpha = 0.6
        addSubview(img)
        img.isHidden = true
        
        inner = UIImageView(frame: CGRect(x: 0, y: 0, width: 29, height: 34))
        inner.center = CGPoint(x: offSet_0, y: offSet_0)
        inner.image = #imageLiteral(resourceName: "inner_icon")
        inner.layer.anchorPoint = CGPoint(x: 0.5, y: 0.60294)
        addSubview(inner)
        inner.isHidden = true
        
        red = UIImageView(frame: CGRect(x: 0, y: 0, width: 12.5, height: 12.5))
        red.center = CGPoint(x: offSet_0, y: offSet_0)
        red.image = #imageLiteral(resourceName: "inside_circle")
        red.alpha = 0.9
        addSubview(red)
        red.isHidden = true
        
        selfIcon = UIImageView(frame: CGRect(x: 0, y: 0, width: mapAvatarWidth, height: mapAvatarWidth))
        selfIcon.layer.zPosition = 5
        selfIcon.center = anchorPoint
        addSubview(selfIcon)
        
        animations()
    }
    
    func invisibleOn() {
        LocManager.shared.locManager.startUpdatingHeading()
        timer?.invalidate()
        timer = nil
        timer = Timer.scheduledTimer(timeInterval: 2, target: self, selector: #selector(updateHeading), userInfo: nil, repeats: true)
        selfIcon.isHidden = true
        inner.isHidden = false
        red.isHidden = false
        img.isHidden = false
    }
    
    func invisibleOff() {
        guard userStatus != 5 else { return }
        LocManager.shared.locManager.stopUpdatingHeading()
        timer?.invalidate()
        timer = nil
        selfIcon.isHidden = false
        inner.isHidden = true
        red.isHidden = true
        img.isHidden = false
    }
    
    func updateHeading() {
        UIView.animate(withDuration: 0.5, animations: {
            self.inner.transform = CGAffineTransform(rotationAngle: CGFloat(Double.pi * LocManager.shared.curtHeading) / 180.0)
        }, completion: nil)
    }
    
    func changeAvatar() {
        guard userStatus != 5 else { return }
        mapAvatar = userMiniAvatar
    }
    
    func getSelfAccountInfo() {
        let getSelfInfo = FaeUser()
        getSelfInfo.getAccountBasicInfo({ (status: Int, message: Any?) in
            guard status / 100 == 2 else {
                self.mapAvatar = 1
                self.invisibleOff()
                return
            }
            let selfUserInfoJSON = JSON(message!)
            userFirstname = selfUserInfoJSON["first_name"].stringValue
            userLastname = selfUserInfoJSON["last_name"].stringValue
            userBirthday = selfUserInfoJSON["birthday"].stringValue
            Key.shared.gender = selfUserInfoJSON["gender"].stringValue
            Key.shared.username = selfUserInfoJSON["user_name"].stringValue
            userMiniAvatar = selfUserInfoJSON["mini_avatar"].intValue + 1
            LocalStorageManager.shared.saveInt("userMiniAvatar", value: userMiniAvatar)
            self.mapAvatar = selfUserInfoJSON["mini_avatar"].intValue + 1
            if userStatus == 5 {
                return
            }
            self.invisibleOff()
        })
    }
    
    func animations() {
        let circleWidth: CGFloat = 120
        let offSet: CGFloat = CGFloat(-(circleWidth - mapAvatarWidth) / 2)
        let offSet_0: CGFloat = CGFloat(mapAvatarWidth / 2)
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.6) {
            self.img.frame = CGRect(x: offSet_0, y: offSet_0, width: 0, height: 0)
            self.img.alpha = 0.8
            self.red.frame = CGRect(x: offSet_0 - 6.25, y: offSet_0 - 6.25, width: 12.5, height: 12.5)
            self.red.alpha = 0.9
            
            UIView.animate(withDuration: 0.75, delay: 0, options: [.curveEaseOut], animations: {
                self.red.frame = CGRect(x: offSet_0 - 7.5, y: offSet_0 - 7.5, width: 15, height: 15)
                self.red.alpha = 1
            }, completion: nil)
            
            UIView.animate(withDuration: 2.25, delay: 0.25, options: [.curveEaseOut], animations: {
                self.img.frame = CGRect(x: offSet, y: offSet, width: circleWidth, height: circleWidth)
                self.img.alpha = 0
            }, completion: { _ in
                self.animations()
            })
            UIView.animate(withDuration: 1, delay: 2, options: [.curveEaseOut], animations: {
                self.red.frame = CGRect(x: offSet_0 - 6.25, y: offSet_0 - 6.25, width: 12.5, height: 12.5)
                self.red.alpha = 0.9
            }, completion: nil)
        }
    }
    
    var selfIcon_invisible: UIImageView!
    var outsideCircle_1: UIImageView!
    var outsideCircle_2: UIImageView!
    var outsideCircle_3: UIImageView!
    
    func outsideCircleAnimation() {
        
        if outsideCircle_1 != nil {
            outsideCircle_1.removeFromSuperview()
            outsideCircle_2.removeFromSuperview()
            outsideCircle_3.removeFromSuperview()
        }
        
        let initWidth: CGFloat = 20
        
        outsideCircle_1 = UIImageView(frame: CGRect(x: 0, y: 0, width: initWidth, height: initWidth))
        outsideCircle_2 = UIImageView(frame: CGRect(x: 0, y: 0, width: initWidth, height: initWidth))
        outsideCircle_3 = UIImageView(frame: CGRect(x: 0, y: 0, width: initWidth, height: initWidth))
        outsideCircle_1.layer.zPosition = 0
        outsideCircle_2.layer.zPosition = 1
        outsideCircle_3.layer.zPosition = 2
        outsideCircle_1.center = anchorPoint
        outsideCircle_2.center = anchorPoint
        outsideCircle_3.center = anchorPoint
        outsideCircle_1.isUserInteractionEnabled = false
        outsideCircle_2.isUserInteractionEnabled = false
        outsideCircle_3.isUserInteractionEnabled = false
        outsideCircle_1.image = #imageLiteral(resourceName: "myPosition_outside")
        outsideCircle_2.image = #imageLiteral(resourceName: "myPosition_outside")
        outsideCircle_3.image = #imageLiteral(resourceName: "myPosition_outside")
        
        addSubview(outsideCircle_3)
        addSubview(outsideCircle_2)
        addSubview(outsideCircle_1)
        
        let circleWidth: CGFloat = 100
        let offSet: CGFloat = -(circleWidth - mapAvatarWidth) / 2
        
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
        isEnabled = false
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
    
    var optionsReady = false
    var optionsOpened = false
    var optionsOpeing = false
    
    var imgCollected: UIImageView!
    
    override init(annotation: MKAnnotation?, reuseIdentifier: String?) {
        super.init(annotation: annotation, reuseIdentifier: reuseIdentifier)
        frame = CGRect(x: 0, y: 0, width: 56, height: 56)
        layer.zPosition = 1
        layer.anchorPoint = CGPoint(x: 0.5, y: 1.0)
        isEnabled = false
        
        imgIcon = UIImageView(frame: CGRect(x: 28, y: 56, width: 0, height: 0))
        imgIcon.contentMode = .scaleAspectFit
        addSubview(imgIcon)
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func assignImage(_ image: UIImage) {
        imgIcon.image = image
    }
    
    fileprivate func loadButtons() {
        btnDetail = UIButton(frame: CGRect(x: 0, y: 43, width: 46, height: 46))
        btnDetail.setImage(#imageLiteral(resourceName: "place_new_detail"), for: .normal)
        btnDetail.setImage(#imageLiteral(resourceName: "place_new_detail_s"), for: .selected)
        btnDetail.alpha = 0
        
        btnCollect = UIButton(frame: CGRect(x: 35, y: 0, width: 46, height: 46))
        btnCollect.setImage(#imageLiteral(resourceName: "place_new_collect"), for: .normal)
        btnCollect.setImage(#imageLiteral(resourceName: "place_new_collect_s"), for: .selected)
        btnCollect.alpha = 0
        imgCollected = UIImageView(frame: CGRect(x: 36, y: 10, width: 0, height: 0))
        imgCollected.image = #imageLiteral(resourceName: "place_new_collected")
        imgCollected.alpha = 0
        btnCollect.addSubview(imgCollected)
        
        btnRoute = UIButton(frame: CGRect(x: 93, y: 0, width: 46, height: 46))
        btnRoute.setImage(#imageLiteral(resourceName: "place_new_route"), for: .normal)
        btnRoute.setImage(#imageLiteral(resourceName: "place_new_route_s"), for: .selected)
        btnRoute.alpha = 0
        
        btnShare = UIButton(frame: CGRect(x: 128, y: 43, width: 46, height: 46))
        btnShare.setImage(#imageLiteral(resourceName: "place_new_share"), for: .normal)
        btnShare.setImage(#imageLiteral(resourceName: "place_new_share_s"), for: .selected)
        btnShare.alpha = 0
        
        layer.zPosition = 2
        imgIcon.layer.zPosition = 2
        btnDetail.layer.zPosition = 2
        btnCollect.layer.zPosition = 2
        btnRoute.layer.zPosition = 2
        btnShare.layer.zPosition = 2
        
        addSubview(btnDetail)
        addSubview(btnCollect)
        addSubview(btnRoute)
        addSubview(btnShare)
        bringSubview(toFront: btnDetail)
        bringSubview(toFront: btnCollect)
        bringSubview(toFront: btnRoute)
        bringSubview(toFront: btnShare)
        bringSubview(toFront: imgIcon)
        superview?.bringSubview(toFront: self)
        
        arrBtns.append(btnDetail)
        arrBtns.append(btnCollect)
        arrBtns.append(btnRoute)
        arrBtns.append(btnShare)
    }
    
    func showButtons() {
        guard arrBtns.count == 0 else { return }
        optionsReady = true
        optionsOpeing = true
        loadButtons()
        var point = frame.origin; point.x -= 59; point.y -= 56
        frame = CGRect(x: point.x, y: point.y, width: 174, height: 112)
        imgIcon.center.x = 87; imgIcon.frame.origin.y = 56
        var delay: Double = 0
        for btn in arrBtns {
            btn.addTarget(self, action: #selector(action(_:animated:)), for: .touchUpInside)
            btn.center = imgIcon.center
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
        guard arrBtns.count == 4 else { return }
        UIView.animate(withDuration: 0.2, animations: {
            for btn in self.arrBtns {
                btn.alpha = 0
                btn.center = self.imgIcon.center
            }
        }, completion: { _ in
            var point = self.frame.origin; point.x += 59; point.y += 56
            self.frame = CGRect(x: point.x, y: point.y, width: 56, height: 56)
            self.imgIcon.frame.origin = CGPoint.zero
            self.imgIcon.layer.zPosition = 1
            self.layer.zPosition = 1
            self.removeButtons()
        })
    }
    
    fileprivate func removeButtons() {
        for btn in arrBtns {
            btn.layer.zPosition = 1
            btn.removeTarget(nil, action: nil, for: .touchUpInside)
            btn.removeFromSuperview()
        }
        arrBtns.removeAll()
    }
    
    func optionsToNormal() {
        guard arrBtns.count == 4 else { return }
        UIView.animate(withDuration: 0.2, delay: 0, options: .curveEaseOut, animations: {
            self.btnDetail.frame.origin = CGPoint(x: 0, y: 43)
            self.btnCollect.frame.origin = CGPoint(x: 35, y: 0)
            self.btnRoute.frame.origin = CGPoint(x: 93, y: 0)
            self.btnShare.frame.origin = CGPoint(x: 128, y: 43)
            for btn in self.arrBtns {
                btn.isSelected = false
                btn.frame.size = CGSize(width: 46, height: 46)
            }
        }, completion: nil)
    }
    
    func showCollectedNoti() {
        UIView.animate(withDuration: 0.2, delay: 0, options: .curveEaseOut, animations: {
            self.imgCollected.frame = CGRect(x: 27, y: 1, width: 18, height: 18)
            self.imgCollected.alpha = 1
        }, completion: nil)
    }
    
    func action(_ sender: UIButton, animated: Bool = false) {
        
        guard animated else { chooseAction(sender); return }
        
        btnDetail.isSelected = sender == btnDetail
        btnCollect.isSelected = sender == btnCollect
        btnRoute.isSelected = sender == btnRoute
        btnShare.isSelected = sender == btnShare
        
        UIView.animate(withDuration: 0.2, delay: 0, options: .curveEaseOut, animations: {
            for btn in self.arrBtns {
                if btn == sender {
                    btn.frame.size = CGSize(width: 52, height: 52)
                } else {
                    btn.frame.size = CGSize(width: 46, height: 46)
                }
            }
            if sender == self.btnDetail {
                sender.frame.origin = CGPoint(x: -3, y: 40)
                self.btnCollect.frame.origin = CGPoint(x: 45, y: 0)
                self.btnRoute.frame.origin = CGPoint(x: 103, y: 0)
                self.btnShare.frame.origin = CGPoint(x: 128, y: 53)
            } else if sender == self.btnCollect {
                sender.frame.origin = CGPoint(x: 32, y: -3)
                self.btnDetail.frame.origin = CGPoint(x: 0, y: 53)
                self.btnRoute.frame.origin = CGPoint(x: 103, y: 0)
                self.btnShare.frame.origin = CGPoint(x: 128, y: 50)
            } else if sender == self.btnRoute {
                sender.frame.origin = CGPoint(x: 90, y: -3)
                self.btnDetail.frame.origin = CGPoint(x: 0, y: 50)
                self.btnCollect.frame.origin = CGPoint(x: 28, y: 0)
                self.btnShare.frame.origin = CGPoint(x: 128, y: 53)
            } else if sender == self.btnShare {
                sender.frame.origin = CGPoint(x: 125, y: 40)
                self.btnDetail.frame.origin = CGPoint(x: 0, y: 53)
                self.btnCollect.frame.origin = CGPoint(x: 25, y: 0)
                self.btnRoute.frame.origin = CGPoint(x: 83, y: 0)
            }
        }, completion: nil)
    }
    
    func chooseAction(_ sender: UIButton = UIButton()) {
        guard arrBtns.count == 4 else { return }
        if btnDetail.isSelected || sender == btnDetail {
            delegate?.placePinAction(action: .detail)
        } else if btnCollect.isSelected || sender == btnCollect {
            delegate?.placePinAction(action: .collect)
        } else if btnRoute.isSelected || sender == btnRoute {
            delegate?.placePinAction(action: .route)
        } else if btnShare.isSelected || sender == btnShare {
            delegate?.placePinAction(action: .share)
        }
    }
}

class LocPinAnnotationView: MKAnnotationView {
    
    weak var delegate: PlacePinAnnotationDelegate?
    
    var imgIcon: UIImageView!
    
    var btnDetail: UIButton!
    var btnCollect: UIButton!
    var btnRoute: UIButton!
    var btnShare: UIButton!
    var arrBtns = [UIButton]()
    
    var optionsReady = false
    var optionsOpened = false
    var optionsOpeing = false
    
    var imgCollected: UIImageView!
    
    override init(annotation: MKAnnotation?, reuseIdentifier: String?) {
        super.init(annotation: annotation, reuseIdentifier: reuseIdentifier)
        frame = CGRect(x: 0, y: 0, width: 56, height: 56)
        layer.zPosition = 1
        layer.anchorPoint = CGPoint(x: 0.5, y: 1.0)
        isEnabled = false
        
        imgIcon = UIImageView(frame: CGRect(x: 28, y: 56, width: 0, height: 0))
        imgIcon.contentMode = .scaleAspectFit
        addSubview(imgIcon)
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func assignImage(_ image: UIImage) {
        imgIcon.image = image
    }
    
    fileprivate func loadButtons() {
        btnDetail = UIButton(frame: CGRect(x: 0, y: 43, width: 46, height: 46))
        btnDetail.setImage(#imageLiteral(resourceName: "place_new_detail"), for: .normal)
        btnDetail.setImage(#imageLiteral(resourceName: "place_new_detail_s"), for: .selected)
        btnDetail.alpha = 0
        
        btnCollect = UIButton(frame: CGRect(x: 35, y: 0, width: 46, height: 46))
        btnCollect.setImage(#imageLiteral(resourceName: "place_new_collect"), for: .normal)
        btnCollect.setImage(#imageLiteral(resourceName: "place_new_collect_s"), for: .selected)
        btnCollect.alpha = 0
        imgCollected = UIImageView(frame: CGRect(x: 36, y: 10, width: 0, height: 0))
        imgCollected.image = #imageLiteral(resourceName: "place_new_collected")
        imgCollected.alpha = 0
        btnCollect.addSubview(imgCollected)
        
        btnRoute = UIButton(frame: CGRect(x: 93, y: 0, width: 46, height: 46))
        btnRoute.setImage(#imageLiteral(resourceName: "place_new_route"), for: .normal)
        btnRoute.setImage(#imageLiteral(resourceName: "place_new_route_s"), for: .selected)
        btnRoute.alpha = 0
        
        btnShare = UIButton(frame: CGRect(x: 128, y: 43, width: 46, height: 46))
        btnShare.setImage(#imageLiteral(resourceName: "place_new_share"), for: .normal)
        btnShare.setImage(#imageLiteral(resourceName: "place_new_share_s"), for: .selected)
        btnShare.alpha = 0
        
        layer.zPosition = 2
        imgIcon.layer.zPosition = 2
        btnDetail.layer.zPosition = 2
        btnCollect.layer.zPosition = 2
        btnRoute.layer.zPosition = 2
        btnShare.layer.zPosition = 2
        
        addSubview(btnDetail)
        addSubview(btnCollect)
        addSubview(btnRoute)
        addSubview(btnShare)
        bringSubview(toFront: btnDetail)
        bringSubview(toFront: btnCollect)
        bringSubview(toFront: btnRoute)
        bringSubview(toFront: btnShare)
        bringSubview(toFront: imgIcon)
        superview?.bringSubview(toFront: self)
        
        arrBtns.append(btnDetail)
        arrBtns.append(btnCollect)
        arrBtns.append(btnRoute)
        arrBtns.append(btnShare)
    }
    
    func showButtons() {
        guard arrBtns.count == 0 else { return }
        optionsReady = true
        optionsOpeing = true
        loadButtons()
        var point = frame.origin; point.x -= 59; point.y -= 56
        frame = CGRect(x: point.x, y: point.y, width: 174, height: 112)
        imgIcon.center.x = 87; imgIcon.frame.origin.y = 56
        var delay: Double = 0
        for btn in arrBtns {
            btn.addTarget(self, action: #selector(action(_:animated:)), for: .touchUpInside)
            btn.center = imgIcon.center
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
        guard arrBtns.count == 4 else { return }
        UIView.animate(withDuration: 0.2, animations: {
            for btn in self.arrBtns {
                btn.alpha = 0
                btn.center = self.imgIcon.center
            }
        }, completion: { _ in
            var point = self.frame.origin; point.x += 59; point.y += 56
            self.frame = CGRect(x: point.x, y: point.y, width: 56, height: 56)
            self.imgIcon.frame.origin = CGPoint.zero
            self.imgIcon.layer.zPosition = 1
            self.layer.zPosition = 1
            self.removeButtons()
        })
    }
    
    fileprivate func removeButtons() {
        for btn in arrBtns {
            btn.layer.zPosition = 1
            btn.removeTarget(nil, action: nil, for: .touchUpInside)
            btn.removeFromSuperview()
        }
        arrBtns.removeAll()
    }
    
    func optionsToNormal() {
        guard arrBtns.count == 4 else { return }
        UIView.animate(withDuration: 0.2, delay: 0, options: .curveEaseOut, animations: {
            self.btnDetail.frame.origin = CGPoint(x: 0, y: 43)
            self.btnCollect.frame.origin = CGPoint(x: 35, y: 0)
            self.btnRoute.frame.origin = CGPoint(x: 93, y: 0)
            self.btnShare.frame.origin = CGPoint(x: 128, y: 43)
            for btn in self.arrBtns {
                btn.isSelected = false
                btn.frame.size = CGSize(width: 46, height: 46)
            }
        }, completion: nil)
    }
    
    func showCollectedNoti() {
        UIView.animate(withDuration: 0.2, delay: 0, options: .curveEaseOut, animations: {
            self.imgCollected.frame = CGRect(x: 27, y: 1, width: 18, height: 18)
            self.imgCollected.alpha = 1
        }, completion: nil)
    }
    
    func action(_ sender: UIButton, animated: Bool = false) {
        
        guard animated else { chooseAction(sender); return }
        
        btnDetail.isSelected = sender == btnDetail
        btnCollect.isSelected = sender == btnCollect
        btnRoute.isSelected = sender == btnRoute
        btnShare.isSelected = sender == btnShare
        
        UIView.animate(withDuration: 0.2, delay: 0, options: .curveEaseOut, animations: {
            for btn in self.arrBtns {
                if btn == sender {
                    btn.frame.size = CGSize(width: 52, height: 52)
                } else {
                    btn.frame.size = CGSize(width: 46, height: 46)
                }
            }
            if sender == self.btnDetail {
                sender.frame.origin = CGPoint(x: -3, y: 40)
                self.btnCollect.frame.origin = CGPoint(x: 45, y: 0)
                self.btnRoute.frame.origin = CGPoint(x: 103, y: 0)
                self.btnShare.frame.origin = CGPoint(x: 128, y: 53)
            } else if sender == self.btnCollect {
                sender.frame.origin = CGPoint(x: 32, y: -3)
                self.btnDetail.frame.origin = CGPoint(x: 0, y: 53)
                self.btnRoute.frame.origin = CGPoint(x: 103, y: 0)
                self.btnShare.frame.origin = CGPoint(x: 128, y: 50)
            } else if sender == self.btnRoute {
                sender.frame.origin = CGPoint(x: 90, y: -3)
                self.btnDetail.frame.origin = CGPoint(x: 0, y: 50)
                self.btnCollect.frame.origin = CGPoint(x: 28, y: 0)
                self.btnShare.frame.origin = CGPoint(x: 128, y: 53)
            } else if sender == self.btnShare {
                sender.frame.origin = CGPoint(x: 125, y: 40)
                self.btnDetail.frame.origin = CGPoint(x: 0, y: 53)
                self.btnCollect.frame.origin = CGPoint(x: 25, y: 0)
                self.btnRoute.frame.origin = CGPoint(x: 83, y: 0)
            }
        }, completion: nil)
    }
    
    func chooseAction(_ sender: UIButton = UIButton()) {
        guard arrBtns.count == 4 else { return }
        if btnDetail.isSelected || sender == btnDetail {
            delegate?.placePinAction(action: .detail)
        } else if btnCollect.isSelected || sender == btnCollect {
            delegate?.placePinAction(action: .collect)
        } else if btnRoute.isSelected || sender == btnRoute {
            delegate?.placePinAction(action: .route)
        } else if btnShare.isSelected || sender == btnShare {
            delegate?.placePinAction(action: .share)
        }
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
