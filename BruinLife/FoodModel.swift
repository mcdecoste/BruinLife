//
//  FoodModel.swift
//  BruinLife
//
//  Created by Matthew DeCoste on 12/15/14.
//  Copyright (c) 2014 Matthew DeCoste. All rights reserved.
//

import UIKit
import CloudKit

class Time {
	var hour: Int
	var minute: Int
	
	/// give hour in 24 hour notation (can be more than 24 hours if past midnight)
	init(hour: Int, minute: Int) {
		self.hour = hour
		self.minute = minute
	}
	
	init(hoursString: String) {
		var formatter = NSDateFormatter()
		formatter.dateFormat = "h:mm a"
		let comps = NSCalendar.currentCalendar().components(.CalendarUnitHour | .CalendarUnitMinute, fromDate: formatter.dateFromString(hoursString)!)
		self.hour = comps.hour + comps.hour < 7 ? 24 : 0
		self.minute = comps.minute
	}
	
	init(hoursString: String, date: NSDate) {
		var formatter = NSDateFormatter()
		formatter.dateFormat = "h:mm a"
		let interval = formatter.dateFromString(hoursString)!.timeIntervalSinceDate(date)
		
		self.hour = Int(interval) / 3600
		self.minute = Int(interval % 3600) / 60
	}
	
	func timeDateForDate(dayDate: NSDate?) -> NSDate? {
		var interval = 3600.0 * Double(hour) + 60 * Double(minute)
		return NSCalendar.currentCalendar().dateBySettingHour(0, minute: 0, second: 0, ofDate: dayDate!, options: NSCalendarOptions())?.dateByAddingTimeInterval(interval)
	}
	
