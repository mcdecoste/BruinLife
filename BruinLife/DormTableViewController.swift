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
		isHall = true
	}
	
	override func viewDidAppear(animated: Bool) {
		super.viewDidAppear(animated)
		dormCVC?.updateNavItem(self)
	}
	
	/// Returns the desired title for the page view controller's navbar
	func preferredTitle() -> String {
		var formatter = NSDateFormatter()
		formatter.dateFormat = compact() ? "EEEE, MMM. d" : "EEEE, MMMM d"
		var title = formatter.stringFromDate(information.date)
		
		switch NSCalendar.currentCalendar().component(.DayCalendarUnit, fromDate: information.date) {
		case 1, 21, 31:
			title += "st"
		case 2, 22:
			title += "nd"
		case 3, 23:
			title += "rd"
		default:
			title += "th"
		}
		return title
	}
}
