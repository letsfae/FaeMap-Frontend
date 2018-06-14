//
//  MBComtsStoriesCell.swift
//  faeBeta
//
//  Created by vicky on 2017/6/16.
//  Copyright © 2017年 fae. All rights reserved.
//

import UIKit

// A protocol that the TableViewCell uses to inform its delegate of state change
protocol MBComtsStoriesCellDelegate: class {
    
    func replyToThisPin(indexPath: IndexPath, boolReply: Bool)
    func likeThisPin(indexPath: IndexPath, strPinId: String)
}

class MBComtsStoriesCell: UITableViewCell, UIScrollViewDelegate {
    var btnLoc: UIButton!
    var btnFav: UIButton!
    var btnReply: UIButton!
    var imgAvatar: UIImageView!
    var imgHotPin: UIImageView!
    var lblLoc: MBAddressLabel!
    var lblContent: UILabel!
    var lblFavCount: UILabel!
    var lblReplyCount: UILabel!
    var lblTime: UILabel!
    var lblUsrName: UILabel!
    var uiviewCellFooter: UIView!
    var imgFeelings = [UIImageView]()
    
    var indexForCurtCell: IndexPath!
    var strPinId: String!
    static var strPinType = ""
    
    var scrollViewMedia: UIScrollView!
    var imgMediaArr = [UIImageView]()
    
    weak var delegate: MBComtsStoriesCellDelegate?
    
