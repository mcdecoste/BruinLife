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
		switch (type) {
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

class FoodTableViewController: UITableViewController, UIPopoverPresentationControllerDelegate {
	let kRestCellID = "FoodCell"
	var kRestCellHeight = 88
	let kFoodDisplayID = "DisplayCell"
	var kFoodDisplayHeight = 220
	let kFoodDisplayTag = 99
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
		
		foodVC.modalPresentationStyle = UIModalPresentationStyle.Popover
		foodVC.preferredContentSize = foodVC.preferredContentSize
		
		let ppc = foodVC.popoverPresentationController
		ppc?.permittedArrowDirections = UIPopoverArrowDirection.allZeros
		ppc?.delegate = self
		ppc?.sourceView = tableView // or source rect or barbuttonitem
		
		var anchorFrame = tableView.rectForRowAtIndexPath(displayIndexPath)
		
		let xVal = (anchorFrame.origin.x) + anchorFrame.size.width / 2.0
		let yVal = ((anchorFrame.origin.y) + anchorFrame.size.height / 2.0) + 11.0
		ppc?.sourceRect = CGRect(x: xVal, y: yVal, width: 0.0, height: 0.0)
		presentViewController(foodVC, animated: true, completion: nil)
		foodVC.setFood((sender?.food)!)
	}
	
	// MARK: UIPopoverPresentationControllerDelegate
	
	func adaptivePresentationStyleForPresentationController(controller: UIPresentationController!) -> UIModalPresentationStyle{
		return .None
	}
	
	
	// MARK: ScrollViewDelegate
	override func scrollViewDidScroll(scrollView: UIScrollView) {
		var cells = tableView.visibleCells() as Array<FoodTableViewCell>
		for cell in cells {
			var percent = (cell.frame.origin.y - scrollView.contentOffset.y) / scrollView.frame.height
			cell.parallaxImageWithScrollPercent(percent)
		}
	}
}
