//
//  FoodTableViewController.swift
//  BruinLife
//
//  Created by Matthew DeCoste on 11/27/14.
//  Copyright (c) 2014 Matthew DeCoste. All rights reserved.
//

import UIKit

enum FoodControllerLoadState: Int {
	case Loading = 0
	case Failed = 1
	case Expanding = 2
	case Hiding = 3
	case Done = 4
	
	func showActivity() -> Bool {
		switch self {
		case Loading, Expanding:
			return true
		default:
			return false
		}
	}
}

class FoodTableViewController: UITableViewController, UIPopoverPresentationControllerDelegate, UICollectionViewDataSource, UICollectionViewDelegate, UIAlertViewDelegate {
	let kRestCellID = "FoodCell", kRestCellHeight: CGFloat = 88
	let kFoodDisplayID = "DisplayCell", kFoodDisplayHeight: CGFloat = 220
	let EmptyCellID = "EmptyCell"
	
	let foodVCid = "foodDescriptionViewController"
	let refresh: Selector = "retryLoad"
	
	var displayIndexPath: NSIndexPath?
	var displayCell: MenuTableViewCell?
	var informationData: NSData = NSData() {
		didSet {
			loadState = .Expanding // will reload tableview
			setInformationIfNeeded()
		}
	}
	var information: DayBrief = DayBrief() {
		didSet {
			loadState = hasData ? .Done : .Failed
		}
	}
	internal var dateMeals: Array<MealType> { get { return orderedMeals(information.meals.keys.array) } }
	internal var isHall: Bool { get { return true } }
	internal var loadState: FoodControllerLoadState = .Loading {
		didSet {
			if loadState == .Failed {
				if let refresher = refreshControl {
					refresher.endRefreshing()
				} else {
					refreshControl = UIRefreshControl()
					refreshControl!.addTarget(self, action: refresh, forControlEvents: .ValueChanged)
				}
			} else {
				if !loadState.showActivity() {
					refreshControl?.endRefreshing()
					refreshControl = nil
				}
			}
			dispatch_async(dispatch_get_main_queue(), { () -> Void in
				self.tableView.reloadData()
			})
		}
	}
	internal var hasData: Bool { get { return information.meals.count != 0 } }
	private var hasInlineFoodDisplay: Bool { get { return displayIndexPath != nil } }
	private var compact: Bool { get { return view.frame.width == 320 } }
	
	override func viewDidLoad() {
		super.viewDidLoad()
		
		tableView.registerClass(RestaurantTableViewCell.self, forCellReuseIdentifier: kRestCellID)
		tableView.registerClass(MenuTableViewCell.self, forCellReuseIdentifier: kFoodDisplayID)
		tableView.registerClass(EmptyTableViewCell.self, forCellReuseIdentifier: EmptyCellID)
		tableView.backgroundColor = tableBackgroundColor
	}
	
	override func viewWillAppear(animated: Bool) {
		super.viewWillAppear(animated)
		
		if hasData {
			for cell in tableView.visibleCells() as! Array<FoodTableViewCell> {
				cell.updateDisplay()
			}
		}
		
		NSNotificationCenter.defaultCenter().addObserver(self, selector: "handleForeground:", name: "AppEnteringForeground", object: nil)
	}
	
	override func viewDidAppear(animated: Bool) {
		super.viewDidAppear(animated)
		
		// Check how much to do this
		setInformationIfNeeded()
		scrollToMeal()
	}
	
	override func viewWillDisappear(animated: Bool) {
		super.viewWillDisappear(animated)
		
		NSNotificationCenter.defaultCenter().removeObserver(self)
	}
	
	private func orderedMeals(meals: Array<MealType>) -> Array<MealType> {
		var mealByValue: Dictionary<MealType, Int> = [.Breakfast : 1, .Lunch : 2, .Brunch : 2, .Dinner : 3, .LateNight : 4]
		var remainingMeals = meals, orderedMeals: Array<MealType> = []
		
		while remainingMeals.count > 0 {
			var nextMeal = remainingMeals.first!, nextMealIndex = 0
			for (index, meal) in enumerate(remainingMeals) {
				if mealByValue[meal] < mealByValue[nextMeal] {
					nextMeal = meal
					nextMealIndex = index
				}
			}
			
			orderedMeals.append(nextMeal)
			remainingMeals.removeAtIndex(nextMealIndex)
		}
		
		return orderedMeals
	}
	
