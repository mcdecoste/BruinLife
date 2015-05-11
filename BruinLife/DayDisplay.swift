//
//  DayDisplay.swift
//  BruinLife
//
//  Created by Matthew DeCoste on 5/9/15.
//  Copyright (c) 2015 Matthew DeCoste. All rights reserved.
//

import UIKit

class DayDisplay: UIButton {
	var date: NSDate = comparisonDate() {
		didSet {
			setupLabel()
			changeLabelText()
		}
	}
	var dayIndex: Int = 0 {
		didSet {
			date = comparisonDate(daysInFuture: dayIndex)
		}
	}
	
	func setupLabel() {
		setTitle("Hello", forState: .Normal)
		titleLabel!.font = .boldSystemFontOfSize(14)
//		titleLabel!.textAlignment = .Center
		setTitleColor(color(0, 122, 255), forState: .Normal)
		setTitleColor(color(0, 122, 255, alpha: 0.4), forState: .Highlighted)
	}
	
	func changeLabelText() {
		var formatter = NSDateFormatter()
//		formatter.dateStyle = .ShortStyle
		formatter.dateFormat = "EEEE, M/d"
		
		titleLabel!.text = formatter.stringFromDate(date)
//		titleLabel.frame.size.width = NSString(string: titleLabel.text!).sizeWithAttributes([NSFontAttributeName: titleLabel.font]).width
//		frame.size.width = titleLabel.frame.width
//		setNeedsDisplay()
	}
	
	
}
