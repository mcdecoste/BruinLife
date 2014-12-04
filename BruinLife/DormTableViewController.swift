//
//  DormTableViewController.swift
//  BruinLife
//
//  Created by Matthew DeCoste on 11/26/14.
//  Copyright (c) 2014 Matthew DeCoste. All rights reserved.
//

import UIKit

class DormTableViewController: FoodTableViewController {
//	var information = DayInfo()
	
	var dormCVC: DormContainerViewController?
	
	override func viewDidLoad() {
		super.viewDidLoad()
		
		setTitle()
	}
	
	override func preferredTitle() -> String {
		var formatter = NSDateFormatter()
		
		let dateFormat = "EEEE, MMMM d"
		let dayFormat = "d"
		let suffixes = ["th", "st", "nd", "rd"]
		
		formatter.dateFormat = dayFormat
		var day = formatter.stringFromDate(information.date)
		var dayIndex = NSString(string: day).integerValue
		if dayIndex > 3 {
			dayIndex = 0
		}
		
		formatter.dateFormat = dateFormat
		var title = formatter.stringFromDate(information.date)
		
		return title + suffixes[dayIndex]
	}
	
	func setTitle() {
		var leftButton: UIBarButtonItem? = nil
		if (pageIndex != 0) {
			leftButton = UIBarButtonItem(title: "Today", style: .Plain, target: dormCVC, action: "jumpToFirst")
		}
		
		navigationItem.leftBarButtonItem = leftButton
		navigationItem.rightBarButtonItem = nil
		
		navigationItem.title = preferredTitle()
	}
	
	func setInformation(info: DayInfo) {
		information = info
		setTitle()
	}
	
//	override func tableView(tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
//		return (section == 0) ? 64.0 + 22.0 : 22.0
//	}
//	
//	override func tableView(tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
//		var height = (section == 0) ? 64.0 + 22.0 : 22.0
//		var width = self.tableView.frame.size.width
//		var mainView = UIView(frame: CGRect(x: 0, y: 0, width: 0.0, height: height))
//		mainView.frame.size.width = width
//		mainView.backgroundColor = .clearColor()
//		
//		var backingView = UIView(frame: CGRect(x: 0.0, y: 64.0, width: width, height: 22.0))
//		backingView.backgroundColor = UIColor(white: 247.0/255.0, alpha: 1.0)
//		
//		mainView.addSubview(backingView)
//		return mainView
//	}
	
//	override func tableView(tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
//		var header = UIView(frame: CGRect(x: 0, y: 0, width: tableView.frame.width, height: (section == 0) ? 64.0 : 0.0))
//		header.backgroundColor = .clearColor()
//		return header
//	}
}
