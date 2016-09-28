//
//  CustomCollectionViewController.swift
//  quickChat
//
//  Created by User on 7/12/16.
//  Copyright © 2016 User. All rights reserved.
//

import UIKit

import Photos

// delegate to send mutiple image in ChatVC

protocol SendMutipleImagesDelegate {
    
    func sendImages(images : [UIImage])
    
}

// this view controller is used to show image from one album, it has a table view for you to switch albums

class CustomCollectionViewController: UICollectionViewController, UICollectionViewDelegateFlowLayout, UITableViewDelegate, UITableViewDataSource {
    
    var photoPicker : PhotoPicker!
    
    let photoPickerCellIdentifier = "photoPickerCellIdentifier"
    
    let layOut = UICollectionViewFlowLayout()
    
    let screenWidth = UIScreen.mainScreen().bounds.width
    let screenHeight = UIScreen.mainScreen().bounds.height
    
    var quitButton : UIButton!
    var showTableButton : UIButton!
    
    var titleLabel : UILabel!
    
    let requestOption = PHImageRequestOptions()
    
    var currentCell : AlbumTableViewCell!
    
    // table view variable
    
    var tableViewAlbum : UITableView!
    let albumReuseIdentifiler = "AlbumTableViewCell"
    var tableViewAlbumVisible = false

    //send image delegate
    
    var imageDelegate : SendMutipleImagesDelegate!
    
    var selectedImage = [UIImage]()
    
    var imageDict = [Int : UIImage]()
    
    var imageReverseDict = [UIImage : NSIndexPath]()
    
    var imageIndexDict = [UIImage : Int]()
    
    var indexImageDict = [Int : UIImage]()
    
    var frameImageName = ["photoSelection1", "photoSelection2", "photoSelection3", "photoSelection4","photoSelection5", "photoSelection6", "photoSelection7", "photoSelection8", "photoSelection9", "photoSelection10"]
    
    
    let activityIndicator = UIActivityIndicatorView(activityIndicatorStyle: .Gray)
    
    override func viewDidLoad() {
        super.viewDidLoad()
        photoPicker = PhotoPicker.shared
        collectionView?.backgroundColor = UIColor.whiteColor()
        collectionView?.registerNib(UINib(nibName: "PhotoPickerCollectionViewCell", bundle: nil), forCellWithReuseIdentifier: photoPickerCellIdentifier)
        requestOption.synchronous = false
        requestOption.resizeMode = .Fast
        requestOption.deliveryMode = .HighQualityFormat
        self.collectionView?.decelerationRate = UIScrollViewDecelerationRateFast
        navigationBarSet()
    }
    
    override func viewWillAppear(animated: Bool) {
        //fetch photo from collection
        self.navigationController?.hidesBarsOnTap = false
        self.collectionView?.reloadData()
        prepareTableView()
    }
    
    func prepareTableView() {
        tableViewAlbum = UITableView(frame: CGRect(x: 0, y: 0, width: screenWidth, height: 480))
        tableViewAlbum.registerNib(UINib(nibName: "AlbumTableViewCell", bundle: nil), forCellReuseIdentifier: albumReuseIdentifiler)
        tableViewAlbum.delegate = self
        tableViewAlbum.dataSource = self
    }
    
