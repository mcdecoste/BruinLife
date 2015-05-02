//
//  SwipesTableViewController.swift
//  BruinLife
//
//  Created by Matthew DeCoste on 11/26/14.
//  Copyright (c) 2014 Matthew DeCoste. All rights reserved.
//

import UIKit

class SwipesTableViewController: UITableViewController {
	let scrollID = "swipeCell", displayID = "displayCell"
	
	let planTag = 10, weekTag = 20, dowTag = 30
	
	var model = SwipeModel()
	
	var planView: ScrollSelectionView?
	var weekView: ScrollSelectionView?
	var dayView: ScrollSelectionView?
	
	override func viewDidLoad() {
        super.viewDidLoad()
		
		self.navigationItem.leftBarButtonItem = UIBarButtonItem(title: "Today", style: .Plain, target: self, action: "revertToToday")
		self.navigationItem.title = "Swipe Counter"
    }
	
	override func viewDidAppear(animated: Bool) {
		super.viewDidAppear(animated)
		
		revertToToday()
		for (index, plan) in enumerate(model.plans) {
			if plan == model.mealPlan { planView?.scrollToPage(index) }
		}
	}

    // MARK: - Table view data source
	override func tableView(tableView: UITableView, heightForRowAtIndexPath indexPath: NSIndexPath) -> CGFloat {
		return indexPath.section == 0 ? 66.0 : 88.0
	}
	
    override func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return 2 // Return the number of sections.
    }

    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
		// row 0: pick plan		row 1: pick week	row 2: pick day of week
		// row 0: display # of swipes
		return section == 0 ? 3 : 1 // Return the number of rows in the section.
    }
	
	override func tableView(tableView: UITableView, titleForFooterInSection section: Int) -> String? {
		var displayText = model.currentWeekAndQuarter().quarter == nil ? "It doesn't appear to be any quarter right now." : "Will likely differ from your actual swipe count."
		return section == 1 ? displayText : nil
	}
	
    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
		if indexPath.section == 0 {
			let cell = tableView.dequeueReusableCellWithIdentifier(scrollID, forIndexPath: indexPath) as! ScrollSelectionTableViewCell
			cell.selectionStyle = .None
			
			// Configure the cell...
			var strArray = [String]()
			
			switch indexPath.row {
			case 0:
				planView = cell.clipView
				planView?.scrollView.tag = planTag
				for (index, plan) in enumerate(model.plans) { strArray.append(plan.rawValue) }
			case 1:
				weekView = cell.clipView
				weekView?.scrollView.tag = weekTag
				for (index, week) in enumerate(model.weeks) { strArray.append(week.rawValue) }
			default:
				dayView = cell.clipView
				dayView?.scrollView.tag = dowTag
				for (index, dow) in enumerate(model.daysOfWeek) { strArray.append(dow.rawValue) }
			}
			cell.clipView.scrollView.delegate = self
			cell.setEntries(strArray)
			cell.layoutSubviews()
			
			return cell
		} else {
			let cell = tableView.dequeueReusableCellWithIdentifier(displayID, forIndexPath: indexPath) as! UITableViewCell
			cell.selectionStyle = .None
			
			// Configure the cell...
			let swipes = model.swipesForDay
			cell.textLabel?.font = .systemFontOfSize(20)
			
			if cell.bounds.width <= 320 { // 4" screen or smaller
				cell.textLabel?.text = "You should have \(swipes) swipe" + (swipes == 1 ? "" : "s") + " left."
			} else {
				cell.textLabel?.attributedText = attributedDisplay(swipes)
			}
			
			return cell
		}
    }
	
	func attributedDisplay(swipes: Int) -> NSAttributedString {
		var titlePart1 = "You should have "
		var titlePart2 = "\(swipes)"
		var titlePart3 = " swipe" + (swipes == 1 ? "" : "s") + " left."
		var attrString = NSMutableAttributedString(string: titlePart1 + titlePart2 + titlePart3)
		var range = NSMakeRange(NSString(string: titlePart1).length, NSString(string: titlePart2).length)
		attrString.addAttribute(NSFontAttributeName, value: UIFont.systemFontOfSize(28), range: range)
		attrString.addAttribute(NSBaselineOffsetAttributeName, value: -3.0, range: range)
		return NSAttributedString(attributedString: attrString)
	}
	
	override func scrollViewDidScroll(scrollView: UIScrollView) {
		var index = Int((scrollView.contentOffset.x / scrollView.frame.size.width) + 0.5) // the + 0.5 is to round evenly
		if index < 0 { index = 0 }
		
		var reload = true
		switch scrollView.tag {
		case planTag:
			if index >= model.plans.count { index = model.plans.count - 1 }
			model.mealPlan = model.plans[index]
		case weekTag:
			if index >= model.weeks.count { index = model.weeks.count - 1 }
			model.selectedWeek = index
		case dowTag:
			if index >= model.daysOfWeek.count { index = model.daysOfWeek.count - 1 }
			model.selectedDay = index
		default:
			reload = false
		}
		
		if reload { tableView.reloadRowsAtIndexPaths([NSIndexPath(forRow: 0, inSection: 1)], withRowAnimation: .None) }
		self.navigationItem.leftBarButtonItem?.enabled = !model.sameAsCurrent
	}
	
	func revertToToday() {
		model.resetToCurrent()
		weekView?.scrollToPage(model.selectedWeek)
		dayView?.scrollToPage(model.selectedDay)
	}
}