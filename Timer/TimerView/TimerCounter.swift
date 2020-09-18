//
//  TimerCounter.swift
//  Timer
//
//  Created by Artsiom Batura on 9/17/20.
//  Copyright © 2020 Artsiom Batura. All rights reserved.
//

import Foundation

class TimerService {
    // MARK: - Constants
    public let timerInterval: Int = 1
    public let maxTime: Int = 86400
    
    // Counting time in seconds
    private var timeTotal: Int = 0
    private var timePassed: Int = 0
    
    // MARK: - Public
    public var timeRemaining: Int {
        guard timeTotal > 0, timePassed >= 0 else { return 0 }
        return timeTotal - timePassed
    }
    
    // timeTotal
    public func getTimeTotal() -> Int {
        return timeTotal
    }
    
    public func setTimeTotal(time: Int) {
        timeTotal = time
    }
    //
    
    // timePassed
    public func incrementTimePassed() {
        timePassed += timerInterval
    }
    
    public func incrementTimePassed(byTime time: Int) {
        let newTime = timePassed + time
        
        if newTime <= 0 {
            timePassed = 0
            return
        } else if newTime >= timeTotal {
            timePassed = timeTotal
            return
        }
        
        timePassed += time
    }
    
    public func getTimePassed() -> Int {
        return timePassed
    }
    //
}
