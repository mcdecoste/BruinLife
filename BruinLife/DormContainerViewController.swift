//
//  DormContainerViewController.swift
//  BruinLife
//
//  Created by Matthew DeCoste on 12/3/14.
//  Copyright (c) 2014 Matthew DeCoste. All rights reserved.
//

import UIKit

class DormContainerViewController: UIViewController, UIPageViewControllerDataSource, UIPageViewControllerDelegate {
	var pageController = UIPageViewController(transitionStyle: .Scroll, navigationOrientation: UIPageViewControllerNavigationOrientation.Horizontal, options: [UIPageViewControllerOptionInterPageSpacingKey : 0.0]) // good default is 32.0
	var pageInfo: Array<DayInfo> = []
	var currIndex = 0
	
	var pageStoryboardID = "dormTableView"
	
	override func viewDidLoad() {
		super.viewDidLoad()
		// Do any additional setup after loading the view.
		pageController.dataSource = self
		pageController.delegate = self
		pageController.view.frame = view.bounds
		
		pageInfo = nextWeek()
		
		pageController.setViewControllers([vcForIndex(currIndex)], direction: .Forward, animated: false, completion: nil)
		
		self.addChildViewController(pageController)
		view.addSubview(pageController.view)
		
		view.backgroundColor = UIColor(white: 247.0/255.0, alpha: 1.0)
	}
	
	// UIPageViewControllerDataSource
	
	func pageViewController(pageViewController: UIPageViewController, viewControllerBeforeViewController viewController: UIViewController) -> UIViewController? {
		viewController.navigationItem.leftBarButtonItem = nil
		viewController.navigationItem.rightBarButtonItem = nil
		var pageVC = dormVCfromNavVC(viewController as UINavigationController)
		var index = pageVC.pageIndex
		if index == 0 {
			return nil
		}
		return vcForIndex(index - 1)
	}
	
	func pageViewController(pageViewController: UIPageViewController, viewControllerAfterViewController viewController: UIViewController) -> UIViewController? {
		var pageVC = dormVCfromNavVC(viewController as UINavigationController)
		var index = pageVC.pageIndex
		if index == pageInfo.count - 1 {
			return nil
		}
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
		vc.dormCVC = self
		
		var navVC = UINavigationController(rootViewController: vc)
		return navVC
	}
	
	func secsInDay() -> Int {
		return 24 * 60 * 60
	}
	
	func nextWeek() -> Array<DayInfo> {
		var secondsInDay = secsInDay()
		
		var week: Array<DayInfo> = []
		for index in 0...6 {
			var interval = index * secondsInDay
			var daysDate = NSDate(timeIntervalSinceNow: Double(interval))
			week.append(exampleDayForDate(daysDate))
		}
		
		return week
	}
	
	func exampleDayForDate(date: NSDate) -> DayInfo {
		var example = [RestaurantInfo(restName: "De Neve"),
			RestaurantInfo(restName: "Covel"),
			RestaurantInfo(restName: "Feast"),
			RestaurantInfo(restName: "Hedrick"),
			RestaurantInfo(restName: "Sproul")]
		
		var exampleBreakfast = MealInfo(meal: .Breakfast, rests: example)
//		var exampleBrunch = MealInfo(rests: [])
		var exampleLunch = MealInfo(meal: .Lunch, rests: example)
		var exampleDinner = MealInfo(meal: .Dinner, rests: example)
		
		return DayInfo(date: date, restForMeal: [exampleBreakfast, exampleLunch, exampleDinner])
	}
	
	func jumpToFirst() {
		pageController.setViewControllers([vcForIndex(0)], direction: .Reverse, animated: true, completion: nil)
	}
}
