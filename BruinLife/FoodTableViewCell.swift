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
		let aboutToday = comparisonDate() == comparisonDate(date: date!)
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

class MenuTableViewCell: FoodTableViewCell {
	var collectionView: UICollectionView?
	var blurView = UIVisualEffectView(effect: UIBlurEffect(style: .Light))
	
	override func finishSetup() {
		// add the labels!
		super.finishSetup()
		
		collectionView = UICollectionView(frame: CGRectZero, collectionViewLayout: VerticalFlow())
		collectionView?.registerClass(FoodCollectionViewCell.self, forCellWithReuseIdentifier: "foodDisplay")
		collectionView?.registerClass(SectionCollectionReusableView.self, forSupplementaryViewOfKind: UICollectionElementKindSectionHeader, withReuseIdentifier: "headerCell")
		collectionView?.backgroundView = blurView
		collectionView?.backgroundColor = .clearColor()
		collectionView?.alwaysBounceVertical = true
		
		addSubview(collectionView!)
	}
	
	override func updateDisplay() {
		// do things to update the display for the new brief
		backgroundImageView?.frame = bounds // CGRectMake(0, -1, bounds.width, bounds.height + 2)
		backgroundImageView?.clipsToBounds = true
		
		if collectionView?.frame == CGRectZero {
			collectionView?.frame = bounds
		}
		(collectionView?.collectionViewLayout as! VerticalFlow).updateForCollectionSize()
		collectionView?.reloadData()
		
		blurView.frame = bounds
	}
	
	/// Preferred method for setting brief and date, as this also changes the display
	override func changeInfo(info: RestaurantBrief, andDate date: NSDate, isHall: Bool) {
		self.brief = info
		self.date = date
		self.isHall = isHall
		
		let imageIndex = (subviews as NSArray).indexOfObject(backgroundImageView!)
		
		backgroundImageView?.removeFromSuperview()
		backgroundImageView = UIImageView(image: ImageProvider.sharedInstance.image(brief!.hall, open: open))
		parallaxImageWithScrollPercent(0.0)
		backgroundImageView?.contentMode = .ScaleAspectFill // UIViewContentMode.ScaleToFill // .ScaleAspectFill
		
		insertSubview(backgroundImageView!, atIndex: imageIndex)
		
		updateDisplay()
	}
}
