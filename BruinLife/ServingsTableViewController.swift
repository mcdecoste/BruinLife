//
//  ServingsTableViewController.swift
//  BruinLife
//
//  Created by Matthew DeCoste on 1/14/15.
//  Copyright (c) 2015 Matthew DeCoste. All rights reserved.
//

import UIKit
import CoreData

class ServingsTableViewController: UITableViewController {
	let nutritionID = "nutrition"
	let foodID = "serving"
	
	let nutritionSection = 0
	let foodSection = 1
	
	lazy var managedObjectContext : NSManagedObjectContext? = {
		let appDelegate = UIApplication.sharedApplication().delegate as AppDelegate
		if let moc = appDelegate.managedObjectContext { return moc }
		else { return nil }
	}()
	var foodItems = [Food]()
	var nutritionValues = [NutritionListing]()
	
    override func viewDidLoad() {
        super.viewDidLoad()
		
		self.navigationItem.title = "Nutrition"
		tableView.registerClass(NutritionTableViewCell.self, forCellReuseIdentifier: nutritionID)
		tableView.registerClass(ServingsDisplayTableViewCell.self, forCellReuseIdentifier: foodID)
    }
	
	override func viewWillAppear(animated: Bool) {
		super.viewWillAppear(animated)
		
		fetchFoods()
		nutritionValues = calculateNutritionData()
		tableView.reloadData()
		tableView.separatorStyle = .None
	}
	
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
	
	func calculateNutritionData() -> Array<NutritionListing> {
		var measures = [Int]()
		for index in 0..<Nutrient.allValues.count { measures.append(0) }
		
		// add in the various foods
		for food in foodItems {
			for (index, nutr) in enumerate(food.info().nutrition) {
				measures[index] += nutr.measure.toInt()! * Int(food.servings)
			}
		}
		
		var info = [NutritionListing]()
		for (index, nutrient) in enumerate(Nutrient.allValues) {
			info.append(NutritionListing(type: nutrient, measure: "\(measures[index])"))
		}
		
		return info
	}
	
	// MARK: - Core Data
	
	/// Can either grab the food or delete something
	func fetchFoods() {
		var fetchRequest = NSFetchRequest(entityName: "Food")
		fetchRequest.sortDescriptors = [NSSortDescriptor(key: "recipe", ascending: true)] // name
		fetchRequest.predicate = NSPredicate(format: "servings > 0")
		
		if let fetchResults = managedObjectContext!.executeFetchRequest(fetchRequest, error: nil) as? [Food] {
			for food in fetchResults { food.checkDate() }
		}
		if let fetchResults = managedObjectContext!.executeFetchRequest(fetchRequest, error: nil) as? [Food] {
			foodItems = fetchResults
		}
	}
	
	func save() {
		var error: NSError?
		if managedObjectContext!.save(&error) {
			if error != nil { println(error?.localizedDescription) }
		}
	}
	
	func removeServing(path: NSIndexPath) {
		var request = NSFetchRequest(entityName: "Food")
		request.predicate = NSPredicate(format: "recipe == %@", foodItems[path.row].info().recipe)!
		
		if let result = managedObjectContext!.executeFetchRequest(request, error: nil) as? [Food] {
			result[0].servings = 0
		}
		save()
		
		tableView.beginUpdates()
		tableView.deleteRowsAtIndexPaths([path], withRowAnimation: .Left)
		foodItems.removeAtIndex(path.row)
		tableView.endUpdates()
		
		if !hasFood() {
			tableView.reloadSections(NSIndexSet(index: foodSection), withRowAnimation: .Automatic)
		}
	}
	
	func changeServing(row: ServingsDisplayTableViewCell, count: Int) {
		let path = tableView.indexPathForCell(row)!
		
		var fetchRequest = NSFetchRequest(entityName: "Food")
		fetchRequest.predicate = NSPredicate(format: "recipe == %@", foodItems[path.row].info().recipe)!
		
		if let fetchResults = managedObjectContext!.executeFetchRequest(fetchRequest, error: nil) as? [Food] {
			fetchResults[0].servings = Int16(count)
		}
		save()
		
		// update the nutrition side
		nutritionValues = calculateNutritionData()
		for cell in (tableView.visibleCells() as [UITableViewCell]) {
			if let cellPath = tableView.indexPathForCell(cell) {
				// update nutritional cells
				if cellPath.section == nutritionSection {
					updateNutritionCell(cell as NutritionTableViewCell, path: cellPath)
				}
			}
		}
	}
	
    // MARK: - Table view data source

    override func numberOfSectionsInTableView(tableView: UITableView) -> Int {
		return 2 // nutrition facts first. food list second.
    }

    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
		switch section {
		case nutritionSection:
			return Nutrient.rowPairs.count //hasFood() ? Nutrient.rowPairs.count : 1
		case foodSection:
			return foodItems.count
		default:
			return 0
		}
    }
	
	override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
		switch indexPath.section {
		case foodSection:
			let food = foodItems[indexPath.row]
			
			let cell = tableView.dequeueReusableCellWithIdentifier(foodID, forIndexPath: indexPath) as ServingsDisplayTableViewCell
			cell.selectionStyle = .None
			cell.controller = self
			cell.changeFood(food)
			
			return cell
		default:
			var cell = tableView.dequeueReusableCellWithIdentifier(nutritionID) as NutritionTableViewCell
			
			cell.frame.size.width = tableView.frame.width
			cell.selectionStyle = .None
			
			updateNutritionCell(cell, path: indexPath)
			
			return cell
		}
	}
	
	func updateNutritionCell(cell: NutritionTableViewCell, path: NSIndexPath) {
		let cellInfo = Nutrient.rowPairs[path.row]
		
		let nutrArray = Nutrient.allRawValues as NSArray
		
		var leftIndex = nutrArray.indexOfObject(cellInfo.left.rawValue)
		var rightIndex = nutrArray.indexOfObject(cellInfo.right.rawValue)
		
		cell.setInformation((type: cellInfo.type, left: nutritionValues[leftIndex], right: nutritionValues[rightIndex]))
		cell.setServingCount(0)
	}
	
	override func tableView(tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
		switch section {
		case nutritionSection:
			return "Today's Nutrition Facts"
		case foodSection:
			return hasFood() ? "Today's Foods" : ""
		default:
			return ""
		}
	}
	
	override func tableView(tableView: UITableView, titleForFooterInSection section: Int) -> String? {
		switch section {
		case nutritionSection:
			return hasFood() ? "" : "You can add foods in the Dorm and Quick sections."
		default:
			return ""
		}
	}
	
	override func tableView(tableView: UITableView, titleForDeleteConfirmationButtonForRowAtIndexPath indexPath: NSIndexPath) -> String! {
		return "Didn't\nEat"
	}
	
	// MARK: Table view delegate
	
	override func tableView(tableView: UITableView, canEditRowAtIndexPath indexPath: NSIndexPath) -> Bool {
		return hasFood() && indexPath.section == foodSection
	}
	
	override func tableView(tableView: UITableView, editingStyleForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCellEditingStyle {
		switch indexPath.section {
		case foodSection:
			return hasFood() ? .Delete : .None
		default:
			return .None
		}
	}
	
	override func tableView(tableView: UITableView, commitEditingStyle editingStyle: UITableViewCellEditingStyle, forRowAtIndexPath indexPath: NSIndexPath) {
		if editingStyle == .Delete {
			removeServing(indexPath)
		}
	}
	
	func hasFood() -> Bool { return foodItems.count != 0 }
}
