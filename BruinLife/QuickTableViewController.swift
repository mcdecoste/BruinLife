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
			CloudManager.sharedInstance.downloadQuickRecord({ (error) -> Void in return })
		} else {
			// load for the first time
			loadState = .Loading
			CloudManager.sharedInstance.downloadQuickRecord({ (error) -> Void in
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
			if let quickDict = deserializedOpt(informationData) {
				let quickBrief = DayBrief(dict: quickDict)
				
				// grab the hours information from the dining side!
				if let dayData = CloudManager.sharedInstance.diningDay(NSDate())?.data where dayData.length > 0 {
					// we have info to use
					if let dayDict = deserializedOpt(dayData) {
						for (meal, mealBrief) in DayBrief(dict: dayDict).meals {
							for (hall, hallBrief) in mealBrief.halls {
								if find(Halls.allQuickServices, hall) != nil {
									var mealToUse = meal == .Brunch ? .Lunch : meal
									
									quickBrief.meals[mealToUse]?.halls[hall]?.openTime = hallBrief.openTime
									quickBrief.meals[mealToUse]?.halls[hall]?.closeTime = hallBrief.closeTime
								}
							}
						}
					}
				}
				
				if !isHall {
					quickBrief.date = comparisonDate()
				}
				
				information = quickBrief
			}
		}
	}
}