//
//  DormContainerViewController.swift
//  BruinLife
//
//  Created by Matthew DeCoste on 12/3/14.
//  Copyright (c) 2014 Matthew DeCoste. All rights reserved.
//

import UIKit

class DormContainerViewController: UIViewController, UIPageViewControllerDataSource, UIPageViewControllerDelegate {
	var pageController = UIPageViewController(transitionStyle: .Scroll, navigationOrientation: UIPageViewControllerNavigationOrientation.Horizontal, options: [UIPageViewControllerOptionInterPageSpacingKey : 0.0]) // good default is 32.0, tight is 0.0
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
	
	func nextWeek() -> Array<DayInfo> {
		var week: Array<DayInfo> = []
		for index in 0...6 {
			var daysDate = NSDate(timeIntervalSinceNow: Double(index * Int(timeInDay)))
			week.append(exampleDayForDate(daysDate))
		}
		
		return week
	}
	
	func exampleDayForDate(date: NSDate) -> DayInfo {
		let bOpen = Time(hour: 7, minute: 0)
		let bClose = Time(hour: 11, minute: 0)
		
		let lOpen = Time(hour: 11, minute: 0) // 11
		let lClose = Time(hour: 14, minute: 0)
		
		let dOpen = Time(hour: 17, minute: 0)
		let dClose = Time(hour: 20, minute: 0)
		
		var breakfast = MealInfo(halls: [.DeNeve : RestaurantInfo(hall: .DeNeve), .BruinPlate : RestaurantInfo(hall: .BruinPlate)])
		var lunch = MealInfo(halls: [.DeNeve : RestaurantInfo(hall: .DeNeve), .Covel : RestaurantInfo(hall: .Covel), .Feast : RestaurantInfo(hall: .Feast), .BruinPlate : RestaurantInfo(hall: .BruinPlate)])
		var dinner = MealInfo(halls: [.DeNeve : RestaurantInfo(hall: .DeNeve), .Covel : RestaurantInfo(hall: .Covel), .Feast : RestaurantInfo(hall: .Feast), .BruinPlate : RestaurantInfo(hall: .BruinPlate)])
		
		for key in breakfast.halls.keys {
			breakfast.halls[key]?.openTime = bOpen
			breakfast.halls[key]?.closeTime = bClose
		}
		for key in lunch.halls.keys {
			breakfast.halls[key]?.openTime = lOpen
			breakfast.halls[key]?.closeTime = lClose
		}
		for key in dinner.halls.keys {
			dinner.halls[key]?.openTime = dOpen
			dinner.halls[key]?.closeTime = dClose
		}
		
		return DayInfo(date: date, meals: [.Breakfast : breakfast, .Lunch : lunch, .Dinner : dinner])
	}
	
	func jumpToFirst() {
		pageController.setViewControllers([vcForIndex(0)], direction: .Reverse, animated: true, completion: nil)
	}
}
