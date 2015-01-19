//
//  ClockView.swift
//  BruinLife
//
//  Created by Matthew DeCoste on 1/18/15.
//  Copyright (c) 2015 Matthew DeCoste. All rights reserved.
//

import UIKit
import CoreGraphics

class ClockView: UIView {
	var percLayer: CAShapeLayer = CAShapeLayer()
	
	override init(frame: CGRect) {
		super.init(frame: frame)
		establish()
	}
	
	required init(coder aDecoder: NSCoder) {
		super.init(coder: aDecoder)
		establish()
	}
	
	func establish() {
		let lineWidth = max(0.025 * frame.width, 1.0) // 0.025 | 0.0375
		var contentsScale: CGFloat = UIScreen.mainScreen().scale
		
		percLayer.frame = bounds
		percLayer.contentsScale = contentsScale
		percLayer.strokeColor = tintColor!.CGColor
		percLayer.fillColor = UIColor.grayColor().CGColor
		percLayer.lineCap = kCALineCapSquare
		percLayer.lineWidth = lineWidth
		
		
		
		let startAngle = CGFloat(-1*M_PI_2)
		let endAngle = startAngle + (2 * CGFloat(M_PI))
		let radius = (bounds.width - (3 * lineWidth)) / 2
		
		var processPath = UIBezierPath()
		processPath.lineCapStyle = kCGLineCapButt
		processPath.lineWidth = lineWidth
		processPath.addArcWithCenter(CGPoint(x: frame.size.width/2, y: frame.size.height/2), radius: radius, startAngle: startAngle, endAngle: endAngle, clockwise: true)
		
		percLayer.path = processPath.CGPath
		
		layer.addSublayer(percLayer)
		
		setNeedsDisplay()
		
//		secondMarkers(ctx, x: frame.midX, y: frame.midY, radius: rad, sides: 60, color: .whiteColor())
		
	}

	
	
//	func degree2radian(degree: CGFloat) -> CGFloat {
//		return CGFloat(M_PI) * degree/180
//	}
//	
//	func circleCircumferencePoints(sides: Int, x: CGFloat, y: CGFloat, radius: CGFloat, adjustment: CGFloat=0) -> [CGPoint] {
//		let angle = degree2radian(360/CGFloat(sides))
//		var i: CGFloat = CGFloat(sides)
//		var points = [CGPoint]()
//		while points.count <= sides {
//			let xpo = x - radius * cos(angle * i + degree2radian(adjustment))
//			let ypo = y - radius * sin(angle * i + degree2radian(adjustment))
//			points.append(CGPoint(x: xpo, y: ypo))
//			i--;
//		}
//		return points
//	}
//	
//	func secondMarkers(ctx: CGContextRef, x: CGFloat, y: CGFloat, radius: CGFloat, sides: Int, color: UIColor) {
//		let points = circleCircumferencePoints(sides, x: x, y: y, radius: radius)
//		let path = CGPathCreateMutable()
//		
//		var divider: CGFloat = 1/16
//		for point in enumerate(points) {
//			divider = point.index % 5 == 0 ? 1/8 : 1/16
//			
//			let xn = point.element.x + divider * ( x - point.element.x )
//			let yn = point.element.y + divider * ( y - point.element.y )
//			
//			CGPathMoveToPoint(path, nil, point.element.x, point.element.y)
//			CGPathAddLineToPoint(path, nil, xn, yn)
//			CGPathCloseSubpath(path)
//			
//			CGContextAddPath(ctx, path)
//		}
//		CGContextSetStrokeColorWithColor(ctx, color.CGColor)
//		CGContextSetLineWidth(ctx, 3.0)
//		CGContextStrokePath(ctx)
//	}
}
