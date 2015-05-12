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
	
	var preferredTitleView: DayDisplay {
		get {
			var pref = DayDisplay()
			pref.date = information.date
			return pref
		}
	}
	
	override func viewDidLoad() {
		super.viewDidLoad()
	}
	
	override func viewDidAppear(animated: Bool) {
		super.viewDidAppear(animated)
		dormCVC?.updateNavItem(self)
	}
	
	override func viewWillAppear(animated: Bool) {
		super.viewWillAppear(animated)
		NSNotificationCenter.defaultCenter().addObserver(self, selector: "handleDataChange:", name: "NewDayInfoAdded", object: nil)
		NSNotificationCenter.defaultCenter().addObserver(self, selector: "handleDataChange:", name: "DayInfoUpdated", object: nil)
	}
	
	override func numberOfSectionsInTableView(tableView: UITableView) -> Int {
		return hasData ? information.meals.count - 1 : 1
	}
	
	override func handleDataChange(notification: NSNotification) {
		switch notification.name {
		case "NewDayInfoAdded":
			let dDay = notification.userInfo!["newItem"] as! DiningDay
			if dDay.day == information.date {
				informationData = dDay.data
			}
		case "DayInfoUpdated":
			let dDay = notification.userInfo!["updatedItem"] as! DiningDay
			if dDay.day == information.date {
				informationData = dDay.data
			}
		default:
			break
		}
	}
	
	override func scrollToMeal() {
		if currCal.isDateInToday(information.date) {
			var currMeal = currentMeal
			if currMeal == .LateNight {
				return
			}
			
			var sectionToShow = 0
			
			for (index, meal) in enumerate(dateMeals) {
				if meal.equalTo(currMeal) {
					sectionToShow = index
					break
				}
			}
			tableView.scrollToRowAtIndexPath(NSIndexPath(forRow: 0, inSection: sectionToShow), atScrollPosition: .Top, animated: true)
		}
	}
}
