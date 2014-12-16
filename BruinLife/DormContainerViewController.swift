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
	
	override func didReceiveMemoryWarning() {
		super.didReceiveMemoryWarning()
		// Dispose of any resources that can be recreated.
	}
	
	func nextWeek() -> Array<DayInfo> {
		var secondsInDay = Int(timeInDay)
		
		var week: Array<DayInfo> = []
		for index in 0...6 {
			var interval = index * secondsInDay
			var daysDate = NSDate(timeIntervalSinceNow: Double(interval))
			week.append(exampleDayForDate(daysDate))
		}
		
		return week
	}
	
	func exampleDayForDate(date: NSDate) -> DayInfo {
		let bOpen = Time(hour: 7, minute: 0, pm: false)
		let bClose = Time(hour: 11, minute: 0, pm: false)
		
		let lOpen = Time(hour: 11, minute: 0, pm: false) // 11
		let lClose = Time(hour: 2, minute: 0, pm: true)
		
		let dOpen = Time(hour: 5, minute: 0, pm: true)
		let dClose = Time(hour: 8, minute: 0, pm: true)
		
		var breakfast = [RestaurantInfo(name: "De Neve", hall: .DeNeve, openTime: bOpen, closeTime: bClose), RestaurantInfo(name: "Bruin Plate", hall: .BruinPlate, openTime: bOpen, closeTime: bClose)]
		var lunch = [RestaurantInfo(name: "De Neve", hall: .DeNeve, openTime: lOpen, closeTime: lClose), RestaurantInfo(name: "Covel", hall: .Covel, openTime: lOpen, closeTime: lClose), RestaurantInfo(name: "Feast", hall: .Feast, openTime: lOpen, closeTime: lClose), RestaurantInfo(name: "Bruin Plate", hall: .BruinPlate, openTime: lOpen, closeTime: lClose)]
		var dinner = [RestaurantInfo(name: "De Neve", hall: .DeNeve, openTime: dOpen, closeTime: dClose), RestaurantInfo(name: "Covel", hall: .Covel, openTime: dOpen, closeTime: dClose), RestaurantInfo(name: "Feast", hall: .Feast, openTime: dOpen, closeTime: dClose), RestaurantInfo(name: "Bruin Plate", hall: .BruinPlate, openTime: dOpen, closeTime: dClose)]
		
		var exampleBreakfast = MealInfo(meal: .Breakfast, rests: breakfast)
		var exampleLunch = MealInfo(meal: .Lunch, rests: lunch)
		var exampleDinner = MealInfo(meal: .Dinner, rests: dinner)
		
		return DayInfo(date: date, restForMeal: [exampleBreakfast, exampleLunch, exampleDinner])
	}
	
	func jumpToFirst() {
		pageController.setViewControllers([vcForIndex(0)], direction: .Reverse, animated: true, completion: nil)
	}
}
