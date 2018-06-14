//
//  SettingsCell.swift
//  FaeSettings
//
//  Created by 子不语 on 2017/8/28.
//  Copyright © 2017年 子不语. All rights reserved.
//

import UIKit

protocol GeneralTitleCellDelegate: class {
    func startUpdating()
    func stopUpdating()
}

// MARK: -
class GeneralTitleCell: UITableViewCell {
    
    // MARK: Properties
    // Cell Height = 60 or 110
    
    weak var delegate: GeneralTitleCellDelegate?
    
    var lblName: FaeLabel!
    var switchIcon: UISwitch!
    var lblDes: FaeLabel!
    var imgView: UIImageView!
    var topGrayLine: UIView!
    
    var uiviewBackground: UIView?
    
    private var lblDesContraint = [NSLayoutConstraint]() {
        didSet {
            if oldValue.count != 0 {
                self.removeConstraints(oldValue)
            }
            if lblDesContraint.count != 0 {
                self.addConstraints(lblDesContraint)
            }
        }
    }
    
    private var lblNameContraint = [NSLayoutConstraint]() {
        didSet {
            if oldValue.count != 0 {
                self.removeConstraints(oldValue)
            }
            if lblNameContraint.count != 0 {
                self.addConstraints(lblNameContraint)
            }
        }
    }
    
    // MARK: init
    override init(style: UITableViewCellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        selectionStyle = .none
        loadContent()
        separatorInset = UIEdgeInsets(top: 0, left: 1000, bottom: 0, right: 0)
    }
    
