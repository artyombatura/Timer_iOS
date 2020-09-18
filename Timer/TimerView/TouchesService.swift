//
//  TouchesService.swift
//  Timer
//
//  Created by Artsiom Batura on 9/17/20.
//  Copyright © 2020 Artsiom Batura. All rights reserved.
//

import Foundation
import UIKit

class TouchesService {
    enum MoveDirection {
        case up
        case down
    }
    
    private var previousPoint: CGPoint!
    private var currentPoint: CGPoint!
    
    // MARK: - Public computed properties
    public var yOffset: CGFloat {
        guard previousPoint != nil else { return 0.0 }
        
        return currentPoint.y - previousPoint.y
    }
    public var moveDirection: MoveDirection {
        return yOffset <= 0 ? .up : .down
    }
    
    // MARK: - Public methods
    public func writePoint(point: CGPoint) {
        if previousPoint == nil {
            previousPoint = point
        } else {
            previousPoint = currentPoint
            currentPoint = point
        }
    }
}
