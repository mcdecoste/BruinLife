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
	}
	
	override func viewWillAppear(animated: Bool) {
		super.viewWillAppear(animated)
		
		NSNotificationCenter.defaultCenter().addObserver(self, selector: "handleDataChange:", name: "QuickInfoUpdated", object: nil)
		
		let currentData = CloudManager.sharedInstance.quickData
		if currentData.length > 0 {
			informationData = currentData
		} else {
			CloudManager.sharedInstance.fetchQuickRecord()
		}
	}
	
	override func handleDataChange(notification: NSNotification) {
		if notification.name == "QuickInfoUpdated" {
			let dDay = notification.userInfo!["quickInfo"] as! QuickMenu
			informationData = dDay.data
		}
	}
	
	override func setInformationIfNeeded() {
		if !hasData && informationData.length != 0 {
			var quickBrief = DayBrief(dict: NSJSONSerialization.JSONObjectWithData(informationData, options: .allZeros, error: nil) as! Dictionary<String, AnyObject>)
			
			// grab the hours information from the dining side!
			let dayData = CloudManager.sharedInstance.fetchDiningDay(NSDate())
			if dayData.length > 0 {
				// we have info to use
				let dayBrief = DayBrief(dict: NSJSONSerialization.JSONObjectWithData(dayData, options: .allZeros, error: nil) as! Dictionary<String, AnyObject>)
				
				for (meal, mealBrief) in dayBrief.meals {
					for (hall, hallBrief) in mealBrief.halls {
						if find(Halls.allQuickServices, hall) != nil {
							var mealToUse = meal == .Brunch ? .Lunch : meal
							
							quickBrief.meals[mealToUse]?.halls[hall]?.openTime = hallBrief.openTime
							quickBrief.meals[mealToUse]?.halls[hall]?.closeTime = hallBrief.closeTime
						}
					}
				}
			}
			
			if !isHall {
				information.date = comparisonDate()
			}
			
			information = quickBrief
		}
	}
}