    func getUserAlbumSet() {
        let userAlbumsOptions = PHFetchOptions()
        userAlbumsOptions.predicate = NSPredicate(format: "estimatedAssetCount > 0")
        
        let userAlbums = PHAssetCollection.fetchAssetCollectionsWithType(PHAssetCollectionType.Album, subtype: PHAssetCollectionSubtype.Any, options: userAlbumsOptions)
        
        userAlbums.enumerateObjectsUsingBlock( {
            if let collection = $0.0 as? PHAssetCollection {
                print("album title: \(collection.localizedTitle)")
                //For each PHAssetCollection that is returned from userAlbums: PHFetchResult you can fetch PHAssets like so (you can even limit results to include only photo assets):
                let onlyImagesOptions = PHFetchOptions()
                onlyImagesOptions.predicate = NSPredicate(format: "mediaType = %i", PHAssetMediaType.Image.rawValue)
                if let result = PHAsset.fetchKeyAssetsInAssetCollection(collection, options: nil) {
                    print("Images count: \(result.count)")
                }
            }
        } )
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    //MARK: collectionViewController Delegate
    
    override func collectionView(collectionView: UICollectionView, didSelectItemAtIndexPath indexPath: NSIndexPath) {
        let cell = collectionView.cellForItemAtIndexPath(indexPath) as! PhotoPickerCollectionViewCell
        
        if cell.chosenFrameImageView.hidden {
            if imageDict.count == 10 {
                showAlertView()
            } else {
                imageDict[indexPath.row] = cell.photoImageView.image
                imageIndexDict[cell.photoImageView.image!] = imageDict.count - 1
                indexImageDict[imageDict.count - 1] = cell.photoImageView.image
                cell.chosenFrameImageView.image = UIImage(named: frameImageName[imageDict.count - 1])
                cell.chosenFrameImageView.hidden = false
                imageReverseDict[cell.photoImageView.image!] = indexPath
            }
        } else {
            cell.chosenFrameImageView.hidden = true
            let deselectedImage = imageDict[indexPath.row]
            let deselectedIndex = imageIndexDict[deselectedImage!]
            imageIndexDict[deselectedImage!] = nil
            indexImageDict[deselectedIndex!] = nil
            shiftChosenFrameFromIndex(deselectedIndex! + 1)
            imageDict[indexPath.row] = nil
            imageReverseDict[deselectedImage!] = nil
        }
        print("imageDict has \(imageDict.count) images")
        collectionView.deselectItemAtIndexPath(indexPath, animated: true)
    }
    
    override func collectionView(collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return photoPicker.currentAlbum.albumContent.count
    }
    
    func collectionView(collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumLineSpacingForSectionAtIndex section: Int) -> CGFloat {
        return 1.5
    }
    
    func collectionView(collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumInteritemSpacingForSectionAtIndex section: Int) -> CGFloat {
        return 0
    }
    
    func collectionView(collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAtIndexPath indexPath: NSIndexPath) -> CGSize {
        return CGSizeMake(view.frame.width / 3 - 1, view.frame.width / 3 - 1)
    }
    
    override func collectionView(collectionView: UICollectionView, cellForItemAtIndexPath indexPath: NSIndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCellWithReuseIdentifier(photoPickerCellIdentifier, forIndexPath: indexPath) as! PhotoPickerCollectionViewCell
        return cell
    }
    
    override func collectionView(collectionView: UICollectionView, willDisplayCell cell: UICollectionViewCell, forItemAtIndexPath indexPath: NSIndexPath) {
        let cell = cell as! PhotoPickerCollectionViewCell
        //get image from PHFetchResult
        let asset : PHAsset = photoPicker.currentAlbum.albumContent[indexPath.item] as! PHAsset
        cell.loadImage(asset, requestOption: requestOption)
        if self.imageDict[indexPath.row] != nil {
            cell.chosenFrameImageView.hidden = false
            cell.chosenFrameImageView.image = UIImage(named: self.frameImageName[self.imageIndexDict[self.imageDict[indexPath.row]!]!])
        }
    }
    
    override func collectionView(collectionView: UICollectionView, didEndDisplayingCell cell: UICollectionViewCell, forItemAtIndexPath indexPath: NSIndexPath) {
        let mycell = cell as! PhotoPickerCollectionViewCell
        mycell.photoImageView.image = nil
    }
    
    
    //MARK: support method
    
    func navigationBarSet() {
        let centerView = UIView(frame: CGRect(x: 0,y: 0,width: 200,height: 30))
        showTableButton = UIButton(frame: CGRect(x: 0, y: 0, width: 200, height: 30))
        showTableButton.titleLabel?.text = ""
        showTableButton.addTarget(self, action: #selector(CustomCollectionViewController.showAlbumTable), forControlEvents: .TouchUpInside)
        
        self.navigationController?.navigationBar.tintColor = UIColor(red: 249 / 255, green: 90 / 255, blue: 90 / 255, alpha: 1.0)
        self.navigationController?.navigationBar.barTintColor = UIColor.whiteColor()
        self.navigationController?.navigationBar.translucent = false
        
        titleLabel = UILabel(frame: CGRect(x: 0, y: 0, width: 200, height: 25))
        titleLabel.text = "Camera Roll"
        titleLabel.textAlignment = .Center
        titleLabel.font = UIFont(name: "Avenir Next", size: 20)
        titleLabel.textColor = UIColor(red: 89 / 255, green: 89 / 255, blue: 89 / 255, alpha: 1.0)
        centerView.addSubview(titleLabel)
        
        
        let arrow = UIImageView(frame: CGRect(x: 97, y: 25, width: 10, height: 6))
        arrow.image = UIImage(named: "arrow")
        centerView.addSubview(arrow)
        centerView.addSubview(showTableButton)
        self.navigationItem.titleView = centerView
        
        self.navigationItem.rightBarButtonItems = [UIBarButtonItem.init(title: "Send", style: .Plain, target: self, action: #selector(CustomCollectionViewController.sendImages))]
        
        self.navigationItem.leftBarButtonItems = [UIBarButtonItem.init(title: "Cancel", style: .Plain, target: self, action: #selector(CustomCollectionViewController.cancelSend))]
        
    }
    
    func showAlbumTable() {
        if !tableViewAlbumVisible {
            quitButton = UIButton(frame: CGRect(x: 0, y: 0, width: screenWidth, height: screenHeight))
            quitButton.backgroundColor = UIColor(red: 58 / 255, green: 51 / 255, blue: 51 / 255, alpha: 0.5)
            self.view.addSubview(quitButton)
            quitButton.addTarget(self, action: #selector(CustomCollectionViewController.dismissAlbumTable), forControlEvents: .TouchUpInside)
            self.view.addSubview(tableViewAlbum)
            tableViewAlbum.setContentOffset(CGPointZero, animated: true)
        } else {
            dismissAlbumTable()
        }
        tableViewAlbumVisible = !tableViewAlbumVisible
    }
    
    func sendImages() {
        showProcessIndicator()
        imageDelegate.sendImages([UIImage](imageDict.values))
        hideProcessIndicator()
        cancelSend()
    }
    
    func cancelSend() {
        self.navigationController?.popViewControllerAnimated(true)
    }
    
    func dismissAlbumTable() {
        quitButton.removeFromSuperview()
        tableViewAlbum.removeFromSuperview()
    }
    
    func showAlertView() {
        let alert = UIAlertController(title: "You can send up to 10 photos at once", message: "", preferredStyle: UIAlertControllerStyle.Alert)
        alert.addAction(UIAlertAction(title: "OK", style: UIAlertActionStyle.Default, handler: nil))
        self.presentViewController(alert, animated: true, completion: nil)
    }
    
    func showProcessIndicator() {
        activityIndicator.center = self.view.center
        activityIndicator.startAnimating()
        activityIndicator.layer.zPosition = 10
        self.view.userInteractionEnabled = false
        self.view.addSubview(activityIndicator)
    }
    
    func hideProcessIndicator() {
        activityIndicator.stopAnimating()
        activityIndicator.removeFromSuperview()
        self.view.userInteractionEnabled = true
    }
    
    func shiftChosenFrameFromIndex(index : Int) {
        var i = index
        while i < imageDict.count {
            let image = indexImageDict[i]
            imageIndexDict[image!] = i - 1
            let cell = collectionView?.cellForItemAtIndexPath(imageReverseDict[image!]!) as! PhotoPickerCollectionViewCell
            cell.chosenFrameImageView.image = UIImage(named: frameImageName[i-1])
            indexImageDict[i-1] = image
            i += 1
        }
    }
    
    
    //MARK: table view delegate method
    
    func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCellWithIdentifier(albumReuseIdentifiler) as! AlbumTableViewCell
        cell.albumTitleLabel.text = photoPicker.selectedAlbum[indexPath.row].albumName
        cell.albumNumberLabel.text = "\(photoPicker.selectedAlbum[indexPath.row].albumCount)"
        cell.checkMarkImage.hidden = photoPicker.selectedAlbum[indexPath.row].albumName != photoPicker.currentAlbum.albumName
        
        if !cell.checkMarkImage.hidden {
            currentCell = cell
        }
        //set thumbnail
        let asset : PHAsset = self.photoPicker.selectedAlbum[indexPath.row].albumContent[0] as! PHAsset
        
        PHCachingImageManager.defaultManager().requestImageForAsset(asset, targetSize: CGSizeMake(view.frame.width - 1 / 10, view.frame.width - 1 / 10), contentMode: .AspectFill, options: nil) { (result, info) in
            cell.titleImageView.image = result!
        }
        
        return cell
    }
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return photoPicker.selectedAlbum.count
    }
    
    func tableView(tableView: UITableView, heightForRowAtIndexPath indexPath: NSIndexPath) -> CGFloat {
        return 80
    }
    
    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        let cell = tableView.cellForRowAtIndexPath(indexPath) as! AlbumTableViewCell
        if cell.checkMarkImage.hidden {
            photoPicker.currentAlbum = photoPicker.selectedAlbum[indexPath.row]
            tableView.deselectRowAtIndexPath(indexPath, animated: true)
            dismissAlbumTable()
            tableViewAlbumVisible = !tableViewAlbumVisible
            self.titleLabel.text = photoPicker.currentAlbum.albumName
            currentCell.checkMarkImage.hidden = true
            let cellNew = tableView.cellForRowAtIndexPath(indexPath) as! AlbumTableViewCell
            cellNew.checkMarkImage.hidden = false
            currentCell = cellNew
            imageDict.removeAll()
            collectionView?.reloadData()
        }
    }
}

extension UIImage {
    var uncompressedPNGData: NSData      { return UIImagePNGRepresentation(self)!        }
    var highestQualityJPEGNSData: NSData { return UIImageJPEGRepresentation(self, 1.0)!  }
    var highQualityJPEGNSData: NSData    { return UIImageJPEGRepresentation(self, 0.75)! }
    var mediumQualityJPEGNSData: NSData  { return UIImageJPEGRepresentation(self, 0.5)!  }
    var lowQualityJPEGNSData: NSData     { return UIImageJPEGRepresentation(self, 0.25)! }
    var lowestQualityJPEGNSData:NSData   { return UIImageJPEGRepresentation(self, 0.0)!  }
}
