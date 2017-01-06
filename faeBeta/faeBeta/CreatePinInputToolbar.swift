//
//  CreatePinself.swift
//  faeBeta
//
//  Created by YAYUAN SHI on 12/6/16.
//  Copyright © 2016 fae. All rights reserved.
//

import UIKit

protocol CreatePinInputToolbarDelegate: class {
    func inputToolbarFinishButtonTapped(inputToolbar: CreatePinInputToolbar)// tool bar right button tapped
    func inputToolbarEmojiButtonTapped(inputToolbar: CreatePinInputToolbar)// tool bar left button tapped
}

enum CreatePinInputToolbarMode {
    case emoji
    case tag
}

class CreatePinInputToolbar: UIView {
    
    //MARK: - properties
    var buttonOpenFaceGesPanel: UIButton!
    var buttonFinishEdit: UIButton!
    var labelCountChars: UILabel!
    var darkBackgroundView: UIView!
    
    private var _mode: CreatePinInputToolbarMode = .emoji
    var maximumNumberOfCharacters: Int
    {
        get{
            if _mode == .emoji{
                return 200
            }
            //for tag mode
            else {
                return 5
            }
        }
    }
    
    private var _numberOfCharactersEntered: Int = 0
    // a variable to track how many characters the user've entered. Also used to track how many tags the user has added in tag mode.
    var numberOfCharactersEntered: Int{
        set{
            _numberOfCharactersEntered = newValue
            if _mode == .emoji{
                labelCountChars.text = "\(maximumNumberOfCharacters - _numberOfCharactersEntered)"
            }else if _mode == .tag{
                labelCountChars.text = "\(_numberOfCharactersEntered)/\(maximumNumberOfCharacters)"
            }
            countCharsLabelHidden = false
        }
        get{
            return _numberOfCharactersEntered
        }
    }
    
    private var _countCharsLabelHidden: Bool = false
    // set this to true if the count label should be hidden
    var countCharsLabelHidden: Bool{
        get{
            return _countCharsLabelHidden
        }
        set{
            _countCharsLabelHidden = newValue
            if(_countCharsLabelHidden){
                labelCountChars.alpha = 0
            }else{
                labelCountChars.alpha = 1
            }
        }
    }
    private var _mode: CreatePinInputToolbarMode = .emoji
    // can be either emoji mode or tag mode. The button image and function will be different
    var mode: CreatePinInputToolbarMode {
        get{
            return _mode
        }
        set{
            _mode = newValue
            switch newValue {
            case .emoji:
                buttonOpenFaceGesPanel.setImage(#imageLiteral(resourceName: "faeGesture_filled"), for: UIControlState())
                buttonOpenFaceGesPanel.setTitle("", for: UIControlState())
                break
            case .tag:
                buttonOpenFaceGesPanel.setAttributedTitle(
                    NSAttributedString(string:"Add", attributes: [NSForegroundColorAttributeName: UIColor.white, NSFontAttributeName: UIFont(name: "AvenirNext-DemiBold", size: 18)!]),
                                                          for: UIControlState())
                buttonOpenFaceGesPanel.setImage(nil, for: UIControlState())
                break
            }
        }
    }
    
    weak var delegate:CreatePinInputToolbarDelegate!
    
    //MARK: - init
    init()
    {
        super.init(frame: CGRect(x: 0, y: screenHeight-100, width: screenWidth, height: 100))
        setup()
    }
    
    required init?(coder aDecoder: NSCoder)
    {
        fatalError("init(coder:) has not been implemented, use init() instead!")
    }

    override init(frame: CGRect)
    {
        fatalError("init(frame:) has not been implemented, use init() instead!")
    }
    
    //MARK: - setup
    private func setup()
    {
        self.backgroundColor = UIColor.clear
        darkBackgroundView = UIView(frame: CGRect(x: 0, y: 0, width: screenWidth, height: 50))
        darkBackgroundView.backgroundColor = UIColor(red: 70/255, green: 70/255, blue: 70/255, alpha: 0.7)
        self.addSubview(darkBackgroundView)
        self.addConstraintsWithFormat("H:|-0-[v0]-0-|", options: [], views: darkBackgroundView)
        self.addConstraintsWithFormat("V:[v0(50)]-0-|", options: [], views: darkBackgroundView)
        
        
        buttonOpenFaceGesPanel = UIButton()
        buttonOpenFaceGesPanel.imageEdgeInsets = UIEdgeInsets(top: 0, left: -20, bottom: 0, right: 0)
        buttonOpenFaceGesPanel.setImage(#imageLiteral(resourceName: "faeGesture_filled"), for: UIControlState())
        self.addSubview(buttonOpenFaceGesPanel)
        self.addConstraintsWithFormat("H:|-14-[v0(45)]", options: [], views: buttonOpenFaceGesPanel)
        self.addConstraintsWithFormat("V:[v0(29)]-11-|", options: [], views: buttonOpenFaceGesPanel)
        buttonOpenFaceGesPanel.addTarget(self, action: #selector(self.emojiButtonTapped(_:)), for: .touchUpInside)
        
        buttonFinishEdit = UIButton()
        buttonFinishEdit.setImage(UIImage(named: "finishEditing"), for: UIControlState())
        self.addSubview(buttonFinishEdit)
        self.addConstraintsWithFormat("H:[v0(49)]-14-|", options: [], views: buttonFinishEdit)
        self.addConstraintsWithFormat("V:[v0(25)]-11-|", options: [], views: buttonFinishEdit)
        buttonFinishEdit.addTarget(self, action: #selector(self.finishEditButtonTapped(_:)), for: .touchUpInside)
        
        labelCountChars = UILabel(frame: CGRect(x: screenWidth-43, y: screenHeight, width: 29, height: 20))
        labelCountChars.text = "\(maximumNumberOfCharacters)"
        labelCountChars.font = UIFont(name: "AvenirNext-Medium", size: 16)
        labelCountChars.textAlignment = .right
        labelCountChars.textColor = UIColor.white
        self.self.addSubview(labelCountChars)
        self.addConstraintsWithFormat("V:[v0(20)]-9-[v1]", options: [], views: labelCountChars, darkBackgroundView)
        self.addConstraintsWithFormat("H:[v0(29)]-|", options: [], views: labelCountChars)
    }
    
    //MARK: - button actions
    func finishEditButtonTapped(_ sender: UIButton)
    {
        self.delegate?.inputToolbarFinishButtonTapped(inputToolbar:self)
    }
    
    func emojiButtonTapped(_ sender: UIButton)
    {
        print("emoji is tapped")
        self.delegate?.inputToolbarEmojiButtonTapped(inputToolbar:self)
    }
    
    //MARK: - helper
    func switchToEmojiMode(){
        buttonOpenFaceGesPanel.setImage(#imageLiteral(resourceName: "keyboardIcon_filled"), for: UIControlState())
    }
    
    func switchToKeyboardMode(){
        buttonOpenFaceGesPanel.setImage(#imageLiteral(resourceName: "faeGesture_filled"), for: UIControlState())
    }
}

