//
//  NameCardTagsViewController.swift
//  faeBeta
//
//  Created by blesssecret on 9/24/16.
//  Copyright © 2016 fae. All rights reserved.
//

import UIKit

class NameCardTagsViewController: UIViewController, UICollectionViewDelegate, UICollectionViewDataSource,UICollectionViewDelegateFlowLayout {
    let screenWidth = UIScreen.mainScreen().bounds.width
    let screenHeight = UIScreen.mainScreen().bounds.height
    var collectionViewSelf : UICollectionView!
    let tagName = ["Single", "Dating", "LF Friends", "Foodie", "Athlete", "HMU", "AMA", "Student", "Seller", "For Hire", "Cinephile", "Bookworm", "I do Favors", "Services", "Visitor", "Traveller", "Local"]
    var colorSelf = [UIColor]()
    let cellText = "cellText"
    let cellSize = TagsCollectionViewCell()
    var buttonSuggest : UIButton!
    override func viewDidLoad() {
        super.viewDidLoad()
        let layout = KTCenterFlowLayout()
//        let layout = UICollectionViewFlowLayout()
        layout.minimumInteritemSpacing = 15.0
        layout.minimumLineSpacing = 33.0
        collectionViewSelf = UICollectionView(frame: CGRectMake(0, 132 - 64, screenWidth, screenHeight - 100), collectionViewLayout: layout)
        collectionViewSelf.backgroundColor = UIColor.clearColor()
        collectionViewSelf.delegate = self
        collectionViewSelf.dataSource = self
//        collectionViewSelf.registerNib(UINib(nibName: "TagsCollectionViewCell",bundle: nil), forCellWithReuseIdentifier: cellText)
        collectionViewSelf.registerClass(TagsCollectionViewCell.self, forCellWithReuseIdentifier: cellText)
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
        
        buttonSuggest = UIButton(frame: CGRectMake((screenWidth - 300)/2, screenHeight - 80 - 64, 300, 50))
        buttonSuggest.titleLabel?.text = "+ Suggest New Tags"
        buttonSuggest.setTitle("+ Suggest New Tags", forState: .Normal)
        buttonSuggest.setTitleColor(colors(249, green: 90, blue: 90), forState: .Normal)
//        buttonSuggest.titleLabel?.textColor = colors(249, green: 90, blue: 90)
        buttonSuggest.layer.cornerRadius = 15
        buttonSuggest.layer.borderWidth = 2.0
        buttonSuggest.layer.borderColor = colors(249, green: 90, blue: 90).CGColor
        self.view.addSubview(buttonSuggest)
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    func saveTags() {
        
    }
    func collectionView(collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return tagName.count
    }
    
    func collectionView(collectionView: UICollectionView, cellForItemAtIndexPath indexPath: NSIndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCellWithReuseIdentifier(cellText, forIndexPath: indexPath)as! TagsCollectionViewCell
        cell.colorSelf = colorSelf[indexPath.row]
//        cell.colorSelf = UIColor.blueColor()
        cell.labelTitle.text = tagName[indexPath.row]
        return cell
    }

    func collectionView(collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAtIndexPath indexPath: NSIndexPath) -> CGSize {
        let str = tagName[indexPath.row]
        cellSize.labelTitle.text = tagName[indexPath.row]
        return cellSize.newContentSize()
    }
    func colors(red: Float, green: Float, blue: Float) -> UIColor {
        return UIColor(colorLiteralRed: red/255.0, green: green/255.0, blue: blue/255.0, alpha: 1.0)
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
