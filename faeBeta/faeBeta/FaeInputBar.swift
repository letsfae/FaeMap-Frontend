//
//  FaeInputBar.swift
//  faeBeta
//
//  Created by Jichao on 2018/6/2.
//  Copyright © 2018年 fae. All rights reserved.
//

import UIKit

class FaeInputBar: UIView {
    
    weak var delegate: FaeInputBarDelegate?
    var backgroundView: UIView = {
        let view = UIView()
        view.translatesAutoresizingMaskIntoConstraints = false
        view.backgroundColor = .white
        return view
    }()
    
    var contentView: UIView = {
        let view = UIView()
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()
    
    let separatorLineTop = SeparatorLine()
    let separatorLineMiddle = SeparatorLine()
    
    let topStackView: ChatInputStackView = {
        let stackView = ChatInputStackView(axis: .horizontal, spacing: 0)
        stackView.alignment = .fill
        return stackView
    }()
    var boolHasPin: Bool {
        return topStackView.arrangedSubviews.count > 0
    }
    
    let rightStackView = ChatInputStackView(axis: .horizontal, spacing: 0)
    
    let bottomStackView: ChatInputStackView = {
        let stackView = ChatInputStackView(axis: .horizontal, spacing: 12)
        stackView.distribution = .equalCentering
        return stackView
    }()
    
    lazy var inputTextView: ChatInputTextView = {
        let textView = ChatInputTextView()
        textView.translatesAutoresizingMaskIntoConstraints = false
        textView.faeInputBar = self
        return textView
    }()
    
    var padding: UIEdgeInsets = UIEdgeInsets(top: 6, left: 12, bottom: 6, right: 6) {
        didSet {
            updatePadding()
        }
    }
    
    var topStackViewPadding: UIEdgeInsets = UIEdgeInsets(top: 0, left: 0, bottom: 0, right: 0) {
        didSet {
            updateTopStackViewPadding()
        }
    }
    
    var textViewPadding: UIEdgeInsets = UIEdgeInsets(top: 0, left: 0, bottom: 15, right: 8) {
        didSet {
            updateTextViewPadding()
        }
    }
    
    override var intrinsicContentSize: CGSize {
        return cachedIntrinsicContentSize
    }
    private(set) var previousIntrinsicContentSize: CGSize?
    private lazy var cachedIntrinsicContentSize: CGSize = calculateIntrinsicContentSize()
    
    private(set) var isOverMaxTextViewHeight = false
    
    var maxTextViewHeight: CGFloat = 0 {
        didSet {
            textViewHeightAnchor?.constant = maxTextViewHeight
            invalidateIntrinsicContentSize()
        }
    }
    
    var requiredInputTextViewHeight: CGFloat {
        let maxTextViewSize = CGSize(width: inputTextView.bounds.width, height: .greatestFiniteMagnitude)
        return inputTextView.sizeThatFits(maxTextViewSize).height.rounded(.down)
    }
    
    private(set) var rightStackViewWidthConstant: CGFloat = 52 {
        didSet {
            rightStackViewLayoutSet?.width?.constant = rightStackViewWidthConstant
        }
    }
    
    private(set) var rightStackViewItems: [ChatInputBarButton] = []
    private(set) var bottomStackViewItems: [ChatInputBarButton] = []
    private var sendButton: ChatInputBarButton!
    var items: [ChatInputBarButton] {
        return [rightStackViewItems, bottomStackViewItems].flatMap { $0 }
    }
    
    
    private var textViewLayoutSet: NSLayoutConstraintSet?
    private var textViewHeightAnchor: NSLayoutConstraint?
    private var topStackViewLayoutSet: NSLayoutConstraintSet?
    private var rightStackViewLayoutSet: NSLayoutConstraintSet?
    private var bottomStackViewLayoutSet: NSLayoutConstraintSet?
    private var contentViewLayoutSet: NSLayoutConstraintSet?
    private var windowAnchor: NSLayoutConstraint?
    private var backgroundViewBottomAnchor: NSLayoutConstraint?
    
    var viewStickerPicker: StickerKeyboardView!
    var faePhotoPicker: FaePhotoPicker!
    var btnQuickSendImage: UIButton!
    var viewAudioRecorder: AudioRecorderView!
    var viewMiniLoc = LocationPickerMini()
    enum InputView: Int {
        case keyboard, sticker, photo, camera, recorder, map, send
    }
    var currentInputView: InputView = .keyboard {
        didSet {
            defer {
                inputTextView.currentInputView = currentInputView
            }
        }
    }
    var imgHeart: UIImageView!
    var imgHeartDic: [CAAnimation: UIImageView] = [CAAnimation: UIImageView]()
    var animatingHeartTimer: Timer!
    
    var boolIsFirstShown: Bool = true
    
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
    
    
    func calculateIntrinsicContentSize() -> CGSize {
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
    
    private func setupSubviews() {
        //setupTopStackView()
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
            right: rightStackView.rightAnchor.constraint(equalTo: contentView.rightAnchor, constant: 0),
            width: rightStackView.widthAnchor.constraint(equalToConstant: rightStackViewWidthConstant)
        )
        
        separatorLineMiddle.addConstraints(inputTextView.bottomAnchor, left: leftAnchor, right: rightAnchor, topConstant: 10, leftConstant: 10, rightConstant: 10)
        
        bottomStackViewLayoutSet = NSLayoutConstraintSet(
            top: bottomStackView.topAnchor.constraint(equalTo: inputTextView.bottomAnchor, constant: textViewPadding.bottom),
            bottom: bottomStackView.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: 0),
            left: bottomStackView.leftAnchor.constraint(equalTo: contentView.leftAnchor, constant: 5),
            right: bottomStackView.rightAnchor.constraint(equalTo: contentView.rightAnchor, constant: -5)
        )
        activateConstraints()
    }
    
