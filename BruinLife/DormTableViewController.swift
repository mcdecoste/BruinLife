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
		
		information = exampleDay()
		dateMeals = orderedMeals(Array(information.meals.keys))
		setTitle()
		
		isHall = true
	}
	
	/// Returns the desired title for the page view controller's navbar
	func preferredTitle() -> String {
		var formatter = NSDateFormatter()
		
		let dateFormat = "EEEE, MMMM d"
		let dayFormat = "d"
		let suffixes = ["th", "st", "nd", "rd"]
		
		formatter.dateFormat = dayFormat
		var day = formatter.stringFromDate(information.date)
		var dayIndex = NSString(string: day).integerValue
		if dayIndex > 3 {
			dayIndex = 0
		}
		
		formatter.dateFormat = dateFormat
		var title = formatter.stringFromDate(information.date)
		
		return title + suffixes[dayIndex]
	}
	
	func setTitle() {
		var leftButton: UIBarButtonItem? = nil
		if (pageIndex != 0) {
			leftButton = UIBarButtonItem(title: "Today", style: .Plain, target: dormCVC, action: "jumpToFirst")
		}
		
		navigationItem.leftBarButtonItem = leftButton
		navigationItem.rightBarButtonItem = nil
		
		navigationItem.title = preferredTitle()
	}
	
	func setInformation(info: DayInfo) {
		information = info
		setTitle()
	}
}
