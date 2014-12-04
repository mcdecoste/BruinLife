//
//  FoodTableViewController.swift
//  BruinLife
//
//  Created by Matthew DeCoste on 11/27/14.
//  Copyright (c) 2014 Matthew DeCoste. All rights reserved.
//

import UIKit

struct RestaurantInfo {
	var name:String = "Hello"
	var image: UIImage?
	var openDate: NSDate?
	var closeDate: NSDate?
	
	init(restName: String) {
		name = restName
		image = nil
		openDate = nil
		closeDate = nil
	}
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
	
//	var dataArray:Array<RestaurantInfo> = []
	var displayIndexPath: NSIndexPath = NSIndexPath(forRow: 0, inSection: -1)
	
//	var currMeal: MealType = .Lunch // default value
	
	var information = DayInfo()
	
	var pageIndex = 0
	
    override func viewDidLoad() {
        super.viewDidLoad()
		
//		self.navigationItem.rightBarButtonItem = UIBarButtonItem(title: mealButtonTitle(), style: .Plain, target: self, action: "addMealPopover:")
    }
	
	/// Returns the desired title for the page view controller's navbar
	func preferredTitle() -> String {
		return ""
	}
	
	// MARK: Meal Selection
	
//	func mealButtonTitle() -> String {
//		return currMeal.rawValue
//	}
//	
//	func setNewMeal(newMeal: MealType) {
//		currMeal = newMeal
//		self.navigationItem.rightBarButtonItem?.title = mealButtonTitle()
//	}
	
//	func addMealPopover(sender: UIBarButtonItem?){
//		var mealVC = storyboard?.instantiateViewControllerWithIdentifier(mealVCid) as MealSelectionTableViewController
//		
//		mealVC.foodVC = self
//		mealVC.meal = currMeal
//		mealVC.setDate(NSDate())
//		mealVC.isDorm = false
//		
//		mealVC.modalPresentationStyle = .Popover
//		mealVC.preferredContentSize = mealVC.preferredContentSize
//		
//		let popoverPresentationViewController = mealVC.popoverPresentationController
//		popoverPresentationViewController?.permittedArrowDirections = .Up
//		popoverPresentationViewController?.delegate = self
//		popoverPresentationViewController?.barButtonItem = sender
//		presentViewController(mealVC, animated: true, completion: nil)
//	}
	
	// MARK: UIPopoverPresentationControllerDelegate
	
//	func adaptivePresentationStyleForPresentationController(controller: UIPresentationController!) -> UIModalPresentationStyle{
//		return .None
//	}
	
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
		
//		return (hasInlineFoodDisplay() ? dataArray.count+1 : dataArray.count)
	}
	
	override func tableView(tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
		return information.restForMeal[section].meal.rawValue
	}
	
	override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
		var cellID = kRestCellID
		var cellHeight = kRestCellHeight
		var selStyle = UITableViewCellSelectionStyle.Default
		if indexPathHasFoodDisplay(indexPath) {
			cellID = kFoodDisplayID
			cellHeight = kFoodDisplayHeight
			selStyle = .None
		}
		
		var cell: UITableViewCell = tableView.dequeueReusableCellWithIdentifier(cellID)! as UITableViewCell
		cell.selectionStyle = selStyle
		
		var shouldDecr = hasInlineFoodDisplay() && displayIndexPath.row <= indexPath.row
		var modelRow = shouldDecr ? indexPath.row - 1 : indexPath.row
		var itemData = information.restForMeal[indexPath.section].rests[modelRow]
		
		if cellID == kRestCellID {
			cell.textLabel?.text = itemData.name
		} else {
			// populate the display
			cell.textLabel?.text = "I AM FOODS"
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
	
	
	
    /*
    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCellWithIdentifier("reuseIdentifier", forIndexPath: indexPath) as UITableViewCell

        // Configure the cell...

        return cell
    }
    */

    /*
    // Override to support conditional editing of the table view.
    override func tableView(tableView: UITableView, canEditRowAtIndexPath indexPath: NSIndexPath) -> Bool {
        // Return NO if you do not want the specified item to be editable.
        return true
    }
    */

    /*
    // Override to support editing the table view.
    override func tableView(tableView: UITableView, commitEditingStyle editingStyle: UITableViewCellEditingStyle, forRowAtIndexPath indexPath: NSIndexPath) {
        if editingStyle == .Delete {
            // Delete the row from the data source
            tableView.deleteRowsAtIndexPaths([indexPath], withRowAnimation: .Fade)
        } else if editingStyle == .Insert {
            // Create a new instance of the appropriate class, insert it into the array, and add a new row to the table view
        }    
    }
    */

    /*
    // Override to support rearranging the table view.
    override func tableView(tableView: UITableView, moveRowAtIndexPath fromIndexPath: NSIndexPath, toIndexPath: NSIndexPath) {

    }
    */

    /*
    // Override to support conditional rearranging of the table view.
    override func tableView(tableView: UITableView, canMoveRowAtIndexPath indexPath: NSIndexPath) -> Bool {
        // Return NO if you do not want the item to be re-orderable.
        return true
    }
    */

    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
//	override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
//		// Get the new view controller using [segue destinationViewController].
//		// Pass the selected object to the new view controller.
//		
//		if (segue.identifier == mealSegue) {
//			var dest = segue.destinationViewController as MealSelectionNavigationController
//			
//			dest.foodVC = self
//			dest.selectedDate = NSDate()
//			dest.selectedMeal = currMeal
//			dest.isDorm = false
//		}
//	}
//	
	
	// MARK: Utilities
	
	func hasDisplayForIndexPath(indexPath: NSIndexPath) -> Bool {
		var targetedRow = indexPath.row + 1
		
		var checkDisplayCell: UITableViewCell? = tableView.cellForRowAtIndexPath(NSIndexPath(forRow: targetedRow, inSection: indexPath.section))
		var checkFoodDisplay = checkDisplayCell?.viewWithTag(kFoodDisplayTag) as FoodsScrollView?
		
		return checkFoodDisplay != nil // has date picker
	}
	
	func updateFoodDisplay() {
//		return // other stuff isn't ready yet
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
//		if (displayIndexPath.row != tableView.numberOfRowsInSection(displayIndexPath.section)) {
//			tableView.scrollToRowAtIndexPath(displayIndexPath, atScrollPosition: .Middle, animated: true)
//		} else {
//			tableView.scrollToRowAtIndexPath(indexPath, atScrollPosition: .Middle, animated: true)
//		}
		
		updateFoodDisplay()
	}

}
