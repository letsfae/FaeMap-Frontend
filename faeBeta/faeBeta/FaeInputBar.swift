//
//  FaeInputBar.swift
//  faeBeta
//
//  Created by Jichao on 2018/6/2.
//  Copyright © 2018年 fae. All rights reserved.
//

import UIKit
import Photos

class FaeInputBar: UIView {
    // MARK: - Properties
    
    weak var delegate: FaeInputBarDelegate?
    
    /// The backgroundView anchored to the bottom, left, and right of the FaeInputBar
    /// which leaves a safe area for iPhone X
    private var backgroundView: UIView = {
        let view = UIView()
        view.translatesAutoresizingMaskIntoConstraints = false
        view.backgroundColor = .white
        return view
    }()
    
    /// The contentView holds the InputTextView and the right/bottom InputStackView
    private var contentView: UIView = {
        let view = UIView()
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()
    
    /// The separator line at the top
    private let separatorLineTop: SeparatorLine = {
        let line = SeparatorLine()
        line.height = 1.0
        line.backgroundColor = UIColor._200199204()
        return line
    }()
    
    /// The separator line between InputTextView and bottomStackView
    private let separatorLineMiddle: SeparatorLine = {
        let line = SeparatorLine()
        line.height = 1.0
        line.backgroundColor = UIColor._200199204()
        return line
    }()
    
    /// The topStackView holds the place/location pin details
    private let topStackView: ChatInputStackView = {
        let stackView = ChatInputStackView(axis: .horizontal, spacing: 0)
        stackView.alignment = .fill
        return stackView
    }()
    
    /// Determines if the topStackView should be shown
    private var boolHasPin: Bool {
        return topStackView.arrangedSubviews.count > 0
    }
    
    /// The rightSrackView holds the FaeHeartButton
    private let rightStackView: ChatInputStackView = {
        let stackView = ChatInputStackView(axis: .vertical, spacing: 0)
        stackView.distribution = .equalSpacing
        return stackView
    }()
    
    /// The bottonStackView holds InputBarButton,
    /// including keyboard, sticker, photo, camera, recorder, map, send
    private let bottomStackView: ChatInputStackView = {
        let stackView = ChatInputStackView(axis: .horizontal, spacing: 12)
        stackView.distribution = .equalCentering
        return stackView
    }()
    
    /// The InputTextView where user types in
    lazy var inputTextView: ChatInputTextView = {
        let textView = ChatInputTextView()
        textView.translatesAutoresizingMaskIntoConstraints = false
        textView.faeInputBar = self
        return textView
    }()
    
    /// The anchor constants that inset the contentView
    private var padding: UIEdgeInsets = UIEdgeInsets(top: 6, left: 12, bottom: 6, right: 6) {
        didSet {
            updatePadding()
        }
    }
    
    /// The anchor constants used by the topStackView
    private var topStackViewPadding: UIEdgeInsets = UIEdgeInsets(top: 0, left: 0, bottom: 0, right: 0) {
        didSet {
            updateTopStackViewPadding()
        }
    }
    
    /// The anchor constants used by the InputTextView
    private var textViewPadding: UIEdgeInsets = UIEdgeInsets(top: 3, left: 0, bottom: 12, right: 8) {
        didSet {
            updateTextViewPadding()
        }
    }
    
    /// Returns the mose recent size calculated by `calculateIntrinsicContentSize()`
    override var intrinsicContentSize: CGSize {
        return cachedIntrinsicContentSize
    }
    
    /// Decreases the times of calling delegate to post intrinsicContentSize changing
    private(set) var previousIntrinsicContentSize: CGSize?
    
    /// The most recent calculation of the intrinsicContentSize
    private lazy var cachedIntrinsicContentSize: CGSize = calculateIntrinsicContentSize()
    
    /// Determines if the maxTextViewHeight has been met
    private(set) var isOverMaxTextViewHeight = false
    
    /// The maximum height the InputTextView can reach
    private var maxTextViewHeight: CGFloat = 0 {
        didSet {
            textViewHeightAnchor?.constant = maxTextViewHeight
            invalidateIntrinsicContentSize()
        }
    }
    
    /// The height that will fit the current text in the InputTextView based on its current bounds
    private var requiredInputTextViewHeight: CGFloat {
        let maxTextViewSize = CGSize(width: inputTextView.bounds.width, height: .greatestFiniteMagnitude)
        return inputTextView.sizeThatFits(maxTextViewSize).height.rounded(.down)
    }
    
    /// The fixed widthAnchor constant of the rightStackView
    private(set) var rightStackViewWidthConstant: CGFloat = 31 {
        didSet {
            rightStackViewLayoutSet?.width?.constant = rightStackViewWidthConstant
        }
    }
    
    /// Buttons within FaeInputBar
    private(set) var rightStackViewItems: [ChatInputBarButton] = []
    private(set) var bottomStackViewItems: [ChatInputBarButton] = []
    private var sendButton: ChatInputBarButton!
    
    // MARK: Auto-Layout management
    private var textViewLayoutSet: NSLayoutConstraintSet?
    private var textViewHeightAnchor: NSLayoutConstraint?
    private var topStackViewLayoutSet: NSLayoutConstraintSet?
    private var rightStackViewLayoutSet: NSLayoutConstraintSet?
    private var bottomStackViewLayoutSet: NSLayoutConstraintSet?
    private var contentViewLayoutSet: NSLayoutConstraintSet?
    private var windowAnchor: NSLayoutConstraint?
    private var backgroundViewBottomAnchor: NSLayoutConstraint?
    
    // MARK: Views in InputView
    var viewStickerPicker: StickerKeyboardView!
    var faePhotoPicker: FaePhotoPicker!
    var btnQuickSendImage: UIButton!
    var viewAudioRecorder: AudioRecorderView!
    //var viewMiniLoc: LocationPickerMini!
    var viewMiniLoc: LocationMiniPicker!
    
    var prevInputView: UIView?
    
    enum InputViewType: Int {
        case keyboard, sticker, photo, camera, recorder, map, send
    }
    /// Current inputView type
    var currentInputViewType: InputViewType = .keyboard {
        didSet {
            inputTextView.boolPreventMenu = oldValue != .keyboard
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
                self.inputTextView.boolPreventMenu = false
            }
        }
    }
    var prevInputViewType: InputViewType = .keyboard
    
