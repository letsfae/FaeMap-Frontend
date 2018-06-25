//
//  MapKitAnnotation.swift
//  faeBeta
//
//  Created by Yue on 7/12/17.
//  Copyright © 2017 fae. All rights reserved.
//

import UIKit
import SwiftyJSON
//import CCHMapClusterController
import MapKit

let mapAvatarWidth: CGFloat = 35

class AddressAnnotation: MKPointAnnotation {
    var isStartPoint = false
}

class AddressAnnotationView: MKAnnotationView {
    
    private var icon = UIImageView()
    
    override init(annotation: MKAnnotation?, reuseIdentifier: String?) {
        super.init(annotation: annotation, reuseIdentifier: reuseIdentifier)
        frame = CGRect(x: 0, y: 0, width: 48, height: 52)
        layer.anchorPoint = CGPoint(x: 0.5, y: 1)
        icon = UIImageView(frame: CGRect(x: 0, y: 0, width: 48, height: 52))
        addSubview(icon)
        icon.contentMode = .scaleAspectFit
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
    
    public func assignImage(_ image: UIImage) {
        icon.image = image
    }
}

enum FaePinType: String {
    case none
    case user
    case place
    case location
}

@objc class FaePinAnnotation: MKPointAnnotation {
    
    override func isEqual(_ object: Any?) -> Bool {
        guard let rhs = object as? FaePinAnnotation else { return false }
        return id == rhs.id && type == rhs.type
    }
    
    static func ==(lhs: FaePinAnnotation, rhs: FaePinAnnotation) -> Bool {
        return lhs.isEqual(rhs)
    }
    
    // general
    var type: FaePinType = .none
    var id: Int = -1
    private var mapViewCluster: CCHMapClusterController?
    public var animatable = true
    public var isSelected = false
    
    // location pin
    var address_1 = ""
    var address_2 = ""
    
    // place pin
    var icon = UIImage()
    var category_icon_id: Int = 48
    var pinInfo: AnyObject!
    private var selected = false
    
    // user pin only
    var avatar = UIImage()
    private var miniAvatar: Int!
    var positions = [CLLocationCoordinate2D]()
    private var count = 0
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
    private var timer: Timer?
    
    /// - parameter type: pin type, only 'place' and 'user' are available for now
    ///             cluster: the cluster manager passed from FaeMapViewController, default is nil
    ///             data: the data need to manage with, only PlacePin and UserPin are available for now
    init(type: FaePinType, cluster: CCHMapClusterController? = nil, data: AnyObject) {
        super.init()
        mapViewCluster = cluster
        self.type = type
        self.pinInfo = data
        switch type {
        case .user:
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
        case .place:
            guard let placePin = data as? PlacePin else { return }
            id = placePin.id
            category_icon_id = placePin.category_icon_id
            icon = placePin.icon ?? #imageLiteral(resourceName: "place_map_48")
            coordinate = placePin.coordinate
        case .location:
            guard let pin = data as? LocationPin else { return }
            id = pin.id
            coordinate = pin.coordinate
            icon = #imageLiteral(resourceName: "icon_startpoint")
        default:
            break
        }
    }
    
    deinit {
        self.isValid = false
    }
    
    private func getRandomTime() -> Double {
        return Double.random(min: 15, max: 30)
    }
    
