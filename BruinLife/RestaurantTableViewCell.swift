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
	
	override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
		
		// add the labels!
		nameLabel.font = UIFont.systemFontOfSize(30) // 22
		nameLabel.textAlignment = .Left
		nameLabel.textColor = UIColor(white: 1.0, alpha: 1.0)
		nameLabel.adjustsFontSizeToFitWidth = true
		nameLabel.minimumScaleFactor = 0.8
		nameLabel.baselineAdjustment = .AlignBaselines
		
		openLabel.font = UIFont.systemFontOfSize(20) // 14 ()
		openLabel.textAlignment = .Right
		
		hoursLabel.font = UIFont.systemFontOfSize(12) // 9 (11)
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
		(openDate, closeDate) = openCloseDates()
		var open = openDate?.timeIntervalSinceNow <= 0 && closeDate?.timeIntervalSinceNow >= 0
		var willOpenToday = true
		
		var formatter = NSDateFormatter()
		formatter.timeZone = NSTimeZone(name: "Americas/Los_Angeles")
		formatter.dateFormat = "M/d"
		
		willOpenToday = formatter.stringFromDate(NSDate()) == formatter.stringFromDate(date!)
		
		formatter.dateFormat = "h:mm a"
		
		
		var openTime = formatter.stringFromDate(openDate!)
		var closeTime = formatter.stringFromDate(closeDate!)
		
		var openText = "until \(closeTime)"
		var closedText = "until \(openTime)"
		
		if openDate?.timeIntervalSinceNow >= 0 { // still to open
			closedText = "\(openTime) — \(closeTime)" // gives more information this way
		} else { // was open, now is closed
			if willOpenToday {
				closedText = "as of \(closeTime)"
			} else {
				closedText = "\(openTime) — \(closeTime)" // should never happen
			}
		}
		
		nameLabel.text = information?.name
		
		openLabel.textColor = open ? .greenColor() : .redColor()
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