    /// FaeInputBar has shown for at least once
    var boolIsFirstShown: Bool = true
    
    // iOS Geocoder
    let clgeocoder = CLGeocoder()
    
    // MARK: - init
    override init(frame: CGRect) {
        super.init(frame: frame)
        setup()
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    deinit {
        NotificationCenter.default.removeObserver(self)
    }
    
    override func didMoveToWindow() {
        super.didMoveToWindow()
        setupConstraints(to: window)
    }
    
    // MARK: - Setup
    private func setup() {
        autoresizingMask = [.flexibleHeight]
        setupSubviews()
        setupConstraints()
        setupObservers()
    }
    
    private func setupObservers() {
        NotificationCenter.default.addObserver(self, selector: #selector(textViewDidChange), name: .UITextViewTextDidChange, object: inputTextView)
        NotificationCenter.default.addObserver(self, selector: #selector(textViewDidBeginEditing), name: .UITextViewTextDidBeginEditing, object: inputTextView)
        NotificationCenter.default.addObserver(self, selector: #selector(textViewDidEndEditing), name: .UITextViewTextDidEndEditing, object: inputTextView)
    }
    
    private func setupSubviews() {
        setupRightStackView()
        setupBottomStackView()
        addSubview(backgroundView)
        addSubview(topStackView)
        addSubview(contentView)
        addSubview(separatorLineTop)
        contentView.addSubview(inputTextView)
        contentView.addSubview(rightStackView)
        contentView.addSubview(separatorLineMiddle)
        contentView.addSubview(bottomStackView)
    }
    
    private func setupRightStackView() {
        let heart = FaeHeartButton()
        heart.delegate = self
        performLayout(false) {
            self.rightStackView.addArrangedSubview(heart)
            guard self.superview != nil else { return }
            self.rightStackView.layoutIfNeeded()
            self.invalidateIntrinsicContentSize()
        }
    }
    
    private func setupBottomStackView() {
        let items = [
            makeButton(named: "keyboardEnd", tag: InputViewType.keyboard.rawValue, highlight: "keyboard"),
            makeButton(named: "sticker", tag: InputViewType.sticker.rawValue, highlight: "stickerChosen"),
            makeButton(named: "imagePicker", tag: InputViewType.photo.rawValue, highlight: "imagePickerChosen"),
            makeButton(named: "camera", tag: InputViewType.camera.rawValue, highlight: ""),
            makeButton(named: "voiceMessage", tag: InputViewType.recorder.rawValue, highlight: "voiceMessage_red"),
            makeButton(named: "shareLocation", tag: InputViewType.map.rawValue, highlight: "locationChosen"),
            makeButton(named: "cannotSendMessage", tag: InputViewType.send.rawValue, highlight: "canSendMessage").configure { btn in
                btn.isEnabled = false
            }
        ]
        sendButton = items.last!
        performLayout(false) {
            self.bottomStackViewItems = items
            self.bottomStackViewItems.forEach {
                $0.parentStackViewPosition = .bottom
                self.bottomStackView.addArrangedSubview($0)
            }
            guard self.superview != nil else { return }
            self.bottomStackView.layoutIfNeeded()
            self.invalidateIntrinsicContentSize()
        }
    }
    
    private func setupConstraints() {
        separatorLineTop.addConstraints(topAnchor, left: leftAnchor, right: rightAnchor)
        backgroundViewBottomAnchor = backgroundView.bottomAnchor.constraint(equalTo: bottomAnchor)
        backgroundViewBottomAnchor?.isActive = true
        backgroundView.addConstraints(topStackView.bottomAnchor, left: leftAnchor, right: rightAnchor)
        
        topStackViewLayoutSet = NSLayoutConstraintSet(
            top: topStackView.topAnchor.constraint(equalTo: topAnchor, constant: topStackViewPadding.top),
            bottom: topStackView.bottomAnchor.constraint(equalTo: contentView.topAnchor, constant: -padding.top),
            left: topStackView.leftAnchor.constraint(equalTo: leftAnchor, constant: topStackViewPadding.left),
            right: topStackView.rightAnchor.constraint(equalTo: rightAnchor, constant: -topStackViewPadding.right)
        )
        
        contentViewLayoutSet = NSLayoutConstraintSet(
            top: contentView.topAnchor.constraint(equalTo: topStackView.bottomAnchor, constant: padding.top),
            bottom: contentView.bottomAnchor.constraint(equalTo: bottomAnchor, constant: -padding.bottom),
            left: contentView.leftAnchor.constraint(equalTo: leftAnchor, constant: padding.left),
            right: contentView.rightAnchor.constraint(equalTo: rightAnchor, constant: -padding.right)
        )
        
        if #available(iOS 11.0, *) {
            contentViewLayoutSet?.bottom = contentView.bottomAnchor.constraint(equalTo: safeAreaLayoutGuide.bottomAnchor, constant: -padding.bottom)
            contentViewLayoutSet?.left = contentView.leftAnchor.constraint(equalTo: safeAreaLayoutGuide.leftAnchor, constant: padding.left)
            contentViewLayoutSet?.right = contentView.rightAnchor.constraint(equalTo: safeAreaLayoutGuide.rightAnchor, constant: -padding.right)
            
            topStackViewLayoutSet?.left = topStackView.leftAnchor.constraint(equalTo: safeAreaLayoutGuide.leftAnchor, constant: topStackViewPadding.left)
            topStackViewLayoutSet?.right = topStackView.rightAnchor.constraint(equalTo: safeAreaLayoutGuide.rightAnchor, constant: -topStackViewPadding.right)
        }
        
        textViewLayoutSet = NSLayoutConstraintSet(
            top: inputTextView.topAnchor.constraint(equalTo: contentView.topAnchor, constant: textViewPadding.top),
            bottom: inputTextView.bottomAnchor.constraint(equalTo: bottomStackView.topAnchor, constant: -textViewPadding.bottom),
            left: inputTextView.leftAnchor.constraint(equalTo: contentView.leftAnchor, constant: textViewPadding.left),
            right: inputTextView.rightAnchor.constraint(equalTo: rightStackView.leftAnchor, constant: -textViewPadding.right)
        )
        
        maxTextViewHeight = calculateMaxTextViewHeight()
        textViewHeightAnchor = inputTextView.heightAnchor.constraint(equalToConstant: maxTextViewHeight)
        
        rightStackViewLayoutSet = NSLayoutConstraintSet(
            top: rightStackView.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 0),
            bottom: rightStackView.bottomAnchor.constraint(equalTo: inputTextView.bottomAnchor, constant: 0),
            right: rightStackView.rightAnchor.constraint(equalTo: contentView.rightAnchor, constant: -10),
            width: rightStackView.widthAnchor.constraint(equalToConstant: rightStackViewWidthConstant)
        )
        
        separatorLineMiddle.addConstraints(inputTextView.bottomAnchor, left: leftAnchor, right: rightAnchor, topConstant: 4, leftConstant: 10, rightConstant: 10)
        
        bottomStackViewLayoutSet = NSLayoutConstraintSet(
            top: bottomStackView.topAnchor.constraint(equalTo: inputTextView.bottomAnchor, constant: textViewPadding.bottom),
            bottom: bottomStackView.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: 0),
            left: bottomStackView.leftAnchor.constraint(equalTo: contentView.leftAnchor, constant: 5),
            right: bottomStackView.rightAnchor.constraint(equalTo: contentView.rightAnchor, constant: -5)
        )
        activateConstraints()
    }
    
    private func setupConstraints(to window: UIWindow?) {
        if #available(iOS 11.0, *) {
            guard UIScreen.main.nativeBounds.height == 2436 else { return }
            if let window = window {
                windowAnchor?.isActive = false
                windowAnchor = contentView.bottomAnchor.constraintLessThanOrEqualToSystemSpacingBelow(window.safeAreaLayoutGuide.bottomAnchor, multiplier: 1)
                windowAnchor?.constant = -padding.bottom
                windowAnchor?.priority = UILayoutPriority(rawValue: 750)
                windowAnchor?.isActive = true
                backgroundViewBottomAnchor?.constant = 34
            }
        }
    }
    
