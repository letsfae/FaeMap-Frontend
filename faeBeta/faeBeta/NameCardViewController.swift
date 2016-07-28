//
//  NameCardViewController.swift
//  faeBeta
//
//  Created by User on 7/15/16.
//  Copyright © 2016 fae. All rights reserved.
//

import UIKit

class NameCardViewController: UIViewController {
    
    let screenWidth = UIScreen.mainScreen().bounds.width
    let screenHeight = UIScreen.mainScreen().bounds.height
    // tagView
    let tagName = ["Single", "HMU", "I do Favors", "Seller", "Services", "LF Friends", "Student", "Foodie", "For Hire", "Dating", "Local", "Visitor", "AMA", "Athlete", "Traveller", "Bookworm", "Cinephile"]
    var tagView : UIView!
    var selectedTagView : UIView!
    var cancel : UIButton!
    var tagButtonSet = [UIButton]()
    var selectedButtonSet = [UIButton]()
    var tagLength = [CGFloat]()
    var tagColor = [UIColor]()
    var tagTitle = [NSMutableAttributedString]()
    let exlength : CGFloat = 8
    let selectedInterval : CGFloat = 11
    let maxLength : CGFloat = 300
    let lineInterval : CGFloat = 25.7
    let intervalInLine : CGFloat = 13.8
    let tagHeight : CGFloat = 18
    var tagContentView : UIView!
    // tableView
    var tableViewNameCard : UITableView!
    let cellGeneral = "cellGeneral"
    let cellAddPhotos = "cellAddPhotos"
    // table header view
    var viewHeaderBackground : UIView!
    var viewHeaderUnderline : UIView!
    var viewHeader : UIView!
    var labelHeaderTitle : UILabel!
    var viewAvatarShadow : UIView!
    var imageViewAvatar : UIImageView!
    var imageGender : UIImageView!
    var labelHeaderName : UILabel!
    var labelHeaderIntroduction : UILabel!
    var labelHeaderTags : UILabel!
    var viewTagsUnderline : UIView!
    
    var collectionViewPhotos : UICollectionView!
    var cellPhotos = "cellPhotos"
    var imageViewLeft : UIImageView!
    var imageViewRight : UIImageView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.title = "Your NameCards"
        initialTagView()
        initialTableView()
        self.navigationController?.navigationBar.topItem?.title = ""
        // Do any additional setup after loading the view.
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    
    
    func getColor(red : CGFloat, green : CGFloat, blue : CGFloat) -> UIColor {
        return UIColor(red: red / 255, green: green / 255, blue: blue / 255, alpha: 1.0)
    }

}

