//
//  QuickTableViewController.swift
//  BruinLife
//
//  Created by Matthew DeCoste on 11/26/14.
//  Copyright (c) 2014 Matthew DeCoste. All rights reserved.
//

import UIKit

class QuickTableViewController: FoodTableViewController {
	
	override func viewDidLoad() {
		super.viewDidLoad()
		
		self.navigationItem.title = "Quick Service"
		
		dataArray = [	RestaurantInfo(restName: "Bruin Cafe"),
						RestaurantInfo(restName: "1919"),
						RestaurantInfo(restName: "Rendezvous"),
						RestaurantInfo(restName: "Late Night")		]
		
		//		NSNotificationCenter.defaultCenter().addObserver(self, selector: "localeChanged:", name: NSCurrentLocaleDidChangeNotification, object: nil)
	}
	
	//	override func dealloc() {
	//		NSNotificationCenter.defaultCenter().removeObserver(self, name: NSCurrentLocaleDidChangeNotification, object: nil)
	//	}
	
//	func localeChanged(notif: NSNotification) {
//		tableView.reloadData()
//	}
	
//	override func didReceiveMemoryWarning() {
//		super.didReceiveMemoryWarning()
//		// Dispose of any resources that can be recreated.
//	}
	
}