    // MARK: - Constraint layout updates
    private func updatePadding() {
        topStackViewLayoutSet?.bottom?.constant = -padding.top
        contentViewLayoutSet?.top?.constant = padding.top
        contentViewLayoutSet?.left?.constant = padding.left
        contentViewLayoutSet?.right?.constant = -padding.right
        contentViewLayoutSet?.bottom?.constant = -padding.bottom
        windowAnchor?.constant = -padding.bottom
    }
    
    private func updateTextViewPadding() {
        textViewLayoutSet?.top?.constant = textViewPadding.top
        textViewLayoutSet?.left?.constant = textViewPadding.left
        textViewLayoutSet?.right?.constant = -textViewPadding.right
        textViewLayoutSet?.bottom?.constant = -textViewPadding.bottom
        bottomStackViewLayoutSet?.top?.constant = textViewPadding.bottom
    }
    
    private func updateTopStackViewPadding() {
        topStackViewLayoutSet?.top?.constant = topStackViewPadding.top
        topStackViewLayoutSet?.left?.constant = topStackViewPadding.left
        topStackViewLayoutSet?.right?.constant = -topStackViewPadding.right
    }
    
    override func invalidateIntrinsicContentSize() {
        super.invalidateIntrinsicContentSize()
        cachedIntrinsicContentSize = calculateIntrinsicContentSize()
        if previousIntrinsicContentSize != cachedIntrinsicContentSize {
            delegate?.faeInputBar(self, didChangeIntrinsicContentTo: cachedIntrinsicContentSize)
            previousIntrinsicContentSize = cachedIntrinsicContentSize
        }
    }
    
