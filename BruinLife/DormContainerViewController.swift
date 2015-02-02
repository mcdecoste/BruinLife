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
	var pageController = UIPageViewController(transitionStyle: .Scroll, navigationOrientation: UIPageViewControllerNavigationOrientation.Horizontal, options: [UIPageViewControllerOptionInterPageSpacingKey : 0.0]) // good default is 32.0, tight is 0.0
	let pageStoryboardID = "dormTableView"
	
	override func viewDidLoad() {
		super.viewDidLoad()
		// Do any additional setup after loading the view.
		pageController.dataSource = self
		pageController.delegate = self
		pageController.view.frame = view.bounds
		
		CloudManager.sharedInstance.fetchRecords("DiningDay", completion: { (records: Array<CKRecord>) -> Void in
			if records == [] {
				// handle error case
				self.dormVCfromNavVC(self.pageController.viewControllers[0] as UINavigationController).loadFailed()
			}
		})
		
		pageController.setViewControllers([vcForIndex(0)], direction: .Forward, animated: false, completion: nil)
		
		addChildViewController(pageController)
		view.addSubview(pageController.view)
		
		view.backgroundColor = UIColor(white: 247.0/255.0, alpha: 1.0)
	}
	
	// UIPageViewControllerDataSource
	func pageViewController(pageViewController: UIPageViewController, viewControllerBeforeViewController viewController: UIViewController) -> UIViewController? {
		viewController.navigationItem.leftBarButtonItem = nil
		viewController.navigationItem.rightBarButtonItem = nil
		let index = dormVCfromNavVC(viewController as UINavigationController).pageIndex
		if index == 0 { return nil }
		return vcForIndex(index - 1)
	}
	
	func pageViewController(pageViewController: UIPageViewController, viewControllerAfterViewController viewController: UIViewController) -> UIViewController? {
		let index = dormVCfromNavVC(viewController as UINavigationController).pageIndex
		if index == 6 { return nil }
		return vcForIndex(index + 1)
	}
	
	func dormVCfromNavVC(navVC: UINavigationController) -> DormTableViewController {
		return navVC.viewControllers[0] as DormTableViewController
	}
	
	// UIPageViewControllerDelegate
	func pageViewController(pageViewController: UIPageViewController, didFinishAnimating finished: Bool, previousViewControllers: [AnyObject], transitionCompleted completed: Bool) {
		if completed {
			
		}
	}
	
	func vcForIndex(index: Int) -> UINavigationController {
		var vc = storyboard?.instantiateViewControllerWithIdentifier(pageStoryboardID) as DormTableViewController
		vc.pageIndex = index
		
		let date = comparisonDate(daysInFuture: index)
		let infoStr = CloudManager.sharedInstance.fetchDiningDay(date)
		vc.information = DayInfo(date: date, formattedString: infoStr)
		vc.dateMeals = orderedMeals(vc.information.meals.keys.array)
		vc.dormCVC = self
		
		var navVC = UINavigationController(rootViewController: vc)
		return navVC
	}
	
	func jumpToFirst() {
		pageController.setViewControllers([vcForIndex(0)], direction: .Reverse, animated: true, completion: nil)
	}
}
