//
//  FavoritesTableViewController.swift
//  BruinLife
//
//  Created by Matthew DeCoste on 1/14/15.
//  Copyright (c) 2015 Matthew DeCoste. All rights reserved.
//

import UIKit
import CoreData

class FavoritesTableViewController: UITableViewController {
	let cellID = "favorite"
	
	lazy var managedObjectContext : NSManagedObjectContext? = {
		let appDelegate = UIApplication.sharedApplication().delegate as AppDelegate
		if let moc = appDelegate.managedObjectContext { return moc }
		else { return nil }
	}()
	var foodItems = [Food]()
	
    override func viewDidLoad() {
        super.viewDidLoad()
		
		self.navigationItem.title = "Favorites"
		tableView.registerClass(NotificationTableViewCell.self, forCellReuseIdentifier: cellID)
    }
	
	override func viewWillAppear(animated: Bool) {
		super.viewWillAppear(animated)
		
		fetchFoods()
		tableView.reloadData()
	}

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
	
	// MARK: - Core Data
	
	/// Can either grab the food or delete something
	func fetchFoods() {
		var fetchRequest = NSFetchRequest(entityName: "Food")
		fetchRequest.sortDescriptors = [NSSortDescriptor(key: "recipe", ascending: true)] // was name
		fetchRequest.predicate = NSPredicate(format: "favorite == %@", NSNumber(bool: true))
		
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
	
	func removeFavorite(path: NSIndexPath) {
		var fetchRequest = NSFetchRequest(entityName: "Food")
		let pred1 = NSPredicate(format: "favorite == %@", NSNumber(bool: true))!
		let pred2 = NSPredicate(format: "recipe == %@", foodItems[path.row].info().recipe)!
		fetchRequest.predicate = NSCompoundPredicate(type: NSCompoundPredicateType.AndPredicateType, subpredicates: [pred1, pred2])
		
		if let fetchResults = managedObjectContext!.executeFetchRequest(fetchRequest, error: nil) as? [Food] {
			fetchResults[0].favorite = false
		}
		save()
		
		tableView.beginUpdates()
		tableView.deleteRowsAtIndexPaths([path], withRowAnimation: .Left)
		foodItems.removeAtIndex(path.row)
		tableView.endUpdates()
	}
	
    // MARK: - Table view data source

    override func numberOfSectionsInTableView(tableView: UITableView) -> Int {
		return 1 // TODO: split them by which are showing up in the next week and which aren't?
    }

    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return foodItems.count
    }

	override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
		let cell = tableView.dequeueReusableCellWithIdentifier(cellID, forIndexPath: indexPath) as NotificationTableViewCell
		cell.setLabels(foodItems[indexPath.row].info().name)
		return cell
	}
	
//	override func tableView(tableView: UITableView, viewForFooterInSection section: Int) -> UIView? {
//		let footer = UIView(frame: CGRect(x: 0, y: 0, width: tableView.frame.width, height: 24))
//		footer.backgroundColor = .clearColor()
//		
//		return footer
//	}
	
	// Override to support editing the table view.
	override func tableView(tableView: UITableView, commitEditingStyle editingStyle: UITableViewCellEditingStyle, forRowAtIndexPath indexPath: NSIndexPath) {
		if editingStyle == .Delete {
			removeFavorite(indexPath)
		}
	}
}
