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
	
	/// Returns the desired title for the page view controller's navbar
	var preferredTitle: String {
		get {
			var formatter = NSDateFormatter()
			formatter.dateFormat = compact() ? "EEEE, MMM. d" : "EEEE, MMMM d"
			var title = formatter.stringFromDate(information.date)
			
			switch NSCalendar.currentCalendar().component(.CalendarUnitDay, fromDate: information.date) {
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
	
	override func viewDidLoad() {
		super.viewDidLoad()
		isHall = true
	}
	
	override func viewDidAppear(animated: Bool) {
		super.viewDidAppear(animated)
		dormCVC?.updateNavItem(self)
	}
	
	override func viewWillAppear(animated: Bool) {
		super.viewWillAppear(animated)
		NSNotificationCenter.defaultCenter().addObserver(self, selector: "handleDataChange:", name: "NewDayInfoAdded", object: nil)
	}
	
	override func viewWillDisappear(animated: Bool) {
		super.viewWillDisappear(animated)
		NSNotificationCenter.defaultCenter().removeObserver(self)
	}
	
	override func numberOfSectionsInTableView(tableView: UITableView) -> Int {
		return hasData ? information.meals.count - 1 : 1
	}
	
	override func handleDataChange(notification: NSNotification) {
		if notification.name == "NewDayInfoAdded" {
			let dDay = notification.userInfo!["newItem"] as! DiningDay
			
			if dDay.day == information.date {
				informationData = dDay.data
				//				(tableView.visibleCells() as! [EmptyTableViewCell]).first!.loadState = loadState
			}
		}
	}
	
	override func scrollToMeal() {
		if representsToday(information.date) {
			var currMeal = currentMeal()
			if currMeal == .LateNight {
				return
			}
			
			var sectionToShow = 0
			
			for (index, meal) in enumerate(orderedMeals(information.meals.keys.array)) {
				if meal.equalTo(currMeal) {
					sectionToShow = index
					break
				}
			}
			tableView.scrollToRowAtIndexPath(NSIndexPath(forRow: 0, inSection: sectionToShow), atScrollPosition: .Top, animated: true)
		}
	}
}
