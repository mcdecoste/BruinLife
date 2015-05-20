//
//  QuickTableViewController.swift
//  BruinLife
//
//  Created by Matthew DeCoste on 11/26/14.
//  Copyright (c) 2014 Matthew DeCoste. All rights reserved.
//

import UIKit

class QuickTableViewController: FoodTableViewController {
	override var isHall: Bool {
		get {
			return false
		}
	}
	
	override func viewDidLoad() {
		super.viewDidLoad()
		self.navigationItem.title = "Quick Service"
		
		getTheData()
	}
	
	override func viewWillAppear(animated: Bool) {
		super.viewWillAppear(animated)
		
		NSNotificationCenter.defaultCenter().addObserver(self, selector: "handleDataChange:", name: "QuickInfoUpdated", object: nil)
		
		if !hasData && loadState != .Loading {
			getTheData()
		}
	}
	
	func getTheData() {
		let currentData = CloudManager.sharedInstance.quickData
		if currentData.length > 0 {
			informationData = currentData
			// check for updates anyways (we don't care if this fails)
			CloudManager.sharedInstance.fetchQuickRecord({ (error) -> Void in return })
		} else {
			// load for the first time
			loadState = .Loading
			CloudManager.sharedInstance.fetchQuickRecord({ (error) -> Void in
				println(error)
				self.loadState = .Failed
			})
		}
	}
	
	override func retryLoad() {
		loadState = .Loading
		tableView.reloadData()
		getTheData()
	}
	
	override func handleDataChange(notification: NSNotification) {
		if notification.name == "QuickInfoUpdated" {
			let dDay = notification.userInfo!["quickInfo"] as! QuickMenu
			informationData = dDay.data
			CloudManager.sharedInstance.save()
		}
	}
	
	override func setInformationIfNeeded() {
		if !hasData && informationData.length != 0 {
			var quickError: NSError?
			if let quickDict = NSJSONSerialization.JSONObjectWithData(informationData, options: .allZeros, error: nil) as? Dictionary<String, AnyObject> {
				let quickBrief = DayBrief(dict: quickDict)
				
				// grab the hours information from the dining side!
				let dayData = CloudManager.sharedInstance.fetchDiningDay(NSDate())
				if dayData.length > 0 {
					// we have info to use
					var dayError: NSError?
					if let dayDict = NSJSONSerialization.JSONObjectWithData(dayData, options: .allZeros, error: nil) as? Dictionary<String, AnyObject> {
						let dayBrief = DayBrief(dict: dayDict)
						
						for (meal, mealBrief) in dayBrief.meals {
							for (hall, hallBrief) in mealBrief.halls {
								if find(Halls.allQuickServices, hall) != nil {
									var mealToUse = meal == .Brunch ? .Lunch : meal
									
									quickBrief.meals[mealToUse]?.halls[hall]?.openTime = hallBrief.openTime
									quickBrief.meals[mealToUse]?.halls[hall]?.closeTime = hallBrief.closeTime
								}
							}
						}
					} else {
						println(dayError)
					}
				}
				
				if !isHall {
					information.date = comparisonDate()
				}
				
				information = quickBrief
			} else {
				println(quickError)
			}
		}
	}
}