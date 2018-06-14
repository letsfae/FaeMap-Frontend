//
//  ChatInputBarButton.swift
//  faeBeta
//
//  Created by Jichao on 2018/6/2.
//  Copyright © 2018年 fae. All rights reserved.
//

import UIKit

class ChatInputBarButton: UIButton {
    
    /// The spacing properties of the InputBarButtonItem
    ///
    /// - fixed: The spacing is fixed
    /// - flexible: The spacing is flexible
    /// - none: There is no spacing
    enum Spacing {
        case fixed(CGFloat)
        case flexible
        case none
    }
    
    typealias ChatInputBarButtonAction = ((ChatInputBarButton) -> Void)
    
    // MARK: - Properties
    
    /// A weak reference to the MessageInputBar that the InputBarButtonItem used in
    weak var faeInputBar: FaeInputBar?
    
    /// The spacing property of the InputBarButtonItem that determines the contentHuggingPriority and any
    /// additional space to the intrinsicContentSize
    var spacing: Spacing = .none {
        didSet {
            switch spacing {
            case .flexible:
                setContentHuggingPriority(UILayoutPriority(rawValue: 1), for: .horizontal)
            case .fixed:
                setContentHuggingPriority(UILayoutPriority(rawValue: 1000), for: .horizontal)
            case .none:
                setContentHuggingPriority(UILayoutPriority(rawValue: 500), for: .horizontal)
            }
        }
    }
    
    /// When not nil this size overrides the intrinsicContentSize
    private var size: CGSize? = CGSize(width: 20, height: 20) {
        didSet {
            invalidateIntrinsicContentSize()
        }
    }
    
    override var intrinsicContentSize: CGSize {
        var contentSize = size ?? super.intrinsicContentSize
        switch spacing {
        case .fixed(let width):
            contentSize.width += width
        case .flexible, .none:
            break
        }
        return contentSize
    }
    
    /// A reference to the stack view position that the InputBarButtonItem is held in
    var parentStackViewPosition: ChatInputStackView.Position?
    
    override var isSelected: Bool {
        didSet {
            if isSelected, let name = imageSelectedName {
                setImage(UIImage(named: name), for: .normal)
            } else {
                setImage(UIImage(named: imageNormalName), for: .normal)
            }
        }
    }
    
    override var isEnabled: Bool {
        didSet {
            if isEnabled, let name = imageSelectedName {
                setImage(UIImage(named: name), for: .normal)
            }
        }
    }
    
    /// Image name for normal and selected state
    var imageNormalName: String = ""
    var imageSelectedName: String? = ""
    
    // MARK: - Reactive Hooks
    
    private var onTouchUpInsideAction: ChatInputBarButtonAction?
    private var onKeyboardEditingEndsAction: ChatInputBarButtonAction?
    private var onKeyboardEditingBeginsAction: ChatInputBarButtonAction?
    
    // MARK: - Initialization
    
    convenience init() {
        self.init(frame: .zero)
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setup()
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        setup()
    }
    
    // MARK: - Setup
    
    /// Sets up the default properties
    func setup() {
        contentVerticalAlignment = .center
        contentHorizontalAlignment = .center
        imageView?.contentMode = .scaleAspectFit
        setContentHuggingPriority(UILayoutPriority(rawValue: 500), for: .horizontal)
        setContentHuggingPriority(UILayoutPriority(rawValue: 500), for: .vertical)
        tintColor = UIColor._2499090()
        adjustsImageWhenHighlighted = false
        addTarget(self, action: #selector(touchUpInsideAction), for: .touchUpInside)
    }
    
    // MARK: - Size Adjustment
    
    /// Sets the size of the InputBarButtonItem which overrides the intrinsicContentSize. When set to nil
    /// the default intrinsicContentSize is used. The new size will be laid out in the UIStackView that
    /// the InputBarButtonItem is held in
    ///
    /// - Parameters:
    ///   - newValue: The new size
    ///   - animated: If the layout should be animated
    func setSize(_ newValue: CGSize?, animated: Bool) {
        size = newValue
        if animated, let position = parentStackViewPosition {
            faeInputBar?.performLayout(animated) { [weak self] in
                self?.faeInputBar?.layoutStackViews([position])
            }
        }
    }
    
    // MARK: - Hook Setup Methods
    
    /// Used to setup your own initial properties
    ///
    /// - Parameter item: A reference to Self
    /// - Returns: Self
    @discardableResult
    func configure(_ item: ChatInputBarButtonAction) -> Self {
        item(self)
        return self
    }
    
    /// Sets the onTouchUpInsideAction
    ///
    /// - Parameter action: The new onTouchUpInsideAction
    /// - Returns: Self
    @discardableResult
    func onTouchUpInside(_ action: @escaping ChatInputBarButtonAction) -> Self {
        onTouchUpInsideAction = action
        return self
    }
    
    @discardableResult
    func onKeyboardEditingBeginsAction(_ action: @escaping ChatInputBarButtonAction) -> Self {
        onKeyboardEditingBeginsAction = action
        return self
    }
    
    @discardableResult
    func onKeyboardEditingEnds(_ action: @escaping ChatInputBarButtonAction) -> Self {
        onKeyboardEditingEndsAction = action
        return self
    }
    
    /// Executes the onTouchUpInsideAction
    @objc
    func touchUpInsideAction() {
        onTouchUpInsideAction?(self)
    }
    
    /// Executes the onKeyboardEditingEndsAction
    func keyboardEditingEndsAction() {
        onKeyboardEditingEndsAction?(self)
    }
    
    /// Executes the onKeyboardEditingBeginsAction
    func keyboardEditingBeginsAction() {
        onKeyboardEditingBeginsAction?(self)
    }
    
    // MARK: - Static Spacers
    
    /// An InputBarButtonItem that's spacing property is set to be .flexible
    static var flexibleSpace: ChatInputBarButton {
        let item = ChatInputBarButton()
        item.setSize(.zero, animated: false)
        item.spacing = .flexible
        return item
    }
    
    /// An InputBarButtonItem that's spacing property is set to be .fixed with the width arguement
    class func fixedSpace(_ width: CGFloat) -> ChatInputBarButton {
        let item = ChatInputBarButton()
        item.setSize(.zero, animated: false)
        item.spacing = .fixed(width)
        return item
    }
}
