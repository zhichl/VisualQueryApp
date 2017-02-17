//
//  ViewController.swift
//  TestVQ
//
//  Created by Nebul on 24/10/2016.
//  Copyright © 2016 Roger Liu. All rights reserved.
//

import UIKit

class ViewController: UIViewController, UITableViewDataSource, UITableViewDelegate {
    
    //    let sketchHeatMapSize = CGSize(width: 10, height: 10)
    let sketchWidth = 10;
    let sketchHeight = 10;
    let rectSize = CGSize(width: 30, height: 30)
    
    var sketchFills: [Double]
    var sketchTiles: [Double]
    // rectTiles: skectch heap map
    //    var rectTiles: [[CGRect]]
    var rectTiles: [CGRect]
    //    var rectTiles = [[CGRect]](repeating:[CGRect](repeating:CGRect(x: 0, y: 0, width: 0, height: 0), count: 10), count: 10);)
    
    var rgbNo = 1.0
    let baseDiff = -2.0/255.0
    let rgbDiffs: [[Double]]
    let diff2 = Int(5.5/5)
    
    var lastPoint = CGPoint.zero
    var swiped = false
    
    var shapeList = [Polygon]()
    let overallWidth = 1106
    let overallHeight = 487
    // overallFills: overall heap map values
    var overallFills: [Double]
    
    let densityData = DensityData()
    
    typealias Handler = (Data?, URLResponse?, Error?) -> Swift.Void
    
    var densityResultHeapMaps =  [WindowHeatMap]()
    
    var restaurantNames = ["Cafe Deadend", "Homei", "Teakha", "Cafe Loisl", "PetiteOyster",
                           "For Kee Restaurant", "Palomino Espresso", "Upstate", "Traif", "Graham Avenue Meats And Deli",
                           "Waffle & Wolf", "Five Leaves", "Cafe Lore", "Confessional"]
    
