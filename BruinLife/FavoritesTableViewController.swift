//
//  FavoritesTableViewController.swift
//  BruinLife
//
//  Created by Matthew DeCoste on 1/14/15.
//  Copyright (c) 2015 Matthew DeCoste. All rights reserved.
//

import UIKit

class FavoritesTableViewController: UITableViewController {
	let cellID = "favorite"
	let notifySection = 0, dontSection = 1
	
	var favorites: Array<Array<Food>> = [[], []]
	
    override func viewDidLoad() {
        super.viewDidLoad()
		
		navigationItem.title = "Favorites"
		navigationItem.rightBarButtonItem = UIBarButtonItem(barButtonSystemItem: .Edit, target: self, action: "editTable")
		
		tableView.registerClass(NotificationTableViewCell.self, forCellReuseIdentifier: cellID)
    }
	
	override func viewWillAppear(animated: Bool) {
		super.viewWillAppear(animated)
		
		favorites = CloudManager.sharedInstance.favoritedFoods
		tableView.reloadData()
	}

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
	
	// MARK: - Core Data
	
	func removeFavorite(path: NSIndexPath) {
		CloudManager.sharedInstance.removeFavorite(favorites[path.section][path.row].info.recipe)
		
		tableView.beginUpdates()
		tableView.deleteRowsAtIndexPaths([path], withRowAnimation: .Left)
		favorites[path.section].removeAtIndex(path.row)
		tableView.endUpdates()
	}
	
	func changeFoodNotify(food: Food, notify: Bool) {
		CloudManager.sharedInstance.changeFoodNotification(food.info.recipe, shouldNotify: notify)
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
			return "These notifications are a work in progress and will work in a future version." // "Notifications will be sent out when the food's dining hall opens" // "Favorites will be shown in Today View Extension regardless of this setting"
		default:
			return nil
		}
	}

	override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
		let cell = tableView.dequeueReusableCellWithIdentifier(cellID, forIndexPath: indexPath) as! NotificationTableViewCell
		var places: Array<String> = []
		// TODO: Consult existing menus to see when this food will come up again
		cell.setLabels(favorites[indexPath.section][indexPath.row].info.name, places: places)
		return cell
	}
	
	override func tableView(tableView: UITableView, shouldIndentWhileEditingRowAtIndexPath indexPath: NSIndexPath) -> Bool {
		return false
	}
	
//	override func tableView(tableView: UITableView, editingStyleForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCellEditingStyle {
//		return .None
//	}
	
	// Override to support editing the table view.
	override func tableView(tableView: UITableView, commitEditingStyle editingStyle: UITableViewCellEditingStyle, forRowAtIndexPath indexPath: NSIndexPath) {
		if editingStyle == .Delete {
			removeFavorite(indexPath)
		}
	}
	
	func editTable() {
		setEditing(!editing, animated: true)
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
	
	override func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
		tableView.deselectRowAtIndexPath(indexPath, animated: true)
	}
}
