//
//  DirectionData.swift
//  TestVQ
//
//  Created by Nebul on 23/12/2016.
//  Copyright © 2016 Roger Liu. All rights reserved.
//

import Foundation
import UIKit

class DirectionData {
    
    let sketchWidth = 10
    let sketchHeight = 10
    
    var lines: [Line] = []
    var lineNum = 0
    var vectorField: [Vector]
    var vField0: [Vector]
    let vCoefs = [0.0, 0.2, 0.4, 0.2, 0.0,
                  0.2, 0.6, 0.8, 0.6, 0.2,
                  0.4, 0.8, 1.0, 0.8, 0.4,
                  0.2, 0.6, 0.8, 0.6, 0.2,
                  0.0, 0.2, 0.4, 0.2, 0.0]
    
    init() {
        vectorField = [Vector](repeating: Vector(x:0, y:0), count: sketchWidth * sketchHeight)
        vField0 = [Vector](repeating: Vector(x:0, y:0), count: sketchWidth * sketchHeight)
        lines.append(Line())
    }
    
    func clearSketch() {
        vectorField = [Vector](repeating: Vector(x:0, y:0), count: sketchWidth * sketchHeight)
        vField0 = [Vector](repeating: Vector(x:0, y:0), count: sketchWidth * sketchHeight)
        lines.removeAll()
        lines.append(Line())
    }
    
    /*****************************************************************************************/
    /*********************************** direction search ************************************/
    /*****************************************************************************************/
    
    func updateVector() {
        // init a vector field
        let size = 10
        let range = 2
        let rangeSize = 2 * range + 1
        let rectSize = 30
        
        for i in 0..<size {
            for j in 0..<size {
                vField0[j * size + i] = Vector(x:0, y:0)
                for k in 0..<lines.count {
                    let linePoints = lines[k].linePoints
                    Loop: for l in 0..<linePoints.count {
                        let p = linePoints[l]
                        if (p.x >= Double(j * rectSize) && p.x <= Double((j + 1) * rectSize)
                            && p.y >= Double(i * rectSize)
                            && p.y <= Double((i + 1) * rectSize)) {
                            vField0[j * size + i].add(x: (lines[k].lineVector?.x)!, y: (lines[k].lineVector?.y)!)
                            break Loop
                        }
                    }
                }
            }
        }
        
        for i in 0..<size {
            for j in 0..<size {
                let index = j * size + i
                let norm = sqrt(vField0[index].x * vField0[index].x
                    + vField0[index].y * vField0[index].y)
                if (norm != 0) {
                    let newX = vField0[index].x / norm
                    let newY = vField0[index].y / norm
                    vField0[index] = Vector(x: newX, y: newY)
                    
                }
            }
        }
        
        // interpolate vector field
        for i in 0..<size {
            for j in 0..<size {
                let index = j * size + i
                vectorField[index] = Vector(x: 0, y: 0)
                for a in -range...range {
                    if (i + a >= 0 && i + a < size) {
                        for b in -range...range {
                            if (j + b >= 0 && j + b < size) {
                                let index2 = (i + a) * size + j + b
                                let coef = vCoefs[(a + range) * rangeSize
                                    + (b + range)]
                                vectorField[index].add(x: coef * vField0[index2].x,
                                                       y: coef * vField0[index2].y)
                            }
                        }
                    }
                }
            }
        }
        for i in 0..<size {
            for j in 0..<size {
                let index = j * size + i
                let norm = sqrt(vectorField[index].x
                    * vectorField[index].x
                    + vectorField[index].y
                    * vectorField[index].y)
                if (norm != 0) {
                    let newX = vectorField[index].x / norm
                    let newY = vectorField[index].y / norm
                    vectorField[index] = Vector(x: newX, y: newY)
                }
            }
        }
        
    }
    
}