	func displayString() -> String {
		var formatter = NSDateFormatter()
		formatter.dateFormat = "h:mm a"
		return formatter.stringFromDate(timeDateForDate(NSDate())!)
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

class HoursInfo {
	var hours: Dictionary<MealType, MealHoursInfo>
	
	init(dictionary: Dictionary<MealType, Dictionary<Halls, (open: Bool, openTime: Time?, closeTime: Time?)>>) {
		hours = [:]
		for meal in dictionary.keys.array {
			hours[meal] = MealHoursInfo(dictionary: dictionary[meal]!)
		}
	}
	
	init(formattedString: String) {
		hours = [:]
		
		for mealStr in formattedString.componentsSeparatedByString("‰") {
			var mealStrParts = mealStr.componentsSeparatedByString("Ø")
			hours[MealType(rawValue: mealStrParts[0])!] = MealHoursInfo(formattedString: mealStrParts[1])
		}
	}
	
	func formattedString() -> String {
		var string = ""
		for key in hours.keys.array {
			if string != "" { string += "‰" }
			string += "\(key.rawValue)Ø\(hours[key]!.formattedString())"
		}
		return string
	}
}

class MealHoursInfo {
	var hours: Dictionary<Halls, (open: Bool, openTime: Time?, closeTime: Time?)>
	
	init(dictionary: Dictionary<Halls, (open: Bool, openTime: Time?, closeTime: Time?)>) {
		hours = dictionary
	}
	
	init(formattedString: String) {
		hours = [:]
		
		for hallStr in formattedString.componentsSeparatedByString("Í") {
			let hallStrParts = hallStr.componentsSeparatedByString("ˆ")
			
			let hallName = hallStrParts[0]
			if hallStrParts[1] == "C" {
				hours[Halls(rawValue: hallName)!] = (false, nil, nil)
			} else {
				let hourParts = hallStrParts[1].componentsSeparatedByString("~")
				
				let openParts = hourParts[0].componentsSeparatedByString("-")
				let openTime = Time(hour: openParts[0].toInt()!, minute: openParts[1].toInt()!)
				
				let closeParts = hourParts[1].componentsSeparatedByString("-")
				let closeTime = Time(hour: closeParts[0].toInt()!, minute: closeParts[1].toInt()!)
				
				hours[Halls(rawValue: hallName)!] = (true, openTime, closeTime)
			}
		}
	}
	
	func formattedString() -> String {
		var string = ""
		for key in hours.keys.array {
			if string != "" { string += "Í" }
			
			let (open, openT, closeT) = hours[key]!
			var form = "C"
			if open {
				form = "\(openT!.hour)-\(openT!.minute)~\(closeT!.hour)-\(closeT!.minute)"
			}
			
			string += "\(key.rawValue)ˆ\(form)"
		}
		return string
	}
}

class DayInfo {
	var date = NSDate()
	var meals: Dictionary<MealType, MealInfo> = [:]
	
	init() {
		
	}
	
	init(record: CKRecord) {
		date = record.objectForKey("Day") as NSDate
		let formString = NSString(data: record.objectForKey("Data") as NSData, encoding: NSUTF8StringEncoding) as String
		let parts = formString.componentsSeparatedByString("ﬂ")
		for part in parts {
			let dictParts = part.componentsSeparatedByString("Ø")
			let meal = MealType(rawValue: dictParts[0])!
			let information = MealInfo(formattedString: dictParts[1])
			meals[meal] = information
		}
	}
	
	init(date: NSDate = NSDate(), formattedString: String) {
		self.date = date
		self.meals = [:]
		let parts = formattedString.componentsSeparatedByString("ﬂ")
		for part in parts {
			let dictParts = part.componentsSeparatedByString("Ø")
			if dictParts.count == 2 {
				let meal = MealType(rawValue: dictParts[0])!
				let information = MealInfo(formattedString: dictParts[1])
				meals[meal] = information
			}
		}
	}
	
	init(date: NSDate, meals: Dictionary<MealType, MealInfo>) {
		self.date = date
		self.meals = meals
	}
	
	func formattedString() -> String {
		var string = ""
		for key in meals.keys {
			if string != "" {
				string = string + "ﬂ"
			}
			
			string = string + "\(key.rawValue)Ø\(meals[key]!.formattedString())"
		}
		return string
	}
}

class MealInfo {
	var halls: Dictionary<Halls, RestaurantInfo>
	
	init(halls: Dictionary<Halls, RestaurantInfo>) {
		self.halls = halls
	}
	
	init(formattedString: String) {
		halls = [:]
		let parts = formattedString.componentsSeparatedByString("‡")
		for part in parts {
			let dictParts = part.componentsSeparatedByString("¨")
			let hall = Halls(rawValue: dictParts[0])!
			let information = RestaurantInfo(formattedString: dictParts[1])
			halls[hall] = information
		}
	}
	
	func formattedString() -> String {
		var string = ""
		for key in halls.keys {
			if string != "" {
				string = string + "‡"
			}
			
			string = string + "\(key.rawValue)¨\(halls[key]!.formattedString())"
		}
		return string
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
	
	init(formattedString: String) {
		let parts = formattedString.componentsSeparatedByString("·")
		hall = Halls(rawValue: parts[0])!
		
		let openParts = parts[1].componentsSeparatedByString("-")
		openTime = Time(hour: openParts[0].toInt()!, minute: openParts[1].toInt()!)
		
		let closeParts = parts[2].componentsSeparatedByString("-")
		closeTime = Time(hour: closeParts[0].toInt()!, minute: closeParts[1].toInt()!)
		
		sections = []
		for section in parts[3..<parts.count] {
			sections.append(SectionInfo(formattedString: section))
		}
	}
	
	func name(isHall: Bool) -> String {
		return hall.displayName(isHall)
	}
	
	func imageName(open: Bool) -> String {
		return hall.imageName(open)
	}
	
	func formattedString() -> String {
		var string = "\(hall.rawValue)·\(openTime.hour)-\(openTime.minute)·\(closeTime.hour)-\(closeTime.minute)"
		for section in sections {
			string = string + "·\(section.formattedString())"
		}
		return string
	}
}

class SectionInfo {
	var name: String = ""
	var foods = [MainFoodInfo]()
	
	init(name: String) {
		self.name = name
	}
	
	init(formattedString: String) {
		let parts = formattedString.componentsSeparatedByString("ª")
		name = parts[0]
		foods = []
		for part in parts[1..<parts.count] {
			if part != "" {
				foods.append(MainFoodInfo(formattedString: part))
			}
		}
	}
	
	func formattedString() -> String {
		var foodStrings = [String]()
		for food in foods { foodStrings.append(food.foodString()) }
		
		let foodsString = "ª".join(foodStrings)
		return "\(name)ª\(foodsString)"
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
	var nutrition = [NutritionListing]()
	var ingredients: String = ""
	var description: String = ""
	var countryCode: String = ""
	
	init(name: String, recipe: String, type: FoodType) {
		self.name = name
		self.recipe = recipe
		self.type = type
		
		for nutrient in Nutrient.allValues { nutrition.append(NutritionListing(type: nutrient, measure: "0")) }
	}
	
	/// Only call this initializer if you had the precisely formatted string created by the foodString() function
	init(formattedString: String) {
		let parts = formattedString.componentsSeparatedByString("°")

		name = parts[0]
		recipe = parts[1]
		type = FoodType(rawValue: parts[2])!
		setNutrition(parts[3])
		ingredients = parts[4]
		description = parts[5]
		countryCode = parts[6]
	}
	
	func typeString() -> String { return type.rawValue }
	func setType(string: String) { type = FoodType(rawValue: string)! }
	
	func nutritionString() -> String {
		var nutritionStrings = [String]() // other array initialization strategy
		for nutr in nutrition {
			nutritionStrings.append(nutr.measure)
		}
		
		return "•".join(nutritionStrings)
	}
	
	func setNutrition(string: String) {
		let parts = string.componentsSeparatedByString("•")
		
		if parts.count == 1 && parts[0] == "" {
			nutrition = []
			
			for (index, nutr) in enumerate(Nutrient.allValues) {
				nutrition.append(NutritionListing(type: nutr, measure: "0"))
			}
		} else {
			nutrition = []
			
			for (index, nutr) in enumerate(Nutrient.allValues) {
				nutrition.append(NutritionListing(type: nutr, measure: parts[index]))
			}
		}
	}
	
	func foodString() -> String {
		return "\(name)°\(recipe)°\(type.rawValue)°\(nutritionString())°\(ingredients)°\(description)°\(countryCode)"
	}
}

class MainFoodInfo: FoodInfo {
	var withFood: SubFoodInfo?
	
	override init(name: String, recipe: String, type: FoodType) {
		super.init(name: name, recipe: recipe, type: type)
	}
	
	/// Only call this initializer if you had the precisely formatted string created by the foodString() function
	override init(formattedString: String) {
		let parts = formattedString.componentsSeparatedByString("|")
		if parts[0] == "" {
			super.init(formattedString: formattedString)
		} else {
			super.init(formattedString: parts[0])
		}
		
		withFood = parts.count == 2 ? SubFoodInfo(formattedString: parts[1]) : nil
	}
	
	override func foodString() -> String {
		if let with = withFood {
			return "\(super.foodString())|\(with.foodString())"
		} else {
			return super.foodString()
		}
	}
	
	class func isMain(formattedString: String) -> Bool {
		let parts = formattedString.componentsSeparatedByString("|")
		return parts.count == 2
	}
}

class SubFoodInfo: FoodInfo {
	override init(name: String, recipe: String, type: FoodType) {
		super.init(name: name, recipe: recipe, type: type)
	}
	
	override init(formattedString: String) {
		if formattedString.rangeOfString("°") == nil {
			super.init(name: formattedString, recipe: "", type: .Regular)
		} else {
			super.init(formattedString: formattedString)
		}
	}
	
	override func foodString() -> String {
		return recipe == "" ? name : super.foodString()
	}
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
	static let rowPairs: Array<(type: NutrientDisplayType, left: Nutrient, right: Nutrient)> = [(.twoMain, .Cal, .FatCal), (.oneMain, .TotFat, .Cal), (.oneSub, .SatFat, .Cal), (.oneSub, .TransFat, .Cal), (.oneMain, .Chol, .Cal), (.oneMain, .Sodium, .Cal), (.oneMain, .TotCarb, .Cal), (.oneSub, .DietFiber, .Cal), (.oneSub, .Sugar, .Cal), (.oneMain, .Protein, .Cal), (.doublePlain, .VitA, .VitC), (.doublePlain, .Calcium, .Iron)]
	
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