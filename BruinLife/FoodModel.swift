//
//  FoodModel.swift
//  BruinLife
//
//  Created by Matthew DeCoste on 12/15/14.
//  Copyright (c) 2014 Matthew DeCoste. All rights reserved.
//

import UIKit
import CloudKit

protocol Serializable {
	func dictFromObject() -> Dictionary<String, AnyObject>
	init(dict: Dictionary<String, AnyObject>)
}

class Time {
	var hour: Int
	var minute: Int
	
	var displayString: String {
		get {
			var formatter = NSDateFormatter()
			formatter.dateFormat = "h:mm a"
			return formatter.stringFromDate(timeDateForDate(NSDate()))
		}
	}
	
	/// give hour in 24 hour notation (can be more than 24 hours if past midnight)
	init(hour: Int, minute: Int) {
		self.hour = hour
		self.minute = minute
	}
	
	func timeDateForDate(date: NSDate) -> NSDate {
		var interval = 3600.0 * Double(hour) + 60 * Double(minute)
		return comparisonDate(date: date).dateByAddingTimeInterval(interval)
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
	
	/// returns the URL code (note that 03 and 05 have NO association)
	var urlCode: String? {
		switch self {
		case DeNeve:
			return "01"
		case Covel:
			return "07"
		case Hedrick:
			return "06"
		case Feast:
			return "04"
		case BruinPlate:
			return "02"
		default:
			return nil
		}
	}
	
	static let allDiningHalls: Array<Halls> = [.DeNeve, .BruinPlate, .Feast, .Hedrick, .Covel] // DeNeve - late night
	static let allQuickServices: Array<Halls> = [.DeNeve, .Cafe1919, .Rendezvous, .BruinCafe] // DeNeve is late only
	
	/// the exact order of this is important to prevent collisions between Rendezvous and Hedrick
	static let allRestaurants: Array<Halls> = [.Cafe1919, .Rendezvous, .BruinCafe, .DeNeve, .BruinPlate, .Feast, .Hedrick, .Covel]
	
	static func hallForString(string: String) -> Halls? {
		// preprocess String to prevent multiple matches?
		for hall in Halls.allRestaurants {
			if string.lowercaseString.rangeOfString(hall.rawValue.lowercaseString) != nil { return hall }
		}
		return nil
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

// MARK:- STANDARD MODEL

enum FoodType: String {
	case Regular = ""
	case Vegetarian = "Vegetarian"
	case Vegan = "Vegan"
	
	/// returns the preferred color when displaying food type
	var displayColor: UIColor {
		get {
			switch self {
			case .Vegetarian:
				return UIColor(red: 0.2, green: 0.9, blue: 0.3, alpha: 1.0)
			case .Vegan:
				return UIColor(red: 0.0, green: 1.0, blue: 0.0, alpha: 1.0)
			default:
				return UIColor(white: 1.0, alpha: 1.0)
			}
		}
	}
}

class FoodInfo: Serializable {
	var name: String = ""
	var recipe: String = "000000"
	var type: FoodType = .Regular
	var nutrition: Dictionary<Nutrient, NutritionListing> = [:]
	var ingredients: String = ""
	var description: String = ""
	var countryCode: String = ""
	
	init() {
		for nutrient in Nutrient.allValues {
			nutrition[nutrient] = NutritionListing(type: nutrient, measure: "0")
		}
	}
	
	required init(dict: Dictionary<String, AnyObject>) {
		name = dict["name"] as? String ?? "No Name"
		recipe = dict["recipe"] as? String ?? "No Recipe"
		type = FoodType(rawValue: dict["type"] as? String ?? "")!
		for nutrient in Nutrient.allValues {
			nutrition[nutrient] = NutritionListing(type: nutrient, measure: dict[nutrient.rawValue] as? String ?? "0")
		}
		ingredients = dict["ingredients"] as? String ?? ""
		description = dict["description"] as? String ?? ""
		countryCode = dict["country"] as? String ?? ""
	}
	
	// MARK:- Serializable Protocol
	func dictFromObject() -> Dictionary<String, AnyObject> {
		var dict: Dictionary<String, AnyObject> = [:]
		
		dict["name"] = name
		dict["recipe"] = recipe
		dict["type"] = type.rawValue
		for nutrient in Nutrient.allValues {
			dict[nutrient.rawValue] = nutrition[nutrient]?.measure ?? "0"
		}
		dict["ingredients"] = ingredients
		dict["description"] = description
		dict["country"] = countryCode
		
		return dict
	}
	
	
}

// MARK:- NEW MODEL

struct FoodCollection: Serializable {
	var info: FoodInfo
	var places: Dictionary<String, Dictionary<String, Bool>> = [:]
	
	init(info: FoodInfo) {
		self.info = info
	}
	
	init(dict: Dictionary<String, AnyObject>) {
		info = FoodInfo(dict: dict["info"] as! Dictionary<String, AnyObject>)
		places = dict["places"] as! Dictionary<String, Dictionary<String, Bool>>
	}
	
	func dictFromObject() -> Dictionary<String, AnyObject> {
		return ["info" : info.dictFromObject(), "places" : places]
	}
}

class DayBrief: Serializable {
	var date = comparisonDate()
	var meals: Dictionary<MealType, MealBrief> = [:]
	var foods: Dictionary<String, FoodCollection> = [:]
	
	init() {
		
	}
	
	required init(dict: Dictionary<String, AnyObject>) {
		var form = NSDateFormatter()
		form.dateStyle = .ShortStyle
		
		date = form.dateFromString(dict["date"] as! String)!
		
		meals = [:]
		var mealsDict = dict["meals"] as! Dictionary<String, Dictionary<String, AnyObject>>
		for (mealName, mealDict) in mealsDict {
			meals[MealType(rawValue: mealName)!] = MealBrief(dict: mealDict)
		}
		var foodsDict = dict["foods"] as! Dictionary<String, Dictionary<String, AnyObject>>
		for (recipe, foodDict) in foodsDict {
			foods[recipe] = FoodCollection(dict: foodDict)
		}
	}
	
	func dictFromObject() -> Dictionary<String, AnyObject> {
		var form = NSDateFormatter()
		form.dateStyle = .ShortStyle
		
		var dict: Dictionary<String, AnyObject> = [:]
		
		dict["date"] = form.stringFromDate(date)
		var mealsDict: Dictionary<String, Dictionary<String, AnyObject>> = [:]
		for (mealName, meal) in meals {
			mealsDict[mealName.rawValue] = meal.dictFromObject()
		}
		dict["meals"] = mealsDict
		
		var foodsDict: Dictionary<String, Dictionary<String, AnyObject>> = [:]
		for (recipe, food) in foods {
			foodsDict[recipe] = food.dictFromObject()
		}
		dict["foods"] = foodsDict
		
		return dict
	}
}

class MealBrief: Serializable {
	var halls: Dictionary<Halls, RestaurantBrief> = [:]
	
	required init(dict: Dictionary<String, AnyObject>) {
		halls = [:]
		var hallsDict = dict["halls"] as! Dictionary<String, Dictionary<String, AnyObject>>
		
		for hall in hallsDict.keys {
			halls[Halls(rawValue: hall)!] = RestaurantBrief(dict: hallsDict[hall]!)
		}
	}
	
	func dictFromObject() -> Dictionary<String, AnyObject> {
		var dict: Dictionary<String, AnyObject> = [:]
		
		var hallsDict: Dictionary<String, Dictionary<String, AnyObject>> = [:]
		for hall in halls.keys {
			hallsDict[hall.rawValue] = halls[hall]!.dictFromObject()
		}
		dict["halls"] = hallsDict
		
		return dict
	}
}

class PlaceBrief: Serializable {
	var hall: Halls // redundant storage?
	
	var openTime: Time = Time(hour: 8, minute: 0)
	var closeTime: Time = Time(hour: 8, minute: 0)
	
	var sectionDicts: Array<Dictionary<String, AnyObject>> = []
	
	var fullDetails: Array<SectionBrief> {
		get {
			var sections: Array<SectionBrief> = []
			
			for dict in sectionDicts {
				sections.append(SectionBrief(dict: dict))
			}
			
			return sections
		}
	}
	
	init(hall: Halls) {
		self.hall = hall
	}
	
	required init(dict: Dictionary<String, AnyObject>) {
		hall = Halls(rawValue: dict["hall"] as! String)!
		openTime = Time(hour: dict["openHour"] as! Int, minute: dict["openMin"] as! Int)
		closeTime = Time(hour: dict["closeHour"] as! Int, minute: dict["closeMin"] as! Int)
		sectionDicts = dict["sections"] as? Array<Dictionary<String, AnyObject>> ?? []
	}
	
	func dictFromObject() -> Dictionary<String, AnyObject> {
		var dict: Dictionary<String, AnyObject> = [:]
		
		dict["hall"] = hall.rawValue
		dict["openHour"] = openTime.hour
		dict["openMin"] = openTime.minute
		dict["closeHour"] = closeTime.hour
		dict["closeMin"] = closeTime.minute
		dict["sections"] = sectionDicts
		
		return dict
	}
	
	func name(isHall: Bool) -> String {
		return hall.displayName(isHall)
	}
}

class RestaurantBrief: Serializable {
	var hall: Halls = .DeNeve // redundant storage?
	
	var openTime: Time = Time(hour: 8, minute: 0)
	var closeTime: Time = Time(hour: 8, minute: 0)
	
	var sections: Array<SectionBrief> = []
	
	init() {
		
	}
	
	required init(dict: Dictionary<String, AnyObject>) {
		hall = Halls(rawValue: dict["hall"] as! String)!
		openTime = Time(hour: dict["openHour"] as! Int, minute: dict["openMin"] as! Int)
		closeTime = Time(hour: dict["closeHour"] as! Int, minute: dict["closeMin"] as! Int)
		
		sections = []
		var sectionDicts = dict["sections"] as? Array<Dictionary<String, AnyObject>> ?? []
		for sectionDict in sectionDicts {
			sections.append(SectionBrief(dict: sectionDict))
		}
	}
	
	func dictFromObject() -> Dictionary<String, AnyObject> {
		var dict: Dictionary<String, AnyObject> = [:]
		
		dict["hall"] = hall.rawValue
		dict["openHour"] = openTime.hour
		dict["openMin"] = openTime.minute
		dict["closeHour"] = closeTime.hour
		dict["closeMin"] = closeTime.minute
		
		var sectionDicts: Array<Dictionary<String, AnyObject>> = []
		for section in sections {
			sectionDicts.append(section.dictFromObject())
		}
		dict["sections"] = sectionDicts
		
		return dict
	}
	
	func name(isHall: Bool) -> String {
		return hall.displayName(isHall)
	}
}

class SectionBrief: Serializable {
	var name: String = ""
	var foods: Array<FoodBrief> = []
	
	required init(dict: Dictionary<String, AnyObject>) {
		name = dict["name"] as? String ?? "No Name"
		for foodDict in dict["foods"] as? Array<Dictionary<String, AnyObject>> ?? [] {
			foods.append(FoodBrief(dict: foodDict))
		}
	}
	
	func dictFromObject() -> Dictionary<String, AnyObject> {
		var dict: Dictionary<String, AnyObject> = [:]
		
		dict["name"] = name
		var foodDicts: Array<Dictionary<String, AnyObject>> = []
		for food in foods {
			foodDicts.append(food.dictFromObject())
		}
		dict["foods"] = foodDicts
		
		return dict
	}
}

class FoodBrief: Serializable {
	var name: String = ""
	var type: FoodType = .Regular
	var recipe: String = ""
	var sideBrief: FoodBrief?
	
	func dictFromObject() -> Dictionary<String, AnyObject> {
		return ["name" : name, "type" : type.rawValue, "recipe" : recipe]
	}
	
	init() {
		
	}
	
	required init(dict: Dictionary<String, AnyObject>) {
		name = dict["name"] as! String
		type = FoodType(rawValue: dict["type"] as! String)!
		recipe = dict["recipe"] as! String
	}
	
	init(food: FoodInfo, sideFood: FoodInfo? = nil) {
		name = food.name
		type = food.type
		recipe = food.recipe
		if let side = sideFood {
			sideBrief = FoodBrief(food: side)
		}
	}
}

// MARK:- After

enum NutrientDisplayType {
	case oneMain // bold
	case doubleMain // both bold
	case doublePlain // both regular
	case twoMain // first bold
	case oneSub // not bold (replacing twoSub)
	case empty // since no nils possible in tuples
}

enum Nutrient: String { // , Equatable
	case Cal = "Calories", FatCal = "From Fat"
	case TotFat = "Total Fat", SatFat = "Saturated Fat"
	case TransFat = "Trans Fat", Chol = "Cholesterol", Sodium = "Sodium"
	case TotCarb = "Total Carbohydrates", DietFiber = "Dietary Fiber"
	case Sugar = "Sugars", Protein = "Protein"
	case VitA = "Vitamin A", VitC = "Vitamin C", Calcium = "Calcium", Iron = "Iron"
	
	func unit() -> String {
		switch self {
		case Cal, FatCal:
			return "cal"
		case TotFat, SatFat, TransFat, TotCarb, DietFiber, Sugar, Protein:
			return "g"
		case Chol, Sodium:
			return "mg"
		case VitA, VitC, Calcium, Iron:
			return "%"
		}
	}
	
	static let allValues: Array<Nutrient> = [Cal, FatCal, TotFat, SatFat, TransFat, Chol, Sodium, TotCarb, DietFiber, Sugar, Protein, VitA, VitC, Calcium, Iron]
	static let allRawValues = Nutrient.allValues.map { (nut: Nutrient) -> String in return nut.rawValue }
	static let allMatchingValues: Array<String> = ["Calories", "Fat Cal.", "Total Fat", "Saturated Fat", "Trans Fat", "Cholesterol", "Sodium", "Total Carbohydrate", "Dietary Fiber", "Sugars", "Protein", "Vitamin A", "Vitamin C", "Calcium", "Iron"]
	static let allMatchingXML: Array<String> = ["Cal", "FatCal", "TotFat", "SatFat", "TransFat", "Chol", "Sodium", "TotCarb", "DietFiber", "Sugar", "Protein", "VitA", "VitC", "Calcium", "Iron"]
	internal static let dailyValues: Dictionary<Nutrient, Int> = [Cal:2000, TotFat:65, SatFat:20, Chol:300, Sodium:1500, TotCarb:130, DietFiber:40, VitA:100, VitC:100, Calcium:100, Iron:100]
	static let rowPairs: Array<(type: NutrientDisplayType, left: Nutrient, right: Nutrient)> = [(.twoMain, Cal, FatCal), (.oneMain, TotFat, Cal), (.oneSub, SatFat, Cal), (.oneSub, TransFat, Cal), (.oneMain, Chol, Cal), (.oneMain, Sodium, Cal), (.oneMain, TotCarb, Cal), (.oneSub, DietFiber, Cal), (.oneSub, Sugar, Cal), (.oneMain, Protein, Cal), (.doublePlain, VitA, VitC), (.doublePlain, Calcium, Iron)]
	
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
	
	static func typeForXML(xml: String) -> Nutrient? {
		if let index = find(Nutrient.allMatchingXML, xml) {
			return Nutrient.allValues[index]
		}
		return nil
	}
	
	var hasDV: Bool {
		get {
			return Nutrient.dailyValues[self] != nil
		}
	}
	
	// TODO: decide if redundant / maybe swap out for NutritionListing.dailyValue
	func dailyValue(measure: String) -> Int? {
		if let dailyValue = Nutrient.dailyValues[self] {
			return Int((100.0 * ((measure as NSString).floatValue)) / Float(dailyValue))
		} else {
			return nil
		}
	}
}

class NutritionListing {
	var unit: String
	var measure: String
	var percent: Int? // out of 100
	
	init(type: Nutrient, measure: String) {
		self.measure = measure
		self.unit = type.unit()
		self.percent = dailyValue(type)
	}
	
	internal func dailyValue(type: Nutrient) -> Int? {
		if let dailyValue = Nutrient.dailyValues[type] {
			return Int((100.0 * ((measure as NSString).floatValue)) / Float(dailyValue))
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
	
	var urlCode: String? {
		get {
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
	}
	
	func equalTo(otherMeal: MealType) -> Bool {
		switch self {
		case Breakfast:
			return otherMeal == Breakfast || otherMeal == Brunch
		case Brunch:
			return otherMeal == Breakfast || otherMeal == Brunch || otherMeal == Lunch
		case Lunch:
			return otherMeal == Lunch || otherMeal == Brunch
		default:
			return self == otherMeal
		}
	}
	
	static func allMeals(date: NSDate) -> Array<MealType> {
		return currCal.isDateInWeekend(date) ? [Brunch, Dinner] : [Breakfast, Lunch, Dinner]
	}
}