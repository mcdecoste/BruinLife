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

class DormContainerViewController: UIViewController, UIPageViewControllerDataSource, UIPageViewControllerDelegate {
	var pageController = UIPageViewController(transitionStyle: .Scroll, navigationOrientation: UIPageViewControllerNavigationOrientation.Horizontal, options: [UIPageViewControllerOptionInterPageSpacingKey : 32.0])
	let pageStoryboardID = "dormTableView"
	
	override func viewDidLoad() {
		super.viewDidLoad()
		// Do any additional setup after loading the view.
		pageController.dataSource = self
		pageController.delegate = self
		pageController.view.frame = view.bounds
		
		if CloudManager.sharedInstance.fetchDiningDay(comparisonDate()) == "" {
			CloudManager.sharedInstance.fetchNewRecords(completion: { (error: NSError!) -> Void in
				if error != nil {
					// handle error case
					self.dormVCfromIndex(0).loadFailed(error)
				} else {
					self.loadMoreDays() // load more days?
				}
			})
		} else {
			loadMoreDays()
		}
		
		// TODO: create empty shell to show for before loading
		pageController.setViewControllers([UINavigationController()], direction: .Forward, animated: false, completion: nil)
		addChildViewController(pageController)
		view.addSubview(pageController.view)
		
		navigationItem.leftBarButtonItem = UIBarButtonItem(title: "Today", style: .Plain, target: self, action: "jumpToFirst")
		navigationItem.leftBarButtonItem?.enabled = false
		
		navigationItem.rightBarButtonItem = UIBarButtonItem(title: "Days", style: .Plain, target: self, action: "showDays")
		navigationItem.rightBarButtonItem?.enabled = false
		
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
		
		if (pageController.viewControllers[0] as UINavigationController).viewControllers.count == 0 {
			pageController.setViewControllers([vcForIndex(0)], direction: .Forward, animated: false, completion: nil)
		}
	}
	
	// MARK: - Helpers
	func loadMoreDays() {
		CloudManager.sharedInstance.fetchNewRecords(completion: { (error: NSError!) -> Void in })
	}
	
	func jumpToFirst() {
		pageController.setViewControllers([vcForIndex(0)], direction: .Reverse, animated: true, completion: nil)
	}
	
	func showDays() {
		
	}
	
	func updateNavItem(vc: DormTableViewController) {
		navigationItem.leftBarButtonItem!.enabled = daysInFuture(vc.information.date) != 0
		navigationItem.title = vc.preferredTitle()
	}
	
	// MARK: - UIPageViewControllerDataSource
	func pageViewController(pageViewController: UIPageViewController, viewControllerBeforeViewController viewController: UIViewController) -> UIViewController? {
		viewController.navigationItem.leftBarButtonItem = nil
		viewController.navigationItem.rightBarButtonItem = nil
		let index = daysInFuture(dormVCfromNavVC(viewController as UINavigationController).information.date)
		if index == 0 { return nil }
		return vcForIndex(index - 1)
	}
	
	func pageViewController(pageViewController: UIPageViewController, viewControllerAfterViewController viewController: UIViewController) -> UIViewController? {
		let index = daysInFuture(dormVCfromNavVC(viewController as UINavigationController).information.date)
		if index == 6 { return nil }
		return vcForIndex(index + 1)
	}
	
	func dormVCfromIndex(index: Int) -> DormTableViewController {
		return dormVCfromNavVC(pageController.viewControllers[index] as UINavigationController)
	}
	
	func dormVCfromNavVC(navVC: UINavigationController) -> DormTableViewController {
		return navVC.viewControllers[0] as DormTableViewController
	}
	
	// MARK: UIPageViewControllerDelegate
	func pageViewController(pageViewController: UIPageViewController, didFinishAnimating finished: Bool, previousViewControllers: [AnyObject], transitionCompleted completed: Bool) {
		let vc = completed ? dormVCfromIndex(0) : dormVCfromNavVC(previousViewControllers[0] as UINavigationController)
		navigationItem.leftBarButtonItem?.enabled = daysInFuture(vc.information.date) != 0
		navigationItem.title = vc.preferredTitle()
	}
	
	func pageViewController(pageViewController: UIPageViewController, willTransitionToViewControllers pendingViewControllers: [AnyObject]) {
		if pendingViewControllers.count != 0 {
			let vc = dormVCfromNavVC(pendingViewControllers[0] as UINavigationController)
			navigationItem.leftBarButtonItem!.enabled = daysInFuture(vc.information.date) != 0
			navigationItem.title = vc.preferredTitle()
		}
	}
	
	func vcForIndex(index: Int) -> UINavigationController {
		var vc = storyboard?.instantiateViewControllerWithIdentifier(pageStoryboardID) as DormTableViewController
		vc.setInformationString(CloudManager.sharedInstance.fetchDiningDay(comparisonDate(daysInFuture: index)))
		vc.information.date = comparisonDate(daysInFuture: index)
		vc.dormCVC = self
		
		var navVC = UINavigationController(rootViewController: vc)
		return navVC
	}
}
