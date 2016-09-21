//
//  NameCardAddTableViewCell.swift
//  faeBeta
//
//  Created by blesssecret on 7/22/16.
//  Copyright © 2016 fae. All rights reserved.
//

import UIKit

class NameCardAddTableViewCell: UITableViewCell, UICollectionViewDelegate,UICollectionViewDataSource,UIImagePickerControllerDelegate, UINavigationControllerDelegate,UIActionSheetDelegate {

    @IBOutlet weak var labelTitle: UILabel!
    
    @IBOutlet weak var collectionViewAdd: UICollectionView!
    let cellIdentifier = "cellAdd"
    var imagePicker : UIImagePickerController!
    var imageIndex : Int = 0
    var viewSelf : UIViewController!
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
        labelTitle.textColor = UIColor(colorLiteralRed: 89/255, green: 89/255, blue: 89/255, alpha: 1)
        collectionViewAdd.delegate = self
        collectionViewAdd.dataSource = self
        collectionViewAdd.backgroundColor = UIColor.clearColor()
        collectionViewAdd.registerNib(UINib(nibName: "NameCardAddCollectionViewCell",bundle: nil), forCellWithReuseIdentifier: cellIdentifier)
        imagePicker = UIImagePickerController()
        imagePicker.delegate = self
//        imagePicker.allowsEditing = true
//        collectionViewAdd.backgroundColor = UIColor.greenColor()
    }
    func collectionView(collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return 8
    }
    func collectionView(collectionView: UICollectionView, cellForItemAtIndexPath indexPath: NSIndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCellWithReuseIdentifier(cellIdentifier, forIndexPath: indexPath)as! NameCardAddCollectionViewCell
        let row = indexPath.row
        if arrayNameCard[row] != nil {
            cell.imageViewTitle.image = arrayNameCard[row]
            cell.imageViewTitle.layer.masksToBounds = true
            cell.imageViewTitle.layer.cornerRadius = 10
        } else {
            cell.imageViewTitle.image = UIImage(named: "nameCardAdd")
        }
        print(indexPath.row)
        return cell
    }
    func collectionView(collectionView: UICollectionView, didSelectItemAtIndexPath indexPath: NSIndexPath) {
        imageIndex = indexPath.row
        print(indexPath)
        let menu = UIAlertController(title: nil, message: "Choose image", preferredStyle: .ActionSheet)
        let showLibrary = UIAlertAction(title: "Choose from library", style: .Default) { (alert: UIAlertAction) in
            self.imagePicker.sourceType = .PhotoLibrary
            menu.removeFromParentViewController()
            self.viewSelf.presentViewController(self.imagePicker,animated:true,completion:nil)
        }
        let showCamera = UIAlertAction(title: "Take photoes", style: .Default) { (alert: UIAlertAction) in
            self.imagePicker.sourceType = .Camera
            menu.removeFromParentViewController()
            self.viewSelf.presentViewController(self.imagePicker,animated:true,completion:nil)
        }
        let cancel = UIAlertAction(title: "Cancel", style: .Cancel) { (alert: UIAlertAction) in
            
        }
        menu.addAction(showLibrary)
        menu.addAction(showCamera)
        menu.addAction(cancel)
//        UIApplication.sharedApplication().keyWindow.
        self.viewSelf.presentViewController(menu,animated:true,completion: nil)
    }
    func imagePickerController(picker: UIImagePickerController, didFinishPickingImage image: UIImage, editingInfo: [String : AnyObject]?) {
//        let cell = collectionViewAdd.dequeueReusableCellWithReuseIdentifier(cellIdentifier, forIndexPath: imageIndex) as! NameCardAddCollectionViewCell
//        print(imageIndex)
//        cell.imageViewTitle.image = image
//        self.imageView?.image = image
//        print(image)
        arrayNameCard[imageIndex] = image
        self.imagePicker.dismissViewControllerAnimated(true, completion: nil)
        self.collectionViewAdd.reloadData()
    }

    override func setSelected(selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
}
