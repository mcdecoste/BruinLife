//
//  QuickTableViewController.swift
//  BruinLife
//
//  Created by Matthew DeCoste on 11/26/14.
//  Copyright (c) 2014 Matthew DeCoste. All rights reserved.
//

import UIKit

class QuickTableViewController: FoodTableViewController {
	override func viewDidLoad() {
		super.viewDidLoad()
		self.navigationItem.title = "Quick Service"
		
		information = exampleDay()
		dateMeals = orderedMeals(Array(information.meals.keys))
		isHall = false	
	}
	
	// TODO: REPLACE SOON
	func exampleDay() -> DayInfo {
		var date = NSDate()
		
		var breakfast = exampleDayHelper([.BruinCafe, .Rendezvous], open: Time(hour: 7, minute: 0), close: Time(hour: 11, minute: 0))
		var lunch = exampleDayHelper([.BruinCafe, .Rendezvous, .Cafe1919], open: Time(hour: 11, minute: 0), close: Time(hour: 14, minute: 0))
		var dinner = exampleDayHelper([.BruinCafe, .Rendezvous, .Cafe1919], open: Time(hour: 17, minute: 0), close: Time(hour: 20, minute: 0))
		var lateNight = exampleDayHelper([.BruinCafe, .DeNeve, .Hedrick], open: Time(hour: 21, minute: 0), close: Time(hour: 26, minute: 0))
		
		return DayInfo(date: date, meals: [.Breakfast : breakfast, .Lunch : lunch, .Dinner : dinner, .LateNight : lateNight])
	}
	
	/// helper method for showing example day
	func exampleDayHelper(halls: Array<Halls>, open: Time, close: Time) -> MealInfo {
		var meal: Dictionary<Halls, RestaurantInfo> = Dictionary()
		for hall in halls { meal[hall] = RestaurantInfo(hall: hall) }
		
		var mealInfo = MealInfo(halls: meal)
		for key in mealInfo.halls.keys {
			mealInfo.halls[key]?.openTime = open
			mealInfo.halls[key]?.closeTime = close
			
			var section1 = SectionInfo(name: "Entrees")
			section1.foods = defaultFoods()
			var section2 = SectionInfo(name: "Tea Latte & Cookies")
			section2.foods = defaultFoods()
			mealInfo.halls[key]?.sections = [section1, section2]
		}
		
		return mealInfo
	}
}