    // MARK: - Helper methods
    private func calculateIntrinsicContentSize() -> CGSize {
        var inputTextViewHeight = requiredInputTextViewHeight
        if inputTextViewHeight >= maxTextViewHeight {
            if !isOverMaxTextViewHeight {
                textViewHeightAnchor?.isActive = true
                inputTextView.isScrollEnabled = true
                isOverMaxTextViewHeight = true
            }
            inputTextViewHeight = maxTextViewHeight
        } else {
            if isOverMaxTextViewHeight {
                textViewHeightAnchor?.isActive = false
                inputTextView.isScrollEnabled = false
                isOverMaxTextViewHeight = false
                inputTextView.invalidateIntrinsicContentSize()
            }
        }
        
        let totalPadding = padding.top + padding.bottom + topStackViewPadding.top + textViewPadding.top + textViewPadding.bottom
        let topStackViewHeight = topStackView.arrangedSubviews.count > 0 ? topStackView.bounds.height : 0
        let bottomStackViewHeight = bottomStackView.bounds.height
        let verticalStackViewHeight = topStackViewHeight + bottomStackViewHeight
        let requiredHeight = inputTextViewHeight + totalPadding + verticalStackViewHeight
        return CGSize(width: bounds.width, height: requiredHeight)
    }
    
