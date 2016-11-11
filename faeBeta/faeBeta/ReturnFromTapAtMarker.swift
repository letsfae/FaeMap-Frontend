//
//  ReturnFromTapAtMarker.swift
//  faeBeta
//
//  Created by Yue on 10/28/16.
//  Copyright © 2016 fae. All rights reserved.
//

import UIKit
import GoogleMaps

//MARK: Show right slide window
extension FaeMapViewController: CommentPinViewControllerDelegate {
    func dismissMarkerShadow(dismiss: Bool) {
        print("back from comment pin detail")
        if dismiss {
            self.markerBackFromCommentDetail.icon = UIImage(named: "comment_pin_marker")
            self.markerBackFromCommentDetail.zIndex = 0
        }
        else {
            self.markerBackFromCommentDetail.map = nil
        }
    }
}
