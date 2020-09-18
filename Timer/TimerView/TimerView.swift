//
//  TimerView.swift
//  Timer
//
//  Created by Artsiom Batura on 9/17/20.
//  Copyright © 2020 Artsiom Batura. All rights reserved.
//

import UIKit
import SnapKit

class TimerView: UIView {
    
    // MARK: - Constants
    private let circleLineWidth: CGFloat = 30.0
    private var circleOffsetFromBounds: CGFloat {
        return self.frame.height * 0.05
    }
    private let userDefaultsKeyForSettedTimerTime: String = "TimerSettedTime"
    private let userDefaultsKeyForPassedTimerTime: String = "TimerPassedTime"
    
    // MARK: - Properties
    private var timer: Timer!
    private var timerService: TimerService = TimerService()
    private var touchesService: TouchesService = TouchesService()
    
    public var timerActiveColor: UIColor = .red
    public var timerBacksideColor: UIColor = .cyan
    
    // MARK: - Callbacks

    // MARK: - Subviews
    private var timeLabel: UILabel!
    private var mainButton: UIButton!

    // MARK: - INIT
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        self.backgroundColor = .clear
        
        // Subviews setting
        setTimerLabel()
        setStartButton()
        
        // Services setting
        initTimerService()
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        
        self.backgroundColor = .clear
        
        // Subviews setting
        setTimerLabel()
        setStartButton()
        
        // Services setting
        initTimerService()
    }
    
    // MARK: - Lifecycle
    
    // MARK: - Draw
    override func draw(_ rect: CGRect) {
        guard let context = UIGraphicsGetCurrentContext()
            else { return }
        
        drawBacksideArc(context: context)
        drawNeededArc(context: context)
    }
}

// MARK: - Public methods
extension TimerView {

}

// MARK: - Private #INIT# methods; Get needed state for timer: @running or configuring@
extension TimerView {
    private func initTimerService() {
        var isTimerRunning: Bool = false
        
        //
        // Define if timer is already running
        // Get totalTime, passedTimed from UserDefaults
        //
        var timerSettedTime: Int = 0
        var timerPassedTime: Int = 0
        let userDefaults = UserDefaults.standard
        if let timerSettedTimeLocal = userDefaults.value(forKey: userDefaultsKeyForSettedTimerTime) as? Int,
            let timerPassedTimeLocal = userDefaults.value(forKey: userDefaultsKeyForPassedTimerTime) as? Int {
            
            timerSettedTime = timerSettedTimeLocal
            timerPassedTime = timerPassedTimeLocal
            
            isTimerRunning = true
            timerService.isRunning = true
        }
        
        if isTimerRunning {
            // Set total time to timer
            // Set passed time to timer
            // => RUN
            timerService.setTimeTotal(time: timerSettedTime)
            timerService.incrementTimePassed(byTime: timerPassedTime)
            
            startTimer()
        } else {
            // Timer in configuring state
            timerService.setTimeTotal(time: timerService.maxTime)
        }
        
        let title: String = timerService.isRunning ? "CANCEL" : "START"
        mainButton.setTitle(title, for: .normal)
    }
}

// MARK: - Private #Draw# methods
extension TimerView {
    private func drawNeededArc(context: CGContext) {
        let angleToFill = calculateArcFillPercent(passedTime: timerService.getTimePassed(), totalTime: timerService.getTimeTotal())
        
        context.setStrokeColor(timerActiveColor.cgColor)
        context.setLineWidth(circleLineWidth)
        context.setLineCap(.round)
        
        let center: CGPoint = CGPoint(x: self.frame.width / 2, y: self.frame.height / 2)
        let radius: CGFloat = self.frame.width / 2
        
        context.addArc(center: center, radius: radius - circleOffsetFromBounds, startAngle: 3 * .pi / 2, endAngle: (3 * .pi / 2) - angleToFill, clockwise: true)
        
        context.drawPath(using: .stroke)
    }
    
    private func drawBacksideArc(context: CGContext) {
        context.setStrokeColor(timerBacksideColor.withAlphaComponent(1.0).cgColor)
        context.setLineWidth(circleLineWidth)
        context.setLineCap(.round)
        
        let center: CGPoint = CGPoint(x: self.frame.width / 2, y: self.frame.height / 2)
        let radius: CGFloat = self.frame.width / 2
        
        context.addArc(center: center, radius: radius - circleOffsetFromBounds, startAngle: 0, endAngle:  .pi * 2, clockwise: true)
        
        context.drawPath(using: .stroke)
    }
    
    private func calculateArcFillPercent(passedTime: Int, totalTime: Int) -> CGFloat {
        let fillPercent: CGFloat = CGFloat(passedTime) / CGFloat(totalTime)
        let arcFillAngle: CGFloat = 2.0 * .pi * fillPercent
        return arcFillAngle
    }
}

