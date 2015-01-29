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
	let notifySection = 0
	let dontSection = 1
	
	lazy var managedObjectContext : NSManagedObjectContext? = {
		let appDelegate = UIApplication.sharedApplication().delegate as AppDelegate
		if let moc = appDelegate.managedObjectContext { return moc }
		else { return nil }
	}()
	var favorites: Array<Array<Food>> = [[], []]
	
    override func viewDidLoad() {
        super.viewDidLoad()
		
		navigationItem.title = "Favorites"
		navigationItem.rightBarButtonItem = UIBarButtonItem(title: "Edit", style: .Plain, target: self, action: "editTable") // editButtonItem()
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
		fetchRequest.predicate = NSPredicate(format: "favorite == %@", NSNumber(bool: true))
		
		if let fetchResults = managedObjectContext!.executeFetchRequest(fetchRequest, error: nil) as? [Food] {
			favorites = [[], []]
			for result in fetchResults {
				favorites[result.notify ? notifySection : dontSection].append(result)
			}
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
		let recipe = favorites[path.section][path.row].info().recipe
		fetchRequest.predicate = NSPredicate(format: "favorite == %@", NSNumber(bool: true))!
		
		if let fetchResults = managedObjectContext!.executeFetchRequest(fetchRequest, error: nil) as? [Food] {
			for result in fetchResults {
				if result.info().recipe == recipe {
					result.favorite = false
				}
			}
		}
		save()
		
		tableView.beginUpdates()
		tableView.deleteRowsAtIndexPaths([path], withRowAnimation: .Left)
		favorites[path.section].removeAtIndex(path.row)
		tableView.endUpdates()
	}
	
	func changeFoodNotify(food: Food, notify: Bool) {
		var fetchRequest = NSFetchRequest(entityName: "Food")
		let recipe = food.info().recipe
		fetchRequest.predicate = NSPredicate(format: "favorite == %@", NSNumber(bool: true))!
		
		if let fetchResults = managedObjectContext!.executeFetchRequest(fetchRequest, error: nil) as? [Food] {
			for result in fetchResults {
				if result.info().recipe == recipe {
					result.notify = notify
				}
			}
		}
		save()
	}
	
    // MARK: - Table view data source

    override func numberOfSectionsInTableView(tableView: UITableView) -> Int {
		return favorites.count // foods that will send reminders and foods taht won't
    }

    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return favorites[section].count
    }
	
	override func tableView(tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
		switch section {
		case notifySection:
			return "Tell me when available"
		case dontSection:
			return "Don't tell me"
		default:
			return nil
		}
	}
	
	override func tableView(tableView: UITableView, titleForFooterInSection section: Int) -> String? {
		switch section {
		case notifySection:
			return nil
		case dontSection:
			return "Favorites will be shown in Today View Extension regardless of this setting"
		default:
			return nil
		}
	}

	override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
		let cell = tableView.dequeueReusableCellWithIdentifier(cellID, forIndexPath: indexPath) as NotificationTableViewCell
		cell.setLabels(favorites[indexPath.section][indexPath.row].info().name)
		return cell
	}
	
	override func tableView(tableView: UITableView, shouldIndentWhileEditingRowAtIndexPath indexPath: NSIndexPath) -> Bool {
		return false
	}
	
	override func tableView(tableView: UITableView, editingStyleForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCellEditingStyle {
		return .None
	}
	
	// Override to support editing the table view.
	override func tableView(tableView: UITableView, commitEditingStyle editingStyle: UITableViewCellEditingStyle, forRowAtIndexPath indexPath: NSIndexPath) {
		if editingStyle == .Delete {
			removeFavorite(indexPath)
		}
	}
	
	func editTable() {
		setEditing(!editing, animated: true)
		navigationItem.rightBarButtonItem?.style = !editing ? .Plain : .Done
		navigationItem.rightBarButtonItem?.title = !editing ? "Edit" : "Done"
	}
	
	override func tableView(tableView: UITableView, canMoveRowAtIndexPath indexPath: NSIndexPath) -> Bool {
		return true
	}
	
	override func tableView(tableView: UITableView, moveRowAtIndexPath sourceIndexPath: NSIndexPath, toIndexPath destinationIndexPath: NSIndexPath) {
		let movedFood = favorites[sourceIndexPath.section][sourceIndexPath.row]
		
		favorites[sourceIndexPath.section].removeAtIndex(sourceIndexPath.row)
		favorites[destinationIndexPath.section].insert(movedFood, atIndex: destinationIndexPath.row)
		
		changeFoodNotify(movedFood, notify: destinationIndexPath.section == notifySection)
	}
}