    required init?(coder aDecoder: NSCoder) {
        self.sketchFills = [Double](repeating: 1.0, count: sketchWidth * sketchHeight)
        self.sketchTiles = [Double](repeating: 0.0, count: sketchWidth * sketchHeight)
        
        //        create H*W 2D array with respect to the rectTiles
        self.rectTiles = [CGRect](repeating:CGRect(x: 0, y: 0, width: 0, height: 0), count: sketchWidth * sketchHeight)
        for x in 0..<sketchWidth {
            for y in 0..<sketchHeight{
                
                let orginPoint = CGPoint(x: CGFloat(x)*rectSize.width, y: CGFloat(y)*rectSize.height)
                self.rectTiles[x*sketchWidth+y] = CGRect(origin: orginPoint, size: rectSize)
            }
        }
        rgbDiffs = [[baseDiff, 2*baseDiff, baseDiff],
                    [2*baseDiff, 3*baseDiff, 2*baseDiff]]
        
        self.overallFills = [Double](repeating: 1.0, count: self.overallWidth * self.overallHeight)
        
        
        
        super.init(coder: aDecoder)
        //        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        self.sketchView.layer.borderColor = UIColor.black.cgColor
        self.sketchView.layer.borderWidth = 1
        self.resultView.layer.borderColor = UIColor.black.cgColor
        self.resultView.layer.borderWidth = 1
        //        getAllShapes()
        //        setOverallFills()
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    
    @IBOutlet weak var resultView: UIImageView!
    
    @IBOutlet weak var sketchView: UIImageView!
    
    @IBAction func clear(_ sender: AnyObject) {
        sketchClear()
    }
    
    @IBOutlet weak var swithButton: UIButton!
    
    @IBAction func sketchToggle(_ sender: Any) {
        sketchClear()
        self.densityData.sketchTypeToggole()
        let sketchType = self.densityData.sketchType
        if sketchType == 1 {
            self.swithButton.setTitle("Switch to density sketch", for: .normal)
        } else {
            self.swithButton.setTitle("Switch to direction sketch", for: .normal)
        }
    }

    func sketchClear() {
        self.sketchView.image = nil
        self.resultView.image = nil
        sketchFills = [Double](repeating: 1.0, count: sketchWidth * sketchHeight)
        sketchTiles = [Double](repeating: 0.0, count: sketchWidth * sketchHeight)
        
        self.rgbNo = 1
        self.densityResultHeapMaps = []
        self.tableView.reloadData()
        self.densityData.clearSketch()
    }
    
    
    func fillRects(aroundPoint currentPoint: CGPoint){
        updateSketchFills(basedOn: currentPoint)
        
        var color: UIColor
        UIGraphicsBeginImageContext(self.sketchView.frame.size)
        //        let context = UIGraphicsGetCurrentContext()
        //        context?.saveGState()
        for x in 0..<sketchWidth {
            for y in 0..<sketchHeight {
                color = UIColor(white: CGFloat(sketchFills[x*sketchWidth+y]), alpha: 1)
                color.setFill()
                UIRectFill(rectTiles[x*sketchWidth+y])
            }
        }
        sketchView.image = UIGraphicsGetImageFromCurrentImageContext()
        //        context?.restoreGState()
        UIGraphicsEndImageContext()
        
    }
    
    func updateSketchFills (basedOn currentPoint: CGPoint) {
        //        let sketchWidth = Int(sketchHeatMapSize.width)
        //        let sketchHeight = Int(sketchHeatMapSize.height)
        let currentX = Int(currentPoint.x/self.rectSize.width)
        let currentY = Int(currentPoint.y/self.rectSize.height)
        var x: Int
        var y: Int
        
        cLoop: for i in -1...1 {
            x = currentX + i
            if x < 0 || x >= self.sketchWidth{
                continue cLoop
            }
            rLoop: for j in -1...0 {
                y = currentY + j
                if y < 0 || y >= self.sketchHeight{
                    continue rLoop
                }
                let rgbDiff = self.rgbDiffs[j+1][i+1]
                if self.sketchFills[x*sketchHeight+y] + rgbDiff < 0 {
                    self.sketchFills[x*sketchHeight+y] = 0
                    self.sketchTiles[x*sketchHeight+y] = 255.0
                } else {
                    self.sketchFills[x*sketchHeight+y] += rgbDiff
                    self.sketchTiles[x*sketchHeight+y] += abs(rgbDiff/baseDiff)
                }
                
            }
        }
    }
      
    
    @IBAction func densitySearch(_ sender: Any) {
        //        select * from markup where cx between 39400.0 and 40400.0 and cy between 36900.0 and 37900.0
        //        let x1 = 394.0*100, x2 = (394.0+10.0)*100, y1 = 369.0*100, y2 = (369.0+10.0)*100
        self.densityResultHeapMaps.removeAll()
        self.tableView.reloadData()
        densityData.densitySearch(withSketch: self.sketchTiles)
        if densityData.resultsCount == 0 {
            let alert = UIAlertController(title: nil, message: "No result found \n Please draw again" , preferredStyle: .alert)
            let okAction = UIAlertAction(title: "OK", style: .cancel, handler: nil)
            alert.addAction(okAction)
            present(alert, animated: true, completion: nil)
            print("No result found")
        } else {
            self.densityResultHeapMaps = densityData.resultHeatMaps
            self.tableView.reloadData()
        }
    }
    
    
    func drawPolygons(startX: Double, startY: Double, polygons: [Polygon]){
        
        //        let context = UIGraphicsGetCurrentContext()
        //        context?.saveGState()
        
        print("starts drawing polygons")
//        if self.resultView.image == nil {
//            print("resultView.image is nil")
//        }
        UIGraphicsBeginImageContext(self.resultView.frame.size)
        resultView.image?.draw(in: CGRect(x: 0, y: 0, width: self.resultView.frame.width, height: self.resultView.frame.height))
        let context = UIGraphicsGetCurrentContext()
        context?.saveGState()
        
        // reset the current rect fill in this context
        let color = UIColor(white: 1, alpha: 1)
        color.setFill()
        UIRectFill(CGRect(x: 0, y: 0, width: 300, height: 300))
        
        // drawing polygons
        context?.setLineCap(.round)
        context?.setLineWidth(0.5)
        context?.setFillColor(gray: 0, alpha: 1)
        context?.setBlendMode(.normal)
        
        
//        if  let minDiffResult = densityData.minDiffResult{
//            let x0 = minDiffResult.x, y0 = minDiffResult.y
//            for polygon in polygons {
//                var points = [CGPoint]()
//                for v in polygon.vertices{
//                    points.append(CGPoint(x: (v.x-x0*100)/100/10*300, y: (v.y-y0*100)/100/10*300))
//                }
//                for p in points {
//                    if p == points[0] {
//                        context?.move(to: p)
//                    }
//                    context?.addLine(to: p)
//                }
//                context?.addLine(to: points[0])
//            }
//            context?.strokePath()
//            
//        }
        
        for polygon in polygons {
            var points = [CGPoint]()
            for v in polygon.vertices{
                points.append(CGPoint(x: (v.x-startX*100)/100/10*300, y: (v.y-startY*100)/100/10*300))
            }
            for p in points {
                if p == points[0] {
                    context?.move(to: p)
                }
                context?.addLine(to: p)
            }
            context?.addLine(to: points[0])
        }
        context?.strokePath()
        
        resultView.image = UIGraphicsGetImageFromCurrentImageContext()
        context?.restoreGState()
        UIGraphicsEndImageContext()
        
        print("drawing finished, polygons count: \(polygons.count)")
    }
    
    
    
    
    //    func drawLineFrom(fromPoint: CGPoint, toPoint: CGPoint, in imageView: UIImageView) {
    func drawLineFrom(fromPoint: CGPoint, toPoint: CGPoint) {
        
        // 1
        UIGraphicsBeginImageContext(self.sketchView.frame.size)
        sketchView.image?.draw(in: CGRect(x: 0, y: 0, width: self.sketchView.frame.width, height: self.sketchView.frame.height))
        let context = UIGraphicsGetCurrentContext()
        
        context?.setLineCap(.round)
        context?.setLineWidth(0.5)
        context?.setStrokeColor(red: 0, green: 0, blue: 0, alpha:1.0)
        context?.setBlendMode(.normal)
        context?.move(to: fromPoint)
        context?.addLine(to: toPoint)
        context?.strokePath()
        
        sketchView.image = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        
    }
    
    func drawLine(fromPoint: CGPoint, toPoint: CGPoint, in context: CGContext?) {
        context?.setLineCap(.round)
        context?.setLineWidth(0.5)
        context?.setStrokeColor(red: 0, green: 0, blue: 0, alpha:1.0)
        context?.setBlendMode(.normal)
        context?.move(to: fromPoint)
        context?.addLine(to: toPoint)
        context?.strokePath()
    }
    
    func sketchVectors() {
        let vField = densityData.vectorField
        let size = 10
        UIGraphicsBeginImageContext(self.sketchView.frame.size)
        sketchView.image?.draw(in: CGRect(x: 0, y: 0, width: self.sketchView.frame.width, height: self.sketchView.frame.height))
        let context = UIGraphicsGetCurrentContext()
        context?.saveGState()
        
//        // reset context
        let color = UIColor(white: 1, alpha: 1)
        color.setFill()
        UIRectFill(CGRect(x: 0, y: 0, width: 300, height: 300))
        
        
        let context0 = UIGraphicsGetCurrentContext()
        for i in 0..<size {
            for j in 0..<size {
                let index = j * size + i
                if (vField[index].x != 0 && vField[index].y != 0) {
                    let rSize = Double(rectSize.width)
                    let p1 = CGPoint(x: (Double(i) + 0.5) * rSize, y: (Double(j) + 0.5) * rSize)
                    let p2 = CGPoint(x: (Double(i) + 0.5) * rSize + vField[index].x * 6,
                                     y: (Double(j) + 0.5) * rSize + vField[index].y * 6)
                    drawLine(fromPoint: p1, toPoint: p2, in: context0)
//                    line((i + 0.5f) * rectSize, (j + 0.5f) * rectSize,
//                         (i + 0.5f) * rectSize + (float) vField[index].x * 6,
//                         (j + 0.5f) * rectSize + (float) vField[index].y * 6)
                }
            }
        }
        
        
        sketchView.image = UIGraphicsGetImageFromCurrentImageContext()
        context?.restoreGState()
        UIGraphicsEndImageContext()
//        int i = densityData.lines.size() - 1;
//        if (i >= 0) {
//            // for (int i = 0; i < densityData.lines.size(); i++) {
//            // System.out.println(i+" "+densityData.lines.get(i).line.size());
//            drawLine(densityData.lines.get(i));
//        }
    }
    
    /******************************************************************************************/
    /************************************ drawing process *************************************/
    /******************************************************************************************/
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        swiped = false
        if let touch = touches.first{
            lastPoint = touch.location(in: self.sketchView)
            
        }
    }
    
