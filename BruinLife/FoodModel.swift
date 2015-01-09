//
//  FoodModel.swift
//  BruinLife
//
//  Created by Matthew DeCoste on 12/15/14.
//  Copyright (c) 2014 Matthew DeCoste. All rights reserved.
//

import UIKit

class Time {
	var hour: Int
	var minute: Int
	
	/// give hour in 24 hour notation (can be more than 24 hours if past midnight)
	init(hour: Int, minute: Int) {
		self.hour = hour
		self.minute = minute
	}
	
	init(hoursString: String) {
		// before	: = hour	|	after	: = minute	|	last two characters = am/pm
		var colonRange = hoursString.rangeOfString(":")
		var remainder = hoursString.substringFromIndex((colonRange?.endIndex)!)
		var isPM = remainder.substringFromIndex((remainder.rangeOfString("m")?.startIndex.predecessor())!) == "pm"
		
		self.hour = (hoursString.substringToIndex((colonRange?.startIndex)!) as NSString).integerValue + (isPM ? 12 : 0)
		self.minute = (remainder.substringToIndex((colonRange?.startIndex.predecessor())!) as NSString).integerValue
		
		if self.hour % 12 == 0 { self.hour -= 12 }
		if self.hour < 7 { self.hour += 24 }
	}
	
	func timeDateForDate(dayDate: NSDate?) -> NSDate? {
		var interval = 3600.0 * Double(hour) + 60 * Double(minute)
		return NSCalendar.currentCalendar().dateBySettingHour(0, minute: 0, second: 0, ofDate: dayDate!, options: NSCalendarOptions())?.dateByAddingTimeInterval(interval)
	}
	
	func displayString() -> String {
		let AMPM = ((hour/12) == 0 || (hour/12) == 2) ? "AM" : "PM"
		
		if minute < 10 {
			return "\(hour):0\(minute) \(AMPM)"
		} else {
			return "\(hour):\(minute) \(AMPM)"
		}
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
	
	static let allDiningHalls: Array<Halls> = [.DeNeve, .BruinPlate, .Feast, .Hedrick, .Covel]
	
	/// the exact order of this is importnat to prevent collisions between Rendezvous and Hedrick
	static let allRestaurants: Array<Halls> = [.Cafe1919, .Rendezvous, .BruinCafe, .DeNeve, .BruinPlate, .Feast, .Hedrick, .Covel]
	
	/// returns the URL code (note that 03 and 05 have NO association)
	func urlCode() -> String? {
		switch self {
		case .DeNeve:
			return "01"
		case .Covel:
			return "07"
		case .Hedrick:
			return "06"
		case .Feast:
			return "04"
		case .BruinPlate:
			return "02"
		default:
			return nil
		}
	}
	
	static func hallForString(string: String) -> Halls? {
		// preprocess String to prevent multiple matches?
		for hall in Halls.allRestaurants {
			if string.lowercaseString.rangeOfString(hall.rawValue.lowercaseString) != nil { return hall }
		}
		return nil
	}
	
	func imageName(open: Bool) -> String {
		return self.rawValue + (open ? " Dark" : " BW")
	}
	
	func displayName(isHall: Bool) -> String {
		if isHall { return self.rawValue }
		
		switch self {
		case .DeNeve:
			return "Late Night"
		case .Hedrick:
			return "Night Hedrick"
		default:
			return self.rawValue
		}
	}
}

class DayInfo {
	var date = NSDate()
	var meals: Dictionary<MealType, MealInfo> = Dictionary()
	var allHours: Dictionary<MealType, Dictionary<Halls, (open: Bool, openTime: Time?, closeTime: Time?)>> = Dictionary()
	
	init() {
		
	}
	
	init(date: NSDate, meals: Dictionary<MealType, MealInfo>) {
		self.date = date
		self.meals = meals
	}
}

class MealInfo {
	var halls: Dictionary<Halls, RestaurantInfo>
	
	init (halls: Dictionary<Halls, RestaurantInfo>) {
		self.halls = halls
	}
}

class RestaurantInfo {
	var hall: Halls // redundant storage?
	
	var openTime: Time = Time(hour: 8, minute: 0)
	var closeTime: Time = Time(hour: 17, minute: 0)
	
	var sections: Array<SectionInfo>
	
	init(hall: Halls) {
		self.hall = hall
		self.sections = []
	}
	
	func name(isHall: Bool) -> String {
		return hall.displayName(isHall)
	}
	
	func imageName(open: Bool) -> String {
		return hall.imageName(open)
	}
}

class SectionInfo {
	var name: String = ""
	var foods: Array<MainFoodInfo> = []
	
	init(name: String) {
		self.name = name
	}
}

enum FoodType: String {
	case Regular = ""
	case Vegetarian = "Vegetarian"
	case Vegan = "Vegan"
	
