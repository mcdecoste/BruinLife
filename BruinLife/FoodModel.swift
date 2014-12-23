//
//  FoodModel.swift
//  BruinLife
//
//  Created by Matthew DeCoste on 12/15/14.
//  Copyright (c) 2014 Matthew DeCoste. All rights reserved.
//

import UIKit

struct Time {
	var hour: Int
	var minute: Int
	
	/// give hour in 24 hour notation (can be more than 24 hours if past midnight)
	init(hour: Int, minute: Int) {
		self.hour = hour
		self.minute = minute
	}
	
	func timeDateForDate(dayDate: NSDate?) -> NSDate? {
		// set dayDate back to midnight
		var midnight = NSCalendar.currentCalendar().dateBySettingHour(0, minute: 0, second: 0, ofDate: dayDate!, options: NSCalendarOptions())
		
		// add in the necessary time
		var interval = 3600.0 * Double(hour) + 60 * Double(minute)
		return midnight?.dateByAddingTimeInterval(interval)
	}
}

enum Halls: String {
	case DeNeve = "De Neve"
	case Covel = "Covel"
	case Hedrick = "Hedrick"
	case Feast = "Feast"
	case BruinPlate = "Bruin Plate"
	case Cafe1919 = "Cafe 1919"
	case Rendezvous = "Rendezvous"
	case BruinCafe = "Bruin Cafe"
	
	func image(open: Bool) -> UIImage? {
		return UIImage(named: (self.rawValue + (open ? " Dark" : " BW")))
	}
}

struct DayInfo {
	var date = NSDate()
	var restForMeal: Array<MealInfo> = []
}

struct MealInfo {
	var meal: MealType = .Lunch
	var rests: Array<RestaurantInfo> = []
}

struct RestaurantInfo {
	var name: String = ""
	var hall: Halls = .DeNeve
	
	var openTime: Time = Time(hour: 8, minute: 0)
	var closeTime: Time = Time(hour: 17, minute: 0)
	
	var foods: Array<FoodInfo> = [FoodInfo(name: "Thai Tea"), FoodInfo(name: "Sushi Bowl"), FoodInfo(name: "Angel Hair Pasta"), FoodInfo(name: "Turkey Burger"), FoodInfo(name: "Carne Asada Fries"), FoodInfo(name: "Barbeque Chicken Quesadilla"), FoodInfo(name: "Yogurt"), FoodInfo(name: "Pepperoni Pizza"), FoodInfo(name: "Chocolate Shake with Oreo")]
	
	init(name: String, hall: Halls) {
		self.name = name
		self.hall = hall
	}
	
	init(name: String, hall: Halls, openTime: Time, closeTime: Time) {
		self.name = name
		self.hall = hall
		self.openTime = openTime
		self.closeTime = closeTime
	}
	
	init(name: String, hall: Halls, foods: Array<FoodInfo>) {
		self.name = name
		self.hall = hall
		self.foods = foods
	}
	
	func image(open: Bool) -> UIImage? {
		return hall.image(open)
	}
}

struct FoodInfo {
	var name: String = ""
	
	// TODO: add nutritional information
	var nutrients: Array<NutritionListing> = [NutritionListing(type: .Cal, measure: "100")]
	
	init(name: String) {
		self.name = name
	}
}

enum Nutrient: String {
	case Cal = "Calories"
	case FatCal = "Calories From Fat"
	case TotFat = "Total Fat"
	case SatFat = "Saturated Fat"
	case TransFat = "Trans Fat"
	case Chol = "Cholesterol"
	case Sodium = "Sodium"
	case TotCarb = "Total Carbohydrate"
	case DietFiber = "Dietary Fiber"
	case Sugar = "Sugars"
	case Protein = "Protein"
	case VitA = "Vitamin A"
	case VitC = "Vitamin C"
	case Calcium = "Calcium"
	case Iron = "Iron"
	
	func unit() -> String {
		switch self {
		case .Cal, .FatCal:
			return ""
		case .TotFat, .SatFat, .TransFat, .TotCarb, .DietFiber, .Sugar, .Protein:
			return "g"
		case .Chol, .Sodium:
			return "mg"
		case .VitA, .VitC, .Calcium, .Iron:
			return "%"
		}
	}
}

struct NutritionListing {
	var type: Nutrient = .Cal
	var unit: String
	var measure: String = ""
	
	init(type: Nutrient, measure: String) {
		self.type = type
		self.measure = measure
		self.unit = type.unit()
	}
}

enum MealType : String {
	case Breakfast = "Breakfast"
	case Lunch = "Lunch"
	case Dinner = "Dinner"
	case Brunch = "Brunch"
	case LateNight = "Late Night"
}