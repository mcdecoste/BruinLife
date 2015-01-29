//
//  DormContainerViewController.swift
//  BruinLife
//
//  Created by Matthew DeCoste on 12/3/14.
//  Copyright (c) 2014 Matthew DeCoste. All rights reserved.
//

import UIKit
import CloudKit

class DormContainerViewController: UIViewController, UIPageViewControllerDataSource, UIPageViewControllerDelegate {
	var pageController = UIPageViewController(transitionStyle: .Scroll, navigationOrientation: UIPageViewControllerNavigationOrientation.Horizontal, options: [UIPageViewControllerOptionInterPageSpacingKey : 0.0]) // good default is 32.0, tight is 0.0
	var pageInfo = [DayInfo]()
	var currIndex = 0
	let pageStoryboardID = "dormTableView"
	
	var cloudManager = CloudManager()
	
	override func viewDidLoad() {
		super.viewDidLoad()
		// Do any additional setup after loading the view.
		pageController.dataSource = self
		pageController.delegate = self
		pageController.view.frame = view.bounds
		
		pageInfo = nextWeek()
		
		cloudManager.fetchRecords("DiningDay", completion: { (records: Array<CKRecord>) -> Void in
			self.pageInfo = []
			for record in records {
				self.pageInfo.append(DayInfo(record: record))
			}
			
			self.pageController.setViewControllers([self.vcForIndex(self.currIndex)], direction: .Forward, animated: false, completion: nil)
		})
		
		pageController.setViewControllers([vcForIndex(currIndex)], direction: .Forward, animated: false, completion: nil)
		
		addChildViewController(pageController)
		view.addSubview(pageController.view)
		
		view.backgroundColor = UIColor(white: 247.0/255.0, alpha: 1.0)
	}
	
	// UIPageViewControllerDataSource
	func pageViewController(pageViewController: UIPageViewController, viewControllerBeforeViewController viewController: UIViewController) -> UIViewController? {
		viewController.navigationItem.leftBarButtonItem = nil
		viewController.navigationItem.rightBarButtonItem = nil
		var pageVC = dormVCfromNavVC(viewController as UINavigationController)
		var index = pageVC.pageIndex
		if index == 0 { return nil }
		return vcForIndex(index - 1)
	}
	
	func pageViewController(pageViewController: UIPageViewController, viewControllerAfterViewController viewController: UIViewController) -> UIViewController? {
		var pageVC = dormVCfromNavVC(viewController as UINavigationController)
		var index = pageVC.pageIndex
		if index == pageInfo.count - 1 { return nil }
		return vcForIndex(index + 1)
	}
	
	func dormVCfromNavVC(navVC: UINavigationController) -> DormTableViewController {
		return navVC.viewControllers[0] as DormTableViewController
	}
	
	// UIPageViewControllerDelegate
	func pageViewController(pageViewController: UIPageViewController, didFinishAnimating finished: Bool, previousViewControllers: [AnyObject], transitionCompleted completed: Bool) {
		if completed {
			// update the index
			currIndex = (dormVCfromNavVC(pageViewController.viewControllers[0] as UINavigationController)).pageIndex
		}
	}
	
	func vcForIndex(index: Int) -> UINavigationController { // DormTableViewController
		var vc = storyboard?.instantiateViewControllerWithIdentifier(pageStoryboardID) as DormTableViewController
		vc.pageIndex = index
		vc.information = pageInfo[index]
		vc.dateMeals = orderedMeals(Array(vc.information.meals.keys))
		vc.dormCVC = self
		
		var navVC = UINavigationController(rootViewController: vc)
		return navVC
	}
	
	func nextWeek() -> Array<DayInfo> {
		var week: Array<DayInfo> = []
		
		for index in 0...6 {
//			week.append(dayInfo(comparisonDate(NSDate(timeIntervalSinceNow: Double(index * Int(timeInDay))))))
			week.append(DayInfo()) // TODO: pull in any existing cache in Core Data?
		}
		
//		for index in 0...6 {
//			var daysDate = NSDate(timeIntervalSinceNow: Double(index * Int(timeInDay)))
//			week.append(exampleDay(daysDate))
//			
////			week.append(changeDateOfDay(day, toDate: daysDate))
//		}
		
		return week
	}
	
	func jumpToFirst() {
		pageController.setViewControllers([vcForIndex(0)], direction: .Reverse, animated: true, completion: nil)
	}
}
