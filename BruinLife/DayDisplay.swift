//
//  DayDisplay.swift
//  BruinLife
//
//  Created by Matthew DeCoste on 5/9/15.
//  Copyright (c) 2015 Matthew DeCoste. All rights reserved.
//

import UIKit

class DayDisplay: UIButton {
	private var normalColor: UIColor {
		get {
			return tintColor!
		}
	}
	private var highlightedColor: UIColor {
		get {
			let comp = CGColorGetComponents(normalColor.CGColor!)
			return UIColor(red: comp[0], green: comp[1], blue: comp[2], alpha: 0.2)
		}
	}
	private var title: String {
		get {
			return DayDisplay.titleStringDate(date)
		}
	}
	
	private func setupLabel() {
		setTitle("Hello", forState: .Normal)
		titleLabel!.font = .boldSystemFontOfSize(17)
		setTitleColor(normalColor, forState: .Normal)
		setTitleColor(highlightedColor, forState: .Highlighted)
	}
	
	var date: NSDate = comparisonDate() {
		didSet {
			setupLabel()
			setTitle(title, forState: .Normal)
			frame.size = NSString(string: titleLabel!.text!).sizeWithAttributes([NSFontAttributeName:titleLabel!.font])
		}
	}
	var dayIndex: Int = 0 {
		didSet {
			date = comparisonDate(daysInFuture: dayIndex)
		}
	}
	
	class func titleString(daysInAdvance: Int) -> String {
		return titleStringDate(comparisonDate(daysInFuture: daysInAdvance))
	}
	
	class func titleStringDate(date: NSDate) -> String {
		var formatter = NSDateFormatter()
		formatter.dateFormat = "MMM"
		let shortMonth = formatter.stringFromDate(date)
		formatter.dateFormat = "MMMM"
		let longMonth = formatter.stringFromDate(date)
		let monthStr = shortMonth == longMonth ? longMonth : "\(shortMonth)."
		
		formatter.dateFormat = "EEEE, "
		let weekday = formatter.stringFromDate(date)
		formatter.dateFormat = "d"
		let day = formatter.stringFromDate(date)
		
		var titleStr = "\(weekday)\(monthStr) \(day)"
		
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