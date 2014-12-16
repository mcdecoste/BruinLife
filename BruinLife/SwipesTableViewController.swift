//
//  SwipesTableViewController.swift
//  BruinLife
//
//  Created by Matthew DeCoste on 11/26/14.
//  Copyright (c) 2014 Matthew DeCoste. All rights reserved.
//

import UIKit

class SwipesTableViewController: UITableViewController {
	let scrollID = "swipeCell"
	let displayID = "displayCell"
	
	let planTag = 10
	let weekTag = 20
	let dowTag = 30
	
	var model = SwipeModel()
	
	var planView: ScrollSelectionView?
	var weekView: ScrollSelectionView?
	var dayView: ScrollSelectionView?
	
	override func viewDidLoad() {
        super.viewDidLoad()
		
		self.navigationItem.leftBarButtonItem = UIBarButtonItem(title: "Now", style: .Plain, target: self, action: "revertToToday")
		self.navigationItem.title = "Swipe Counter"
    }
	
	override func viewDidAppear(animated: Bool) {
		super.viewDidAppear(animated)
		
		revertToToday()
		
		for (index, plan) in enumerate(model.plans) {
			if plan == model.mealPlan.plan {
				planView?.scrollToPage(index)
				break
			}
		}
	}
	
	override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    // MARK: - Table view data source
	
	override func tableView(tableView: UITableView, heightForRowAtIndexPath indexPath: NSIndexPath) -> CGFloat {
		return indexPath.section == 0 ? 66.0 : 88.0
	}
	
    override func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        // Return the number of sections.
		return 2
    }

    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        // Return the number of rows in the section.
		
		// row 0: pick plan		row 1: pick week	row 2: pick day of week
		// row 0: display # of swipes
		return section == 0 ? 3 : 1
    }
	
	override func tableView(tableView: UITableView, titleForFooterInSection section: Int) -> String? {
		switch section {
		case 0:
			return nil
		default:
			return "Will likely differ from your actual swipe count."
		}
	}
	
    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
		if indexPath.section == 0 {
			let cell = tableView.dequeueReusableCellWithIdentifier(scrollID, forIndexPath: indexPath) as ScrollSelectionTableViewCell
			
			cell.selectionStyle = .None
			
			// Configure the cell...
			var strArray: Array<String> = []
			
			switch indexPath.row {
			case 0:
				planView = cell.clipView
				planView?.scrollView.tag = planTag
				for (index, plan) in enumerate(model.plans) {
					strArray.append(plan.rawValue)
				}
			case 1:
				weekView = cell.clipView
				weekView?.scrollView.tag = weekTag
				for (index, week) in enumerate(model.weeks) {
					strArray.append(week.rawValue)
				}
			default:
				dayView = cell.clipView
				dayView?.scrollView.tag = dowTag
				for (index, dow) in enumerate(model.daysOfWeek) {
					strArray.append(dow.rawValue)
				}
			}
			cell.clipView.scrollView.delegate = self
			cell.setEntries(strArray)
			cell.layoutSubviews()
			
			return cell
		} else {
			let cell = tableView.dequeueReusableCellWithIdentifier(displayID, forIndexPath: indexPath) as UITableViewCell
			
			cell.selectionStyle = .None
			
			// Configure the cell...
			var swipes = 0
			if indexPath.section == 1 {
				swipes = model.swipesForSelectedDayAndTime()
			} else {
				swipes = model.swipesForSelectedDay()
			}
			
			cell.textLabel?.font = .systemFontOfSize(20)
			
			if indexPath.section == 1 {
				cell.textLabel?.text = "You should have \(swipes) swipe" + (swipes == 1 ? "" : "s") + " left."
			} else {
				cell.textLabel?.text = "After today you'll have \(swipes)."
			}
			
			return cell
		}
    }
	
	override func scrollViewDidScroll(scrollView: UIScrollView) {
		var index = Int((scrollView.contentOffset.x / scrollView.frame.size.width) + 0.5) // the + 0.5 is to round evenly
		
		var reload = true
		
		switch scrollView.tag {
		case planTag:
			model.mealPlan.setPlan(model.plans[index])
		case weekTag:
			model.selectedWeek = index
		case dowTag:
			model.selectedDay = index
		default:
			reload = false
		}
		
		if reload {
			tableView.reloadRowsAtIndexPaths([NSIndexPath(forRow: 0, inSection: 1)], withRowAnimation: .None) // , NSIndexPath(forRow: 0, inSection: 2)
		}
		
		self.navigationItem.leftBarButtonItem?.enabled = !model.sameAsCurrent()
	}
	
	func revertToToday() {
		model.resetToCurrent()
		weekView?.scrollToPage(model.selectedWeek)
		dayView?.scrollToPage(model.selectedDay)
	}
}