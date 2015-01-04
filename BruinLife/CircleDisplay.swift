//
//  CircleDisplay.swift
//  BruinLife
//
//  Created by Matthew DeCoste on 1/1/15.
//  Copyright (c) 2015 Matthew DeCoste. All rights reserved.
//

import UIKit
import QuartzCore
import CoreGraphics

class CircleDisplay: UIButton {
	var centralLabel: UILabel
	var percLayer: CAShapeLayer
	
	var nutrition: NutritionListing?
	var showingAmount: Bool = true
	
	var progress: CGFloat = 0.0
	var lineWidth: CGFloat = 0.0
	
	let progressWidthRatio: CGFloat = 2.0 // must be larger than 1
	
	var servingCount: Int = 1
	
	override init(frame: CGRect) {
		centralLabel = UILabel(frame: frame)
		percLayer = CAShapeLayer()
		super.init(frame: frame)
		
		setup()
	}
	
	required init(coder aDecoder: NSCoder) {
		centralLabel = UILabel(coder: aDecoder)
		percLayer = CAShapeLayer(coder: aDecoder)
		super.init(coder: aDecoder)
		
		setup()
	}
	
	func setup() {
		backgroundColor = .clearColor()
		
		// label
		centralLabel.text = ""
		centralLabel.font = UIFont.systemFontOfSize(10)
		centralLabel.sizeToFit()
		centralLabel.center = center
		centralLabel.numberOfLines = 2
		centralLabel.textAlignment = .Center
		
		// layers time
		lineWidth = max(0.025 * frame.width, 1.0) // 0.025 | 0.0375
		var contentsScale: CGFloat = UIScreen.mainScreen().scale
		
		percLayer.frame = bounds
		percLayer.contentsScale = contentsScale
		percLayer.strokeColor = tintColor!.CGColor
		percLayer.fillColor = nil
		percLayer.lineCap = kCALineCapSquare
		percLayer.lineWidth = lineWidth * progressWidthRatio
		
		layer.addSublayer(percLayer)
		addSubview(centralLabel)
		
		addTarget(self, action: "handleTap", forControlEvents: .TouchUpInside)
	}
	
	// MARK: Setters
	func setNutrition(nutrition: NutritionListing, servingCount: Int) {
		self.nutrition = nutrition
		self.servingCount = servingCount
		
		if self.nutrition?.percent == nil {
			setProgress(1)
			percLayer.strokeColor = UIColor(white: 0.2, alpha: 0.25).CGColor
		} else {
			setProgress(CGFloat(self.servingCount * (self.nutrition?.percent)!) / 100)
			percLayer.strokeColor = tintColor!.CGColor
		}
		updateDisplayText()
	}
	
	func handleTap() {
		if (nutrition?.type.hasDVpercentage())! {
			showingAmount = !showingAmount
			updateDisplayText()
		}
	}
	
	func setProgress(progress: CGFloat) {
		self.progress = min(progress, 1)
		
		let startAngle = CGFloat(3*M_PI_2)
		let endAngle = startAngle + (2 * CGFloat(M_PI) * self.progress)
		let radius = (bounds.width - (3 * lineWidth)) / 2
		
		var processPath = UIBezierPath()
		processPath.lineCapStyle = kCGLineCapButt
		processPath.lineWidth = lineWidth
		processPath.addArcWithCenter(CGPoint(x: frame.size.width/2, y: frame.size.height/2), radius: radius, startAngle: startAngle, endAngle: endAngle, clockwise: true)
		
		percLayer.path = processPath.CGPath
		
		setNeedsDisplay()
	}
	
	func setLineWidth(width: CGFloat) {
		self.lineWidth = width
		
		percLayer.lineWidth = width * progressWidthRatio
	}
	
	func updateDisplayText() {
		let measure = "\(self.servingCount * NSString(string: (self.nutrition?.measure)!).integerValue)"
		let unit = (self.nutrition?.unit)!
		let percOpt = self.nutrition?.percent
		let perc = percOpt == nil ? 100 : percOpt!
		
		let tooLong = countElements(measure + unit) > 4
		let inbetweenText = tooLong ? "\n" : ""
		centralLabel.numberOfLines = tooLong ? 2 : 1
		
		let text = showingAmount ? (measure + inbetweenText + unit) : "\(perc)%"
		
		centralLabel.frame.size = bounds.size
		centralLabel.text = text
		centralLabel.sizeToFit()
		centralLabel.center = CGPoint(x: frame.size.width/2, y: frame.size.height/2)
	}
}