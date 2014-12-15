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
		
		let bOpen = Time(hour: 7, minute: 0, pm: false)
		let bClose = Time(hour: 11, minute: 0, pm: false)
		
		let lOpen = Time(hour: 11, minute: 0, pm: false) // 11
		let lClose = Time(hour: 2, minute: 0, pm: true)
		
		let dOpen = Time(hour: 5, minute: 0, pm: true)
		let dClose = Time(hour: 8, minute: 0, pm: true)
		
		let nOpen = Time(hour: 9, minute: 0, pm: true)
		let nClose = Time(hour: 2, minute: 0, pm: false, nextDay: true) // 2 AM, the next morning
		
		var breakfast = [RestaurantInfo(name: "Bruin Cafe", hall: .BruinCafe, openTime: bOpen, closeTime: bClose), RestaurantInfo(name: "Rendezvous", hall: .Rendezvous, openTime: bOpen, closeTime: bClose)]
		var lunch = [RestaurantInfo(name: "Bruin Cafe", hall: .BruinCafe, openTime: lOpen, closeTime: lClose), RestaurantInfo(name: "Cafe 1919", hall: .Cafe1919, openTime: lOpen, closeTime: lClose), RestaurantInfo(name: "Rendezvous", hall: .Rendezvous, openTime: lOpen, closeTime: lClose)]
		var dinner = [RestaurantInfo(name: "Bruin Cafe", hall: .BruinCafe, openTime: dOpen, closeTime: dClose), RestaurantInfo(name: "Cafe 1919", hall: .Cafe1919, openTime: dOpen, closeTime: dClose), RestaurantInfo(name: "Rendezvous", hall: .Rendezvous, openTime: dOpen, closeTime: dClose)]
		var lateNight = [RestaurantInfo(name: "Bruin Cafe", hall: .BruinCafe, openTime: nOpen, closeTime: nClose), RestaurantInfo(name: "Late Night", hall: .DeNeve, openTime: nOpen, closeTime: nClose), RestaurantInfo(name: "Night Hedrick", hall: .Hedrick, openTime: nOpen, closeTime: nClose)]
		
		var exampleBreakfast = MealInfo(meal: .Breakfast, rests: breakfast)
		var exampleLunch = MealInfo(meal: .Lunch, rests: lunch)
		var exampleDinner = MealInfo(meal: .Dinner, rests: dinner)
		var exampleLateNight = MealInfo(meal: .LateNight, rests: lateNight)
		
		return DayInfo(date: date, restForMeal: [exampleBreakfast, exampleLunch, exampleDinner, exampleLateNight])
	}
}