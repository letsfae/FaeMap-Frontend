//
//  Throttler.swift
//  faeBeta
//
//  Created by Yue Shen on 6/16/18.
//  Copyright © 2018 fae. All rights reserved.
//

import Foundation

class Throttler {
    
    private let queue: DispatchQueue = DispatchQueue.global(qos: .userInteractive)
    
    private var job: DispatchWorkItem = DispatchWorkItem(block: {})
    private var previousRun: Date = Date.distantPast
    private var maxInterval: Double
    private var throttlerName: String
    
    init(name: String, seconds: Double) {
        self.throttlerName = name
        self.maxInterval = seconds
    }
    
    func throttle(block: @escaping () -> ()) {
        job.cancel()
        job = DispatchWorkItem(){ [weak self] in
            self?.previousRun = Date()
            block()
        }
        let delay = Date.second(from: previousRun) > maxInterval ? 0.5 : maxInterval
        queue.asyncAfter(deadline: .now() + Double(delay), execute: job)
        // joshprint(throttlerName + ": \(Date.second(from: previousRun))")
    }
    
    func cancelCurrentJob() {
        job.cancel()
    }
}

private extension Date {
    static func second(from referenceDate: Date) -> Double {
        return Double(Date().timeIntervalSince(referenceDate).rounded())
    }
}
