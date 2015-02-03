//
//  FoodTableViewController.swift
//  BruinLife
//
//  Created by Matthew DeCoste on 11/27/14.
//  Copyright (c) 2014 Matthew DeCoste. All rights reserved.
//

import UIKit
import CoreData
import CloudKit

enum FoodControllerLoadState: Int {
	case Loading = 0
	case Failed = 1
}

class FoodTableViewController: UITableViewController, UIPopoverPresentationControllerDelegate, UICollectionViewDataSource, UICollectionViewDelegate {
	let kRestCellID = "FoodCell"
	let kRestCellHeight = 88
	let kFoodDisplayID = "DisplayCell"
	let kFoodDisplayHeight = 220
	let foodVCid = "foodDescriptionViewController"
	
	var displayIndexPath: NSIndexPath = NSIndexPath(forRow: 0, inSection: -1)
	var displayCell: MenuTableViewCell?
	var information = DayInfo()
	var dateMeals = [MealType]()
	
	var pageIndex = 0
	var isHall = true
	
	var loadState: FoodControllerLoadState = .Loading
	
	// Core Data
	
	lazy var managedObjectContext : NSManagedObjectContext? = {
		let appDelegate = UIApplication.sharedApplication().delegate as AppDelegate
		if let managedObjectContext = appDelegate.managedObjectContext {
			return managedObjectContext
		}
		else {
			return nil
		}
	}()
	
	override func viewDidLoad() {
		super.viewDidLoad()
		
		tableView.registerClass(UITableViewCell.self, forCellReuseIdentifier: "EmptyCell")
	}
	
	override func viewWillAppear(animated: Bool) {
		super.viewWillAppear(animated)
		tableView.separatorStyle = .None
		
		if hasData() {
			for cell in tableView.visibleCells() as Array<FoodTableViewCell> {
				cell.updateDisplay()
			}
		}
		
		NSNotificationCenter.defaultCenter().addObserver(self, selector: "handleDataChange:", name: "NewDayInfoAdded", object: nil)
	}
	
	override func viewDidAppear(animated: Bool) {
		super.viewDidAppear(animated)
		
		// Check how much to do this
		refreshParallax()
		scrollToMeal()
		refreshParallax()
	}
	
	override func viewWillDisappear(animated: Bool) {
		super.viewWillDisappear(animated)
		
		NSNotificationCenter.defaultCenter().removeObserver(self, name: "NewDayInfoAdded", object: nil)
	}
	
	// MARK: - Core Data
	
	func handleDataChange(notification: NSNotification) {
		let dDay = notification.userInfo!["newItem"] as DiningDay
		
		if dDay.day == comparisonDate() {
			information = DayInfo(date: dDay.day, formattedString: dDay.data)
			dateMeals = orderedMeals(information.meals.keys.array)
			dispatch_async(dispatch_get_main_queue()) {
				self.tableView.reloadData()
				self.refreshControl = nil
				self.scrollToMeal()
			}
		}
	}
	
	// MARK: - Helpers
	
	func loadFailed(error: NSError!) {
		dispatch_async(dispatch_get_main_queue()) {
			self.loadState = .Failed
			self.tableView.reloadData()
			
			if let refresher = self.refreshControl {
				refresher.endRefreshing()
			} else {
				self.refreshControl = UIRefreshControl()
				self.refreshControl!.addTarget(self, action: "retryLoad", forControlEvents: .ValueChanged)
			}
		}
	}
	
	func retryLoad() {
		CloudManager.sharedInstance.fetchRecords("DiningDay", completion: { (error: NSError!) -> Void in
			if error != nil { // handle error case
				self.loadFailed(error)
			}
		})
	}
	
	func hasData() -> Bool {
		return information.meals.count != 0
	}
	
	func scrollToMeal() {
		if representsToday(information.date) {
			var currMeal = currentMeal()
			var sectionToShow = 0
			
			for (index, meal) in enumerate(orderedMeals(information.meals.keys.array)) {
				if meal.equalTo(currMeal) {
					sectionToShow = index
					break
				}
			}
			tableView.scrollToRowAtIndexPath(NSIndexPath(forRow: 0, inSection: sectionToShow), atScrollPosition: .Top, animated: true)
		}
	}
	
