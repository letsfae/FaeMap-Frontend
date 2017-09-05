//
//  ManageColListViewController.swift
//  faeBeta
//
//  Created by Faevorite 2 on 2017-09-01.
//  Copyright © 2017 fae. All rights reserved.
//

import UIKit

class ManageColListViewController: UIViewController {
    var uiviewChooseAction: UIView!
    var lblChoose: UILabel!
    var btnActFirst: UIButton!
    var btnActSecond: UIButton!
    var btnActThird: UIButton!
    var btnCancel: UIButton!
    var uiviewMsgHint: UIView!
    var btnCrossCancel: UIButton!
    var btnYes: UIButton!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = UIColor(r: 107, g: 105, b: 105, alpha: 70)
        loadContent()
        // Do any additional setup after loading the view.
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        animationShowSelf()
    }
    
    fileprivate func loadContent() {
        uiviewChooseAction = UIView(frame: CGRect(x: 0, y: 200, w: 290, h: 302))
        uiviewChooseAction.center.x = screenWidth / 2
        uiviewChooseAction.backgroundColor = .white
        uiviewChooseAction.layer.cornerRadius = 20
        view.addSubview(uiviewChooseAction)
        
        lblChoose = UILabel(frame: CGRect(x: 0, y: 20, w: 290, h: 25))
        lblChoose.textAlignment = .center
        lblChoose.text = "Choose an Option"
        lblChoose.textColor = UIColor._898989()
        lblChoose.font = UIFont(name: "AvenirNext-Medium", size: 18 * screenHeightFactor)
        uiviewChooseAction.addSubview(lblChoose)
        
        btnActFirst = UIButton(frame: CGRect(x: 41, y: 65, w: 208, h: 50))
        btnActSecond = UIButton(frame: CGRect(x: 41, y: 130, w: 208, h: 50))
        btnActThird = UIButton(frame: CGRect(x: 41, y: 195, w: 208, h: 50))
        btnActFirst.setTitle("Manage", for: .normal)
        btnActSecond.setTitle("Settings", for: .normal)
        btnActThird.setTitle("Delete", for: .normal)
        
        var btnActions = [UIButton]()
        btnActions.append(btnActFirst)
        btnActions.append(btnActSecond)
        btnActions.append(btnActThird)
        
        for i in 0..<btnActions.count {
            btnActions[i].tag = i
            btnActions[i].setTitleColor(UIColor._2499090(), for: .normal)
            btnActions[i].titleLabel?.font = UIFont(name: "AvenirNext-DemiBold", size: 18 * screenHeightFactor)
            btnActions[i].addTarget(self, action: #selector(actionChooseOption(_:)), for: .touchUpInside)
            btnActions[i].layer.borderWidth = 2
            btnActions[i].layer.borderColor = UIColor._2499090().cgColor
            btnActions[i].layer.cornerRadius = 26 * screenWidthFactor
            uiviewChooseAction.addSubview(btnActions[i])
        }
        
        btnCancel = UIButton()
        btnCancel.setTitle("Cancel", for: .normal)
        btnCancel.setTitleColor(UIColor._2499090(), for: .normal)
        btnCancel.titleLabel?.font = UIFont(name: "AvenirNext-Medium", size: 18 * screenHeightFactor)
        btnCancel.addTarget(self, action: #selector(actionCancel(_:)), for: .touchUpInside)
        uiviewChooseAction.addSubview(btnCancel)
        view.addConstraintsWithFormat("H:|-80-[v0]-80-|", options: [], views: btnCancel)
        view.addConstraintsWithFormat("V:[v0(25)]-\(15 * screenHeightFactor)-|", options: [], views: btnCancel)
        
        loadDeleteConfirm()
    }
    
    fileprivate func loadDeleteConfirm() {
        uiviewMsgHint = UIView(frame: CGRect(x: 0, y: 200, w: 290, h: 208))
        uiviewMsgHint.backgroundColor = .white
        uiviewMsgHint.center.x = screenWidth / 2
        uiviewMsgHint.layer.cornerRadius = 20 * screenWidthFactor
        uiviewMsgHint.isHidden = true
        
        btnCrossCancel = UIButton(frame: CGRect(x: 0, y: 0, w: 42, h: 40))
        btnCrossCancel.tag = 0
        btnCrossCancel.setImage(#imageLiteral(resourceName: "check_cross_red"), for: .normal)
        btnCrossCancel.addTarget(self, action: #selector(actionCancel(_:)), for: .touchUpInside)
        
        let lblMsgSent = UILabel(frame: CGRect(x: 0, y: 30, w: 290, h: 50))
        lblMsgSent.numberOfLines = 2
        lblMsgSent.textAlignment = .center
        lblMsgSent.font = UIFont(name: "AvenirNext-Medium", size: 18 * screenHeightFactor)
        lblMsgSent.textColor = UIColor._898989()
        lblMsgSent.text = "Are you sure you want \nto delete this list?"
        
        let lblMsg = UILabel(frame: CGRect(x: 0, y: 93, w: 290, h: 36))
        lblMsg.numberOfLines = 2
        lblMsg.textAlignment = .center
        lblMsg.font = UIFont(name: "AvenirNext-Medium", size: 13 * screenHeightFactor)
        lblMsg.textColor = UIColor._138138138()
        lblMsg.text = "This list cannot be recovered and all \nitems in this list will be removed."
        
        btnYes = UIButton(frame: CGRect(x: 41, y: 149, w: 208, h: 39))
        btnYes.setTitle("Yes", for: .normal)
        btnYes.setTitleColor(UIColor.white, for: .normal)
        btnYes.titleLabel?.font = UIFont(name: "AvenirNext-DemiBold", size: 18 * screenHeightFactor)
        btnYes.backgroundColor = UIColor._2499090()
        btnYes.layer.cornerRadius = 19 * screenWidthFactor
        btnYes.addTarget(self, action: #selector(actionYes(_:)), for: .touchUpInside)
        
        uiviewMsgHint.addSubview(lblMsgSent)
        uiviewMsgHint.addSubview(lblMsg)
        uiviewMsgHint.addSubview(btnCrossCancel)
        uiviewMsgHint.addSubview(btnYes)
        view.addSubview(uiviewMsgHint)
    }
    
    func actionCancel(_ sender: UIButton) {
        dismiss(animated: false, completion: nil)
    }
    
    func actionChooseOption(_ sender: UIButton) {
        switch sender.tag {
        case 0: // manage
            break
        case 1: // settings
            break
        case 2: // delete
            animationActionView()
            break
        default:
            break
        }
    }
    
    func actionYes(_ sender: UIButton) {
        animationHideSelf()
    }
    
    // animations
    func animationActionView() {
        uiviewChooseAction.isHidden = true
        uiviewMsgHint.isHidden = false
        uiviewChooseAction.alpha = 0
        uiviewMsgHint.alpha = 0
        UIView.animate(withDuration: 0.25, delay: 0, options: .curveEaseOut, animations: {
            self.uiviewMsgHint.alpha = 1
        }, completion: nil)
    }
    
    func animationShowSelf() {
        view.alpha = 0
        uiviewChooseAction.alpha = 0
        UIView.animate(withDuration: 0.25, delay: 0, options: .curveEaseOut, animations: {
            self.view.alpha = 1
            self.uiviewChooseAction.alpha = 1
        }, completion: nil)
    }
    
    func animationHideSelf() {
        view.alpha = 1
        uiviewChooseAction.alpha = 1
        uiviewMsgHint.alpha = 1
        UIView.animate(withDuration: 0.25, delay: 0, options: .curveEaseOut, animations: {
            self.uiviewChooseAction.alpha = 0
            self.uiviewMsgHint.alpha = 0
            self.view.alpha = 0
        }, completion: { _ in
            self.dismiss(animated: false)
        })
    }
    // animations end
}
