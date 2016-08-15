//
//  TestViewController.swift
//  faeBeta
//
//  Created by 王彦翔 on 16/7/26.
//  Copyright © 2016年 fae. All rights reserved.
//

import UIKit
import GoogleMaps

extension FaeMapViewController: UICollectionViewDelegate, UICollectionViewDataSource {
    
    func loadNamecard() {
        self.view.backgroundColor = UIColor.whiteColor()
        
        uiviewDialog = UIView(frame: CGRect(x: (screenWidth-360)/2, y: 110,width: 360,height: 335))
        uiviewDialog.backgroundColor = UIColor(patternImage: UIImage(named: "map_namecard_dialog")!)
        uiviewDialog.layer.zPosition = 20

        
        //avatar
        imageviewNamecardAvatar = UIImageView(frame: CGRect(x: 150, y: -17, width: 60, height: 60))
        imageviewNamecardAvatar.image = UIImage(named: "map_namecard_photo1")
        imageviewNamecardAvatar.layer.cornerRadius = 30
        imageviewNamecardAvatar.clipsToBounds = true
        imageviewNamecardAvatar.layer.borderColor = UIColor.whiteColor().CGColor
        imageviewNamecardAvatar.layer.borderWidth = 5
        
        //button more
        buttonMore = UIButton(frame: CGRect(x: (maxLength-52), y: 32/736*screenHeight, width: 27, height: 7))
        let imageMore = UIImage(named: "map_namecard_dots")
        buttonMore.setImage(imageMore, forState: .Normal)
        buttonMore.addTarget(self, action: #selector(FaeMapViewController.buttonMoreAction(_:)), forControlEvents: .TouchUpInside)
        
        //load function view
        loadFunctionview()
        
        //label name
        labelNamecardName = UILabel(frame: CGRect(x: (maxLength-180)/2, y: 54, width: 180, height: 27))
        labelNamecardName.font = UIFont(name: "AvenirNext-DemiBold", size: 20.0)
        labelNamecardName.textColor = UIColor.darkGrayColor()
        labelNamecardName.textAlignment = .Center
        labelNamecardName.text = "LinLInLiN"
        
        //label description
        labelNamecardDescription = UILabel(frame: CGRect(x: (maxLength-294)/2, y: 85, width: 294, height: 44))
        labelNamecardDescription.numberOfLines = 2
        labelNamecardDescription.font = UIFont(name: "AvenirNext-Medium", size: 15.0)
        labelNamecardDescription.textColor = UIColor.lightGrayColor()
        labelNamecardDescription.textAlignment = .Center
        labelNamecardDescription.text = "hahahaaahahah\nahaahahahahahahahe\nhahahhahahahahahahahahahahah"
        
        //line 
        viewLine = UIView(frame: CGRect(x: (maxLength-252)/2, y: 158, width: 252, height: 1))
        viewLine.backgroundColor = UIColor.lightGrayColor()
        
        //collection view
        let x : CGFloat = 47
        let y : CGFloat = 155
        let flowLayout = UICollectionViewFlowLayout()
        flowLayout.scrollDirection = .Horizontal
        flowLayout.minimumLineSpacing = 9
        flowLayout.minimumInteritemSpacing = 9
        flowLayout.itemSize = CGSize(width: 58, height: 58)
        collectionViewPhotos = UICollectionView(frame: CGRectMake(96 - x, 328 - y, 263, 58), collectionViewLayout: flowLayout)
        collectionViewPhotos.registerNib(UINib(nibName: "NameCardAddCollectionViewCell",bundle: nil), forCellWithReuseIdentifier: cellPhotos)
        collectionViewPhotos.delegate = self
        collectionViewPhotos.dataSource = self
        collectionViewPhotos.backgroundColor = UIColor.clearColor()
        //collectionViewPhotos.alwaysBounceVertical = true
        uiviewDialog.addSubview(collectionViewPhotos)
        
        imageViewLeft = UIImageView(frame: CGRectMake(80 - x, 351 - y, 7.5, 13))
        imageViewLeft.image = UIImage(named: "nameCardLeft")
        uiviewDialog.addSubview(imageViewLeft)
        
        imageViewRight = UIImageView(frame: CGRectMake(366 - x, 351 - y, 7.5, 13))
        imageViewRight.image = UIImage(named: "nameCardRight")
        uiviewDialog.addSubview(imageViewRight)
        
        //load button
        buttonChat = UIButton(frame: CGRect(x:(maxLength-130)/2, y: 245, width: 130, height: 39))
        buttonChat.backgroundColor = UIColor(red: 249/255, green: 90/255, blue: 90/255, alpha: 1.0)
        buttonChat.layer.cornerRadius = 7
        buttonChat.setTitle("Chat", forState: .Normal)
        buttonChat.titleLabel?.font = UIFont(name: "AvenirNext-Medium", size: 20.0)
        buttonChat.addTarget(self, action: #selector(FaeMapViewController.buttonChatAction(_:)), forControlEvents: .TouchUpInside)
        
        loadTags()
        

        uiviewDialog.addSubview(buttonMore)
        uiviewDialog.addSubview(labelNamecardName)
        uiviewDialog.addSubview(labelNamecardDescription)
        uiviewDialog.addSubview(viewLine)
        
        uiviewDialog.addSubview(buttonChat)
        
        self.view.addSubview(uiviewDialog)
        self.uiviewDialog.addSubview(imageviewNamecardAvatar)
        
        uiviewDialog.alpha = 0.0

    }
    
    func showOpenUserPinAnimation(lati: CLLocationDegrees, longi: CLLocationDegrees) {
        UIView.animateWithDuration(0.2, animations: ({
            self.uiviewDialog.alpha = 1.0
        }))
        openUserPinActive = true
        let camera = GMSCameraPosition.cameraWithLatitude(lati+0.001, longitude: longi, zoom: 17)
        faeMapView.animateToCameraPosition(camera)
        if commentPinCellsOpen {
            hideCommentPinCells()
            commentPinCellsOpen = false
        }
    }
    
    func hideOpenUserPinAnimation() {
        UIView.animateWithDuration(0.2, animations: ({
            self.uiviewDialog.alpha = 0.0
        }))
    }
    
    func getColor(red : CGFloat, green : CGFloat, blue : CGFloat) -> UIColor {
        return UIColor(red: red / 255, green: green / 255, blue: blue / 255, alpha: 1.0)
    }
    
    func loadTags(){
        uiviewTag = UIView(frame: CGRect(x: 0, y: 135, width: maxLength, height: tagHeight))
        uiviewDialog.addSubview(uiviewTag)
        
        tagColor.append(getColor(255, green: 114, blue: 169))
        tagColor.append(getColor(178, green: 228, blue: 77))
        tagColor.append(getColor(255, green: 126, blue: 126))
        
        var totalInterval = (CGFloat)(tagName.count - 1) * selectedInterval
        var totalTag : CGFloat = 0
        
        
        
        for tag in tagName {
            
            let attributedString = NSMutableAttributedString(string: tag)
            attributedString.addAttribute(NSKernAttributeName, value: CGFloat(-0.1), range: NSRange(location: 0, length: attributedString.length))
            attributedString.addAttribute(NSFontAttributeName, value: UIFont(name: "AvenirNext-DemiBold",size: 11)!, range: NSRange(location: 0, length: attributedString.length))
            
            let length = attributedString.widthWithConstrainedHeight(15)
            tagLength.append(length + 2*exlength)
            totalTag += length + 2*exlength
            tagTitle.append(attributedString)
            
        }
        
        var xOffset : CGFloat = (maxLength - totalTag - totalInterval) / 2
        
        for (var i=0; i<tagName.count; i++){
             var buttonTag : UIButton = UIButton(frame: CGRect(x: xOffset, y: 0, width: tagLength[i], height: tagHeight))
            buttonTag.backgroundColor = tagColor[i]
            buttonTag.setAttributedTitle(tagTitle[i], forState: .Normal)
            buttonTag.titleLabel?.textColor = UIColor.whiteColor()
            uiviewTag.addSubview(buttonTag)
            xOffset += (tagLength[i]+intervalInLine)
        }
    }
    
    override func touchesBegan(touches: Set<UITouch>, withEvent event: UIEvent?) {
        if let touch: UITouch = touches.first{
            if(touch.view != uiviewFunction && touch.view != buttonMore){
                hideFunctionview()
            }
        }
    }
    
    func loadFunctionview(){
        uiviewFunction = UIView(frame: CGRect(x: (maxLength-298)/2+5,y: 42,width: 298,height: 110))
        uiviewFunction.backgroundColor = UIColor(patternImage: UIImage(named: "map_namecard_popup")!)
        uiviewDialog.addSubview(uiviewFunction)
        
        let buttonWidth = 42.0
        let interval = 25.0
        buttonFollow = UIButton(frame: CGRect(x: (298-4*buttonWidth-3*interval)/2,y: 10,width: buttonWidth,height: 110))
        buttonFollow.setImage(UIImage(named: "map_namecard_follow"), forState: .Normal)
        buttonFollow.addTarget(self, action: #selector(buttonFollowAction(_:)), forControlEvents: .TouchUpInside)
        uiviewFunction.addSubview(buttonFollow)
        
        buttonShare = UIButton(frame: CGRect(x: (298-2*buttonWidth-interval)/2,y: 10,width: buttonWidth,height: 110))
        buttonShare.setImage(UIImage(named: "map_namecard_share"), forState: .Normal)
        buttonShare.addTarget(self, action: #selector(buttonShareAction(_:)), forControlEvents: .TouchUpInside)
        uiviewFunction.addSubview(buttonShare)
        
        buttonKeep = UIButton(frame: CGRect(x: (298-2*buttonWidth-interval)/2+interval+buttonWidth,y: 10,width: buttonWidth,height: 110))
        buttonKeep.setImage(UIImage(named: "map_namecard_keep"), forState: .Normal)
        buttonKeep.addTarget(self, action: #selector(buttonKeepAction(_:)), forControlEvents: .TouchUpInside)
        uiviewFunction.addSubview(buttonKeep)
        
        buttonReport = UIButton(frame: CGRect(x: (298-2*buttonWidth-interval)/2+2*interval+2*buttonWidth,y: 10,width: buttonWidth,height: 110))
        buttonReport.setImage(UIImage(named: "map_namecard_report"), forState: .Normal)
        buttonReport.addTarget(self, action: #selector(buttonReportAction(_:)), forControlEvents: .TouchUpInside)
        uiviewFunction.addSubview(buttonReport)
        
        uiviewFunction.hidden = true
    }
    
    func buttonFollowAction(sender: UIButton!){
        print("Follow")
    }
    
    func buttonShareAction(sender: UIButton!){
        print("Share")
    }
    
    func buttonKeepAction(sender: UIButton!){
        print("Keep")
    }
    
    func buttonReportAction(sender: UIButton!){
        print("Report")
    }

    
    func buttonChatAction(sender: UIButton!){
        print("chat")
    }
    
    func buttonMoreAction(sender: UIButton!){
        print("more")
        showFunctionview()
    }
    
    func hideFunctionview(){
        uiviewFunction.hidden = true
        labelNamecardName.hidden = false
        labelNamecardDescription.hidden = false
        uiviewTag.hidden = false
        print("hiddend")
    }
    
    func showFunctionview(){
        uiviewFunction.hidden = false
        labelNamecardName.hidden = true
        labelNamecardDescription.hidden = true
        uiviewTag.hidden = true
        print("show")
    }
    
    func collectionView(collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return 8
    }
    func collectionView(collectionView: UICollectionView, cellForItemAtIndexPath indexPath: NSIndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCellWithReuseIdentifier(cellPhotos, forIndexPath: indexPath)as! NameCardAddCollectionViewCell
        if indexPath.row==1{
            cell.imageViewTitle.image = UIImage(named: "map_namecard_photo")
        }
        else if indexPath.row==0{
            cell.imageViewTitle.image = UIImage(named: "map_namecard_photo3")
        }
        else if indexPath.row==2{
            cell.imageViewTitle.image = UIImage(named: "map_namecard_photo")
        }
        else if indexPath.row==3{
            cell.imageViewTitle.image = UIImage(named: "map_namecard_photo1")
        }
        else if indexPath.row==4{
            cell.imageViewTitle.image = UIImage(named: "map_namecard_photo2")
        }
        else if indexPath.row==5{
            cell.imageViewTitle.image = UIImage(named: "map_namecard_photo3")
        }
        else if indexPath.row==6{
            cell.imageViewTitle.image = UIImage(named: "map_namecard_photo3")
        }
        else if indexPath.row==7{
            cell.imageViewTitle.image = UIImage(named: "map_namecard_photo3")
        }
        else{
            cell.imageViewTitle.image = UIImage(named: "nameCardEmpty")
        }
        
        return cell
    }
    


    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

}

