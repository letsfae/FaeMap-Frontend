//
//  GCDControl.swift
//  faeBeta
//
//  Created by Yue Shen on 7/23/17.
//  Copyright © 2017 fae. All rights reserved.
//

import Foundation

typealias Task = (_ cancel: Bool) -> ()

func delay(time: Double, task: @escaping () -> ()) -> Task? {
    
    func dispatch_later(block: @escaping () -> ()) {
        DispatchQueue.main.asyncAfter(deadline: .now() + time, execute: block)
    }
    
    var closure: (() -> ())? = task
    var result: Task?
    
    let delayedClosure: Task = { cancel in
        if let internalClosure = closure {
            if cancel == false {
                DispatchQueue.main.async(execute: internalClosure)
            }
        }
        closure = nil
        result = nil
    }
    
    result = delayedClosure
    
    dispatch_later {
        if let delayedClosure = result {
            delayedClosure(false)
        }
    }
    
    return result
}

func cancel(task: Task?) {
    task?(true)
}