    private func loadContent() {
        
        topGrayLine = UIView(frame: CGRect(x: 0, y: 0, width: screenWidth, height: 5))
        topGrayLine.backgroundColor = UIColor._241241241()
        addSubview(topGrayLine)
        
        lblName = FaeLabel(CGRect.zero, .left, .medium, 18, UIColor._898989())
        addSubview(lblName)
        addConstraintsWithFormat("H:|-20-[v0]-60-|", options: [], views: lblName)
        lblName.numberOfLines = 0
        
        switchIcon = UISwitch()
        switchIcon.isOn = false
        switchIcon.onTintColor = UIColor._2499090()
        switchIcon.transform = CGAffineTransform(scaleX: 35 / 51, y: 21 / 31)
        switchIcon.addTarget(self, action: #selector(actionSwitchFunc(_:)), for: .valueChanged)
        addSubview(switchIcon)
        addConstraintsWithFormat("H:[v0(38)]-19-|", options: [], views: switchIcon)
        addConstraintsWithFormat("V:|-18-[v0(23)]", options: [], views: switchIcon)
        
        lblDes = FaeLabel(CGRect.zero, .left, .mediumItalic, 15, UIColor._168168168())
        addSubview(lblDes)
        lblDes.numberOfLines = 0
        lblDes.lineBreakMode = .byWordWrapping
        addConstraintsWithFormat("H:|-20-[v0]-20-|", options: [], views: lblDes)
        lblDes.isHidden = true
        
        imgView = UIImageView()
        addSubview(imgView)
        imgView.image = #imageLiteral(resourceName: "Settings_next")
        addConstraintsWithFormat("H:[v0(9)]-20-|", options: [], views: imgView)
        addConstraintsWithFormat("V:|-25-[v0(17)]", options: [], views: imgView)
        
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
    
    // MARK: Switch action
    @objc private func actionSwitchFunc(_ sender: UISwitch) {
        switch sender.tag {
        case 31:
            if Key.shared.userEmailVerified == false {
                self.uiviewBackground?.isHidden = !sender.isOn
            }
            Key.shared.emailSubscribed = sender.isOn
            FaeUser.shared.whereKey("email_subscription", value: "\(sender.isOn)")
            FaeUser.shared.setUserSettings { (status, message) in
                guard status / 100 == 2 else { return }
            }
            break
        case 101:
            delegate?.startUpdating()
            FaeUser.shared.whereKey("show_name_card_options", value: "\(!sender.isOn)")
            FaeUser.shared.setUserSettings { status, _ in
                if status / 100 == 2 {
                    print("[hideOptions] Successfully update namecard")
                    Key.shared.showNameCardOption = sender.isOn
                } else {
                    print("[hideOptions] Fail to update namecard")
                    sender.setOn(!sender.isOn, animated: true)
                }
                self.delegate?.stopUpdating()
            }
        case 102:
            delegate?.startUpdating()
            FaeUser.shared.whereKey("show_gender", value: "\(!sender.isOn)")
            FaeUser.shared.updateNameCard { status, _ in
                if status / 100 == 2 {
                    print("[showGenderAge] Successfully update namecard")
                    Key.shared.disableGender = sender.isOn
                } else {
                    print("[showGenderAge] Fail to update namecard")
                    sender.setOn(!sender.isOn, animated: true)
                }
                self.delegate?.stopUpdating()
            }
        case 103:
            delegate?.startUpdating()
            FaeUser.shared.whereKey("show_age", value: "\(!sender.isOn)")
            FaeUser.shared.updateNameCard { status, _ in
                if status / 100 == 2 {
                    print("[showGenderAge] Successfully update namecard")
                    Key.shared.disableAge = sender.isOn
                } else {
                    print("[showGenderAge] Fail to update namecard")
                    sender.setOn(!sender.isOn, animated: true)
                }
                self.delegate?.stopUpdating()
            }
        default: break
        }
    }
    
    // MARK: Helper methods for controling constraints
    func setContraintsForDes(desp exist: Bool = true) {
        if exist {
            lblDesContraint = returnConstraintsWithFormat("V:|-50-[v0]-20-|", options: [], views: lblDes)            
        }
        lblNameContraint = returnConstraintsWithFormat("V:|-20-[v0(25)]", options: [], views: lblName)
    }
    
    func removeContraintsForDes() {
        removeConstraints(lblDesContraint)
        lblNameContraint = returnConstraintsWithFormat("V:|-20-[v0]-15-|", options: [], views: lblName)
    }
}

// MARK: -
class GeneralSubTitleCell: UITableViewCell {
    // MARK: Properties
    // cell height = 47
    
    var lblName: FaeLabel!
    var switchIcon: UISwitch!
    var lblDes: FaeLabel!
    var btnSelect: UIButton!
    var imgView: UIImageView!
    
    private var lblContraint = [NSLayoutConstraint]() {
        didSet {
            if oldValue.count != 0 {
                self.removeConstraints(oldValue)
            }
            if lblContraint.count != 0 {
                self.addConstraints(lblContraint)
            }
        }
    }
    
    // MARK: init
    override init(style: UITableViewCellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        selectionStyle = .none
        separatorInset = UIEdgeInsets(top: 0, left: 1000, bottom: 0, right: 0)
        loadContent()
    }
    
    private func loadContent() {
        lblName = FaeLabel(CGRect.zero, .left, .medium, 16, UIColor._898989())
        addSubview(lblName)
        addConstraintsWithFormat("H:|-30-[v0]-60-|", options: [], views: lblName)
        addConstraintsWithFormat("V:|-0-[v0(22)]", options: [], views: lblName)
        
        btnSelect = UIButton()
        btnSelect.setImage(#imageLiteral(resourceName: "Settings_choose"), for: .selected)
        btnSelect.setImage(#imageLiteral(resourceName: "Settings_notChoose"), for: .normal)
        btnSelect.adjustsImageWhenHighlighted = false
        btnSelect.isUserInteractionEnabled = false
        addSubview(btnSelect)
        addConstraintsWithFormat("H:[v0(22)]-27-|", options: [], views: btnSelect)
        addConstraintsWithFormat("V:|-0-[v0(22)]", options: [], views: btnSelect)
        
        switchIcon = UISwitch()
        switchIcon.isOn = false
        switchIcon.onTintColor = UIColor._2499090()
        switchIcon.transform = CGAffineTransform(scaleX: 35 / 51, y: 21 / 31)
        addSubview(switchIcon)
        addConstraintsWithFormat("H:[v0(39)]-19-|", options: [], views: switchIcon)
        addConstraintsWithFormat("V:|-(-3)-[v0(23)]", options: [], views: switchIcon)
        switchIcon.addTarget(self, action: #selector(self.actionSwitchFunc(_:)), for: .touchUpInside)
        
        imgView = UIImageView()
        addSubview(imgView)
        imgView.image = #imageLiteral(resourceName: "Settings_next")
        addConstraintsWithFormat("H:[v0(9)]-20-|", options: [], views: imgView)
        addConstraintsWithFormat("V:|-3-[v0(17)]", options: [], views: imgView)
        
        lblDes = FaeLabel(CGRect.zero, .left, .mediumItalic, 15, UIColor._168168168())
        addSubview(lblDes)
        lblDes.numberOfLines = 0
        addConstraintsWithFormat("H:|-30-[v0]-45-|", options: [], views: lblDes)
        lblDes.isHidden = true
        lblDes.text = "Enable to allow Fae Map to send you notifications such as new chats and new places to discover."
    }
    
    // MARK: Switch action
    @objc func actionSwitchFunc(_ sender: UISwitch) {
        switch sender.tag {
        case 11, 12, 13, 14, 15:
            UIApplication.shared.openURL(URL(string: UIApplicationOpenSettingsURLString)!)
            break
        default:
            break
        }
    }
    
    // MARK: Helper methods
    func updateName(name: String) {
        var arrNames = name.split(separator: " ")
        var array = [String]()
        guard arrNames.count >= 1 else { return }
        for i in 0..<arrNames.count {
            let name = String(arrNames[i]).trimmingCharacters(in: CharacterSet.whitespaces)
            array.append(name)
        }
        
        let fullAttrStr = NSMutableAttributedString()
        
        let attrs_0 = [NSAttributedStringKey.foregroundColor: UIColor._898989(), NSAttributedStringKey.font: UIFont(name: "AvenirNext-Medium", size: 16)!]
        let title_0_attr = NSMutableAttributedString(string: array[0] + " ", attributes: attrs_0)
        
        let attrs_1 = [NSAttributedStringKey.foregroundColor: UIColor._168168168(), NSAttributedStringKey.font: UIFont(name: "AvenirNext-Medium", size: 16)!]
        let title_1_attr = NSMutableAttributedString(string: array[1] + "  ", attributes: attrs_1)
        
        fullAttrStr.append(title_0_attr)
        fullAttrStr.append(title_1_attr)
        
        lblName.attributedText = fullAttrStr
    }
    
    func setContraintsForDes() {
        lblContraint = returnConstraintsWithFormat("V:|-27-[v0]-20-|", options: [], views: lblDes)
    }
    
    func removeContraintsForDes() {
        removeConstraints(lblContraint)
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
}

