//
//  FaeScrollBar.swift
//  faeBeta
//
//  Created by Jichao on 2018/1/6.
//  Copyright © 2018 fae. All rights reserved.
//

import UIKit

protocol FaeScrollBarDelegate: class {
    func setScrollViewContentOffset(_ position: CGPoint, animated: Bool)
}

enum IndicatorSize: Int {
    case thin = 0
    case normal = 1
    case wide = 2
}

class FaeScrollBar: UIView {
    
    var btnIndicator: UIButton!
    var uiviewBar: UIView!
    var lblPrefix: UILabel!
    var delegate: FaeScrollBarDelegate?
    let floatBtnHeight: CGFloat = 30.0
    var floatFingerToBtnTop: CGFloat = 0.0
    var floatBtnRange: CGFloat {
        get {
            return frame.height - floatBtnHeight
        }
    }
    var floatScrollRange: CGFloat = 0.0
    var floatBtnYPositon: CGFloat {
        get {
            return btnIndicator.frame.origin.y
        }
    }
    
    init(frame: CGRect, scrollRange: CGFloat) {
        super.init(frame: frame)
        floatScrollRange = scrollRange
        backgroundColor = .clear
        let longpressGestureZone = UILongPressGestureRecognizer(target: self, action: #selector(handleScrollZoneLongPress(_:)))
        addGestureRecognizer(longpressGestureZone)
        setup()
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func setup() {
        btnIndicator = UIButton(frame: CGRect(x: 0, y: 0, width: 23, height: floatBtnHeight))
        btnIndicator.adjustsImageWhenHighlighted = false
        addSubview(btnIndicator)
        let panGesture = UIPanGestureRecognizer(target: self, action: #selector(panGestureIndicator(_:)))
        let longpressGesture = UILongPressGestureRecognizer(target: self, action: #selector(longPressGestureRecognizer(_:)))
        longpressGesture.minimumPressDuration = 0.3
        btnIndicator.addGestureRecognizer(panGesture)
        btnIndicator.addGestureRecognizer(longpressGesture)
        
        uiviewBar = UIView(frame: CGRect(x: 15, y: 0, width: 3, height: floatBtnHeight))
        uiviewBar.backgroundColor = UIColor._2499090()
        uiviewBar.layer.cornerRadius = 3
        btnIndicator.addSubview(uiviewBar)
        
        lblPrefix = UILabel(frame: CGRect(x: 10, y: 3, width: 20, height: 25))
        lblPrefix.textAlignment = .left
        lblPrefix.font = UIFont(name: "AvenirNext-DemiBold", size: 18)
        lblPrefix.textColor = .white
        lblPrefix.tag = 0
        btnIndicator.addSubview(lblPrefix)
        lblPrefix.isHidden = true
    }
    
    @objc func longPressGestureRecognizer(_ recognizer: UIGestureRecognizer) {
        //felixprint("btn long press")
        let curPosition = recognizer.location(in: self).y
        switch recognizer.state {
        case .began:
            animatedIndicator(type: .wide)
            floatFingerToBtnTop = curPosition - floatBtnYPositon
            break
        case .changed:
            if curPosition < floatFingerToBtnTop || curPosition > self.frame.height - 30 + floatFingerToBtnTop {
                break
            }
            setBtnYPosition(curPosition - floatFingerToBtnTop, animated: 0.0)
            var percentage = floatBtnYPositon / floatBtnRange
            if percentage > 0.995 {
                percentage = 1.0
            }
            if percentage < 0.005 {
                percentage = 0.0
            }
            delegate?.setScrollViewContentOffset(CGPoint(x: 0, y: floatScrollRange * percentage), animated: false)
            break
        case .ended:
            animatedIndicator(type: .thin)
            break
        default:
            animatedIndicator(type: .thin)
        }
    }
    
    @objc func panGestureIndicator(_ pan: UIPanGestureRecognizer) {
        //felixprint("btn pan")
        let curPosition = pan.location(in: self).y
        switch pan.state {
        case .began:
            animatedIndicator(type: .wide)
            floatFingerToBtnTop = curPosition - floatBtnYPositon
            break
        case .changed:
            if curPosition < floatFingerToBtnTop || curPosition > self.frame.height - 30 + floatFingerToBtnTop {
                break
            }
            setBtnYPosition(curPosition - floatFingerToBtnTop, animated: 0.0)
            var percentage = floatBtnYPositon / floatBtnRange
            if percentage > 0.995 {
                percentage = 1.0
            }
            if percentage < 0.005 {
                percentage = 0.0
            }
            delegate?.setScrollViewContentOffset(CGPoint(x: 0, y: floatScrollRange * percentage), animated: false)
        case .ended:
            animatedIndicator(type: .thin)
            break
        default:
            animatedIndicator(type: .thin)
        }
    }
    
    @objc func handleScrollZoneLongPress(_ recognizer: UILongPressGestureRecognizer) {
        let curPositon = recognizer.location(in: self).y
        //felixprint(curPositon)
        switch recognizer.state {
        case .began:
            floatFingerToBtnTop = 15.0
            if curPositon <= floatBtnHeight {
                delegate?.setScrollViewContentOffset(CGPoint(x: 0, y: 0), animated: false)
                scrollToTop(animated: 0.2)
            } else if curPositon >= self.frame.height - floatBtnHeight {
                delegate?.setScrollViewContentOffset(CGPoint(x: 0, y: floatScrollRange), animated: false)
                scrollToBottom(animated: 0.2)
            } else {
                let percentage = (curPositon - 15.0) / floatBtnRange
                delegate?.setScrollViewContentOffset(CGPoint(x: 0, y: floatScrollRange * percentage), animated: false)
                setBtnYPosition(curPositon - 15.0, animated: 0.2)
            }
            animatedIndicator(type: .wide)
        case .changed:
            if curPositon < floatFingerToBtnTop || curPositon > self.frame.height - 30 + floatFingerToBtnTop {
                break
            }
            setBtnYPosition(curPositon - floatFingerToBtnTop, animated: 0.0)
            var percentage = floatBtnYPositon / floatBtnRange
            if percentage > 0.995 {
                percentage = 1.0
            }
            if percentage < 0.005 {
                percentage = 0.0
            }
            delegate?.setScrollViewContentOffset(CGPoint(x: 0, y: floatScrollRange * percentage), animated: false)
            break
        case .ended:
            animatedIndicator(type: .thin)
            break
        default:
            animatedIndicator(type: .thin)
        }
    }
    
    func animatedIndicator(type: IndicatorSize) {
        switch type {
        case .thin:
            lblPrefix.isHidden = true
            UIView.animate(withDuration: 0.2, delay: 0, options: [.curveEaseOut], animations: {
                self.uiviewBar.frame.size.width = 3
                self.uiviewBar.frame.origin.x = 15
            }, completion: { _ in
                self.uiviewBar.layer.cornerRadius = 3
            })
            break
        case .normal:
            uiviewBar.layer.cornerRadius = 5
            UIView.animate(withDuration: 0.2, delay: 0, options: [.curveEaseOut], animations: {
                self.uiviewBar.frame.size.width = 50
                self.uiviewBar.frame.origin.x = 3 + 15 - 50
                self.lblPrefix.frame.origin.x = 3 + 15 - 50 + 6
                self.lblPrefix.isHidden = false
            })
            break
        case .wide:
            uiviewBar.layer.cornerRadius = 5
            UIView.animate(withDuration: 0.2, delay: 0, options: [.curveEaseOut], animations: {
                self.uiviewBar.frame.size.width = 90
                self.uiviewBar.frame.origin.x = 3 + 15 - 90
                self.lblPrefix.frame.origin.x = 3 + 15 - 90 + 6
                self.lblPrefix.isHidden = false
            })
            break
        }
    }
    
    func scrollToTop(animated duration: TimeInterval) {
        setBtnYPosition(0.0, animated: duration)
    }
    
    func scrollToBottom(animated duration: TimeInterval) {
        setBtnYPosition(frame.height - floatBtnHeight, animated: duration)
    }
    
    func setBtnYPosition(_ pos: CGFloat, animated duration: TimeInterval) {
        UIView.animate(withDuration: duration, delay: 0, options: [.curveEaseOut], animations: {
            self.btnIndicator.frame.origin.y = pos
        })
    }
    
    func setPrefixLable(_ prefix: String) {
        lblPrefix.text = prefix
    }
}

extension UIScrollView {
    var isAtTop: Bool {
        return contentOffset.y <= verticalOffsetForTop
    }
    
    var isAtBottom: Bool {
        return contentOffset.y >= verticalOffsetForBottom
    }
    
    var verticalOffsetForTop: CGFloat {
        let topInset = contentInset.top
        return -topInset
    }
    
    var verticalOffsetForBottom: CGFloat {
        let scrollViewHeight = bounds.height
        let scrollContentSizeHeight = contentSize.height
        let bottomInset = contentInset.bottom
        let scrollViewBottomOffset = scrollContentSizeHeight + bottomInset - scrollViewHeight
        return scrollViewBottomOffset
    }
}
