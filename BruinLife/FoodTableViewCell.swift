//
//  FoodTableViewCell.swift
//  BruinLife
//
//  Created by Matthew DeCoste on 12/8/14.
//  Copyright (c) 2014 Matthew DeCoste. All rights reserved.
//

import UIKit

class FoodTableViewCell: UITableViewCell {
	var brief: RestaurantBrief?
	var date: NSDate?
	var foodVC: FoodTableViewController?
	var backgroundImageView: UIImageView?
	var isHall: Bool = true
	
	var open: Bool {
		get {
			return dateInfo.open
		}
	}
	
	var dateInfo: (open: Bool, openDate: NSDate?, closeDate: NSDate?) {
		get {
			if let info = brief, useDate = isHall ? date : NSDate() {
				let open1 = info.openTime.timeDateForDate(useDate)
				let close1 = info.closeTime.timeDateForDate(useDate)
				
				let diffDate = comparisonDate(daysInFuture(useDate)-1)
				let open2 = info.openTime.timeDateForDate(diffDate)
				let close2 = info.closeTime.timeDateForDate(diffDate)
				
				let result1 = open1.timeIntervalSinceNow <= 0 && close1.timeIntervalSinceNow >= 0
				let result2 = open2.timeIntervalSinceNow <= 0 && close2.timeIntervalSinceNow >= 0
				let isOpen = result1 || (!isHall && result2)
				return (isOpen, open1, close1)
			}
			return (false, nil, nil)
		}
	}
	
	override init(style: UITableViewCellStyle, reuseIdentifier: String?) {
		super.init(style: style, reuseIdentifier: reuseIdentifier)
		finishSetup()
	}
	
	required init(coder aDecoder: NSCoder) {
		super.init(coder: aDecoder)
		finishSetup()
	}
	
    func finishSetup() {
		backgroundImageView = UIImageView(frame: CGRectZero)
		addSubview(backgroundImageView!)
		clipsToBounds = true
    }
	
	/// Preferred method for setting information and date, as this also changes the display
	func changeInfo(info: RestaurantBrief, andDate date: NSDate, isHall: Bool) {
		self.brief = info
		self.date = isHall ? date : comparisonDate()
		self.isHall = isHall
		
		let imageIndex = (subviews as NSArray).indexOfObject(backgroundImageView!)
		
		backgroundImageView?.removeFromSuperview()
		backgroundImageView = UIImageView(image: ImageProvider.sharedInstance.image(brief!.hall, open: open))
		parallaxImageWithScrollPercent(0.0)
		backgroundImageView?.contentMode = .ScaleAspectFill
		
		insertSubview(backgroundImageView!, atIndex: imageIndex)
		
		updateDisplay()
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
