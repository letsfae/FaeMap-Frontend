//
//  ECPLoadItems.swift
//  faeBeta
//
//  Created by Jacky on 1/11/17.
//  Copyright © 2017 fae. All rights reserved.
//

import UIKit

extension EditCommentPinViewController {
    func loadEditCommentPinItems() {
        buttonCancel = UIButton()
        buttonCancel.setImage(UIImage(named: "cancelEditCommentPin"), for: UIControlState())
        self.view.addSubview(buttonCancel)
        self.view.addConstraintsWithFormat("H:|-15-[v0(54)]", options: [], views: buttonCancel)
        self.view.addConstraintsWithFormat("V:|-28-[v0(25)]", options: [], views: buttonCancel)
        buttonCancel.addTarget(self,
                               action: #selector(self.actionCancelCommentPinEditing(_:)),
                               for: .touchUpInside)
        
        buttonSave = UIButton()
        buttonSave.titleLabel?.font = UIFont(name: "AvenirNext-Medium", size: 18)
        buttonSave.setTitle("Save", for: .normal)
        let buttonTitle = buttonSave.title(for: .normal)
        let attributedString = NSMutableAttributedString(string: buttonTitle!)
        attributedString.addAttribute(NSKernAttributeName, value: CGFloat(-0.46), range: NSRange(location: 0, length: buttonTitle!.characters.count))
        buttonSave.setAttributedTitle(attributedString, for: .normal)
        
        self.view.addSubview(buttonSave)
        self.view.addConstraintsWithFormat("H:[v0(38)]-15-|", options: [], views: buttonSave)
        self.view.addConstraintsWithFormat("V:|-28-[v0(25)]", options: [], views: buttonSave)
        buttonSave.addTarget(self,
                             action: #selector(self.actionUpdateCommentPinEditing(_:)),
                             for: .touchUpInside)
        
        labelTitle = UILabel()
        labelTitle.font = UIFont(name: "AvenirNext-Medium", size: 20)
        labelTitle.text = ""
        labelTitle.textColor = UIColor(red: 89/255, green: 89/255, blue: 89/255, alpha: 1.0)
        labelTitle.textAlignment = .center
        self.view.addSubview(labelTitle)
        self.view.addConstraintsWithFormat("H:[v0(133)]", options: [], views: labelTitle)
        self.view.addConstraintsWithFormat("V:|-28-[v0(27)]", options: [], views: labelTitle)
        NSLayoutConstraint(item: labelTitle, attribute: .centerX, relatedBy: .equal, toItem: self.view, attribute: .centerX, multiplier: 1.0, constant: 0).isActive = true
        
        uiviewLine = UIView(frame: CGRect(x: 0, y: 64, width: screenWidth, height: 1))
        uiviewLine.layer.borderWidth = screenWidth
        uiviewLine.layer.borderColor = UIColor(red: 200/255, green: 199/255, blue: 204/255, alpha: 1.0).cgColor
        self.view.addSubview(uiviewLine)
        
        var textViewWidth: CGFloat = 0
        if screenWidth == 414 { // 5.5
            textViewWidth = 360
        }
        else if screenWidth == 320 { // 4.0
            textViewWidth = 266
        }
        else if screenWidth == 375 { // 4.7
            textViewWidth = 321
        }
        textViewUpdateComment = UITextView(frame: CGRect(x: 27, y: 84, width: textViewWidth, height: 100))
        textViewUpdateComment.text = ""
        textViewUpdateComment.font = UIFont(name: "AvenirNext-Regular", size: 18)
        textViewUpdateComment.textColor = UIColor(red: 89/255, green: 89/255, blue: 89/255, alpha: 1.0)
        textViewUpdateComment.textContainerInset = UIEdgeInsets.zero
        textViewUpdateComment.indicatorStyle = UIScrollViewIndicatorStyle.white
        textViewUpdateComment.text = previousCommentContent
        textViewUpdateComment.delegate = self
        self.view.addSubview(textViewUpdateComment)
        UITextView.appearance().tintColor = UIColor.faeAppRedColor()
        
        labelTextViewPlaceholder = UILabel(frame: CGRect(x: 2, y: 0, width: 171, height: 27))
        labelTextViewPlaceholder.font = UIFont(name: "AvenirNext-Regular", size: 18)
        labelTextViewPlaceholder.textColor = colorPlaceHolder
        labelTextViewPlaceholder.text = "Type a comment..."
        textViewUpdateComment.addSubview(labelTextViewPlaceholder)
        
        checkButtonState()
        
        switch editPinMode {
        case .comment:
            loadViewForComment()
            break
        case .chat_room:
            loadViewForChat()
            break
        case .media:
            loadViewForMoment()
            break
        case .place:
            break
        }
        
    }
    
