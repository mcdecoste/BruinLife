//
//  FoodTableViewController.swift
//  BruinLife
//
//  Created by Matthew DeCoste on 11/27/14.
//  Copyright (c) 2014 Matthew DeCoste. All rights reserved.
//

import UIKit

struct Time {
	var hour: Int
	var minute: Int
	var PM: Bool = true
	
	init(hr: Int, min: Int, isPM: Bool) {
		hour = hr
		minute = min
		if isPM { hour += 12 }
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
	var name:String = ""
	var image: UIImage? = nil
	var openTime: Time = Time(hr: 8, min: 0, isPM: false)
	var closeTime: Time = Time(hr: 5, min: 0, isPM: true)
	
	var foods: Array<FoodInfo> = []
	
	init(restName: String) {
		name = restName
		foods = [FoodInfo(name: "Default", image: nil)]
	}
	init(restName: String, foodList: Array<FoodInfo>) {
		name = restName
		foods = foodList
	}
}

struct FoodInfo {
	var name: String = ""
	var image: UIImage?
	
	// TODO: add nutritional information
}

enum MealType : String {
	case Breakfast = "Breakfast"
	case Lunch = "Lunch"
	case Dinner = "Dinner"
	case Brunch = "Brunch"
	case LateNight = "Late Night"
}

class FoodTableViewController: UITableViewController /*, UIPopoverPresentationControllerDelegate */ {
	let kRestCellID = "FoodCell"
	var kRestCellHeight = 88
	let kFoodDisplayID = "DisplayCell"
	var kFoodDisplayHeight = 220
	let kFoodDisplayTag = 99
	let mealVCid = "mealSelectionTableView"
	
	var displayIndexPath: NSIndexPath = NSIndexPath(forRow: 0, inSection: -1)
	var information = DayInfo()
	var pageIndex = 0
	
    override func viewDidLoad() {
        super.viewDidLoad()
    }
	
	/// Returns the desired title for the page view controller's navbar
	func preferredTitle() -> String {
		return ""
	}
	
	// MARK: Table view data source
	override func tableView(tableView: UITableView, heightForRowAtIndexPath indexPath: NSIndexPath) -> CGFloat {
		return indexPathHasFoodDisplay(indexPath) ? CGFloat(kFoodDisplayHeight) : CGFloat(kRestCellHeight)
	}
	
	override func numberOfSectionsInTableView(tableView: UITableView) -> Int {
		// Return the number of sections.
		return information.restForMeal.count
	}
	
	override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
		var rowCount = information.restForMeal[section].rests.count
		
		if (hasInlineFoodDisplay() && displayIndexPath.section == section) {
			rowCount++
		}
		
		return rowCount
	}
	
	override func tableView(tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
		return information.restForMeal[section].meal.rawValue
	}
	
	override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
		var shouldDecr = hasInlineFoodDisplay() && displayIndexPath.row <= indexPath.row
		var modelRow = shouldDecr ? indexPath.row - 1 : indexPath.row
		var itemData = information.restForMeal[indexPath.section].rests[modelRow]
		
		var cellID = kRestCellID
		if indexPathHasFoodDisplay(indexPath) {
			cellID = kFoodDisplayID
		}
		
		if cellID == kRestCellID {
			var cell = tableView.dequeueReusableCellWithIdentifier(cellID)! as RestaurantTableViewCell
			cell.selectionStyle = .Default
			cell.frame = CGRect(x: 0, y: 0, width: self.tableView.frame.width, height: self.tableView(tableView, heightForRowAtIndexPath: indexPath))
			cell.changeInfo(itemData, andDate: information.date)
			
			return cell
		} else {
			var cell = tableView.dequeueReusableCellWithIdentifier(cellID)! as UITableViewCell
			cell.selectionStyle = .None
			
			// populate the display
			cell.textLabel?.text = "I AM FOODS"
			
			return cell
		}
	}
	
	// MARK: Delegate
	
	override func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
		var cell = (tableView.cellForRowAtIndexPath(indexPath))!
		if cell.reuseIdentifier == kRestCellID {
			displayInlineFoodDisplayForRowAtIndexPath(indexPath)
		}
		
		tableView.deselectRowAtIndexPath(indexPath, animated:true)
	}
	
	// MARK: Utilities
	
	func hasDisplayForIndexPath(indexPath: NSIndexPath) -> Bool {
		var targetedRow = indexPath.row + 1
		
		var checkDisplayCell: UITableViewCell? = tableView.cellForRowAtIndexPath(NSIndexPath(forRow: targetedRow, inSection: indexPath.section))
		var checkFoodDisplay = checkDisplayCell?.viewWithTag(kFoodDisplayTag) as FoodsScrollView?
		
		return checkFoodDisplay != nil // has date picker
	}
	
	func updateFoodDisplay() {
//		if hasInlineFoodDisplay() {
//			var associatedDisplayCell = tableView.cellForRowAtIndexPath(displayIndexPath)
//			var targetedDisplay = associatedDisplayCell?.viewWithTag(kFoodDisplayTag) as FoodsScrollView?
//			
//			if targetedDisplay != nil { // found UIDatePicker
//				var index = displayIndexPath.row - 1
//				var itemData = dataArray[index]
//				
//				// TDOO: put this back in
//				// targetedDisplay?.setData(nil);
//			}
//		}
	}
	
	func hasInlineFoodDisplay() -> Bool {
		return displayIndexPath.section != -1
	}
	
	func indexPathHasFoodDisplay(indexPath: NSIndexPath) -> Bool {
		var bool1 = hasInlineFoodDisplay()
		var bool2 = indexPath.row == displayIndexPath.row
		var bool3 = indexPath.section == displayIndexPath.section
		return bool1 && bool2 && bool3
	}
	
	func displayInlineFoodDisplayForRowAtIndexPath(indexPath: NSIndexPath) {
		tableView.beginUpdates()
		
		var before = false
		var replaceDisplayWithNew = false
		var deletingDisplay = hasInlineFoodDisplay()
		
		var shouldScroll = false
		
		if deletingDisplay {
			replaceDisplayWithNew = (displayIndexPath.section != indexPath.section) || (indexPath.row != displayIndexPath.row - 1)
			before = (displayIndexPath.section == indexPath.section) && (displayIndexPath.row < indexPath.row)
			
			// remove any existing display cell
			tableView.deleteRowsAtIndexPaths([displayIndexPath], withRowAnimation: .Fade)
			displayIndexPath = NSIndexPath(forRow: 0, inSection: -1)
		}
		
		if replaceDisplayWithNew || (!deletingDisplay && (displayIndexPath.row - 1 != indexPath.row)) {
			// show new display
			var rowToReveal = before ? indexPath.row : indexPath.row + 1
			var indexPathToReveal = NSIndexPath(forRow: rowToReveal, inSection: indexPath.section)
			
			tableView.insertRowsAtIndexPaths([indexPathToReveal], withRowAnimation: .Fade)
			displayIndexPath = NSIndexPath(forRow: indexPathToReveal.row, inSection: indexPath.section)
			
			tableView.deselectRowAtIndexPath(indexPath, animated: true)
			shouldScroll = true
		}
		
		tableView.endUpdates()
		
		if (shouldScroll) {
			tableView.scrollToRowAtIndexPath(displayIndexPath, atScrollPosition: .Middle, animated: true)
		}
		
		updateFoodDisplay()
	}
}
