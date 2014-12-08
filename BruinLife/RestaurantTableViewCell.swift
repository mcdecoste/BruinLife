//
//  RestaurantTableViewCell.swift
//  BruinLife
//
//  Created by Matthew DeCoste on 12/4/14.
//  Copyright (c) 2014 Matthew DeCoste. All rights reserved.
//

import UIKit

class RestaurantTableViewCell: UITableViewCell {
	var information: RestaurantInfo?
	var date: NSDate?

	var backgroundImageView: UIImageView?
	
	var nameLabel = UILabel() // just name of restaurant
	var openLabel = UILabel() // big text: OPEN or CLOSED
	var hoursLabel = UILabel() // "until [close time]" "[open] - [close]"
	
	let saturationFactor = 0.75
	
	override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
		
		
		// put this back in when you have actual photos to use
//		var backImageView = UIImageView(image: information?.image, highlightedImage: lowerSaturation(onImage: information?.image))
//		
//		backImageView.center = center
//		self.backgroundView = backImageView
		
		self.backgroundColor = .blackColor()
		
		// add the labels!
		nameLabel.font = UIFont.systemFontOfSize(30) // 22
		nameLabel.textAlignment = .Left
		nameLabel.textColor = UIColor(white: 1.0, alpha: 0.7)
		
		openLabel.font = UIFont.systemFontOfSize(20) // 14 ()
		openLabel.textAlignment = .Right
		
		hoursLabel.font = UIFont.systemFontOfSize(12) // 9 (11)
		hoursLabel.textAlignment = .Right
		hoursLabel.textColor = UIColor(white: 1.0, alpha: 0.7)
		
		addSubview(nameLabel)
		addSubview(openLabel)
		addSubview(hoursLabel)
    }
	
	/// Preferred method for setting information and date, as this also changes the display
	func changeInfo(info: RestaurantInfo, andDate newDate: NSDate) {
		information = info
		date = newDate
		
		updateDisplay()
	}
	
	func updateDisplay() {
		// fix the frames
		updateLabelFrames()
		
		
		var cal = NSCalendar.currentCalendar()
		var openDate = cal.dateBySettingHour((information?.openTime.hour)!, minute: (information?.openTime.minute)!, second: 0, ofDate: date!, options: NSCalendarOptions())
		var closeDate = cal.dateBySettingHour((information?.closeTime.hour)!, minute: (information?.closeTime.minute)!, second: 0, ofDate: date!, options: NSCalendarOptions())
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
		
		if !open {
			if willOpenToday {
				closedText = "as of \(closeTime)"
			} else {
				closedText = "\(openTime) — \(closeTime)"
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
	
//	func lowerSaturation(onImage image: UIImage?) -> UIImage? {
//		var context = CIContext(options: nil)
//		var ciImage = CIImage(CGImage: image?.CGImage)
//		var filter = CIFilter(name: "CIColorControls")
//		
//		filter.setValue(ciImage, forKey: kCIInputImageKey)
//		filter.setValue(saturationFactor, forKey: kCIInputImageKey)
//		
//		var result = filter.valueForKey(kCIOutputImageKey) as CIImage
//		var cgImage = context.createCGImage(result, fromRect: result.extent())
//		var image = UIImage(CGImage: cgImage)
//		return image!
//	}
	
	override func setSelected(selected: Bool, animated: Bool) {
		super.setSelected(selected, animated: animated)
		
		// some indication that you're looking at this one. Change the color of the title maybe?
	}
	
	override func setHighlighted(highlighted: Bool, animated: Bool) {
		super.setHighlighted(highlighted, animated: animated)
		
		backgroundImageView?.highlighted = highlighted
	}
}
