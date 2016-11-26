//
//  CountingLabel.swift
//  My Dojo
//
//  Created by Andreas Hörberg on 2016-11-10.
//  Copyright © 2016 Andreas Hörberg. All rights reserved.
//

import UIKit
import Foundation

class CountingLabel: UILabel {

    fileprivate var timer: Timer?    
    fileprivate var endValue = -1
    fileprivate var startValue = -1
    fileprivate var timeIntervalInSeconds = 1.5
    fileprivate var currentTime = 0.0
    fileprivate var iterationInterval: Double = 0.0
    fileprivate var intervals: [Double] = []
    
    func calculateNewTimeInterval() -> Double {
        let value = (timeIntervalInSeconds-currentTime) / Double(endValue - startValue)
        print("Time interval: \(timeIntervalInSeconds)")
        print("End value - startValue: \(endValue - startValue)")
        print("Return value: \(value)")
        return value
    }
    
    open var suffix = ""
    open var isAnimating = true
    open var easeOut = true
    open var currentValue = 0
    
    func beginCounting(to endValue: Int) {
        beginCounting(from: 0, to: endValue)
    }
    
    func beginCounting(from fromValue: Int, to toValue: Int) {
        
        currentValue = fromValue
        endValue = toValue
        startValue = fromValue
    
        currentTime = 0.0
        for _ in fromValue...toValue {
            let interval = calculateNewTimeInterval()
            intervals.append(interval)
            print("interval: \(interval)")
            currentTime += calculateNewTimeInterval()
        }
        
        reset()
        startTimer()
    }
    
    fileprivate func startTimer() {
        
        let interval: Double
        if easeOut {
            interval = intervals.popLast()!
        } else {
            interval = intervals.removeFirst()
        }
        timer = Timer.scheduledTimer(timeInterval: interval, target: self, selector: #selector(countUp), userInfo: nil, repeats: false)
    }
    
    fileprivate func stopTimer() {
        timer?.invalidate()
    }
    
    func reset() {        
        timer?.invalidate()
        
        updateText()
    }
    
    internal func countUp() {
        
        if currentValue < endValue {
            currentValue += 1
            
            let interval: Double
            if easeOut {
                interval = intervals.popLast()!
            } else {
                interval = intervals.removeFirst()
            }
            Timer.scheduledTimer(timeInterval: interval, target: self, selector: #selector(countUp), userInfo: nil, repeats: false)
        } else {
            currentValue = endValue
            stopTimer()
        }
        updateText()
    }
    
    fileprivate func updateText() {
        
        if isAnimating {
            
            let animations: (() -> Void)? = { [unowned self] _ in
                self.text = String(self.currentValue)
                if !self.suffix.isEmpty {
                    self.text?.append(self.suffix)
                }
            }
            
            UIView.transition(with: self,
                              duration: iterationInterval,
                              options: [.curveEaseInOut, .transitionCrossDissolve],
                              animations: animations,
                              completion: nil)
        } else {
            text = String(currentValue)
            if !suffix.isEmpty {
                text?.append(suffix)
            }
        }
    }
}
