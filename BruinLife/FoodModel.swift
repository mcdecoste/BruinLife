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

//func representsToday(date: NSDate) -> Bool {
//	return daysInFuture(date) == 0
//}
//
//func daysInFuture(date: NSDate) -> Int {
//	let today = NSCalendar.currentCalendar().components(.CalendarUnitDay, fromDate: NSDate()).day
//	let selectedDay = NSCalendar.currentCalendar().components(.CalendarUnitDay, fromDate: date).day
//	return abs(today - selectedDay)
//}

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
		formatter.dateFormat = "h:mma"
		let comps = NSCalendar.currentCalendar().components(.CalendarUnitHour | .CalendarUnitMinute, fromDate: formatter.dateFromString(hoursString)!)
		var increase = (comps.hour < 7) ? 24 : 0
		self.hour = comps.hour + increase
		self.minute = comps.minute
	}
	
	init(hoursString: String, date: NSDate) {
		var formatter = NSDateFormatter()
		formatter.dateFormat = "h:mma"
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
	
	static let allDiningHalls: Array<Halls> = [.DeNeve, .BruinPlate, .Feast, .Hedrick, .Covel] // DeNeve - late night
	static let allQuickServices: Array<Halls> = [.DeNeve, .Cafe1919, .Rendezvous, .BruinCafe] // DeNeve is late only
	
	/// the exact order of this is important to prevent collisions between Rendezvous and Hedrick
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

// MARK:- OLD MODEL

//class DayInfo: Serializable {
//	var date = comparisonDate(NSDate())
//	var meals: Dictionary<MealType, MealInfo> = [:]
//	
//	init() {
//		
//	}
//	
//	init(record: CKRecord) {
//		date = record.objectForKey("Day") as! NSDate
//		let formString = NSString(data: record.objectForKey("Data") as! NSData, encoding: NSUTF8StringEncoding) as! String
//		let parts = formString.componentsSeparatedByString("ﬂ")
//		for part in parts {
//			let dictParts = part.componentsSeparatedByString("Ø")
//			let meal = MealType(rawValue: dictParts[0])!
//			let information = MealInfo(formattedString: dictParts[1])
//			meals[meal] = information
//		}
//	}
//	
//	init(date: NSDate = NSDate(), formattedString: String) {
//		self.date = date
//		self.meals = [:]
//		let parts = formattedString.componentsSeparatedByString("ﬂ")
//		for part in parts {
//			let dictParts = part.componentsSeparatedByString("Ø")
//			if dictParts.count == 2 {
//				let meal = MealType(rawValue: dictParts[0])!
//				let information = MealInfo(formattedString: dictParts[1])
//				meals[meal] = information
//			}
//		}
//	}
//	
//	init(date: NSDate, meals: Dictionary<MealType, MealInfo>) {
//		self.date = date
//		self.meals = meals
//	}
//	
//	required init(dict: Dictionary<String, AnyObject>) {
//		var form = NSDateFormatter()
//		form.dateStyle = .ShortStyle
//		
//		date = form.dateFromString(dict["date"] as! String)!
//		
//		meals = [:]
//		var mealsDict = dict["meals"] as! Dictionary<String, Dictionary<String, AnyObject>>
//		for mealDict in mealsDict.keys {
//			meals[MealType(rawValue: mealDict)!] = MealInfo(dict: mealsDict[mealDict]!)
//		}
//	}
//	
//	func dictFromObject() -> Dictionary<String, AnyObject> {
//		var form = NSDateFormatter()
//		form.dateStyle = .ShortStyle
//		
//		var dict: Dictionary<String, AnyObject> = [:]
//		
//		dict["date"] = form.stringFromDate(date)
//		var mealsDict: Dictionary<String, Dictionary<String, AnyObject>> = [:]
//		for meal in meals.keys {
//			mealsDict[meal.rawValue] = meals[meal]!.dictFromObject()
//		}
//		dict["meals"] = mealsDict
//		
//		return dict
//	}
//	
//	func formattedString() -> String {
//		var string = ""
//		for key in meals.keys {
//			if string != "" {
//				string = string + "ﬂ"
//			}
//			
//			string = string + "\(key.rawValue)Ø\(meals[key]!.formattedString())"
//		}
//		return string
//	}
//}
//
//class MealInfo: Serializable {
//	var halls: Dictionary<Halls, RestaurantInfo>
//	
//	init(halls: Dictionary<Halls, RestaurantInfo>) {
//		self.halls = halls
//	}
//	
//	init(formattedString: String) {
//		halls = [:]
//		let parts = formattedString.componentsSeparatedByString("‡")
//		for part in parts {
//			let dictParts = part.componentsSeparatedByString("¨")
//			let hall = Halls(rawValue: dictParts[0])!
//			let information = RestaurantInfo(formattedString: dictParts[1])
//			halls[hall] = information
//		}
//	}
//	
//	required init(dict: Dictionary<String, AnyObject>) {
//		halls = [:]
//		var hallsDict = dict["halls"] as! Dictionary<String, Dictionary<String, AnyObject>>
//		
//		for hall in hallsDict.keys {
//			halls[Halls(rawValue: hall)!] = RestaurantInfo(dict: hallsDict[hall]!)
//		}
//	}
//	
//	func dictFromObject() -> Dictionary<String, AnyObject> {
//		var dict: Dictionary<String, AnyObject> = [:]
//		
//		var hallsDict: Dictionary<String, Dictionary<String, AnyObject>> = [:]
//		for hall in halls.keys {
//			hallsDict[hall.rawValue] = halls[hall]!.dictFromObject()
//		}
//		dict["halls"] = hallsDict
//		
//		return dict
//	}
//	
//	func formattedString() -> String {
//		var string = ""
//		for key in halls.keys {
//			if string != "" {
//				string = string + "‡"
//			}
//			
//			string = string + "\(key.rawValue)¨\(halls[key]!.formattedString())"
//		}
//		return string
//	}
//}
//
//class RestaurantInfo: Serializable {
//	var hall: Halls // redundant storage?
//	
//	var openTime: Time = Time(hour: 8, minute: 0)
//	var closeTime: Time = Time(hour: 17, minute: 0)
//	
//	var sections: Array<SectionInfo>
//	
//	init(hall: Halls) {
//		self.hall = hall
//		self.sections = []
//	}
//	
//	init(formattedString: String) {
//		let parts = formattedString.componentsSeparatedByString("·")
//		hall = Halls(rawValue: parts[0])!
//		
//		let openParts = parts[1].componentsSeparatedByString("-")
//		openTime = Time(hour: openParts[0].toInt()!, minute: openParts[1].toInt()!)
//		
//		let closeParts = parts[2].componentsSeparatedByString("-")
//		closeTime = Time(hour: closeParts[0].toInt()!, minute: closeParts[1].toInt()!)
//		
//		sections = []
//		for section in parts[3..<parts.count] {
//			sections.append(SectionInfo(formattedString: section))
//		}
//	}
//	
//	required init(dict: Dictionary<String, AnyObject>) {
//		hall = Halls(rawValue: dict["hall"] as! String)!
//		openTime = Time(hour: dict["openHour"] as! Int, minute: dict["openMin"] as! Int)
//		closeTime = Time(hour: dict["closeHour"] as! Int, minute: dict["closeMin"] as! Int)
//		
//		sections = []
//		var sectionDicts = dict["sections"] as? Array<Dictionary<String, AnyObject>> ?? []
//		for sectionDict in sectionDicts {
//			sections.append(SectionInfo(dict: sectionDict))
//		}
//	}
//	
//	func dictFromObject() -> Dictionary<String, AnyObject> {
//		var dict: Dictionary<String, AnyObject> = [:]
//		
//		dict["hall"] = hall.rawValue
//		dict["openHour"] = openTime.hour
//		dict["openMin"] = openTime.minute
//		dict["closeHour"] = closeTime.hour
//		dict["closeMin"] = closeTime.minute
//		
//		var sectionDicts: Array<Dictionary<String, AnyObject>> = []
//		for section in sections {
//			sectionDicts.append(section.dictFromObject())
//		}
//		dict["sections"] = sectionDicts
//		
//		return dict
//	}
//	
//	func name(isHall: Bool) -> String {
//		return hall.displayName(isHall)
//	}
//	
//	func imageName(open: Bool) -> String {
//		return hall.imageName(open)
//	}
//	
//	func formattedString() -> String {
//		var string = "\(hall.rawValue)·\(openTime.hour)-\(openTime.minute)·\(closeTime.hour)-\(closeTime.minute)"
//		for section in sections {
//			string = string + "·\(section.formattedString())"
//		}
//		return string
//	}
//}
//
//class SectionInfo: Serializable {
//	var name: String = ""
//	var foods = [MainFoodInfo]()
//	
//	init(name: String) {
//		self.name = name
//	}
//	
//	init(formattedString: String) {
//		let parts = formattedString.componentsSeparatedByString("ª")
//		name = parts[0]
//		foods = []
//		for part in parts[1..<parts.count] {
//			if part != "" {
//				foods.append(MainFoodInfo(formattedString: part))
//			}
//		}
//	}
//	
//	func formattedString() -> String {
//		var foodStrings = [String]()
//		for food in foods { foodStrings.append(food.foodString()) }
//		
//		let foodsString = "ª".join(foodStrings)
//		return "\(name)ª\(foodsString)"
//	}
//	
//	required init(dict: Dictionary<String, AnyObject>) {
//		name = dict["name"] as? String ?? "No Name"
//		foods = []
//		var foodDicts = dict["foods"] as? Array<Dictionary<String, AnyObject>> ?? []
//		for foodDict in foodDicts {
//			foods.append(MainFoodInfo(dict: foodDict))
//		}
//	}
//	
//	func dictFromObject() -> Dictionary<String, AnyObject> {
//		var dict: Dictionary<String, AnyObject> = [:]
//		
//		dict["name"] = name
//		var foodDicts: Array<Dictionary<String, AnyObject>> = []
//		for food in foods {
//			foodDicts.append(food.dictFromObject())
//		}
//		dict["foods"] = foodDicts
//		
//		return dict
//	}
//}

// MARK:- STANDARD MODEL

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

class FoodInfo: Serializable {
	var name: String
	var recipe: String
	var type: FoodType
	var nutrition = [Nutrient : NutritionListing]()
	var ingredients: String = ""
	var description: String = ""
	var countryCode: String = ""
	
	init(name: String, recipe: String, type: FoodType) {
		self.name = name
		self.recipe = recipe
		self.type = type
		for nutrient in Nutrient.allValues {
			nutrition[nutrient] = NutritionListing(type: nutrient, measure: "0")
		}
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
		for nutr in nutrition.values.array {
			nutritionStrings.append(nutr.measure)
		}
		
		return "•".join(nutritionStrings)
	}
	
	func setNutrition(string: String) {
		let parts = string.componentsSeparatedByString("•")
		
		if parts.count == 1 && parts[0] == "" {
			nutrition = [:]
			for (index, nutr) in enumerate(Nutrient.allValues) {
				nutrition[nutr] = (NutritionListing(type: nutr, measure: "0"))
			}
		} else {
			nutrition = [:]
			for (index, nutr) in enumerate(Nutrient.allValues) {
				nutrition[nutr] = (NutritionListing(type: nutr, measure: parts[index]))
			}
		}
	}
	
	func foodString() -> String {
		return "\(name)°\(recipe)°\(type.rawValue)°\(nutritionString())°\(ingredients)°\(description)°\(countryCode)"
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
	
	required init(dict: Dictionary<String, AnyObject>) {
		name = dict["name"] as? String ?? "No Name"
		recipe = dict["recipe"] as? String ?? "No Recipe"
		type = FoodType(rawValue: dict["type"] as! String)!
		for nutrient in Nutrient.allValues {
			nutrition[nutrient] = NutritionListing(type: nutrient, measure: dict[nutrient.rawValue] as? String ?? "0")
		}
		ingredients = dict["ingredients"] as? String ?? ""
		description = dict["description"] as? String ?? ""
		countryCode = dict["country"] as? String ?? ""
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
	
	// MARK:- Serializable Protocol
	
	override func dictFromObject() -> Dictionary<String, AnyObject> {
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
		dict["withFood"] = withFood?.dictFromObject() ?? [:]
		
		return dict
	}
	
	required init(dict: Dictionary<String, AnyObject>) {
		super.init(dict: dict)
		
		let withFoodDict = dict["withFood"] as! Dictionary<String, AnyObject>
		if withFoodDict.count != 0 {
			withFood = SubFoodInfo(dict: withFoodDict)
		}
	}
}

class SubFoodInfo: FoodInfo {
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
	
	// MARK:- Serializable Protocol
	required init(dict: Dictionary<String, AnyObject>) {
		super.init(dict: dict)
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
	var date = comparisonDate(NSDate())
	var meals: Dictionary<MealType, MealBrief> = [:]
	var foods: Dictionary<String, FoodCollection> = [:]
	
	init() {
		
	}
	
	//	init(record: CKRecord) {
	//		date = record.objectForKey("Day") as! NSDate
	//		let formString = NSString(data: record.objectForKey("Data") as! NSData, encoding: NSUTF8StringEncoding) as! String
	//		let parts = formString.componentsSeparatedByString("ﬂ")
	//		for part in parts {
	//			let dictParts = part.componentsSeparatedByString("Ø")
	//			let meal = MealType(rawValue: dictParts[0])!
	//			let information = MealInfo(formattedString: dictParts[1])
	//			meals[meal] = information
	//		}
	//	}
	
	init(date: NSDate, meals: Dictionary<MealType, MealBrief>) {
		self.date = date
		self.meals = meals
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
	var halls: Dictionary<Halls, RestaurantBrief>
	
	init(halls: Dictionary<Halls, RestaurantBrief>) {
		self.halls = halls
	}
	
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

class RestaurantBrief: Serializable {
	var hall: Halls // redundant storage?
	
	var openTime: Time = Time(hour: 8, minute: 0)
	var closeTime: Time = Time(hour: 17, minute: 0)
	
	var sections: Array<SectionBrief>
	
	init(hall: Halls) {
		self.hall = hall
		self.sections = []
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
	
	func imageName(open: Bool) -> String {
		return hall.imageName(open)
	}
}

class SectionBrief: Serializable {
	var name: String = ""
	var foods = [FoodBrief]()
	
	init(name: String) {
		self.name = name
	}
	
	required init(dict: Dictionary<String, AnyObject>) {
		name = dict["name"] as? String ?? "No Name"
		foods = []
		var foodDicts = dict["foods"] as? Array<Dictionary<String, AnyObject>> ?? []
		for foodDict in foodDicts {
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
	var name: String
	var type: FoodType
	var recipe: String
	var sideBrief: FoodBrief?
	
	func dictFromObject() -> Dictionary<String, AnyObject> {
		return ["name" : name, "type" : type.rawValue, "recipe" : recipe]
	}
	
	required init(dict: Dictionary<String, AnyObject>) {
		name = dict["name"] as! String
		type = FoodType(rawValue: dict["type"] as! String)!
		recipe = dict["recipe"] as! String
	}
	
	init(name: String) {
		self.name = name
		type = .Regular
		recipe = ""
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

class TopFoodInfo: FoodInfo {
	var withFoodBrief: FoodBrief?
	
	// MARK:- Serializable Protocol
	required init(dict: Dictionary<String, AnyObject>) {
		super.init(dict: dict)
		
		let withFoodDict = dict["withFood"] as! Dictionary<String, AnyObject>
		if withFoodDict.count != 0 {
			withFoodBrief = FoodBrief(dict: withFoodDict)
		}
	}
	
	override func dictFromObject() -> Dictionary<String, AnyObject> {
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
		dict["withFood"] = withFoodBrief?.dictFromObject() ?? [:]
		
		return dict
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
	static let allMatchingXML: Array<String> = ["Cal", "FatCal", "TotFat", "SatFat", "TransFat", "Chol", "Sodium", "TotCarb", "DietFiber", "Sugar", "Protein", "VitA", "VitC", "Calcium", "Iron"]
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
	
	static func typeForXML(xml: String) -> Nutrient? {
		if let index = find(Nutrient.allMatchingXML, xml) {
			return Nutrient.allValues[index]
		}
		return nil
	}
	
	func hasDVpercentage() -> Bool {
		return Nutrient.allDailyValues[find(Nutrient.allRawValues, rawValue)!] != nil
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
		if let dailyValue = Nutrient.allDailyValues[(find(Nutrient.allValues, type))!] {
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
		var dow = NSCalendar.currentCalendar().component(.CalendarUnitWeekday, fromDate: date)
		return (dow == 1 || dow == 7) ? [.Brunch, .Dinner] : [.Breakfast, .Lunch, .Dinner]
	}
}