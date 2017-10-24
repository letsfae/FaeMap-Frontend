//
//  InfiniteScrollingView.swift
//  faeBeta
//
//  Created by Vicky on 2017-08-16.
//  Copyright © 2017 fae. All rights reserved.
//

import UIKit

class InfiniteScrollingView: UIView {
//    var placePhotos = [UIImage]()
    var placePhotos = [#imageLiteral(resourceName: "food_1"), #imageLiteral(resourceName: "food_2"), #imageLiteral(resourceName: "food_3"), #imageLiteral(resourceName: "food_4"), #imageLiteral(resourceName: "food_5"), #imageLiteral(resourceName: "food_6")]
    var imgPic_0: UIImageView!
    var imgPic_1: UIImageView!
    var imgPic_2: UIImageView!
    var boolLeft: Bool!
    var boolRight: Bool!
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        loadContent()
        
        if placePhotos.count > 1 {
            let panGesture = UIPanGestureRecognizer()
            panGesture.maximumNumberOfTouches = 1
            panGesture.addTarget(self, action: #selector(handlePanGesture(_:)))
            addGestureRecognizer(panGesture)
        }
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func loadImages(place: PlacePin) {
        downloadImageForView(place: place, url: place.imageURL, imgPic: imgPic_1)
        downloadImageForView(place: place, url: place.imageURL, imgPic: imgPic_0)
        downloadImageForView(place: place, url: place.imageURL, imgPic: imgPic_2)
    }
    
    func downloadImageForView(place: PlacePin, url: String, imgPic: UIImageView) {
        if url == "" {
            imgPic.image = UIImage(named: "place_result_\(place.class_2_icon_id)") ?? UIImage(named: "place_result_48")
            imgPic.backgroundColor = .white
        } else {
            if let placeImgFromCache = placeInfoBarImageCache.object(forKey: url as AnyObject) as? UIImage {
                imgPic.image = placeImgFromCache
                imgPic.backgroundColor = UIColor._2499090()
            } else {
                downloadImage(URL: url) { (rawData) in
                    guard let data = rawData else { return }
                    DispatchQueue.global(qos: .userInitiated).async {
                        guard let placeImg = UIImage(data: data) else { return }
                        DispatchQueue.main.async {
                            imgPic.image = placeImg
                            imgPic.backgroundColor = UIColor._2499090()
                            placeInfoBarImageCache.setObject(placeImg, forKey: url as AnyObject)
                        }
                    }
                }
            }
        }
    }
    
    func loadContent() {
        imgPic_0 = UIImageView(frame: frame)
        imgPic_1 = UIImageView(frame: frame)
        imgPic_2 = UIImageView(frame: frame)
        imgPic_0.contentMode = .scaleAspectFill
        imgPic_1.contentMode = .scaleAspectFill
        imgPic_2.contentMode = .scaleAspectFill
        imgPic_0.clipsToBounds = true
        imgPic_1.clipsToBounds = true
        imgPic_2.clipsToBounds = true
        resetSubviews()
        
        addSubview(imgPic_0)
        addSubview(imgPic_1)
        addSubview(imgPic_2)
        if placePhotos.count == 0 {
//            imgPic_0.image = #imageLiteral(resourceName: "food_1")
//            imgPic_1.image = #imageLiteral(resourceName: "food_1")
//            imgPic_2.image = #imageLiteral(resourceName: "food_1")
        } else {
//            imgPic_0.image = placePhotos[placePhotos.count - 1]
//            imgPic_1.image = placePhotos[0]
//            imgPic_2.image = placePhotos[1 % placePhotos.count]
        }
        boolLeft = placePhotos.count > 1
        boolRight = placePhotos.count > 1
    }
    
    func panToPrev(_ time: Double = 0.3) {
        UIView.animate(withDuration: time, delay: 0, usingSpringWithDamping: 1, initialSpringVelocity: 0, options: .curveEaseOut, animations: {
            self.imgPic_0.frame.origin.x = 0
            self.imgPic_1.frame.origin.x += screenWidth
        }, completion: {_ in
            let image = self.imgPic_2.image
            self.imgPic_2.image = self.imgPic_1.image
            self.imgPic_1.image = self.imgPic_0.image
//            var idx = self.placePhotos.index(of: self.imgPic_0.image!)!
//            idx = (idx + self.placePhotos.count - 1) % self.placePhotos.count
            self.imgPic_0.image = image
            self.resetSubviews()
        })
    }
    
    func panToNext(_ time: Double = 0.3) {
        UIView.animate(withDuration: time, delay: 0, usingSpringWithDamping: 1, initialSpringVelocity: 0, options: .curveEaseOut, animations: {
            self.imgPic_1.frame.origin.x = -screenWidth
            self.imgPic_2.frame.origin.x = 0
        }, completion: { _ in
            let image = self.imgPic_0.image
            self.imgPic_0.image = self.imgPic_1.image
            self.imgPic_1.image = self.imgPic_2.image
//            var idx = self.placePhotos.index(of: self.imgPic_2.image!)!
//            idx = (idx + self.placePhotos.count + 1) % self.placePhotos.count
            self.imgPic_2.image = image
            self.resetSubviews()
        })
    }
    
    func panBack(_ time: Double = 0.3) {
        UIView.animate(withDuration: time, delay: 0, usingSpringWithDamping: 1, initialSpringVelocity: 0, options: .curveEaseOut, animations: {
            self.resetSubviews()
        }, completion: nil)
    }
    
    var end: CGFloat = 0
    
    func handlePanGesture(_ pan: UIPanGestureRecognizer) {
        var resumeTime: Double = 0.5
        if pan.state == .began {
            end = pan.location(in: self).x
        } else if pan.state == .ended || pan.state == .failed || pan.state == .cancelled {
            let velocity = pan.velocity(in: self)
            let location = pan.location(in: self)
            let distanceMoved = end - location.x
            let percent = distanceMoved / screenWidth
            resumeTime = abs(Double(CGFloat(distanceMoved) / velocity.x))
            if resumeTime > 0.5 {
                resumeTime = 0.5
            } else if resumeTime < 0.3 {
                resumeTime = 0.3
            }
            let absPercent: CGFloat = 0.1
            if percent < -absPercent {
                panToPrev(resumeTime)
            } else if percent > absPercent {
                panToNext(resumeTime)
            } else {
                panBack(resumeTime)
            }
        } else if pan.state == .changed {
            if boolLeft || boolRight {
                let translation = pan.translation(in: self)
                imgPic_0.center.x = imgPic_0.center.x + translation.x
                imgPic_1.center.x = imgPic_1.center.x + translation.x
                imgPic_2.center.x = imgPic_2.center.x + translation.x
                pan.setTranslation(CGPoint.zero, in: self)
            }
        }
    }
    
    func resetSubviews() {
        imgPic_0.frame.origin.x = -screenWidth
        imgPic_1.frame.origin.x = 0
        imgPic_2.frame.origin.x = screenWidth
    }
}

