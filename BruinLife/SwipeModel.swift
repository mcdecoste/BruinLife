//
//  SwipeModel.swift
//  BruinLife
//
//  Created by Matthew DeCoste on 12/15/14.
//  Copyright (c) 2014 Matthew DeCoste. All rights reserved.
//

import UIKit

internal enum DaysOfWeekNames: String {
	case Mon = "Monday"
	case Tues = "Tuesday"
	case Wed = "Wednesday"
	case Thur = "Thursday"
	case Fri = "Friday"
	case Sat = "Saturday"
	case Sun = "Sunday"
	
	static let allValues = [Mon, Tues, Wed, Thur, Fri, Sat, Sun]
	static let allRawValues = DaysOfWeekNames.allValues.map { (dow: DaysOfWeekNames) -> String in return dow.rawValue }
}

internal enum WeekNames: String {
	case One = "Week One"
	case Two = "Week Two"
	case Three = "Week Three"
	case Four = "Week Four"
	case Five = "Week Five"
	case Six = "Week Six"
	case Seven = "Week Seven"
	case Eight = "Week Eight"
	case Nine = "Week Nine"
	case Ten = "Week Ten"
	case Final = "Finals Week"
	
	static let allValues = [One, Two, Three, Four, Five, Six, Seven, Eight, Nine, Ten, Final]
	static let allRawValues = WeekNames.allValues.map { (week: WeekNames) -> String in return week.rawValue }
}

internal enum QuarterType: String {
	case Fall = "Fall"
	case Winter = "Winter"
	case Spring = "Spring"
	
	static let allValues = [Fall, Winter, Spring]
	static let allRawValues = QuarterType.allValues.map { (quarter: QuarterType) -> String in return quarter.rawValue }
	static let startValues = [(2, Winter), (14, Spring), (41, Fall)]
}

internal enum MealPlanType: String {
	case BP19 = "Bruin Premier 19"
	case BP14 = "Bruin Premier 14"
	case G19 = "Gold 19"
	case G14 = "Gold 14"
	case C11 = "Cub 11"
	
	static let allValues = [C11, G14, G19, BP14, BP19]
	static let allRawValues = MealPlanType.allValues.map { (plan: MealPlanType) -> String in return plan.rawValue }
	
	var hasRollover: Bool {
		get {
			switch self {
			case BP19, BP14:
				return true
			default:
				return false
			}
		}
	}
	var weeklySwipes: Array<Int> {
		get {
			switch self {
			case BP19, G19:
				return [19, 16, 13, 10, 7, 4, 2, 0]
			case BP14, G14:
				return [14, 12, 10, 8, 6, 4, 2, 0]
			default:
				return [11, 9, 8, 6, 5, 3, 1, 0]
			}
		}
	}
	
	func mealSwipeDict(swipes: Int) -> Dictionary<MealType, Int> {
		switch swipes {
		case 3:
			return [.LateNight : 0, .Dinner : 0, .Lunch : 1, .Brunch : 2, .Breakfast : 2]
		case 2:
			return [.LateNight : 0, .Dinner : 0, .Lunch : 1, .Brunch : 1, .Breakfast : 1]
		default:
			return [.LateNight : 0, .Dinner : 0, .Lunch : 0, .Brunch : 0, .Breakfast : 0]
		}
	}
	
	func swipesLeft(week: Int, day: Int, meal: MealType) -> Int {
		let weekRemainder = weeklySwipes[day + 1]
		let rolloverSwipes = hasRollover ? (10 - week) * weeklySwipes[0] : 0
		return mealSwipeDict(weeklySwipes[day] - weeklySwipes[day + 1])[meal]! + weekRemainder + rolloverSwipes
	}
}

class SwipeModel: NSObject {
	let plans = MealPlanType.allValues
	let weeks = WeekNames.allValues
	let daysOfWeek = DaysOfWeekNames.allValues
	
	var mealPlan: MealPlanType = .BP19
	var selectedWeek = 0, selectedDay = 0, selectedMeal: MealType = .Lunch
	var currentQuarter: QuarterType? = nil
	
	var swipesForDay: Int {
		get {
			return mealPlan.swipesLeft(selectedWeek, day: selectedDay, meal: selectedMeal)
		}
	}
	var sameAsCurrent: Bool {
		var sameWeek = selectedWeek == currentWeekAndQuarter.week
		var sameDay = selectedDay == currentDayOfWeek
		var sameMeal = selectedMeal == currentMeal
		return sameWeek && sameDay && sameMeal
	}
	private var currentDayOfWeek: Int {
		// go from Sunday = 1, Saturday = 7 to Monday = 0, Sunday = 6
		get {
			return currCal.component(.CalendarUnitWeekday, fromDate: comparisonDate(5))
		}
	}
	
	/// Returns the current week and quarter (since they're related)
	var currentWeekAndQuarter: (week: Int, quarter: QuarterType?) {
		get {
			// decrement if sunday
			let weekOfYear = currCal.component(.CalendarUnitWeekOfYear, fromDate: currentDayOfWeek == 6 ? comparisonDate(-7) : comparisonDate())
			
			for (startWeek, quarter) in QuarterType.startValues {
				let currWeek = weekOfYear - startWeek
				switch currWeek {
				case 0...10:
					return (currWeek, quarter)
				default:
					continue
				}
			}
			
			return (0, nil) // default values
		}
	}
	
	override init() {
		super.init()
		resetToCurrent()
	}
	
	func resetToCurrent() {
		(selectedWeek, currentQuarter) = currentWeekAndQuarter
		selectedDay = currentDayOfWeek
		selectedMeal = currentMeal
	}
}