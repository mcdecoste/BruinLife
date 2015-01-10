//
//  FoodTableViewCell.swift
//  BruinLife
//
//  Created by Matthew DeCoste on 12/8/14.
//  Copyright (c) 2014 Matthew DeCoste. All rights reserved.
//

import UIKit

class FoodTableViewCell: UITableViewCell {
	var information: RestaurantInfo?
	var date: NSDate?
	var foodVC: FoodTableViewController?
	var backgroundImageView: UIImageView?
	var isHall: Bool = true
	
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
		backgroundImageView = UIImageView(frame: CGRectZero)
		addSubview(backgroundImageView!)
		clipsToBounds = true
    }
	
	/// Preferred method for setting information and date, as this also changes the display
	func changeInfo(info: RestaurantInfo, andDate date: NSDate, isHall: Bool) {
		self.information = info
		self.date = date
		self.isHall = isHall
		
		var imageIndex = (subviews as NSArray).indexOfObject(backgroundImageView!)
		
		backgroundImageView?.removeFromSuperview()
		
		backgroundImageView = UIImageView(image: UIImage(named: (information?.imageName(open()))!))
		parallaxImageWithScrollPercent(0.0)
		backgroundImageView?.contentMode = .ScaleAspectFill
		
		insertSubview(backgroundImageView!, atIndex: imageIndex)
		
		updateDisplay()
	}
	
	func dateInfo() -> (open: Bool, openDate: NSDate?, closeDate: NSDate?) {
		var openDate1 = information?.openTime.timeDateForDate(date)
		var closeDate1 = information?.closeTime.timeDateForDate(date)
		
		let diff = (daysInFuture(date!)-1) * timeInDay
		var openDate2 = information?.openTime.timeDateForDate(date?.dateByAddingTimeInterval(diff))
		var closeDate2 = information?.closeTime.timeDateForDate(date?.dateByAddingTimeInterval(diff))
		
		var open1 = (openDate1?.timeIntervalSinceNow <= 0 && closeDate1?.timeIntervalSinceNow >= 0)
		var open2 = (openDate2?.timeIntervalSinceNow <= 0 && closeDate2?.timeIntervalSinceNow >= 0)
		var open = open1 || open2
		return (open, openDate1, closeDate1)
	}
	
	func open() -> Bool {
		return dateInfo().open
	}
	
	func parallaxImageWithScrollPercent(perc: CGFloat) {
		let parallaxCoeff: CGFloat = 0.5
		
		var percentage: CGFloat = perc
		if perc < 0.0 { percentage = 0.0 }
		if perc > 1.0 { percentage = 1.0 }
		
		let displayHeight:CGFloat = 220.0
		var cellHeight: CGFloat = bounds.height
		
		var startPoint: CGFloat = 0.0
		var diff: CGFloat = parallaxCoeff * percentage * (displayHeight - cellHeight)
		
		backgroundImageView?.frame.origin.y = startPoint - diff
	}
	
	func updateDisplay() {}
}
