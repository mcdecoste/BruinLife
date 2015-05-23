//
//  DormContainerViewController.swift
//  BruinLife
//
//  Created by Matthew DeCoste on 12/3/14.
//  Copyright (c) 2014 Matthew DeCoste. All rights reserved.
//

import UIKit

class DormContainerViewController: UIViewController, UIPageViewControllerDataSource, UIPageViewControllerDelegate, UIPopoverPresentationControllerDelegate {
	private var currIndex: Int = 0 {
		didSet {
			if let todayButton = navigationItem.leftBarButtonItem {
				todayButton.enabled = currIndex != 0
			}
			if let titleDisplay = navigationItem.titleView as? DayDisplay {
				titleDisplay.dayIndex = currIndex
			}
		}
	}
	var pageController = UIPageViewController(transitionStyle: .Scroll, navigationOrientation: .Horizontal, options: [UIPageViewControllerOptionInterPageSpacingKey : 32.0])
	let pageStoryboardID = "dormTableView"
	
	override func viewDidLoad() {
		super.viewDidLoad()
		// page controller setup
		pageController.dataSource = self
		pageController.delegate = self
		pageController.view.frame = view.bounds
		pageController.view.backgroundColor = tableBackgroundColor
		addChildViewController(pageController)
		view.addSubview(pageController.view)
		
		navigationItem.leftBarButtonItem = UIBarButtonItem(title: "Today", style: .Plain, target: self, action: "jumpToFirst")
		currIndex = 0
	}
	
	override func viewWillAppear(animated: Bool) {
		super.viewWillAppear(animated)
		loadMoreDays()
	}
	
	override func viewDidAppear(animated: Bool) {
		super.viewDidAppear(animated)
		
		// if (no displayed view controller) or (empty displayed controller), update
		if let first = pageController.viewControllers.first as? UINavigationController where first.viewControllers.count != 0 {
		} else {
			pageController.setViewControllers([vcForIndex(0)], direction: .Forward, animated: true, completion: nil)
		}
	}
	
	// MARK:- Navigation Item
	
	/// Show the popover for what day to pick
	func showDays() {
		if let popVC = storyboard?.instantiateViewControllerWithIdentifier("comingWeek") as? ComingWeekTableViewController {
			popVC.modalPresentationStyle = UIModalPresentationStyle.Popover
			popVC.preferredContentSize = popVC.preferredContentSize
			
			if let controller = popVC.popoverPresentationController {
				controller.delegate = self
				controller.permittedArrowDirections = .Up
				if let display = navigationItem.titleView as? DayDisplay {
					controller.sourceView = display
					controller.sourceRect = display.bounds
				}
			}
			
			presentViewController(popVC, animated: true, completion: nil)
		}
	}
	
	func jumpToFirst() {
		didPickDay(0)
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
		
		pageController.setViewControllers([vcForIndex(newIndex)], direction: direction, animated: false, completion: nil)
	}
	
	/// Update the navigation item based on the newly presented view controller
	func updateNavItem(vc: DormTableViewController?) {
		if let dormVC = vc {
			currIndex = daysInFuture(dormVC.information.date)
			createDayDisplayIfNecessary(dormVC)
		}
	}
	
	func createDayDisplayIfNecessary(vc: DormTableViewController) {
		if navigationItem.titleView as? DayDisplay == nil {
			navigationItem.titleView = vc.preferredTitleView
			(navigationItem.titleView as! DayDisplay).addTarget(self, action: "showDays", forControlEvents: .TouchUpInside)
		}
	}
	
	// MARK: - Helpers
	func loadMoreDays() {
		CloudManager.sharedInstance.downloadNewRecords(completion: { (error: NSError!) -> Void in
			if let err = error where self.pageController.viewControllers.count > 0 {
				self.dormVCfromIndex(0)?.loadFailed(err)
			}
		})
	}
	
	func dormVCfromIndex(index: Int) -> DormTableViewController? {
		return dormVCfromNavVC(pageController.viewControllers[index] as? UINavigationController)
	}
	
	func dormVCfromNavVC(navVC: UINavigationController?) -> DormTableViewController? {
		return navVC?.viewControllers.first as? DormTableViewController
	}
	
	func vcForIndex(index: Int) -> UINavigationController {
		if let vc = storyboard?.instantiateViewControllerWithIdentifier(pageStoryboardID) as? DormTableViewController {
			vc.information.date = comparisonDate(index)
			vc.informationData = CloudManager.sharedInstance.diningDay(vc.information.date)?.data ?? NSData()
			vc.dormCVC = self
			
			return UINavigationController(rootViewController: vc)
		}
		return UINavigationController()
	}
	
	// MARK:- UIPopoverPresentationControllerDelegate
	func adaptivePresentationStyleForPresentationController(controller: UIPresentationController) -> UIModalPresentationStyle {
		return .None
	}
	
	func popoverPresentationControllerDidDismissPopover(popoverPresentationController: UIPopoverPresentationController) {
		
	}
	
	// MARK: - UIPageViewControllerDataSource
	func pageViewController(pageViewController: UIPageViewController, viewControllerBeforeViewController viewController: UIViewController) -> UIViewController? {
		if let dormVC = dormVCfromNavVC(viewController as? UINavigationController) {
			let index = daysInFuture(dormVC.information.date)
			if index > 0 {
				return vcForIndex(index - 1)
			}
		}
		return nil
	}
	
	func pageViewController(pageViewController: UIPageViewController, viewControllerAfterViewController viewController: UIViewController) -> UIViewController? {
		if let dormVC = dormVCfromNavVC(viewController as? UINavigationController) {
			let index = daysInFuture(dormVC.information.date)
			if index < 6 {
				return vcForIndex(index + 1)
			}
		}
		return nil
	}
	
	// MARK:- UIPageViewControllerDelegate
	func pageViewController(pageViewController: UIPageViewController, didFinishAnimating finished: Bool, previousViewControllers: [AnyObject], transitionCompleted completed: Bool) {
		// only update if transition cancelled ("willTransition" handles otherwise)
		if completed { updateNavItem(dormVCfromIndex(0)) }
	}
	
	func pageViewController(pageViewController: UIPageViewController, willTransitionToViewControllers pendingViewControllers: [AnyObject]) {
		if let first = pendingViewControllers.first as? UINavigationController {
			updateNavItem(dormVCfromNavVC(first))
		}
	}
}
