//
//  PlotOrig.swift
//  healthTexter
//
//  Created by Ioannis Tornazakis on 4/4/16.
//  Copyright © 2016 polarbear.gr. All rights reserved.
//
//  Closely followed the example found on the next link:
//  http://www.raywenderlich.com/90693/modern-core-graphics-with-swift-part-2
//

import UIKit

/// Base class intended to be extended by the pain, sleep, functionality and progress classes
public class Plot: UIView {
    
    // MARK: - Properties
    
    // Data are initialized in the ProgressViewConrtoller
    public var graphPoints: [Int] = Array()
    
    // Gradient
    @IBInspectable public var startColor: UIColor = UIColor.red
    @IBInspectable public var endColor: UIColor = UIColor.green
    
    // MARK: - UIView
    
    override public func draw(_ rect: CGRect) {
        
        //----------------------------------
        // Background clipping area
        //----------------------------------
        let path = UIBezierPath(
            roundedRect: rect,
            byRoundingCorners: UIRectCorner.allCorners,
            cornerRadii: CGSize(width: 8.0, height: 8.0)
        )
        path.addClip()
        
        //------------------------
        // Gradient
        //------------------------
        
        // Get the current context
        let context = UIGraphicsGetCurrentContext()
        let colors = [startColor.cgColor, endColor.cgColor]
        
        // Set up the color space
        let colorSpace = CGColorSpaceCreateDeviceRGB()
        
        // Set up the color stops
        let colorLocations: [CGFloat] = [0.0, 1.0]
        
        // Create the gradient
        let gradient = CGGradient(colorsSpace: colorSpace, colors: colors as CFArray, locations: colorLocations)
        
        // Draw the gradient
        var startPoint = CGPoint.zero
        var endPoint = CGPoint(x: 0, y: self.bounds.height)
        context!.drawLinearGradient(gradient!, start: startPoint, end: endPoint, options: CGGradientDrawingOptions(rawValue: 0))
        
        //------------------------
        // Calculate the x point
        //------------------------
        
        let margin: CGFloat = 20.0
        let columnXPoint = { (column: Int) -> CGFloat in
            // Set the number of points on the x-axis If you want to resize the x-axis to the available number of points, use self.graphPoints.count - 1 instead
            let numberOfWeekPoints = 7 - 1
            let numberOfMonthPoints = 30 - 1

            // Define the number of points for week or month view
            var numberOfPoints = 0
            if self.graphPoints.count <= 7 {
                numberOfPoints = numberOfWeekPoints
            } else {
                numberOfPoints = numberOfMonthPoints
            }
            
            // Calculate gap between points
            let spacer = (rect.width - margin * 2 - 4) / CGFloat((numberOfPoints))
            var x: CGFloat = CGFloat(column) * spacer
            x += margin + 2
            
            return x
        }
        
        //------------------------
        // Calculate the y point
        //------------------------
        
        let topBorder: CGFloat = 60
        let bottomBorder: CGFloat = 50
        let graphHeight = rect.height - topBorder - bottomBorder
        var maxValue = graphPoints.max()
        
        let columnYPoint = { (graphPoint: Int) -> CGFloat in
            if maxValue == 0 { maxValue = 1 } // Avoid devision by zero
            var y: CGFloat = CGFloat(graphPoint) / CGFloat(maxValue!) * graphHeight

            // Flip the graph
            y = graphHeight + topBorder - y
            
            return y
        }
        
        //------------------------
        // Draw the line graph
        //------------------------
        
        UIColor.white.setFill()
        UIColor.white.setStroke()
        
        // Set up the points line
        let graphPath = UIBezierPath()
        
        // Go to start of line
        graphPath.move(to: CGPoint(x: columnXPoint(0), y: columnYPoint(graphPoints[0])))
        
        // Add points for each item in the graphPoints array at the correct (x, y) for the point
        for ix in 1 ..< graphPoints.count {
            let nextPoint = CGPoint(x: columnXPoint(ix), y: columnYPoint(graphPoints[ix]))
            graphPath.addLine(to: nextPoint)
        }

        //-----------------------------------------------------
        // Create the clipping path for the graph gradient
        //-----------------------------------------------------
        
        // Save the state of the context
        context!.saveGState()
        
        // Make a copy of the path
        let clippingPath = graphPath.copy() as! UIBezierPath
        
        // Add lines to the copied path to complete the clip area
        clippingPath.addLine(to: CGPoint(x: columnXPoint(graphPoints.count - 1), y: rect.height))
        clippingPath.addLine(to: CGPoint(x: columnXPoint(0), y: rect.height))
        clippingPath.close()
        
        // Add the clipping path to the context
        clippingPath.addClip()
        
        let highestYPoint = columnYPoint(maxValue!)
        startPoint = CGPoint(x: margin, y: highestYPoint)
        endPoint = CGPoint(x: margin, y: self.bounds.height)
        
        context!.drawLinearGradient(gradient!, start: startPoint, end: endPoint, options: CGGradientDrawingOptions(rawValue: 0))
        context!.restoreGState()
        
        //-------------------------------------------------
        // Draw the line on top of the clipped gradient
        //-------------------------------------------------
        
        graphPath.lineWidth = 2.0
        graphPath.stroke()
        
        //-------------------------------------------------
        // Draw the circles on top of graph stroke
        //-------------------------------------------------
        
        for ix in 0 ..< graphPoints.count {
            var point = CGPoint(x:columnXPoint(ix), y:columnYPoint(graphPoints[ix]))
            point.x -= 5.0/2
            point.y -= 5.0/2
            let circle = UIBezierPath(ovalIn: CGRect(origin: point, size: CGSize(width: 5.0, height: 5.0)))
            circle.fill()
        }
        
        //---------------------------------------------------------
        // Draw horizontal graph lines on the top of everything
        //---------------------------------------------------------
        
        let linePath = UIBezierPath()
        
        // Top line
        linePath.move(to: CGPoint(x:margin, y: topBorder))
        linePath.addLine(to: CGPoint(x: (rect.width - margin), y: topBorder))
        
        // Center line
        linePath.move(to: CGPoint(x: margin, y: graphHeight / 2 + topBorder))
        linePath.addLine(to: CGPoint(x: (rect.width - margin), y: (graphHeight/2 + topBorder)))
        
        // Bottom line
        linePath.move(to: CGPoint(x: margin, y: (rect.height - bottomBorder)))
        linePath.addLine(to: CGPoint(x: (rect.width - margin), y: (rect.height - bottomBorder)))
        let color = UIColor(white: 1.0, alpha: 0.3)
        color.setStroke()
        
        linePath.lineWidth = 1.0
        linePath.stroke()
    }
}
