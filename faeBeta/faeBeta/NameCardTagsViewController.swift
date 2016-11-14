//
//  NameCardTagsViewController.swift
//  faeBeta
//
//  Created by blesssecret on 9/24/16.
//  Copyright © 2016 fae. All rights reserved.
//

import UIKit

class NameCardTagsViewController: UIViewController, UICollectionViewDelegate, UICollectionViewDataSource,UICollectionViewDelegateFlowLayout {
    let screenWidth = UIScreen.main.bounds.width
    let screenHeight = UIScreen.main.bounds.height
    var collectionViewSelf : UICollectionView!
    let tagName = ["Single", "Dating", "LF Friends", "Foodie", "Athlete", "HMU", "AMA", "Student", "Seller", "For Hire", "Cinephile", "Bookworm", "I do Favors", "Services", "Visitor", "Traveller", "Local"]
    var colorSelf = [UIColor]()
    let cellText = "cellText"
    let cellSize = TagsCollectionViewCell()
    var buttonSuggest : UIButton!
    var buttonSave : UIBarButtonItem!
    //var buttonSave : UIButton!
    var labelTitle : UILabel!
    var arrIndex = [Int]()
    override func viewDidLoad() {
        super.viewDidLoad()
        setupNavigationBar()
        let layout = KTCenterFlowLayout()
//        let layout = UICollectionViewFlowLayout()
        layout.minimumInteritemSpacing = 15.0
        layout.minimumLineSpacing = 33.0
        collectionViewSelf = UICollectionView(frame: CGRect(x: 0, y: 132 - 64, width: screenWidth, height: screenHeight - 120), collectionViewLayout: layout)
        collectionViewSelf.backgroundColor = UIColor.clear
        collectionViewSelf.delegate = self
        collectionViewSelf.dataSource = self
        collectionViewSelf.allowsMultipleSelection = true
//        collectionViewSelf.registerNib(UINib(nibName: "TagsCollectionViewCell",bundle: nil), forCellWithReuseIdentifier: cellText)
        collectionViewSelf.register(TagsCollectionViewCell.self, forCellWithReuseIdentifier: cellText)
        self.view.addSubview(collectionViewSelf)
        colorSelf.append(colors(255, green: 114, blue: 169))
        colorSelf.append(colors(223, green: 157, blue: 248))
        colorSelf.append(colors(230, green: 140, blue: 102))
        colorSelf.append(colors(251, green: 202, blue: 81))
        colorSelf.append(colors(138, green: 138, blue: 138))
        colorSelf.append(colors(178, green: 228, blue: 77))
        colorSelf.append(colors(252, green: 191, blue: 157))
        colorSelf.append(colors(145, green: 209, blue: 252))
        colorSelf.append(colors(72, green: 221, blue: 188))
        colorSelf.append(colors(228, green: 108, blue: 108))
        colorSelf.append(colors(116, green: 184, blue: 188))
        colorSelf.append(colors(168, green: 129, blue: 120))
        colorSelf.append(colors(255, green: 126, blue: 126))
        colorSelf.append(colors(151, green: 161, blue: 236))
        colorSelf.append(colors(192, green: 154, blue: 210))
        colorSelf.append(colors(102, green: 160, blue: 228))
        colorSelf.append(colors(122, green: 212, blue: 134))
        
        buttonSuggest = UIButton(frame: CGRect(x: (screenWidth - 300)/2, y: screenHeight - 80, width: 300, height: 50))
//        buttonSuggest.titleLabel?.text = "+ Suggest New Tags"
        buttonSuggest.backgroundColor = UIColor.white
        buttonSuggest.setTitle("+ Suggest New Tags", for: UIControlState())
        buttonSuggest.setTitleColor(colors(249, green: 90, blue: 90), for: UIControlState())
        buttonSuggest.titleLabel?.font = UIFont(name: "AvenirNext-DemiBold", size: 20)
//        buttonSuggest.titleLabel?.textColor = colors(249, green: 90, blue: 90)
        buttonSuggest.layer.cornerRadius = 25
        buttonSuggest.layer.borderWidth = 2.0
        buttonSuggest.layer.borderColor = colors(249, green: 90, blue: 90).cgColor
        buttonSuggest.addTarget(self, action: #selector(NameCardTagsViewController.actionSuggestNewTags(_:)), for: UIControlEvents.touchUpInside)
        self.view.addSubview(buttonSuggest)
        self.view.bringSubview(toFront: buttonSuggest)
        
//        buttonSave = UIBarButtonItem(frame: CGRectMake(screenWidth - 44 - 14, 32 - 64, 44, 27))
        buttonSave = UIBarButtonItem(title: "Save", style: .plain, target: self, action: #selector(NameCardTagsViewController.saveTags))
        
        //buttonSave = UIButton(frame: CGRectMake(0,0,44,27))
        //buttonSave.addTarget(self, action: "saveTags", forControlEvents: .TouchUpInside)
//        buttonSave.setTitle("Save", forState: .Normal)
//        buttonSave.setTitleColor(colors(249, green: 90, blue: 90), forState: .Normal)
//        self.view.addSubview(buttonSave)
        self.navigationItem.rightBarButtonItem = buttonSave

        labelTitle = UILabel(frame: CGRect(x: (screenWidth - 173) / 2, y: 39, width: 174, height: 64))
        labelTitle.text = "Choose three Tags that represent you!"
        labelTitle.numberOfLines = 0
        labelTitle.font = UIFont(name: "AvenirNext-Medium", size: 20)
        labelTitle.textColor = getColor( 89,green: 89, blue: 89)
        self.view.addSubview(labelTitle)
    }
    func getColor(_ red : CGFloat, green : CGFloat, blue : CGFloat) -> UIColor {
        return UIColor(red: red / 255, green: green / 255, blue: blue / 255, alpha: 1.0)
    }
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    fileprivate func setupNavigationBar()
    {
        self.navigationController?.navigationBar.barTintColor = UIColor.white
        self.navigationController?.navigationBar.tintColor = UIColor.faeAppRedColor()
        self.navigationItem.leftBarButtonItem = UIBarButtonItem(image: UIImage(named: "NavigationBackNew"), style: UIBarButtonItemStyle.plain, target: self, action:#selector(LogInViewController.navBarLeftButtonTapped))
        self.navigationController?.isNavigationBarHidden = false
        //self.navigationController?.navigationBar.backgroundColor = UIColor.whiteColor()
        self.navigationController?.navigationBar.isTranslucent = true//the navigationvar will disapear
    }
    func navBarLeftButtonTapped()
    {
        _ = self.navigationController?.popViewController(animated: true)
    }
    func saveTags() {
        if arrIndex.count != 0 {
            var str = ""
            for i in 0 ..< arrIndex.count {
                let num = arrIndex[i]
                str += String(num)
                if (i != arrIndex.count - 1) {
                    str += ";"
                }
            }
            print(str)
            let user = FaeUser()
            user.whereKey("tag_ids", value: str)// MARK: bug here sometime will happen why?
            user.updateNameCard { (status:Int, objects:Any?) in
//                print (status)
//                print (objects)
                if status / 100 == 2 {
                    _ = self.navigationController?.popViewController(animated: true)
                }
                else {

                }
            }
        }
    }
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return tagName.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: cellText, for: indexPath)as! TagsCollectionViewCell
        cell.colorSelf = colorSelf[indexPath.row]
//        cell.colorSelf = UIColor.blueColor()
        cell.labelTitle.text = tagName[indexPath.row]
        return cell
    }
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        print(arrIndex)
        if arrIndex.count >= 3 {
            let index = arrIndex.last
            arrIndex.removeLast()
            let cell = collectionView.dequeueReusableCell(withReuseIdentifier: cellText, for: IndexPath(item: index!, section: 0))as! TagsCollectionViewCell
            collectionView.deselectItem(at: IndexPath(item: index!, section: 0), animated: true)
            cell.isSelected = false
//            arrIndex.append(indexPath.row)
        }
        arrIndex.append(indexPath.row)

    }
    func collectionView(_ collectionView: UICollectionView, didDeselectItemAt indexPath: IndexPath) {
        for i in 0 ..< arrIndex.count {
            if arrIndex[i] == indexPath.row {
                arrIndex.remove(at: i)
//                let cell = collectionView.dequeueReusableCellWithReuseIdentifier(cellText, forIndexPath: NSIndexPath(forItem: index!, inSection: 0))as! TagsCollectionViewCell

                break;
            }
        }
    }
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        cellSize.labelTitle.text = tagName[indexPath.row]
        return cellSize.newContentSize()
    }
    func colors(_ red: Float, green: Float, blue: Float) -> UIColor {
        return UIColor(colorLiteralRed: red/255.0, green: green/255.0, blue: blue/255.0, alpha: 1.0)
    }
    func actionSuggestNewTags(_ sender: UIButton) {
        let suggestNewTagsVC = ReportCommentPinViewController()
        suggestNewTagsVC.reportType = 2
        self.present(suggestNewTagsVC, animated: true, completion: nil)
    }
    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

}
