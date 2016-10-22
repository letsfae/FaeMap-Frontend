//
//  CommentPinViewController.swift
//  faeBeta
//
//  Created by Yue on 10/15/16.
//  Copyright © 2016 fae. All rights reserved.
//

import UIKit

class CommentPinViewController: UIViewController {

    // New Comment Pin Popup Window
    
    var numberOfCommentTableCells: Int = 0
    var dictCommentsOnCommentDetail = [[String: AnyObject]]()
    var animatingHeart: UIImageView!
    var boolCommentPinLiked = false
    var buttonBackToCommentPinDetail: UIButton!
    var buttonBackToCommentPinLists: UIButton!
    var buttonCommentDetailViewActive: UIButton!
    var buttonCommentDetailViewComments: UIButton!
    var buttonCommentDetailViewPeople: UIButton!
    var buttonCommentPinAddComment: UIButton!
    var buttonCommentPinBackToMap: UIButton!
    var buttonCommentPinDetailDragToLargeSize: UIButton!
    var buttonCommentPinDownVote: UIButton!
    var buttonCommentPinLike: UIButton!
    var buttonCommentPinListClear: UIButton!
    var buttonCommentPinListDragToLargeSize: UIButton!
    var buttonCommentPinUpVote: UIButton!
    var buttonMoreOnCommentCellExpanded = false
    var buttonOptionOfCommentPin: UIButton!
    var commentDetailFullBoardScrollView: UIScrollView!
    var commentIDCommentPinDetailView: String = "-999"
    var commentListExpand = false
    var commentListScrollView: UIScrollView!
    var commentListShowed = false
    var commentPinCellArray = [CommentPinListCell]()
    var commentPinDetailLiked = false
    var commentPinDetailShowed = false
    var imageCommentPinUserAvatar: UIImageView!
    var imageViewSaved: UIImageView!
    var labelCommentPinCommentsCount: UILabel!
    var labelCommentPinLikeCount: UILabel!
    var labelCommentPinListTitle: UILabel!
    var labelCommentPinTimestamp: UILabel!
    var labelCommentPinTitle: UILabel!
    var labelCommentPinUserName: UILabel!
    var labelCommentPinVoteCount: UILabel!
    var moreButtonDetailSubview: UIImageView!
    var tableCommentsForComment: UITableView!
    var textviewCommentPinDetail: UITextView!
    var uiviewCommentDetailThreeButtons: UIView!
    var uiviewCommentPinDetail: UIView!
    var uiviewCommentPinDetailGrayBlock: UIView!
    var uiviewCommentPinDetailMainButtons: UIView!
    var uiviewCommentPinListBlank: UIView!
    var uiviewCommentPinListUnderLine01: UIView!
    var uiviewCommentPinListUnderLine02: UIView!
    var uiviewCommentPinUnderLine01: UIView!
    var uiviewCommentPinUnderLine02: UIView!
    var uiviewGrayBaseLine: UIView!
    var uiviewRedSlidingLine: UIView!
    
    // For Dragging
    var buttonCenter = CGPointZero
    var commentPinSizeFrom: CGFloat = 0
    var commentPinSizeTo: CGFloat = 0
    
    // Like Function
    var commentPinLikeCount: Int = 0
    //    {
    //        //我们需要在age属性变化前做点什么
    //        willSet {
    ////            print("New Value is \(newValue)")
    //            if isUpVoting && commentPinDetailLiked == false {
    //                commentPinDetailLiked = true
    //                labelCommentPinVoteCount.text = "\(newValue+1)"
    //                labelCommentPinLikeCount.text = "\(newValue+1)"
    //            }
    //            else if isDownVoting && commentPinDetailLiked {
    //                commentPinDetailLiked = false
    //                labelCommentPinVoteCount.text = "\(newValue-1)"
    //                labelCommentPinLikeCount.text = "\(newValue-1)"
    //            }
    //        }
    //        //我们需要在age属性发生变化后，更新一下nickName这个属性
    //        didSet {
    ////            print("Old Value is \(oldValue)")
    //        }
    //    }
    
    var isUpVoting = false
    var isDownVoting = false
    
    // Fake Transparent View For Closing
    var buttonFakeTransparentClosingView: UIButton!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
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
