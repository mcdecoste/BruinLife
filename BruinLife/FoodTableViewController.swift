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
//	var image: UIImage? = UIImage(named: "Feast")
	var shortImage: UIImage?
	var tallImage: UIImage?
	var openTime: Time = Time(hr: 8, min: 0, isPM: false)
	var closeTime: Time = Time(hr: 5, min: 0, isPM: true)
	
	var foods: Array<FoodInfo> = [FoodInfo(name: "Thai Tea", image: nil), FoodInfo(name: "Sushi Bowl", image: nil), FoodInfo(name: "Angel Hair Pasta", image: nil), FoodInfo(name: "Turkey Burger", image: nil), FoodInfo(name: "Carne Asada Fries", image: nil), FoodInfo(name: "Barbeque Chicken Quesadilla", image: nil), FoodInfo(name: "Yogurt", image: nil), FoodInfo(name: "Pepperoni Pizza", image: nil), FoodInfo(name: "Chocolate Shake with Oreo", image: nil)]
	
	init(restName: String) {
		name = restName
	}
	
	init(restName: String, photoName: String) {
		name = restName
//		image = UIImage(named: photoName)
//		shortImage = UIImage(named: photoName + " Restaurant")
		tallImage = UIImage(named: photoName + " Dark")
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

class FoodTableViewController: UITableViewController, UIPopoverPresentationControllerDelegate {
	let kRestCellID = "FoodCell"
	var kRestCellHeight = 88
	let kFoodDisplayID = "DisplayCell"
	var kFoodDisplayHeight = 220
	let kFoodDisplayTag = 99
//	let mealVCid = "mealSelectionTableView"
	let foodVCid = "foodDescriptionViewController"
	
	var displayIndexPath: NSIndexPath = NSIndexPath(forRow: 0, inSection: -1)
	var displayCell: MenuTableViewCell?
	
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
		var selectionStyle: UITableViewCellSelectionStyle = .None
		
		var cellID = kRestCellID
		if indexPathHasFoodDisplay(indexPath) {
			cellID = kFoodDisplayID
			selectionStyle = .Default
		}
		
		let cellFrame = CGRect(x: 0, y: 0, width: self.tableView.frame.width, height: self.tableView(tableView, heightForRowAtIndexPath: indexPath))
		
		var cell = tableView.dequeueReusableCellWithIdentifier(cellID)! as FoodTableViewCell
		cell.selectionStyle = selectionStyle
		cell.frame = cellFrame
		cell.foodVC = self
		cell.changeInfo(itemData, andDate: information.date)
		
		if cellID == kFoodDisplayID {
			displayCell = cell as? MenuTableViewCell
		}
		
		return cell
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
		if hasInlineFoodDisplay() {
			// why not just ask about displayCell?
			if displayCell?.scrollView != nil { // found the MenuTableViewCell
				var index = displayIndexPath.row - 1
				var itemData = information.restForMeal[displayIndexPath.section].rests[index]
				
				displayCell?.updateInformation(itemData, controller: self)
			}
		}
	}
	
//	func showFoodPopover(food: FoodInfo) {
//		// TODO: put popover logic back in. Create popover with food's information.
//		println(food.name)
//	}
	
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
	
	func addFoodPopover(sender: FoodDisplay?){
		var foodVC = storyboard?.instantiateViewControllerWithIdentifier(foodVCid) as FoodViewController
		foodVC.setFood((sender?.food)!)
		
		foodVC.modalPresentationStyle = UIModalPresentationStyle.Popover
		foodVC.preferredContentSize = foodVC.preferredContentSize
		
		let ppc = foodVC.popoverPresentationController
		ppc?.permittedArrowDirections = UIPopoverArrowDirection.allZeros
		ppc?.delegate = self
		ppc?.sourceView = tableView // or source rect or barbuttonitem
		
		var anchorFrame = tableView.rectForRowAtIndexPath(displayIndexPath)
		
//		ppc?.sourceRect = CGRect(origin: tableView.bounds.origin, size: CGSizeZero)
		let xVal = (anchorFrame.origin.x) + anchorFrame.size.width / 2.0
		let yVal = ((anchorFrame.origin.y) + anchorFrame.size.height / 2.0) + 11.0
		ppc?.sourceRect = CGRect(x: xVal, y: yVal, width: 0.0, height: 0.0)
//		ppc?.sourceRect = CGRect(x: tableView.center.x, y: tableView.center.y, width: 0, height: 0)
		presentViewController(foodVC, animated: true, completion: nil)
		
//		popoverPresentationViewController?.barButtonItem = sender
	}
	
	// MARK: UIPopoverPresentationControllerDelegate
	
	func adaptivePresentationStyleForPresentationController(controller: UIPresentationController!) -> UIModalPresentationStyle{
		return .None
	}
}