    func calculateMaxTextViewHeight() -> CGFloat {
        return 90
        /*if traitCollection.verticalSizeClass == .regular {
         return (UIScreen.main.bounds.height / 3).rounded(.down)
         }
         return (UIScreen.main.bounds.height / 5).rounded(.down)*/
    }
    
    func layoutStackViews(_ positions: [ChatInputStackView.Position] = [.left, .right, .bottom, .top]) {
        
        guard superview != nil else { return }
        
        for position in positions {
            switch position {
            case .left: break
                //leftStackView.setNeedsLayout()
            //leftStackView.layoutIfNeeded()
            case .right:
                rightStackView.setNeedsLayout()
                rightStackView.layoutIfNeeded()
            case .bottom:
                bottomStackView.setNeedsLayout()
                bottomStackView.layoutIfNeeded()
            case .top:
                topStackView.setNeedsLayout()
                topStackView.layoutIfNeeded()
            }
        }
    }
    
    func performLayout(_ animated: Bool, _ animations: @escaping () -> Void) {
        deactivateConstraints()
        if animated {
            DispatchQueue.main.async {
                UIView.animate(withDuration: 0.3, animations: animations)
            }
        } else {
            UIView.performWithoutAnimation { animations() }
        }
        activateConstraints()
    }
    
    private func activateConstraints() {
        contentViewLayoutSet?.activate()
        textViewLayoutSet?.activate()
        rightStackViewLayoutSet?.activate()
        bottomStackViewLayoutSet?.activate()
        topStackViewLayoutSet?.activate()
    }
    
    private func deactivateConstraints() {
        contentViewLayoutSet?.deactivate()
        textViewLayoutSet?.deactivate()
        rightStackViewLayoutSet?.deactivate()
        bottomStackViewLayoutSet?.deactivate()
        topStackViewLayoutSet?.deactivate()
    }
    
    private func toggleSendButton() {
        let trimmedText = inputTextView.text.trimmingCharacters(in: .whitespacesAndNewlines)
        sendButton.isEnabled = !trimmedText.isEmpty || boolHasPin
    }
    