    // change the position of user pin given the five fake coordinates from Fae-API
    @objc private func changePosition() {
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
    
    private let anchorPoint = CGPoint(x: mapAvatarWidth / 2, y: mapAvatarWidth / 2)
    private var selfIcon = UIImageView()
    private var img: UIImageView!
    private var inner: UIImageView!
    private var red: UIImageView!
    
    var mapAvatar: Int = 1 {
        didSet {
            selfIcon.image = UIImage(named: "miniAvatar_\(mapAvatar)")
        }
    }
    
    private var timer: Timer?
    
    override init(annotation: MKAnnotation?, reuseIdentifier: String?) {
        super.init(annotation: annotation, reuseIdentifier: reuseIdentifier)
        frame = CGRect(x: 0, y: 0, width: mapAvatarWidth, height: mapAvatarWidth)
        clipsToBounds = false
        layer.zPosition = 149
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
        
        self.layer.addObserver(self, forKeyPath: "zPosition", options: NSKeyValueObservingOptions(rawValue: 0), context: nil)
    }
    
    deinit {
        NotificationCenter.default.removeObserver(self, name: NSNotification.Name(rawValue: "invisibleMode_off"), object: nil)
        NotificationCenter.default.removeObserver(self, name: NSNotification.Name(rawValue: "reloadUser&MapInfo"), object: nil)
        NotificationCenter.default.removeObserver(self, name: NSNotification.Name(rawValue: "changeCurrentMoodAvatar"), object: nil)
        NotificationCenter.default.removeObserver(self, name: NSNotification.Name(rawValue: "invisibleMode_on"), object: nil)
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
    
    override func observeValue(forKeyPath keyPath: String?, of object: Any?, change: [NSKeyValueChangeKey : Any]?, context: UnsafeMutableRawPointer?) {
        if object is CALayer {
            self.layer.zPosition = 149
        }
    }
    
    private func loadBasic() {
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
    
    @objc func invisibleOn() {
        LocManager.shared.locManager.startUpdatingHeading()
        timer?.invalidate()
        timer = nil
        timer = Timer.scheduledTimer(timeInterval: 2, target: self, selector: #selector(updateHeading), userInfo: nil, repeats: true)
        selfIcon.isHidden = true
        inner.isHidden = false
        red.isHidden = false
        img.isHidden = false
    }
    
    @objc private func invisibleOff() {
        guard Key.shared.onlineStatus != 5 else { return }
        LocManager.shared.locManager.stopUpdatingHeading()
        timer?.invalidate()
        timer = nil
        selfIcon.isHidden = false
        inner.isHidden = true
        red.isHidden = true
        img.isHidden = false
    }
    
    @objc private func updateHeading() {
        UIView.animate(withDuration: 0.5, animations: {
            self.inner.transform = CGAffineTransform(rotationAngle: CGFloat(Double.pi * LocManager.shared.curtHeading) / 180.0)
        }, completion: nil)
    }
    
    @objc func changeAvatar() {
        guard Key.shared.onlineStatus != 5 else { return }
        mapAvatar = Key.shared.userMiniAvatar
    }
    
    @objc private func getSelfAccountInfo() {
        let getSelfInfo = FaeUser()
        getSelfInfo.getAccountBasicInfo({ [weak self] (status, message) in
            guard let `self` = self else { return }
            guard status / 100 == 2 else {
                self.mapAvatar = 1
                self.invisibleOff()
                return
            }
            self.mapAvatar = Key.shared.userMiniAvatar
            if Key.shared.onlineStatus == 5 { return }
            self.invisibleOff()
        })
    }
    
    private func animations() {
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
}

class UserPinAnnotationView: MKAnnotationView {
    
    private var imageView: UIImageView!
    
    override init(annotation: MKAnnotation?, reuseIdentifier: String?) {
        super.init(annotation: annotation, reuseIdentifier: reuseIdentifier)
        frame = CGRect(x: 0, y: 0, width: mapAvatarWidth, height: mapAvatarWidth)
        imageView = UIImageView(frame: CGRect(x: 0, y: 0, width: mapAvatarWidth, height: mapAvatarWidth))
        addSubview(imageView)
        imageView.contentMode = .scaleAspectFit
        isEnabled = false
        layer.zPosition = 99
        
        //layer.borderColor = UIColor.black.cgColor
        //layer.borderWidth = 1
        self.layer.addObserver(self, forKeyPath: "zPosition", options: NSKeyValueObservingOptions(rawValue: 0), context: nil)
    }
    
    override func observeValue(forKeyPath keyPath: String?, of object: Any?, change: [NSKeyValueChangeKey : Any]?, context: UnsafeMutableRawPointer?) {
        if object is CALayer {
            self.layer.zPosition = 99
        }
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
    
    public func assignImage(_ image: UIImage) {
        imageView.image = image
    }
}

protocol PlacePinAnnotationDelegate: class {
    func placePinAction(action: PlacePinAction, mode: CollectionTableMode)
}

enum PlacePinAction: Int {
    case detail = 1
    case collect = 2
    case route = 3
    case share = 4
}

class PlacePinAnnotationView: MKAnnotationView {
    
    weak var delegate: PlacePinAnnotationDelegate?
    
    var imgIcon: UIImageView!
    
    var btnDetail: UIButton!
    var btnCollect: UIButton!
    var btnRoute: UIButton!
    var btnShare: UIButton!
    var arrBtns = [UIButton]()
    
    public var optionsReady = false
    public var optionsOpened = false
    public var optionsOpeing = false
    
    private var imgSaved: UIImageView!
    
    public var boolShowSavedNoti = false {
        didSet {
            guard optionsOpened else { return }
            guard imgSaved != nil else { return }
            guard boolShowSavedNoti else { return }
            self.showSavedNoti()
        }
    }
    
    var iconIndex = -1
    
    public var zPos: CGFloat = 7.0 {
        didSet {
            self.layer.zPosition = zPos
        }
    }
    
    override init(annotation: MKAnnotation?, reuseIdentifier: String?) {
        super.init(annotation: annotation, reuseIdentifier: reuseIdentifier)
        frame = CGRect(x: 0, y: 0, width: 56 - 16, height: 56 - 10)
        layer.anchorPoint = CGPoint(x: 0.5, y: 1.0)
        isEnabled = false
        boolShowSavedNoti = false
        
        layer.zPosition = 7.0
        
        imgIcon = UIImageView(frame: CGRect(x: 28 - 8, y: 56 - 10, width: 0, height: 0))
        imgIcon.contentMode = .scaleAspectFit
        addSubview(imgIcon)
        
        //layer.borderColor = UIColor.black.cgColor
        //layer.borderWidth = 1
        
        NotificationCenter.default.addObserver(self, selector: #selector(showSavedNoti), name: NSNotification.Name(rawValue: "showSavedNoti_place"), object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(hideSavedNoti), name: NSNotification.Name(rawValue: "hideSavedNoti_place"), object: nil)
        
        self.layer.addObserver(self, forKeyPath: "zPosition", options: NSKeyValueObservingOptions(rawValue: 0), context: nil)
    }
    
    deinit {
        NotificationCenter.default.removeObserver(self, name: NSNotification.Name(rawValue: "showSavedNoti_place"), object: nil)
        NotificationCenter.default.removeObserver(self, name: NSNotification.Name(rawValue: "hideSavedNoti_place"), object: nil)
    }
    
    @objc private func showSavedNoti() {
        guard imgSaved != nil else { return }
        guard arrBtns.count == 4 else { return }
        UIView.animate(withDuration: 0.2, delay: 0, options: .curveEaseOut, animations: {
            self.imgSaved.frame = CGRect(x: 27, y: 1, width: 18, height: 18)
            self.imgSaved.alpha = 1
        }, completion: nil)
    }
    
    @objc private func hideSavedNoti() {
        guard imgSaved != nil else { return }
        guard arrBtns.count == 4 else { return }
        UIView.animate(withDuration: 0.2, delay: 0, options: .curveEaseOut, animations: {
            self.imgSaved.frame = CGRect(x: 36, y: 10, width: 0, height: 0)
            self.imgSaved.alpha = 0
        }, completion: nil)
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
    
    override func observeValue(forKeyPath keyPath: String?, of object: Any?, change: [NSKeyValueChangeKey : Any]?, context: UnsafeMutableRawPointer?) {
        if object is CALayer {
            self.layer.zPosition = zPos + CGFloat(iconIndex) / 10000.0
        }
    }
    
    @objc public func assignImage(_ image: UIImage) {
        imgIcon.image = image
    }
    
    private func loadButtons() {
        btnDetail = UIButton(frame: CGRect(x: 0, y: 43, width: 46, height: 46))
        btnDetail.setImage(#imageLiteral(resourceName: "place_new_detail"), for: .normal)
        btnDetail.setImage(#imageLiteral(resourceName: "place_new_detail_s"), for: .selected)
        btnDetail.alpha = 0
        
        btnCollect = UIButton(frame: CGRect(x: 35, y: 0, width: 46, height: 46))
        btnCollect.setImage(#imageLiteral(resourceName: "place_new_collect"), for: .normal)
        btnCollect.setImage(#imageLiteral(resourceName: "place_new_collect_s"), for: .selected)
        btnCollect.alpha = 0
        imgSaved = UIImageView(frame: CGRect(x: 36, y: 10, width: 0, height: 0))
        imgSaved.image = #imageLiteral(resourceName: "place_new_collected")
        imgSaved.alpha = 0
        btnCollect.addSubview(imgSaved)
        
        btnRoute = UIButton(frame: CGRect(x: 93, y: 0, width: 46, height: 46))
        btnRoute.setImage(#imageLiteral(resourceName: "place_new_route"), for: .normal)
        btnRoute.setImage(#imageLiteral(resourceName: "place_new_route_s"), for: .selected)
        btnRoute.alpha = 0
        
        btnShare = UIButton(frame: CGRect(x: 128, y: 43, width: 46, height: 46))
        btnShare.setImage(#imageLiteral(resourceName: "place_new_share"), for: .normal)
        btnShare.setImage(#imageLiteral(resourceName: "place_new_share_s"), for: .selected)
        btnShare.alpha = 0
        
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
    
    public func showButtons() {
        guard arrBtns.count == 0 else { return }
        optionsReady = true
        optionsOpeing = true
        loadButtons()
        var point = frame.origin; point.x -= 59 + 8; point.y -= 56 + 5
        frame = CGRect(x: point.x, y: point.y, width: 174, height: 112 - 5)
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
            }, completion: { _ in
                if btn == self.btnCollect && self.boolShowSavedNoti {
                    self.showSavedNoti()
                }
            })
            delay += 0.075
        }
    }
    
    public func hideButtons() {
        guard arrBtns.count == 4 else { return }
        UIView.animate(withDuration: 0.2, animations: {
            for btn in self.arrBtns {
                btn.alpha = 0
                btn.center = self.imgIcon.center
            }
        }, completion: { _ in
            var point = self.frame.origin; point.x += 59 + 8; point.y += 56 + 5
            self.frame = CGRect(x: point.x, y: point.y, width: 56-16, height: 56-10)
            self.imgIcon.frame.origin = CGPoint(x: -8, y: -5)
            self.removeButtons()
        })
    }
    
    private func removeButtons() {
        for btn in arrBtns {
            btn.removeTarget(nil, action: nil, for: .touchUpInside)
            btn.removeFromSuperview()
        }
        arrBtns.removeAll()
    }
    
    public func optionsToNormal() {
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
    
    @objc func action(_ sender: UIButton, animated: Bool = false) {
        
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
            delegate?.placePinAction(action: .detail, mode: .place)
        } else if btnCollect.isSelected || sender == btnCollect {
            delegate?.placePinAction(action: .collect, mode: .place)
        } else if btnRoute.isSelected || sender == btnRoute {
            delegate?.placePinAction(action: .route, mode: .place)
        } else if btnShare.isSelected || sender == btnShare {
            delegate?.placePinAction(action: .share, mode: .place)
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
    
    private var imgSaved: UIImageView!
    
    var locationId: Int = -1
    
    var boolShowSavedNoti = false {
        didSet {
            guard optionsOpened else { return }
            guard imgSaved != nil else { return }
            guard boolShowSavedNoti else { return }
            self.savedNotiAnimation()
        }
    }
    
    var isRed = false
    
    var zPos: CGFloat = 299 {
        didSet {
            self.layer.zPosition = zPos
        }
    }
    
    override init(annotation: MKAnnotation?, reuseIdentifier: String?) {
        super.init(annotation: annotation, reuseIdentifier: reuseIdentifier)
        frame = CGRect(x: 0, y: 0, width: 56, height: 56)
        layer.anchorPoint = CGPoint(x: 0.5, y: 1.0)
        isEnabled = false
        imgIcon = UIImageView(frame: CGRect(x: 28, y: 56, width: 0, height: 0))
        imgIcon.contentMode = .scaleAspectFit
        addSubview(imgIcon)
        NotificationCenter.default.addObserver(self, selector: #selector(showSavedNoti(_:)), name: NSNotification.Name(rawValue: "showSavedNoti_loc"), object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(hideSavedNoti), name: NSNotification.Name(rawValue: "hideSavedNoti_loc"), object: nil)
        
        self.layer.zPosition = 299
        self.layer.addObserver(self, forKeyPath: "zPosition", options: NSKeyValueObservingOptions(rawValue: 0), context: nil)
    }
    
    override func observeValue(forKeyPath keyPath: String?, of object: Any?, change: [NSKeyValueChangeKey : Any]?, context: UnsafeMutableRawPointer?) {
        if object is CALayer {
            self.layer.zPosition = 299
        }
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
    
    override func prepareForReuse() {
        super.prepareForReuse()
        self.locationId = -1
        self.boolShowSavedNoti = false
    }
    
    deinit {
        NotificationCenter.default.removeObserver(self, name: NSNotification.Name(rawValue: "showSavedNoti_loc"), object: nil)
        NotificationCenter.default.removeObserver(self, name: NSNotification.Name(rawValue: "hideSavedNoti_loc"), object: nil)
    }
    
    public func assignImage(_ image: UIImage, red: Bool = false) {
        imgIcon.image = image
        isRed = red
    }
    
    private func loadButtons() {
        btnDetail = UIButton(frame: CGRect(x: 0, y: 43, width: 46, height: 46))
        btnDetail.setImage(#imageLiteral(resourceName: "place_new_detail"), for: .normal)
        btnDetail.setImage(#imageLiteral(resourceName: "place_new_detail_s"), for: .selected)
        btnDetail.alpha = 0
        
        btnCollect = UIButton(frame: CGRect(x: 35, y: 0, width: 46, height: 46))
        btnCollect.setImage(#imageLiteral(resourceName: "place_new_collect"), for: .normal)
        btnCollect.setImage(#imageLiteral(resourceName: "place_new_collect_s"), for: .selected)
        btnCollect.alpha = 0
        imgSaved = UIImageView(frame: CGRect(x: 36, y: 10, width: 0, height: 0))
        imgSaved.image = #imageLiteral(resourceName: "place_new_collected")
        imgSaved.alpha = 0
        btnCollect.addSubview(imgSaved)
        
        btnRoute = UIButton(frame: CGRect(x: 93, y: 0, width: 46, height: 46))
        btnRoute.setImage(#imageLiteral(resourceName: "place_new_route"), for: .normal)
        btnRoute.setImage(#imageLiteral(resourceName: "place_new_route_s"), for: .selected)
        btnRoute.alpha = 0
        
        btnShare = UIButton(frame: CGRect(x: 128, y: 43, width: 46, height: 46))
        btnShare.setImage(#imageLiteral(resourceName: "place_new_share"), for: .normal)
        btnShare.setImage(#imageLiteral(resourceName: "place_new_share_s"), for: .selected)
        btnShare.alpha = 0
        
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
    
    public func showButtons() {
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
            }, completion: { _ in
                if btn == self.btnCollect && self.boolShowSavedNoti {
                    self.savedNotiAnimation()
                }
            })
            delay += 0.075
        }
    }
    
    public func hideButtons(animated: Bool = true) {
        guard arrBtns.count == 4 else { return }
        if animated {
            UIView.animate(withDuration: 0.2, animations: {
                for btn in self.arrBtns {
                    btn.alpha = 0
                    btn.center = self.imgIcon.center
                }
            }, completion: { _ in
                var point = self.frame.origin; point.x += 59; point.y += 56
                self.frame = CGRect(x: point.x, y: point.y, width: 56, height: 56)
                self.imgIcon.frame.origin = CGPoint.zero
                self.removeButtons()
            })
        } else {
            for btn in self.arrBtns {
                btn.alpha = 0
                btn.center = self.imgIcon.center
            }
            var point = self.frame.origin; point.x += 59; point.y += 56
            self.frame = CGRect(x: point.x, y: point.y, width: 56, height: 56)
            self.imgIcon.frame.origin = CGPoint.zero
            self.removeButtons()
        }
    }
    
    private func removeButtons() {
        for btn in arrBtns {
            btn.removeTarget(nil, action: nil, for: .touchUpInside)
            btn.removeFromSuperview()
        }
        arrBtns.removeAll()
    }
    
    public func optionsToNormal() {
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
    
    @objc private func showSavedNoti(_ sender: Notification) {
        if let id = sender.object as? Int {
            self.locationId = id
        }
        savedNotiAnimation()
    }
    
    private func savedNotiAnimation() {
        if imgSaved == nil {
            showButtons()
        }
        UIView.animate(withDuration: 0.2, delay: 0, options: .curveEaseOut, animations: {
            self.imgSaved.frame = CGRect(x: 27, y: 1, width: 18, height: 18)
            self.imgSaved.alpha = 1
        }, completion: nil)
    }
    
    @objc private func hideSavedNoti() {
        guard imgSaved != nil else { return }
        UIView.animate(withDuration: 0.2, delay: 0, options: .curveEaseOut, animations: {
            self.imgSaved.frame = CGRect(x: 36, y: 10, width: 0, height: 0)
            self.imgSaved.alpha = 0
        }, completion: nil)
    }
    
    @objc func action(_ sender: UIButton, animated: Bool = false) {
        
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
            delegate?.placePinAction(action: .detail, mode: .location)
        } else if btnCollect.isSelected || sender == btnCollect {
            delegate?.placePinAction(action: .collect, mode: .location)
        } else if btnRoute.isSelected || sender == btnRoute {
            delegate?.placePinAction(action: .route, mode: .location)
        } else if btnShare.isSelected || sender == btnShare {
            delegate?.placePinAction(action: .share, mode: .location)
        }
    }
}
