//
//  Line.swift
//  TestVQ
//
//  Created by Nebul on 20/12/2016.
//  Copyright © 2016 Roger Liu. All rights reserved.
//

import Foundation

class Line {
    var linePoints: [Point] = []
    var lineVector: Vector?
    
    func setVector() {
        if(linePoints.count > 1) {
            if let firstP = linePoints.first, let lastP = linePoints.last{
                lineVector = Vector(x: lastP.x - firstP.x,
                                    y: lastP.y - firstP.y)
            }
        }else {
            lineVector = Vector(x: 0, y: 0)
        }
    }
}