    // MARK: - Button within bottomStackView configuration & actions
    private func makeButton(named: String, tag: Int, highlight: String? = "") -> ChatInputBarButton {
        return ChatInputBarButton()
            .configure {
                $0.spacing = .fixed(10)
                $0.setSize(CGSize(width: 29, height: 29), animated: false)
                $0.tag = tag
                $0.imageNormalName = named
                $0.imageSelectedName = highlight
                $0.isSelected = false
            }.onTouchUpInside { button in
                if button.tag == InputViewType.send.rawValue {
                    let trimmedText = self.inputTextView.text.trimmingCharacters(in: .whitespacesAndNewlines)
                    if self.boolHasPin, let pinView = self.topStackView.arrangedSubviews[0] as? InputBarTopPinView {
                        self.delegate?.faeInputBar(self, didPressSendButtonWith: trimmedText, with: pinView)
                        self.closeTopStackView()
                    } else {
                        self.delegate?.faeInputBar(self, didPressSendButtonWith: trimmedText, with: nil)
                    }
                } else if button.tag == InputViewType.camera.rawValue {
                    self.delegate?.faeInputBar(self, showFullView: "camera", with: nil)
                    self.inputTextView.inputView = nil
                    self.inputTextView.reloadInputViews()
                    self.prevInputView = nil
                } else {
                    //self.currentInputViewType = InputViewType(rawValue: button.tag)!
                    for btn in self.bottomStackViewItems {
                        if btn.tag != InputViewType.send.rawValue {
                            btn.isSelected = btn.tag == button.tag
                        }
                    }
                    if button.tag == InputViewType.keyboard.rawValue {
                        self.inputTextView.inputView = nil
                        self.currentInputViewType = InputViewType(rawValue: button.tag)!
                        self.inputTextView.reloadInputViews()
                        self.inputTextView.becomeFirstResponder()
                        self.prevInputView = nil
                    } else {
                        self.setupInputView(button.tag) { view in
                            if view == nil {
                                button.isSelected = false
                                if self.inputTextView.isFirstResponder {
                                    for btn in self.bottomStackViewItems {
                                        if btn.tag == self.currentInputViewType.rawValue {
                                            btn.isSelected = true
                                        }
                                    }
                                }
                            } else {
                                self.inputTextView.inputView = view
                                self.currentInputViewType = InputViewType(rawValue: button.tag)!
                                self.inputTextView.reloadInputViews()
                                self.inputTextView.becomeFirstResponder()
                            }
                        }
                    }
                }
        }
    }
    
    // MARK: - Notification actions
    @objc
    func textViewDidChange() {
        let trimmedText = inputTextView.text.trimmingCharacters(in: .whitespacesAndNewlines)
        
        /*sendButton.isEnabled = !trimmedText.isEmpty || boolHasPin*/
        toggleSendButton()
        inputTextView.placeholderLabel.isHidden = !inputTextView.text.isEmpty
        
        delegate?.faeInputBar(self, textViewTextDidChangeTo: trimmedText)
        
        if requiredInputTextViewHeight != inputTextView.bounds.height {
            // Prevent un-needed content size invalidation
            invalidateIntrinsicContentSize()
        }
    }
    
    @objc
    func textViewDidBeginEditing() {
        if inputTextView.isFirstResponder && !boolIsFirstShown {
            if currentInputViewType != .keyboard {
                UIView.performWithoutAnimation {
                    self.inputTextView.inputView = nil
                    self.inputTextView.reloadInputViews()
                    //self.inputTextView.resignFirstResponder()
                    self.currentInputViewType = .keyboard
                    for btn in self.bottomStackViewItems {
                        if btn.tag == InputViewType.keyboard.rawValue {
                            btn.isSelected = true
                        } else if btn.tag != InputViewType.send.rawValue {
                            btn.isSelected = false
                        }
                    }
                    //self.inputTextView.becomeFirstResponder()
                }
            }
        } else {
            if currentInputViewType == .keyboard {
                bottomStackViewItems[0].isSelected = true
            }
        }
        boolIsFirstShown = false
    }
    
    @objc
    func textViewDidEndEditing() {
        bottomStackViewItems.forEach {
            if $0.tag != InputViewType.send.rawValue {
                $0.isSelected = false
            } else {
                /*let trimmedText = inputTextView.text.trimmingCharacters(in: .whitespacesAndNewlines)
                $0.isEnabled = !trimmedText.isEmpty || boolHasPin*/
                toggleSendButton()
            }
        }
        inputTextView.inputView = nil
        currentInputViewType = .keyboard
        boolIsFirstShown = true
    }
}

