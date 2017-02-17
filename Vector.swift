//
//  Vector.swift
//  TestVQ
//
//  Created by Nebul on 19/12/2016.
//  Copyright © 2016 Roger Liu. All rights reserved.
//

import Foundation

class Vector {
    var x: Double = 0
    var y: Double = 0
    
    init(x: Double, y: Double) {
        self.x = x
        self.y = y
    }
    
    func add(x: Double, y: Double) {
        self.x += x
        self.y += y
    }
    
    static func angle(v1: Vector, v2: Vector) -> Double {
        let l1 = sqrt(v1.x * v1.x + v1.y * v1.y)
        let l2 = sqrt(v2.x * v2.x + v2.y * v2.y)
        let cos = (v1.x * v2.x + v1.y * v2.y) / l1 / l2
        let angle = acos(cos)
        if (cos >= 1) {
            return 0
        }
        let sin = v1.x * v2.y - v1.y * v2.x
        if (sin > 0) {
            return angle
        } else {
            return -angle
        }
    }
    
    
    
}
