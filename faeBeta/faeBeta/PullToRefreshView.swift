//
//  PullToRefreshConst.swift
//  PullToRefreshSwift
//
//  Created by Yuji Hato on 12/11/14.
//  Qiulang rewrites it to support pull down & push up
//
import UIKit
import Gifu

open class PullToRefreshView: UIView {
    enum PullToRefreshState {
        case pulling
        case triggered
        case refreshing
        case stop
        case finish
    }
    
    // MARK: Variables
    let contentOffsetKeyPath = "contentOffset"
    let contentSizeKeyPath = "contentSize"
    var kvoContext = "PullToRefreshKVOContext"
    
    fileprivate var options: PullToRefreshOption
    fileprivate var backgroundView: UIView
    fileprivate var arrow: UIImageView
    fileprivate var indicator: UIActivityIndicatorView
    fileprivate var scrollViewInsets: UIEdgeInsets = UIEdgeInsets.zero
    fileprivate var refreshCompletion: (() -> Void)?
    fileprivate var pull: Bool = true
    var gifUnicorn: GIFImageView
    
    fileprivate var positionY: CGFloat = 0 {
        didSet {
            if self.positionY == oldValue {
                return
            }
            var frame = self.frame
            frame.origin.y = positionY
            self.frame = frame
        }
    }
    
    var state: PullToRefreshState = PullToRefreshState.pulling {
        didSet {
            if self.state == oldValue {
                return
            }
            print(self.state)
            switch self.state {
            case .pulling: // starting point
                arrowRotationBack() // dummy now
                break
            case .triggered:
                arrowRotation() // dummy now
                self.gifUnicorn.frame.origin.x = -130
                break
            case .refreshing:
                UIView.animate(withDuration: 1.5, animations: {
                    self.gifUnicorn.center.x = screenWidth / 2
                }, completion: nil)
                startAnimating()
                break
            case .stop:
                UIView.animate(withDuration: 1.5, animations: {
                    self.gifUnicorn.frame.origin.x = screenWidth
                }, completion: nil)
                stopAnimating()
                break
            case .finish:
                var duration = PullToRefreshConst.animationDuration
                var time = DispatchTime.now() + Double(Int64(duration * Double(NSEC_PER_SEC))) / Double(NSEC_PER_SEC)
                DispatchQueue.main.asyncAfter(deadline: time) {
                    self.stopAnimating()
                }
                duration = duration * 2
                time = DispatchTime.now() + Double(Int64(duration * Double(NSEC_PER_SEC))) / Double(NSEC_PER_SEC)
                DispatchQueue.main.asyncAfter(deadline: time) {
                    self.removeFromSuperview()
                }
                break
            }
        }
    }
    
    // MARK: UIView
    public convenience override init(frame: CGRect) {
        self.init(options: PullToRefreshOption(), frame: frame, refreshCompletion: nil)
    }
    
    public required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    public init(options: PullToRefreshOption, frame: CGRect, refreshCompletion: (() -> Void)?, down: Bool = true) {
        self.options = options
        self.refreshCompletion = refreshCompletion
        
        self.backgroundView = UIView(frame: CGRect(x: 0, y: 0, width: frame.size.width, height: frame.size.height))
        self.backgroundView.backgroundColor = self.options.backgroundColor
        self.backgroundView.autoresizingMask = UIViewAutoresizing.flexibleWidth
        
        self.arrow = UIImageView(frame: CGRect(x: 0, y: 0, width: 30, height: 30))
        self.arrow.autoresizingMask = [.flexibleLeftMargin, .flexibleRightMargin]
        
        self.arrow.image = UIImage(named: PullToRefreshConst.imageName, in: Bundle(for: type(of: self)), compatibleWith: nil)
        
        self.indicator = UIActivityIndicatorView(activityIndicatorStyle: UIActivityIndicatorViewStyle.gray)
        self.indicator.bounds = self.arrow.bounds
        self.indicator.autoresizingMask = self.arrow.autoresizingMask
        self.indicator.hidesWhenStopped = true
        self.indicator.color = options.indicatorColor
        self.pull = down
        
        self.gifUnicorn = GIFImageView(frame: CGRect(x: 0, y: -20, width: 200, height: 140))
        self.gifUnicorn.contentMode = .scaleAspectFit
        
        super.init(frame: frame)
        self.addSubview(self.indicator)
        self.addSubview(self.backgroundView)
        self.addSubview(self.arrow)
        self.autoresizingMask = .flexibleWidth
        
        self.gifUnicorn.animate(withGIFNamed: "GIF_alpha")
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.05) {
            self.gifUnicorn.stopAnimatingGIF()
        }
        
        let imgBackground = UIImageView(frame: CGRect(x: 0, y: 0, width: screenWidth, height: 85))
        imgBackground.image = #imageLiteral(resourceName: "pullToRefreshBackground")
        imgBackground.contentMode = .top
        imgBackground.clipsToBounds = true
        
