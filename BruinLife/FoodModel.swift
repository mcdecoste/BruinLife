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
	var pm: Bool = true
	
	init(hour: Int, minute: Int, pm: Bool) {
		self.hour = pm ? hour + 12 : hour
		self.minute = minute
		self.pm = pm
	}
	
	init(hour: Int, minute: Int, pm: Bool, nextDay: Bool) {
		self.hour = pm ? hour + 12 : hour
		self.minute = minute
		self.pm = pm
		
		if (nextDay) {
			self.hour += 24
		}
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

enum Halls: String {
	case DeNeve = "De Neve"
	case Covel = "Covel"
	case Hedrick = "Hedrick"
	case Feast = "Feast"
	case BruinPlate = "Bruin Plate"
	case Cafe1919 = "Cafe 1919"
	case Rendezvous = "Rendezvous"
	case BruinCafe = "Bruin Cafe"
}

struct HallInfo {
	var hall: Halls = .DeNeve
	var openImage: UIImage?
	var closedImage: UIImage?
	
	init(hall: Halls) {
		self.hall = hall
		openImage = UIImage(named: hall.rawValue + " Dark")
		closedImage = UIImage(named: hall.rawValue + " BW")
	}
}

struct RestaurantInfo {
	var name: String = ""
	var hall: HallInfo = HallInfo(hall: .DeNeve)
	
	var openTime: Time = Time(hour: 8, minute: 0, pm: false)
	var closeTime: Time = Time(hour: 5, minute: 0, pm: true)
	
	var foods: Array<FoodInfo> = [FoodInfo(name: "Thai Tea"), FoodInfo(name: "Sushi Bowl"), FoodInfo(name: "Angel Hair Pasta"), FoodInfo(name: "Turkey Burger"), FoodInfo(name: "Carne Asada Fries"), FoodInfo(name: "Barbeque Chicken Quesadilla"), FoodInfo(name: "Yogurt"), FoodInfo(name: "Pepperoni Pizza"), FoodInfo(name: "Chocolate Shake with Oreo")]
	
	init(name: String, hall: Halls) {
		self.name = name
		self.hall = HallInfo(hall: hall)
	}
	
	init(name: String, hall: Halls, openTime: Time, closeTime: Time) {
		self.name = name
		self.hall = HallInfo(hall: hall)
		self.openTime = openTime
		self.closeTime = closeTime
	}
	
	init(name: String, hall: Halls, foods: Array<FoodInfo>) {
		self.name = name
		self.hall = HallInfo(hall: hall)
		self.foods = foods
	}
	
	func image(open: Bool) -> UIImage? {
		return open ? hall.openImage : hall.closedImage
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
}

struct NutritionListing {
	var type: Nutrient = .Cal
	var unit: String
	var measure: String = ""
	
	init(type: Nutrient, measure: String) {
		self.type = type
		self.measure = measure
		switch type {
		case .Cal, .FatCal:
			self.unit = ""
		case .TotFat, .SatFat, .TransFat, .TotCarb, .DietFiber, .Sugar, .Protein:
			self.unit = "g"
		case .Chol, .Sodium:
			self.unit = "mg"
		case .VitA, .VitC, .Calcium, .Iron:
			self.unit = "%"
		}
	}
}

enum MealType : String {
	case Breakfast = "Breakfast"
	case Lunch = "Lunch"
	case Dinner = "Dinner"
	case Brunch = "Brunch"
	case LateNight = "Late Night"
}

//class FoodModel: NSObject {
//   
//}