//
//  SetNamecardViewController.swift
//  FaeSettings
//
//  Created by 子不语 on 2017/9/17.
//  Copyright © 2017年 子不语. All rights reserved.
//

import UIKit
enum SetInfoEnterMode {
    case nameCard
    case settings
}

class SetInfoNamecard: UIViewController, UITableViewDelegate, UITableViewDataSource, ViewControllerNameDelegate, ViewControllerIntroDelegate {
    
    func protSaveName(txtName: String?) {
        textName = txtName
        // Vicky 09/17/17 在delegate=self之后，你的值是可以传回来了，那你这步操作是在干嘛？你需要更新的label是在table里面，不是在View里面，所以table需要重新reloadData才可以显示值，试试把这句话注释掉的结果。同样，这样地方table命名改一下吧，tblNameCard?或者其他的  以tbl开头
        tblNameCard.reloadData()
    }
    
    func protSaveIntro(txtIntro: String?) {
        textIntro = txtIntro
        tblNameCard.reloadData()
    }
    
    var faeNavBar: FaeNavBar!
    var uiviewNameCard: FMNameCardView!
    var uiviewInterval: UIView!
    var tblNameCard: UITableView!
    var arrInfo: [String] = ["Display Name", "Short Info", "Change Profile Picture", "Change Cover Photo"]
    var textName: String?
    var textIntro: String?
    var enterMode: SetInfoEnterMode!
    // Vicky 09/17/71 不要在这个地方单独操作，当你进入SetDisplayName()的时候，有一个push操作，直接在那个地方delegate=self。你在这个地方，是给了SetDisplayName()一个叫做vc的引用，在viewDidLoad里给这个引用的delegate=self,但你在pushViewController里是push了另一个引用，那个引用里需要将vc.delegate=self，否则是无效的。如果还不理解，周一再问我。
    //    var vc = SetDisplayName()
    
    override func viewDidLoad() {
        // super.viewDidLoad() missing here
        super.viewDidLoad()
        //        vc.delegate = self
        view.backgroundColor = .white
        loadContent()
    }
    
    func loadContent() {
        faeNavBar = FaeNavBar()
        view.addSubview(faeNavBar)
        faeNavBar.lblTitle.text = "Edit NameCard"
        faeNavBar.loadBtnConstraints()
        faeNavBar.rightBtn.setImage(nil, for: .normal)
        faeNavBar.leftBtn.addTarget(self, action: #selector(actionGoBack(_:)), for: .touchUpInside)
        
        uiviewNameCard = FMNameCardView()
        uiviewNameCard.showFullNameCard()
        uiviewNameCard.frame.origin.y = 65 + 11
        uiviewNameCard.boolSmallSize = true
        uiviewNameCard.userId = Key.shared.user_id
        view.addSubview(uiviewNameCard)
        
        uiviewInterval = UIView(frame: CGRect(x: 0, y: 390, w: screenWidth / screenWidthFactor, h: 5))
        view.addSubview(uiviewInterval)
        uiviewInterval.backgroundColor = UIColor._241241241()
        
        tblNameCard = UITableView(frame: CGRect(x: 0, y: 395 * screenHeightFactor, width: screenWidth, height: 270))
        view.addSubview(tblNameCard)
        tblNameCard.delegate = self
        tblNameCard.dataSource = self
        tblNameCard.register(SetAccountCell.self, forCellReuseIdentifier: "cell")
        tblNameCard.separatorStyle = .none
        
//        let line = UIView(frame: CGRect(x: 0, y: 113, width: screenWidth, height: 1))
//        line.backgroundColor = .black
//        view.addSubview(line)
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return arrInfo.count
    }
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 60
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "cell", for: indexPath as IndexPath) as! SetAccountCell
        cell.lblTitle.text = arrInfo[indexPath.row]
        if indexPath.row == 0 {
            cell.lblContent.text = textName
        }
        if indexPath.row == 1 {
            cell.lblContent.text = textIntro
        }
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        switch indexPath.row {
        case 0:
            // Vicky 09/17/17
            let vc = SetDisplayName()
            vc.delegate = self
            navigationController?.pushViewController(vc, animated: true)
            // Vicky 09/17/17 End
            break
        case 1:
            let vc = SetShortIntro()
            vc.delegate = self
            navigationController?.pushViewController(vc, animated: true)
            break
        default:
            break
        }
    }
    
    @objc func actionGoBack(_ sender: UIButton) {
        if enterMode == .nameCard {
            dismiss(animated: true)
        } else {
            navigationController?.popViewController(animated: true)
        }
    }
}