        imgBackground.addSubview(self.gifUnicorn)
        self.gifUnicorn.frame.origin.x = -130
        self.addSubview(imgBackground)
    }
    
    open override func layoutSubviews() {
        super.layoutSubviews()
        self.arrow.center = CGPoint(x: self.frame.size.width / 2, y: self.frame.size.height / 2)
        self.arrow.frame = self.arrow.frame.offsetBy(dx: 0, dy: 0)
        self.indicator.center = self.arrow.center
    }
    
    open override func willMove(toSuperview superView: UIView!) {
        // superview NOT superView, DO NEED to call the following method
        // superview dealloc will call into this when my own dealloc run later!!
        self.removeRegister()
        guard let scrollView = superView as? UIScrollView else {
            return
        }
        scrollView.addObserver(self, forKeyPath: self.contentOffsetKeyPath, options: .initial, context: &self.kvoContext)
        if !self.pull {
            scrollView.addObserver(self, forKeyPath: self.contentSizeKeyPath, options: .initial, context: &self.kvoContext)
        }
    }
    
    fileprivate func removeRegister() {
        if let scrollView = superview as? UIScrollView {
            scrollView.removeObserver(self, forKeyPath: self.contentOffsetKeyPath, context: &self.kvoContext)
            if !self.pull {
                scrollView.removeObserver(self, forKeyPath: self.contentSizeKeyPath, context: &self.kvoContext)
            }
        }
    }
    
    deinit {
        self.removeRegister()
    }
    
    // MARK: KVO
    
    open override func observeValue(forKeyPath keyPath: String?, of object: Any?, change: [NSKeyValueChangeKey: Any]?, context: UnsafeMutableRawPointer?) {
        guard let scrollView = object as? UIScrollView else {
            return
        }
        if keyPath == self.contentSizeKeyPath {
            self.positionY = scrollView.contentSize.height
            return
        }
        
        if !(context == &self.kvoContext && keyPath == self.contentOffsetKeyPath) {
            super.observeValue(forKeyPath: keyPath, of: object, change: change, context: context)
            return
        }
        
        // Pulling State Check
        let offsetY = scrollView.contentOffset.y
        
        // Alpha set
        if PullToRefreshConst.alpha {
            var alpha = fabs(offsetY) / (self.frame.size.height + 40)
            if alpha > 0.8 {
                alpha = 0.8
            }
            self.arrow.alpha = alpha
        }
        
        if offsetY <= 0 {
            if !self.pull {
                return
            }
            if offsetY < -self.frame.size.height {
                // pulling or refreshing
                if scrollView.isDragging == false && self.state != .refreshing { // release the finger
                    self.state = .refreshing // startAnimating
                } else if self.state != .refreshing { // reach the threshold
                    self.state = .triggered
                }
            } else if self.state == .triggered {
                // starting point, start from pulling
                self.state = .pulling
            }
            return // return for pull down
        }
        
        // push up
        let upHeight = offsetY + scrollView.frame.size.height - scrollView.contentSize.height
        if upHeight > 0 {
            // pulling or refreshing
            if self.pull {
                return
            }
            if upHeight > self.frame.size.height {
                // pulling or refreshing
                if scrollView.isDragging == false && self.state != .refreshing { // release the finger
                    self.state = .refreshing // startAnimating
                } else if self.state != .refreshing { // reach the threshold
                    self.state = .triggered
                }
            } else if self.state == .triggered {
                // starting point, start from pulling
                self.state = .pulling
            }
        }
    }
    
    // MARK: private
    
    fileprivate func startAnimating() {
        self.gifUnicorn.startAnimatingGIF()
        self.indicator.startAnimating()
        self.arrow.isHidden = true
        guard let scrollView = superview as? UIScrollView else {
            return
        }
        self.scrollViewInsets = scrollView.contentInset
        
        var insets = scrollView.contentInset
        if self.pull {
            insets.top += self.frame.size.height
        } else {
            insets.bottom += self.frame.size.height
        }
        scrollView.bounces = false
        UIView.animate(withDuration: PullToRefreshConst.animationDuration, delay: 0, options: [],
            animations: {
                scrollView.contentInset = insets
            }, completion: { _ in
                if self.options.autoStopTime != 0 {
                    let time = DispatchTime.now() + Double(Int64(self.options.autoStopTime * Double(NSEC_PER_SEC))) / Double(NSEC_PER_SEC)
                    DispatchQueue.main.asyncAfter(deadline: time) {
                        self.state = .stop
                    }
                }
                self.refreshCompletion?()
            }
        )
    }
    
    fileprivate func stopAnimating() {
        self.indicator.stopAnimating()
        self.arrow.isHidden = false
        guard let scrollView = superview as? UIScrollView else {
            return
        }
        scrollView.bounces = true
        let duration = PullToRefreshConst.animationDuration
        UIView.animate(withDuration: duration, delay: 1.2, options: [],
            animations: {
                scrollView.contentInset = self.scrollViewInsets
                self.arrow.transform = CGAffineTransform.identity
            }, completion: { _ in
                self.state = .pulling
                self.gifUnicorn.stopAnimatingGIF()
            }
        )
    }
    
    fileprivate func arrowRotation() {
        
    }
    
    fileprivate func arrowRotationBack() {
        
    }
}
