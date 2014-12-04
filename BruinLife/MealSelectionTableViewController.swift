//
//  MealSelectionTableViewController.swift
//  BruinLife
//
//  Created by Matthew DeCoste on 12/1/14.
//  Copyright (c) 2014 Matthew DeCoste. All rights reserved.
//

import UIKit

class MealSelectionTableViewController: UITableViewController {
	var meal: MealType = .Lunch
	var meals: Array<MealType> = []
	var mealTitles: Array<String> = []
	
	var isDorm = true
	var date: NSDate = NSDate()
	var foodVC: FoodTableViewController?
	
	let reuseID = "mealCell"
	let cellHeight = 66
	
    override func viewDidLoad() {
        super.viewDidLoad()
		
		self.navigationItem.title = "Select a meal"
		self.navigationItem.leftBarButtonItem = UIBarButtonItem(barButtonSystemItem: .Cancel, target: self, action: "isDone")
    }
	
	func isDone() {
//		foodVC?.setNewMeal(meal)
		self.dismissViewControllerAnimated(true, completion: nil)
	}
	
	func preferredContentSize() -> CGSize {
		return CGSize(width: 130, height: cellHeight * meals.count)
	}
	
	func setDate(date: NSDate) {
		var formatter = NSDateFormatter()
		formatter.dateFormat = "EEE"
		
		var dow = formatter.stringFromDate(date)
		var isWeekend = dow == "Sat" || dow == "Sun"
		
		meals = (isWeekend && isDorm) ? [.Brunch, .Dinner] : [.Breakfast, .Lunch, .Dinner]
		mealTitles = []
		
		for item in meals {
			mealTitles.append(item.rawValue)
		}
		
//		tableView.reloadData()
	}

    // MARK: - Table view data source

    override func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        // Return the number of sections.
        return 1
    }

    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        // Return the number of rows in the section.
        return meals.count
    }
	
	override func tableView(tableView: UITableView, heightForRowAtIndexPath indexPath: NSIndexPath) -> CGFloat {
		return CGFloat(cellHeight)
	}
	
    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCellWithIdentifier(reuseID, forIndexPath: indexPath) as UITableViewCell
		
        // Configure the cell...
		cell.textLabel?.text = mealTitles[indexPath.row]
		
		if meals[indexPath.row] == meal {
			cell.accessoryType = .Checkmark
		}
		
		// consider putting information about which places are open for each meal? Dunno
		
        return cell
    }
	
	override func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
		meal = meals[indexPath.row]
		
		isDone()
	}
}
