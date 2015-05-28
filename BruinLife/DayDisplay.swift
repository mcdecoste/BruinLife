//
//  DayDisplay.swift
//  BruinLife
//
//  Created by Matthew DeCoste on 5/9/15.
//  Copyright (c) 2015 Matthew DeCoste. All rights reserved.
//

import UIKit

class DayDisplay: UIButton {
	private var normalColor: UIColor { get { return tintColor! } }
	private var highlightedColor: UIColor {
		get {
			let comp = CGColorGetComponents(normalColor.CGColor!)
			return UIColor(red: comp[0], green: comp[1], blue: comp[2], alpha: 0.2)
		}
	}
	private var title: String {
		get { return DayDisplay.titleStringDate(date) }
	}
	
	var date: NSDate = NSDate(timeIntervalSince1970: 0) {
		didSet {
			if oldValue == NSDate(timeIntervalSince1970: 0) {
				setupLabel()
			}
			setTitle(title, forState: .Normal)
			frame.size = NSString(string: titleLabel!.text!).sizeWithAttributes([NSFontAttributeName:titleLabel!.font])
		}
	}
	var dayIndex: Int = 0 { didSet { date = comparisonDate(dayIndex) } }
	
	override func tintColorDidChange() {
		super.tintColorDidChange()
		
		setTitleColor(normalColor, forState: .Normal)
		setTitleColor(highlightedColor, forState: .Highlighted)
	}
	
	private func setupLabel() {
		titleLabel!.font = .boldSystemFontOfSize(17)
		setTitleColor(normalColor, forState: .Normal)
		setTitleColor(highlightedColor, forState: .Highlighted)
	}
	
	class func titleString(daysInAdvance: Int) -> String {
		return titleStringDate(comparisonDate(daysInAdvance))
	}
	
	class func titleStringDate(date: NSDate) -> String {
		var formatter = NSDateFormatter()
		
		formatter.dateFormat = "EEEE, MMM"
		let short = formatter.stringFromDate(date)
		formatter.dateFormat = "EEEE, MMMM"
		let long = formatter.stringFromDate(date)
		
		let startStr = short == long ? long : "\(short)."
		
		formatter.dateFormat = "d"
		let day = formatter.stringFromDate(date)
		
		var titleStr = "\(startStr) \(day)"
		
		switch currCal.component(.CalendarUnitDay, fromDate: date) {
		case 1, 21, 31:
			titleStr += "st"
		case 2, 22:
			titleStr += "nd"
		case 3, 23:
			titleStr += "rd"
		default:
			titleStr += "th"
		}
		
		return titleStr
	}
}