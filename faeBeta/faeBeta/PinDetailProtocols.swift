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

protocol PinDetailDelegate: class {
    // Cancel marker's shadow when back to Fae Map
    // true  -> just means user want to back to main screen
    // false -> delete this pin from map
    func backToMainMap()
    // Pass location data to fae map view
    func animateToCamera(_ coordinate: CLLocationCoordinate2D)
    // Change marker icon based on status
    func changeIconImage()
    // Reload map pins because of location changed
    func reloadMapPins(_ coordinate: CLLocationCoordinate2D, pinID: String, annotation: FaePinAnnotation)
    // Go to prev or next pin
    func goTo(nextPin: Bool)
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