    override func touchesMoved(_ touches: Set<UITouch>, with event: UIEvent?) {
        swiped = true
        if let touch = touches.first{
            let currentPoint = touch.location(in: self.sketchView)
            //            drawLineFrom(fromPoint: lastPoint, toPoint: currentPoint)
            if densityData.sketchType == 0 {
                fillRects(aroundPoint: currentPoint)
            } else {
                drawLineFrom(fromPoint: lastPoint, toPoint: currentPoint)
                densityData.lines.last?.linePoints.append(Point(newX: Double(currentPoint.x),
                                                                newY: Double(currentPoint.y)))
            }
            
            lastPoint = currentPoint
        }
    }
    
    override func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent?) {
        if  densityData.sketchType == 1 {
            // drawLineFrom(fromPoint: lastPoint, toPoint: lastPoint)   // draw a single point
            densityData.lines.last?.setVector()
            densityData.updateVector()
            sketchVectors()
            densityData.lines.append(Line()) // append new line for next round of sketching
            densityData.lineNum += 1
        }
        
    }
    
    /******************************************************************************************/
    /************************************** web service ***************************************/
    /******************************************************************************************/
    
    func getShapeListFromWindow(x1: Double, x2: Double, y1: Double, y2: Double, handler: @escaping Handler) {
//        let URL_GET_FROM_WINDOW: String = "http://127.0.0.1/WebService/api/getMarkupsFromWindow.php"
        let URL_GET_FROM_WINDOW: String = "http://192.168.1.14/WebService/api/getMarkupsFromWindow.php"
//        let URL_GET_FROM_WINDOW: String = "http://130.245.68.147/WebService/api/getMarkupsFromWindow.php"

        //        "http://sampleaddress?key1=value1&key2=value2"
        let requestURL = URL(string: "\(URL_GET_FROM_WINDOW)?X1=\(x1)&X2=\(x2)&Y1=\(y1)&Y2=\(y2)")
        let request = NSMutableURLRequest(url: requestURL!)
        request.httpMethod = "GET"
        
        //creating a task to send the get request
        let task = URLSession.shared.dataTask(with: request as URLRequest, completionHandler:  handler)
        //executing the task
        task.resume()
        print("select * from markup where cx between \(x1) and \(x2) and cy between \(y1) and \(y2)")
        
    }
    
    /******************************************************************************************/
    /*************************************** Table View ***************************************/
    /******************************************************************************************/
    
    //    two required methods from UITableViewDataSource protocol
    //    but there is no requried method in UITableViewDataDelegate protocol: all methods in this protocol are optional
    @IBOutlet weak var tableView: UITableView!
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
//        return restaurantNames.count
        return densityResultHeapMaps.count
    }
    
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cellIdentifier = "Cell"
        let cell = tableView.dequeueReusableCell(withIdentifier: cellIdentifier, for: indexPath) as! WindowHeatMapCell
        // Configure the cell...
