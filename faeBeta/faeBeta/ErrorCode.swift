//
//  ErrorCode.swift
//  faeBeta
//
//  Created by Yue Shen on 4/3/18.
//  Copyright © 2018 fae. All rights reserved.
//

import UIKit

// MARK: - Error Code

enum ErrorType {
    case auth, map, collection, contact, chat, file
}

func handleErrorCode(_ type: ErrorType, _ code: String, _ completion: ((String) -> Void)? = nil, _ subType: String = "") {
    switch type {
    case .auth: //jichao
        break
    case .map: //joshua
        switch code {
        case "400-5":
            completion?("Not on mobile phone") // 当前客户端非手机，无法使用定位模块
        case "404-6":
            completion?("") // Session不存在
        case "400-7":
            completion?("") // 输入type错误
        case "404-11":
            completion?("") // POST or UPDATE Locations file_ids if cannot match a file_id -> File不存在
        case "404-16":
            completion?("") // Location(PIN)不存在
        case "400-3":
            completion?("") // 输入ID非数字
        case "403-2":
            completion?("") // 用户不是PIN创建人，无权操作修改
        case "404-3":
            completion?("") // User不存在
        default:
            completion?("Fail to do")
        }
    case .collection: //vicky
        switch code {
        case "404-13":   // 创建/删除memo时 -> PIN不存在
            break
        case "403-7":    // 更新/删除/获取collection时,收藏pin到collection时,从collection删除pin时 -> 用户不是collection创建者，无权操作修改
            break
        case "400-7":    // 收藏pin到collection时,从collection删除pin时 -> 输入type错误
            break    
        default:
            break
        }
        break
    case .contact: //vicky
        switch code {
        case "404-3":   // 发起好友请求/删除好友/获取request和request_sent列表/获取friends和block列表时 -> 用户不存在
            completion?("User doesn't exist.")
        case "400-23":    // 向自己发送好友请求时 -> 不允许给自己发送好友请求
            completion?("Cannot send request \nto yourself")
        case "400-20":    // 发起好友请求时 -> 已发送过好友请求(not resend)
            completion?("You've already \nsent friend request!")
        case "400-21":    // 发起好友请求时 -> 已经是好友了
            completion?("You've already \nbeen friends!")
        case "400-22":    // 发起好友请求时 -> 已经是好友了   // 提issue，当出现这种情况时，应直接使二者成为好友
            completion?("You've already \nbeen friends!")
        case "400-6":    // 发起/接受好友请求时 -> 已屏蔽 （谁屏蔽谁？）
            completion?("Cannot send \nrequest.[block]")
        case "404-12":    // 接受/忽略/撤销好友请求时 -> 好友请求不存在
            completion?("Friend request \ndoesn't exist.")
        case "403-6":    // 撤销好友请求时 -> 不是好友请求发起者，无权撤销
            completion?("You're not authorized \nto withdraw")
        case "400-16":    // block好友时 -> 不允许拉黑自己
            completion?("You cannot \nblock yourself")
        default:
            completion?("Fail to do")
        }
    case .chat: //jichao
        break
    case .file: //joshua
        switch code {
        case "404-11":
            completion?("File does not exist")
        case "404-18":
            completion?("Image does not exist")
        case "400-3":
            completion?("input id is not a number")
        default:
            completion?("Fail to do")
        }
    }
}
