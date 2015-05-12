//
//  ComingWeekTableViewController.swift
//  BruinLife
//
//  Created by Matthew DeCoste on 5/11/15.
//  Copyright (c) 2015 Matthew DeCoste. All rights reserved.
//

import UIKit

class ComingWeekTableViewController: UITableViewController {
	private let reuseID = "Display"
    override func viewDidLoad() {
        super.viewDidLoad()

		clearsSelectionOnViewWillAppear = false
		tableView.registerClass(DayDisplayTableViewCell.self, forCellReuseIdentifier: reuseID)
		preferredContentSize = CGSize(width: 240, height: 308)
		tableView.scrollEnabled = false
    }

    // MARK: - Table view data source
    override func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return 1
    }

    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 7
    }
	
	override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
		return displayCell(indexPath.row)
	}
	
	override func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
		var delegate = popoverPresentationController?.delegate as! DormContainerViewController
		delegate.didPickDay(indexPath.row)
		delegate.dismissViewControllerAnimated(true, completion: nil)
	}
	
	func displayCell(row: Int) -> DayDisplayTableViewCell {
		let cell = tableView.dequeueReusableCellWithIdentifier(reuseID) as! DayDisplayTableViewCell
		cell.day = row
		return cell
	}
}
