//
//  AnswerSystemLineHelper.swift
//  MMRichText_Example
//
//  Created by Mac on 2018/4/6.
//  Copyright © 2018 CocoaPods. All rights reserved.
//

import UIKit

class AnswerSystemLineLayer: CAShapeLayer {
    
}

class AnswerSystemLineHelper: NSObject {
    
    func addLine(left: UIView?, right: UIView?) -> AnswerSystemLineLayer? {
        
        guard let left = left, let right = right else {
            return nil
        }
        
        if let elipseLeft = left as? EllipseButton, let elipseRight = right as? EllipseButton {
            if elipseLeft.position == elipseRight.position {
                return nil
            }
        }
        
        let linkPath = UIBezierPath()
        
        var lineViewLeftSide = left
        var lineViewRightSlide = right
        
        if let elipseLeft = left as? EllipseButton, let elipseRight = right as? EllipseButton {
            if elipseLeft.position > elipseRight.position  {
                //左右
                lineViewLeftSide = right
                lineViewRightSlide = left
                
            }
        }
        
        let startX = lineViewLeftSide.x + lineViewLeftSide.width + 15
        let endX = lineViewRightSlide.x + 15
        
        let startPoint = CGPoint(x: startX , y: lineViewLeftSide.center.y)
        let endPoint = CGPoint(x: endX, y: lineViewRightSlide.center.y)
        
        linkPath.move(to: startPoint)
        linkPath.addLine(to: endPoint)
        
        let lineLayer = AnswerSystemLineLayer()
        lineLayer.lineWidth = 1.5
        lineLayer.strokeColor = RTThemeColor.cgColor
        lineLayer.path = linkPath.cgPath
        return lineLayer
    }
    
    func remove(line: CAShapeLayer?) {
        
        guard let line = line, let path = line.path else {
            return
        }
        
        UIBezierPath(cgPath: path).removeAllPoints()
        line.removeFromSuperlayer()
    }
    
}
