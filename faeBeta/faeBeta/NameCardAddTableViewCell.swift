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
        collectionViewAdd.backgroundColor = UIColor.clear
        collectionViewAdd.register(UINib(nibName: "NameCardAddCollectionViewCell",bundle: nil), forCellWithReuseIdentifier: cellIdentifier)
        imagePicker = UIImagePickerController()
        imagePicker.delegate = self
//        imagePicker.allowsEditing = true
//        collectionViewAdd.backgroundColor = UIColor.greenColor()
    }
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return 8
    }
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: cellIdentifier, for: indexPath)as! NameCardAddCollectionViewCell
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
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        imageIndex = indexPath.row
        print(indexPath)
        let menu = UIAlertController(title: nil, message: "Choose image", preferredStyle: .actionSheet)
        let showLibrary = UIAlertAction(title: "Choose from library", style: .default) { (alert: UIAlertAction) in
            self.imagePicker.sourceType = .photoLibrary
            menu.removeFromParentViewController()
            self.viewSelf.present(self.imagePicker,animated:true,completion:nil)
        }
        let showCamera = UIAlertAction(title: "Take photoes", style: .default) { (alert: UIAlertAction) in
            self.imagePicker.sourceType = .camera
            menu.removeFromParentViewController()
            self.viewSelf.present(self.imagePicker,animated:true,completion:nil)
        }
        let cancel = UIAlertAction(title: "Cancel", style: .cancel) { (alert: UIAlertAction) in
            
        }
        menu.addAction(showLibrary)
        menu.addAction(showCamera)
        menu.addAction(cancel)
//        UIApplication.sharedApplication().keyWindow.
        self.viewSelf.present(menu,animated:true,completion: nil)
    }
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingImage image: UIImage, editingInfo: [String : AnyObject]?) {
//        let cell = collectionViewAdd.dequeueReusableCellWithReuseIdentifier(cellIdentifier, forIndexPath: imageIndex) as! NameCardAddCollectionViewCell
//        print(imageIndex)
//        cell.imageViewTitle.image = image
//        self.imageView?.image = image
//        print(image)
        arrayNameCard[imageIndex] = image
        self.imagePicker.dismiss(animated: true, completion: nil)
        self.collectionViewAdd.reloadData()
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
}
