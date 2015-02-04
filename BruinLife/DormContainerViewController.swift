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
	var pageController = UIPageViewController(transitionStyle: .Scroll, navigationOrientation: UIPageViewControllerNavigationOrientation.Horizontal, options: [UIPageViewControllerOptionInterPageSpacingKey : 32.0]) // good default is 32.0, tight is 0.0
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
		
//		view.backgroundColor = UIColor(white: 247.0/255.0, alpha: 1.0)
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
	
	func loadMoreDays() {
		CloudManager.sharedInstance.fetchNewRecords(completion: { (error: NSError!) -> Void in })
	}
	
	// UIPageViewControllerDataSource
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
	
	// UIPageViewControllerDelegate
//	func pageViewController(pageViewController: UIPageViewController, didFinishAnimating finished: Bool, previousViewControllers: [AnyObject], transitionCompleted completed: Bool) {
//		if completed {
//			
//		}
//	}
	
	func vcForIndex(index: Int) -> UINavigationController {
		var vc = storyboard?.instantiateViewControllerWithIdentifier(pageStoryboardID) as DormTableViewController
		vc.setInformationString(CloudManager.sharedInstance.fetchDiningDay(comparisonDate(daysInFuture: index)))
		vc.information.date = comparisonDate(daysInFuture: index)
		vc.dormCVC = self
		
		var navVC = UINavigationController(rootViewController: vc)
		return navVC
	}
	
	func jumpToFirst() {
		pageController.setViewControllers([vcForIndex(0)], direction: .Reverse, animated: true, completion: nil)
	}
}
