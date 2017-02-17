//
//  densityResult.swift
//  TestVQ
//
//  Created by Nebul on 25/11/2016.
//  Copyright © 2016 Roger Liu. All rights reserved.
//

import Foundation

class DensityResult {
    let originPoint: Point
    let densityRange: Double
    let densityMin: Double
    
    init(originPoint: Point, densityMin: Double, densityRange: Double) {
        self.originPoint = originPoint
        self.densityRange = densityRange
        self.densityMin = densityMin
    }
    
}
