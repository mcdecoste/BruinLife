//
//  DateSelectionTableViewController.swift
//  BruinLife
//
//  Created by Matthew DeCoste on 11/30/14.
//  Copyright (c) 2014 Matthew DeCoste. All rights reserved.
//

import UIKit

class DateSelectionTableViewController: UITableViewController {
	var selectedDate: NSDate?
	var dateIndex = 0
	var dates: Array<NSDate> = []

	let dateIdentifier = "dateDisplay"
	let cellHeight = 66
	
	var dormVC: DormTableViewController?
	
	override func viewDidLoad() {
		super.viewDidLoad()
		
		if (dates.count == 0) { dates = nextWeek() }
		
		self.navigationItem.title = "Select a day"
		self.navigationItem.leftBarButtonItem = UIBarButtonItem(barButtonSystemItem: .Cancel, target: self, action: "isDone")
		
		var interval = selectedDate?.timeIntervalSinceDate(dates[0])
		dateIndex = Int(ceil((interval! / dayInterval())))
	}
	
	func setDate(date: NSDate) {
		selectedDate = date
		
		if (dates.count == 0) {
			dates = nextWeek()
		}
		var interval = selectedDate?.timeIntervalSinceDate(dates[0])
		dateIndex = Int(ceil((interval! / dayInterval())))
	}
	
	func isDone() {
		dormVC?.setNewDate(selectedDate!)
		self.dismissViewControllerAnimated(true, completion: { () -> Void in
			// don't do anything here
		})
	}
	
	func preferredContentSize() -> CGSize {
		return CGSize(width: 200, height: cellHeight * dates.count)
	}
	
	func dayInterval() -> NSTimeInterval {
		return 24 * 60 * 60
	}
	
	func secsInDay() -> Int {
		return 24 * 60 * 60
	}
	
	/// Only returns seven days total.
	func nextWeek() -> Array<NSDate> {
		var secondsInDay = secsInDay()
		
		var week: Array<NSDate> = []
		for index in 0...6 {
			var interval = index * secondsInDay
			week.append(NSDate(timeIntervalSinceNow: Double(interval)))
		}
		
		return week
	}
	
	// MARK: - Table view data source
	
	override func tableView(tableView: UITableView, heightForRowAtIndexPath indexPath: NSIndexPath) -> CGFloat {
		return CGFloat(cellHeight)
	}
	
	override func numberOfSectionsInTableView(tableView: UITableView) -> Int {
		// Return the number of sections.
		return 1
	}
	
	override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
		// Return the number of rows in the section.
		return dates.count
	}
	
	override func tableView(tableView: UITableView, willDisplayCell cell: UITableViewCell, forRowAtIndexPath indexPath: NSIndexPath) {
		cell.separatorInset = UIEdgeInsetsZero
	}
	
	override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
		var cell = tableView.dequeueReusableCellWithIdentifier(dateIdentifier, forIndexPath: indexPath) as CalendarTableViewCell
		let date = dates[indexPath.row]
		
		cell.setDate(date)
		if (indexPath.row == dateIndex) { cell.accessoryType = .Checkmark }
		
		return cell
	}
	
	override func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
		dateIndex = indexPath.row
		selectedDate = dates[dateIndex]
		
		isDone()
	}
}