//MARK: add tableView
extension NameCardViewController : UITableViewDelegate, UITableViewDataSource {
    func initialTableView() {
        tableViewNameCard = UITableView(frame: CGRectMake(0, 0, screenWidth, screenHeight), style: .Grouped)
        tableViewNameCard.delegate = self
        tableViewNameCard.dataSource = self
        tableViewNameCard.backgroundColor = UIColor.clearColor()
        tableViewNameCard.separatorStyle = .None
        
        tableViewNameCard.registerNib(UINib(nibName: "NameCardGeneralTableViewCell",bundle: nil), forCellReuseIdentifier: cellGeneral)
        tableViewNameCard.registerNib(UINib(nibName: "NameCardAddTableViewCell",bundle: nil), forCellReuseIdentifier: cellAddPhotos)
        self.view.addSubview(tableViewNameCard)
        initialHeaderView()
    }
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 4
    }
    func tableView(tableView: UITableView, heightForRowAtIndexPath indexPath: NSIndexPath) -> CGFloat {
        if indexPath.row == 3 {
            return 110
        }
        return 60
    }
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        if indexPath.row < 3 {
            let cell = tableView.dequeueReusableCellWithIdentifier(cellGeneral, forIndexPath: indexPath) as! NameCardGeneralTableViewCell
            cell.selectionStyle = .None
            if indexPath.row == 0 {
                cell.labelTitle.text = "Nickname"
                cell.labelDetail.text = "linlinlin"
            } else if indexPath.row == 1 {
                cell.labelTitle.text = "Short Intro"
                cell.labelDetail.text = "introduction"
            } else if indexPath.row == 2 {
                cell.labelTitle.text = "Choose Tags"
            }
            return cell
        } else {
            let cell = tableView.dequeueReusableCellWithIdentifier(cellAddPhotos, forIndexPath: indexPath)as! NameCardAddTableViewCell
            cell.selectionStyle = .None
            cell.viewSelf = self
            return cell
        }
        return UITableViewCell()
    }
}
//MARK: add Header view
extension NameCardViewController : UICollectionViewDelegate, UICollectionViewDataSource{
    func initialHeaderView() {
        viewHeaderBackground = UIView(frame: CGRectMake(0,0,screenWidth,360))//-64
        tableViewNameCard.tableHeaderView = viewHeaderBackground
        tableViewNameCard.tableHeaderView?.frame = CGRectMake(0, 0, screenWidth, 360)
        
        labelHeaderTitle = UILabel(frame: CGRectMake(172,80 - 64,70,25))
        labelHeaderTitle.text = "Preview:"
        labelHeaderTitle.font = UIFont(name: "AvenirNext-Medium", size: 18)
        labelHeaderTitle.textColor = UIColor(colorLiteralRed: 89/255, green: 89/255, blue: 89/255, alpha: 1)
        viewHeaderBackground.addSubview(labelHeaderTitle)
        
        viewHeaderUnderline = UIView(frame: CGRectMake(17,360,screenWidth - 17 * 2, 2))
        viewHeaderUnderline.backgroundColor = UIColor(colorLiteralRed: 200/255, green: 199/255, blue: 204/255, alpha: 1)
        viewHeaderBackground.addSubview(viewHeaderUnderline)
        
        viewHeader = UIView(frame: CGRectMake(42,100,330,222))
        viewHeader.layer.borderColor = UIColor(colorLiteralRed: 200/255, green: 199/255, blue: 204/255, alpha: 1).CGColor
        viewHeader.layer.cornerRadius = 19
        viewHeader.layer.borderWidth = 2
        viewHeaderBackground.addSubview(viewHeader)
        
        viewAvatarShadow = UIView(frame: CGRectMake((screenWidth-68)/2,123 - 64,68,68))//173,123 - 64
        viewAvatarShadow.layer.shadowOpacity = 0.5
        viewAvatarShadow.layer.shadowOffset = CGSize(width: 0, height: 0)
        viewAvatarShadow.layer.shadowColor = UIColor.blackColor().CGColor
        viewAvatarShadow.layer.shadowRadius = 4.0
        viewHeaderBackground.addSubview(viewAvatarShadow)
        
//        imageViewAvatar = UIImageView(frame: CGRectMake(177, 127 - 64, 60, 60))//50
        imageViewAvatar = UIImageView(frame: CGRectMake(9, 9, 50, 50))
        imageViewAvatar.image = UIImage(named: "myAvatorLin")
//        imageViewAvatar.layer.shadow
        imageViewAvatar.layer.cornerRadius = imageViewAvatar.bounds.height / 2
        viewAvatarShadow.addSubview(imageViewAvatar)
//        viewHeaderBackground.addSubview(imageViewAvatar)
        
        let x : CGFloat = 42
        let y : CGFloat = 165
        imageGender = UIImageView(frame: CGRectMake(83-x, 198-y, 26, 18))
        imageGender.image = UIImage(named: "nameCardMale")
        viewHeader.addSubview(imageGender)
        
        labelHeaderName = UILabel(frame: CGRectMake(117 - x,194 - y, 180, 27))
        labelHeaderName.text = "Lin Lin"
        labelHeaderName.textAlignment = .Center
        viewHeader.addSubview(labelHeaderName)
        
        labelHeaderIntroduction = UILabel(frame: CGRectMake(120 - x, 225 - y, 174, 20))
//        labelHeaderIntroduction = UILabel(frame: CGRectMake(CGRectMake(120-x,225-y,174,20));
        labelHeaderIntroduction.textAlignment = .Center
        labelHeaderIntroduction.text = "Your short intro goes here"
        labelHeaderIntroduction.textColor = getColor(155, green: 155, blue: 155)
        viewHeader.addSubview(labelHeaderIntroduction)
        
        labelHeaderTags = UILabel(frame: CGRectMake(139-x,272-y,136,20))
        labelHeaderTags.textColor = getColor(155, green: 155, blue: 155)
        labelHeaderTags.text = "Your tags show here"
        viewHeader.addSubview(labelHeaderTags)
        
        viewTagsUnderline = UIView(frame: CGRectMake(81-x,298-y,252,2))
        viewTagsUnderline.backgroundColor = getColor(200, green: 199, blue: 204)
        viewHeader.addSubview(viewTagsUnderline)
        
        let flowLayout = UICollectionViewFlowLayout()
        flowLayout.scrollDirection = .Horizontal
        flowLayout.minimumLineSpacing = 9
        flowLayout.minimumInteritemSpacing = 9
        flowLayout.itemSize = CGSize(width: 58, height: 58)
        collectionViewPhotos = UICollectionView(frame: CGRectMake(76 - x, 313 - y, 263, 58), collectionViewLayout: flowLayout)
        collectionViewPhotos.registerNib(UINib(nibName: "NameCardAddCollectionViewCell",bundle: nil), forCellWithReuseIdentifier: cellPhotos)
        collectionViewPhotos.delegate = self
        collectionViewPhotos.dataSource = self
        collectionViewPhotos.backgroundColor = UIColor.clearColor()
        viewHeader.addSubview(collectionViewPhotos)
        
        imageViewLeft = UIImageView(frame: CGRectMake(60 - x, 336 - y, 7.5, 13))
        imageViewLeft.image = UIImage(named: "nameCardLeft")
        viewHeader.addSubview(imageViewLeft)
        
        imageViewRight = UIImageView(frame: CGRectMake(346 - x, 336 - y, 7.5, 13))
        imageViewRight.image = UIImage(named: "nameCardRight")
        viewHeader.addSubview(imageViewRight)

    }
    func collectionView(collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return 8
    }
    func collectionView(collectionView: UICollectionView, cellForItemAtIndexPath indexPath: NSIndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCellWithReuseIdentifier(cellPhotos, forIndexPath: indexPath)as! NameCardAddCollectionViewCell
        cell.imageViewTitle.image = UIImage(named: "nameCardEmpty")
        
        return cell
    }
    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        if indexPath.row == 2 {
            showTagView()
        }
    }
}
//MARK: add tag view
extension NameCardViewController {
    func initialTagView(){
        cancel = UIButton(frame: CGRect(x: 0, y: 0, width: screenWidth, height: screenHeight))
        cancel.backgroundColor = UIColor(red: 107 / 255, green: 105 / 255, blue: 105 / 255, alpha: 0.5)
        cancel.layer.zPosition = 2
        
        cancel.addTarget(self, action: #selector(NameCardViewController.dismissTagView), forControlEvents: .TouchUpInside)
        prepareTagColor()
        addTagView()
        addSelectedTagView()
    }
    func addTagView() {
        tagView = UIView(frame: CGRect(x: 32, y: 153, width: 350, height: 350))
        tagView.layer.cornerRadius = 26
        tagView.layer.zPosition = 10
        tagView.backgroundColor = UIColor.whiteColor()
        let title = UILabel(frame: CGRect(x: 123, y: 31, width: 104, height: 21))
        title.font = UIFont(name: "Avenir Next", size: 20)
        title.textColor = UIColor(red: 107 / 255, green: 105 / 255, blue: 105 / 255, alpha: 1.0)
        let attributedString = NSMutableAttributedString(string: "Add Tags")
        attributedString.addAttribute(NSKernAttributeName, value: CGFloat(-0.2), range: NSRange(location: 0, length: attributedString.length))
        title.attributedText = attributedString
        title.textAlignment = .Center
        tagView.addSubview(title)
        
        let cancelButton = UIButton(frame: CGRect(x: 15, y: 16, width: 17, height: 17))
        cancelButton.setImage(UIImage(named: "check_cross_red"), forState: .Normal)
        cancelButton.addTarget(self, action: #selector(NameCardViewController.dismissTagView), forControlEvents: .TouchUpInside)
        tagView.addSubview(cancelButton)
        
        let subtitle = UILabel(frame: CGRect(x: 100, y: 55, width: 147, height: 18))
        subtitle.font = UIFont(name: "Avenir Next", size: 13)
        subtitle.textColor = UIColor(red: 138 / 255, green: 138 / 255, blue: 138 / 255, alpha: 1.0)
        subtitle.textAlignment = .Center
        subtitle.text = "Select up to 3 tags"
        tagView.addSubview(subtitle)
        
        let underLine = UIView(frame: CGRect(x: 25, y: 107, width: 300, height: 2))
        underLine.backgroundColor = UIColor(red: 200 / 255, green: 199 / 255, blue: 204 / 255, alpha: 1.0)
        tagView.addSubview(underLine)
        
        let saveButton = UIButton(frame: CGRect(x: 110, y: 291, width: 130, height: 39))
        saveButton.layer.cornerRadius = 7
        saveButton.backgroundColor = UIColor(red: 249 / 255, green: 90 / 255, blue: 90 / 255, alpha: 1.0)
        saveButton.setTitle("Save", forState: .Normal)
        saveButton.titleLabel?.font = UIFont(name: "Avenir Next", size: 16)
        saveButton.titleLabel?.textColor = UIColor.whiteColor()
        tagView.addSubview(saveButton)
        
        tagContentView = UIView(frame: CGRect(x: 25, y: 120, width: 300, height: 160))
        
        attachTag()
        
        attachColor()
        
        tagView.addSubview(tagContentView)
        
        
    }
    func showTagView() {
        self.view.addSubview(cancel)
        self.view.addSubview(tagView)
    }
    func dismissTagView() {
        tagView.hidden = true
        cancel.hidden = true
    }
    
    func selectTag(sender : UIButton) {
        if selectedButtonSet.count != 3 && !sender.hidden {
            var newButton = UIButton(frame: sender.frame)
            let attributedString = NSMutableAttributedString(string: (sender.titleLabel?.text)!)
            attributedString.addAttribute(NSKernAttributeName, value: CGFloat(-0.1), range: NSRange(location: 0, length: attributedString.length))
            attributedString.addAttribute(NSFontAttributeName, value: UIFont(name: "AvenirNext-DemiBold",size: 11)!, range: NSRange(location: 0, length: attributedString.length))
            addAttributeToTagButton(newButton, tag: attributedString)
            newButton.backgroundColor = sender.backgroundColor
            newButton.addTarget(self, action: #selector(deselectedTag), forControlEvents: .TouchUpInside)
            selectedButtonSet.append(newButton)
            attachSelectedTag()
            sender.hidden = true
        }
    }
    
    func addSelectedTagView() {
        selectedTagView = UIView(frame: CGRect(x: 25, y: 81, width: 300, height: 26))
        tagView.addSubview(selectedTagView)
    }
    
    func attachSelectedTag() {
        
        var totalInterval = (CGFloat)(selectedButtonSet.count - 1) * selectedInterval
        var totalTag : CGFloat = 0
        for button in selectedButtonSet {
            totalTag += button.frame.width
        }
        var xOffset : CGFloat = (maxLength - totalTag - totalInterval) / 2
        for button in selectedButtonSet {
            button.removeFromSuperview()
            button.frame = CGRect(x: xOffset, y: 0, width: button.frame.width, height: button.frame.height)
            selectedTagView.addSubview(button)
            xOffset += button.frame.width + selectedInterval
        }
        
    }
    
    func deselectedTag(sender : UIButton) {
        for button in tagButtonSet {
            if button.hidden && sender.titleLabel?.text == button.titleLabel?.text {
                button.hidden = false
                break
            }
        }
        for (var i = 0; i < selectedButtonSet.count; i++) {
            if selectedButtonSet[i].titleLabel?.text == sender.titleLabel?.text {
                selectedButtonSet[i].removeFromSuperview()
                selectedButtonSet.removeAtIndex(i)
                break
            }
        }
        
        if(selectedButtonSet.count > 0) {
            attachSelectedTag()
        }
    }
    
    func prepareTagColor() {
        tagColor.append(getColor(255, green: 114, blue: 169))
        tagColor.append(getColor(178, green: 228, blue: 77))
        tagColor.append(getColor(255, green: 126, blue: 126))
        tagColor.append(getColor(72, green: 221, blue: 188))
        tagColor.append(getColor(151, green: 161, blue: 236))
        tagColor.append(getColor(230, green: 140, blue: 102))
        tagColor.append(getColor(145, green: 209, blue: 252))
        tagColor.append(getColor(251, green: 202, blue: 81))
        tagColor.append(getColor(228, green: 108, blue: 108))
        tagColor.append(getColor(223, green: 157, blue: 248))
        tagColor.append(getColor(122, green: 212, blue: 134))
        tagColor.append(getColor(192, green: 154, blue: 210))
        tagColor.append(getColor(252, green: 191, blue: 157))
        tagColor.append(getColor(138, green: 138, blue: 138))
        tagColor.append(getColor(102, green: 160, blue: 228))
        tagColor.append(getColor(168, green: 129, blue: 120))
        tagColor.append(getColor(116, green: 184, blue: 188))
    }
    
    func attachColor() {
        for (var i = 0; i < tagButtonSet.count; i++) {
            tagButtonSet[i].backgroundColor = tagColor[i]
        }
    }
    
    func attachTag() {
        
        for tag in tagName {
            
            let attributedString = NSMutableAttributedString(string: tag)
            attributedString.addAttribute(NSKernAttributeName, value: CGFloat(-0.1), range: NSRange(location: 0, length: attributedString.length))
            attributedString.addAttribute(NSFontAttributeName, value: UIFont(name: "AvenirNext-DemiBold",size: 11)!, range: NSRange(location: 0, length: attributedString.length))
            
            let length = attributedString.widthWithConstrainedHeight(15)
            tagLength.append(length)
            tagTitle.append(attributedString)
        }
        
        var originPoint = CGPoint(x: 0, y: 0)
        
        var totalTagLength : CGFloat = 0
        
        var totalLength : CGFloat = 0
        
        var line : CGFloat = 0
        
        var tagInOneLine = [NSMutableAttributedString]()
        
        for (var i = 0; i < tagName.count; i += 1) {
            
            if totalLength == 0 {
                tagInOneLine.append(tagTitle[i])
                totalLength += tagLength[i] + 2 * exlength
                totalTagLength += tagLength[i] + 2 * exlength
            } else {
                if totalLength + tagLength[i] + 2 * exlength + intervalInLine < maxLength {
                    tagInOneLine.append(tagTitle[i])
                    totalLength += tagLength[i] + 2 * exlength + intervalInLine
                    totalTagLength += tagLength[i] + 2 * exlength
                } else {
                    let totalInterval = maxLength - totalTagLength
                    var xOffset : CGFloat = 0
                    for tag in tagInOneLine {
                        let button = UIButton(frame: CGRect(x: originPoint.x + xOffset, y: originPoint.y + line * (lineInterval + tagHeight), width: tag.widthWithConstrainedHeight(tagHeight) + 2 * exlength, height: tagHeight))
                        addAttributeToTagButton(button, tag: tag)
                        button.addTarget(self, action: #selector(selectTag), forControlEvents: .TouchUpInside)
                        tagContentView.addSubview(button)
                        tagButtonSet.append(button)
                        xOffset += totalInterval / ((CGFloat)(tagInOneLine.count) - 1) + tag.widthWithConstrainedHeight(tagHeight) + 2 * exlength
                    }
                    tagInOneLine.removeAll()
                    i = i - 1
                    line += 1
                    totalLength = 0
                    totalTagLength = 0
                }
            }
            
        }
        var xOffset : CGFloat = 0
        
        for tag in tagInOneLine {
            
            let button = UIButton(frame: CGRect(x: originPoint.x + xOffset, y: originPoint.y + line * (lineInterval + tagHeight), width: tag.widthWithConstrainedHeight(tagHeight) + 2 * exlength, height: tagHeight))
            addAttributeToTagButton(button, tag: tag)
            button.addTarget(self, action: #selector(selectTag), forControlEvents: .TouchUpInside)
            tagContentView.addSubview(button)
            tagButtonSet.append(button)
            xOffset += intervalInLine + tag.widthWithConstrainedHeight(tagHeight) + 2 * exlength
            
        }
        
    }
    
    func addAttributeToTagButton(button : UIButton, tag: NSMutableAttributedString) {
        button.titleLabel?.textColor = UIColor.whiteColor()
        button.setAttributedTitle(tag, forState: .Normal)
        //        button.contentEdgeInsets = UIEdgeInsets(top: 1, left: 0, bottom: 1, right: 8)
        button.titleEdgeInsets = UIEdgeInsets(top: 1, left: 0, bottom: 0, right: 0)
        button.layer.cornerRadius = 3
    }
}

extension NSAttributedString {
    
    func widthWithConstrainedHeight(height: CGFloat) -> CGFloat {
        let constraintRect = CGSize(width: CGFloat.max, height: height)
        
        let boundingBox = self.boundingRectWithSize(constraintRect, options: NSStringDrawingOptions.UsesLineFragmentOrigin, context: nil)
        
        return boundingBox.width
    }
}