// MARK: - Manage the topStackView holding the Pin details
extension FaeInputBar {
    func setupTopStackView(placemark: CLPlacemark? = nil, thumbnail: UIImage? = nil, place: PlacePin? = nil) {
        let view = InputBarTopPinView(frame: CGRect(x: 0, y: 0, width: screenWidth, height: 76))
        view.btnClose.addTarget(self, action: #selector(closeTopStackView), for: .touchUpInside)
        if let placemark = placemark {
            view.setToLocation()
            if let lines = placemark.addressDictionary?["FormattedAddressLines"] as? [String] {
                view.setLabel(texts: lines)
            }
            if let location = placemark.location {
                view.location = location
            }
            if let thumbnail = thumbnail {
                view.setThumbnail(image: thumbnail)
            }
        }
        if let place = place {
            view.placeData = place
            view.setToPlace()
            downloadImage(URL: place.imageURL) { (rawData) in
                guard let data = rawData, let imgae = UIImage(data: data) else { return }
                view.setThumbnail(image: imgae)
            }
        }
        //let wrapView = UIStackWrapView()
        //wrapView.addSubview(view)
        performLayout(false) {
            self.topStackView.arrangedSubviews.first?.removeFromSuperview()
            self.topStackView.addArrangedSubview(view)
            self.topStackView.sizeToFit()
            self.topStackView.layoutIfNeeded()
            self.invalidateIntrinsicContentSize()
            self.toggleSendButton()
        }
    }
    
    @objc func closeTopStackView() {
        topStackView.arrangedSubviews.first?.removeFromSuperview()
        topStackViewPadding = .zero
        invalidateIntrinsicContentSize()
        toggleSendButton()
        superview?.setNeedsLayout()
        superview?.layoutIfNeeded()
        NotificationCenter.default.post(name: NSNotification.Name(rawValue: "InputBarTopPinViewClose"), object: nil)
    }
}

// MARK: - InputView delegates
extension FaeInputBar: SendStickerDelegate, LocationMiniPickerDelegate, AudioRecorderViewDelegate {
    