// MARK: - Private #Timer# methods
extension TimerView {
    private func startTimer() {
        timer = Timer.scheduledTimer(withTimeInterval: TimeInterval(timerService.timerInterval), repeats: true, block: { (timer) in
            let incrementedPassedTime = self.timerService.getTimePassed() + self.timerService.timerInterval
            let totalTime = self.timerService.getTimeTotal()
            if incrementedPassedTime >= totalTime {
                self.resetTimerPlan()
                return
            }
            
            self.timerService.incrementTimePassed()
            self.setNeedsDisplay()
            self.setNeedsDisplayTimeReversed()
            
            let userDefaults = UserDefaults.standard
            userDefaults.set(self.timerService.getTimePassed(), forKey: self.userDefaultsKeyForPassedTimerTime)
        })
    }
}

// MARK: - Touches handling
extension TimerView {
    // MARK: - UIResponder methods
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        if timerService.isRunning {
            return
        }
        
        guard let touch = touches.first else { return }
        let location = touch.location(in: self)
        
        touchesService.writePoint(point: location)
    }
    
    override func touchesMoved(_ touches: Set<UITouch>, with event: UIEvent?) {
        if timerService.isRunning {
            return
        }
        
        guard let touch = touches.first else { return }
        let location = touch.location(in: self)
        
        touchesService.writePoint(point: location)
        
        // Calculating offset(CGFloat) to timeOffset on timer. How much offset equals in time
        let selfHeight: CGFloat = self.frame.height
        let timeOffset: CGFloat = CGFloat(timerService.maxTime) * abs(touchesService.yOffset) / selfHeight
        let increment: Int = touchesService.moveDirection == TouchesService.MoveDirection.down ? Int(timeOffset) : Int(-timeOffset)
        timerService.incrementTimePassed(byTime: increment)
        
        // Update drawing
        setNeedsDisplay()
        
        // Update time label display
        setNeedsDisplayTime()
    }
}

// MARK: - Subviews
extension TimerView {
    // MARK: - TimerLabel
    private func setTimerLabel() {
        timeLabel = UILabel(frame: .zero)
        timeLabel.textAlignment = .center
        timeLabel.textColor = .white
        timeLabel.font = UIFont.systemFont(ofSize: 40.0, weight: .heavy)
        timeLabel.text = ""
        addSubview(timeLabel)
        timeLabel.snp.makeConstraints {
            $0.leading.trailing.equalToSuperview().inset(circleOffsetFromBounds)
            $0.bottom.equalTo(self.snp.centerY).offset(4.0)
            $0.top.greaterThanOrEqualToSuperview().inset(10.0)
            $0.height.equalTo(self.frame.height * 0.2)
        }
        setNeedsDisplayTime()
    }
    
    // Displaying time from start of day. Example: 59 seconds will Display: "00:00:59"
    private func setNeedsDisplayTime() {
        let dateToDisplay = DateHelper.sharedInstance.getDateFromDayStart(forSecondsCount: timerService.getTimePassed())
        let stringFromDate = DateHelper.sharedInstance.getString(fromDate: dateToDisplay, formattingStyle: "HH:mm:ss")
        timeLabel.text = stringFromDate
    }
    
    // Displaying remaining time till the end. Example: 59 seconds till the timer end will Display: "00:00:59", same displaying, but it is @REMAINING@ Time, not actual!!!
    private func setNeedsDisplayTimeReversed() {
        let dateToDisplay = DateHelper.sharedInstance.getDateFromDayStart(forSecondsCount: timerService.timeRemaining)
        let stringFromDate = DateHelper.sharedInstance.getString(fromDate: dateToDisplay, formattingStyle: "HH:mm:ss")
        timeLabel.text = stringFromDate
    }
    
    // MARK: - StartButton
    private func setStartButton() {
        mainButton = UIButton(frame: .zero)
        mainButton.isUserInteractionEnabled = true
        mainButton.addTarget(self, action: #selector(mainButtonAction), for: .touchUpInside)
        addSubview(mainButton)
        mainButton.snp.makeConstraints {
            $0.leading.trailing.equalToSuperview().inset(circleOffsetFromBounds)
            $0.top.equalTo(self.snp.centerY).offset(4.0)
            $0.height.equalTo(self.frame.height * 0.2)
        }
    }
    
    @objc
    private func mainButtonAction() {
        if timerService.isRunning {
            resetTimerPlan()
        } else {
            startTimerPlan()
        }
    }
    
    public func startTimerPlan() {
        let userDefaults = UserDefaults.standard
        // Setting selected time in circle
        userDefaults.set(timerService.getTimePassed(), forKey: self.userDefaultsKeyForSettedTimerTime)
        
        timerService = TimerService()
        
        // Setting passed time to 0
        userDefaults.set(timerService.getTimePassed(), forKey: self.userDefaultsKeyForPassedTimerTime)
        
        // Reinitialize self state
        initTimerService()
    }
    
    public func resetTimerPlan() {
        let userDefaults = UserDefaults.standard
        
        userDefaults.removeObject(forKey: userDefaultsKeyForSettedTimerTime)
        userDefaults.removeObject(forKey: userDefaultsKeyForPassedTimerTime)
        
        timerService = TimerService()
        timerService.isRunning = false
        timer.invalidate()
        timer = nil
        
        initTimerService()
        
        setNeedsDisplay()
        setNeedsDisplayTime()
    }
}
