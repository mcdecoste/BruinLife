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
	}
	
	// TODO: REPLACE SOON
	func exampleDay() -> DayInfo {
		var date = NSDate()
		var breakfast = [RestaurantInfo(restName: "Bruin Cafe"),
			RestaurantInfo(restName: "1919"),
			RestaurantInfo(restName: "Rendezvous")]
		var lunch = [RestaurantInfo(restName: "Bruin Cafe"),
			RestaurantInfo(restName: "1919"),
			RestaurantInfo(restName: "Rendezvous")]
		var dinner = [RestaurantInfo(restName: "Bruin Cafe"),
			RestaurantInfo(restName: "1919"),
			RestaurantInfo(restName: "Rendezvous"),
			RestaurantInfo(restName: "Late Night")]
		
		var exampleBreakfast = MealInfo(meal: .Breakfast, rests: breakfast)
//		var exampleBrunch = MealInfo(rests: [])
		var exampleLunch = MealInfo(meal: .Lunch, rests: lunch)
		var exampleDinner = MealInfo(meal: .Dinner, rests: dinner)
		
		return DayInfo(date: date, restForMeal: [exampleBreakfast, exampleLunch, exampleDinner])
	}
}