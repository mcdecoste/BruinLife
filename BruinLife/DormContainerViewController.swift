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
	var pageInfo = [DayInfo]()
	var currIndex = 0
	let pageStoryboardID = "dormTableView"
	
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
		var week = [DayInfo]()
		for index in 0...6 {
			var daysDate = NSDate(timeIntervalSinceNow: Double(index * Int(timeInDay)))
			week.append(exampleDay(daysDate))
		}
		
		return week
	}
	
	// TODO: replace this with real data
	func exampleDay(date: NSDate) -> DayInfo {
		var breakfast = exampleDayHelper([.DeNeve, .BruinPlate], open: Time(hour: 7, minute: 0), close: Time(hour: 11, minute: 0))
		var lunch = exampleDayHelper([.DeNeve, .BruinPlate, .Covel, .Feast], open: Time(hour: 11, minute: 0), close: Time(hour: 14, minute: 0))
		var dinner = exampleDayHelper([.DeNeve, .BruinPlate, .Covel, .Feast], open: Time(hour: 17, minute: 0), close: Time(hour: 20, minute: 0))
		
		return DayInfo(date: date, meals: [.Breakfast : breakfast, .Lunch : lunch, .Dinner : dinner])
	}
	
	/// helper method for showing example day
	func exampleDayHelper(halls: Array<Halls>, open: Time, close: Time) -> MealInfo {
		var meal: Dictionary<Halls, RestaurantInfo> = Dictionary()
		for hall in halls { meal[hall] = RestaurantInfo(hall: hall) }
		
		var mealInfo = MealInfo(halls: meal)
		for key in mealInfo.halls.keys {
			mealInfo.halls[key]?.openTime = open
			mealInfo.halls[key]?.closeTime = close
			
			var section1 = SectionInfo(name: "Exhibition Kitchen")
			section1.foods = defaultFoods()
			var section2 = SectionInfo(name: "Soups")
			section2.foods = defaultFoods()
			mealInfo.halls[key]?.sections = [section1, section2]
		}
		
		return mealInfo
	}
	
	func jumpToFirst() {
		pageController.setViewControllers([vcForIndex(0)], direction: .Reverse, animated: true, completion: nil)
	}
}