//        cell.textLabel?.text = restaurantNames[indexPath.row]
        if densityResultHeapMaps.count != 0 {
            cell.imageView?.image = densityResultHeapMaps[indexPath.row].image
            return cell
        }
        return cell
    }
    
    
    //    one method from UITableViewDataDelegate protocol
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if densityData.resultsCount != 0 {
           
            let heatMapResult = densityData.results[indexPath.row]
            let windowStartPoint = heatMapResult.originPoint
            let x1 = windowStartPoint.x * 100, x2 = (windowStartPoint.x+10) * 100
            let y1 = windowStartPoint.y * 100, y2 = (windowStartPoint.y+10) * 100
            
            let singleResultHandler: Handler = { (data, response, error) in
                //exiting if there is some error
                if error != nil{
                    print("error is \(error)")
                    return;
                }
                
                //parsing the response
                do {
                    //converting response to NSDictionary
                    var markupJSON: NSDictionary!
                    markupJSON =  try JSONSerialization.jsonObject(with: data!, options: .mutableContainers) as? NSDictionary
                    
                    //getting the JSON array markups from the response
                    let markups: NSArray = markupJSON["markups"] as! NSArray
                    
                    //looping through all the json objects in the array teams
                    self.shapeList.removeAll()
                    for iterm in markups{
                        let markup = iterm as! [String: Any]
                        //getting the data at each index
                        let vertices:String = markup["POLYGON"] as! String!
                        let cx:Double = markup["CX"] as! Double!
                        let cy:Double = markup["CY"] as! Double!
                        self.shapeList.append(Polygon(fromString: vertices, centerX: cx, centerY: cy))
                    }
                    self.drawPolygons(startX: windowStartPoint.x, startY: windowStartPoint.y, polygons: self.shapeList)
                    
                } catch {
                    print(error)
                }
                
            }
            
            self.resultView.image = nil
            getShapeListFromWindow(x1: x1, x2: x2, y1: y1, y2: y2, handler: singleResultHandler)
            //            print("ShapeList count: \(shapeList.count)")
        }
    }

    
    
//    @IBAction func testCells(_ sender: Any) {
//        self.restaurantNames = ["1", "2"]
//        self.tableView.reloadData()
//        
//    }
    
    

    
    
    
}
