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
	
//	var name: NSString = ""
//	var backgroundImage: UIImage?
	var backgroundImageView: UIImageView?
	
	
//	var openDate: NSDate?
//	var closeDate: NSDate?
	
	var nameLabel: UILabel? // just name of restaurant
	var openLabel: UILabel? // big text: OPEN or CLOSED
	var hoursLabel: UILabel? // "until [close time]" "[open] - [close]"
	
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
		nameLabel = UILabel(frame: CGRect(x: 0.0, y: frame.height - 48, width: 220, height: 40))
		nameLabel?.text = information?.name
		nameLabel?.textAlignment = .Left
		nameLabel?.textColor = UIColor(white: 1.0, alpha: 0.7)
		
		let openWidth: CGFloat = 80
		openLabel = UILabel(frame: CGRect(x: (frame.width - openWidth), y: (frame.height * 2.0 / 11.0), width: openWidth, height: (frame.height * 3.0 / 11.0)))
		openLabel?.font = UIFont.systemFontOfSize(30)
		openLabel?.textAlignment = .Center
		
		hoursLabel = UILabel(frame: CGRect(x: (frame.width - openWidth), y: (frame.height * 6.0 / 11.0), width: openWidth, height: (frame.height * 3.0 / 11.0)))
		hoursLabel?.font = UIFont.systemFontOfSize(24)
		hoursLabel?.textAlignment = .Center
		hoursLabel?.textColor = UIColor(white: 1.0, alpha: 0.7)
		
		addSubview(nameLabel!)
		addSubview(openLabel!)
		addSubview(hoursLabel!)
    }
	
	func isOpen() -> (Bool, Bool, NSDate?, NSDate?) {
		var cal = NSCalendar.currentCalendar()
		var openDate = cal.dateBySettingHour((information?.openTime?.hour)!, minute: (information?.openTime?.minute)!, second: 0, ofDate: date!, options: nil)
		var closeDate = cal.dateBySettingHour((information?.closeTime?.hour)!, minute: (information?.closeTime?.minute)!, second: 0, ofDate: date!, options: nil)
		var openNow = openDate?.timeIntervalSinceNow >= 0 && closeDate?.timeIntervalSinceNow <= 0
		var opensLater = openDate?.timeIntervalSinceNow <= 0
		return (openNow, opensLater, openDate, closeDate)
	}
	
	func updateDisplay() {
		var openDate: NSDate?
		var closeDate: NSDate?
		var open: Bool = false
		var willOpen: Bool = false
		(open, willOpen, openDate, closeDate) = isOpen()
		
		var formatter = NSDateFormatter()
		formatter.dateFormat = "H:m a"
		
		openLabel?.textColor = open ? .greenColor() : .redColor()
		openLabel?.text = open ? "Open" : "Closed"
		
		var openText = "until " + formatter.stringFromDate(closeDate!)
		var closedText = willOpen ? "until " + formatter.stringFromDate(openDate!) : "at " + formatter.stringFromDate(closeDate!)
		hoursLabel?.text = open ? openText : closedText
	}
	
	func lowerSaturation(onImage image: UIImage?) -> UIImage? {
		var context = CIContext(options: nil)
		var ciImage = CIImage(CGImage: image?.CGImage)
		var filter = CIFilter(name: "CIColorControls")
		
		filter.setValue(ciImage, forKey: kCIInputImageKey)
		filter.setValue(saturationFactor, forKey: kCIInputImageKey)
		
		var result = filter.valueForKey(kCIOutputImageKey) as CIImage
		var cgImage = context.createCGImage(result, fromRect: result.extent())
		var image = UIImage(CGImage: cgImage)
		return image!
	}
	
	override func setSelected(selected: Bool, animated: Bool) {
		super.setSelected(selected, animated: animated)
		
		// some indication that you're looking at this one. Change the color of the title maybe?
	}
	
	override func setHighlighted(highlighted: Bool, animated: Bool) {
		super.setHighlighted(highlighted, animated: animated)
		
		backgroundImageView?.highlighted = highlighted
	}
}
