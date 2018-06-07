//
//  ChatInputTextView.swift
//  faeBeta
//
//  Created by Jichao on 2018/6/2.
//  Copyright © 2018年 fae. All rights reserved.
//

import UIKit

class ChatInputTextView: UITextView {
    
    // MARK: - Properties
    
    open override var text: String! {
        didSet {
            postTextViewDidChangeNotification()
            placeholderLabel.isHidden = !text.isEmpty
        }
    }
    
    /// A UILabel that holds the InputTextView's placeholder text
    open let placeholderLabel: UILabel = {
        let label = UILabel()
        label.numberOfLines = 0
        label.textColor = .lightGray
        label.text = "Type something..."
        label.backgroundColor = .clear
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    /// The placeholder text that appears when there is no text. The default value is "New Message"
    open var placeholder: String? = "Type something..." {
        didSet {
            placeholderLabel.text = placeholder
        }
    }
    
    /// The placeholderLabel's textColor
    open var placeholderTextColor: UIColor? = .lightGray {
        didSet {
            placeholderLabel.textColor = placeholderTextColor
        }
    }
    
    /// The UIEdgeInsets the placeholderLabel has within the InputTextView
    open var placeholderLabelInsets: UIEdgeInsets = UIEdgeInsets(top: 4, left: 7, bottom: 4, right: 7) {
        didSet {
            updateConstraintsForPlaceholderLabel()
        }
    }
    
    /// The font of the InputTextView. When set the placeholderLabel's font is also updated
    open override var font: UIFont! {
        didSet {
            placeholderLabel.font = font
        }
    }
    
    /// The textAlignment of the InputTextView. When set the placeholderLabel's textAlignment is also updated
    open override var textAlignment: NSTextAlignment {
        didSet {
            placeholderLabel.textAlignment = textAlignment
        }
    }
    
    open override var scrollIndicatorInsets: UIEdgeInsets {
        didSet {
            // When .zero a rendering issue can occur
            if scrollIndicatorInsets == .zero {
                scrollIndicatorInsets = UIEdgeInsets(top: .leastNonzeroMagnitude,
                                                     left: .leastNonzeroMagnitude,
                                                     bottom: .leastNonzeroMagnitude,
                                                     right: .leastNonzeroMagnitude)
            }
        }
    }
    
    /// A weak reference to the MessageInputBar that the InputTextView is contained within
    weak var faeInputBar: FaeInputBar?
    var currentInputView: FaeInputBar.InputView = .keyboard
    
    /// The constraints of the placeholderLabel
    private var placeholderLabelConstraintSet: NSLayoutConstraintSet?
    
    // MARK: - Initializers
    
    public convenience init() {
        self.init(frame: .zero)
    }
    
    public override init(frame: CGRect, textContainer: NSTextContainer?) {
        super.init(frame: frame, textContainer: textContainer)
        setup()
    }
    
    required public init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        setup()
    }
    
    // MARK: - Setup
    
    /// Sets up the default properties
    open func setup() {
        
        font = UIFont.preferredFont(forTextStyle: .body)
        textContainerInset = UIEdgeInsets(top: 4, left: 4, bottom: 4, right: 4)
        scrollIndicatorInsets = UIEdgeInsets(top: .leastNonzeroMagnitude,
                                             left: .leastNonzeroMagnitude,
                                             bottom: .leastNonzeroMagnitude,
                                             right: .leastNonzeroMagnitude)
        isScrollEnabled = false
        allowsEditingTextAttributes = false
        setupPlaceholderLabel()
    }
    
    // swiftlint:disable colon
    /// Adds the placeholderLabel to the view and sets up its initial constraints
    private func setupPlaceholderLabel() {
        
        addSubview(placeholderLabel)
        placeholderLabelConstraintSet = NSLayoutConstraintSet(
            top:     placeholderLabel.topAnchor.constraint(equalTo: topAnchor, constant: placeholderLabelInsets.top),
            bottom:  placeholderLabel.bottomAnchor.constraint(equalTo: bottomAnchor, constant: -placeholderLabelInsets.bottom),
            left:    placeholderLabel.leftAnchor.constraint(equalTo: leftAnchor, constant: placeholderLabelInsets.left),
            right:   placeholderLabel.rightAnchor.constraint(equalTo: rightAnchor, constant: -placeholderLabelInsets.right),
            centerX: placeholderLabel.centerXAnchor.constraint(equalTo: centerXAnchor),
            centerY: placeholderLabel.centerYAnchor.constraint(equalTo: centerYAnchor)
        )
        placeholderLabelConstraintSet?.centerX?.priority = .defaultLow
        placeholderLabelConstraintSet?.centerY?.priority = .defaultLow
        placeholderLabelConstraintSet?.activate()
    }
    // swiftlint:enable colon
    
    /// Adds the required notification observers
    
    /// Updates the placeholderLabels constraint constants to match the placeholderLabelInsets
    private func updateConstraintsForPlaceholderLabel() {
        
        placeholderLabelConstraintSet?.top?.constant = placeholderLabelInsets.top
        placeholderLabelConstraintSet?.bottom?.constant = -placeholderLabelInsets.bottom
        placeholderLabelConstraintSet?.left?.constant = placeholderLabelInsets.left
        placeholderLabelConstraintSet?.right?.constant = -placeholderLabelInsets.right
    }
    
    // MARK: - Notification
    
    private func postTextViewDidChangeNotification() {
        NotificationCenter.default.post(name: .UITextViewTextDidChange, object: self)
    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        super.touchesBegan(touches, with: event)
        if let touch = touches.first {
            if touch.view == self {
                NotificationCenter.default.post(name: .UITextViewTextDidBeginEditing, object: self)
            }
        }
    }
    
    override func canPerformAction(_ action: Selector, withSender sender: Any?) -> Bool {
        if currentInputView != .keyboard {
            return false
        }
        return super.canPerformAction(action, withSender: sender)
    }
    
}
