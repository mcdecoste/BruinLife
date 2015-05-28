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
	private var centralLabel: UILabel = UILabel()
	private var percLayer: CAShapeLayer = CAShapeLayer()
	
	private var nutrition: NutritionListing = NutritionListing(type: .Cal, measure: "0")
	var servingCount: Int = 1 { didSet { update() } }
	private var showingAmount: Bool = true
	
	private var progress: CGFloat = 0.0 {
		didSet {
			let startAngle = CGFloat(-1*M_PI_2)
			let endAngle = startAngle + (2 * CGFloat(M_PI) * progress)
			let radius = bounds.midX - 1.5 * lineWidth
			
			var processPath = UIBezierPath()
			processPath.lineCapStyle = kCGLineCapButt
			processPath.lineWidth = lineWidth
			processPath.addArcWithCenter(boundCenter, radius: radius, startAngle: startAngle, endAngle: endAngle, clockwise: true)
			
			percLayer.path = processPath.CGPath
			
			setNeedsDisplay()
		}
	}
	private var boundCenter: CGPoint { get { return CGPoint(x: bounds.midX, y: bounds.midY) } }
	private var lineWidth: CGFloat = 0.0 {
		didSet {
			percLayer.lineWidth = lineWidth
		}
	}
	
	override init(frame: CGRect) {
		super.init(frame: frame)
		
		setup()
	}
	
	required init(coder aDecoder: NSCoder) {
		super.init(coder: aDecoder)
		
		setup()
	}
	
	private func setup() {
		// label
		centralLabel.font = .systemFontOfSize(10)
		centralLabel.center = boundCenter
		centralLabel.textAlignment = .Center
		
		// layers time
		lineWidth = max(0.025 * frame.width, 1.0) // 0.025 | 0.0375
		
		percLayer.frame = bounds
		percLayer.strokeColor = tintColor!.CGColor
		percLayer.fillColor = nil
		percLayer.lineCap = kCALineCapSquare
		
		layer.addSublayer(percLayer)
		addSubview(centralLabel)
		addTarget(self, action: "handleTap", forControlEvents: .TouchUpInside)
	}
	
	// MARK: Setters
	func setNutrition(nutrition: NutritionListing, servingCount: Int) {
		self.nutrition = nutrition
		self.servingCount = servingCount
	}
	
	private func update() {
		if let percent = nutrition.percent {
			changeProgress(CGFloat(servingCount * percent) / 100.0)
			percLayer.strokeColor = UIColor(red: 0, green: 0.478431, blue: 1, alpha: 1).CGColor
		} else {
			changeProgress(1)
			percLayer.strokeColor = UIColor(white: 0.2, alpha: 0.25).CGColor
		}
		
		updateDisplayText()
	}
	
	private func handleTap() {
		if let _ = nutrition.percent {
			showingAmount = !showingAmount
			updateDisplayText()
		}
	}
	
	private func changeProgress(progress: CGFloat) {
		self.progress = min(progress, 1)
	}
	
	private func updateDisplayText() {
		let formatter = NSNumberFormatter()
		let trueMeasure = Int(Float(servingCount) * (formatter.numberFromString(nutrition.measure)?.floatValue ?? 0))
		let measure = formatter.stringFromNumber(NSNumber(integer: trueMeasure)) ?? "0"
		var perc = nutrition.percent == nil ? 100 : (nutrition.percent! * servingCount)
		let tooLong = count(measure + nutrition.unit) > 4
		let inbetweenText = tooLong ? "\n" : ""
		
		centralLabel.numberOfLines = tooLong ? 2 : 1
		centralLabel.text = showingAmount ? "\(measure)\(inbetweenText)\(nutrition.unit)" : "\(perc)%"
		centralLabel.frame.size = centralLabel.sizeThatFits(bounds.size) // using bounds size => fills circle properly
		centralLabel.center = boundCenter
	}
}