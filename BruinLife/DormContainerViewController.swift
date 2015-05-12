//
//  DormContainerViewController.swift
//  BruinLife
//
//  Created by Matthew DeCoste on 12/3/14.
//  Copyright (c) 2014 Matthew DeCoste. All rights reserved.
//

import UIKit
import CloudKit
import CoreData

class DormContainerViewController: UIViewController, UIPageViewControllerDataSource, UIPageViewControllerDelegate, UIPopoverPresentationControllerDelegate {
	private var currIndex: Int = 0 {
		didSet {
			navigationItem.leftBarButtonItem?.enabled = currIndex != 0
			if let titleDisplay = navigationItem.titleView as? DayDisplay {
				titleDisplay.dayIndex = currIndex
			}
		}
	}
	var pageController = UIPageViewController(transitionStyle: .Scroll, navigationOrientation: .Horizontal, options: [UIPageViewControllerOptionInterPageSpacingKey : 32.0])
	let pageStoryboardID = "dormTableView"
	
	override func viewDidLoad() {
		super.viewDidLoad()
		// Do any additional setup after loading the view.
		pageController.dataSource = self
		pageController.delegate = self
		pageController.view.frame = view.bounds
		
		// true if we don't have today's data yet. False if we have data
		if CloudManager.sharedInstance.fetchDiningDay(comparisonDate()) == "" {
			CloudManager.sharedInstance.fetchNewRecords(completion: { (error: NSError!) -> Void in
				if error != nil {
					// handle error case
					self.dormVCfromIndex(0).loadFailed(error)
				}
			})
		}
		
		// TODO: create proper shell to show for before loading
		pageController.setViewControllers([UINavigationController()], direction: .Forward, animated: false, completion: nil)
		addChildViewController(pageController)
		view.addSubview(pageController.view)
		
		var leftBar = UIBarButtonItem(title: "Today", style: .Plain, target: self, action: "jumpToFirst")
		leftBar.enabled = false
		navigationItem.leftBarButtonItem = leftBar
		
		pageController.view.backgroundColor = tableBackgroundColor
	}
	
	override func viewWillAppear(animated: Bool) {
		super.viewWillAppear(animated)
		
		if CloudManager.sharedInstance.findFirstGap() <= 10 {
			loadMoreDays()
		}
	}
	
	override func viewDidAppear(animated: Bool) {
		super.viewDidAppear(animated)
		
		if (pageController.viewControllers[0] as! UINavigationController).viewControllers.count == 0 {
			pageController.setViewControllers([vcForIndex(0)], direction: .Forward, animated: false, completion: nil)
		}
	}
	
	// MARK: - Helpers
	func loadMoreDays() {
		CloudManager.sharedInstance.fetchNewRecords(completion: { (error: NSError!) -> Void in })
	}
	
	func jumpToFirst() {
		didPickDay(0)
	}
	
	/// Show the popover for what day to pick
	func showDays() {
		let popVC = storyboard?.instantiateViewControllerWithIdentifier("comingWeek") as! ComingWeekTableViewController
		popVC.modalPresentationStyle = UIModalPresentationStyle.Popover
		popVC.preferredContentSize = popVC.preferredContentSize
		
		let controller = popVC.popoverPresentationController!
		controller.delegate = self
		controller.sourceView = navigationItem.titleView as! DayDisplay
		controller.sourceRect = (navigationItem.titleView as! DayDisplay).bounds
		controller.permittedArrowDirections = .Up
		
		(navigationItem.titleView as! DayDisplay).enabled = false
		presentViewController(popVC, animated: true, completion: nil)
	}
	
	func didPickDay(newIndex: Int) {
		let direction: UIPageViewControllerNavigationDirection
		switch newIndex {
		case currIndex:
			return
		case 0..<currIndex:
			direction = .Reverse
		default:
			direction = .Forward
		}
		
		pageController.setViewControllers([vcForIndex(newIndex)], direction: direction, animated: true, completion: nil)
	}
	
	func updateNavItem(vc: DormTableViewController) {
		currIndex = daysInFuture(vc.information.date)
		createDayDisplayIfNecessary(vc)
	}
	
	func createDayDisplayIfNecessary(vc: DormTableViewController) {
		if navigationItem.titleView as? DayDisplay == nil {
			navigationItem.titleView = vc.preferredTitleView
			(navigationItem.titleView as! DayDisplay).addTarget(self, action: "showDays", forControlEvents: .TouchUpInside)
		}
	}
	
	// MARK: UIPopoverPresentationControllerDelegate
	func adaptivePresentationStyleForPresentationController(controller: UIPresentationController) -> UIModalPresentationStyle {
		return .None
	}
	
	func popoverPresentationControllerDidDismissPopover(popoverPresentationController: UIPopoverPresentationController) {
		(navigationItem.titleView as! DayDisplay).enabled = true
	}
	
	// MARK: - UIPageViewControllerDataSource
	func pageViewController(pageViewController: UIPageViewController, viewControllerBeforeViewController viewController: UIViewController) -> UIViewController? {
		let index = daysInFuture(dormVCfromNavVC(viewController as! UINavigationController).information.date)
		if index == 0 { return nil }
		return vcForIndex(index - 1)
	}
	
	func pageViewController(pageViewController: UIPageViewController, viewControllerAfterViewController viewController: UIViewController) -> UIViewController? {
		let index = daysInFuture(dormVCfromNavVC(viewController as! UINavigationController).information.date)
		if index == 6 { return nil }
		return vcForIndex(index + 1)
	}
	
	func dormVCfromIndex(index: Int) -> DormTableViewController {
		return dormVCfromNavVC(pageController.viewControllers[index] as! UINavigationController)
	}
	
	func dormVCfromNavVC(navVC: UINavigationController) -> DormTableViewController {
		return navVC.viewControllers[0] as! DormTableViewController
	}
	
	// MARK: UIPageViewControllerDelegate
	func pageViewController(pageViewController: UIPageViewController, didFinishAnimating finished: Bool, previousViewControllers: [AnyObject], transitionCompleted completed: Bool) {
		updateNavItem(completed ? dormVCfromIndex(0) : dormVCfromNavVC(previousViewControllers[0] as! UINavigationController))
	}
	
	func pageViewController(pageViewController: UIPageViewController, willTransitionToViewControllers pendingViewControllers: [AnyObject]) {
		if pendingViewControllers.count != 0 {
			updateNavItem(dormVCfromNavVC(pendingViewControllers[0] as! UINavigationController))
		}
	}
	
	func vcForIndex(index: Int) -> UINavigationController {
		var vc = storyboard?.instantiateViewControllerWithIdentifier(pageStoryboardID) as! DormTableViewController
		
		var value = CloudManager.sharedInstance.fetchDiningDay(comparisonDate(index))
		vc.information.date = comparisonDate(index)
		vc.informationData = value
		vc.dormCVC = self
		
		var navVC = UINavigationController(rootViewController: vc)
		return navVC
	}
}
