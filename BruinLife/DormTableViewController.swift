//
//  DormTableViewController.swift
//  BruinLife
//
//  Created by Matthew DeCoste on 11/26/14.
//  Copyright (c) 2014 Matthew DeCoste. All rights reserved.
//

import UIKit

class DormTableViewController: FoodTableViewController {
	var selectedDate = NSDate()
	
	let dateConversionFormat = "EEE. M/d" // "MMM. d" "M/d"
	let dateVCid = "dateSelectionTableView"
	
	override func viewDidLoad() {
		super.viewDidLoad()
		
		self.navigationItem.title = "Dining Halls"
		
		dataArray = [	RestaurantInfo(restName: "De Neve"),
						RestaurantInfo(restName: "Covel"),
						RestaurantInfo(restName: "Feast"),
						RestaurantInfo(restName: "Hedrick"),
						RestaurantInfo(restName: "Sproul")		]
		
		self.navigationItem.leftBarButtonItem = UIBarButtonItem(title: dateButtonTitle(), style: .Plain, target: self, action: "addDatePopover:") // showDatePopover
	}
	
	func dateButtonTitle() -> String {
		var formatter = NSDateFormatter()
		formatter.dateFormat = dateConversionFormat
		return formatter.stringFromDate(selectedDate)
	}
	
	func setNewDate(newDate: NSDate) {
		selectedDate = newDate
		self.navigationItem.leftBarButtonItem?.title = dateButtonTitle()
	}
	
	func addDatePopover(sender: UIBarButtonItem?){
		var dateVC = storyboard?.instantiateViewControllerWithIdentifier(dateVCid) as DateSelectionTableViewController
		
		dateVC.dormVC = self
		dateVC.setDate(selectedDate)
		
		dateVC.modalPresentationStyle = .Popover
		dateVC.preferredContentSize = dateVC.preferredContentSize
		
		let popoverPresentationViewController = dateVC.popoverPresentationController
		popoverPresentationViewController?.permittedArrowDirections = .Up
		popoverPresentationViewController?.delegate = self
		popoverPresentationViewController?.barButtonItem = sender
		presentViewController(dateVC, animated: true, completion: nil)
	}
	
	override func addMealPopover(sender: UIBarButtonItem?){
		var mealVC = storyboard?.instantiateViewControllerWithIdentifier(mealVCid) as MealSelectionTableViewController
		
		mealVC.foodVC = self
		mealVC.meal = currMeal
		mealVC.setDate(selectedDate)
		mealVC.isDorm = true
		
		mealVC.modalPresentationStyle = .Popover
		mealVC.preferredContentSize = mealVC.preferredContentSize
		
		let popoverPresentationViewController = mealVC.popoverPresentationController
		popoverPresentationViewController?.permittedArrowDirections = .Up
		popoverPresentationViewController?.delegate = self
		popoverPresentationViewController?.barButtonItem = sender
		presentViewController(mealVC, animated: true, completion: nil)
	}
}
