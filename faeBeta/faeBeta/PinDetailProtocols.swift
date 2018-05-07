//
//  PinDetailProtocols.swift
//  faeBeta
//
//  Created by Yue Shen on 7/28/17.
//  Copyright © 2017 fae. All rights reserved.
//

import Foundation

protocol PinFeelingCellDelegate: class {
    func postFeelingFromFeelingCell(_ feeling: Int)
    func deleteFeelingFromFeelingCell()
}

protocol PinDetailCollectionsDelegate: class {
    // Go back to collections
    func backToCollections(likeCount: String, commentCount: String, pinLikeStatus: Bool, feelingArray: [Int])
}

protocol PinTalkTalkCellDelegate: class {
    func directReplyFromPinCell(_ username: String, index: IndexPath) // Reply to this user
    func showActionSheetFromPinCell(_ username: String, userid: Int, index: IndexPath)
    // Vicky 06/21/17
    func upVoteComment(index: IndexPath)
    func downVoteComment(index: IndexPath)
    //    func cancelCommentVote(index: IndexPath)
    //    func updateCommentVoteCount(index: IndexPath)
    // Vicky 06/21/17
}
