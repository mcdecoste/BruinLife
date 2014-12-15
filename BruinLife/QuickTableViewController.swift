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
		
		var breakfast = [RestaurantInfo(name: "Bruin Cafe", hall: .BruinCafe), RestaurantInfo(name: "Cafe 1919", hall: .Cafe1919), RestaurantInfo(name: "Rendezvous", hall: .Rendezvous)]
		var lunch = [RestaurantInfo(name: "Bruin Cafe", hall: .BruinCafe), RestaurantInfo(name: "Cafe 1919", hall: .Cafe1919), RestaurantInfo(name: "Rendezvous", hall: .Rendezvous)]
		var dinner = [RestaurantInfo(name: "Bruin Cafe", hall: .BruinCafe), RestaurantInfo(name: "Cafe 1919", hall: .Cafe1919), RestaurantInfo(name: "Rendezvous", hall: .Rendezvous), RestaurantInfo(name: "Late Night", hall: .DeNeve), RestaurantInfo(name: "Night Hedrick", hall: .Hedrick)]
		
		var exampleBreakfast = MealInfo(meal: .Breakfast, rests: breakfast)
		var exampleLunch = MealInfo(meal: .Lunch, rests: lunch)
		var exampleDinner = MealInfo(meal: .Dinner, rests: dinner)
		
		return DayInfo(date: date, restForMeal: [exampleBreakfast, exampleLunch, exampleDinner])
	}
}