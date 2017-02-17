//
//  Polygon.swift
//  TestVQ
//
//  Created by Nebul on 11/11/2016.
//  Copyright © 2016 Roger Liu. All rights reserved.
//

import Foundation

class Polygon {
//    let segNum = 30
    var vertices = [Point]()
    let cx: Double
    let cy: Double
    
    init(fromString vertices: String){
        let points = vertices.components(separatedBy: ", ")
        
        for p in points {
            let coordinates = p.components(separatedBy: " ")
            let x = Double(coordinates[0])
            let y = Double(coordinates[1])
            self.vertices.append(Point(newX: x!, newY: y!))
        }
        self.cx = 0.0
        self.cy = 0.0
        
    }
    
    init(fromString vertices: String, centerX: Double, centerY: Double){
        let points = vertices.components(separatedBy: ", ")
        
        for p in points {
            let coordinates = p.components(separatedBy: " ")
            let x = Double(coordinates[0])
            let y = Double(coordinates[1])
            self.vertices.append(Point(newX: x!, newY: y!))
        }
        self.cx = centerX
        self.cy = centerY
        
        
    }


}