    func loadViewForComment() {
        textViewUpdateComment.frame.origin.x = 27
        textViewUpdateComment.frame.origin.y = 84
        
        labelTextViewPlaceholder.text = "Type a comment..."
    }
    func loadViewForMoment() {
        textViewUpdateComment.frame.origin.x = 27
        textViewUpdateComment.frame.origin.y = 196
        
        labelTextViewPlaceholder.text = "Type a comment..."
        
        let layout = CenterCellCollectionViewFlowLayout()
        layout.itemSize = CGSize(width: 100, height: 100)
        layout.scrollDirection = .horizontal
        layout.minimumInteritemSpacing = 0
        layout.minimumLineSpacing = 5
        
        collectionViewMedia = UICollectionView(frame: CGRect(x: 0, y: 81, width: screenWidth, height: 100), collectionViewLayout: layout)
        collectionViewMedia.register(EditPinCollectionViewCell.self, forCellWithReuseIdentifier: "pinMedia")
        collectionViewMedia.delegate = self
        collectionViewMedia.dataSource = self
        collectionViewMedia.isPagingEnabled = false
        collectionViewMedia.backgroundColor = UIColor.clear
        collectionViewMedia.showsHorizontalScrollIndicator = false
        self.view.addSubview(collectionViewMedia)
    }
    func loadViewForChat() {
        imageViewForChat = UIImageView(frame: CGRect(x: 162, y: 76, width: 90, height: 90))
        imageViewForChat.image = imageForChat
        self.view.addSubview(imageViewForChat)
        
        //Line below the image
        let line = UIView(frame: CGRect(x: 0, y: 213, width: screenWidth, height: 12))
        line.backgroundColor = UIColor(red: 241/255, green: 241/255, blue: 241/255, alpha: 1)
        self.view.addSubview(line)
        
        let descriptionTitle = UILabel(frame: CGRect(x: 15, y: 239, width: 200, height: 22))
        descriptionTitle.textColor = UIColor(red: 89/255, green: 89/255, blue: 89/255, alpha: 1)
        descriptionTitle.font = UIFont(name: "AvenirNext-Medium", size: 16)
        descriptionTitle.text = "Description"
        self.view.addSubview(descriptionTitle)
        
        textViewUpdateComment.frame.origin.x = 27
        textViewUpdateComment.frame.origin.y = 266
        
        labelTextViewPlaceholder.text = "Type a chat decription"
    }
    
    func loadKeyboardToolBar() {
        inputToolbar = CreatePinInputToolbar()
        inputToolbar.delegate = self
        inputToolbar.darkBackgroundView.backgroundColor = UIColor.white
        inputToolbar.buttonOpenFaceGesPanel.setImage(#imageLiteral(resourceName: "faeGestureFilledRed"), for: UIControlState())
        inputToolbar.buttonOpenFaceGesPanel.setTitle("", for: UIControlState())
        inputToolbar.buttonFinishEdit.setImage(UIImage(), for: UIControlState())
        
        //Line on the toolbar
        lineOnToolbar = UIView(frame: CGRect(x: 0, y: 1, width: screenWidth, height: 1))
        lineOnToolbar.layer.borderWidth = screenWidth
        lineOnToolbar.layer.borderColor = UIColor(red: 200/255, green: 199/255, blue: 204/255, alpha: 1.0).cgColor
        inputToolbar.darkBackgroundView.addSubview(lineOnToolbar)
        
        inputToolbar.buttonFinishEdit.isHidden = true
        buttonFinishEdit = UIButton()
        buttonFinishEdit.setTitle("Edit Options", for: UIControlState())
        buttonFinishEdit.titleLabel?.font = UIFont(name: "AvenirNext-Medium", size: 18)
        inputToolbar.addSubview(buttonFinishEdit)
        inputToolbar.addConstraintsWithFormat("H:[v0(105)]-14-|", options: [], views: buttonFinishEdit)
        inputToolbar.addConstraintsWithFormat("V:[v0(25)]-11-|", options: [], views: buttonFinishEdit)
        buttonFinishEdit.addTarget(self, action: #selector(self.moreOptions(_ :)), for: .touchUpInside)
        buttonFinishEdit.setTitleColor(UIColor(red: 155/255, green: 155/255, blue:155/255, alpha: 1), for: UIControlState())
        inputToolbar.darkBackgroundView.addSubview(buttonFinishEdit)
        
        inputToolbar.labelCountChars.textColor = UIColor(red: 155/255, green: 155/255, blue:155/255, alpha: 1)
        
        self.view.addSubview(inputToolbar)
        
        inputToolbar.alpha = 1
        self.view.layoutIfNeeded()
    }
    
    func loadEmojiView(){
        emojiView = StickerPickView(frame: CGRect(x: 0, y: screenHeight, width: screenWidth, height: 271), emojiOnly: true)
        emojiView.sendStickerDelegate = self
        self.view.addSubview(emojiView)
    }

}
