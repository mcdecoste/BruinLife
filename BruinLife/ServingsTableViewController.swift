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
	let emptyID = "empty"
	
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
		tableView.registerClass(UITableViewCell.self, forCellReuseIdentifier: emptyID)
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
		for index in 0..<Nutrient.allValues.count {
			measures.append(0)
		}
		
		// add in the various foods
		for food in foodItems {
			for (index, nutr) in enumerate(food.info().nutrition) {
				let existingInt = measures[index]
				let additional = nutr.measure.toInt()! * Int(food.servings)
				
				measures[index] = existingInt + additional
			}
		}
		
		var newInfo = [NutritionListing]()
		for (index, nutrient) in enumerate(Nutrient.allValues) {
			newInfo.append(NutritionListing(type: nutrient, measure: "\(measures[index])"))
		}
		
		return newInfo
	}
	
	// MARK: - Core Data
	
	/// Can either grab the food or delete something
	func fetchFoods() {
		var fetchRequest = NSFetchRequest(entityName: "Food")
		fetchRequest.sortDescriptors = [NSSortDescriptor(key: "name", ascending: true)]
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
		var fetchRequest = NSFetchRequest(entityName: "Food")
		fetchRequest.predicate = NSPredicate(format: "recipe == %@", foodItems[path.row].recipe)!
		
		if let fetchResults = managedObjectContext!.executeFetchRequest(fetchRequest, error: nil) as? [Food] {
			fetchResults[0].servings = 0
		}
		save()
		
		tableView.beginUpdates()
		tableView.deleteRowsAtIndexPaths([path], withRowAnimation: .Left)
		
		foodItems.removeAtIndex(path.row)
		tableView.endUpdates()
	}
	
	func changeServing(row: ServingsDisplayTableViewCell, count: Int) {
		let path = tableView.indexPathForCell(row)!
		
		var fetchRequest = NSFetchRequest(entityName: "Food")
		fetchRequest.predicate = NSPredicate(format: "recipe == %@", foodItems[path.row].recipe)!
		
		if let fetchResults = managedObjectContext!.executeFetchRequest(fetchRequest, error: nil) as? [Food] {
			fetchResults[0].servings = Int16(count)
		}
		save()
	}
	
    // MARK: - Table view data source

    override func numberOfSectionsInTableView(tableView: UITableView) -> Int {
		return 2 // nutrition facts first. food list second.
    }

    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
		switch section {
		case nutritionSection:
			return hasFood() ? Nutrient.rowPairs.count : 1
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
			cell.changeFood(food.name, count: Int(food.servings))
			
			return cell
		default:
			if hasFood() {
				var cell = tableView.dequeueReusableCellWithIdentifier(nutritionID) as NutritionTableViewCell
				
				let cellInfo = Nutrient.rowPairs[indexPath.row] as (type: NutrientDisplayType, left: Nutrient, right: Nutrient) // more readable
				
				var leftIndex = (Nutrient.allRawValues as NSArray).indexOfObject(cellInfo.left.rawValue)
				var rightIndex = (Nutrient.allRawValues as NSArray).indexOfObject(cellInfo.right.rawValue)
				
				cell.frame.size.width = tableView.frame.width
				cell.selectionStyle = .None
				cell.setInformation((type: cellInfo.type, left: nutritionValues[leftIndex], right: nutritionValues[rightIndex]))
				cell.setServingCount(0)
				
				return cell
			} else {
				var cell = tableView.dequeueReusableCellWithIdentifier(emptyID, forIndexPath: indexPath) as UITableViewCell
				
				cell.selectionStyle = .None
				cell.textLabel?.text = "You haven't eaten today!"
				
				return cell
			}
		}
	}
	
	override func tableView(tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
		switch section {
		case nutritionSection:
			return hasFood() ? "Today's Nutrition Facts" : ""
		case foodSection:
			return hasFood() ? "Today's Foods" : ""
		default:
			return ""
		}
	}
	
	override func tableView(tableView: UITableView, titleForFooterInSection section: Int) -> String? {
		switch section {
		case nutritionSection:
			return hasFood() ? "" : "You can add servings in the Dorm and Quick sections."
		default:
			return ""
		}
	}
	
	// MARK: Table view delegate
	
	override func tableView(tableView: UITableView, commitEditingStyle editingStyle: UITableViewCellEditingStyle, forRowAtIndexPath indexPath: NSIndexPath) {
		if editingStyle == .Delete {
			removeServing(indexPath)
		}
	}
	
	func hasFood() -> Bool { return foodItems.count != 0 }
}
