//
//  PullToRefreshConst.swift
//  PullToRefreshSwift
//
//  Created by Yuji Hato on 12/11/14.
//
import Foundation
import UIKit

extension UIScrollView {
    
    fileprivate func refreshViewWithTag(_ tag: Int) -> PullToRefreshView? {
        let pullToRefreshView = viewWithTag(tag)
        return pullToRefreshView as? PullToRefreshView
    }
    
    func addPullRefresh(options: PullToRefreshOption = PullToRefreshOption(), refreshCompletion: (() -> Void)?) {
        let refreshViewFrame = CGRect(x: 0, y: -PullToRefreshConst.height, width: self.frame.size.width, height: PullToRefreshConst.height)
        let refreshView = PullToRefreshView(options: options, frame: refreshViewFrame, refreshCompletion: refreshCompletion)
        refreshView.tag = PullToRefreshConst.pullTag
        addSubview(refreshView)
    }
    
    func addPushRefresh(options: PullToRefreshOption = PullToRefreshOption(), refreshCompletion: (() -> Void)?) {
        let refreshViewFrame = CGRect(x: 0, y: contentSize.height, width: self.frame.size.width, height: PullToRefreshConst.height)
        let refreshView = PullToRefreshView(options: options, frame: refreshViewFrame, refreshCompletion: refreshCompletion, down: false)
        refreshView.tag = PullToRefreshConst.pushTag
        addSubview(refreshView)
    }
    
    func startPullRefresh() {
        let refreshView = self.refreshViewWithTag(PullToRefreshConst.pullTag)
        refreshView?.state = .refreshing
    }
    
    func stopPullRefreshEver(_ ever: Bool = false) {
        let refreshView = self.refreshViewWithTag(PullToRefreshConst.pullTag)
        if ever {
            refreshView?.state = .finish
        } else {
            refreshView?.state = .stop
        }
    }
    
    func removePullRefresh() {
        let refreshView = self.refreshViewWithTag(PullToRefreshConst.pullTag)
        refreshView?.removeFromSuperview()
    }
    
    func startPushRefresh() {
        let refreshView = self.refreshViewWithTag(PullToRefreshConst.pushTag)
        refreshView?.state = .refreshing
    }
    
    func stopPushRefreshEver(_ ever: Bool = false) {
        let refreshView = self.refreshViewWithTag(PullToRefreshConst.pushTag)
        if ever {
            refreshView?.state = .finish
        } else {
            refreshView?.state = .stop
        }
    }
    
    func removePushRefresh() {
        let refreshView = self.refreshViewWithTag(PullToRefreshConst.pushTag)
        refreshView?.removeFromSuperview()
    }
    
    // If you want to PullToRefreshView fixed top potision, Please call this function in scrollViewDidScroll
    func fixedPullToRefreshViewForDidScroll() {
        let pullToRefreshView = self.refreshViewWithTag(PullToRefreshConst.pullTag)
        if !PullToRefreshConst.fixedTop || pullToRefreshView == nil {
            return
        }
        var frame = pullToRefreshView!.frame
        if self.contentOffset.y < -PullToRefreshConst.height {
            frame.origin.y = self.contentOffset.y
            pullToRefreshView!.frame = frame
        } else {
            frame.origin.y = -PullToRefreshConst.height
            pullToRefreshView!.frame = frame
        }
    }
}
