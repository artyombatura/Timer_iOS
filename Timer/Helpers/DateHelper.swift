//
//  DateHelper.swift
//  Timer
//
//  Created by Artsiom Batura on 9/18/20.
//  Copyright © 2020 Artsiom Batura. All rights reserved.
//

import Foundation

class DateHelper {
    
    public static let sharedInstance: DateHelper = DateHelper()
    
    // MARK: - Methods
    public func getDateFromDayStart(forSecondsCount seconds: Int) -> Date {
        let todaysStart = Date.getStartOfDay(date: Date())
        let dateToDisplay = todaysStart.advanced(by: TimeInterval(seconds))// Calculated date, from todays day start with seconds offset
        
        return dateToDisplay
    }
    
    public func getString(fromDate date: Date, formattingStyle style: String) -> String {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = style
        return dateFormatter.string(from: date)
    }
}
