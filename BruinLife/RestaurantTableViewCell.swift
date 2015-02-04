//
//  RestaurantTableViewCell.swift
//  BruinLife
//
//  Created by Matthew DeCoste on 12/4/14.
//  Copyright (c) 2014 Matthew DeCoste. All rights reserved.
//

import UIKit

class RestaurantTableViewCell: FoodTableViewCell {
	var nameLabel = UILabel() // just name of restaurant
	var openLabel = UILabel() // big text: OPEN or CLOSED
	var hoursLabel = UILabel() // "until [close time]" "[open] - [close]"
	
	override func finishSetup() {
		// add the labels!
		super.finishSetup()
		
		nameLabel.font = .systemFontOfSize(30) // 22
		nameLabel.textAlignment = .Left
		nameLabel.textColor = UIColor(white: 1.0, alpha: 1.0)
		nameLabel.adjustsFontSizeToFitWidth = true
		nameLabel.minimumScaleFactor = 0.8
		nameLabel.baselineAdjustment = .AlignBaselines
		
		openLabel.font = .systemFontOfSize(20) // 14 () // was 20 (14)
		openLabel.textAlignment = .Right
		
		hoursLabel.font = .systemFontOfSize(12) // 9 (11)
		hoursLabel.textAlignment = .Right
		hoursLabel.textColor = UIColor(white: 1.0, alpha: 1.0)
		
		addSubview(nameLabel)
		addSubview(openLabel)
		addSubview(hoursLabel)
	}
	
	override func updateDisplay() {
		// fix the frames
		updateLabelFrames()
		
		var openDate: NSDate?
		var closeDate: NSDate?
		var open = true
		(open, openDate, closeDate) = dateInfo()
		
		var aboutToday = comparisonDate() == comparisonDate(date!)
		var formatter = NSDateFormatter()
		formatter.timeZone = NSTimeZone(name: "Americas/Los_Angeles")
		formatter.timeStyle = .ShortStyle
		formatter.dateStyle = .NoStyle
		
		var openTime = formatter.stringFromDate(openDate!)
		var closeTime = formatter.stringFromDate(closeDate!)
		
		let shouldAbbreviate = true
		
		var openTrunc = openTime
		if shouldAbbreviate {
			openTime.substringFromIndex(advance(openTime.endIndex, -2))
			if openTime.substringFromIndex(advance(openTime.endIndex, -2)) == closeTime.substringFromIndex(advance(closeTime.endIndex, -2)) {
				openTrunc = openTime.substringToIndex(openTime.rangeOfString(" ")!.startIndex)
			}
			
			if let openZeros = openTrunc.rangeOfString(":00") {
				openTrunc = stringByRemovingRange(openTrunc, range: openZeros)
			}
		}
		
		var closeTrunc = closeTime
		if shouldAbbreviate {
			if let closeZeros = closeTrunc.rangeOfString(":00") {
				closeTrunc = stringByRemovingRange(closeTrunc, range: closeZeros)
			}
		}
		
		var openText = "until \(closeTrunc)"
		var closedText = aboutToday && openDate?.timeIntervalSinceNow >= 0 ? "as of \(closeTrunc)" : "\(openTrunc) — \(closeTrunc)"
		
		nameLabel.text = information?.name(isHall)
		
//		openLabel.textColor = open ? UIColor(red: 0.0, green: 0.8, blue: 0.0, alpha: 1.0) : .whiteColor()
		openLabel.textColor = UIColor(red: open ? 0.0 : 0.85, green: open ? 0.8 : 0.0, blue: 0.0, alpha: 1.0)
		openLabel.font = .systemFontOfSize(20) // .systemFontOfSize(open ? 20 : 18) // considered bold for a bit
		openLabel.text = open ? "Open" : "Closed"
		
		hoursLabel.text = open ? openText : closedText
	}
	
	func stringByRemovingRange(string: String, range: Range<String.Index>) -> String {
		return "\(string.substringToIndex(range.startIndex))\(string.substringFromIndex(range.endIndex))"
	}
	
	func updateLabelFrames() {
		let leftIndent: CGFloat = 14.0 // was 16, then 13
		let rightIndent: CGFloat = 16.0
		let openWidth: CGFloat = 120.0
		let nameWidth: CGFloat = frame.width - openWidth - leftIndent - rightIndent
		let openX = frame.width - openWidth - rightIndent
		let nameY = frame.height * 12.5/22.0
		let openY = frame.height * 5.0/11.0
		let hoursY = frame.height * 8.0 / 11.0
		
		let nameHeight = frame.height * (4.0 / 11.0)
		let openHeight = frame.height * (3.0 / 11.0)
		let hoursHeight = frame.height * (2.0 / 11.0)
		
		nameLabel.frame = CGRect(x: leftIndent, y: nameY, width: nameWidth, height: nameHeight)
		openLabel.frame = CGRect(x: openX, y: openY, width: openWidth, height: openHeight)
		hoursLabel.frame = CGRect(x: openX, y: hoursY, width: openWidth, height: hoursHeight)
	}
}