    override init(style: UITableViewCellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        let separatorView = UIView()
        separatorView.backgroundColor = UIColor._234234234()
        addSubview(separatorView)
        addConstraintsWithFormat("H:|-0-[v0]-0-|", options: [], views: separatorView)
        addConstraintsWithFormat("V:[v0(5)]-0-|", options: [], views: separatorView)
        selectionStyle = .none
        loadCellContent()
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
    
    func loadCellContent() {
        imgAvatar = UIImageView(frame: CGRect.zero)
        addSubview(imgAvatar)
        imgAvatar.layer.cornerRadius = 25
        imgAvatar.clipsToBounds = true
        imgAvatar.contentMode = .scaleAspectFill
        addConstraintsWithFormat("H:|-15-[v0(50)]", options: [], views: imgAvatar)
        
        lblUsrName = UILabel()
        addSubview(lblUsrName)
        lblUsrName.font = UIFont(name: "AvenirNext-Medium", size: 18)
        lblUsrName.textColor = UIColor._898989()
        addConstraintsWithFormat("H:|-80-[v0]-15-|", options: [], views: lblUsrName)
        
        lblTime = UILabel()
        addSubview(lblTime)
        lblTime.font = UIFont(name: "AvenirNext-Medium", size: 13)
        lblTime.textColor = UIColor._107107107()
        addConstraintsWithFormat("H:|-80-[v0]-15-|", options: [], views: lblTime)
        
        lblContent = UILabel()
        addSubview(lblContent)
        lblContent.font = UIFont(name: "AvenirNext-Regular", size: 18)
        lblContent.textColor = UIColor._898989()
        lblContent.lineBreakMode = .byWordWrapping
        lblContent.numberOfLines = 0
        addConstraintsWithFormat("H:|-27-[v0]-27-|", options: [], views: lblContent)
        
        btnLoc = UIButton()
        btnLoc.setImage(#imageLiteral(resourceName: "mb_loc"), for: .normal)
        btnLoc.backgroundColor = UIColor(red: 248 / 255, green: 248 / 255, blue: 248 / 255, alpha: 1)
        btnLoc.contentHorizontalAlignment = .left
        addSubview(btnLoc)
        addConstraintsWithFormat("H:|-19-[v0]-19-|", options: [], views: btnLoc)
        
        lblLoc = MBAddressLabel(frame: CGRect.zero)
        btnLoc.addSubview(lblLoc)
        lblLoc.font = UIFont(name: "AvenirNext-Medium", size: 15)
        lblLoc.textColor = UIColor._898989()
        lblLoc.lineBreakMode = .byTruncatingTail
        btnLoc.addConstraintsWithFormat("H:|-42-[v0]-2-|", options: [], views: lblLoc)
        btnLoc.addConstraintsWithFormat("V:|-6-[v0(20)]", options: [], views: lblLoc)
        
        uiviewCellFooter = UIView()
        addSubview(uiviewCellFooter)
        uiviewCellFooter.backgroundColor = .clear
        addConstraintsWithFormat("H:|-14-[v0]-14-|", options: [], views: uiviewCellFooter)
        
        btnFav = UIButton()
        btnFav.setImage(#imageLiteral(resourceName: "pinDetailLikeHeartHollow"), for: .normal)
        uiviewCellFooter.addSubview(btnFav)
        addConstraintsWithFormat("V:|-2-[v0(22)]", options: [], views: btnFav)
        
        btnReply = UIButton()
        btnReply.setImage(#imageLiteral(resourceName: "pinDetailShowCommentsHollow"), for: .normal)
        uiviewCellFooter.addSubview(btnReply)
        addConstraintsWithFormat("V:|-2-[v0(22)]", options: [], views: btnReply)
        
        btnFav.addTarget(self, action: #selector(self.actionLikeThisPin(_:)), for: [.touchUpInside, .touchUpOutside])
        //        btnFav.addTarget(self, action: #selector(self.actionHoldingLikeButton(_:)), for: .touchDown)
        btnReply.addTarget(self, action: #selector(self.actionReplyToThisPin(_:)), for: .touchUpInside)
        btnReply.tag = 0
        
        lblFavCount = UILabel()
        uiviewCellFooter.addSubview(lblFavCount)
        lblFavCount.font = UIFont(name: "AvenirNext-Medium", size: 15)
        lblFavCount.textColor = UIColor._107107107()
        lblFavCount.textAlignment = .right
        addConstraintsWithFormat("V:|-3-[v0(20)]", options: [], views: lblFavCount)
        
        lblReplyCount = UILabel()
        uiviewCellFooter.addSubview(lblReplyCount)
        lblReplyCount.font = UIFont(name: "AvenirNext-Medium", size: 15)
        lblReplyCount.textColor = UIColor._107107107()
        lblReplyCount.textAlignment = .right
        addConstraintsWithFormat("V:|-3-[v0(20)]", options: [], views: lblReplyCount)
        
        addConstraintsWithFormat("H:[v0(41)]-8-[v1(26)]-17-[v2(41)]-8-[v3(26)]-0-|", options: [], views: lblFavCount, btnFav, lblReplyCount, btnReply)
        addConstraintsWithFormat("V:|-19-[v0(25)]-1-[v1(18)]", options: [], views: lblUsrName, lblTime)
        
        for index in 0..<5 {
            let imgFeeling = UIImageView(frame: CGRect(x: 30 * index, y: 0, width: 27, height: 27))
            imgFeelings.append(imgFeeling)
            uiviewCellFooter.addSubview(imgFeelings[index])
        }
        
        switch MBComtsStoriesCell.strPinType {
        case "comment":
            addConstraintsWithFormat("V:|-15-[v0(50)]-10-[v1]-10-[v2(32)]-17-[v3(27)]-10-|", options: [], views: imgAvatar, lblContent, btnLoc, uiviewCellFooter)
        case "media":
            scrollViewMedia = UIScrollView()
            scrollViewMedia.delegate = self
            scrollViewMedia.isScrollEnabled = true
            scrollViewMedia.backgroundColor = .clear
            scrollViewMedia.showsHorizontalScrollIndicator = false
            addSubview(scrollViewMedia)
            var insets = scrollViewMedia.contentInset
            insets.left = 15
            insets.right = 15
            scrollViewMedia.contentInset = insets
            scrollViewMedia.scrollToLeft(animated: false)
            
            addConstraintsWithFormat("H:|-0-[v0]-0-|", options: [], views: scrollViewMedia)
            addConstraintsWithFormat("V:|-15-[v0(50)]-10-[v1]-12-[v2(95)]-12-[v3(32)]-17-[v4(27)]-10-|", options: [], views: imgAvatar, lblContent, scrollViewMedia, btnLoc, uiviewCellFooter)
            
            let tapGesture = UITapGestureRecognizer(target: self, action: #selector(self.actionReplyToThisPin(_:)))
            scrollViewMedia.addGestureRecognizer(tapGesture)
        default: break
        }
        
        imgHotPin = UIImageView()
        imgHotPin.image = #imageLiteral(resourceName: "pinDetailHotPin")
        addSubview(imgHotPin)
        imgHotPin.clipsToBounds = true
        imgHotPin.contentMode = .scaleAspectFill
        imgHotPin.isHidden = true
        addConstraintsWithFormat("H:[v0(18)]-15-|", options: [], views: imgHotPin)
        addConstraintsWithFormat("V:|-15-[v0(20)]", options: [], views: imgHotPin)
    }

    func setAddressForCell(position: CLLocationCoordinate2D, id: Int, type: String) {
        lblLoc.pinId = id
        lblLoc.pinType = type
        lblLoc.loadAddress(position: position, id: id, type: type)
    }
    
    func setValueForCell(social: MBSocialStruct) {
        self.strPinId = String(social.pinId)
        
        if social.anonymous || social.displayName == "" {
            lblUsrName.text = "Someone"
            imgAvatar.image = #imageLiteral(resourceName: "default_Avatar")
        } else {
            lblUsrName.text = social.displayName
            General.shared.avatar(userid: social.userId, completion: { (avatarImage) in
                self.imgAvatar.image = avatarImage
            })
        }
        lblTime.text = social.date
        lblContent.attributedText = social.attributedText
        
        setAddressForCell(position: social.position, id: social.pinId, type: social.type)

        imgHotPin.isHidden = social.status != "hot"
        lblFavCount.text = String(social.likeCount)
        btnFav.setImage(social.isLiked ? #imageLiteral(resourceName: "pinDetailLikeHeartFull") : #imageLiteral(resourceName: "pinDetailLikeHeartHollow"), for: .normal)
        lblReplyCount.text = String(social.commentCount)
        
        let count = social.feelingArray.count <= 5 ? social.feelingArray.count : 5;
        for index in 0..<count {
            imgFeelings[index].image = social.feelingArray[index] >= 9 ?
                UIImage(named: "pdFeeling_\(social.feelingArray[index] + 1)-1") :
                UIImage(named: "pdFeeling_0\(social.feelingArray[index] + 1)-1")
        }
        for index in count..<5 {
            imgFeelings[index].image = nil
        }
        
        if MBComtsStoriesCell.strPinType == "media" {
            imgMediaArr.removeAll()
            for subview in scrollViewMedia.subviews {
                subview.removeFromSuperview()
            }
            
            for index in 0..<social.fileIdArray.count {
                let imageView = FaeImageView(frame: CGRect(x: 105 * index, y: 0, width: 95, height: 95))
                imageView.clipsToBounds = true
                imageView.contentMode = .scaleAspectFill
                imageView.layer.cornerRadius = 13.5
                imageView.fileID = social.fileIdArray[index]
                imageView.loadImage(id: social.fileIdArray[index])
                imgMediaArr.append(imageView)
                scrollViewMedia.addSubview(imageView)
            }
            // the tableView can't scroll up/down when finger is touched on the scrollView when height is 95
            // Finally, I set the scrollView's height smaller than the height in storyboard => height: 90 instead of 95
            scrollViewMedia.contentSize = CGSize(width: social.fileIdArray.count * 105 - 10, height: 90)
        }
    }
    
    @objc func actionReplyToThisPin(_ sender: AnyObject) {
        let boolReply = sender.tag != nil
        delegate?.replyToThisPin(indexPath: indexForCurtCell, boolReply: boolReply)
    }
    
    @objc func actionLikeThisPin(_ sender: UIButton) {
        delegate?.likeThisPin(indexPath: indexForCurtCell, strPinId: strPinId)
    }
}
