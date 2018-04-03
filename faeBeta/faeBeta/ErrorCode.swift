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

func errorCode(_ type: ErrorType, _ code: String, _ completion: (() -> Void)? = nil) {
    switch type {
    case .auth: //jichao
        break
    case .map: //joshua
        break
    case .collection: //vicky
        break
    case .contact: //jichao
        break
    case .chat: //jichao
        break
    case .file: //joshua
        break
    }
}