    private func setupRightStackView() {
        let items = [makeButton(named: "pinDetailLikeHeartHollow", tag: 7)]
        imgHeart = items[0].imageView!
        let heart = FaeHeartButton()
        heart.delegate = self
        performLayout(false) {
            //self.rightStackViewItems = items
            /*self.rightStackViewItems.forEach {
                $0.parentStackViewPosition = .right
                self.rightStackView.addArrangedSubview($0)
            }*/
            self.rightStackView.addArrangedSubview(heart)
            guard self.superview != nil else { return }
            self.rightStackView.layoutIfNeeded()
            self.invalidateIntrinsicContentSize()
        }
    }
    
    private func setupBottomStackView() {
        let items = [
            makeButton(named: "keyboardEnd", tag: InputView.keyboard.rawValue, highlight: "keyboard"),
            makeButton(named: "sticker", tag: InputView.sticker.rawValue, highlight: "stickerChosen"),
            makeButton(named: "imagePicker", tag: InputView.photo.rawValue, highlight: "imagePickerChosen"),
            makeButton(named: "camera", tag: InputView.camera.rawValue, highlight: ""),
            makeButton(named: "voiceMessage", tag: InputView.recorder.rawValue, highlight: "voiceMessage_red"),
            makeButton(named: "shareLocation", tag: InputView.map.rawValue, highlight: "locationChosen"),
            makeButton(named: "cannotSendMessage", tag: InputView.send.rawValue, highlight: "canSendMessage").configure { btn in
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
    
    func makeButton(named: String, tag: Int, highlight: String? = "") -> ChatInputBarButton {
        return ChatInputBarButton()
            .configure {
                $0.spacing = .fixed(10)
                $0.setSize(CGSize(width: 29, height: 29), animated: false)
                $0.tag = tag
                $0.imageNormalName = named
                $0.imageSelectedName = highlight
                $0.isSelected = false
            }.onTouchUpInside { button in
                if button.tag == InputView.send.rawValue {
                    let trimmedText = self.inputTextView.text.trimmingCharacters(in: .whitespacesAndNewlines)
                    if self.boolHasPin, let pinView = self.topStackView.arrangedSubviews[0] as? InputBarTopPinView {
                        self.delegate?.faeInputBar(self, didPressSendButtonWith: trimmedText, with: pinView)

                    } else {
                        self.delegate?.faeInputBar(self, didPressSendButtonWith: trimmedText, with: nil)
                    }
                } else {
                    self.currentInputView = InputView(rawValue: button.tag)!
                    for btn in self.bottomStackViewItems {
                        if btn.tag != InputView.send.rawValue {
                            btn.isSelected = btn.tag == button.tag
                        }
                    }
                    //UIView.setAnimationsEnabled(false)
                    //UIView.animate(withDuration: 0.3, animations: {
                    //self.inputTextView.resignFirstResponder()
                        if button.tag == 0 {
                            self.inputTextView.inputView = nil
                        } else {
                            self.inputTextView.inputView = self.setupInputView(button.tag)
                        }
                        self.inputTextView.reloadInputViews()
                        //UIView.setAnimationsEnabled(true)
                        self.inputTextView.becomeFirstResponder()
                        //self.superview?.superview?.layoutIfNeeded()
                    //})
                }
        }
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
    
    func setStackViewItems(_ items: [ChatInputBarButton], forStack position: ChatInputStackView.Position, animated: Bool) {
        
        func setNewItems() {
            switch position {
            case .right:
                rightStackView.arrangedSubviews.forEach { $0.removeFromSuperview() }
                rightStackViewItems = items
                rightStackViewItems.forEach {
                    //$0.messageInputBar = self
                    $0.parentStackViewPosition = position
                    rightStackView.addArrangedSubview($0)
                }
                guard superview != nil else { return }
                rightStackView.layoutIfNeeded()
            case .bottom:
                bottomStackView.arrangedSubviews.forEach { $0.removeFromSuperview() }
                bottomStackViewItems = items
                bottomStackViewItems.forEach {
                    //$0.messageInputBar = self
                    $0.parentStackViewPosition = position
                    bottomStackView.addArrangedSubview($0)
                }
                guard superview != nil else { return }
                bottomStackView.layoutIfNeeded()
            default: break
            }
            invalidateIntrinsicContentSize()
        }
        
        performLayout(animated) {
            setNewItems()
        }
    }
    
    func calculateMaxTextViewHeight() -> CGFloat {
        if traitCollection.verticalSizeClass == .regular {
            return (UIScreen.main.bounds.height / 3).rounded(.down)
        }
        return (UIScreen.main.bounds.height / 5).rounded(.down)
    }
    
    override func traitCollectionDidChange(_ previousTraitCollection: UITraitCollection?) {
        super.traitCollectionDidChange(previousTraitCollection)
        if traitCollection.verticalSizeClass != previousTraitCollection?.verticalSizeClass || traitCollection.horizontalSizeClass != previousTraitCollection?.horizontalSizeClass {
            maxTextViewHeight = calculateMaxTextViewHeight()
            invalidateIntrinsicContentSize()
        }
    }
    
    @objc
    func textViewDidChange() {
        let trimmedText = inputTextView.text.trimmingCharacters(in: .whitespacesAndNewlines)
        
        sendButton.isEnabled = !trimmedText.isEmpty
        inputTextView.placeholderLabel.isHidden = !inputTextView.text.isEmpty
        
        //items.forEach { $0.textViewDidChangeAction(with: inputTextView) }
        
        delegate?.faeInputBar(self, textViewTextDidChangeTo: trimmedText)
        
        if requiredInputTextViewHeight != inputTextView.bounds.height {
            // Prevent un-needed content size invalidation
            invalidateIntrinsicContentSize()
        }
    }
    
    /// Calls each items `keyboardEditingBeginsAction` method
    /// Invalidates the intrinsicContentSize so that the keyboard does not overlap the view
    @objc
    func textViewDidBeginEditing() {
        if inputTextView.isFirstResponder && !boolIsFirstShown {
            if currentInputView != .keyboard {
                UIView.performWithoutAnimation {
                    self.inputTextView.inputView = nil
                    self.inputTextView.reloadInputViews()
                    //self.inputTextView.resignFirstResponder()
                    self.currentInputView = .keyboard
                    for btn in self.bottomStackViewItems {
                        if btn.tag == InputView.keyboard.rawValue {
                            btn.isSelected = true
                        } else if btn.tag != InputView.send.rawValue {
                            btn.isSelected = false
                        }
                    }
                    //self.inputTextView.becomeFirstResponder()
                }
            }
        } else {
            if currentInputView == .keyboard {
                bottomStackViewItems[0].isSelected = true
                boolIsFirstShown = false
            }
        }
        /*bottomStackViewItems.forEach {
            if $0.tag == InputView.keyboard.rawValue {
                $0.isSelected = true
            }
        }*/
    }
    
    /// Calls each items `keyboardEditingEndsAction` method
    @objc
    func textViewDidEndEditing() {
        bottomStackViewItems.forEach {
            if $0.tag != InputView.send.rawValue {
                $0.isSelected = false
            } else {
                let trimmedText = inputTextView.text.trimmingCharacters(in: .whitespacesAndNewlines)
                $0.isEnabled = !trimmedText.isEmpty
            }
        }
        inputTextView.inputView = nil
        currentInputView = .keyboard
    }
}

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
            self.topStackView.addArrangedSubview(view)
            self.topStackView.sizeToFit()
            self.topStackView.layoutIfNeeded()
            self.invalidateIntrinsicContentSize()
        }
    }
    
    @objc func closeTopStackView() {
        topStackView.arrangedSubviews.first?.removeFromSuperview()
        topStackViewPadding = .zero
        invalidateIntrinsicContentSize()
        superview?.setNeedsLayout()
        superview?.layoutIfNeeded()
    }
}

extension FaeInputBar: SendStickerDelegate, LocationPickerMiniDelegate, AudioRecorderViewDelegate {
    
