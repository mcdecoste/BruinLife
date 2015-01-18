//
//  NotificationTableViewController.swift
//  BruinLife
//
//  Created by Matthew DeCoste on 1/9/15.
//  Copyright (c) 2015 Matthew DeCoste. All rights reserved.
//

import UIKit

class NotificationTableViewController: UITableViewController {
	var notifications: Array<Array<UILocalNotification>> = [[], [], [], [], [], [], []]
	let weekdays = ["Sunday", "Monday", "Tuesday", "Wednesday", "Thursday", "Friday", "Saturday"]
	let cellID = "cell"
	
	override init(style: UITableViewStyle) { super.init(style: style) }
	
	required init(coder aDecoder: NSCoder) { super.init(coder: aDecoder) }
	
    override func viewDidLoad() {
        super.viewDidLoad()
		tableView.registerClass(FoodNotificationTableViewCell.self, forCellReuseIdentifier: cellID)
		navigationItem.title = "Notifications"
    }
	
	override func viewWillAppear(animated: Bool) {
		super.viewWillAppear(animated)
		gatherNotifications()
		tableView.reloadData()
	}

	func gatherNotifications() {
		notifications = [[], [], [], [], [], [], []]
		for note in (UIApplication.sharedApplication().scheduledLocalNotifications as Array<UILocalNotification>) {
			var userInfo = note.userInfo as [String : String]
			notifications[indexForWeekday(userInfo[notificationDateID]!)].append(note)
		}
	}
	
	func removeNotification(indexPath: NSIndexPath) {
		let realSection = sectionFromSection(indexPath.section)
		
		UIApplication.sharedApplication().cancelLocalNotification(notifications[realSection][indexPath.row])
		notifications[realSection].removeAtIndex(indexPath.row)
	}
	
	func indexForWeekday(string: String) -> Int {
		return (weekdays as NSArray).indexOfObject(string)
	}
	
	func notificationForPath(path: NSIndexPath) -> UILocalNotification {
		return notifications[sectionFromSection(path.section)][path.row]
	}
	
    // MARK: - Table view data source
    override func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return notifications.count
    }

    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return notifications[sectionFromSection(section)].count
    }

    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
		var cell = tableView.dequeueReusableCellWithIdentifier(cellID, forIndexPath: indexPath) as FoodNotificationTableViewCell
		let userInfo = notificationForPath(indexPath).userInfo as [String : String]
		cell.textLabel?.text = userInfo[notificationFoodID]
		cell.textLabel?.numberOfLines = 0
		cell.detailTextLabel?.text = userInfo[notificationTimeID]
        return cell
    }
	
	override func tableView(tableView: UITableView, commitEditingStyle editingStyle: UITableViewCellEditingStyle, forRowAtIndexPath indexPath: NSIndexPath) {
		if editingStyle == .Delete {
			// Delete the row from the data source
			tableView.beginUpdates()
			removeNotification(indexPath)
			tableView.deleteRowsAtIndexPaths([indexPath], withRowAnimation: .Left)
			
			let realSection = sectionFromSection(indexPath.section)
			if notifications[realSection].count == 0 {
				tableView.reloadSections(NSIndexSet(index: indexPath.section), withRowAnimation: .Fade)
			}
			
			tableView.endUpdates()
		}
	}
	
	override func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
		let notification = notificationForPath(indexPath)
		let userInfo = notification.userInfo as [String : String]
		
		tableView.deselectRowAtIndexPath(indexPath, animated: true)
		
		let dayRelated = representsToday(notification.fireDate!) ? "later today" : "on \(userInfo[notificationDateID]!)"
		let body = "will be at \(userInfo[notificationPlaceID]!) for \(userInfo[notificationMealID]!) \(dayRelated). You will be reminded at \(userInfo[notificationTimeID]!). \(userInfo[notificationPlaceID]!) will be open from \(userInfo[notificationHoursID]!)."
		
		UIAlertView(title: userInfo[notificationFoodID], message: body, delegate: nil, cancelButtonTitle: "Got it").show()
	}
	
	func sectionFromSection(section: Int) -> Int {
		let weekday = NSCalendar.currentCalendar().component(.CalendarUnitWeekday, fromDate: NSDate())
		return (weekday - 1 + section) % weekdays.count
	}
	
	func pathFromPath(path: NSIndexPath) -> NSIndexPath {
		return NSIndexPath(forRow: path.row, inSection: sectionFromSection(path.section))
	}
	
	override func tableView(tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
		let realSection = sectionFromSection(section)
		return notifications[realSection].count > 0 ? weekdays[realSection] : nil
	}
}