	/// returns the preferred color when displaying food type
	func displayColor(alpha: CGFloat) -> UIColor {
		switch self {
		case .Vegetarian:
			return UIColor(red: 0.2, green: 0.9, blue: 0.3, alpha: alpha)
		case .Vegan:
			return UIColor(red: 0.0, green: 1.0, blue: 0.0, alpha: alpha)
		default:
			return UIColor(white: 1.0, alpha: alpha)
		}
	}
}

class FoodInfo {
	var name: String
	var recipe: String
	var type: FoodType
	var nutrition: Array<NutritionListing> = []
	var ingredients: String = ""
	var description: String = ""
	var countryCode: String = ""
	
	init(name: String, recipe: String, type: FoodType) {
		self.name = name
		self.recipe = recipe
		self.type = type
		
		for nutrient in Nutrient.allValues { nutrition.append(NutritionListing(type: nutrient, measure: "0")) }
	}
}

class MainFoodInfo: FoodInfo {
	var withFood: SubFoodInfo?
}

class SubFoodInfo: FoodInfo {
	
}

enum Nutrient: String { // , Equatable
	case Cal = "Calories"
	case FatCal = "From Fat"
	case TotFat = "Total Fat"
	case SatFat = "Saturated Fat"
	case TransFat = "Trans Fat"
	case Chol = "Cholesterol"
	case Sodium = "Sodium"
	case TotCarb = "Total Carbohydrates"
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
			return "cal"
		case .TotFat, .SatFat, .TransFat, .TotCarb, .DietFiber, .Sugar, .Protein:
			return "g"
		case .Chol, .Sodium:
			return "mg"
		case .VitA, .VitC, .Calcium, .Iron:
			return "%"
		}
	}
	
	static let allValues: Array<Nutrient> = [.Cal, .FatCal, .TotFat, .SatFat, .TransFat, .Chol, .Sodium, .TotCarb, .DietFiber, .Sugar, .Protein, .VitA, .VitC, .Calcium, .Iron]
	static let allRawValues = Nutrient.allValues.map { (nut: Nutrient) -> String in return nut.rawValue }
	static let allMatchingValues: Array<String> = ["Calories", "Fat Cal.", "Total Fat", "Saturated Fat", "Trans Fat", "Cholesterol", "Sodium", "Total Carbohydrate", "Dietary Fiber", "Sugars", "Protein", "Vitamin A", "Vitamin C", "Calcium", "Iron"]
	internal static let allDailyValues: Array<Int?> = [2000, nil, 65, 20, nil, 300, 1500, 130, 40, nil, nil, 100, 100, 100, 100]
	static let rowPairs: Array<(NutrientDisplayType, Nutrient, Nutrient)> = [(.twoMain, .Cal, .FatCal), (.oneMain, .TotFat, .Cal), (.oneSub, .SatFat, .Cal), (.oneSub, .TransFat, .Cal), (.oneMain, .Chol, .Cal), (.oneMain, .Sodium, .Cal), (.oneMain, .TotCarb, .Cal), (.oneSub, .DietFiber, .Cal), (.oneSub, .Sugar, .Cal), (.oneMain, .Protein, .Cal), (.doublePlain, .VitA, .VitC), (.doublePlain, .Calcium, .Iron)]
	
	static func typeForName(name: String) -> Nutrient? {
		var index = 0
		var matchingValues = Nutrient.allMatchingValues
		for value in matchingValues {
			if name.rangeOfString(value) != nil { break }
			index++
		}
		if index > matchingValues.count-1 { return nil }
		return Nutrient.allValues[index]
	}
	
	func hasDVpercentage() -> Bool {
		var index = (Nutrient.allRawValues as NSArray).indexOfObject(rawValue)
		return Nutrient.allDailyValues[index] != nil
	}
}

class NutritionListing {
	var type: Nutrient
	var unit: String
	var measure: String
	var percent: Int? // out of 100
	
	init(type: Nutrient, measure: String) {
		self.type = type
		self.measure = measure
		self.unit = type.unit()
		self.percent = dailyValue()
	}
	
	internal func dailyValue() -> Int? {
		if let dailyValue = Nutrient.allDailyValues[(find(Nutrient.allValues, self.type))!] {
			return Int(100.0 * ((measure as NSString).floatValue) / Float(dailyValue))
		}
		return nil
	}
}

enum MealType : String {
	case Breakfast = "Breakfast"
	case Lunch = "Lunch"
	case Dinner = "Dinner"
	case Brunch = "Brunch"
	case LateNight = "Late Night"
	
	func equalTo(otherMeal: MealType) -> Bool {
		var one = (self == .Breakfast || self == .Lunch) && otherMeal == .Brunch
		var two = (otherMeal == .Breakfast || self == .Lunch) && self == .Brunch
		return one || two || self.rawValue == otherMeal.rawValue
	}
	
	func urlCode() -> String? {
		switch self {
		case .Breakfast:
			return "1"
		case .Lunch, .Brunch:
			return "2"
		case .Dinner:
			return "3"
		default:
			return nil
		}
	}
	
	static func allMeals(date: NSDate) -> Array<MealType> {
		var dow = NSCalendar.currentCalendar().component(.WeekdayCalendarUnit, fromDate: date)
		return (dow == 1 || dow == 7) ? [.Brunch, .Dinner] : [.Breakfast, .Lunch, .Dinner]
	}
}