	// prevent stale displays
	func handleForeground(notification: NSNotification) {
		tableView.reloadData()
		refreshParallax()
	}
	
	func setInformationIfNeeded() {
		if !hasData && informationData.length > 0 {
			if let dayDataDict = deserializedOpt(informationData) {
				let infoExtra = DayBrief(dict: dayDataDict)
				
				// purge out empty entries for quick things
				for (meal, mealBrief) in infoExtra.meals {
					for (hall, hallBrief) in mealBrief.halls {
						if hallBrief.sections.count == 0 {
							infoExtra.meals[meal]!.halls.removeValueForKey(hall)
						}
					}
				}
				
				if !isHall {
					infoExtra.date = comparisonDate()
				}
				
				information = infoExtra
			}
		}
	}
	
	// MARK: - Core Data
	
	func handleDataChange(notification: NSNotification) {  }
	
	// MARK: - Helpers
	
	func loadFailed(error: NSError!) {
		if informationData.length == 0 {
			dispatch_async(dispatch_get_main_queue()) {
				self.loadState = .Failed
				
				if let userInfo = error.userInfo, errDesc = userInfo[NSLocalizedDescriptionKey] as? String {
					UIAlertView(title: "Error", message: errDesc, delegate: self, cancelButtonTitle: "Okay", otherButtonTitles: "Reload").show()
				}
				
				if let refresher = self.refreshControl {
					refresher.endRefreshing()
				} else {
					self.refreshControl = UIRefreshControl()
					self.refreshControl!.addTarget(self, action: self.refresh, forControlEvents: .ValueChanged)
				}
			}
		}
	}
	
	func retryLoad() {
		loadState = .Loading
		CloudManager.sharedInstance.downloadNewRecords(completion: { (error: NSError!) -> Void in
			if error != nil { // handle error case
				self.loadFailed(error)
			}
		})
	}
	
	func scrollToMeal() {
		if let currMeal = currentMealOpt where currCal.isDateInToday(information.date) || !isHall {
			for (index, meal) in enumerate(dateMeals) {
				if meal.equalTo(currMeal) {
					tableView.scrollToRowAtIndexPath(NSIndexPath(forRow: 0, inSection: index), atScrollPosition: .Top, animated: true)
					return
				}
			}
		}
	}
	
	func refreshParallax() {
		if let visibleCells = tableView.visibleCells() as? Array<FoodTableViewCell> {
			for cell in visibleCells {
				var percent = (cell.frame.origin.y - tableView.contentOffset.y) / tableView.frame.height
				cell.parallaxImageWithScrollPercent(percent)
			}
		}
	}
	
	// MARK: - Table view data source
	override func tableView(tableView: UITableView, heightForRowAtIndexPath indexPath: NSIndexPath) -> CGFloat {
		return hasData ? (indexPathHasFoodDisplay(indexPath) ? kFoodDisplayHeight : kRestCellHeight) : 100
	}
	
	override func numberOfSectionsInTableView(tableView: UITableView) -> Int {
		return hasData ? information.meals.count : 1
	}
	
