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
    
    private var btnIndicator: UIButton!
    private var uiviewBar: UIView!
    private var lblPrefix: UILabel!
    weak var delegate: FaeScrollBarDelegate?
    private let floatBtnHeight: CGFloat = 30.0
    private var floatFingerToBtnTop: CGFloat = 0.0
    private var floatBtnRange: CGFloat {
        get {
            return frame.height - floatBtnHeight
        }
    }
    private var floatScrollRange: CGFloat = 0.0
    private var floatBtnYPositon: CGFloat {
        get {
            return btnIndicator.frame.origin.y
        }
    }
    
    // MARK: init and setup
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
    
    private func setup() {
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
    
    // MARK: long press gesture for indicator
    @objc private func longPressGestureRecognizer(_ recognizer: UIGestureRecognizer) {
        //felixprint("btn long press")
        let curPosition = recognizer.location(in: self).y
        switch recognizer.state {
        case .began:
            animatedIndicator(type: .wide)
            floatFingerToBtnTop = curPosition - floatBtnYPositon
        case .changed:
            if curPosition < floatFingerToBtnTop || curPosition > self.frame.height - 30 + floatFingerToBtnTop {
            }
            setIndicatorPosition(curPosition - floatFingerToBtnTop, animated: 0.0)
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
        default:
            animatedIndicator(type: .thin)
        }
    }
    
    // MARK: pan gesture for indicator
    @objc private func panGestureIndicator(_ pan: UIPanGestureRecognizer) {
        //felixprint("btn pan")
        let curPosition = pan.location(in: self).y
        switch pan.state {
        case .began:
            animatedIndicator(type: .wide)
            floatFingerToBtnTop = curPosition - floatBtnYPositon
        case .changed:
            if curPosition < floatFingerToBtnTop || curPosition > self.frame.height - 30 + floatFingerToBtnTop {
            }
            setIndicatorPosition(curPosition - floatFingerToBtnTop, animated: 0.0)
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
        default:
            animatedIndicator(type: .thin)
        }
    }
    
    // MARK: long press gesture for scroll zone
    @objc private func handleScrollZoneLongPress(_ recognizer: UILongPressGestureRecognizer) {
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
                setIndicatorPosition(curPositon - 15.0, animated: 0.2)
            }
            animatedIndicator(type: .wide)
        case .changed:
            if curPositon < floatFingerToBtnTop || curPositon > self.frame.height - 30 + floatFingerToBtnTop {
            }
            setIndicatorPosition(curPositon - floatFingerToBtnTop, animated: 0.0)
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
        default:
            animatedIndicator(type: .thin)
        }
    }
    
    // MARK: set the size of indicator
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
        case .normal:
            uiviewBar.layer.cornerRadius = 5
            UIView.animate(withDuration: 0.2, delay: 0, options: [.curveEaseOut], animations: {
                self.uiviewBar.frame.size.width = 50
                self.uiviewBar.frame.origin.x = 3 + 15 - 50
                self.lblPrefix.frame.origin.x = 3 + 15 - 50 + 6
                self.lblPrefix.isHidden = false
            })
        case .wide:
            uiviewBar.layer.cornerRadius = 5
            UIView.animate(withDuration: 0.2, delay: 0, options: [.curveEaseOut], animations: {
                self.uiviewBar.frame.size.width = 90
                self.uiviewBar.frame.origin.x = 3 + 15 - 90
                self.lblPrefix.frame.origin.x = 3 + 15 - 90 + 6
                self.lblPrefix.isHidden = false
            })
        }
    }
    
    // MARK: set the position of the indicator
    func scrollToTop(animated duration: TimeInterval) {
        setIndicatorPosition(0.0, animated: duration)
    }
    
    func scrollToBottom(animated duration: TimeInterval) {
        setIndicatorPosition(frame.height - floatBtnHeight, animated: duration)
    }
    
    func setIndicatorPosition(_ pos: CGFloat, animated duration: TimeInterval) {
        UIView.animate(withDuration: duration, delay: 0, options: [.curveEaseOut], animations: {
            self.btnIndicator.frame.origin.y = pos
        })
    }
    
    // MARK: set the prefix of the indicator
    func setPrefixLable(_ prefix: String) {
        lblPrefix.text = prefix
    }
}

// MARK: extension to know whether the ScrollView is at the top or bottom
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
