//
//  ChatInputBarViews.swift
//  faeBeta
//
//  Created by Jichao on 2018/6/2.
//  Copyright © 2018年 fae. All rights reserved.
//

import UIKit

// MARK: - ChatInputStackView
class ChatInputStackView: UIStackView {
    
    /// The stack view position in the MessageInputBar
    ///
    /// - left: Left Stack View
    /// - right: Bottom Stack View
    /// - bottom: Left Stack View
    /// - top: Top Stack View
    public enum Position {
        case left, right, bottom, top
    }
    
    // MARK: Initialization
    
    convenience init(axis: UILayoutConstraintAxis, spacing: CGFloat) {
        self.init(frame: .zero)
        self.axis = axis
        self.spacing = spacing
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setup()
    }
    
    required init(coder: NSCoder) {
        super.init(coder: coder)
    }
    
    // MARK: Setup
    
    /// Sets up the default properties
    func setup() {
        translatesAutoresizingMaskIntoConstraints = false
        distribution = .fill
        alignment = .bottom
    }
}

// MARK: - SeparatorLine
class SeparatorLine: UIView {
    
    // MARK: Properties
    
    /// The height of the line
    var height: CGFloat = 1.0 {
        didSet {
            invalidateIntrinsicContentSize()
        }
    }
    
    override var intrinsicContentSize: CGSize {
        return CGSize(width: super.intrinsicContentSize.width, height: height)
    }
    
    // MARK: Initialization
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setup()
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        setup()
    }
    
    /// Sets up the default properties
    func setup() {
        backgroundColor = .lightGray
        translatesAutoresizingMaskIntoConstraints = false
        setContentHuggingPriority(.defaultHigh, for: .vertical)
    }
}

// MARK: - FaeHeartButton
protocol FaeHeartButtonDelegate: class {
    func faeHeartButton(_ faeHeartButton: FaeHeartButton)
}

class FaeHeartButton: UIButton, CAAnimationDelegate {
    // MARK: Properties
    var imgHeartDic: [CAAnimation: UIImageView] = [CAAnimation: UIImageView]()
    var animatingHeartTimer: Timer!
    var imgView: UIImageView!
    weak var delegate: FaeHeartButtonDelegate?
    
    // MARK: init
    override init(frame: CGRect) {
        super.init(frame: frame)
        adjustsImageWhenHighlighted = false
        
        setImage(UIImage(named: "pinDetailLikeHeartHollow"), for: .normal)
        addTarget(self, action: #selector(actionTapped), for: .touchUpInside)
        addTarget(self, action: #selector(actionHolding), for: .touchDown)
        addTarget(self, action: #selector(actionLeave), for: .touchDragOutside)
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK: Actions
    @objc private func actionTapped() {
        if animatingHeartTimer != nil {
            animatingHeartTimer.invalidate()
            animatingHeartTimer = nil
        }
        delegate?.faeHeartButton(self)
    }
    
    @objc private func actionHolding() {
        if animatingHeartTimer == nil {
            animatingHeartTimer = Timer.scheduledTimer(timeInterval: 0.15, target: self, selector: #selector(heartAnimated), userInfo: nil, repeats: true)
        }
    }
    
    @objc private func actionLeave() {
        if animatingHeartTimer != nil {
            animatingHeartTimer.invalidate()
            animatingHeartTimer = nil
        }
    }
    
    @objc private func heartAnimated() {
        guard let imageView = imageView else { return }
        imgView = UIImageView(frame: CGRect(x: 0, y: 0, width: 26, height: 22))
        imgView.image = #imageLiteral(resourceName: "pinDetailLikeHeartFull")
        imgView.layer.opacity = 0
        addSubview(imgView)
        
        let randomX = CGFloat(arc4random_uniform(150))
        let randomY = CGFloat(arc4random_uniform(50) + 100)
        let randomSize: CGFloat = (CGFloat(arc4random_uniform(40)) - 20) / 100 + 1
        
        let transform: CGAffineTransform = CGAffineTransform(translationX: imageView.center.x, y: imageView.center.y)
        let path = CGMutablePath()
        path.move(to: CGPoint(x: 0, y: 0), transform: transform)
        path.addLine(to: CGPoint(x: randomX - 75, y: -randomY), transform: transform)
        
        let scaleAnimation = CAKeyframeAnimation(keyPath: "transform")
        scaleAnimation.values = [NSValue(caTransform3D: CATransform3DMakeScale(1, 1, 1)), NSValue(caTransform3D: CATransform3DMakeScale(randomSize, randomSize, 1))]
        scaleAnimation.timingFunction = CAMediaTimingFunction(name: kCAMediaTimingFunctionEaseOut)
        scaleAnimation.duration = 1
        
        let fadeAnimation = CABasicAnimation(keyPath: "opacity")
        fadeAnimation.fromValue = 1.0
        fadeAnimation.toValue = 0.0
        fadeAnimation.duration = 1
        fadeAnimation.delegate = self
        
        let orbit = CAKeyframeAnimation(keyPath: "position")
        orbit.duration = 1
        orbit.path = path
        orbit.calculationMode = kCAAnimationPaced
        imgView.layer.add(orbit, forKey: "Move")
        imgView.layer.add(fadeAnimation, forKey: "Opacity")
        imgView.layer.add(scaleAnimation, forKey: "Scale")
        imgView.layer.position = CGPoint(x: imageView.center.x, y: imageView.center.y)
    }
    
    // MARK: CAAnimationDelegate
    func animationDidStart(_ anim: CAAnimation) {
        if anim.duration == 1 {
            imgHeartDic[anim] = imgView
            let seconds = 0.5
            let delay = seconds * Double(NSEC_PER_SEC) // nanoseconds per seconds
            let dispatchTime = DispatchTime.now() + Double(Int64(delay)) / Double(NSEC_PER_SEC)
            DispatchQueue.main.asyncAfter(deadline: dispatchTime, execute: {
                self.sendSubview(toBack: self.imgHeartDic[anim]!)
            })
        }
    }
    
    func animationDidStop(_ anim: CAAnimation, finished flag: Bool) {
        if anim.duration == 1 && flag {
            imgHeartDic[anim]?.removeFromSuperview()
            imgHeartDic[anim] = nil
        }
    }
}
