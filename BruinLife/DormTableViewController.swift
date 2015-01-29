//
//  DormTableViewController.swift
//  BruinLife
//
//  Created by Matthew DeCoste on 11/26/14.
//  Copyright (c) 2014 Matthew DeCoste. All rights reserved.
//

import UIKit

class DormTableViewController: FoodTableViewController {
	var dormCVC: DormContainerViewController?
	
	override func viewDidLoad() {
		super.viewDidLoad()
		setTitle()
		isHall = true
	}
	
	/// Returns the desired title for the page view controller's navbar
	func preferredTitle() -> String {
		var formatter = NSDateFormatter()
		formatter.dateFormat = "EEEE, MMMM d"
		let title = formatter.stringFromDate(information.date)
		
		switch NSCalendar.currentCalendar().component(.DayCalendarUnit, fromDate: information.date) {
		case 1, 21, 31:
			return title + "st"
		case 2, 22:
			return title + "nd"
		case 3, 23:
			return title + "rd"
		default:
			return title + "th"
		}
	}
	
	func setTitle() {
		navigationItem.leftBarButtonItem = pageIndex == 0 ? nil : UIBarButtonItem(title: "Today", style: .Plain, target: dormCVC, action: "jumpToFirst")
		navigationItem.rightBarButtonItem = nil
		navigationItem.title = preferredTitle()
	}
	
	func setInformation(info: DayInfo) {
		information = info
		setTitle()
	}
}