    func setupInputView(_ tag: Int, complete: @escaping (UIView?) -> Void) {
        let floatInputViewHeight: CGFloat = 271 + device_offset_bot
        switch InputViewType(rawValue: tag) {
        case .sticker?:
            viewStickerPicker = StickerKeyboardView(frame: CGRect(x: 0, y: 0, width: screenWidth, height: floatInputViewHeight))
            viewStickerPicker.delegate = self
            complete(viewStickerPicker)
        case .photo?:
            
            func showLibrary() -> UIView {
                var configure = FaePhotoPickerConfigure()
                configure.boolFullPicker = false
                configure.sizeThumbnail = CGSize(width: 220, height: floatInputViewHeight)
                
                faePhotoPicker = FaePhotoPicker(frame: CGRect(x: 0, y: 0, width: frame.width, height: floatInputViewHeight), with: configure)
                
                faePhotoPicker.selectHandler = observeOnSelectedCount
                
                let btnMoreImage = UIButton(frame: CGRect(x: 10, y: floatInputViewHeight - 52 - device_offset_bot, width: 42, height: 42))
                btnMoreImage.setImage(UIImage(named: "moreImage"), for: UIControlState())
                btnMoreImage.addTarget(self, action: #selector(showFullAlbum), for: .touchUpInside)
                faePhotoPicker.addSubview(btnMoreImage)
                
                btnQuickSendImage = UIButton(frame: CGRect(x: screenWidth - 52, y: floatInputViewHeight - 52 - device_offset_bot, width: 42, height: 42))
                btnQuickSendImage.addTarget(self, action: #selector(sendImageFromQuickPicker), for: .touchUpInside)
                btnQuickSendImage.setImage(UIImage(named: "imageQuickSend"), for: UIControlState())
                faePhotoPicker.addSubview(btnQuickSendImage)
                btnQuickSendImage.isHidden = true
                
                return faePhotoPicker
            }
            if PHPhotoLibrary.authorizationStatus() != .authorized {
                //inputTextView.resignFirstResponder()
                PHPhotoLibrary.requestAuthorization { [weak self] status in
                    DispatchQueue.main.async {
                        if status != .authorized {
                            print("not authorized!")
                            let vc = self?.delegate as! ChatViewController
                            vc.showAlertView(withWarning: "Cannot use this function without authorization to Photo!")
                        } else {
                            complete(showLibrary())
                        }
                    }
                }
            } else {
                complete(showLibrary())
            }
        case .recorder?:
            viewAudioRecorder = AudioRecorderView(frame: CGRect(x: 0, y: 0, width: frame.width, height: floatInputViewHeight))
            viewAudioRecorder.backgroundColor = backgroundView.backgroundColor
            viewAudioRecorder.delegate = self
            complete(viewAudioRecorder)
        case .map?:
            //viewMiniLoc = LocationPickerMini()
            //viewMiniLoc.delegate = self
            viewMiniLoc = LocationMiniPicker(frame: CGRect(x: 0, y: 0, width: frame.width, height: floatInputViewHeight))
            viewMiniLoc.delegate = self
            complete(viewMiniLoc)
        default: break
        }
        complete(nil)
    }
    
    // MARK: SendStickerDelegate
    func sendStickerWithImageName(_ name: String) {
        delegate?.faeInputBar(self, didSendStickerWith: name, isFaeHeart: false)
    }
    
    func appendEmojiWithImageName(_ name: String) {
        inputTextView.insertText("[\(name)]")

    }
    
    func deleteEmoji() {
        let previous = inputTextView.text
        inputTextView.text = previous?.stringByDeletingLastEmoji()
    }
    
    // MARK: Quick photo picker button actions
    @objc func showFullAlbum() {
        delegate?.faeInputBar(self, showFullView: "photo", with: faePhotoPicker)
    }

    @objc func sendImageFromQuickPicker() {
        delegate?.faeInputBar(self, didPressQuickSendImages: faePhotoPicker.selectedAssets)
        faePhotoPicker.selectedAssets.removeAll()
        faePhotoPicker.updateSelectedOrder()
        btnQuickSendImage.isHidden = true
    }
    
    private func observeOnSelectedCount(_ count: Int) {
        btnQuickSendImage.isHidden = (count == 0)
    }
    
    // MARK: LocationMiniPickerDelegate
    func showFullLocationView(_ locationMiniPicker: LocationMiniPicker) {
        delegate?.faeInputBar(self, showFullView: "map", with: nil)
    }
    
    func selectLocation(_ locationMiniPicker: LocationMiniPicker, location: CLLocation) {
        UIGraphicsBeginImageContext(locationMiniPicker.frame.size)
        locationMiniPicker.layer.render(in: UIGraphicsGetCurrentContext()!)
        if let thunbmnail = UIGraphicsGetImageFromCurrentImageContext() {
            CLGeocoder().reverseGeocodeLocation(location) { (placemarks, error) in
                guard let response = placemarks?[0] else {
                    return // TODO
                }
                self.setupTopStackView(placemark: response, thumbnail: thunbmnail)
            }
        }
        NotificationCenter.default.post(name: NSNotification.Name(rawValue: "InputBarTopPinViewClose"), object: nil)
    }
    
    func selectPlacePin(_ locationMiniPicker: LocationMiniPicker, placePin: PlacePin) {
        setupTopStackView(place: placePin)
    }
    
    // MARK: LocationPickerMiniDelegate
    func showFullLocationView() {
        delegate?.faeInputBar(self, showFullView: "map", with: nil)
    }
    
    func sendLocationMessageFromMini(_ locationPickerMini: LocationPickerMini) {
        UIGraphicsBeginImageContext(locationPickerMini.frame.size)
        locationPickerMini.layer.render(in: UIGraphicsGetCurrentContext()!)
        if let thunbmnail = UIGraphicsGetImageFromCurrentImageContext() {
            let center = locationPickerMini.mapView.camera.centerCoordinate
            let location = CLLocation(latitude: center.latitude, longitude: center.longitude)
            clgeocoder.cancelGeocode()
            clgeocoder.reverseGeocodeLocation(location) { (placemarks, error) in
                guard let response = placemarks?[0] else {
                    return // TODO
                }
                self.setupTopStackView(placemark: response, thumbnail: thunbmnail)
            }
        }
    }
    
    // MARK: AudioRecorderViewDelegate
    func audioRecorderView(_ audioView: AudioRecorderView, needToSendAudioData data: Data) {
        delegate?.faeInputBar(self, needToSendAudioData: data)
    }
    
}

extension FaeInputBar: FaeHeartButtonDelegate {
    func faeHeartButton(_ faeHeartButton: FaeHeartButton) {
        delegate?.faeInputBar(self, didSendStickerWith: "", isFaeHeart: true)
    }
    
    
}