	override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
		if hasData {
			var currDate = information.date, sectionMeal = dateMeals[section]
			if let rowCount = information.meals[sectionMeal]?.halls.count {
				if let displayPath = displayIndexPath where displayPath.section == section {
					return rowCount + 1
				}
				return rowCount
			}
			return 0
		} else {
			return 1
		}
	}
	
	override func tableView(tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
		return hasData ? dateMeals[section].rawValue : ""
	}
	
	override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
		if hasData {
			var decrement = hasInlineFoodDisplay && displayIndexPath!.row <= indexPath.row && displayIndexPath!.section == indexPath.section
			var modelRow = indexPath.row - (decrement ? 1 : 0)
			
			if let place = information.meals[dateMeals[indexPath.section]], restaurant = place.halls[place.halls.keys.array[modelRow]] {
				if indexPathHasFoodDisplay(indexPath) {
					return menuCell(restaurant)
				} else {
					return hallCell(NSIndexPath(forRow: modelRow, inSection: indexPath.section), restaurant: restaurant)
				}
			} else {
				return UITableViewCell() // should never be called
			}
		} else {
			return emptyCell()
		}
	}
	
	private func emptyCell() -> EmptyTableViewCell {
		var cell = tableView.dequeueReusableCellWithIdentifier(EmptyCellID) as! EmptyTableViewCell
		cell.loadState = loadState
		return cell
	}
	
	private func menuCell(restaurant: RestaurantBrief) -> MenuTableViewCell {
		var cell = tableView.dequeueReusableCellWithIdentifier(kFoodDisplayID) as! MenuTableViewCell
		
		cell.selectionStyle = .None
		cell.frame.size = CGSize(width: tableView.frame.width, height: kFoodDisplayHeight)
		cell.changeInfo(restaurant, andDate: information.date, isHall: isHall)
		cell.collectionView?.dataSource = self
		cell.collectionView?.delegate = self
		displayCell = cell
		
		return cell
	}
	
	private func hallCell(path: NSIndexPath, restaurant: RestaurantBrief) -> RestaurantTableViewCell {
		var cell = tableView.dequeueReusableCellWithIdentifier(kRestCellID, forIndexPath: path) as! RestaurantTableViewCell
		
		cell.selectionStyle = .None
		cell.frame.size = CGSize(width: tableView.frame.width, height: kRestCellHeight)
		cell.changeInfo(restaurant, andDate: information.date, isHall: isHall)
		
		return cell
	}
	
	// MARK: Delegate
	override func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
		if let cell = tableView.cellForRowAtIndexPath(indexPath) where cell.reuseIdentifier == kRestCellID {
			handleRestTap(indexPath)
		}
	}
	
	// MARK: - Utilities
	private func updateFoodDisplay() {
		if let displayPath = displayIndexPath where displayCell?.collectionView != nil {
			var displayRow = displayPath.row - 1
			
			var allHalls = (information.meals[dateMeals[Int(displayPath.section)]]?.halls)!
			var hallForRow = allHalls.keys.array[displayRow]
			var restaurant = (allHalls[hallForRow])!
			
			displayCell?.changeInfo(restaurant, andDate: information.date, isHall: isHall)
			displayCell!.collectionView?.invalidateIntrinsicContentSize()
			if displayCell!.collectionView?.numberOfSections() > 0 {
				displayCell!.collectionView?.scrollToItemAtIndexPath(NSIndexPath(forItem: 0, inSection: 0), atScrollPosition: .Left, animated: false)
			}
		}
	}
	
	private func indexPathHasFoodDisplay(indexPath: NSIndexPath) -> Bool {
		return hasInlineFoodDisplay && indexPath == displayIndexPath
	}
	
	private func removeInlineDisplay() {
		if let displayPath = displayIndexPath {
			tableView.deleteRowsAtIndexPaths([displayPath], withRowAnimation: .Fade)
			displayIndexPath = nil
		}
	}
	
	private func showInlineDisplay(belowPath restPath: NSIndexPath) {
		displayIndexPath = NSIndexPath(forRow: restPath.row + 1, inSection: restPath.section)
		tableView.insertRowsAtIndexPaths([displayIndexPath!], withRowAnimation: .Fade)
	}
	
	private func handleRestTap(indexPath: NSIndexPath) {
		var showNew = true
		var newRowIsBelowOld = false
		var willRemoveOldDisplay = false
		if let displayPath = displayIndexPath {
			willRemoveOldDisplay = true
			showNew = !(indexPath.section == displayPath.section && indexPath.row == displayPath.row - 1)
			newRowIsBelowOld = displayPath.section == indexPath.section && displayPath.row < indexPath.row
		}
		
		tableView.beginUpdates()
		removeInlineDisplay()
		
		let compensatedPath = NSIndexPath(forRow: indexPath.row - 1, inSection: indexPath.section)
		let shouldAdjust = willRemoveOldDisplay && newRowIsBelowOld
		let adjustedPath = shouldAdjust ? compensatedPath : indexPath
		
		if showNew {
			showInlineDisplay(belowPath: adjustedPath)
			tableView.endUpdates()
			tableView.scrollToRowAtIndexPath(adjustedPath, atScrollPosition: .Top, animated: true)
		} else {
			tableView.endUpdates()
		}
		
		refreshParallax()
		updateFoodDisplay()
	}
	
	// MARK:- ScrollViewDelegate
	override func scrollViewDidScroll(scrollView: UIScrollView) {
		if scrollView == tableView {
			refreshParallax()
		}
	}
	
	// MARK: - Popovers
	private func addFoodPopover(food: FoodInfo){
		if let displayPath = displayIndexPath {
			var foodVC = storyboard?.instantiateViewControllerWithIdentifier(foodVCid) as! FoodViewController
			
			foodVC.modalPresentationStyle = UIModalPresentationStyle.Popover
			foodVC.preferredContentSize = foodVC.preferredContentSize
			
			let ppc = foodVC.popoverPresentationController!
			ppc.permittedArrowDirections = .allZeros
			ppc.delegate = self
			ppc.sourceView = tableView // or source rect or barbuttonitem
			
			var anchorFrame = tableView.rectForRowAtIndexPath(displayPath)
			
			let xVal = (anchorFrame.origin.x) + anchorFrame.size.width / 2.0
			let yVal = ((anchorFrame.origin.y) + anchorFrame.size.height / 2.0) + 11.0
			ppc.sourceRect = CGRect(x: xVal, y: yVal, width: 0.0, height: 0.0)
			presentViewController(foodVC, animated: true, completion: nil)
			
			foodVC.setFood(food, date: information.date, meal: dateMeals[displayPath.section], place: (displayCell?.brief)!)
		}
	}
	
	// MARK: UIPopoverPresentationControllerDelegate
	func adaptivePresentationStyleForPresentationController(controller: UIPresentationController) -> UIModalPresentationStyle {
		return .None
	}
	
	// MARK: - UICollectionViewDataSource
	func collectionView(collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
		return (displayCell?.brief?.sections[section].foods.count)!
	}
	
	func collectionView(collectionView: UICollectionView, cellForItemAtIndexPath indexPath: NSIndexPath) -> UICollectionViewCell {
		var restaurant = displayCell?.brief
		var food = restaurant?.sections[indexPath.section].foods[indexPath.row]
		var cell = collectionView.dequeueReusableCellWithReuseIdentifier("foodDisplay", forIndexPath: indexPath) as! FoodCollectionViewCell
		cell.setFood(restaurant!.sections[indexPath.section].foods[indexPath.row], isHall: isHall)
		return cell
	}
	
	func numberOfSectionsInCollectionView(collectionView: UICollectionView) -> Int {
		return displayCell!.brief!.sections.count
	}
	
	func collectionView(collectionView: UICollectionView, viewForSupplementaryElementOfKind kind: String, atIndexPath indexPath: NSIndexPath) -> UICollectionReusableView {
		var header = collectionView.dequeueReusableSupplementaryViewOfKind(kind, withReuseIdentifier: "headerCell", forIndexPath: indexPath) as! SectionCollectionReusableView
		header.changeTitle((displayCell?.brief?.sections[indexPath.section].name)!)
		
		var flow = collectionView.collectionViewLayout as! HorizontalFlow
		while flow.headerWidths.count - indexPath.section < 1 {
			flow.headerWidths.append(240)
		}
		flow.headerWidths[indexPath.section] = header.title.frame.width
		
		return header
	}
	
	// MARK: UICollectionViewDelegate
	func collectionView(collectionView: UICollectionView, didSelectItemAtIndexPath indexPath: NSIndexPath) {
		let section = displayCell?.brief!.sections[indexPath.section]
		let foodBrief = section!.foods[indexPath.row]
		if information.foods.indexForKey(foodBrief.recipe) != nil {
			let food = information.foods[foodBrief.recipe]!.info
			addFoodPopover(food)
		}
	}
	
	func alertView(alertView: UIAlertView, didDismissWithButtonIndex buttonIndex: Int) {
		switch alertView.buttonTitleAtIndex(buttonIndex) {
		case "Reload":
			retryLoad()
		default:
			return
		}
	}
}
