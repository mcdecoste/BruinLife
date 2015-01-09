//
//  Helpers.swift
//  BruinLife
//
//  Created by Matthew DeCoste on 12/16/14.
//  Copyright (c) 2014 Matthew DeCoste. All rights reserved.
//

import UIKit

var timeInDay: Double = 24*60*60

/// Returns the most likely Meal given the time
func currentMeal() -> MealType {
	var hour = NSCalendar.currentCalendar().component(.CalendarUnitHour, fromDate: NSDate())
	
	if hour <= 3 { return .LateNight }
	if hour <= 10 { return .Breakfast }
	if hour <= 15 { return .Lunch }
	if hour <= 20 { return .Dinner }
	return .LateNight
}

func orderedMeals(meals: Array<MealType>) -> Array<MealType> {
	var mealByValue: Dictionary<MealType, Int> = [.Breakfast : 1, .Lunch : 2, .Brunch : 2, .Dinner : 3, .LateNight : 4]
	var remainingMeals = meals
	var orderedMeals: Array<MealType> = []
	
	while remainingMeals.count > 0 {
		var nextMeal = remainingMeals[0]
		for meal in remainingMeals {
			if mealByValue[meal] < mealByValue[nextMeal] { nextMeal = meal }
		}
		
		orderedMeals.append(nextMeal)
		remainingMeals.removeAtIndex((find(remainingMeals, nextMeal))!)
	}
	
	return orderedMeals
}

func defaultFoods() -> Array<MainFoodInfo> {
	var lastFood = MainFoodInfo(name: "Super Awesome Angel Hair Pasta", recipe: "000007", type: .Regular)
	lastFood.withFood = SubFoodInfo(name: "Garlic Bread", recipe: "000008", type: .Vegetarian)
	
	var theFoods = [MainFoodInfo(name: "Greek Cream of Roaster Garlic & Cauliflower Soup", recipe: "000001", type: .Regular), MainFoodInfo(name: "Italian Minestrone Soup", recipe: "000002", type: .Vegetarian), MainFoodInfo(name: "Mediterranean Spiced Beef Soup", recipe: "000003", type: .Regular), MainFoodInfo(name: "Chicken Pasta w/ Lemon Caper Sauce", recipe: "000004", type: .Regular), MainFoodInfo(name: "Linguini w/ Lemon Sauce", recipe: "000005", type: .Vegan), MainFoodInfo(name: "Chicken Keftedes Pita Sandwich", recipe: "000006", type: .Regular), lastFood]
	
	var theValues = [130, 30, 8, 6, 2, 24, 123, 25, 4, 3, 6, 31, 2, 3, 6]
	
	for food in theFoods {
		food.description = "White wine marinated chicken breast sautéed with garlic and parsley. Tossed with ziti noodles and fragrant lemon caper sauce."
		food.countryCode = "Hawaii"
		food.ingredients = "Lemon Caper Sauce.. (Water, Fresh Lemon Juice, Capers, Flour, Butter, Vegetarian Base, Garlic Powder, Onion Powder), Ziti Noodles (Ziti Pasta, Olive Oil Blend, Sea Salt), Marinated Chicken Breast (Chicken Breast, Garlic, Poultry Marinade (Chablis Wine, Olive Oil Blend, Garlic, Sea Salt, Black Pepper)), Garlic, Parsley"
		for (index, listing) in enumerate(food.nutrition) {
			food.nutrition[index] = NutritionListing(type: Nutrient.allValues[index], measure: "\(theValues[index])")
		}
	}
	
	return theFoods
}