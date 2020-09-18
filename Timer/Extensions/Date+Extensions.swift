//
//  Date+Extensions.swift
//  Timer
//
//  Created by Artsiom Batura on 9/18/20.
//  Copyright © 2020 Artsiom Batura. All rights reserved.
//

import Foundation

extension Date {
    public static func getStartOfDay(date: Date) -> Date {
        return Calendar.current.startOfDay(for: date).advanced(by: 1)
    }
}
