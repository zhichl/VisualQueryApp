//
//  DensityData.swift
//  TestVQ
//
//  Created by Nebul on 19/11/2016.
//  Copyright © 2016 Roger Liu. All rights reserved.
//

import Foundation
import UIKit

class DensityData {
    
    let width = 1106
    let height = 487
    let sketchWidth = 10
    let sketchHeight = 10
    var overallHeatMap = [Double]()
    let dataPath = Bundle.main.path(forResource: "densityField", ofType: "txt")
    var results = [DensityResult]()
    var resultsCount = 0
    var minDiffResult: Point?
    
    let resultWindowWidth = 10
    let resultWindowHeight = 10
    var resultHeatMaps = [WindowHeatMap]()
    let resultHeatMapSize = CGSize(width: 100, height: 100)
    var resultTiles: [CGRect]
    let rectSize = CGSize(width: 10, height: 10)
    
    // 0: density search  1: direction search
    var sketchType = 0
    
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
        self.resultTiles = [CGRect](repeating:CGRect(x: 0, y: 0, width: 0, height: 0),
                                    count: resultWindowWidth * resultWindowHeight)
        for x in 0..<resultWindowWidth {
            for y in 0..<resultWindowHeight{
                
                let orginPoint = CGPoint(x: CGFloat(x)*self.rectSize.width, y: CGFloat(y)*self.rectSize.height)
                self.resultTiles[x*resultWindowWidth+y] = CGRect(origin: orginPoint, size: rectSize)
            }
        }
        
        vectorField = [Vector](repeating: Vector(x:0, y:0), count: sketchWidth * sketchHeight)
        vField0 = [Vector](repeating: Vector(x:0, y:0), count: sketchWidth * sketchHeight)
        lines.append(Line())
        
        self.initOverallHeatMap(path: dataPath)
        

    }
    
    func initOverallHeatMap(path: String?) {
        //        self.overallHeatMap = [Double](repeating: 0, count: self.width * self.height)
        
        do {
            let data = try String(contentsOfFile: path!, encoding: String.Encoding.utf8)
            let stringTiles = data.components(separatedBy: ",")
            for tile in stringTiles {
                let number: Double? = Double(tile)
                self.overallHeatMap.append(number!)
            }
            print("max count in heat map tiles: \(self.overallHeatMap.max())")
        }
        catch {
            print(error)
        }
        
    }
    
    func clearSketch() {
        vectorField = [Vector](repeating: Vector(x:0, y:0), count: sketchWidth * sketchHeight)
        vField0 = [Vector](repeating: Vector(x:0, y:0), count: sketchWidth * sketchHeight)
        lines.removeAll()
        lines.append(Line())
    }
    
    func sketchTypeToggole() {
        self.sketchType = 1 - self.sketchType
    }
    
    /*****************************************************************************************/
    /************************************ density search *************************************/
    /*****************************************************************************************/
    
    func densitySearch(withSketch sketchTiles: [Double]) {
        self.resultsCount = 0
        self.results.removeAll()
        self.minDiffResult = nil
        let threshold = 15.0
        var sketchMax = 0.0
        var sketchMin = Double.infinity
        //        var SketchResultList = [Point]()
        //		get the max and min density of sketch tiles
        for x in 0..<sketchWidth {
            for y in 0..<sketchHeight {
                let index = x * sketchWidth + y
                if (sketchMax < sketchTiles[index]) {
                    sketchMax = sketchTiles[index]
                }
                if (sketchMin > sketchTiles[index]) {
                    sketchMin = sketchTiles[index]
                }
            }
        }
        sketchMax += 1
        let sketchRange = sketchMax - sketchMin
        
        var count = 0
        var minDiff = Double.infinity
        for x in 0..<width - sketchWidth {
            for y in 0..<height - sketchHeight {
                // get the max and min density in every 10*10 window
                var max = 0.0
                var min = Double.infinity
                for i in 0..<sketchWidth {
                    for j in 0..<sketchHeight {
                        let index = (x + i) * height + (y + j)
                        if (max < self.overallHeatMap[index]) {
                            max = self.overallHeatMap[index]
                        }
                        if (min > self.overallHeatMap[index]) {
                            min = self.overallHeatMap[index]
                        }
                    }
                }
                max += 1
                let range = max - min
                var diff = 0.0
                for i in 0..<sketchWidth {
                    for j in 0..<sketchHeight {
                        
                        let index = (x + i) * height + (y + j);
                        let index2 = i * sketchHeight + j
                        diff += abs(1.0 * (self.overallHeatMap[index] - min)
                            / range - (sketchTiles[index2] - sketchMin)
                            / sketchRange)
                    }
                }
                
                if (diff < threshold) {
                    if (diff < minDiff) {
                        minDiff = diff
                        self.minDiffResult = Point(newX: Double(x), newY: Double(y))
                    }
                    let origin = Point(newX: Double(x), newY: Double(y))
                    self.results.append(DensityResult(originPoint: origin, densityMin: min, densityRange: range))
                    count += 1
                }
            }
        }
        print("\(count) results found")
        self.resultsCount = count
        generateResultHeatMaps(results: self.results)
    }
    
    func generateResultHeatMaps(results: [DensityResult]) {
        if self.resultsCount == 0 {
            print("no heat map to generate")
            return
        } else {
            print("heat maps are being generated...")
            self.resultHeatMaps.removeAll()
            for result in results {
                let image = getWindowHeatMapImage(fromDensityResult: result)
                let heatMap = WindowHeatMap(image)
                self.resultHeatMaps.append(heatMap)
            }
            print("result heat maps count: \(self.resultHeatMaps.count)")
        }
    }
    
    func getWindowHeatMapImage (fromDensityResult result: DensityResult) -> UIImage {
        var resultFills = [Double](repeating: 1.0, count: resultWindowWidth * resultWindowHeight)
        
        let originX = Int(result.originPoint.x)
        let originY = Int(result.originPoint.y)
//        let min = result.densityMin
//        let range = result.densityRange
        
        for x in 0..<resultWindowWidth {
            for y in 0..<resultWindowHeight {
                let index = (originX + x) * height + (originY + y)
                resultFills[x*resultWindowHeight+y] = 1.0 - (self.overallHeatMap[index])/36.0
//                resultFills[x*resultWindowHeight+y] = 1.0 - (self.overallHeatMap[index]-min)/range
//                print("\(self.overallHeatMap[index]/37.0)")
            }
        }
        
        var color: UIColor
        UIGraphicsBeginImageContext(resultHeatMapSize)
        let context = UIGraphicsGetCurrentContext()
        context?.saveGState()
        for x in 0..<resultWindowWidth {
            for y in 0..<resultWindowHeight {
                color = UIColor(white: CGFloat(resultFills[x*resultWindowWidth+y]), alpha: 1)
                color.setFill()
                UIRectFill(resultTiles[x*resultWindowWidth+y])
            }
        }
        let heatMapImg = UIGraphicsGetImageFromCurrentImageContext()
        context?.restoreGState()
        UIGraphicsEndImageContext()
        
        return heatMapImg!
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
