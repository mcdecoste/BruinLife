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
	
	var progress: CGFloat = 0.0 {
		didSet {
			let startAngle = CGFloat(-1*M_PI_2)
			let endAngle = startAngle + (2 * CGFloat(M_PI) * self.progress)
			let radius = (bounds.width - (3 * lineWidth)) / 2
			
			var processPath = UIBezierPath()
			processPath.lineCapStyle = kCGLineCapButt
			processPath.lineWidth = lineWidth
			processPath.addArcWithCenter(CGPoint(x: frame.size.width/2, y: frame.size.height/2), radius: radius, startAngle: startAngle, endAngle: endAngle, clockwise: true)
			
			percLayer.path = processPath.CGPath
			
			setNeedsDisplay()
		}
	}
	var lineWidth: CGFloat = 0.0 {
		didSet {
			percLayer.lineWidth = lineWidth * progressWidthRatio
		}
	}
	
	let progressWidthRatio: CGFloat = 2.0 // must be larger than 1
	
	var servingCount: Int = 1 {
		didSet {
			update()
		}
	}
	
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
	}
	
	func update() {
		if nutrition?.percent == nil {
			changeProgress(1)
			percLayer.strokeColor = UIColor(white: 0.2, alpha: 0.25).CGColor
		} else {
			changeProgress(CGFloat(servingCount * (nutrition?.percent)!) / 100)
			percLayer.strokeColor = UIColor(red: 0, green: 0.478431, blue: 1, alpha: 1).CGColor
		}
		updateDisplayText()
	}
	
	func handleTap() {
		if nutrition!.percent == nil {
			showingAmount = !showingAmount
			updateDisplayText()
		}
	}
	
	func changeProgress(progress: CGFloat) {
		self.progress = min(progress, 1)
	}
	
	func updateDisplayText() {
		let trueMeasure = CGFloat(NSNumberFormatter().numberFromString((nutrition?.measure)!)!)
		let measure = "\(Int(CGFloat(servingCount) * trueMeasure))" // round it
		let unit = (nutrition?.unit)!
		let percOpt = nutrition?.percent
		var perc = 100
		if let percNotOpt = percOpt {
			perc = percNotOpt * servingCount
		}
//		let perc = percOpt == nil ? 100 : percOpt! * servingCount
		let tooLong = count(measure + unit) > 4 // count should work but doesn't
		let inbetweenText = tooLong ? "\n" : ""
		centralLabel.numberOfLines = tooLong ? 2 : 1
		
		let text = showingAmount ? (measure + inbetweenText + unit) : "\(perc)%"
		
		centralLabel.frame.size = bounds.size
		centralLabel.text = text
		centralLabel.sizeToFit()
		centralLabel.center = CGPoint(x: frame.size.width/2, y: frame.size.height/2)
	}
}