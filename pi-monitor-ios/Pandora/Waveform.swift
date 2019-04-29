//
//  GraphView.swift
//  Pandora
//
//  Created by Kayron Cabral on 23/11/15.
//  Copyright © 2015 Pandora Technology. All rights reserved.
//

import UIKit

@objc protocol WaveformDelegate {
    optional func onTouchMoved(position: Int, xPoint: CGFloat)
}

class Waveform: UIView {
    
    @IBInspectable var lineColor: UIColor = UIColor.clearColor()
    @IBInspectable var maxValueMilivolts: CGFloat = 2.5
    @IBInspectable var secondRange: CGFloat = 6.0
    @IBInspectable var lineWidth: CGFloat = 1
    
    var delegate: WaveformDelegate?
    
    var quandrants: Int!
    
    private var margin = CGFloat(0)
    private var halfFactor = CGFloat(2)
    private var hundredthsFactor = CGFloat(100)
    private var width: CGFloat!
    private var height: CGFloat!
    private let marginTop = CGFloat(0)
    private let marginBotton = CGFloat(0)
    var isStreaming = true
    var data = [Float]() {
        didSet {
            if isStreaming {
                if data.count == Int(secondRange * hundredthsFactor) {
                    data.removeAll(keepCapacity: true)
                }
                redraw()
            }
        }
    }
    private var touchPoint = (Int(0), CGFloat(0))
    
    override func drawRect(rect: CGRect) {
        width = rect.width
        height = rect.height
        
        drawGrid()
        
        if !data.isEmpty {
            //calculate the x point
            let columnXPoint = { (column:Int) -> CGFloat in
                //Calculate gap between points
                let spacer = self.width / (self.secondRange * self.hundredthsFactor)
                return CGFloat(column) * spacer
            }
            
            // calculate the y point
            let graphHeight = (height - marginTop - marginBotton) / halfFactor
            let maxValue = maxValueMilivolts
            let columnYPoint = { (graphPoint:Float) -> CGFloat in
                var y = CGFloat(graphPoint) / CGFloat(maxValue) * graphHeight
                y = graphHeight + self.marginTop - y // Flip the graph
                return y
            }
            
            // draw the line graph
            lineColor.setFill()
            lineColor.setStroke()
            
            //set up the points line
            let graphPath = UIBezierPath()
            //go to start of line
            graphPath.moveToPoint(CGPoint(x:columnXPoint(0), y:columnYPoint(data[0])))
            
            //add points for each item in the data array
            //at the correct (x, y) for the point
            for i in 1..<data.count {
                let nextPoint = CGPoint(x:columnXPoint(i), y:columnYPoint(data[i]))
                graphPath.addLineToPoint(nextPoint)
            }
            
            graphPath.lineWidth = lineWidth
            graphPath.stroke()
        }
    }
    
    func drawGrid(){
        quandrants = Int(Double(secondRange) / 0.04)
        
        //Draw horizontal graph lines on the top of everything
        let hLinePath = UIBezierPath()
        let vMargin = height / 8
        let hMidlePoint = height / 2
        let hInitialPoint = (hMidlePoint) - (CGFloat(vMargin) * 5)
        let countHorizontalLines = quandrants + 1
        
        for i in 0..<countHorizontalLines {
            hLinePath.moveToPoint(CGPoint(x: 0, y: CGFloat(hInitialPoint + CGFloat(vMargin * CGFloat(i)))))
            hLinePath.addLineToPoint(CGPoint(x: width, y: CGFloat(hInitialPoint + CGFloat(vMargin * CGFloat(i)))))
        }
        
        Color.gray.colorWithAlphaComponent(0.1).setStroke()
        
        hLinePath.lineWidth = 1
        hLinePath.stroke()
        
        
        //Draw vertical graph lines on the top of everything
        let vLinePath2 = UIBezierPath()
        let hMargin = width / CGFloat(quandrants)
        let vMidlePoint = width / 2
        let vInitialPoint = (vMidlePoint) - (CGFloat(hMargin) * CGFloat(quandrants / 2))
        let countVerticalLines = quandrants + 1
        
        for i in 0..<countVerticalLines {
            if i % 5 == 0 {
                vLinePath2.moveToPoint(CGPoint(x: CGFloat(vInitialPoint + CGFloat(hMargin * CGFloat(i))), y: height - marginBotton))
                vLinePath2.addLineToPoint(CGPoint(x: CGFloat(vInitialPoint + CGFloat(hMargin * CGFloat(i))), y: marginBotton))
            }
        }
        
        Color.gray.colorWithAlphaComponent(0.1).setStroke()
        
        vLinePath2.lineWidth = 1
        vLinePath2.stroke()
    }
    
    func redraw() {
        self.setNeedsDisplay()
    }
    
    override func touchesMoved(touches: Set<UITouch>, withEvent event: UIEvent?) {
        let touch = getTouchPoint(touches)
        delegate?.onTouchMoved!(touch.position, xPoint: touch.xPoint)
    }
    
    override func touchesBegan(touches: Set<UITouch>, withEvent event: UIEvent?) {
        let touch = getTouchPoint(touches)
        delegate?.onTouchMoved!(touch.position, xPoint: touch.xPoint)
    }
    
    func getTouchPoint(touches: Set<UITouch>) -> (position: Int, xPoint: CGFloat) {
        let touch = touches.first
        let point = touch!.locationInView(self)
        let xPoint = point.x
        if (Int(xPoint) >= 0 && Int(xPoint) <= data.count) && (xPoint >= self.bounds.origin.x && xPoint <= self.bounds.width - self.layer.borderWidth) {
            let factor = CGFloat(data.count) >= self.bounds.width ? CGFloat(data.count) / self.bounds.width : 1.0
            touchPoint = (Int(xPoint * factor), xPoint)
            print(Int(xPoint * factor), data.count, factor)
        }
        return touchPoint
    }
    
}