    func setupInputView(_ tag: Int) -> UIView {
        let floatInputViewHeight: CGFloat = 271 + device_offset_bot
        switch tag {
        case 1:
            viewStickerPicker = StickerKeyboardView(frame: CGRect(x: 0, y: 0, width: screenWidth, height: floatInputViewHeight))
            viewStickerPicker.delegate = self
            return viewStickerPicker
        case 2:
            var configure = FaePhotoPickerConfigure()
            configure.boolFullPicker = false
            configure.sizeThumbnail = CGSize(width: 220, height: floatInputViewHeight)
            
            faePhotoPicker = FaePhotoPicker(frame: CGRect(x: 0, y: 0, width: frame.width, height: floatInputViewHeight), with: configure)
            
            faePhotoPicker.selectHandler = observeOnSelectedCount
            
            let btnMoreImage = UIButton(frame: CGRect(x: 10, y: floatInputViewHeight - 52 - device_offset_bot, width: 42, height: 42))
            btnMoreImage.setImage(UIImage(named: "moreImage"), for: UIControlState())
            btnMoreImage.addTarget(self, action: #selector(showFullAlbum), for: .touchUpInside)
            faePhotoPicker.addSubview(btnMoreImage)
            
            btnQuickSendImage = UIButton(frame: CGRect(x: floatInputViewHeight - 52, y: floatInputViewHeight - 52 - device_offset_bot, width: 42, height: 42))
            btnQuickSendImage.addTarget(self, action: #selector(sendImageFromQuickPicker), for: .touchUpInside)
            btnQuickSendImage.setImage(UIImage(named: "imageQuickSend"), for: UIControlState())
            return faePhotoPicker
        case 4:
            viewAudioRecorder = AudioRecorderView(frame: CGRect(x: 0, y: 0, width: frame.width, height: floatInputViewHeight))
            viewAudioRecorder.backgroundColor = backgroundView.backgroundColor
            viewAudioRecorder.delegate = self
            return viewAudioRecorder
        case 5:
            //let viewMiniLoc = LocationPickerMini()
            viewMiniLoc.delegate = self
            return viewMiniLoc
        default: break
        }
        return UIView()
    }
    
    func sendStickerWithImageName(_ name: String) {
        delegate?.faeInputBar(self, didSendStickerWith: name, isFaeHeart: false)
    }
    
    func appendEmojiWithImageName(_ name: String) { }
    
    func deleteEmoji() { }
    
    
    @objc func showFullAlbum() {
        delegate?.faeInputBar(self, showFullAlbumWith: faePhotoPicker)
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
    
    func showFullLocationView() {
        delegate?.faeInputBar(self, showFullLocation: true)
    }
    
    func sendLocationMessageFromMini(_ locationPickerMini: LocationPickerMini) {
        UIGraphicsBeginImageContext(locationPickerMini.frame.size)
        locationPickerMini.layer.render(in: UIGraphicsGetCurrentContext()!)
        if let thunbmnail = UIGraphicsGetImageFromCurrentImageContext() {
            let center = locationPickerMini.mapView.camera.centerCoordinate
            let location = CLLocation(latitude: center.latitude, longitude: center.longitude)
            CLGeocoder().reverseGeocodeLocation(location) { (placemarks, error) in
                guard let response = placemarks?[0] else {
                    return // TODO
                }
                self.setupTopStackView(placemark: response, thumbnail: thunbmnail)
            }
        }
    }
    
    //
    func audioRecorderView(_ audioView: AudioRecorderView, needToSendAudioData data: Data) {
        delegate?.faeInputBar(self, needToSendAudioData: data)
    }
    
}

extension FaeInputBar: FaeHeartButtonDelegate {
    func faeHeartButton(_ faeHeartButton: FaeHeartButton) {
        delegate?.faeInputBar(self, didSendStickerWith: "", isFaeHeart: true)
    }
    
    
}