	func refreshParallax() {
		if hasData() {
			for cell in (tableView.visibleCells() as Array<FoodTableViewCell>) {
				var percent = (cell.frame.origin.y - tableView.contentOffset.y) / tableView.frame.height
				cell.parallaxImageWithScrollPercent(percent)
			}
		}
	}
	
	// MARK: - Table view data source
	override func tableView(tableView: UITableView, heightForRowAtIndexPath indexPath: NSIndexPath) -> CGFloat {
		return indexPathHasFoodDisplay(indexPath) ? CGFloat(kFoodDisplayHeight) : CGFloat(kRestCellHeight)
	}
	
	override func numberOfSectionsInTableView(tableView: UITableView) -> Int {
		return hasData() ? information.meals.count : 1
	}
	
	override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
		if !hasData() { return 1 }
		
		var currDate = information.date
		var sectionMeal = dateMeals[section]
		var mealInfo = (information.meals[sectionMeal])!
		
		var rowCount = mealInfo.halls.count
		if (hasInlineFoodDisplay() && displayIndexPath.section == section) { rowCount++ }
		
		return rowCount
	}
	
	override func tableView(tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
		return hasData() ? dateMeals[section].rawValue : ""
	}
	
	override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
		if !hasData() {
			var cell = tableView.dequeueReusableCellWithIdentifier("EmptyCell")! as UITableViewCell
			
			cell.textLabel?.text = loadState == .Loading ? "Loading menu information" : "Load failed. Pull down to retry."
			if loadState == .Loading {
				cell.accessoryView = UIActivityIndicatorView(activityIndicatorStyle: .Gray)
				(cell.accessoryView as UIActivityIndicatorView).startAnimating()
			}
			return cell
		}
		
		
		var shouldDecr = hasInlineFoodDisplay() && displayIndexPath.row <= indexPath.row && displayIndexPath.section == indexPath.section
		var modelRow = shouldDecr ? indexPath.row - 1 : indexPath.row
		
		var allHalls = (information.meals[dateMeals[Int(indexPath.section)]]?.halls)!
		var restaurant = (allHalls[allHalls.keys.array[modelRow]])!
		
		var cellID = kRestCellID
		var selectionStyle: UITableViewCellSelectionStyle = .None
		if indexPathHasFoodDisplay(indexPath) {
			cellID = kFoodDisplayID
			selectionStyle = .Default
		}
		
		let cellFrame = CGRect(x: 0, y: 0, width: tableView.frame.width, height: self.tableView(tableView, heightForRowAtIndexPath: indexPath))
		
		var cell = tableView.dequeueReusableCellWithIdentifier(cellID)! as FoodTableViewCell
		cell.selectionStyle = selectionStyle
		cell.frame = cellFrame
		cell.foodVC = self
		cell.changeInfo(restaurant, andDate: information.date, isHall: isHall)
		
		if cellID == kFoodDisplayID { displayCell = cell as? MenuTableViewCell }
		
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
	
	// MARK: - Utilities
	func updateFoodDisplay() {
		if hasInlineFoodDisplay() {
			// why not just ask about displayCell?
			if displayCell?.collectionView != nil { // found the MenuTableViewCell
				var displayRow = displayIndexPath.row - 1
				
				var allHalls = (information.meals[dateMeals[Int(displayIndexPath.section)]]?.halls)!
				var hallForRow = allHalls.keys.array[displayRow]
				var restaurant = (allHalls[hallForRow])!
				
				displayCell?.changeInfo(restaurant, andDate: information.date, isHall: isHall)
				displayCell!.collectionView?.invalidateIntrinsicContentSize()
				displayCell!.collectionView?.scrollToItemAtIndexPath(NSIndexPath(forItem: 0, inSection: 0), atScrollPosition: .Left, animated: true)
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
		var newDisplayBelowOld = false
		
		if deletingDisplay {
			replaceDisplayWithNew = (displayIndexPath.section != indexPath.section) || (indexPath.row != displayIndexPath.row - 1)
			before = (displayIndexPath.section == indexPath.section) && (displayIndexPath.row < indexPath.row)
			
			// remove any existing display cell
			tableView.deleteRowsAtIndexPaths([displayIndexPath], withRowAnimation: .Fade)
			displayIndexPath = NSIndexPath(forRow: 0, inSection: -1)
		}
		
		if replaceDisplayWithNew || (!deletingDisplay && (displayIndexPath.row - 1 != indexPath.row)) {
			newDisplayBelowOld = before
			
			// show new display
			var rowToReveal = before ? indexPath.row : indexPath.row + 1
			var indexPathToReveal = NSIndexPath(forRow: rowToReveal, inSection: indexPath.section)
			
			tableView.insertRowsAtIndexPaths([indexPathToReveal], withRowAnimation: .Fade)
			displayIndexPath = NSIndexPath(forRow: indexPathToReveal.row, inSection: indexPath.section)
			
			tableView.deselectRowAtIndexPath(indexPath, animated: true)
			shouldScroll = true
		}
		
		tableView.endUpdates()
		
		if shouldScroll {
			var pathToShow = newDisplayBelowOld ? NSIndexPath(forRow: indexPath.row-1, inSection: indexPath.section) : indexPath
			tableView.scrollToRowAtIndexPath(pathToShow, atScrollPosition: .Top, animated: true)
		}
		
		updateFoodDisplay()
	}
	
	// MARK: ScrollViewDelegate
	override func scrollViewDidScroll(scrollView: UIScrollView) {
		if scrollView == tableView {
			refreshParallax()
		}
	}
	
	// MARK: - Popovers
	func addFoodPopover(food: MainFoodInfo?){
		var foodVC = storyboard?.instantiateViewControllerWithIdentifier(foodVCid) as FoodViewController
		
		foodVC.modalPresentationStyle = UIModalPresentationStyle.Popover
		foodVC.preferredContentSize = foodVC.preferredContentSize
		foodVC.foodVC = self
		
		let ppc = foodVC.popoverPresentationController
		ppc?.permittedArrowDirections = UIPopoverArrowDirection.allZeros
		ppc?.delegate = self
		ppc?.sourceView = tableView // or source rect or barbuttonitem
		
		var anchorFrame = tableView.rectForRowAtIndexPath(displayIndexPath)
		
		let xVal = (anchorFrame.origin.x) + anchorFrame.size.width / 2.0
		let yVal = ((anchorFrame.origin.y) + anchorFrame.size.height / 2.0) + 11.0
		ppc?.sourceRect = CGRect(x: xVal, y: yVal, width: 0.0, height: 0.0)
		presentViewController(foodVC, animated: true, completion: nil)
		
		foodVC.setFood(food!, date: information.date, meal: dateMeals[displayIndexPath.section], place: (displayCell?.information)!)
	}
	
	// MARK: UIPopoverPresentationControllerDelegate
	func adaptivePresentationStyleForPresentationController(controller: UIPresentationController!) -> UIModalPresentationStyle{
		return .None
	}
	
	// MARK: - UICollectionViewDataSource
	func collectionView(collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
		return (displayCell?.information?.sections[section].foods.count)!
	}
	
	func collectionView(collectionView: UICollectionView, cellForItemAtIndexPath indexPath: NSIndexPath) -> UICollectionViewCell {
		var restaurant = displayCell?.information
		var food = restaurant?.sections[indexPath.section].foods[indexPath.row]
		var cell = collectionView.dequeueReusableCellWithReuseIdentifier("foodDisplay", forIndexPath: indexPath) as FoodCollectionViewCell
		cell.setFood(restaurant!.sections[indexPath.section].foods[indexPath.row], isHall: isHall)
		return cell
	}
	
	func numberOfSectionsInCollectionView(collectionView: UICollectionView) -> Int {
		return displayCell!.information!.sections.count
	}
	
	func collectionView(collectionView: UICollectionView, viewForSupplementaryElementOfKind kind: String, atIndexPath indexPath: NSIndexPath) -> UICollectionReusableView {
		var header = collectionView.dequeueReusableSupplementaryViewOfKind(kind, withReuseIdentifier: "headerCell", forIndexPath: indexPath) as SectionCollectionReusableView
		header.setTitle((displayCell?.information?.sections[indexPath.section].name)!)
		
		var flow = collectionView.collectionViewLayout as HorizontalFlow
		while flow.headerWidths.count - indexPath.section < 1 {
			flow.headerWidths.append(240)
		}
		flow.headerWidths[indexPath.section] = header.title.frame.width
		
		return header
	}
	
	// MARK: UICollectionViewDelegate
	func collectionView(collectionView: UICollectionView, didSelectItemAtIndexPath indexPath: NSIndexPath) {
		var restaurant = displayCell?.information
		addFoodPopover(restaurant?.sections[indexPath.section].foods[indexPath.row])
	}
}
