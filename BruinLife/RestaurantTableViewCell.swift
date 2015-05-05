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
		
		var (open, openDate, closeDate) = dateInfo
		let aboutToday = comparisonDate() == comparisonDate(date!)
		var formatter = NSDateFormatter()
		formatter.timeZone = NSTimeZone(name: "Americas/Los_Angeles")
		formatter.timeStyle = .ShortStyle
		
		var openTime = formatter.stringFromDate(openDate!).stringByReplacingOccurrencesOfString(":00", withString: "")
		var closeTime = formatter.stringFromDate(closeDate!).stringByReplacingOccurrencesOfString(":00", withString: "")
		
		var openText = "until \(closeTime)"
		var closedText = aboutToday && openDate?.timeIntervalSinceNow < 0 ? "as of \(closeTime)" : "\(openTime) — \(closeTime)"
		if openDate == closeDate {
			closedText = "Not open today"
		}
		
		nameLabel.text = brief?.name(isHall)
		openLabel.textColor = UIColor(red: open ? 0.0 : 0.85, green: open ? 0.8 : 0.0, blue: 0.0, alpha: 1.0)
		openLabel.font = .systemFontOfSize(20)
		openLabel.text = open ? "Open" : "Closed"
		hoursLabel.text = open ? openText : closedText
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
